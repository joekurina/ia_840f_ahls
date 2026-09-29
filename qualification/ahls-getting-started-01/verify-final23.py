"""Verify collected GettingStarted results offline; never execute vendor tools."""
import datetime
from decimal import Decimal
import hashlib
import json
from pathlib import Path
import re

E = Path(__file__).resolve().parent
N = E.parent.parent
V = N / 'examples/ahls/hls-samples'


def read(path):
    return json.loads(path.read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_collection(number):
    metadata = read(E / ('collection' + number + '.json'))
    root = E / ('capture' + number)
    for relative, record in metadata['files'].items():
        p = root / relative
        assert p.stat().st_size == record['bytes'] and digest(p) == record['sha256'], str(p)
    return metadata


provenance = read(V / 'UPSTREAM.json')
assert provenance['commit'] == '0abae6d78af5daca3fe5d67e617ab037e58aff89'
for relative, record in provenance['files'].items():
    assert (V / relative).stat().st_size == record['bytes']
    assert digest(V / relative) == record['sha256']
collections = {number: check_collection(number) for number in ('06', '15', '17', '20', '21')}
prior = read(E / 'prior-verification03.json')
assert prior['success'] and len(prior['cases']) == 6
for relative, record in prior['files'].items():
    assert (E / relative).stat().st_size == record['bytes'] and digest(E / relative) == record['sha256']
diag = read(E / 'diagnostic-disposition13.json')
for relative, record in diag['files'].items():
    assert (E / relative).stat().st_size == record['bytes'] and digest(E / relative) == record['sha256']
assert {r['sample']: len(r['diagnostics']) for r in diag['transcripts']} == {
    'part2': 6, 'part3': 6, 'part4': 6, 'template': 6, 'fast': 0}
new_sim = read(E / 'simulator-verification07.json')
assert new_sim['success']
assert new_sim['fast_recompile']['host_only_delta_exact']
assert new_sim['fast_recompile']['before_and_after_numerical_checks_passed']
assert new_sim['fast_recompile']['existing_image_extraction_observed']
assert not new_sim['fast_recompile']['device_payload_byte_identity_independently_verified']

ip = []
for identifier, number in [('compile2-ip', '15'), ('compile3-ip', '15'), ('compile4-ip', '15'),
                           ('fast-ip', '20'), ('template-ip', '21')]:
    base = E / ('capture' + number) / 'runs' / identifier
    result = read(base / 'result.json')
    assert result['success'] and result['effective_rc'] == 0 and result['source_unchanged']
    assert not result['hardware_access'] and result['real_card_execution'] is False
    assert result['pid_namespace'] != result['outer_pid_namespace']
    assert all(c['rc'] == 0 and c['helpers_drained'] and c['log_complete'] for c in result['commands'])
    for command in result['commands']:
        assert digest(base / command['log']) == command['log_sha256']
    for relative, record in result['report_files'].items():
        key = 'runs/' + identifier + '/' + relative
        actual = (collections[number]['files'].get(key) or collections[number].get('omitted', {}).get(key)
                  or collections['17']['files'].get(key))
        assert actual == record, (identifier, relative)
    stem = result['job']['stem']
    project = base / 'build' / (stem + '.fpga.prj')
    synthesis = (project / 'quartus_compile.syn.summary').read_text()
    fitter = (project / 'quartus_compile.fit.summary').read_text()
    timing_text = (project / 'quartus_compile.sta.summary').read_text()
    native_path = project / 'quartus_sh_compile.log'
    if not native_path.exists():
        native_path = E / 'capture17/runs' / identifier / 'build' / (stem + '.fpga.prj') / 'quartus_sh_compile.log'
    native = native_path.read_text()
    assert 'Synthesis Status : Successful' in synthesis and 'Fitter Status : Successful' in fitter
    assert 'Device : AGFB027R25A2E2V' in synthesis and 'Device : AGFB027R25A2E2V' in fitter
    assert '25.1.0 Build 129' in synthesis and '25.1.0 Build 129' in fitter
    assert re.search(r'Quartus Prime Full Compilation was successful\. 0 errors', native)
    assert re.search(r'Quartus Prime Fitter was successful\. 0 errors', native)
    assert re.search(r'Quartus Prime Timing Analyzer was successful\. 0 errors', native)
    assert not re.search(r'^\s*(?:Error|Fatal)(?:\s*\(\d+\))?\s*[:!]', native, re.I | re.M)
    assert re.search(r'Info \(332111\):\s+1\.000\s+clock', native)
    timing = [{'type': kind.strip(), 'slack_ns': slack, 'tns_ns': tns, 'corner': corner.strip()}
              for kind, slack, tns, corner in re.findall(
                  r'Type\s*:\s*([^\n]+)\nSlack\s*:\s*([-\d.]+)\nTNS\s*:\s*([-\d.]+)\nCorner\s*:\s*([^\n]+)', timing_text)]
    assert len(timing) == 5
    negative = [row for row in timing if Decimal(row['slack_ns']) < 0]
    resources = {line.split(' : ', 1)[0]: line.split(' : ', 1)[1]
                 for line in fitter.splitlines() if ' : ' in line}
    ip.append({'id': identifier, 'sample': result['job']['sample'], 'selectors': result['job']['selectors'],
               'native_cmake_rc': 0, 'full_compilation_completed': True,
               'exact_part': 'AGFB027R25A2E2V', 'quartus': '25.1.0 Build 129',
               'generated_clock_period_ns': '1.000', 'timing_target_met': not negative,
               'timing': timing, 'negative_timing': negative, 'fitter_resources': resources,
               'native_milestones': [line.strip() for line in native.splitlines()
                                     if re.search(r'Quartus Prime .+ was successful|Full Compilation was successful', line)],
               'native_result_sha256': digest(base / 'result.json'),
               'capture': str(base.relative_to(E)), 'real_card_execution': False})

finished = read(E / 'finished01.json')
assert finished['worker_outer_rc'] == 0
worker = collections['21']['worker']
assert worker['finished'] and worker['success'] and len(worker['jobs']) == 7
assert all(row['namespace_rc'] == 0 and row['ended'] for row in worker['jobs'])
postflight = read(E / 'postflight22.json')
assert postflight['success'] and postflight['source_unchanged'] and not postflight['owned_live_processes']
counts = {'upstream_roots': 3, 'program_variants': len(prior['cases']),
          'CPU_numerical_passes': prior['counts']['CPU_runs'],
          'emulator_numerical_passes': prior['counts']['emulator_runs'],
          'report_builds': prior['counts']['report_builds'],
          'RTL_simulation_numerical_passes': len(prior['rtl_simulations']) + len(new_sim['rtl_simulations']),
          'RTL_simulations_with_family_diagnostics': sum(not row['diagnostic_clean'] for row in diag['transcripts']),
          'full_IP_compilations_completed': len(ip),
          'full_IP_generated_timing_targets_met': sum(row['timing_target_met'] for row in ip),
          'real_card_executions': 0}
result = {'recorded_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
          'requested_build_and_verification_work_complete': True,
          'all_modes_diagnostic_clean': False,
          'scope': 'Original GettingStarted sources; CPU/emulator/report and PART2-4 simulator results reused, two new simulations, host-only reuse demonstration and five new isolated-IP compilations. No card operation.',
          'counts': counts, 'full_IP_results': ip,
          'simulator_diagnostic_disposition': 'diagnostic-disposition13.json',
          'numerical_evidence': ['prior-verification03.json', 'simulator-verification07.json'],
          'fast_recompile_device_payload_byte_identity_claimed': False,
          'mixed_version_warning_retained': 'HLS IP Gen2026.1 supports Quartus26.1; selected installed toolchain25.1 warning retained, not vendor-qualified compatibility.',
          'receipts': {name: digest(E / name) for name in ['prior-verification03.json', 'simulator-verification07.json',
                       'diagnostic-disposition13.json', 'collection06.json', 'collection15.json', 'collection17.json',
                       'collection20.json', 'collection21.json', 'finished01.json', 'postflight22.json']},
          'source_import_sha256': digest(V / 'UPSTREAM.json'), 'hardware_access': False}
with (E / 'verification23.json').open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
print(json.dumps({'verification_work_complete': True, 'all_modes_diagnostic_clean': False, 'counts': counts}, indent=2))
