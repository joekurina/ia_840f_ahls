"""Offline revalidation of retained results for exactly the imported six variants."""
import datetime
import hashlib
import json
from pathlib import Path
import re
import shutil

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
OLD = HERE.parent / 'hls-samples-2026.1.0-01'
SOURCE = REPO / 'examples/ahls/hls-samples'
OUT = HERE / 'prior03'
assert not OUT.exists()


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path):
    return json.loads(path.read_text())


def check_output(text, cpu=False, floating=False, simulator=False):
    ignored = 'hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.'
    clean = '\n'.join(line for line in text.splitlines() if line != ignored)
    assert not re.search(r'\b(?:FAIL|FAILED)\b|\b(?:error|fatal)(?:\s+\([^)]*\))?\s*:|Caught[^\n]*SYCL[^\n]*exception|\bmismatch\b|\bErrors\s*:\s*[1-9]\d*', clean, re.I)
    assert re.search(r'^PASSED(?:: results are correct)?$', clean, re.M)
    if not floating:
        assert 'add two vectors of size 256' in text
    if not cpu:
        assert ('SimulatorDevice' if simulator else 'FPGA Emulation Device') in text
    return {'numerical_elements': 32 if floating else 256,
            'scope': 'original host numerical checks after completion/copyback',
            'mode': 'CPU' if cpu else 'RTL simulation' if simulator else 'FPGA emulation',
            'native_output': text}


provenance = load(SOURCE / 'UPSTREAM.json')
old_sources = load(OLD / 'source-release11-manifest.json')
assert provenance['commit'] == old_sources['commit'] == '0abae6d78af5daca3fe5d67e617ab037e58aff89'
for name, record in provenance['files'].items():
    assert sha(SOURCE / name) == record['sha256'] == old_sources['files'][name]['sha256'], name
OUT.mkdir()
manifest = {}
rows = []


def copy_checked(source, destination, expected=None):
    raw = source.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if expected is not None:
        assert digest == expected, str(source)
    assert len(raw) <= 2_000_000
    target = OUT / destination
    target.parent.mkdir(parents=True, exist_ok=True)
    assert not target.exists()
    shutil.copyfile(source, target)
    assert sha(target) == digest
    manifest[str(target.relative_to(HERE))] = {'bytes': len(raw), 'sha256': digest,
                                             'original_path': str(source.relative_to(REPO))}
    return str(target.relative_to(HERE))


def commands(base, native, selected, prefix):
    result = []
    for command in native['commands']:
        if not selected(command):
            continue
        assert command['rc'] == 0, command['label']
        path = base / command['log']
        assert path.stat().st_size == command['log_bytes']
        export = copy_checked(path, prefix + '/' + command['log'], command['log_sha256'])
        result.append(dict(command, published_log=export))
    return result


# The original CPU binary was built once; only its loader environment changed.
batch1 = OLD / 'remote-capture/batch01'
batch2 = OLD / 'remote-capture/batch02'
r1 = load(batch1 / 'result.json')
r2 = load(batch2 / 'result.json')
assert sha(batch2 / 'result.json') == load(OLD / 'gettingstarted-verification10.json')['result_sha256']
assert r2['success'] and r2['source_unchanged'] and not r2['hardware_access']
for part in r2['parts']:
    n = part['part']
    assert part['numerical_pass'] and part['cpu_or_emulator_native_rc'] == 0
    cs = commands(batch2, r2, lambda c: c['label'].startswith('part' + str(n) + '-'), 'compile' + str(n))
    if n == 1:
        cs = commands(batch1, r1, lambda c: c['label'] in ('part1-configure', 'part1-emulator-build'), 'compile1-original-build') + cs
    run = next(c for c in cs if c['label'].endswith('-emulator-run'))
    checked = check_output((HERE / run['published_log']).read_text(), cpu=n == 1)
    backend = []
    for log in part.get('backend_target_logs', []):
        text = (batch2 / log).read_text()
        assert '-target=AGFB027R25A2E2V' in text
        backend.append(copy_checked(batch2 / log, 'compile' + str(n) + '/' + log))
    for interface in part.get('generated_device_interfaces', []):
        assert sha(batch2 / interface['path']) == interface['sha256']
    rows.append({'id': 'compile' + str(n), 'sample': 'fpga_compile', 'PART': n,
                 'prior_receipt_sha256': sha(batch2 / 'result.json'), 'commands': cs,
                 'cpu_emulator': checked, 'report_pass': n != 1,
                 'backend_logs': backend, 'executable_sha256': part['executable_sha256'],
                 'verification_reused': True, 'new_execution': False})

# Each tutorial has a separate original emulator/report result.
fast_base = OLD / 'capture25/w1/s091'
fast = load(fast_base / 'result.json')
assert sha(fast_base / 'result.json') == next(r for r in load(OLD / 'tutorials-verification29.json')['rows'] if r['id'] == 's091')['result_sha256']
located = []
for worker in ('w0', 'w1', 'w2'):
    base = OLD / 'capture16' / worker
    native = load(base / 'result.json')
    if any(case['id'] == 's096' for case in native['cases']):
        assert sha(base / 'result.json') == load(OLD / 'batch12-verification22.json')['result_sha256s'][worker]
        located.append((base, native))
assert len(located) == 1
for sample, identifier, base, native in [('fast_recompile', 's091', fast_base, fast),
                                       ('fpga_template', 's096', *located[0])]:
    assert native['success'] and native['source_unchanged'] and not native['hardware_access']
    case = next(c for c in native['cases'] if c['id'] == identifier)
    assert case['emulator_pass'] and case['report_pass']
    cs = commands(base, native, lambda c: c['label'].startswith(identifier + '-'), sample)
    output = next(c for c in cs if c['label'].endswith('-emulator-run'))
    checked = check_output((HERE / output['published_log']).read_text(), floating=identifier == 's091')
    backend = []
    for log in case['backend_target_logs']:
        assert '-target=AGFB027R25A2E2V' in (base / log).read_text()
        backend.append(copy_checked(base / log, sample + '/' + log))
    for interface in case['generated_device_interfaces']:
        assert sha(base / interface['path']) == interface['sha256']
    rows.append({'id': sample, 'sample': sample, 'prior_receipt_sha256': sha(base / 'result.json'),
                 'commands': cs, 'cpu_emulator': checked, 'report_pass': True,
                 'backend_logs': backend, 'executable_sha256': case['executable_sha256'],
                 'verification_reused': True, 'new_execution': False})

# Accepted PART2/PART3 simulation includes native compile/run logs and wave hashes.
simulators = []
for n, identifier, rel, expected in [
    (2, 's093', 'capture31/w0/s093', load(OLD / 'simulator-verification31.json')['native_result_sha256']),
    (3, 's094', 'capture36/w0/s094', load(OLD / 'simulator-verification36.json')['results'][0]['native_result_sha256'])]:
    base = OLD / rel
    native = load(base / 'result.json')
    assert sha(base / 'result.json') == expected
    assert native['success'] and native['source_unchanged'] and not native['hardware_access']
    case = native['cases'][0]
    assert case['rtl_simulation'] and case['simulator_build']
    cs = commands(base, native, lambda c: c['label'].startswith(identifier + '-'), 'compile' + str(n) + '-sim')
    output = next(c for c in cs if c['label'].endswith('-simulator-run'))
    checked = check_output((HERE / output['published_log']).read_text(), simulator=True)
    collection = load(OLD / ('collection31.json' if n == 2 else 'collection36.json'))
    for waveform in case['waveform_files']:
        # The original collector hash-inventoried waveforms but did not transfer their bytes.
        key = 'w0/' + identifier + '/' + waveform['path']
        assert collection['artifacts'][key] == {'bytes': waveform['bytes'], 'sha256': waveform['sha256']}
    for log in case['backend_target_logs']:
        assert '-target=AGFB027R25A2E2V' in (base / log).read_text()
        copy_checked(base / log, 'compile' + str(n) + '-sim/' + log)
    simulators.append({'PART': n, 'commands': cs, 'numerical': checked,
                       'prior_receipt_sha256': expected, 'waveforms': case['waveform_files'],
                       'waveform_verification': 'Recorded original collector size/hash reconciled; waveform binary not locally retained or freshly rehashed'})

# PART4 reused the same successful simulator build after correcting its address limit.
recovery = OLD / 'capture47/sim-map46'
record = load(recovery / 'result.json')
verified = load(OLD / 'simulator-verification47.json')
assert record['native_test_pass'] and record['native_status']['strace_launcher_rc'] == 0
assert record['simulator_error_lines'] == [] and record['failed_mmaps'] == []
assert record['artifacts']['executable']['sha256'] == verified['root_cause_evidence']['unchanged_binary_sha256']
for name in ('program.log', 'syscalls.log'):
    assert sha(recovery / name) == record['artifacts'][name]['sha256']
check_output(record['program_output'], simulator=True)
copy_checked(recovery / 'program.log', 'compile4-sim/program.log', record['artifacts']['program.log']['sha256'])
copy_checked(OLD / 'simulator-verification47.json', 'compile4-sim/accepted-recovery.json')
copy_checked(OLD / 'simulator-verification36.json', 'compile4-sim/original-part3-part4-results.json')
simulators.append({'PART': 4, 'numerical': check_output(record['program_output'], simulator=True),
                   'native_status': record['native_status'], 'executable_sha256': record['artifacts']['executable']['sha256'],
                   'original_SIGABRT_preserved': True, 'recompiled': False,
                   'recovery_receipt_sha256': sha(recovery / 'result.json'),
                   'corrected_virtual_address_limit_bytes': record['virtual_address_limit_bytes']})
assert len(rows) == 6 and len(simulators) == 3
summary = {'verified_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
           'success': True, 'scope': 'Offline revalidation of prior CPU/emulator/report and PART2-4 simulation evidence against the imported original source bytes; no new native execution',
           'commit': provenance['commit'], 'source_files_verified': len(provenance['files']),
           'cases': rows, 'rtl_simulations': simulators, 'files': manifest,
           'counts': {'CPU_runs': 1, 'emulator_runs': 5, 'report_builds': 5, 'RTL_simulations': 3},
           'hardware_access': False,
           'local_verifier_correction': 'verify-prior02 incorrectly assumed hash-inventoried simulator waveform binaries were locally captured; partial prior02 exports and failed verifier retained. No native rerun.'}
with (HERE / 'prior-verification03.json').open('x') as stream:
    stream.write(json.dumps(summary, indent=2) + '\n')
print(json.dumps({'success': True, 'counts': summary['counts'], 'source_files_verified': summary['source_files_verified'], 'captured_evidence_files': len(manifest)}))
