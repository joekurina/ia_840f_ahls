"""Compile-only successor of the exercised native-CMake stage supervisor.

No stage is launched without a parent-bound fresh input manifest. This script
runs no device utility, does not reset/recover hardware, and never auto-retries.
"""
import datetime
import hashlib
import json
import os
from pathlib import Path
import resource
import re
import shutil
import signal
import socket
import subprocess
import sys
import time

B = Path('/home/uwb_student00/ahls/new_BSP')
E = B/'qualification/fim-build-24'
W = B/'work_ia840f_fim_24'
J = W/'syn/board/ia840f/syn_top'
Q = Path('/opt/altera/26.1.1/quartus')
STAGES = ('ip_inventory', 'ip_regeneration', 'headers', 'compile')
DEADLINES = {'ip_inventory': 600, 'ip_regeneration': 7200, 'headers': 1800, 'compile': 10800}
MARKERS = (b'IA840F_GATE_REJECTED', b'IA840F NOT READY', b'Critical Warning (125091)')


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def identity(pid):
    root = Path('/proc')/str(pid)
    fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'start_ticks': fields[19], 'exe': os.readlink(root/'exe'),
            'cwd': os.readlink(root/'cwd'),
            'argv': (root/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def live_group(gid):
    result = []
    for root in Path('/proc').iterdir():
        if not root.name.isdigit():
            continue
        try:
            fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
            if int(fields[2]) == gid and fields[0] != 'Z':
                result.append(int(root.name))
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            pass
    return result


def run():
    assert __debug__ and len(sys.argv) == 3 and sys.argv[1] in STAGES
    stage, expected_manifest = sys.argv[1:]
    assert stage == 'compile', 'this additive runner is compile-only'
    assert socket.gethostname() == 'Agilex7Workstation' and os.getuid() == 1000
    assert os.environ.get('TMUX') and subprocess.check_output(
        ['tmux', 'display-message', '-p', '-t', os.environ['TMUX_PANE'], '#S'], text=True).strip() == 'ia840f_mailbox_monitored_01'
    manifest_path = E/'stage-inputs'/(stage+'.json')
    assert sha(manifest_path) == expected_manifest, 'parent manifest binding'
    manifest = json.loads(manifest_path.read_text())
    assert manifest['stage'] == stage and manifest['work'] == str(W) and manifest['project'] == str(J)
    assert manifest['parent_execution_accepted'] is True
    assert manifest['toolchain'] == 'Quartus Prime Pro 26.1.1 Build 130'
    assert manifest['part'] == 'AGFB027R25A2E2V' and manifest['critical_inputs']
    assert manifest['runner_sha256'] == sha(Path(__file__))
    for name, target in manifest['critical_links'].items():
        link = Path(name)
        assert link.is_symlink() and os.readlink(link) == target, ('input link drift', name)
        assert link.resolve(strict=True).is_relative_to(W), ('input link escape', name)
    for path, digest in manifest.get('preflight_only_inputs', {}).items():
        assert sha(path) == digest, ('preflight input drift', path)
    for path, digest in manifest['critical_inputs'].items():
        assert sha(path) == digest, ('input drift', path)
    for path, digest in manifest['runtime_hashes'].items():
        assert sha(path) == digest, ('tool drift', path)
    assert sha(E/'candidate01/CMakeLists.txt') == manifest['cmake_sha256']
    for path, digest in manifest['prerequisites'].items():
        assert sha(path) == digest, ('prerequisite drift', path)
    cpus = set(os.sched_getaffinity(0))
    assert sorted(cpus) == manifest['cpus']
    assert ('set_global_assignment -name NUM_PARALLEL_PROCESSORS '+str(len(cpus))) in (J/'ofs_top.qsf').read_text()
    memory = int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
    disk = shutil.disk_usage(W).free
    assert memory > 80000000000 and disk > 20000000000, 'resource headroom'
    competing = []
    for proc in Path('/proc').iterdir():
        if not proc.name.isdigit():
            continue
        try:
            name = Path(os.readlink(proc/'exe')).name
            if name.startswith(('quartus_', 'qsys-', 'ahls', 'aoc', 'vsim', 'vlog')):
                competing.append({'pid': int(proc.name), 'exe': name})
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            pass
    assert not competing, competing
    env = dict(os.environ)
    for key in list(env):
        if key.startswith('OFS_BUILD_TAG_') or key in ('LD_LIBRARY_PATH', 'PYTHONPATH', 'PYTHONOPTIMIZE',
            'QUARTUS_ROOTDIR', 'OPAE_PLATFORM_GEN', 'SEED', 'ANALYSIS_AND_ELAB_ONLY',
            'USE_OFSS_CONFIG_SCRIPT', 'OFS_PRE_SETUP_SCRIPT', 'OFS_POST_SETUP_SCRIPT',
            'OFS_PRE_COMPILE_SCRIPT', 'OFS_POST_COMPILE_SCRIPT', 'AFU_WITH_PIM',
            'BUILD_VAR_SETUP_COMPLETE', 'BUILD_ROOT_REL_PRINTED'):
            env.pop(key, None)
    assert all(env.get(key) for key in ('LM_LICENSE_FILE', 'MGLS_LICENSE_FILE', 'SALT_LICENSE_SERVER'))
    operation = E/'operations'/stage
    assert not operation.exists() and not operation.is_symlink(), 'operation already consumed'
    native_lock = E/'native-operation.lock'
    native_lock.mkdir()  # Exclusive across different stages, before any child.
    operation.mkdir(parents=True, exist_ok=False)
    (operation/'home').mkdir()
    (operation/'tmp').mkdir()
    env.update(HOME=str(operation/'home'), TMPDIR=str(operation/'tmp'), LANG='C',
        OFS_ROOTDIR=str(W), OFS_PLATFORM_AFU_BBB=str(B/'ofs-platform-afu-bbb'),
        BUILD_ROOT_REL='../../../..', QUARTUS_ROOTDIR_OVERRIDE=str(Q),
        PATH=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/local/bin:/usr/bin:/bin',
        PYTHONDONTWRITEBYTECODE='1', IA840F_MIGRATION_AUTHORITY=str(operation/'authority.json'))
    authority = {'approved': True, 'ready_for_build': False, 'scope': 'ia840f-ofs2026-native-'+stage,
        'project': str(J), 'part': manifest['part'], 'toolchain': manifest['toolchain'],
        'runner': identity(os.getpid()), 'contexts': manifest['contexts'],
        'runtime_hashes': manifest['runtime_hashes'], 'critical_inputs': manifest['critical_inputs'],
        'critical_links': manifest['critical_links'],
        'parent_manifest_sha256': expected_manifest}
    with (operation/'authority.json').open('x') as stream:
        json.dump(authority, stream, indent=2)
    assert json.loads((operation/'authority.json').read_text()) == authority
    result = {'stage': stage, 'started': now(), 'complete': False, 'commands': [],
        'hardware_access': False, 'ready_for_build': False, 'manifest_sha256': expected_manifest,
        'authority_sha256': sha(operation/'authority.json'), 'resource_preflight': {
            'mem_available_bytes': memory, 'disk_free_bytes': disk, 'cpus': sorted(cpus),
            'rlimit_as_bytes': 64*1024**3}, 'native_acceptance': 'PENDING ACTUAL RESULT REVIEW'}

    def persist():
        (operation/'status.json').write_text(json.dumps(result, indent=2)+'\n')

    def limits():
        os.sched_setaffinity(0, cpus)
        resource.setrlimit(resource.RLIMIT_AS, (64*1024**3, 64*1024**3))
        resource.setrlimit(resource.RLIMIT_CORE, (0, 0))

    def native(label, argv, duration):
        rec = {'label': label, 'argv': argv, 'started': now()}
        result['commands'].append(rec)
        persist()
        child = None
        timedout = False
        rejected = False
        offset = 0
        tail = b''
        logfile = operation/(label+'.log')
        with logfile.open('xb') as log:
            try:
                child = subprocess.Popen(argv, cwd=J, env=env, stdout=log, stderr=subprocess.STDOUT,
                                         start_new_session=True, preexec_fn=limits)
                # Protection begins immediately after spawn, including bookkeeping failures.
                rec['process'] = identity(child.pid)
                persist()
                deadline = time.monotonic()+duration
                while os.waitid(os.P_PID, child.pid, os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
                    with logfile.open('rb') as reader:
                        reader.seek(offset)
                        data = reader.read(1048576)
                        offset += len(data)
                    window = tail+data
                    rejected = rejected or any(marker in window for marker in MARKERS)
                    tail = window[-128:]
                    if rejected:
                        raise RuntimeError('owned native callback rejection')
                    if time.monotonic() > deadline:
                        timedout = True
                        break
                    time.sleep(0.2)
                residual = live_group(child.pid)
                rec['descendants_observed_at_leader_exit'] = residual
                while residual and not timedout and time.monotonic() < deadline:
                    time.sleep(0.2)
                    residual = live_group(child.pid)
                if residual:
                    timedout = True
            finally:
                if child is not None:
                    # Keep the leader unreaped until every possible group signal finishes.
                    if live_group(child.pid):
                        os.killpg(child.pid, signal.SIGTERM)
                        end = time.monotonic()+3
                        while live_group(child.pid) and time.monotonic() < end:
                            time.sleep(0.1)
                        if live_group(child.pid):
                            os.killpg(child.pid, signal.SIGKILL)
                    cmake_rc = child.wait()
                    rec.update(cmake_rc=cmake_rc, timeout=timedout, gate_rejected=rejected, ended=now())
                    # Persist raw CMake status before fallible postflight acquisition.
                    persist()
                    residual_after = live_group(child.pid)
                    rec['owned_group_live_after'] = residual_after
                    rec['native_rc'] = 0 if label == 'native' and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct native CMake target: zero propagates child zero; nonzero does not disclose child exit.'
                                                  if label == 'native' else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']

    persist()
    try:
        configure = ['/usr/bin/cmake', '-S', str(E/'candidate01'), '-B', str(operation/'cmake-build'),
            '-G', 'Unix Makefiles', '-DCMAKE_MAKE_PROGRAM=/usr/bin/make', '-DFIM_PROJECT='+str(J),
            '-DQUARTUS_ROOT='+str(Q), '-DIP_INVENTORY_OUTPUT='+str(E/'project-ip-inventory.tcl')]
        assert native('configure', configure, 120) == 0, 'CMake configure failed'
        command = ['/usr/bin/cmake', '--build', str(operation/'cmake-build'), '--target', stage, '--parallel', '1']
        native('native', command, DEADLINES[stage])
        result['complete'] = True
    except Exception as exc:
        result['error'] = repr(exc)
    finally:
        result['postflight_errors'] = []
        for path, target in manifest['critical_links'].items():
            try:
                link = Path(path)
                if not link.is_symlink() or os.readlink(link) != target or not link.resolve(strict=True).is_relative_to(W):
                    result['postflight_errors'].append({'path': path, 'error': 'input link changed or escaped'})
            except Exception as exc:
                result['postflight_errors'].append({'path': path, 'error': repr(exc)})
        for path, digest in manifest['critical_inputs'].items():
            try:
                if sha(path) != digest:
                    result['postflight_errors'].append({'path': path, 'error': 'critical input changed'})
            except Exception as exc:
                result['postflight_errors'].append({'path': path, 'error': repr(exc)})
        result['runtime_output_changes'] = {}
        for path, digest in manifest.get('preflight_only_inputs', {}).items():
            try:
                after = sha(path) if Path(path).is_file() else None
                result['runtime_output_changes'][path] = {'before_sha256': digest, 'after_sha256': after,
                    'changed': after != digest, 'role': manifest['runtime_output_roles'][path]}
            except Exception as exc:
                result['postflight_errors'].append({'path': path, 'error': repr(exc)})
        result['log_hashes'] = {p.name: {'bytes': p.stat().st_size, 'sha256': sha(p)} for p in operation.glob('*.log')}
        result['diagnostics'] = []
        final_gate_rejection = False
        for logfile in operation.glob('*.log'):
            with logfile.open('r', errors='replace') as stream:
                for number, line in enumerate(stream, 1):
                    gate_rejection = any(marker.decode() in line for marker in MARKERS)
                    final_gate_rejection = final_gate_rejection or gate_rejection
                    if gate_rejection or re.search(r'\b(?:Error|Fatal)(?:\s+\([^)]*\))?\s*:', line, re.I):
                        result['diagnostics'].append({'log': logfile.name, 'line': number, 'text': line.rstrip('\n')})
        result['final_gate_rejection'] = final_gate_rejection
        result['ended'] = now()
        result['execution_clean'] = (result['complete'] and 'error' not in result and
            len(result['commands']) == 2 and all(c.get('effective_rc') == 0 for c in result['commands']) and
            not result['postflight_errors'] and not result['diagnostics'] and not final_gate_rejection)
        persist()
        if result['execution_clean']:
            native_lock.rmdir()
        print(json.dumps(result, indent=2), flush=True)
    return 0 if result['execution_clean'] else 1


if __name__ == '__main__':
    sys.exit(run())
