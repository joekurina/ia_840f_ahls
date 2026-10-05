"""Single serial tutorial PR/load/run attempt. No timeout kills or recovery."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time

RUN = Path(__file__).resolve().parent
EXPECTED_BOOT = '3e2d2060-d6c0-44b5-a269-1adf1e450041'
OBSERVER = Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/activation-pre43/runtime/ownership27.py')
OBSERVER_SHA = 'c120062efd638824d05f4495faf7e63634576744e3cc13f26aa0d3a2d12faf8c'
APPROVAL_SHA256 = sys.argv[1] if len(sys.argv) == 2 else 'UNBOUND_NOT_AUTHORIZED'


def sha(p):
    h = hashlib.sha256()
    with Path(p).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def proc(pid):
    p = Path('/proc') / str(pid)
    s = (p / 'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(s[1]), 'state': s[0], 'start_ticks': s[19],
            'exe': os.readlink(p / 'exe'), 'cwd': os.readlink(p / 'cwd'),
            'argv': (p / 'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def ownership():
    assert sha(OBSERVER) == OBSERVER_SHA
    z = subprocess.run(['sudo', '-n', '/usr/bin/python3', '-I', '-B', str(OBSERVER)],
                       capture_output=True, timeout=60)
    assert z.returncode == 0, z.stderr.decode(errors='replace')
    return json.loads(z.stdout)


def execute_once(name, argv, deadline_seconds, directory, env):
    result = {'argv': argv, 'utc_start': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'native_rc': None, 'execution_state': 'NOT_STARTED', 'retained_owner': False}
    child = None
    try:
        with (directory / (name + '.stdout')).open('xb', buffering=0) as out, \
             (directory / (name + '.stderr')).open('xb', buffering=0) as err:
            child = subprocess.Popen(argv, cwd=RUN, env=env, stdout=out, stderr=err,
                                     start_new_session=True)
            # Never signal this hardware process, including on bookkeeping failure.
            result['owner'] = proc(child.pid)
            (directory / (name + '-launch.json')).write_text(json.dumps(result, indent=2))
            deadline = time.monotonic() + deadline_seconds
            while time.monotonic() < deadline:
                rc = child.poll()
                if rc is not None:
                    result.update(native_rc=rc, execution_state='EXITED', retained_owner=False)
                    break
                current = proc(child.pid)
                if current['state'] in ('T', 't', 'D'):
                    result.update(execution_state='RETAINED_' + current['state'],
                                  retained_owner=True, current_owner=current)
                    break
                time.sleep(0.1)
            else:
                result.update(execution_state='TIMEOUT_EXECUTION_UNKNOWN', retained_owner=True,
                              current_owner=proc(child.pid))
    except BaseException as exc:
        result['error'] = repr(exc)
        if child is not None and child.returncode is None:
            result.update(execution_state='BOOKKEEPING_FAILURE_EXECUTION_UNKNOWN', retained_owner=True,
                          pid=child.pid)
    result['utc_end'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    for stream in ('stdout', 'stderr'):
        p = directory / (name + '.' + stream)
        if p.exists():
            result[stream] = {'bytes': p.stat().st_size, 'sha256': sha(p)}
    with (directory / (name + '-result.json')).open('x') as stream:
        json.dump(result, stream, indent=2)
    return result


def main():
    assert os.environ.get('TMUX') and socket.gethostname() == 'Agilex7Workstation'
    assert os.getuid() == 1000 and APPROVAL_SHA256 != 'UNBOUND_NOT_AUTHORIZED'
    approval_path = RUN / 'hardware-approval.json'
    assert sha(approval_path) == APPROVAL_SHA256
    approval = json.loads(approval_path.read_text())
    assert approval['accepted_for_one_attempt'] is True
    assert approval['run'] == str(RUN)
    assert approval['scope'] == 'one default plain-user fpgaconf; one checked tutorial greeting; no recovery'
    assert sha(__file__) == approval['runner_sha256']
    for path, digest in approval['files'].items():
        assert sha(path) == digest, path
    compile_result = json.loads((RUN / 'compile-result.json').read_text())
    assert compile_result['native_rc'] == 0 and compile_result['terminal'] is True
    assert approval['compile_result_sha256'] == sha(RUN / 'compile-result.json')
    assert Path('/proc/sys/kernel/random/boot_id').read_text().strip() == EXPECTED_BOOT
    cached = Path(approval['cached_uuid_path']).read_text().strip()
    assert cached == 'fc603c445c8f5e94bcbea5780030947c'
    before = ownership()
    assert before['boot_id'] == EXPECTED_BOOT
    assert not any(before[k] for k in ('d_state', 'holders', 'maps', 'errors', 'relevant_processes'))
    for bdf, driver in approval['drivers'].items():
        assert str((Path('/sys/bus/pci/devices') / bdf / 'driver').resolve()) == driver
    trial = RUN / 'hardware-attempt01'
    trial.mkdir(exist_ok=False)
    (trial / 'preflight.json').write_text(json.dumps(before, indent=2))
    env = dict(os.environ)
    # Bind the same existing configuration selected by the installed resolver.
    assert env.get('LIBOPAE_CFGFILE') in (None, approval['opae_cfg'])
    assert env.get('LD_LIBRARY_PATH', '') == approval['ld_library_path']
    env['LIBOPAE_CFGFILE'] = approval['opae_cfg']
    for key in ('OPAE_CONFIG_FILE', 'OPAE_CONFIG_PATH', 'OPAE_PLUGIN_PATH', 'LD_PRELOAD'):
        assert not env.get(key), (key, 'unreviewed inherited override')
    results = {'scope': approval['scope'], 'success': False, 'boot': EXPECTED_BOOT}
    kernel_before = subprocess.run(['sudo', '-n', '/usr/bin/dmesg', '--raw', '--color=never'],
                                   capture_output=True, timeout=30)
    assert kernel_before.returncode == 0, kernel_before.stderr.decode(errors='replace')
    (trial / 'kernel-before.log').write_bytes(kernel_before.stdout)
    load = execute_once('fpgaconf', ['/usr/bin/fpgaconf', '0000:4f:00.0', approval['gbs']],
                        120, trial, env)
    results['load'] = load
    if load['execution_state'] == 'EXITED' and load['native_rc'] == 0:
        # No reset/rebind/retry between successful PR and this one tutorial execution.
        host = execute_once('host', [approval['host']], 30, trial, env)
        results['host'] = host
        if host['execution_state'] == 'EXITED' and host['native_rc'] == 0:
            stdout = (trial / 'host.stdout').read_bytes()
            stderr = (trial / 'host.stderr').read_bytes()
            results['exact_data_marker'] = stdout == b'Hello world!\nCHECK greeting_line_bytes=64 PASS\n'
            results['empty_host_stderr'] = stderr == b''
            after = ownership()
            results['postflight'] = after
            results['success'] = (results['exact_data_marker'] and results['empty_host_stderr']
                                  and after['boot_id'] == EXPECTED_BOOT
                                  and not any(after[k] for k in ('d_state', 'holders', 'maps', 'errors', 'relevant_processes')))
    kernel_after = subprocess.run(['sudo', '-n', '/usr/bin/dmesg', '--raw', '--color=never'],
                                  capture_output=True, timeout=30)
    results['kernel_capture_rc'] = kernel_after.returncode
    (trial / 'kernel-after.log').write_bytes(kernel_after.stdout)
    (trial / 'kernel-after.stderr').write_bytes(kernel_after.stderr)
    results['kernel_logs'] = {name: {'bytes': (trial / name).stat().st_size,
                                   'sha256': sha(trial / name)}
                              for name in ('kernel-before.log', 'kernel-after.log')}
    if kernel_after.returncode != 0:
        results['success'] = False
    results['boot_after'] = Path('/proc/sys/kernel/random/boot_id').read_text().strip()
    with (trial / 'result.json').open('x') as stream:
        json.dump(results, stream, indent=2)
    print(json.dumps(results, indent=2), flush=True)
    return 0 if results['success'] else 1


if __name__ == '__main__':
    sys.exit(main())
