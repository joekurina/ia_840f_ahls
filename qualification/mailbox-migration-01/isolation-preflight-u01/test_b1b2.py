#!/usr/bin/env python3
"""Injected process topology only; NEVER forks or opens a real pidfd."""
from contextlib import ExitStack
import io
import json
from pathlib import Path
import signal
import time
import unittest
from unittest import mock
import preflight as p

BASE = Path(__file__).resolve().parent / 'regression-fixtures-b1b2-01'


def identity(pid, ppid, namespace='host', start='100'):
    return dict(pid=pid, ppid=ppid, namespace=namespace, starttime=start, state='S')


class Regressions(unittest.TestCase):
    def fixture(self):
        root = BASE / self._testMethodName
        root.mkdir()
        (root / 'observer').mkdir()
        return root

    def final(self):
        return dict(status='INCONCLUSIVE', authorization=False, ready_for_build=False,
                    vendor_run=False, attempts=[], error='primary fixture failure')

    def rejected_attempt(self, case):
        sup, parent, init = identity(100, 50), identity(200, 100), identity(300, 200, 'new')
        changed = dict(init, starttime='101')
        reads = {100: sup, 200: parent, 300: init}
        if case == 'unrelated':
            reads[200] = dict(parent, ppid=999)
        if case == 'reused':
            reads[300] = changed
        count = [0]
        def proc_identity(pid):
            if pid == 300:
                count[0] += 1
                if case == 'changed' and count[0] > 1:
                    return changed
                # candidate from info is stale, acquisition sees a replacement
                if case == 'reused' and count[0] == 1:
                    return init
            return reads[pid]
        def live(fd):
            return not (case == 'stale' and fd == 30)
        def ns(pid):
            if case == 'missing_nspid' and pid == 300:
                raise RuntimeError('missing NSpid')
            return ['200'] if pid == 200 else ['300', '2' if case == 'bad_nspid' else '1']
        receipts = p.Receipts()
        receipts.save = mock.Mock()
        with ExitStack() as stack:
            def patch(obj, attr, **kwargs):
                return stack.enter_context(mock.patch.object(obj, attr, **kwargs))
            patch(p.os, 'pipe', side_effect=[(1, 2), (3, 4), (5, 6)])
            fork = patch(p.os, 'fork', return_value=100)
            patch(p, 'argv', return_value=['inert-mock'])
            patch(p, 'verified_pidfd', return_value=(10, sup))
            patch(p, 'process_identity', side_effect=proc_identity)
            patch(p.os, 'pidfd_open', side_effect=lambda pid, flags: {200:20, 300:30}[pid])
            patch(p, 'alive', side_effect=live)
            patch(p, 'nspids', side_effect=ns)
            patch(p.os, 'readlink', return_value='host')
            patch(p.select, 'select', return_value=([1], [], []))
            patch(p.os, 'read', return_value=b'{"child-pid": 300}')
            patch(p.os, 'waitpid', return_value=(100, 9))
            close = patch(p.os, 'close')
            send = patch(p, 'send')
            kill = patch(p.os, 'kill')
            with self.assertRaises(RuntimeError):
                p.attempt('controls', {}, receipts, time.monotonic() + 20)
            fork.assert_called_once()
            self.assertEqual(send.call_args_list, [mock.call(10, signal.SIGKILL)])
            kill.assert_not_called()
            if case != 'unrelated':
                self.assertIn(mock.call(30), close.call_args_list)
                self.assertIn(mock.call(20), close.call_args_list)
            self.assertEqual(receipts.cleanup[0]['teardown'], 'UNKNOWN')
            self.assertTrue(receipts.cleanup[0]['supervisor_reaped'])

    def test_stale_pid_never_signaled_even_finally(self):
        self.rejected_attempt('stale')

    def test_reused_pid_never_signaled_even_finally(self):
        self.rejected_attempt('reused')

    def test_unrelated_namespace_init_never_signaled(self):
        self.rejected_attempt('unrelated')

    def test_changed_identity_never_signaled_even_finally(self):
        self.rejected_attempt('changed')

    def test_failed_nspid_never_signaled_even_finally(self):
        self.rejected_attempt('bad_nspid')

    def test_missing_nspid_never_signaled_even_finally(self):
        self.rejected_attempt('missing_nspid')

    def test_valid_chain_promoted_only_after_checks(self):
        ids = {100: identity(100, 50), 200: identity(200, 100), 300: identity(300, 200, 'new')}
        with mock.patch.object(p, 'process_identity', side_effect=ids.__getitem__), \
             mock.patch.object(p.os, 'pidfd_open', side_effect=[20, 30]), \
             mock.patch.object(p, 'alive', return_value=True), \
             mock.patch.object(p, 'nspids', side_effect=[['200'], ['300','1']]), \
             mock.patch.object(p.os, 'close') as close, mock.patch.object(p, 'send') as send:
            self.assertEqual(p.launch_init_pidfd(ids[300], 10, ids[100]), (30, ids[300]))
            close.assert_called_once_with(20)
            send.assert_not_called()

    def test_cleanup_signal_close_reap_and_scan_errors_independent(self):
        with mock.patch.object(p, 'send', side_effect=PermissionError('signal')) as send, \
             mock.patch.object(p.os, 'close', side_effect=OSError('close')) as close, \
             mock.patch.object(p.os, 'waitpid', side_effect=OSError('wait')) as wait, \
             mock.patch.object(p.select, 'select', side_effect=OSError('poll')), \
             mock.patch.object(p, 'namespace_members', side_effect=RuntimeError('scan')) as scan:
            r = p.cleanup_attempt(100, None, 10, 30, identity(300, 200, 'new'), [1,3,5])
            self.assertEqual(send.call_count, 2)
            self.assertEqual(close.call_count, 5)
            wait.assert_called_once_with(100, p.os.WNOHANG)
            scan.assert_called_once()
            self.assertEqual(r['teardown'], 'UNKNOWN')
            self.assertEqual(len(r['errors']), 10)

    def test_cleanup_confirmed_requires_exit_and_empty_namespace(self):
        with mock.patch.object(p, 'send'), mock.patch.object(p.os, 'close'), \
             mock.patch.object(p.os, 'waitpid', return_value=(100,9)), \
             mock.patch.object(p.select, 'select', return_value=([30],[],[])), \
             mock.patch.object(p, 'namespace_members', return_value=[]):
            r = p.cleanup_attempt(100, None, 10, 30, identity(300,200,'new'), [])
            self.assertEqual(r['teardown'], 'CONFIRMED')

    def test_cleanup_unreaped_is_bounded_unknown(self):
        with mock.patch.object(p, 'send'), mock.patch.object(p.os, 'close') as close, \
             mock.patch.object(p.os, 'waitpid', return_value=(0,0)) as wait, \
             mock.patch.object(p.time, 'monotonic', side_effect=[0,1,3]), \
             mock.patch.object(p.time, 'sleep'):
            r = p.cleanup_attempt(100, None, 10, None, None, [1,3,5])
            wait.assert_called_once_with(100, p.os.WNOHANG)
            self.assertEqual(close.call_count, 4)
            self.assertEqual(r['teardown'], 'UNKNOWN')

    def test_no_supervisor_fd_stops_only_owned_unreaped_child(self):
        with mock.patch.object(p.os, 'kill') as kill, mock.patch.object(p.os, 'close'), \
             mock.patch.object(p.os, 'waitpid', return_value=(100,9)):
            p.cleanup_attempt(100, None, None, None, None, [])
            kill.assert_called_once_with(100, signal.SIGKILL)

    def test_terminal_reserve_survives_cap(self):
        root = self.fixture()
        with mock.patch.object(p, 'ROOT', root), mock.patch.object(p, 'MAX_OUTPUT', p.TERMINAL_RESERVE + 1024):
            r = p.Receipts()
            raw = json.dumps('x'*1021, sort_keys=True, indent=2).encode() + b'\n'
            self.assertEqual(len(raw), 1024)
            r.save('fill.json', 'x'*1021)
            with self.assertRaisesRegex(RuntimeError, 'cap'):
                r.save('over.json', {})
            self.assertTrue(r.finish(self.final()))
            self.assertLessEqual(sum(x.stat().st_size for x in (root/'observer').iterdir()), p.MAX_OUTPUT)
            self.assertEqual(json.loads((root/'observer/final.json').read_text())['status'], 'INCONCLUSIVE')

    def test_oversized_terminal_detail_compacted(self):
        root = self.fixture()
        with mock.patch.object(p, 'ROOT', root):
            r = p.Receipts()
            r.cleanup = [{'errors': ['x'*p.MAX_OUTPUT], 'teardown':'UNKNOWN'}]
            self.assertTrue(r.finish(self.final()))
            data = json.loads((root/'observer/final.json').read_text())
            self.assertIn('detail_omitted', data)
            self.assertLess((root/'observer/final.json').stat().st_size, p.TERMINAL_RESERVE)

    def test_terminal_write_failure_truthful_postclaim(self):
        r = p.Receipts()
        output = io.StringIO()
        with mock.patch('builtins.open', side_effect=OSError('filesystem unavailable')), \
             mock.patch.object(p.sys, 'stderr', output):
            self.assertFalse(r.finish(self.final()))
        data = json.loads(output.getvalue())
        self.assertEqual(data['status'], 'INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE')
        self.assertEqual(data['retained_root'], str(p.ROOT))
        self.assertEqual(data['primary_error'], 'primary fixture failure')
        self.assertEqual(data['final_receipt'], 'missing_or_partial')

    def test_launch_receipt_failure_closes_all_without_fork(self):
        r = p.Receipts()
        r.save = mock.Mock(side_effect=OSError('write failure'))
        with mock.patch.object(p.os, 'pipe', side_effect=[(1,2),(3,4),(5,6)]), \
             mock.patch.object(p, 'argv', return_value=['inert-mock']), \
             mock.patch.object(p.os, 'close') as close, mock.patch.object(p.os, 'fork') as fork:
            with self.assertRaisesRegex(OSError, 'write failure'):
                p.attempt('controls', {}, r, time.monotonic()+20)
            fork.assert_not_called()
            self.assertEqual(close.call_count, 6)
            self.assertEqual(r.cleanup[0]['teardown'], 'NO_LAUNCH')

    def test_cap_after_launch_still_stops_closes_reaps_and_finishes(self):
        root = self.fixture()
        r = p.Receipts()
        with mock.patch.object(p, 'ROOT', root), \
             mock.patch.object(p.os, 'pipe', side_effect=[(1,2),(3,4),(5,6)]), \
             mock.patch.object(p, 'argv', return_value=['inert-mock']), \
             mock.patch.object(p.os, 'fork', return_value=100), \
             mock.patch.object(p, 'verified_pidfd', return_value=(10, identity(100,50))), \
             mock.patch.object(p.select, 'select', return_value=([1],[],[])), \
             mock.patch.object(p.os, 'read', return_value=b'x'*1048576), \
             mock.patch.object(p, 'send', side_effect=PermissionError('stop denied')) as send, \
             mock.patch.object(p.os, 'waitpid', return_value=(100,9)) as wait, \
             mock.patch.object(p.os, 'close') as close:
            with self.assertRaisesRegex(RuntimeError, 'pipe receipt cap'):
                p.attempt('controls', {}, r, time.monotonic()+20)
            send.assert_called_once_with(10, signal.SIGKILL)
            wait.assert_called_once_with(100, p.os.WNOHANG)
            self.assertEqual(close.call_count, 7)
            self.assertEqual(r.cleanup[0]['teardown'], 'UNKNOWN')
            self.assertIn('stop denied', r.cleanup[0]['errors'][0])
            self.assertTrue(r.finish(self.final()))
            self.assertTrue((root/'observer/final.json').exists())

    def test_rejected_close_errors_preserve_primary_and_never_signal(self):
        with mock.patch.object(p, 'alive', return_value=True), \
             mock.patch.object(p, 'process_identity', side_effect=[identity(200,100), identity(300,200,'changed')]), \
             mock.patch.object(p.os, 'pidfd_open', side_effect=[20,30]), \
             mock.patch.object(p.os, 'close', side_effect=OSError('close denied')) as close, \
             mock.patch.object(p, 'send') as send:
            with self.assertRaisesRegex(RuntimeError, 'candidate identity race') as caught:
                p.launch_init_pidfd(identity(300,200,'new'),10,identity(100,50))
            self.assertEqual(len(caught.exception.untrusted_close_errors),2)
            self.assertEqual(close.call_args_list,[mock.call(20),mock.call(30)])
            send.assert_not_called()

    def test_acquisition_failure_closes_ancestor_without_signal(self):
        with mock.patch.object(p, 'alive', return_value=True), \
             mock.patch.object(p, 'process_identity', return_value=identity(200,100)), \
             mock.patch.object(p.os, 'pidfd_open', side_effect=[20, ProcessLookupError('stale')]), \
             mock.patch.object(p.os, 'close') as close, mock.patch.object(p, 'send') as send:
            with self.assertRaises(ProcessLookupError):
                p.launch_init_pidfd(identity(300,200,'new'),10,identity(100,50))
            close.assert_called_once_with(20)
            send.assert_not_called()

    def test_pipe_receipt_failure_cannot_skip_cleanup_or_mask_primary(self):
        r = p.Receipts()
        r.save = mock.Mock(side_effect=[None, OSError('pipes write failure')])
        with mock.patch.object(p.os, 'pipe', side_effect=[(1,2),(3,4),(5,6)]), \
             mock.patch.object(p, 'argv', return_value=['inert-mock']), \
             mock.patch.object(p.os, 'fork', return_value=100), \
             mock.patch.object(p, 'verified_pidfd', side_effect=RuntimeError('primary identity failure')), \
             mock.patch.object(p.os, 'kill') as kill, \
             mock.patch.object(p.os, 'waitpid', return_value=(100,9)) as wait, \
             mock.patch.object(p.os, 'close') as close:
            with self.assertRaisesRegex(RuntimeError, 'primary identity failure'):
                p.attempt('controls', {}, r, time.monotonic()+20)
            self.assertEqual(close.call_count, 6)
            kill.assert_called_once_with(100, signal.SIGKILL)
            wait.assert_called_once()
            self.assertIn('pipes write failure', r.cleanup[0]['errors'][0])
            self.assertTrue(r.cleanup[0]['supervisor_reaped'])


if __name__ == '__main__':
    p.os.umask(0o077)
    BASE.mkdir()
    unittest.main(verbosity=2)
