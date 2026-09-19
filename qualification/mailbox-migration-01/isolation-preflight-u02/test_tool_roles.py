#!/usr/bin/env python3
"""Inert synthetic tool identities; never execute or modify installed tools."""
import copy
import errno
import stat
import unittest
from contextlib import ExitStack
from types import SimpleNamespace
from unittest import mock

import preflight as p
import probe

EXECUTED = {'python3', 'bwrap', 'tmux'}
INVENTORY = {'unshare', 'mount', 'setpriv', 'strace'}


class ToolRoles(unittest.TestCase):
    def setUp(self):
        self.expected = {n: {'path': '/usr/bin/' + n,
                             'realpath': '/usr/bin/' + n,
                             'sha256': 'a' * 64}
                         for n in sorted(EXECUTED | INVENTORY)}
        self.modes = {n: stat.S_IFREG | 0o755 for n in self.expected}
        self.caps = {n: b'' for n in self.expected}
        self.sizes = {n: 1 for n in self.expected}
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        # Isolate OS mocks from unittest/traceback and the rest of Python.
        self.stack.enter_context(mock.patch.object(p, 'os', mock.Mock(wraps=p.os)))
        self.realpath = self.stack.enter_context(mock.patch.object(
            p.os.path, 'realpath', side_effect=lambda path:
            '/usr/bin/python3' if path == '/proc/self/exe' else path))
        self.stat = self.stack.enter_context(mock.patch.object(
            p.os, 'stat', side_effect=lambda path: SimpleNamespace(
                st_mode=self.modes[path.rsplit('/', 1)[-1]],
                st_size=self.sizes[path.rsplit('/', 1)[-1]])))
        def getxattr(path, key):
            self.assertEqual(key, 'security.capability')
            data = self.caps[path.rsplit('/', 1)[-1]]
            if isinstance(data, Exception):
                raise data
            return data
        self.xattr = self.stack.enter_context(mock.patch.object(p.os, 'getxattr', side_effect=getxattr))
        self.digest = self.stack.enter_context(mock.patch.object(p, 'digest', return_value='a' * 64))
        self.run = self.stack.enter_context(mock.patch.object(p.subprocess, 'run', side_effect=AssertionError('no execution')))
        self.popen = self.stack.enter_context(mock.patch.object(p.subprocess, 'Popen', side_effect=AssertionError('no execution')))

    def test_closed_roles_and_universal_identity_calls(self):
        result = p.tool_identities(self.expected)
        self.assertEqual(set(result), EXECUTED | INVENTORY)
        for name, item in result.items():
            self.assertEqual(item['role'], 'EXECUTED' if name in EXECUTED else 'INVENTORY_ONLY')
            self.assertEqual(item['mode'], self.modes[name])
            self.assertEqual(item['capabilities'], '')
            self.assertEqual(item['sha256'], 'a' * 64)
        calls = [mock.call('/usr/bin/' + n) for n in sorted(self.expected)]
        self.assertEqual(self.digest.call_args_list, calls)
        self.assertEqual(self.stat.call_args_list, calls)
        self.assertEqual(self.xattr.call_args_list,
                         [mock.call('/usr/bin/' + n, 'security.capability') for n in sorted(self.expected)])
        self.run.assert_not_called()
        self.popen.assert_not_called()

    def test_inventory_privilege_metadata_retained_not_normalized(self):
        for n in INVENTORY:
            self.modes[n] |= stat.S_ISUID | stat.S_ISGID
            self.caps[n] = b'\x00\x01\xff'
        self.modes['mount'] = 0o104755
        result = p.tool_identities(self.expected)
        self.assertEqual(result['mount']['mode'], 0o104755)
        for n in INVENTORY:
            self.assertEqual(result[n]['mode'], self.modes[n])
            self.assertEqual(result[n]['capabilities'], '0001ff')
            self.assertEqual(result[n]['role'], 'INVENTORY_ONLY')
            self.assertIn(mock.call('/usr/bin/' + n), self.digest.call_args_list)
        self.run.assert_not_called()
        self.popen.assert_not_called()

    def test_each_executed_setuid_setgid_and_capabilities_refuse(self):
        for n in sorted(EXECUTED):
            for bit in (stat.S_ISUID, stat.S_ISGID):
                with self.subTest(name=n, bit=bit):
                    self.modes[n] |= bit
                    with self.assertRaisesRegex(RuntimeError, 'privileged executed tool'):
                        p.tool_identities(self.expected)
                    self.modes[n] &= ~bit
            with self.subTest(name=n, capabilities=True):
                self.caps[n] = b'\x00'
                with self.assertRaisesRegex(RuntimeError, 'file capabilities present'):
                    p.tool_identities(self.expected)
                self.caps[n] = b''

    def test_role_override_is_not_authority(self):
        self.expected['bwrap']['role'] = 'INVENTORY_ONLY'
        self.expected['mount']['role'] = 'EXECUTED'
        result = p.tool_identities(self.expected)
        self.assertEqual(result['bwrap']['role'], 'EXECUTED')
        self.assertEqual(result['mount']['role'], 'INVENTORY_ONLY')
        self.modes['bwrap'] |= stat.S_ISUID
        with self.assertRaisesRegex(RuntimeError, 'privileged executed tool'):
            p.tool_identities(self.expected)

    def test_each_missing_name_and_unknown_name_refuse_before_identity(self):
        for n in sorted(self.expected):
            with self.subTest(missing=n):
                altered = copy.deepcopy(self.expected)
                del altered[n]
                with self.assertRaisesRegex(RuntimeError, 'exact tool role union'):
                    p.tool_identities(altered)
        altered = dict(self.expected, mystery=self.expected['mount'])
        with self.assertRaisesRegex(RuntimeError, 'exact tool role union'):
            p.tool_identities(altered)
        self.stat.assert_not_called()
        self.xattr.assert_not_called()
        self.digest.assert_not_called()

    def test_role_overlap_refuses(self):
        with mock.patch.object(p, 'INVENTORY_ONLY_TOOLS', frozenset(INVENTORY | {'python3'})):
            with self.assertRaisesRegex(RuntimeError, 'tool role overlap'):
                p.tool_identities(self.expected)

    def test_nonregular_each_role_refuses(self):
        for n in sorted(self.expected):
            for kind in (stat.S_IFDIR, stat.S_IFIFO, stat.S_IFSOCK, stat.S_IFCHR):
                with self.subTest(name=n, kind=kind):
                    self.modes[n] = kind | 0o755
                    with self.assertRaisesRegex(RuntimeError, 'nonregular tool'):
                        p.tool_identities(self.expected)
                    self.modes[n] = stat.S_IFREG | 0o755

    def test_hash_mismatch_each_entry_including_privileged_mount(self):
        self.modes['mount'] = 0o104755
        for n in sorted(self.expected):
            with self.subTest(name=n):
                altered = copy.deepcopy(self.expected)
                altered[n]['sha256'] = 'b' * 64
                with self.assertRaisesRegex(RuntimeError, 'tool hash mismatch: ' + n):
                    p.tool_identities(altered)

    def test_realpath_mismatch_each_entry(self):
        for n in sorted(self.expected):
            with self.subTest(name=n):
                altered = copy.deepcopy(self.expected)
                altered[n]['realpath'] = '/other/' + n
                with self.assertRaisesRegex(RuntimeError, 'realpath mismatch: ' + n):
                    p.tool_identities(altered)

    def test_location_each_entry_refuses(self):
        for n in sorted(self.expected):
            with self.subTest(name=n):
                altered = copy.deepcopy(self.expected)
                altered[n]['path'] = '/bin/' + n
                with self.assertRaisesRegex(RuntimeError, 'unexpected tool location'):
                    p.tool_identities(altered)

    def test_capability_detection_only_enodata_is_absence(self):
        for n in self.caps:
            self.caps[n] = OSError(errno.ENODATA, 'absent')
        self.assertTrue(all(x['capabilities'] == '' for x in p.tool_identities(self.expected).values()))
        for n in sorted(self.expected):
            for error in (errno.EACCES, errno.EPERM, errno.ENOTSUP, errno.EIO, errno.ENOENT):
                with self.subTest(name=n, errno=error):
                    self.caps[n] = OSError(error, 'unreadable or unsupported')
                    with self.assertRaisesRegex(RuntimeError, 'capability detection unsupported'):
                        p.tool_identities(self.expected)
            self.caps[n] = b''

    def test_cumulative_hash_cap_includes_inventory(self):
        self.sizes['mount'] = 4
        with mock.patch.object(p, 'MAX_HASH', 4):
            with self.assertRaisesRegex(RuntimeError, 'identity hash cap'):
                p.tool_identities(self.expected)
        self.assertNotIn(mock.call('/usr/bin/mount'), self.digest.call_args_list)

    def test_wrong_interpreter_refuses(self):
        self.realpath.side_effect = lambda path: '/wrong/python' if path == '/proc/self/exe' else path
        with self.assertRaisesRegex(RuntimeError, 'wrong interpreter'):
            p.tool_identities(self.expected)

    def test_stat_and_hash_read_failures_propagate(self):
        for n in sorted(self.expected):
            with self.subTest(name=n):
                def stat_failure(path):
                    if path == '/usr/bin/' + n:
                        raise PermissionError('stat denied')
                    return SimpleNamespace(st_mode=0o100755, st_size=1)
                self.stat.side_effect = stat_failure
                with self.assertRaisesRegex(PermissionError, 'stat denied'):
                    p.tool_identities(self.expected)
                self.stat.side_effect = None
                self.stat.return_value = SimpleNamespace(st_mode=0o100755, st_size=1)
                def digest_failure(path):
                    if path == '/usr/bin/' + n:
                        raise PermissionError('hash denied')
                    return 'a' * 64
                self.digest.side_effect = digest_failure
                with self.assertRaisesRegex(PermissionError, 'hash denied'):
                    p.tool_identities(self.expected)
                self.digest.side_effect = None


class BaselinePreservation(unittest.TestCase):
    def test_nonewprivs_and_every_capability_set_required(self):
        keys = ('CapInh', 'CapPrm', 'CapEff', 'CapBnd', 'CapAmb')
        status = {'NoNewPrivs': '1', **{k: '00000000' for k in keys}}
        def read(path):
            if path == '/proc/self/status':
                return '\n'.join(k + ':\t' + v for k, v in status.items())
            return ''
        with mock.patch.object(probe.os, 'listdir', side_effect=lambda path:
                               ['0', '1', '2'] if path == '/proc/self/fd' else ['null', 'zero', 'random', 'urandom']), \
             mock.patch.object(probe.os, 'readlink', side_effect=lambda path:
                               '/dev/null' if path.endswith('/fd/0') else 'pipe:[mock]'), \
             mock.patch.object(probe, 'read', side_effect=read), \
             mock.patch.object(probe, 'identity', return_value={}):
            self.assertEqual(probe.baseline()['status'], status)
            for key in ('NoNewPrivs',) + keys:
                with self.subTest(field=key):
                    old = status[key]
                    status[key] = '0' if key == 'NoNewPrivs' else '00000001'
                    with self.assertRaises(AssertionError):
                        probe.baseline()
                    status[key] = old


if __name__ == '__main__':
    unittest.main(verbosity=2)
