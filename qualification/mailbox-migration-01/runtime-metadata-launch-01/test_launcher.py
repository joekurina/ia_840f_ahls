"""Local-only inert children. NEVER call attest/main or execute collector bytes."""
import base64
import errno
import json
import os
import signal
import unittest
from unittest.mock import patch
import launcher as L

GOOD = b'print(\'{"authorization":false,"ready_for_build":false,"vendor_run":false,"terminal":{"result":"completed"}}\')\n'


class LauncherTests(unittest.TestCase):
    def inert(self, data, **changes):
        self.assertNotEqual(L.digest(data), L.COLLECTOR_SHA)
        with patch.multiple(L, COLLECTOR_LENGTH=len(data),
                            COLLECTOR_SHA=L.digest(data), **changes):
            return L.run_child(data)

    def raw(self, report, channel):
        item = report[channel]
        data = base64.b64decode(item['base64'], validate=True)
        self.assertEqual(len(data), item['length'])
        self.assertEqual(L.digest(data), item['sha256'])
        self.assertLessEqual(len(data), L.CAP)
        return data

    def test_transport_unpack_only_never_execute(self):
        import transport
        data = transport.unpack()
        self.assertEqual(L.digest(data), transport.SHA256)
        self.assertEqual(len(data), transport.LENGTH)
        with patch.object(transport, 'LENGTH', 0):
            with self.assertRaisesRegex(RuntimeError, 'transport_binding'):
                transport.unpack()
        with patch.object(transport, 'SHA256', '0' * 64):
            with self.assertRaisesRegex(RuntimeError, 'transport_binding'):
                transport.unpack()

    def test_embedded_source_binding_without_execution(self):
        data = L.source()
        self.assertEqual(len(data), 13851)
        self.assertEqual(L.digest(data), '6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897')

    def test_mutated_source_refuses_before_fork(self):
        with patch.object(L.os, 'fork') as fork:
            with self.assertRaisesRegex(RuntimeError, 'collector_binding'):
                L.run_child(b'pass\n')
            fork.assert_not_called()
        with patch.object(L, 'COLLECTOR_LENGTH', 0):
            with self.assertRaisesRegex(RuntimeError, 'collector_binding'):
                L.source()

    def test_missing_pidfd_before_child(self):
        with patch.object(L.os, 'pidfd_open', None), patch.object(L.os, 'fork') as fork:
            with self.assertRaisesRegex(RuntimeError, 'pidfd_API'):
                L.pidfd_preflight()
            fork.assert_not_called()

    def test_kernel_refusal_before_child(self):
        with patch.object(L.os, 'pidfd_open', side_effect=OSError(errno.ENOSYS, 'inert')), patch.object(L.os, 'fork') as fork:
            with self.assertRaises(OSError):
                self.inert(GOOD)
            fork.assert_not_called()

    def test_exact_deadlines(self):
        self.assertEqual(L.due(64.999, False, False), [])
        self.assertEqual(L.due(65, False, False), [signal.SIGTERM])
        self.assertEqual(L.due(69.999, True, False), [])
        self.assertEqual(L.due(70, True, False), [signal.SIGKILL])
        self.assertEqual(L.due(75, False, False), [signal.SIGTERM, signal.SIGKILL])
        self.assertEqual(L.due(75, True, True), [])

    def test_completed_inert_child_and_fixed_flags(self):
        data = b'import sys\nassert sys.flags.isolated and sys.flags.no_site and sys.dont_write_bytecode\n' + GOOD
        result = self.inert(data)
        self.assertEqual(result['terminal'], 'completed')
        self.assertTrue(result['reaped'])
        self.assertEqual(result['errors'], [])
        self.assertEqual(self.raw(result, 'stderr'), b'')
        self.assertEqual(json.loads(self.raw(result, 'stdout'))['terminal']['result'], 'completed')

    def test_nonzero_and_partial_channels(self):
        result = self.inert(b'import os\nos.write(1,b"partial")\nos.write(2,b"error")\nraise SystemExit(3)\n')
        self.assertEqual(result['terminal'], 'INCOMPLETE')
        self.assertEqual(self.raw(result, 'stdout'), b'partial')
        self.assertEqual(self.raw(result, 'stderr'), b'error')
        self.assertEqual(os.waitstatus_to_exitcode(result['wait_status']), 3)

    def test_bad_json_incomplete(self):
        for data in (b'pass\n', b'print("not-json")\n', b'print("[]")\n', b'print(\'{"terminal":null}\')\n'):
            with self.subTest(data=data):
                self.assertEqual(self.inert(data)['terminal'], 'INCOMPLETE')

    def test_both_output_channels_larger_than_pipe(self):
        result = self.inert(b'import os\nfor i in range(32):\n os.write(1,b"x"*8192)\n os.write(2,b"y"*8192)\n')
        self.assertEqual(len(self.raw(result, 'stdout')), 262144)
        self.assertEqual(len(self.raw(result, 'stderr')), 262144)
        self.assertTrue(result['reaped'])

    def test_output_cap_each_channel(self):
        for channel in (1, 2):
            with self.subTest(channel=channel):
                result = self.inert(('import os\nos.write(%d,b"x"*1048577)\n' % channel).encode())
                name = 'stdout' if channel == 1 else 'stderr'
                self.assertEqual(len(self.raw(result, name)), L.CAP)
                self.assertIn('output_limit_' + name, ' '.join(result['errors']))
                self.assertEqual(result['terminal'], 'INCOMPLETE')
                self.assertTrue(result['reaped'])

    def test_term_then_kill_only_owned_pidfd(self):
        data = b'import os,signal,time\nsignal.signal(signal.SIGTERM,signal.SIG_IGN)\nos.write(1,b"before-timeout")\ntime.sleep(30)\n'
        actual = signal.pidfd_send_signal
        signals = []
        def record(fd, sig, info, flags):
            signals.append((fd, sig))
            return actual(fd, sig, info, flags)
        with patch.object(L.signal, 'pidfd_send_signal', side_effect=record):
            result = self.inert(data, TERM_AT=0.3, KILL_AT=0.5)
        nonzero = [(fd, sig) for fd, sig in signals if sig]
        self.assertEqual([sig for fd, sig in nonzero], [signal.SIGTERM, signal.SIGKILL])
        self.assertEqual(nonzero[0][0], nonzero[1][0])
        self.assertEqual(self.raw(result, 'stdout'), b'before-timeout')
        self.assertTrue(result['timed_out'])
        self.assertEqual(result['terminal'], 'INCOMPLETE')
        self.assertEqual(os.waitstatus_to_exitcode(result['wait_status']), -signal.SIGKILL)

    def test_term_exit_no_kill(self):
        result = self.inert(b'import time\ntime.sleep(30)\n', TERM_AT=0.2, KILL_AT=0.4)
        self.assertTrue(result['timed_out'])
        self.assertEqual(os.waitstatus_to_exitcode(result['wait_status']), -signal.SIGTERM)

    def test_acquisition_failure_gates_child(self):
        real = os.pidfd_open
        def acquire(pid, flags):
            if pid == os.getpid():
                return real(pid, flags)
            raise OSError(errno.EMFILE, 'inert acquisition refusal')
        with patch.object(L.os, 'pidfd_open', side_effect=acquire):
            result = self.inert(b'raise SystemExit(99)\n')
        self.assertEqual(os.waitstatus_to_exitcode(result['wait_status']), 125)
        self.assertTrue(result['reaped'])
        self.assertEqual(result['terminal'], 'INCOMPLETE')

    def test_setup_refusal_gate_close_error_still_cleans_up_fake_only(self):
        from contextlib import ExitStack
        # All descriptors and the direct child are fake; no fork or syscall.
        for refusal in ('acquisition', 'probe'):
            with self.subTest(refusal=refusal), ExitStack() as stack:
                events = []
                primary = OSError('inert ' + refusal + ' refusal')
                gate_error = OSError('inert gate close failure')

                def close(fd):
                    events.append(('close', fd))
                    if fd == 107:
                        raise gate_error

                def send(fd, sig, info, flags):
                    events.append(('signal', fd, sig))
                    if sig == 0:
                        raise primary

                def wait(pid, flags):
                    events.append(('wait', pid, flags))
                    return pid, 0

                stack.enter_context(patch.object(L, 'pidfd_preflight'))
                stack.enter_context(patch.object(L.os, 'pipe2', side_effect=[
                    (100, 101), (102, 103), (104, 105), (106, 107)]))
                stack.enter_context(patch.object(L.os, 'fork', return_value=4242))
                acquire = stack.enter_context(patch.object(L.os, 'pidfd_open',
                    side_effect=primary if refusal == 'acquisition' else None,
                    return_value=108))
                stack.enter_context(patch.object(L.os, 'close', side_effect=close))
                stack.enter_context(patch.object(L.signal, 'pidfd_send_signal', side_effect=send))
                stack.enter_context(patch.object(L.os, 'waitpid', side_effect=wait))
                stack.enter_context(patch.object(L.os, 'set_blocking'))
                read = stack.enter_context(patch.object(L.os, 'read', return_value=b''))
                write = stack.enter_context(patch.object(L.os, 'write'))
                kill = stack.enter_context(patch.object(L.os, 'kill'))
                result = self.inert(GOOD)
                acquire.assert_called_once_with(4242, 0)
                write.assert_not_called()  # Gate never released.
                kill.assert_not_called()   # No numeric signal fallback.
                self.assertEqual(result['terminal'], 'INCOMPLETE')
                self.assertTrue(result['reaped'])
                self.assertEqual(result['errors'], [
                    'OSError:' + str(primary), 'gate_close:OSError:' + str(gate_error)])
                for flag in ('authorization', 'ready_for_build', 'vendor_run'):
                    self.assertIs(result[flag], False)
                self.assertEqual([e for e in events if e[0] == 'wait'], [('wait', 4242, 0)])
                closed = [e[1] for e in events if e[0] == 'close']
                self.assertCountEqual(closed, list(range(100, 108)) +
                                      ([108] if refusal == 'probe' else []))
                self.assertEqual(closed.count(107), 1)  # Never retry failed close.
                self.assertLess(events.index(('close', 107)), events.index(('wait', 4242, 0)))
                for fd in (101, 102, 104):
                    self.assertLess(events.index(('wait', 4242, 0)), events.index(('close', fd)))
                self.assertEqual([c.args[0] for c in read.call_args_list], [102, 104])
                self.assertEqual([e for e in events if e[0] == 'signal'],
                    [('signal', 108, 0), ('signal', 108, signal.SIGKILL)]
                    if refusal == 'probe' else [])

    def test_signal_probe_failure_gates_child(self):
        actual = signal.pidfd_send_signal
        calls = []
        def probe(fd, sig, info, flags):
            calls.append(sig)
            if len(calls) == 2:
                raise PermissionError('inert child signal policy failure')
            return actual(fd, sig, info, flags)
        with patch.object(L.signal, 'pidfd_send_signal', side_effect=probe):
            result = self.inert(b'raise SystemExit(99)\n')
        self.assertTrue(result['reaped'])
        self.assertEqual(result['terminal'], 'INCOMPLETE')
        self.assertNotEqual(os.waitstatus_to_exitcode(result['wait_status']), 99)

    def test_large_source_nonblocking_input(self):
        result = self.inert(b'# inert padding\n' * 20000 + GOOD)
        self.assertEqual(result['terminal'], 'completed')

    def test_outer_channel_broken_pipe(self):
        r, w = os.pipe()
        os.close(r)
        class Output:
            def fileno(self):
                return w
        try:
            with patch.object(L.sys, 'stdout', Output()):
                self.assertFalse(L.emit({'terminal': 'INCOMPLETE'}))
        finally:
            os.close(w)

    def test_outer_channel_full_is_bounded(self):
        r, w = os.pipe()
        class Output:
            def fileno(self):
                return w
        try:
            with patch.object(L.sys, 'stdout', Output()), patch.object(L, 'OUTPUT_SECONDS', 0.05):
                self.assertFalse(L.emit({'terminal': 'INCOMPLETE', 'inert': 'x' * 100000}))
        finally:
            os.close(r)
            os.close(w)

    def test_all_owned_fds_closed_and_exact_child_reaped(self):
        real_pipe, real_open, real_wait = os.pipe2, os.pidfd_open, os.waitpid
        owned, waited, children = [], [], []
        def pipe(flags):
            pair = real_pipe(flags)
            owned.extend(pair)
            return pair
        def acquire(pid, flags):
            fd = real_open(pid, flags)
            owned.append(fd)
            if pid != os.getpid():
                children.append(pid)
            return fd
        def wait(pid, flags):
            waited.append((pid, flags))
            return real_wait(pid, flags)
        with patch.object(L.os, 'pipe2', side_effect=pipe), patch.object(L.os, 'pidfd_open', side_effect=acquire), patch.object(L.os, 'waitpid', side_effect=wait):
            result = self.inert(GOOD)
        self.assertTrue(result['reaped'])
        self.assertEqual(waited, [(children[0], 0)])
        for fd in owned:
            with self.assertRaises(OSError) as raised:
                os.fstat(fd)
            self.assertEqual(raised.exception.errno, errno.EBADF)

    def test_identity_and_interpreter_attestation_fake_only(self):
        from contextlib import ExitStack
        from types import SimpleNamespace
        from unittest.mock import mock_open
        expected = dict(host='Agilex7Workstation', uid=1000, euid=1000,
                        parent=25387, version=(3, 9), real=L.REAL_PYTHON,
                        user='uwb_student00', logname='uwb_student00',
                        tmux='/tmp/tmux-1000/default,7828,4', pane='%4')
        mutations = dict(host='wrong', uid=0, euid=0, parent=1, version=(3, 10),
                         real='/wrong', user='wrong', logname='wrong',
                         tmux='wrong', pane='%5')
        for change in [None] + list(mutations):
            values = dict(expected)
            if change:
                values[change] = mutations[change]
            with self.subTest(change=change), ExitStack() as stack:
                for obj, name, value in ((L.sys, 'argv', ['-']),
                        (L.sys, 'version_info', values['version']),
                        (L.sys, 'flags', SimpleNamespace(isolated=1, no_site=1)),
                        (L.sys, 'dont_write_bytecode', True),
                        (L, 'PYTHON_SHA', L.digest(b'inert executable'))):
                    stack.enter_context(patch.object(obj, name, value))
                for name, value in (('uname', SimpleNamespace(nodename=values['host'])),
                                    ('getuid', values['uid']), ('geteuid', values['euid']),
                                    ('getppid', values['parent'])):
                    stack.enter_context(patch.object(L.os, name, return_value=value))
                stack.enter_context(patch.dict(L.os.environ, dict(USER=values['user'],
                    LOGNAME=values['logname'], TMUX=values['tmux'], TMUX_PANE=values['pane']), clear=True))
                stack.enter_context(patch.object(L.os.path, 'realpath', return_value=values['real']))
                opened = stack.enter_context(patch('builtins.open', mock_open(read_data=b'inert executable')))
                if change:
                    with self.assertRaises(RuntimeError):
                        L.attest()
                else:
                    L.attest()
                    self.assertEqual([c.args[0] for c in opened.call_args_list], [L.REAL_PYTHON, '/proc/self/exe'])

    def test_attestation_rejects_arguments_without_host_access(self):
        with patch.object(L.sys, 'argv', ['-', 'extra']), patch.object(L.os, 'uname') as uname:
            with self.assertRaisesRegex(RuntimeError, 'stdin_program'):
                L.attest()
            uname.assert_not_called()


if __name__ == '__main__':
    unittest.main()
