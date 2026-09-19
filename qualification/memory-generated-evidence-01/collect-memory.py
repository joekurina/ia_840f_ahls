#!/usr/bin/env python3
"""Static filesystem capture only. Python 3.9+. See README before use."""
import argparse
import hashlib
import json
import os
import pathlib
import pwd
import stat
import time

SCOPE_SHA256 = 'f8d8259a39295c564dfb8942b6aa039099e1f22253f6b30aa64ab6355c7994bb'
OUTPUT = '/home/uwb_student00/ahls/new_BSP/qualification/memory-generated-evidence-01'


def open_nolinks(path, directory=False):
    """Anchor every component with openat+O_NOFOLLOW; reject ALL symlinks."""
    p = pathlib.PurePosixPath(path)
    if not p.is_absolute() or '..' in p.parts:
        raise ValueError('absolute path without parent components required')
    fd = os.open('/', os.O_RDONLY | os.O_DIRECTORY)
    try:
        for i, component in enumerate(p.parts[1:]):
            is_dir = directory or i < len(p.parts[1:]) - 1
            flags = os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK
            if is_dir:
                flags |= os.O_DIRECTORY
            new_fd = os.open(component, flags, dir_fd=fd)
            os.close(fd)
            fd = new_fd
        return fd
    except Exception:
        os.close(fd)
        raise


def read_regular(path, cap):
    fd = open_nolinks(path)
    try:
        before = os.fstat(fd)
        if not stat.S_ISREG(before.st_mode):
            raise ValueError('not regular file')
        if before.st_size > cap:
            raise ValueError('file_bytes limit: %s > %s' % (before.st_size, cap))
        chunks = []
        remaining = cap + 1
        while remaining:
            data = os.read(fd, min(65536, remaining))
            if not data:
                break
            chunks.append(data)
            remaining -= len(data)
        raw = b''.join(chunks)
        after = os.fstat(fd)
        attrs = ('st_dev', 'st_ino', 'st_size', 'st_mtime_ns', 'st_ctime_ns')
        if len(raw) > cap:
            raise ValueError('file_bytes limit during read')
        if len(raw) != before.st_size or any(getattr(before, k) != getattr(after, k) for k in attrs):
            raise ValueError('changed during read; snapshot rejected')
        return raw, {k: getattr(before, k) for k in attrs}
    finally:
        os.close(fd)


def discover(scope, issues):
    limits = scope['limits']
    selected = set()
    counters = {'entries': 0, 'directories': 0}
    queue = [(r, 0) for r in scope['discovery_roots']]
    while queue:
        path, depth = queue.pop(0)
        if counters['directories'] >= limits['directories']:
            issues.append({'path': path, 'status': 'directories_limit', 'unvisited_directories': len(queue) + 1})
            break
        counters['directories'] += 1
        try:
            fd = open_nolinks(path, directory=True)
            try:
                entries = []
                with os.scandir(fd) as iterator:
                    for entry in iterator:
                        counters['entries'] += 1
                        if counters['entries'] > limits['entries']:
                            issues.append({'path': path, 'status': 'entries_limit', 'discovery_partial': True})
                            return sorted(selected), counters
                        entries.append((entry.name, entry.is_symlink(), entry.is_dir(follow_symlinks=False), entry.is_file(follow_symlinks=False)))
            finally:
                os.close(fd)
            for name, link, is_dir, is_file in sorted(entries):
                child = path + '/' + name
                if link:
                    issues.append({'path': child, 'status': 'symlink_rejected_no_traversal', 'target_not_read': True})
                elif is_dir:
                    if name in scope['pruned_directory_names']:
                        continue
                    if depth >= limits['depth']:
                        issues.append({'path': child, 'status': 'depth_limit'})
                    else:
                        queue.append((child, depth + 1))
                elif is_file:
                    p = pathlib.PurePosixPath(child)
                    metadata = p.suffix in scope['metadata_suffixes']
                    top_hdl = p.suffix in ('.sv', '.v') and p.stem in scope['module_stems'] and 'synth' in p.parts
                    if metadata or top_hdl:
                        selected.add(child)
                        if len(selected) >= limits['selected_files']:
                            issues.append({'path': child, 'status': 'discovery_selected_files_limit'})
                            return sorted(selected), counters
        except (OSError, ValueError) as exc:
            issues.append({'path': path, 'status': 'directory_unreadable_missing_or_symlink', 'error': str(exc)})
    return sorted(selected), counters


def collect(scope):
    """Called on synthetic fixture roots by tests; production scope is hash-pinned."""
    issues = []
    records = []
    total = 0
    exact = {r['path']: r for r in scope['exact_files']}
    discovered, counters = discover(scope, issues)
    # Exact targets first, then discovered synthesis tops, then saved metadata/manifests.
    discovered.sort(key=lambda p: (pathlib.PurePosixPath(p).suffix not in ('.v', '.sv'), p))
    paths = list(exact) + [p for p in discovered if p not in exact]
    for i, path in enumerate(paths):
        if i >= scope['limits']['selected_files']:
            issues.append({'status': 'selected_files_limit', 'uncaptured_paths': paths[i:]})
            break
        record = {'original_path': path, 'purpose': exact.get(path, {}).get('purpose', 'bounded generated memory discovery')}
        try:
            cap = min(scope['limits']['file_bytes'], scope['limits']['total_bytes'] - total)
            if cap <= 0:
                raise ValueError('total_bytes limit')
            raw, info = read_regular(path, cap)
            total += len(raw)
            text = raw.decode('utf-8', errors='strict')
            if '\x00' in text:
                raise ValueError('NUL content is not captured as text')
            record.update(status='captured_full_text', bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), content=text, stat=info)
            expected = exact.get(path, {}).get('expected_sha256')
            if expected:
                record['expected_sha256'] = expected
                record['binding_matches'] = record['sha256'] == expected
                if not record['binding_matches']:
                    issues.append({'path': path, 'status': 'reviewed_binding_mismatch'})
        except FileNotFoundError as exc:
            record.update(status='missing', error=str(exc))
            issues.append({'path': path, 'status': 'missing'})
        except (OSError, ValueError, UnicodeError) as exc:
            record.update(status='not_captured', error=str(exc))
            issues.append({'path': path, 'status': 'read_limit_symlink_or_format_failure', 'error': str(exc)})
        records.append(record)
    return {'schema': 1, 'status': 'partial' if issues else 'bounded_scope_captured_not_qualified',
            'complete_generated_tree': False, 'generated_interface_accepted': False,
            'ready_for_build': False, 'authorization': False, 'files': records,
            'issues': issues, 'discovery_counters': counters, 'bytes_read': total,
            'captured_file_count': sum(r['status'] == 'captured_full_text' for r in records),
            'scope': scope, 'scope_sha256': SCOPE_SHA256,
            'limitations': ['No vendor/Qsys API invocation; static serialization only.',
                            'All symlinks refused, including in-root links; no link target bytes captured.',
                            'Inner megafunctions, simulation trees and non-selected HDL intentionally excluded.',
                            'Missing skipped-stage headers remain missing; no generation authorized.',
                            'Per-file stable read is not an atomic whole-tree snapshot.',
                            'No synthesis, placement, calibration or hardware acceptance.']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--operator-verified-endpoint', required=True)
    parser.add_argument('--verified-tmux-session', required=True)
    parser.add_argument('--verified-tmux-pane', required=True)
    parser.add_argument('--verified-tmux-value', required=True)
    args = parser.parse_args()
    # Identity before target discovery or output creation. No subprocesses permitted.
    if os.uname().nodename != 'Agilex7Workstation' or pwd.getpwuid(os.getuid()).pw_name != 'uwb_student00' or os.getuid() != os.geteuid():
        raise SystemExit('REFUSED: exact host/user mismatch')
    if os.path.abspath(__file__) != OUTPUT + '/collect-memory.py' or os.getcwd() != OUTPUT:
        raise SystemExit('REFUSED: script/cwd must be exact reviewed qualification directory')
    raw, unused = read_regular(OUTPUT + '/scope.json', 65536)
    if hashlib.sha256(raw).hexdigest() != SCOPE_SHA256:
        raise SystemExit('REFUSED: scope hash mismatch')
    scope = json.loads(raw)
    if (args.operator_verified_endpoint != scope['endpoint'] or
            args.verified_tmux_session != scope['tmux_session'] or
            not os.environ.get('TMUX') or not os.environ.get('TMUX_PANE') or
            args.verified_tmux_pane != os.environ['TMUX_PANE'] or
            args.verified_tmux_value != os.environ['TMUX']):
        raise SystemExit('REFUSED: live operator endpoint/tmux verification required')
    directory = open_nolinks(OUTPUT, directory=True)
    try:
        # Exclusive reservation before collection; existing receipts are never overwritten.
        fd = os.open(scope['receipt_name'], os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=directory)
        with os.fdopen(fd, 'w', encoding='utf-8') as dest:
            started = time.time()
            try:
                receipt = collect(scope)
            except Exception as exc:
                receipt = {'status': 'aborted_partial', 'ready_for_build': False, 'authorization': False, 'error': repr(exc)}
            receipt['identity'] = {'host': os.uname().nodename, 'user': pwd.getpwuid(os.getuid()).pw_name,
                                   'uid': os.getuid(), 'tmux_environment': os.environ['TMUX'],
                                   'pane_environment': os.environ['TMUX_PANE'],
                                   'operator_asserted_session': args.verified_tmux_session,
                                   'operator_asserted_endpoint': args.operator_verified_endpoint,
                                   'tmux_session_independently_verified_by_collector': False}
            receipt['started_unix'] = started
            receipt['finished_unix'] = time.time()
            json.dump(receipt, dest, ensure_ascii=True, indent=2)
            dest.write('\n')
            dest.flush()
            os.fsync(dest.fileno())
        captured, unused = read_regular(OUTPUT + '/' + scope['receipt_name'], 224 * 1024 * 1024)
        if json.loads(captured) != receipt:
            raise SystemExit('REFUSED: receipt readback differs')
        print(json.dumps({'receipt': OUTPUT + '/' + scope['receipt_name'], 'sha256': hashlib.sha256(captured).hexdigest(), 'status': receipt['status']}))
        return 2 if receipt['status'] in ('partial', 'aborted_partial') else 0
    finally:
        os.close(directory)


if __name__ == '__main__':
    raise SystemExit(main())
