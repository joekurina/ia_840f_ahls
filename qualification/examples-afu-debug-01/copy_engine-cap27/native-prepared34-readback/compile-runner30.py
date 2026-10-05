"""Bounded native CMake PR compile supervisor, executed in owned tmux only."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import resource
import signal
import socket
import subprocess
import sys
import time
import traceback

RUN = Path(__file__).resolve().parent
PROJECT = RUN / 'persona/build/syn/board/ia840f/syn_top'
RELEASE = '/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01'
DEADLINE_SECONDS = 7200
LOG_LIMIT = 200_000_000


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def proc(pid):
    p = Path('/proc') / str(pid)
    fields = (p / 'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(fields[1]), 'state': fields[0],
            'pgid': int(fields[2]), 'start_ticks': fields[19],
            'exe': os.readlink(p / 'exe'), 'cwd': os.readlink(p / 'cwd'),
            'argv': (p / 'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def group_members(pgid):
    members = []
    for p in Path('/proc').iterdir():
        if not p.name.isdecimal():
            continue
        try:
            r = proc(int(p.name))
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            continue
        if r['pgid'] == pgid and r['state'] != 'Z':
            members.append(r)
    return members


def main():
    assert os.environ.get('TMUX') and socket.gethostname() == 'Agilex7Workstation'
    assert os.getuid() == 1000 and not (RUN / 'compile-result.json').exists()
    fd = os.open(RUN / 'compile-claim.json', os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    owner = proc(os.getpid())
    os.write(fd, json.dumps(owner).encode())
    os.close(fd)
    resource.setrlimit(resource.RLIMIT_AS, (64 * 1024**3, 64 * 1024**3))
    env = dict(os.environ, QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',
               PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/bin:/bin',
               OPAE_PLATFORM_ROOT=RELEASE, OPAE_PLATFORM_FPGA_FAMILY='AGILEX',
               QUARTUS_VERSION='26.1', QUARTUS_VERSION_MAJOR='26',
               BUILD_ROOT_REL='../../../..', PR_COMPILE='1')
    for k in ['OPAE_PLATFORM_GEN', 'BBS_LIB_PATH', 'OPAE_PLATFORM_DB_PATH', 'OPAE_AFU_TOP_IFC_DB_PATH']:
        env.pop(k, None)
    authority = json.loads((RUN / 'compile-prepared.json').read_text())
    assert authority['scope'] == 'tutorial PR compile only; no hardware'
    for path, digest in authority['inputs'].items():
        assert sha(path) == digest, path
    authority.update(approved=True, owner=owner)
    with (RUN / 'compile-authority.json').open('x') as stream:
        json.dump(authority, stream, indent=2)
    command = ['/usr/bin/cmake', '--build', str(RUN / 'cmake-build'),
               '--target', 'compile', '--parallel', '1', '--verbose']
    result = {'argv': command, 'utc_start': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'deadline_seconds': DEADLINE_SECONDS, 'owner': owner, 'native_rc': None,
              'effective_rc': 1, 'error': None, 'terminal': False}
    child = None
    reaped = False
    deadline = time.monotonic() + DEADLINE_SECONDS
    try:
        with (RUN / 'compile.log').open('xb', buffering=0) as log:
            child = subprocess.Popen(command, cwd=PROJECT, env=env, stdout=log,
                                     stderr=subprocess.STDOUT, start_new_session=True)
            # All fallible post-spawn work is protected by this try/finally.
            result['child'] = proc(child.pid)
            (RUN / 'compile-launch.json').write_text(json.dumps(result, indent=2))
            while time.monotonic() < deadline:
                ended = os.waitid(os.P_PID, child.pid, os.WEXITED | os.WNOHANG | os.WNOWAIT)
                data = (RUN / 'compile.log').read_bytes()
                assert len(data) <= LOG_LIMIT, 'polled log budget exceeded'
                assert b'EXAMPLES_AFU_GATE_REJECTED' not in data, 'native gate rejected'
                if ended is not None and not group_members(child.pid):
                    result['native_rc'] = child.wait()
                    reaped = True
                    result['terminal'] = True
                    break
                time.sleep(2)
            else:
                raise TimeoutError('bounded native compile deadline exceeded')
            result['effective_rc'] = 0 if result['native_rc'] == 0 else 1
    except BaseException as exc:
        result['error'] = repr(exc)
        result['traceback'] = traceback.format_exc()
    finally:
        if child is not None and not reaped:
            # Unreaped session leader reserves its PID/PGID until signaling is finished.
            try:
                os.killpg(child.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass
            for _ in range(10):
                if not group_members(child.pid):
                    break
                time.sleep(1)
            if group_members(child.pid):
                try:
                    os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            try:
                result['native_rc'] = child.wait(timeout=15)
                reaped = True
            except subprocess.TimeoutExpired:
                result['error'] = str(result['error']) + '; session leader termination unknown'
            result['remaining_group'] = group_members(child.pid)
            result['terminal'] = reaped and not result['remaining_group']
    result['utc_end'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    result['log'] = {'bytes': (RUN / 'compile.log').stat().st_size,
                     'sha256': sha(RUN / 'compile.log')}
    result['outputs'] = {str(p): {'bytes': p.stat().st_size, 'sha256': sha(p)}
                         for p in (PROJECT / 'output_files').glob('*')
                         if p.is_file() and p.suffix in ('.gbs', '.rbf', '.sof', '.pmsf')}
    result['input_preservation'] = {p: sha(p) == h for p, h in authority['inputs'].items()}
    if not all(result['input_preservation'].values()):
        result['effective_rc'] = 1
    with (RUN / 'compile-result.json').open('x') as stream:
        json.dump(result, stream, indent=2)
    return result['effective_rc']


if __name__ == '__main__':
    rc = 1
    try:
        rc = main()
    finally:
        subprocess.run(['tmux', 'set-buffer', '-b', 'examples_afu_'+RUN.name.replace('-', '_')+'_compile58_rc', str(rc)], check=True)
        subprocess.run(['tmux', 'wait-for', '-S', 'examples_afu_'+RUN.name.replace('-', '_')+'_compile58_done'], check=True)
    sys.exit(rc)
