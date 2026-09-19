#!/usr/bin/python3
"""Nonvendor-only finite controls; never yields full proposal acceptance."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import pwd
import select
import signal
import socket
import stat
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = Path('/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u03')
RESERVED = [str(ROOT.parent / n) for n in ('scratch-first-7c407469a419-u01', 'observation-first-7c407469a419-u01')]
ENV = {'PATH': '/usr/bin:/bin', 'LANG': 'C'}
MAX_OUTPUT = 67108864
MAX_ENTRIES = 250000
MAX_HASH = 8589934592
BWRAP = '/usr/bin/bwrap'
PYTHON = '/usr/bin/python3'
EXECUTED_TOOLS = frozenset({'python3', 'bwrap', 'tmux'})
INVENTORY_ONLY_TOOLS = frozenset({'unshare', 'mount', 'setpriv', 'strace'})


def tool_roles(expected):
    """Source-bound roles, never caller-supplied execution permission."""
    require(not EXECUTED_TOOLS & INVENTORY_ONLY_TOOLS, 'tool role overlap')
    require(set(expected) == EXECUTED_TOOLS | INVENTORY_ONLY_TOOLS, 'exact tool role union required')
    return {name: 'EXECUTED' if name in EXECUTED_TOOLS else 'INVENTORY_ONLY'
            for name in expected}


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


def digest(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def no_links(path, absent=False):
    p = Path(path)
    require(p.is_absolute() and '..' not in p.parts, 'noncanonical path')
    for part in [*reversed(p.parents), p]:
        if absent and part == p and not os.path.lexists(str(part)):
            return
        require(not stat.S_ISLNK(os.lstat(str(part)).st_mode), 'symlink ancestor: ' + str(part))


def claim(path):
    no_links(path, absent=True)
    os.mkdir(str(path), 0o700)  # collision is terminal, never remove/reuse
    global CLAIMED
    CLAIMED = True  # also tracks failure creating children after successful claim
    for child in ('rw', 'protected', 'observer'):
        os.mkdir(str(path / child), 0o700)


def process_identity(pid):
    text = Path('/proc/%d/stat' % pid).read_text()
    fields = text[text.rfind(')') + 2:].split()
    return {'pid': pid, 'ppid': int(fields[1]), 'starttime': fields[19], 'state': fields[0],
            'namespace': os.readlink('/proc/%d/ns/pid' % pid)}


def same_identity(first, second):
    return all(first[k] == second[k] for k in ('pid', 'ppid', 'starttime', 'namespace'))


def alive(fd):
    return not select.select([fd], [], [], 0)[0]


def verified_pidfd(pid):
    """Only for the fork-owned, not-yet-reaped direct supervisor."""
    first = process_identity(pid)
    fd = os.pidfd_open(pid, 0)
    try:
        require(same_identity(first, process_identity(pid)), 'PID identity race')
        return fd, first
    except BaseException:
        os.close(fd)  # never signal a rejected handle
        raise


def nspids(pid):
    lines = [line.split()[1:] for line in Path('/proc/%d/status' % pid).read_text().splitlines()
             if line.startswith('NSpid:')]
    require(len(lines) == 1 and lines[0], 'missing NSpid')
    return lines[0]


def launch_init_pidfd(candidate, supfd, supervisor):
    """Require the exact init -> bwrap -> owned supervisor chain.

    The supervisor forks exactly one child and never forks again. It stays
    unreaped until validation completes. Live pidfds bracket ALL proc reads;
    consequently neither ancestor may be replaced during validation. Unsupported
    bwrap topology is inconclusive, not a relaxed ancestry check.
    """
    temporary = []
    promoted = False
    try:
        require(alive(supfd), 'supervisor exited before validation')
        parent = process_identity(candidate['ppid'])
        require(parent['ppid'] == supervisor['pid'], 'init not in launch ancestry')
        parentfd = os.pidfd_open(parent['pid'], 0)
        temporary.append(parentfd)
        fd = os.pidfd_open(candidate['pid'], 0)
        temporary.append(fd)
        require(alive(parentfd) and alive(fd), 'stale launch PID')
        require(same_identity(candidate, process_identity(candidate['pid'])), 'candidate identity race')
        parent_ns = nspids(parent['pid'])
        child_ns = nspids(candidate['pid'])
        require(len(child_ns) == len(parent_ns) + 1 and child_ns[-1] == '1', 'not namespace init')
        require(candidate['namespace'] != parent['namespace'] == supervisor['namespace'], 'namespace relationship')
        require(same_identity(parent, process_identity(parent['pid'])), 'bwrap identity race')
        require(same_identity(supervisor, process_identity(supervisor['pid'])), 'supervisor identity race')
        require(same_identity(candidate, process_identity(candidate['pid'])), 'candidate identity race')
        require(alive(fd) and alive(parentfd) and alive(supfd), 'launch exited during validation')
        # Close ancillary handle BEFORE promotion so a close error cannot leak
        # an otherwise validated init into a caller that never received it.
        temporary.remove(parentfd)
        os.close(parentfd)
        promoted = True
        return fd, candidate
    finally:
        close_errors = []
        for handle in temporary:
            if not promoted:
                try:
                    os.close(handle)
                except OSError as exc:
                    close_errors.append('untrusted-close: ' + brief(exc))
        if close_errors:
            # Keep the validation error primary, expose close failures separately.
            active = sys.exc_info()[1]
            if active is not None:
                active.untrusted_close_errors = close_errors
            else:
                raise RuntimeError('; '.join(close_errors))


def send(fd, sig):
    signal.pidfd_send_signal(fd, sig, None, 0)


def namespace_members(namespace, deadline):
    members = []
    entries = list(Path('/proc').iterdir())
    require(len(entries) <= MAX_ENTRIES, 'survivor scan cap')
    for p in entries:
        require(time.monotonic() < deadline, 'survivor scan deadline')
        if not p.name.isdigit():
            continue
        try:
            ns = os.readlink(str(p / 'ns/pid'))
        except FileNotFoundError:
            continue
        # Permission errors deliberately propagate: inaccessible is unknown.
        if ns == namespace:
            members.append(process_identity(int(p.name)))
    return members


def runtime_inventory(roots, deadline):
    records, count = {}, 0
    mount_targets = []
    for line in Path('/proc/self/mountinfo').read_text().splitlines():
        target = line.split()[4]
        require('\\' not in target, 'escaped mount pathname unsupported')
        mount_targets.append(target)
    for root in roots:
        root = str(Path(root).resolve())
        if root in records:
            continue
        require(not any(m == root or m.startswith(root + '/') for m in mount_targets), 'runtime nested mount: ' + root)
        tree = []
        stack = [root]
        while stack:
            require(time.monotonic() < deadline, 'runtime inventory deadline')
            p = stack.pop()
            s = os.lstat(p)
            count += 1
            require(count <= MAX_ENTRIES, 'runtime inventory entry cap')
            require(stat.S_ISREG(s.st_mode) or stat.S_ISDIR(s.st_mode) or stat.S_ISLNK(s.st_mode), 'runtime endpoint/device: ' + p)
            tree.append([p, s.st_mode, s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns,
                         os.readlink(p) if stat.S_ISLNK(s.st_mode) else None])
            if stat.S_ISDIR(s.st_mode):
                with os.scandir(p) as items:
                    stack.extend(e.path for e in items)
        records[root] = sorted(tree)
    return records


def tool_identities(expected):
    roles = tool_roles(expected)
    result, total = {}, 0
    for name, item in expected.items():
        path = item['path']
        require(path.startswith('/usr/bin/'), 'unexpected tool location')
        resolved = os.path.realpath(path)
        require(resolved == item['realpath'], 'realpath mismatch: ' + name)
        s = os.stat(path)
        total += s.st_size
        require(total <= MAX_HASH, 'identity hash cap')
        require(stat.S_ISREG(s.st_mode), 'nonregular tool: ' + name)
        try:
            capability = os.getxattr(path, 'security.capability')
        except OSError as exc:
            import errno
            require(exc.errno == errno.ENODATA, 'capability detection unsupported')
            capability = b''
        require(digest(path) == item['sha256'], 'tool hash mismatch: ' + name)
        if roles[name] == 'EXECUTED':
            require(not s.st_mode & (stat.S_ISUID | stat.S_ISGID), 'privileged executed tool: ' + name)
            require(not capability, 'file capabilities present: ' + name)
        result[name] = dict(item, mode=s.st_mode, capabilities=capability.hex(), role=roles[name])
    require(os.path.realpath('/proc/self/exe') == expected['python3']['realpath'], 'wrong interpreter')
    return result


def host_state():
    import importlib.util
    spec = importlib.util.spec_from_file_location('bound_probe', HERE / 'probe.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    identity = module.identity
    return {'namespaces': {n: os.readlink('/proc/self/ns/' + n) for n in ('mnt','pid','user','net','ipc','uts')},
            'mountinfo': Path('/proc/self/mountinfo').read_text(), 'identity': identity(),
            'route': Path('/proc/net/route').read_text(), 'ipv6_route': Path('/proc/net/ipv6_route').read_text()}


def argv(mode, config, infofd):
    command = [BWRAP, '--unshare-user', '--unshare-pid', '--unshare-net', '--unshare-ipc',
               '--die-with-parent', '--new-session', '--cap-drop', 'ALL', '--clearenv',
               '--setenv', 'PATH', '/usr/bin:/bin', '--setenv', 'LANG', 'C',
               '--info-fd', str(infofd), '--ro-bind', '/usr', '/usr']
    for p in ('/bin', '/lib', '/lib64'):
        if os.path.islink(p):
            command += ['--symlink', os.readlink(p), p]
        elif os.path.isdir(p):
            command += ['--ro-bind', p, p]
    if os.path.isfile('/etc/machine-id'):
        no_links('/etc/machine-id')
        command += ['--ro-bind', '/etc/machine-id', '/etc/machine-id']
    command += ['--ro-bind', str(HERE / 'probe.py'), '/probe.py',
                '--ro-bind', str(ROOT / 'protected/ro'), '/ro',
                '--bind', str(ROOT / 'rw'), '/rw', '--symlink', '/rw/tmp', '/tmp',
                '--proc', '/proc', '--dir', '/dev',
                '--dev-bind', '/dev/null', '/dev/null', '--dev-bind', '/dev/zero', '/dev/zero',
                '--dev-bind', '/dev/random', '/dev/random', '--dev-bind', '/dev/urandom', '/dev/urandom',
                '--dir', str(ROOT), '--chdir', '/rw', '--remount-ro', '/',
                '--', PYTHON, '-I', '-B', '-S', '/probe.py', mode]
    if mode == 'controls':
        command.append(json.dumps(config, sort_keys=True))
    return command


TERMINAL_RESERVE = 16384
CLAIMED = False


def brief(exc):
    return repr(exc)[:240]


class Receipts:
    def __init__(self):
        self.used = 0
        self.cleanup = []

    def save(self, name, data, terminal=False):
        require((name == 'final.json') == terminal, 'terminal receipt name reserved')
        raw = json.dumps(data, sort_keys=True, indent=2).encode() + b'\n'
        limit = MAX_OUTPUT if terminal else MAX_OUTPUT - TERMINAL_RESERVE
        require(not terminal or len(raw) <= TERMINAL_RESERVE, 'terminal receipt cap')
        require(self.used + len(raw) <= limit, 'aggregate receipt cap')
        # Charge before open/write: even a partial failed write consumes budget.
        self.used += len(raw)
        with open(ROOT / 'observer' / name, 'xb') as f:
            require(f.write(raw) == len(raw), 'short receipt write')

    def finish(self, final):
        compact = {k: final[k] for k in ('status', 'authorization', 'ready_for_build', 'vendor_run')}
        compact.update(primary_error=final.get('error'), cleanup=self.cleanup,
                       attempt_count=len(final['attempts']), retained_root=str(ROOT))
        if len(json.dumps(compact, sort_keys=True, indent=2).encode()) + 1 > TERMINAL_RESERVE:
            compact['status'] = 'INCONCLUSIVE'
            compact['cleanup'] = [{'teardown': r.get('teardown', 'UNKNOWN'),
                                   'error_count': len(r.get('errors', []))} for r in self.cleanup[:6]]
            compact['detail_omitted'] = 'terminal cap; consult individual retained receipts'
            final['status'] = 'INCONCLUSIVE'
        try:
            self.save('final.json', compact, terminal=True)
            return True
        except BaseException as exc:
            print(json.dumps({'status': 'INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE',
                              'retained_root': str(ROOT), 'final_receipt': 'missing_or_partial',
                              'primary_error': final.get('error'), 'terminal_error': brief(exc),
                              'cleanup': self.cleanup, 'authorization': False,
                              'ready_for_build': False}), file=sys.stderr)
            return False


def cleanup_attempt(supervisor, supervisor_status, supfd, initfd, init, streams):
    """Independent best efforts; a sent signal is never evidence of exit."""
    report = {'errors': [], 'supervisor_reaped': supervisor_status is not None,
              'init_exited': False, 'namespace_empty': False, 'teardown': 'UNKNOWN'}
    def error(label, exc):
        report['errors'].append(label + ': ' + brief(exc))
    for label, fd in (('init', initfd), ('supervisor', supfd)):
        if fd is not None:
            # Do not let a failed liveness query suppress the stop attempt.
            try:
                send(fd, signal.SIGKILL)
            except ProcessLookupError:
                pass
            except BaseException as exc:
                error(label + '-stop', exc)
    if supfd is None and supervisor_status is None:
        # Our unreaped direct fork child cannot have its PID reused.
        try:
            os.kill(supervisor, signal.SIGKILL)
        except ProcessLookupError:
            pass
        except BaseException as exc:
            error('owned-supervisor-stop', exc)
    end = time.monotonic() + 2
    try:
        while not report['supervisor_reaped'] and time.monotonic() < end:
            got, status = os.waitpid(supervisor, os.WNOHANG)
            if got:
                report['supervisor_reaped'] = True
            else:
                time.sleep(0.02)
    except BaseException as exc:
        error('reap', exc)
    if initfd is not None:
        try:
            remaining = max(0, end - time.monotonic())
            report['init_exited'] = bool(select.select([initfd], [], [], remaining)[0])
        except BaseException as exc:
            error('init-exit-check', exc)
    if init is not None:
        try:
            report['namespace_empty'] = not namespace_members(init['namespace'], end)
        except BaseException as exc:
            error('namespace-check', exc)
    for fd in [initfd, supfd, *streams]:
        if fd is not None:
            try:
                os.close(fd)
            except BaseException as exc:
                error('close', exc)
    if all(report[k] for k in ('supervisor_reaped', 'init_exited', 'namespace_empty')):
        report['teardown'] = 'CONFIRMED'
    return report


def attempt(kind, config, receipts, batch_deadline):
    """One fixed launch; pipes only. Init termination uses stable kernel pidfd."""
    started = time.monotonic()
    deadline = min(batch_deadline, started + 20)
    allocated = []
    try:
        for _ in range(3):
            allocated.extend(os.pipe())
        ir, iw, out_r, out_w, err_r, err_w = allocated
        command = argv('controls' if kind == 'controls' else 'lifecycle', config, iw)
        receipts.save(kind + '-launch.json', {'argv': command, 'env': ENV, 'cwd': str(ROOT / 'rw')})
        # This supervisor creates exactly one child, and never forks again.
        outer_pid = os.getpid()
        supervisor = os.fork()
    except BaseException:
        errors = []
        for fd in allocated:
            try:
                os.close(fd)
            except BaseException as exc:
                errors.append(brief(exc))
        receipts.cleanup.append({'kind': kind, 'teardown': 'NO_LAUNCH', 'errors': errors})
        raise
    if supervisor == 0:
        try:
            libc = ctypes.CDLL(None, use_errno=True)
            require(libc.prctl(1, signal.SIGKILL, 0, 0, 0) == 0, 'supervisor PDEATHSIG unavailable')
            require(os.getppid() == outer_pid, 'outer controller already lost')
            signal.signal(signal.SIGALRM, signal.SIG_DFL)
            signal.alarm(19)
            os.close(ir); os.close(out_r); os.close(err_r)
            with open('/dev/null', 'rb') as null:
                proc = subprocess.Popen(command, stdin=null, stdout=out_w, stderr=err_w,
                                        pass_fds=(iw,), close_fds=True, env=ENV, cwd=str(ROOT / 'rw'))
            os.close(iw); os.close(out_w); os.close(err_w)
            os._exit(0 if proc.wait(timeout=19) == 0 else 1)
        except BaseException:
            os._exit(2)
    pending_writes = {iw, out_w, err_w}
    supfd = None
    initfd = None
    init = None
    streams = {ir: bytearray(), out_r: bytearray(), err_r: bytearray()}
    open_streams = set(streams)
    event_time = None
    term_time = None
    killed = False
    failure = None
    validation_close_errors = []
    supervisor_status = None
    try:
        while pending_writes:
            os.close(pending_writes.pop())
        supfd, sup_identity = verified_pidfd(supervisor)
        while time.monotonic() < deadline:
            for fd in select.select(list(open_streams), [], [], 0.05)[0]:
                data = os.read(fd, 65536)
                if not data:
                    open_streams.remove(fd)
                    continue
                require(sum(len(b) for b in streams.values()) + len(data) < min(1048576, (MAX_OUTPUT - receipts.used) // 8),
                        'pipe receipt cap')
                streams[fd].extend(data)
            if init is None and streams[ir]:
                try:
                    info = json.loads(streams[ir])
                except ValueError:
                    info = None
                if info is not None:
                    pid = info.get('child-pid')
                    require(type(pid) is int and pid > 1, 'missing bwrap child-pid')
                    candidate = process_identity(pid)
                    if candidate['namespace'] == os.readlink('/proc/self/ns/pid'):
                        continue  # info-fd may arrive before namespace setup
                    initfd, init = launch_init_pidfd(candidate, supfd, sup_identity)
                    receipts.save(kind + '-init.json', {'info': info, 'identity': init, 'supervisor': sup_identity})
            lines = streams[out_r].decode('utf-8').splitlines()
            ready = any('"kind": "lifecycle-ready"' in line for line in lines) and any('"kind": "descendant"' in line for line in lines)
            now = time.monotonic()
            if kind != 'controls' and ready and init is not None and event_time is None and (kind == 'parent-loss' or now - started >= 2):
                # Validate descendant namespace membership before any signal.
                events = [json.loads(line) for line in lines]
                descendant = next(e for e in events if e['kind'] == 'descendant')
                require(descendant['pid_namespace'] == init['namespace'], 'descendant namespace mismatch')
                require(descendant['sid'] != descendant['pid'], 'doublefork/setsid topology absent')
                require(len(namespace_members(init['namespace'], deadline)) >= 2, 'missing live descendants')
                event_time = now
                if kind == 'parent-loss':
                    send(supfd, signal.SIGKILL)
                else:
                    send(initfd, signal.SIGTERM)
                    term_time = now
            if term_time is not None and now - term_time >= 10 and not killed:
                if not select.select([initfd], [], [], 0)[0]:
                    send(initfd, signal.SIGKILL)
                    killed = True
            if kind == 'parent-loss' and event_time is not None and now - event_time >= 10:
                require(select.select([initfd], [], [], 0)[0], 'parent-loss did not terminate init within grace')
            if supervisor_status is None:
                got, status = os.waitpid(supervisor, os.WNOHANG)
                if got:
                    supervisor_status = status
            if not open_streams and supervisor_status is not None:
                break
        require(not open_streams and supervisor_status is not None, 'per-probe deadline or open pipe')
        require(init is not None, 'missing validated init identity')
        require(select.select([initfd], [], [], 0)[0], 'namespace init not exited')
        survivors = namespace_members(init['namespace'], deadline)
        require(not survivors, 'namespace descendants survive')
        events = [json.loads(line) for line in streams[out_r].decode().splitlines()]
        for event in events:
            if 'evidence' in event:
                for n in ('user','mnt','pid','net','ipc'):
                    require(event['evidence']['namespaces'][n] != os.readlink('/proc/self/ns/' + n), 'namespace not private: ' + n)
        if kind == 'controls':
            require(supervisor_status == 0 and len(events) == 1 and events[0]['kind'] == 'controls', 'controls failure')
        else:
            require(event_time is not None, 'lifecycle event never tested')
            require(time.monotonic() - started < 17, 'natural payload alarm could explain teardown')
        return {'kind': kind, 'controls_observed': True, 'events': events, 'survivors': survivors,
                'term_sent': term_time is not None, 'kill_sent': killed, 'supervisor_status': supervisor_status}
    except BaseException as exc:
        failure = brief(exc)
        validation_close_errors = getattr(exc, 'untrusted_close_errors', [])
        raise
    finally:
        report = cleanup_attempt(supervisor, supervisor_status, supfd, initfd, init, [*streams, *pending_writes])
        report['errors'].extend(validation_close_errors)
        report['kind'] = kind
        receipts.cleanup.append(report)
        try:
            receipts.save(kind + '-pipes.json', {'info': streams[ir].decode(errors='replace'),
                          'stdout': streams[out_r].decode(errors='replace'), 'stderr': streams[err_r].decode(errors='replace'),
                          'primary_error': failure, 'cleanup': report})
        except BaseException as exc:
            report['errors'].append('pipes-receipt: ' + brief(exc))
        if failure is None:
            require(not report['errors'] and report['teardown'] == 'CONFIRMED', 'cleanup incomplete; see terminal receipt')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bundle-sha256', required=True)
    parser.add_argument('--inputs', required=True)
    parser.add_argument('--inputs-sha256', required=True)
    parser.add_argument('--acknowledge-partial-nonvendor-only', action='store_true', required=True)
    args = parser.parse_args()
    require(digest(HERE / 'HASHES.json') == args.bundle_sha256, 'bundle identity mismatch')
    manifest = json.loads((HERE / 'HASHES.json').read_text())
    require({'preflight.py', 'probe.py', 'tools.json'} <= set(manifest), 'incomplete bundle manifest')
    for name, expected in manifest.items():
        require('/' not in name and name not in ('.','..'), 'bad manifest name')
        no_links(str(HERE / name))
        require(digest(HERE / name) == expected, 'bundle member mismatch: ' + name)
    no_links(os.path.abspath(args.inputs))
    require(digest(args.inputs) == args.inputs_sha256, 'inputs identity mismatch')
    inputs = json.loads(Path(args.inputs).read_text())
    require(inputs['approval_scope'] == 'partial-nonvendor-fixture-controls-only', 'approval scope mismatch')
    require(socket.gethostname() == 'Agilex7Workstation', 'wrong host')
    require(os.geteuid() == 1000 and os.getuid() == 1000 and pwd.getpwuid(1000).pw_name == 'uwb_student00', 'wrong user')
    require(os.environ.get('TMUX') == '/tmp/tmux-1000/default,7828,4', 'named tmux server identity drift')
    require(hasattr(os, 'pidfd_open') and hasattr(signal, 'pidfd_send_signal'), 'pidfd unavailable; no fallback')
    expected = json.loads((HERE / 'tools.json').read_text())
    expected['tmux'] = inputs['tmux_tool']
    require(expected['tmux']['path'] == '/usr/bin/tmux', 'wrong tmux path')
    tools = tool_identities(expected)
    tmux = subprocess.run(['/usr/bin/tmux', '-S', '/tmp/tmux-1000/default', 'display-message', '-p', '-t', 'ia840f_migration_preflight',
                           '#{session_name}|#{session_id}|#{pane_id}|#{pane_pid}'],
                          stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=ENV, timeout=3, check=True)
    require(tmux.stdout == b'ia840f_migration_preflight|$4|%4|25387\n', 'named tmux pane identity drift')
    protected = inputs['protected_absent_paths']
    require(set(protected) == {'original', 'work03', 'board_boundary_1', 'board_boundary_2'}, 'exact protected path roles required')
    for p in protected.values():
        no_links(p)
        require(p.startswith('/home/uwb_student00/ahls/new_BSP/'), 'unexpected protected location')
        require(not (str(ROOT).startswith(p.rstrip('/') + '/') or p.startswith(str(ROOT))), 'fixture overlaps protected path')
    for p in RESERVED:
        no_links(p, absent=True)
        require(not os.path.lexists(p), 'reserved path exists; stop')
    help_result = subprocess.run([BWRAP, '--help'], stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE, env=ENV, timeout=3, check=True)
    for option in ('--unshare-user','--unshare-pid','--unshare-net','--unshare-ipc','--die-with-parent',
                   '--new-session','--cap-drop','--clearenv','--info-fd','--remount-ro'):
        require(option.encode() in help_result.stdout, 'unsupported bwrap option: ' + option)
    os.umask(0o077)
    claim(ROOT)
    receipts = Receipts()
    listeners = []
    deadline = time.monotonic() + 300
    final = {'status': 'INCONCLUSIVE', 'authorization': False, 'ready_for_build': False, 'vendor_run': False,
             'license_compatibility': 'UNKNOWN', 'attempts': [], 'omissions': [
                 'Finite candidate identity maps, native chains, exact BMC/board and original/work03 before/after content inventories are NOT implemented.',
                 'Vendor installation and license are deliberately absent. This runtime-only fixture view does not validate the proposed vendor view.',
                 'Installed unshare/mount/setpriv version/help and userns/LSM discovery are not collected.',
                 'Metadata comparison is not a snapshot or a hard resource quota; no complete syscall/exec audit.']}
    try:
        receipts.save('inputs.json', {'tools': tools, 'inputs': inputs, 'bundle_sha256': args.bundle_sha256,
                                   'tmux': tmux.stdout.decode(), 'bwrap_help': help_result.stdout.decode()})
        before = host_state()
        receipts.save('host-before.json', before)
        roots = ['/usr'] + [p for p in ('/bin','/lib','/lib64') if os.path.isdir(p)]
        inventory = runtime_inventory(roots, min(deadline, time.monotonic() + 60))
        receipts.save('runtime-before.json', inventory)
        os.mkdir(ROOT / 'protected/ro', 0o700)
        (ROOT / 'protected/ro/canary').write_bytes(b'protected-canary\n')
        os.mkfifo(ROOT / 'protected/host.fifo', 0o600)
        os.mkdir(ROOT / 'rw/tmp', 0o700)
        pathname = str(ROOT / 'protected/host.sock')
        abstract = 'mailbox-preflight-isolation-7c407469a419-u01'
        for family, address in ((socket.AF_INET, ('127.0.0.1', 0)), (socket.AF_UNIX, '\0' + abstract), (socket.AF_UNIX, pathname)):
            s = socket.socket(family, socket.SOCK_STREAM)
            listeners.append(s)
            if family == socket.AF_UNIX and address == pathname:
                old_cwd = os.getcwd()
                try:
                    os.chdir(str(ROOT))
                    s.bind('protected/host.sock')
                finally:
                    os.chdir(old_cwd)
            else:
                s.bind(address)
            s.listen(1); s.setblocking(False)
        config = {'port': listeners[0].getsockname()[1], 'abstract': abstract, 'pathname': 'protected/host.sock', 'synthetic_cwd': str(ROOT),
                  'absent': list(protected.values()) + RESERVED + [str(ROOT / 'observer'), str(ROOT / 'protected'), '/opt', '/run', '/var', '/sys']}
        for kind in ('controls', 'timeout', 'parent-loss'):
            result = attempt(kind, config, receipts, deadline)
            final['attempts'].append(result)
            require(not select.select(listeners, [], [], 0)[0], 'host listener received connection')
            require((ROOT / 'protected/ro/canary').read_bytes() == b'protected-canary\n', 'outside canary changed')
            require(host_state() == before, 'host namespace/mount/network identity drift')
            receipts.save(kind + '-result.json', result)
        require(runtime_inventory(roots, min(deadline, time.monotonic() + 60)) == inventory, 'runtime metadata drift')
        require(all(not os.path.lexists(p) for p in RESERVED), 'reserved path changed')
        receipts.save('host-after.json', host_state())
        final['status'] = 'FINITE_FIXTURE_CONTROLS_OBSERVED_PROPOSAL_INCOMPLETE'
    except BaseException as exc:
        final['error'] = brief(exc)
    finally:
        for s in listeners:
            try:
                s.close()
            except BaseException as exc:
                receipts.cleanup.append({'listener_close_error': brief(exc)})
                final['status'] = 'INCONCLUSIVE'
        retained = receipts.finish(final)
    print(json.dumps({'status': final['status'] if retained else 'INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE',
                      'receipt': str(ROOT / 'observer/final.json') if retained else None,
                      'retained_root': str(ROOT), 'authorization': False, 'ready_for_build': False}))
    # Never a full-preflight success exit, even when all implemented controls pass.
    return 2


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(json.dumps({'status': 'INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE' if CLAIMED else 'REFUSED_BEFORE_CLAIM',
                          'retained_root': str(ROOT) if CLAIMED else None,
                          'final_receipt': 'missing_or_partial' if CLAIMED else None, 'error': brief(exc),
                          'authorization': False, 'ready_for_build': False}), file=sys.stderr)
        sys.exit(2)
