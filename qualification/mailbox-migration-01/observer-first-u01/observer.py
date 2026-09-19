#!/usr/bin/env python3
"""Bounded NONVENDOR preflight supervisor. Vendor execution deliberately refused.

Not a sandbox. No complete strace scope parser is implemented; see README.md.
"""
import argparse
import hashlib
import json
import multiprocessing as mp
import os
from pathlib import Path
import re
import shutil
import signal
import stat
import subprocess
import sys
import time

PROPOSAL_SHA256 = '3a43e54127052568364e5bdbeb1e70b7a2d98a0454132f9777c4c24859bfaf83'
HERE = Path(__file__).resolve().parent
PROPOSAL = HERE.parent / 'first-experiment-binding-proposal.json'
LIMITS = dict(deadline=1800, trace_limit=2147483648, grace=10, poll=1)
OPTIONS = ['-ff', '-ttt', '-T', '-yy', '-v', '-s', '65535', '-e', 'trace=all',
           '-e', 'raw=read,pread64,readv,preadv,preadv2']


class Refusal(RuntimeError):
    pass


def digest(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for b in iter(lambda: f.read(1024 * 1024), b''):
            h.update(b)
    return h.hexdigest()


def put(path, data):
    with open(path, 'x') as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write('\n')
        f.flush()
        os.fsync(f.fileno())


def identity(path):
    p = Path(path)
    return dict(path=str(p), resolved=str(p.resolve(strict=True)), sha256=digest(p))


def manifest(roots):
    """No symlink following; unreadable/special entries fail, never disappear."""
    out = {}
    def visit(p):
        s = p.lstat()
        entry = dict(mode=s.st_mode, size=s.st_size, mtime_ns=s.st_mtime_ns,
                     inode=s.st_ino, device=s.st_dev)
        if stat.S_ISLNK(s.st_mode):
            entry['symlink'] = os.readlink(p)
        elif stat.S_ISREG(s.st_mode):
            entry['sha256'] = digest(p)
            if p.lstat() != s:
                raise Refusal('protected file changed during hash: ' + str(p))
        elif not stat.S_ISDIR(s.st_mode):
            raise Refusal('special protected path: ' + str(p))
        out[str(p)] = entry
        if stat.S_ISDIR(s.st_mode):
            for c in sorted(p.iterdir()):
                visit(c)
    if not roots:
        raise Refusal('protected roots required')
    for root in roots:
        visit(Path(root).absolute())
    return out


def claim(path, scratch):
    path, scratch = Path(path).absolute(), Path(scratch).absolute()
    if path == scratch or scratch in path.parents or path in scratch.parents:
        raise Refusal('observation and scratch must be disjoint')
    for p in [path.parent, *path.parent.parents]:
        if p.is_symlink():
            raise Refusal('symlink observation ancestor: ' + str(p))
    os.umask(0o077)
    path.mkdir(mode=0o700)  # exclusive; never parents=True or exist_ok=True
    return path


def scope_decision(event):
    # This is a fail-closed interface, NOT a syscall parser or detector.
    return 'stop: unsupported scope audit: ' + event


def vendor_gate():
    raise Refusal('vendor launch unsupported: complete cwd/dirfd/FD/rename/mmap '
                  'scope parser and race-safe descendant accounting unavailable; '
                  'no approval or preflight result overrides this gate')


def proc(pid):
    try:
        root = Path('/proc') / str(pid)
        fields = (root / 'stat').read_text().rsplit(')', 1)[1].split()
        return dict(pid=pid, state=fields[0], ppid=int(fields[1]),
                    starttime=int(fields[19]))
    except (FileNotFoundError, ProcessLookupError):
        return None


def alive(record):
    now = proc(record['pid'])
    return now and now['starttime'] == record['starttime'] and now['state'] != 'Z'


def inventory(known):
    table = {}
    for p in Path('/proc').iterdir():
        if p.name.isdigit():
            r = proc(int(p.name))
            if r:
                table[r['pid']] = r
    changed = True
    while changed:
        changed = False
        for pid, r in table.items():
            parent = known.get(r['ppid'])
            if pid not in known and parent and table.get(r['ppid'], {}).get('starttime') == parent['starttime']:
                known[pid] = r
                changed = True
    return [r for r in known.values() if alive(r)]


def signal_known(known, sig):
    # pidfd avoids a PID reuse race between identity check and kill.
    for r in inventory(known):
        try:
            fd = os.pidfd_open(r['pid'])
            try:
                if alive(r):
                    signal.pidfd_send_signal(fd, sig)
            finally:
                os.close(fd)
        except ProcessLookupError:
            pass


def watchdog(conn, evidence, deadline, trace_limit, grace, poll, trace_required):
    evidence = Path(evidence)
    known, trace_state = {}, {}
    begin = health = time.monotonic()
    reason, root = None, None
    put(evidence / 'watchdog-start.json', dict(pid=os.getpid(),
        process=proc(os.getpid()), python=identity(sys.executable),
        observer=identity(__file__), monotonic=begin))
    conn.send(('ready', os.getpid()))
    try:
        while reason is None:
            now = time.monotonic()
            while conn.poll():
                kind, value = conn.recv()
                if kind == 'root':
                    root = proc(value)
                    if not root:
                        raise Refusal('launch root vanished before registration')
                    known[value] = root
                    conn.send(('registered', value))
                elif kind == 'health':
                    health = now
                elif kind == 'stop':
                    reason = value
                elif kind == 'complete':
                    reason = 'completed'
            live = inventory(known)
            with open(evidence / 'processes.jsonl', 'a') as f:
                for r in live:
                    p = Path('/proc') / str(r['pid'])
                    row = dict(r, monotonic=now)
                    try:
                        row.update(exe=os.readlink(p / 'exe'), cwd=os.readlink(p / 'cwd'),
                                   maps=(p / 'maps').read_text())
                    except (FileNotFoundError, ProcessLookupError):
                        row['snapshot_race'] = True
                    f.write(json.dumps(row) + '\n')
            traces = list(evidence.glob('syscall.*'))
            size = 0
            current = {}
            for path in traces:
                s = path.lstat()
                if not stat.S_ISREG(s.st_mode):
                    raise Refusal('trace replaced with nonregular file')
                current[str(path)] = (s.st_ino, s.st_size)
                prior = trace_state.get(str(path))
                if prior and (prior[0] != s.st_ino or prior[1] > s.st_size):
                    reason = 'trace loss'
                size += s.st_size
            if set(trace_state) - set(current):
                reason = 'trace loss'
            trace_state = current
            if root and size >= trace_limit:
                reason = 'trace byte limit'
            if now - begin >= deadline:
                reason = 'deadline'
            if now - health > max(3 * poll, .3):
                reason = 'observer heartbeat lost'
            if root and trace_required and now - begin > max(3 * poll, .3) and not traces:
                reason = 'trace missing'
            if reason is None:
                time.sleep(poll)
    except BaseException as e:
        reason = 'watchdog error: ' + repr(e)
    finally:
        # Kill all known identities even on normal completion: surviving children
        # cannot become an implicit background-service exception.
        signal_known(known, signal.SIGTERM)
        until = time.monotonic() + grace
        while inventory(known) and time.monotonic() < until:
            time.sleep(min(poll, .1))
            signal_known(known, signal.SIGTERM)
        signal_known(known, signal.SIGKILL)
        time.sleep(min(poll, .1))
        put(evidence / 'watchdog.json', dict(reason=reason, known=list(known.values()),
            survivors=inventory(known), trace_bytes=sum(v[1] for v in trace_state.values()),
            limits=dict(deadline=deadline, trace_limit=trace_limit, grace=grace, poll=poll),
            accounting='proc polling supplemental only; not proof of complete descendants'))
        conn.close()


def start_supervised(argv, evidence, env, *, deadline=1800, trace_limit=2147483648,
                     grace=10, poll=1, trace_required=True):
    """Private primitive for fixed probe/tests, not an authorized vendor launcher."""
    if not hasattr(os, 'pidfd_open') or not hasattr(signal, 'pidfd_send_signal'):
        raise Refusal('pidfd APIs unavailable')
    a, b = mp.Pipe()
    guard = mp.get_context('fork').Process(target=watchdog,
        args=(b, str(evidence), deadline, trace_limit, grace, poll, trace_required))
    guard.start()
    b.close()
    if not a.poll(5) or a.recv()[0] != 'ready':
        raise Refusal('watchdog not ready; no child launched')
    readfd, writefd = os.pipe()
    # Fixed bootstrap waits for watchdog PID/starttime registration before exec.
    bootstrap = 'import os,sys; f=int(sys.argv[1]); b=os.read(f,1); os.close(f); b==b"G" or sys.exit(125); os.execve(sys.argv[2],sys.argv[2:],dict(os.environ))'
    p = None
    try:
        with open(evidence / 'stdout', 'xb') as out, open(evidence / 'stderr', 'xb') as err:
            p = subprocess.Popen([sys.executable, '-I', '-B', '-c', bootstrap,
                                  str(readfd), *argv], pass_fds=(readfd,),
                                 env=env, cwd=evidence, start_new_session=True,
                                 stdin=subprocess.DEVNULL, stdout=out, stderr=err)
        a.send(('root', p.pid))
        if not a.poll(5) or a.recv() != ('registered', p.pid):
            raise Refusal('watchdog registration failed')
        os.write(writefd, b'G')
        return p, guard, a
    except BaseException:
        if p:
            p.kill()
            p.wait()
        a.send(('stop', 'launch setup failure'))
        guard.join(15)
        raise
    finally:
        os.close(readfd)
        os.close(writefd)


# Fixed harmless fork/exec/write/read probe. No arbitrary command accepted.
PROBE = '''import os,sys
p=os.fork()
if p==0:
 os.setsid()
 os.execve(sys.executable,[sys.executable,'-I','-B','-c','import os; f=os.open("probe-output",os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600); os.write(f,b"probe-ok"); os.close(f)'],{'LANG':'C','PATH':'/usr/bin:/bin'})
_,s=os.waitpid(p,0)
f=os.open('probe-input',os.O_RDONLY); os.read(f,128); os.close(f)
sys.exit(os.waitstatus_to_exitcode(s))
'''


def preflight(evidence, protected):
    proposal = json.loads(PROPOSAL.read_text())
    if digest(PROPOSAL) != PROPOSAL_SHA256:
        raise Refusal('proposal source hash differs')
    root = claim(evidence, proposal['candidate_binding']['root'])
    result = dict(probe_passed=False, scope_parser='unsupported',
                  vendor_launch='refused', proposal_sha256=PROPOSAL_SHA256,
                  observer=identity(__file__), python=identity(sys.executable))
    before = None
    p = guard = conn = None
    try:
        if any(Path(r).resolve() == root.resolve() or Path(r).resolve() in root.resolve().parents
               or root.resolve() in Path(r).resolve().parents for r in protected):
            raise Refusal('protected roots and evidence must be disjoint')
        before = manifest(protected)
        put(root / 'before.json', before)
        strace = shutil.which('strace', path='/usr/bin:/bin')
        if not strace:
            raise Refusal('strace unavailable; no probe launched')
        result['strace'] = identity(strace)
        (root / 'probe-input').write_bytes(b'RAW_READ_SENTINEL_MUST_NOT_APPEAR')
        argv = [strace, *OPTIONS, '-o', str(root / 'syscall'),
                sys.executable, '-I', '-B', '-c', PROBE]
        result['argv'] = argv
        env = {'LANG': 'C', 'PATH': '/usr/bin:/bin'}
        result['env'] = env
        p, guard, conn = start_supervised(argv, root, env)
        while p.poll() is None:
            if not guard.is_alive():
                raise Refusal('watchdog died during probe')
            conn.send(('health', None))
            time.sleep(.1)
        conn.send(('complete', None))
        guard.join(12)
        if guard.is_alive():
            raise Refusal('watchdog did not finalize')
        receipt = json.loads((root / 'watchdog.json').read_text())
        result['returncode'] = p.returncode
        texts = [t.read_text() for t in root.glob('syscall.*')]
        text = '\n'.join(texts)
        syscall = lambda name: re.findall(r'^\d+\.\d+ ' + name + r'\(.*$', text, re.M)
        checks = dict(follow_fork=len(texts) >= 2,
                      fork=bool(syscall(r'(?:clone|clone3|fork|vfork)')),
                      exec=len(syscall('execve')) >= 2,
                      write=any('"probe-ok"' in line for line in syscall('write')),
                      raw_read=any(re.match(r'^\d+\.\d+ read\(0x[0-9a-f]+, 0x', line)
                                   for line in syscall('read')),
                      no_read_buffer='RAW_READ_SENTINEL_MUST_NOT_APPEAR' not in text,
                      probe_output=(root / 'probe-output').read_bytes() == b'probe-ok',
                      exits=all('+++ exited with 0 +++' in t for t in texts),
                      watchdog=receipt['reason'] == 'completed' and not receipt['survivors'])
        result['checks'] = checks
        result['probe_passed'] = p.returncode == 0 and all(checks.values())
    except Exception as e:
        result['error'] = repr(e)
    finally:
        if conn:
            if guard.is_alive():
                try:
                    conn.send(('stop', result.get('error', 'preflight incomplete')))
                except (BrokenPipeError, EOFError, OSError):
                    pass
                guard.join(12)
            conn.close()
        if p and p.poll() is None:
            p.kill()
            p.wait()
        if before is not None:
            try:
                after = manifest(protected)
                put(root / 'after.json', after)
                result['protected_unchanged'] = before == after
                result['probe_passed'] &= before == after
            except Exception as e:
                result['after_error'] = repr(e)
                result['probe_passed'] = False
        put(root / 'preflight.json', result)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='mode', required=True)
    pre = sub.add_parser('preflight')
    pre.add_argument('--evidence', required=True, type=Path)
    pre.add_argument('--protected', action='append', required=True, type=Path)
    sub.add_parser('upgrade')
    args = parser.parse_args()
    try:
        if args.mode == 'upgrade':
            vendor_gate()
        result = preflight(args.evidence.absolute(), args.protected)
        print(json.dumps(result, indent=2))
        return 0 if result['probe_passed'] else 2
    except Exception as e:
        print(str(e), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
