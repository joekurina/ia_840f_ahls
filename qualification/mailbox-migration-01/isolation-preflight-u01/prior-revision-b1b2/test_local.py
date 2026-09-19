#!/usr/bin/env python3
"""Local inert fixtures only: no bwrap, tmux, SSH or namespace launch."""
import ast
import errno
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import time
import unittest
from unittest import mock

import preflight as p
import probe

BASE = Path(__file__).resolve().parent / 'local-fixtures-01'


class Tests(unittest.TestCase):
    def fixture(self):
        root = BASE / self._testMethodName
        root.mkdir()
        return root

    def test_claim_collision_retained(self):
        root = self.fixture() / 'claim'
        p.claim(root)
        with self.assertRaises(FileExistsError):
            p.claim(root)
        self.assertEqual(sorted(x.name for x in root.iterdir()), ['observer', 'protected', 'rw'])

    def test_no_symlink_ancestor(self):
        root = self.fixture()
        (root / 'target').mkdir()
        (root / 'alias').symlink_to(root / 'target')
        with self.assertRaisesRegex(RuntimeError, 'symlink ancestor'):
            p.claim(root / 'alias' / 'claim')
        self.assertFalse((root / 'target' / 'claim').exists())

    def test_readonly_errno_classifier(self):
        for value in (errno.EROFS, errno.EACCES, errno.EPERM, errno.ENOENT):
            def fail():
                raise OSError(value, 'fixture')
            self.assertEqual(probe.denied('fixture', fail)['errno'], value)
        with self.assertRaisesRegex(RuntimeError, 'unexpectedly succeeded'):
            probe.denied('fixture', lambda: None)
        with self.assertRaisesRegex(RuntimeError, 'unexpected errno'):
            probe.denied('fixture', mock.Mock(side_effect=OSError(errno.EIO, 'fixture')))

    def test_fixture_rw_and_mapping(self):
        root = self.fixture()
        probe.write_file(root / 'file')
        probe.shared_mapping(root / 'file')
        self.assertTrue((root / 'file').read_bytes().startswith(b'X'))
        # This is deliberately a writable local fixture, NOT a readonly-mount test.

    def test_inventory_rejects_fifo(self):
        root = self.fixture()
        os.mkfifo(root / 'fifo')
        with self.assertRaisesRegex(RuntimeError, 'endpoint/device'):
            p.runtime_inventory([str(root)], time.monotonic() + 2)

    def test_inventory_finite_and_drift(self):
        root = self.fixture()
        (root / 'file').write_text('one')
        a = p.runtime_inventory([str(root)], time.monotonic() + 2)
        (root / 'file').write_text('different')
        self.assertNotEqual(a, p.runtime_inventory([str(root)], time.monotonic() + 2))
        with mock.patch.object(p, 'MAX_ENTRIES', 1):
            with self.assertRaisesRegex(RuntimeError, 'entry cap'):
                p.runtime_inventory([str(root)], time.monotonic() + 2)
        with self.assertRaisesRegex(RuntimeError, 'deadline'):
            p.runtime_inventory([str(root)], time.monotonic() - 1)

    def test_fixed_argv(self):
        a = p.argv('lifecycle', {}, 99)
        self.assertEqual(a[0], '/usr/bin/bwrap')
        self.assertEqual(a[a.index('--') + 1:], ['/usr/bin/python3','-I','-B','-S','/probe.py','lifecycle'])
        for option in ('--unshare-user','--unshare-pid','--unshare-net','--unshare-ipc','--die-with-parent','--new-session','--remount-ro'):
            self.assertIn(option, a)
        self.assertNotIn('--unshare-uts', a)
        self.assertNotIn('--share-net', a)
        self.assertNotIn('/opt', a)
        self.assertNotIn('--ro-bind / /', ' '.join(a))
        for reserved in p.RESERVED:
            self.assertNotIn(reserved, a)

    def test_claim_path_exact(self):
        proposal = json.loads((p.HERE.parent / 'isolation-preflight-proposal.json').read_text())
        self.assertEqual(str(p.ROOT), proposal['paths']['exclusive_preflight_root'])
        self.assertEqual(p.RESERVED[0], proposal['paths']['reserved_vendor_scratch_do_not_create'])
        self.assertEqual(p.RESERVED[1], proposal['paths']['reserved_actual_observation_do_not_claim'])

    def test_observed_tools_exact(self):
        actual = json.loads((p.HERE.parent / 'isolation-availability-live01.json').read_text())
        self.assertEqual(json.loads((p.HERE / 'tools.json').read_text()), actual['tools'])

    def test_hash_mismatch_stops_before_exec(self):
        expected = {'python3': {'path': '/usr/bin/python3', 'realpath': '/different', 'sha256': '0' * 64}}
        with self.assertRaisesRegex(RuntimeError, 'realpath mismatch'):
            p.tool_identities(expected)

    def test_pidfd_only_own_inert_child(self):
        proc = subprocess.Popen([sys.executable, '-I', '-B', '-S', '-c', 'import time; time.sleep(3)'],
                                stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        fd = None
        try:
            fd, identity = p.verified_pidfd(proc.pid)
            self.assertEqual(identity['pid'], proc.pid)
            p.send(fd, signal.SIGTERM)
            proc.communicate(timeout=2)
            self.assertEqual(proc.returncode, -signal.SIGTERM)
        finally:
            if fd is not None:
                os.close(fd)
            if proc.poll() is None:
                proc.kill(); proc.communicate(timeout=2)

    def test_receipts_exclusive_and_capped(self):
        root = self.fixture()
        (root / 'observer').mkdir()
        with mock.patch.object(p, 'ROOT', root):
            r = p.Receipts()
            r.save('first.json', {'fixture': True})
            with self.assertRaises(FileExistsError):
                r.save('first.json', {'fixture': False})
            with mock.patch.object(p, 'MAX_OUTPUT', r.used):
                with self.assertRaisesRegex(RuntimeError, 'cap'):
                    r.save('over.json', {'fixture': True})
            self.assertFalse((root / 'observer/over.json').exists())

    def test_python39_syntax(self):
        for name in ('preflight.py','probe.py','test_local.py'):
            ast.parse((p.HERE / name).read_text(), feature_version=(3, 9))

    def test_no_vendor_launcher_strings(self):
        text = (p.HERE / 'preflight.py').read_text() + (p.HERE / 'probe.py').read_text()
        for banned in ('qsys-script', 'qsys-generate', 'quartus_sh', 'lmutil', 'sudo ', 'ssh '):
            self.assertNotIn(banned, text)
        self.assertIn("'authorization': False", text)
        self.assertIn("'ready_for_build': False", text)
        self.assertNotIn('PREFLIGHT_CONTROLS_PASS_LICENSE_AND_VENDOR_UNTESTED', text)


if __name__ == '__main__':
    os.umask(0o077)
    BASE.mkdir()  # exclusive retained test evidence; no automatic cleanup/reuse
    unittest.main(verbosity=2)
