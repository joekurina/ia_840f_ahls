"""Inert fake-backend tests: never instantiate Native or inspect runtime roots."""
import errno
import io
import json
import stat
import unittest
from types import SimpleNamespace as NS
from unittest.mock import patch
import collector as c


def meta(mode, inode=1):
    return NS(st_mode=mode, st_dev=1, st_ino=inode, st_size=0,
              st_mtime_ns=0, st_ctime_ns=0)


class Handle:
    def __init__(self, backend, kind, path, content=None):
        self.b, self.kind, self.path = backend, kind, path
        self.closed = False
        self.data = io.BytesIO(content) if content is not None else None
        self.items = iter(backend.children.get(path, []))

    def read(self, n):
        self.b.hit('mountinfo.read', self.path)
        self.b.read_requested += n
        return self.data.read(n)

    def __next__(self):
        self.b.hit('scandir.iterate', self.path)
        return NS(name=next(self.items))

    def close(self):
        self.closed = True
        self.b.hit(self.kind + '.close', self.path)


class Fake:
    def __init__(self):
        self.now = 0
        self.nodes = {'/usr': meta(stat.S_IFDIR | 0o755),
                      '/usr/file': meta(stat.S_IFREG | 0o644, 2),
                      '/usr/link': meta(stat.S_IFLNK | 0o777, 3)}
        self.links = {'/usr/link': '/never-follow-this'}
        self.children = {'/usr': ['file', 'link']}
        self.mounts = b'1 0 0:1 / / rw - rootfs rootfs rw\n'
        self.handles, self.calls = [], []
        self.faults = {}
        self.hook = None
        self.read_requested = 0
        self.ident = dict(host='Agilex7Workstation', uid=1000, euid=1000,
                          gid=1000, egid=1000, groups=[1000],
                          user='uwb_student00', logname='uwb_student00', tmux=c.TMUX)

    def clock(self):
        return self.now

    def identity(self):
        return self.ident

    def hit(self, op, path):
        self.calls.append((op, path))
        if self.hook:
            self.hook(op, path)
        if (op, path) in self.faults:
            raise self.faults[(op, path)]

    def lstat(self, path):
        self.hit('lstat', path)
        if path not in self.nodes:
            raise FileNotFoundError(errno.ENOENT, 'fake absent', path)
        return self.nodes[path]

    def readlink(self, path):
        self.hit('readlink', path)
        return self.links[path]

    def scandir(self, path):
        self.hit('scandir.open', path)
        handle = Handle(self, 'scandir', path)
        self.handles.append(handle)
        return handle

    def mount_open(self):
        self.hit('mountinfo.open', c.MOUNTINFO)
        handle = Handle(self, 'mountinfo', c.MOUNTINFO, self.mounts)
        self.handles.append(handle)
        return handle


class Tests(unittest.TestCase):
    def run_fake(self, b=None):
        b = b or Fake()
        report = c.Collector(b).run()
        self.assertTrue(all(h.closed for h in b.handles))
        self.assertFalse(report['authorization'])
        self.assertFalse(report['ready_for_build'])
        self.assertFalse(report['vendor_run'])
        self.assertLessEqual(len(c.encode(report)), c.MAX_BYTES)
        return report

    def test_completion_and_no_symlink_follow(self):
        b = Fake()
        r = self.run_fake(b)
        self.assertEqual(r['terminal'], {'result': 'completed'})
        self.assertEqual(r['counts'], {'visited': 3, 'discovered': 3})
        self.assertNotIn(('lstat', '/never-follow-this'), b.calls)

    def test_identity_mismatches(self):
        for key, value in [('host', 'other'), ('uid', 0), ('euid', 0),
                           ('user', 'other'), ('logname', None), ('tmux', 'other')]:
            with self.subTest(key=key):
                b = Fake()
                b.ident[key] = value
                self.assertEqual(self.run_fake(b)['terminal']['reason'], 'identity_or_context_mismatch')
                self.assertEqual(b.calls, [])

    def test_permission_operations(self):
        for op, path, expected in [
            ('lstat', '/usr', 'candidate.lstat'),
            ('lstat', '/bin', 'candidate.lstat'),
            ('mountinfo.open', c.MOUNTINFO, 'mountinfo.open'),
            ('mountinfo.read', c.MOUNTINFO, 'mountinfo.read'),
            ('mountinfo.close', c.MOUNTINFO, 'mountinfo.close'),
            ('lstat', '/usr/file', 'lstat'),
            ('readlink', '/usr/link', 'readlink'),
            ('scandir.open', '/usr', 'scandir.open'),
            ('scandir.iterate', '/usr', 'scandir.iterate'),
            ('scandir.close', '/usr', 'scandir.close')]:
            with self.subTest(op=op, path=path):
                b = Fake()
                b.faults[(op, path)] = PermissionError(errno.EACCES, 'fake denial')
                r = self.run_fake(b)
                t = r['terminal']
                self.assertEqual((t['operation'], t['path'], t['errno']), (expected, path, errno.EACCES))
                self.assertIsNone(t['filename'])
                self.assertIn('counts', t)

    def test_resolution_errors_and_filename_fields(self):
        b = Fake()
        b.nodes['/bin'] = meta(stat.S_IFLNK)
        b.links['/bin'] = '/usr/hidden'
        b.faults[('lstat', '/usr/hidden')] = PermissionError(errno.EACCES, 'fake', 'named', None, 'named2')
        t = self.run_fake(b)['terminal']
        self.assertEqual(t['operation'], 'resolve.lstat')
        self.assertEqual((t['filename'], t['filename2']), ('named', 'named2'))

    def test_alias_dedup(self):
        b = Fake()
        for p in ('/bin', '/lib', '/lib64'):
            b.nodes[p] = meta(stat.S_IFLNK)
            b.links[p] = '/usr'
        r = self.run_fake(b)
        self.assertEqual(r['roots'], ['/usr'])
        self.assertEqual(r['counts']['visited'], 3)

    def test_outside_root(self):
        b = Fake()
        b.nodes.update({'/bin': meta(stat.S_IFLNK), '/outside': meta(stat.S_IFDIR)})
        b.links['/bin'] = '/outside'
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'resolved_root_outside_scope')
        self.assertNotIn(('scandir.open', '/outside'), b.calls)

    def test_symlink_cycle(self):
        b = Fake()
        b.nodes['/bin'] = meta(stat.S_IFLNK)
        b.links['/bin'] = '/bin'
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'resolution_cycle')

    def test_mount_rejections(self):
        for target, reason in [('/usr', 'mount_at_or_below_root'),
                               ('/usr/sub', 'mount_at_or_below_root'),
                               ('/else\\040where', 'escaped_mount_target')]:
            with self.subTest(target=target):
                b = Fake()
                b.mounts = ('1 0 0:1 / %s rw - tmpfs none rw\n' % target).encode()
                self.assertEqual(self.run_fake(b)['terminal']['reason'], reason)
                self.assertFalse(any(op == 'scandir.open' for op, _ in b.calls))

    def test_mount_parse(self):
        b = Fake()
        b.mounts = b'bad line\n'
        self.assertEqual(self.run_fake(b)['terminal']['operation'], 'mountinfo.parse')

    def test_mount_input_boundary(self):
        for size in (c.MAX_BYTES, c.MAX_BYTES + 1):
            with self.subTest(size=size):
                b = Fake()
                b.mounts = b'x' * size
                r = self.run_fake(b)
                self.assertEqual(r['terminal']['reason'], 'mountinfo_input_limit_no_room_to_establish_eof')
                self.assertEqual(b.read_requested, c.MAX_BYTES)

    def test_discovery_boundary(self):
        with patch.object(c, 'MAX_ENTRIES', 3):
            self.assertEqual(self.run_fake()['terminal']['result'], 'completed')
        with patch.object(c, 'MAX_ENTRIES', 2):
            r = self.run_fake()
            self.assertEqual(r['terminal']['reason'], 'discovered_limit')
            self.assertEqual(r['counts'], {'discovered': 2, 'visited': 2})

    def test_visit_boundary_before_metadata(self):
        b = Fake()
        x = c.Collector(b)
        x.report['counts']['visited'] = c.MAX_ENTRIES
        with self.assertRaisesRegex(c.Stop, 'visited_limit'):
            x.visit('/usr')
        self.assertEqual(b.calls, [])

    def test_deadline_on_iterator_and_open_ownership(self):
        for operation in ('mountinfo.open', 'scandir.open', 'scandir.iterate'):
            with self.subTest(operation=operation):
                b = Fake()
                def hook(op, path):
                    if op == operation:
                        b.now = 60
                b.hook = hook
                self.assertEqual(self.run_fake(b)['terminal']['reason'], 'deadline')

    def test_deadline_not_reset(self):
        b = Fake()
        def hook(op, path):
            if op == 'mountinfo.open':
                b.now = 59
            if op == 'scandir.iterate':
                b.now = 60
        b.hook = hook
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'deadline')

    def test_unsupported_type(self):
        b = Fake()
        b.nodes['/usr/file'] = meta(stat.S_IFIFO)
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'unsupported_type')
        self.assertNotIn(('readlink', '/usr/link'), b.calls)

    def test_detected_directory_race(self):
        b = Fake()
        def hook(op, path):
            if op == 'scandir.iterate':
                b.nodes['/usr'] = meta(stat.S_IFLNK, 22)
        b.hook = hook
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'directory_race')
        self.assertNotIn(('lstat', '/usr/file'), b.calls)

    def test_primary_and_close_errors_separate(self):
        b = Fake()
        b.faults[('scandir.iterate', '/usr')] = PermissionError(errno.EACCES, 'first')
        b.faults[('scandir.close', '/usr')] = OSError(errno.EIO, 'close')
        r = self.run_fake(b)
        self.assertEqual(r['terminal']['operation'], 'scandir.iterate')
        self.assertEqual(r['close_errors'][0]['operation'], 'scandir.close')
        self.assertEqual(r['terminal']['errno'], errno.EACCES)

    def test_mount_primary_and_close(self):
        b = Fake()
        b.faults[('mountinfo.read', c.MOUNTINFO)] = PermissionError(errno.EACCES, 'first')
        b.faults[('mountinfo.close', c.MOUNTINFO)] = OSError(errno.EIO, 'close')
        r = self.run_fake(b)
        self.assertEqual(r['terminal']['operation'], 'mountinfo.read')
        self.assertEqual(len(r['close_errors']), 1)

    def test_nested_iterators_closed(self):
        b = Fake()
        b.nodes['/usr/sub'] = meta(stat.S_IFDIR, 4)
        b.children['/usr'] = ['sub']
        b.faults[('scandir.iterate', '/usr/sub')] = PermissionError(errno.EACCES, 'fake')
        self.run_fake(b)
        self.assertEqual([p for op, p in b.calls if op == 'scandir.close'], ['/usr/sub', '/usr'])

    def test_output_limit(self):
        r = self.run_fake()
        r['identity']['user'] = 'x' * c.MAX_BYTES
        out = c.encode(r)
        self.assertLessEqual(len(out), c.MAX_BYTES)
        self.assertEqual(json.loads(out)['terminal']['reason'], 'output_limit')

    def test_report_json_and_exact_output_boundary(self):
        r = self.run_fake()
        data = c.encode(r)
        self.assertEqual(json.loads(data), r)
        with patch.object(c, 'MAX_BYTES', len(data)):
            self.assertEqual(c.encode(r), data)
        with patch.object(c, 'MAX_BYTES', len(data) - 1):
            self.assertEqual(json.loads(c.encode(r))['terminal']['reason'], 'output_limit')

    def test_fixed_bounds(self):
        self.assertEqual((c.MAX_ENTRIES, c.MAX_BYTES, c.SECONDS), (250000, 1048576, 60))
        b = Fake()
        x = c.Collector(b)
        x.report['counts']['discovered'] = 249999
        x.admit('/usr/fake')
        with self.assertRaisesRegex(c.Stop, 'discovered_limit'):
            x.admit('/usr/next')

    def test_mount_just_below_limit(self):
        b = Fake()
        base = b.mounts.rstrip(b'\n')
        b.mounts = base + b' ' * (c.MAX_BYTES - 2 - len(base)) + b'\n'
        self.assertEqual(len(b.mounts), c.MAX_BYTES - 1)
        self.assertEqual(self.run_fake(b)['terminal']['result'], 'completed')

    def test_empty_mountinfo(self):
        b = Fake()
        b.mounts = b''
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'mountinfo_parse_empty')

    def test_resolution_readlink_denial(self):
        b = Fake()
        b.nodes['/bin'] = meta(stat.S_IFLNK)
        b.faults[('readlink', '/bin')] = PermissionError(errno.EACCES, 'fake')
        self.assertEqual(self.run_fake(b)['terminal']['operation'], 'resolve.readlink')

    def test_alias_to_exact_nonsymlink_candidate(self):
        b = Fake()
        b.nodes['/bin'] = meta(stat.S_IFDIR, 4)
        b.nodes['/lib'] = meta(stat.S_IFLNK, 5)
        b.links['/lib'] = '/bin'
        r = self.run_fake(b)
        self.assertEqual(r['roots'], ['/usr', '/bin'])
        self.assertEqual(r['terminal']['result'], 'completed')

    def test_root_race_after_mount_guard(self):
        b = Fake()
        def hook(op, path):
            if op == 'mountinfo.close':
                b.nodes['/usr'] = meta(stat.S_IFLNK, 23)
        b.hook = hook
        self.assertEqual(self.run_fake(b)['terminal']['reason'], 'root_race')
        self.assertNotIn(('scandir.open', '/usr'), b.calls)

    def test_optional_regular_excluded(self):
        b = Fake()
        b.nodes['/bin'] = meta(stat.S_IFREG)
        r = self.run_fake(b)
        self.assertEqual(r['selection'][1]['exclusion'], 'not_directory')
        self.assertEqual(r['terminal']['result'], 'completed')

    def test_main_inert_stdout(self):
        for fail in (False, True):
            with self.subTest(fail=fail):
                b = Fake()
                if fail:
                    b.ident['uid'] = 0
                output = NS(buffer=io.BytesIO())
                with patch.object(c, 'Native', return_value=b), patch.object(c.sys, 'stdout', output):
                    status = c.main()
                self.assertEqual(status, int(fail))
                self.assertIn('terminal', json.loads(output.buffer.getvalue()))

    def test_no_native_backend_in_tests(self):
        with patch.object(c.Native, 'lstat', side_effect=AssertionError('native forbidden')), \
             patch.object(c.Native, 'scandir', side_effect=AssertionError('native forbidden')), \
             patch.object(c.Native, 'mount_open', side_effect=AssertionError('native forbidden')):
            self.assertEqual(self.run_fake()['terminal']['result'], 'completed')


if __name__ == '__main__':
    unittest.main(verbosity=2)
