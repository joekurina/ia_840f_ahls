#!/usr/bin/env python3
"""Prepared-only Questa runner. Importing this module executes no subprocess."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import socket
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
TOOLS = Path('/opt/altera/26.1.1/questa_fe/bin')
LICENSE = '/home/uwb_student00/quartus_26/LR-191011_License.dat'
OVERRIDE = '/opt/altera/26.1.1/quartus'
DEFINES = ['+define+OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS=1',
           '+define+OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH=512',
           '+define+OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH=18']
EXPECTED_PASS = 'PASS scenarios=154 checks=160007'
DO = 'onerror {quit -code 1}; onbreak {quit -code 1}; run -all; quit -code 1'


def pin(path):
    return {'size': path.stat().st_size,
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def dump(path, obj):
    with path.open('x') as f:
        json.dump(obj, f, indent=2, sort_keys=True)
        f.write('\n')


def safe_file(root, rel):
    p = root / rel
    if Path(rel).is_absolute() or '..' in Path(rel).parts:
        raise RuntimeError('Unsafe manifest path: ' + rel)
    if any(x.is_symlink() for x in [p, *p.parents] if x != root.parent):
        raise RuntimeError('Symlink input: ' + str(p))
    if not p.is_file():
        raise RuntimeError('Missing input: ' + str(p))
    return p


def inventory(root, manifest):
    return {rel: pin(safe_file(root, rel)) for rel in manifest}


def diagnostics(text):
    """Reject diagnostic words, except explicit zero error/fatal summaries."""
    text = re.sub(r'^\s*(?:#\s*)?Errors:\s*0(?:,\s*Warnings:\s*\d+)?\s*$',
                  '', text, flags=re.I | re.M)
    return bool(re.search(r'\b(?:errors?|fatal|fatals|fail|failure)\b', text, re.I))


def transcript_gate(text, rc):
    # Questa console prefixes displayed HDL messages with '# '. No searching
    # inside arbitrary lines: command echoes and substrings cannot qualify.
    lines = [re.sub(r'^#\s?', '', line).strip() for line in text.splitlines()]
    checked_lines = [s for s in lines if s.startswith('CHECKED')]
    checks = []
    for line in checked_lines:
        m = re.fullmatch(r'CHECKED ([1-9][0-9]*) .+', line)
        checks.append(int(m.group(1)) if m else None)
    passes = [s for s in lines if re.search(r'\bPASS\b', s)]
    sequential = checks == list(range(1, 155))
    return {'accepted': rc == 0 and sequential and passes == [EXPECTED_PASS]
            and not diagnostics(text),
            'checked_entries': len(checked_lines),
            'actual_checked_scenarios': len(checks) if sequential else 0,
            'sequential_1_through_154': sequential,
            'unique_exact_pass': passes == [EXPECTED_PASS],
            'error_or_fatal': diagnostics(text)}


def stage(out, name, argv, env, timeout):
    folder = out / name
    folder.mkdir()  # exclusive stage reservation; never overwrite old evidence
    record = {'argv': argv, 'cwd': str(out), 'timeout_seconds': timeout,
              'start_unix': time.time(), 'environment': env}
    dump(folder / 'invocation.json', record)
    rc, timed_out, error = 127, False, None
    started = time.monotonic()
    with (folder / 'output.log').open('xb') as log:
        try:
            child = subprocess.Popen(argv, cwd=out, env=env, stdout=log,
                                     stderr=subprocess.STDOUT, start_new_session=True)
            try:
                rc = child.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                timed_out = True
                os.killpg(child.pid, signal.SIGKILL)
                child.wait()
                rc = 124
        except OSError as exc:
            error = str(exc)
    text = (folder / 'output.log').read_text(errors='replace')
    result = {'rc': rc, 'timed_out': timed_out, 'launch_error': error,
              'elapsed_seconds': time.monotonic() - started,
              'error_or_fatal': diagnostics(text),
              'log': pin(folder / 'output.log')}
    dump(folder / 'result.json', result)
    return result


def runtime_guard():
    if socket.gethostname() != 'Agilex7Workstation':
        raise RuntimeError('Required hostname Agilex7Workstation')
    if os.getuid() != 1000 or os.geteuid() != 1000:
        raise RuntimeError('Required real/effective UID 1000')
    if not os.environ.get('TMUX'):
        raise RuntimeError('Must run inside TMUX')
    if not Path(LICENSE).is_file() or not os.access(LICENSE, os.R_OK):
        raise RuntimeError('Required readable license file unavailable')
    if not Path(OVERRIDE).is_dir():
        raise RuntimeError('Required Quartus root override unavailable')
    for name in ('vlib', 'vlog', 'vsim'):
        if not (TOOLS / name).is_file() or not os.access(TOOLS / name, os.X_OK):
            raise RuntimeError('Installed executable unavailable: ' + name)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute-reviewed', action='store_true',
                        help='Operator attests parent spec + quality acceptance')
    parser.add_argument('--output', required=True, type=Path,
                        help='Fresh absolute directory outside package (parent must exist)')
    args = parser.parse_args(argv)
    if not args.execute_reviewed:
        parser.error('Execution requires parent acceptance and --execute-reviewed')
    runtime_guard()  # no files or tools before target identity/prerequisites pass
    out = args.output
    if not out.is_absolute() or out.exists() or out.is_symlink():
        raise RuntimeError('Output must be a fresh absolute path')
    out = out.resolve()
    if out == HERE or HERE in out.parents or out in HERE.parents:
        raise RuntimeError('Output must be outside package, not an ancestor')
    manifest_path = HERE / 'package-sha256.json'
    manifest_pin = pin(manifest_path)
    manifest = json.loads(manifest_path.read_text())
    before = inventory(HERE, manifest)
    if before != manifest:
        raise RuntimeError('Package hash mismatch; no vendor tool run')
    expected_paths = set(manifest) | {'package-sha256.json'}
    actual_paths = {str(p.relative_to(HERE)) for p in HERE.rglob('*') if p.is_file()}
    if actual_paths != expected_paths:
        raise RuntimeError('Unexpected/missing package files (including caches)')
    input_manifest = json.loads((HERE / 'input-manifest.json').read_text())
    input_pins = {x['copy']: {'size': x['size'], 'sha256': x['sha256']}
                  for x in input_manifest['inputs']}
    if len(input_pins) != 13 or inventory(HERE, input_pins) != input_pins:
        raise RuntimeError('Expanded source manifest mismatch')
    out.mkdir()  # exclusive run claim; preserved even on failure
    result = {'status': 'FAIL', 'runner_rc': 2, 'actual_checked_scenarios': 0,
              'planned_scenarios': 154, 'stages': {}, 'simulation_rc': None,
              'scope': 'unit fixture only; reset/stall overlap, not interruption'}
    tools_before = {}
    try:
        dump(out / 'package.before.json', before)
        dump(out / 'package-manifest-pin.json', manifest_pin)
        (out / 'inputs').mkdir()
        for rel in input_pins:
            shutil.copyfile(HERE / rel, out / rel)
        shutil.copyfile(HERE / 'sources.f', out / 'sources.f')
        if inventory(out, input_pins) != input_pins:
            raise RuntimeError('Staged input mismatch')
        (out / 'modelsim.ini').write_text('[Library]\nwork = work\n\n[vsim]\nVoptFlow = 1\n')
        config_before = {name: pin(out / name) for name in ('sources.f', 'modelsim.ini')}
        dump(out / 'configuration.before.json', config_before)
        dump(out / 'inputs.before.json', input_pins)
        (out / 'home').mkdir()
        # Minimal environment prevents inherited vlog/vsim options, ini paths,
        # library mappings or board macros from changing this fixture.
        env = {'PATH': str(TOOLS) + ':/usr/bin:/bin', 'HOME': str(out / 'home'),
               'LANG': 'C', 'LC_ALL': 'C', 'TMPDIR': str(out),
               'TMUX': os.environ['TMUX'], 'MODELSIM': str(out / 'modelsim.ini'),
               'LM_LICENSE_FILE': LICENSE, 'MGLS_LICENSE_FILE': LICENSE,
               'SALT_LICENSE_SERVER': LICENSE, 'QUARTUS_ROOTDIR_OVERRIDE': OVERRIDE}
        tools_before = {name: {'path': str(TOOLS / name),
                              'resolved_path': str((TOOLS / name).resolve()),
                              **pin(TOOLS / name)} for name in ('vlib', 'vlog', 'vsim')}
        dump(out / 'tools.before.json', tools_before)
        dump(out / 'execution.json', {'argv': sys.argv, 'cwd_at_launch': os.getcwd(),
             'stage_cwd': str(out), 'hostname': socket.gethostname(),
             'uid': os.getuid(), 'euid': os.geteuid(), 'environment': env,
             'python': sys.version, 'package': str(HERE),
             'fixture_definitions': DEFINES, 'license_file_sha': pin(Path(LICENSE)),
             'review_attestation': True})
        commands = [(name + '-version', [str(TOOLS / name), '-version'], 15)
                    for name in ('vlog', 'vsim')]
        commands += [('vlib', [str(TOOLS / 'vlib'), 'work'], 30),
                     ('compile', [str(TOOLS / 'vlog'), '-sv', '-timescale', '1ns/1ps',
                                  '-work', 'work', *DEFINES, '-f', 'sources.f'], 180),
                     ('simulation', [str(TOOLS / 'vsim'), '-c', '-onfinish', 'exit',
                                     '-l', 'simulator-transcript.log', 'work.tb',
                                     '-do', DO], 60)]
        for name, command, timeout in commands:
            if inventory(HERE, manifest) != before or pin(manifest_path) != manifest_pin:
                raise RuntimeError('Package changed before stage ' + name)
            if inventory(out, input_pins) != input_pins or inventory(out, config_before) != config_before:
                raise RuntimeError('Staged sources/configuration changed before stage ' + name)
            entry = stage(out, name, command, env, timeout)
            result['stages'][name] = entry
            if name == 'simulation':
                result['simulation_rc'] = entry['rc']
            if entry['rc'] != 0 or entry['error_or_fatal']:
                result['runner_rc'] = entry['rc'] if entry['rc'] > 0 else 2
                raise RuntimeError('Stage rejected: ' + name)
        text = (out / 'simulation/output.log').read_text(errors='replace')
        result['transcript_gate'] = transcript_gate(text, result['simulation_rc'])
        result['actual_checked_scenarios'] = result['transcript_gate']['actual_checked_scenarios']
        if not result['transcript_gate']['accepted']:
            raise RuntimeError('Simulation transcript rejected')
        native_log = out / 'simulator-transcript.log'
        if not native_log.is_file() or diagnostics(native_log.read_text(errors='replace')):
            raise RuntimeError('Native simulator transcript missing or contains diagnostics')
        result['status'], result['runner_rc'] = 'PASS', 0
    except Exception as exc:
        result['failure'] = str(exc)
    finally:
        try:
            after = inventory(HERE, manifest)
            dump(out / 'package.after.json', after)
            staged_after = inventory(out, input_pins)
            dump(out / 'inputs.after.json', staged_after)
            config_after = inventory(out, config_before)
            dump(out / 'configuration.after.json', config_after)
            result['inputs_unchanged'] = (before == after and pin(manifest_path) == manifest_pin
                 and staged_after == input_pins and config_before == config_after
                 and pin(out / 'sources.f') == before['sources.f'])
            tools_after = {name: {'path': str(TOOLS / name),
                                 'resolved_path': str((TOOLS / name).resolve()),
                                 **pin(TOOLS / name)} for name in tools_before}
            dump(out / 'tools.after.json', tools_after)
            result['tools_unchanged'] = bool(tools_before) and tools_after == tools_before
            if not result['inputs_unchanged'] or not result['tools_unchanged']:
                result['status'], result['runner_rc'] = 'FAIL', 2
        except Exception as exc:
            result['status'], result['runner_rc'] = 'FAIL', 2
            result['verification_failure'] = str(exc)
        dump(out / 'result.json', result)
    print(json.dumps(result, indent=2))
    return result['runner_rc']


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print('PRECHECK REJECTED: ' + str(exc), file=sys.stderr)
        sys.exit(2)
