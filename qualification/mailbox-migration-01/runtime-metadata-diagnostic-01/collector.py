#!/usr/bin/env python3
"""Read-only, fixed-scope runtime metadata diagnostic; Python 3.9 stdlib."""
import errno
import json
import os
import stat
import sys
import time

CANDIDATES = ('/usr', '/bin', '/lib', '/lib64')
MOUNTINFO = '/proc/self/mountinfo'
MAX_ENTRIES = 250000
MAX_BYTES = 1048576
SECONDS = 60
TMUX = '/tmp/tmux-1000/default,7828,4'


class Stop(Exception):
    pass


class Native:
    clock = staticmethod(time.monotonic)
    lstat = staticmethod(os.lstat)
    readlink = staticmethod(os.readlink)
    scandir = staticmethod(os.scandir)

    def identity(self):
        # Do not invoke NSS, tmux, or any other process to inspect identity.
        return dict(host=os.uname().nodename, uid=os.getuid(), euid=os.geteuid(),
                    gid=os.getgid(), egid=os.getegid(), groups=os.getgroups(),
                    user=os.environ.get('USER'), logname=os.environ.get('LOGNAME'),
                    tmux=os.environ.get('TMUX'))

    def mount_open(self):
        return open(MOUNTINFO, 'rb', buffering=0)


def signature(s):
    return (s.st_dev, s.st_ino, s.st_mode, s.st_size, s.st_mtime_ns, s.st_ctime_ns)


class Collector:
    def __init__(self, backend):
        self.b = backend
        self.start = backend.clock()
        self.deadline = self.start + SECONDS
        self.phase = 'identity'
        self.op = 'start'
        self.path = None
        self.root = None
        self.report = dict(authorization=False, ready_for_build=False, vendor_run=False,
                           counts=dict(visited=0, discovered=0), selection=[],
                           guard='not_checked', last_completed=None, close_errors=[])
        self.active = []

    def label(self, op, path):
        self.op, self.path = op, path

    def check(self):
        if self.b.clock() >= self.deadline:
            raise Stop('deadline')

    def call(self, op, path, fn, *args):
        self.label(op, path)
        self.check()
        value = fn(*args)
        self.report['last_completed'] = dict(operation=op, path=path)
        # Resource acquisitions must transfer ownership before post-call checks.
        if op not in ('mountinfo.open', 'scandir.open'):
            self.check()
        return value

    def failure(self, exc):
        return dict(phase=self.phase, operation=self.op, path=self.path,
                    exception=type(exc).__name__, errno=getattr(exc, 'errno', None),
                    filename=getattr(exc, 'filename', None),
                    filename2=getattr(exc, 'filename2', None),
                    reason=str(exc) if isinstance(exc, Stop) else None,
                    selected_root=self.root, counts=dict(self.report['counts']),
                    elapsed=self.b.clock() - self.start)

    def close(self, obj, op, path):
        # Cleanup must still run after deadline or primary failure. Never retry.
        self.label(op, path)
        try:
            obj.close()
            self.report['last_completed'] = dict(operation=op, path=path)
        except Exception as exc:
            self.report['close_errors'].append(self.failure(exc))
            if 'terminal' not in self.report:
                self.report['terminal'] = self.failure(exc)

    def resolve(self, candidate):
        # Only metadata of components necessary to resolve these fixed candidates.
        pending = candidate.split('/')[1:]
        parts = []
        links = set()
        while pending:
            self.check()
            part = pending.pop(0)
            if part in ('', '.'):
                continue
            if part == '..':
                parts = parts[:-1]
                continue
            path = '/' + '/'.join(parts + [part])
            s = self.call('resolve.lstat', path, self.b.lstat, path)
            if stat.S_ISLNK(s.st_mode):
                if path in links:
                    raise Stop('resolution_cycle')
                links.add(path)
                target = self.call('resolve.readlink', path, self.b.readlink, path)
                again = self.call('resolve.recheck', path, self.b.lstat, path)
                if signature(s) != signature(again):
                    raise Stop('resolution_race')
                if target.startswith('/'):
                    parts = []
                pending = target.split('/') + pending
            else:
                if pending and not stat.S_ISDIR(s.st_mode):
                    raise Stop('resolution_component_not_directory')
                parts.append(part)
        resolved = '/' + '/'.join(parts)
        return resolved, self.call('qualification.lstat', resolved, self.b.lstat, resolved)

    def select(self):
        self.phase = 'selection'
        roots = []
        initial_candidates = {}
        for candidate in CANDIDATES:
            record = dict(candidate=candidate)
            self.report['selection'].append(record)
            try:
                initial = self.call('candidate.lstat', candidate, self.b.lstat, candidate)
            except FileNotFoundError as exc:
                if candidate == '/usr' or exc.errno != errno.ENOENT:
                    raise
                record.update(qualified=False, exclusion='absent', errno=exc.errno)
                continue
            initial_candidates[candidate] = initial
        allowed_exact = {p for p, s in initial_candidates.items() if stat.S_ISDIR(s.st_mode)}
        for record in self.report['selection']:
            candidate = record['candidate']
            if candidate not in initial_candidates:
                continue
            initial = initial_candidates[candidate]
            resolved, s = self.resolve(candidate)
            record.update(resolved=resolved, qualified=stat.S_ISDIR(s.st_mode))
            if not stat.S_ISDIR(s.st_mode):
                if candidate != '/usr' and stat.S_ISREG(s.st_mode):
                    record['exclusion'] = 'not_directory'
                    continue
                raise Stop('candidate_not_directory_or_unsupported_type')
            if not (resolved == '/usr' or resolved.startswith('/usr/') or
                    resolved in allowed_exact):
                raise Stop('resolved_root_outside_scope')
            again = self.call('candidate.recheck', candidate, self.b.lstat, candidate)
            if signature(initial) != signature(again):
                raise Stop('candidate_race')
            # Exact alias dedup, plus nested coverage dedup to walk each path once.
            roots.append((resolved, s))
        result = []
        for path, s in roots:
            if any(path == p or path.startswith(p + '/') for p, _ in result):
                continue
            result = [(p, x) for p, x in result if not p.startswith(path + '/')]
            result.append((path, s))
        self.report['roots'] = [p for p, _ in result]
        return result

    def mount_guard(self, roots):
        self.phase = 'mount_guard'
        handle = self.call('mountinfo.open', MOUNTINFO, self.b.mount_open)
        try:
            chunks = []
            size = 0
            while size < MAX_BYTES:
                chunk = self.call('mountinfo.read', MOUNTINFO, handle.read,
                                  min(65536, MAX_BYTES - size))
                if not chunk:
                    break
                chunks.append(chunk)
                size += len(chunk)
            # Never read a sentinel byte beyond the 1 MiB budget.
            if size == MAX_BYTES:
                raise Stop('mountinfo_input_limit_no_room_to_establish_eof')
            self.label('mountinfo.parse', MOUNTINFO)
            lines = b''.join(chunks).decode('utf-8', 'strict').splitlines()
            if not lines:
                raise Stop('mountinfo_parse_empty')
            for line in lines:
                self.check()
                fields = line.split()
                if len(fields) < 10 or '-' not in fields[6:]:
                    raise Stop('mountinfo_parse')
                separator = fields.index('-', 6)
                if (separator + 4 != len(fields) or
                        not fields[0].isdigit() or not fields[1].isdigit() or
                        len(fields[2].split(':')) != 2 or
                        not all(x.isdigit() for x in fields[2].split(':'))):
                    raise Stop('mountinfo_parse')
                target = fields[4]
                if '\\' in target:
                    raise Stop('escaped_mount_target')
                if not target.startswith('/') or os.path.normpath(target) != target:
                    raise Stop('mountinfo_target_invalid')
                if any(target == p or target.startswith(p + '/') for p, _ in roots):
                    raise Stop('mount_at_or_below_root')
            self.report['guard'] = 'passed'
        except Exception as exc:
            self.report['terminal'] = self.failure(exc)
        finally:
            self.close(handle, 'mountinfo.close', MOUNTINFO)
        if 'terminal' in self.report:
            raise Stop('already_recorded')
        self.check()

    def ancestors(self):
        for path, before, _ in self.active:
            after = self.call('directory.recheck', path, self.b.lstat, path)
            if signature(before) != signature(after):
                raise Stop('directory_race')

    def admit(self, path):
        self.label('discover', path)
        self.check()
        if self.report['counts']['discovered'] >= MAX_ENTRIES:
            raise Stop('discovered_limit')
        self.report['counts']['discovered'] += 1

    def visit(self, path, expected=None):
        self.label('lstat', path)
        self.check()
        if self.report['counts']['visited'] >= MAX_ENTRIES:
            raise Stop('visited_limit')
        self.ancestors()
        s = self.call('lstat', path, self.b.lstat, path)
        self.report['counts']['visited'] += 1
        if expected is not None and signature(s) != signature(expected):
            raise Stop('root_race')
        if not (stat.S_ISDIR(s.st_mode) or stat.S_ISREG(s.st_mode) or stat.S_ISLNK(s.st_mode)):
            raise Stop('unsupported_type')
        if stat.S_ISLNK(s.st_mode):
            self.call('readlink', path, self.b.readlink, path)
        if stat.S_ISDIR(s.st_mode):
            iterator = self.call('scandir.open', path, self.b.scandir, path)
            # Register immediately so all subsequent failures close this iterator.
            self.active.append((path, s, iterator))
        after = self.call('entry.recheck', path, self.b.lstat, path)
        if signature(s) != signature(after):
            raise Stop('entry_race')
        self.ancestors()

    def walk(self, roots):
        self.phase = 'traversal'
        for root, s in roots:
            self.root = root
            self.admit(root)
            self.visit(root, s)
            while self.active:
                self.ancestors()
                path, before, iterator = self.active[-1]
                try:
                    entry = self.call('scandir.iterate', path, next, iterator)
                except StopIteration:
                    self.ancestors()
                    self.active.pop()
                    self.close(iterator, 'scandir.close', path)
                    if 'terminal' in self.report:
                        raise Stop('already_recorded')
                    continue
                name = entry.name
                if not isinstance(name, str) or name in ('', '.', '..') or '/' in name or '\x00' in name:
                    raise Stop('invalid_directory_entry')
                child = path + '/' + name
                self.admit(child)
                self.visit(child)

    def run(self):
        try:
            identity = self.call('identity', None, self.b.identity)
            self.report['identity'] = identity
            if not (identity['host'] == 'Agilex7Workstation' and
                    identity['uid'] == identity['euid'] == 1000 and
                    identity['user'] == identity['logname'] == 'uwb_student00' and
                    identity['tmux'] == TMUX):
                raise Stop('identity_or_context_mismatch')
            roots = self.select()
            self.mount_guard(roots)
            self.walk(roots)
            self.check()
            self.report['terminal'] = dict(result='completed')
        except Exception as exc:
            if 'terminal' not in self.report:
                self.report['terminal'] = self.failure(exc)
        finally:
            while self.active:
                path, _, iterator = self.active.pop()
                self.close(iterator, 'scandir.close', path)
        self.report['elapsed'] = self.b.clock() - self.start
        return self.report


def encode(report):
    data = (json.dumps(report, ensure_ascii=True, separators=(',', ':')) + '\n').encode('ascii')
    if len(data) <= MAX_BYTES:
        return data
    # Reject rather than silently truncate or emit a partial finding.
    fallback = dict(authorization=False, ready_for_build=False, vendor_run=False,
                    terminal=dict(result='INCOMPLETE', reason='output_limit'),
                    counts=report['counts'], elapsed=report['elapsed'],
                    evidence_emitted=False)
    return (json.dumps(fallback, separators=(',', ':')) + '\n').encode('ascii')


def main():
    runner = Collector(Native())
    report = runner.run()
    data = encode(report)
    if runner.b.clock() >= runner.deadline and report['terminal'].get('result') == 'completed':
        runner.label('report.encode', None)
        report['terminal'] = runner.failure(Stop('deadline'))
        report['elapsed'] = runner.b.clock() - runner.start
        data = encode(report)
    sys.stdout.buffer.write(data)
    sys.stdout.buffer.flush()
    return 0 if json.loads(data)['terminal'].get('result') == 'completed' else 1


if __name__ == '__main__':
    sys.exit(main())
