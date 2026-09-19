"""Synthetic only: fake binary channels, invented reports, no live fixture."""
import base64
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import controller as c

HERE = Path(__file__).resolve().parent
TOKEN = 'b' * 32


def stream(b):
    return dict(length=len(b), sha256=hashlib.sha256(b).hexdigest(),
                base64=base64.b64encode(b).decode('ascii'))


def envelope():
    report = dict(authorization=False, ready_for_build=False, vendor_run=False,
                  terminal={'result': 'completed'}, guard='passed', close_errors=[],
                  counts={'visited': 1, 'discovered': 1}, selection=[], roots=['/usr'],
                  identity=dict(host='Agilex7Workstation', uid=1000, euid=1000,
                                user='uwb_student00', logname='uwb_student00',
                                tmux='/tmp/tmux-1000/default,7828,4'), elapsed=0.5)
    obj = dict(authorization=False, ready_for_build=False, vendor_run=False,
               terminal='completed', reaped=True, wait_status=0, timed_out=False,
               errors=[], elapsed=1.0, collector_length=13851,
               collector_sha256='6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897',
               launcher_binding=dict(length=30087, sha256='2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2'),
               stdout=stream(json.dumps(report).encode()), stderr=stream(bytes(range(256))))
    return b' \n' + json.dumps(obj).encode() + b'\t'


def control(data):
    escaped = b''.join(bytes([v]) if 32 <= v < 127 and v != 92
                       else ('\\%03o' % v).encode() for v in data)
    return b'%output %4 ' + escaped + b'\n'


def transcript(out=None, err=bytes(reversed(range(256))), status=0, restoration=True):
    out = envelope() if out is None else out
    marker = ('D1 ' + TOKEN + ' ').encode()
    frames = []
    for name, value in ((b'O', out), (b'E', err)):
        pieces = [value[i:i+288] for i in range(0, len(value), 288)] + [b'']
        for n, piece in enumerate(pieces):
            frames.append(control(marker + name + b' ' + str(n).encode() + b' ' + base64.b64encode(piece) + b'\n'))
    if status is not None:
        frames.append(control(marker + b'S ' + str(status).encode() + b' 0 0 0\n'))
    if restoration:
        frames.append(control(marker + b'R 0 0\n'))
    return b''.join(frames)


class Channel:
    def __init__(self, events, fail_setup=False, fail_close=False):
        self.events = list(events)
        self.fail_setup, self.fail_close = fail_setup, fail_close
        self.closed = False
        self.reads = 0

    def setup(self, deadline):
        if self.fail_setup:
            raise OSError('setup synthetic')

    def read(self, maximum, deadline):
        self.reads += 1
        item = self.events.pop(0) if self.events else c.CAPTURE_END
        if isinstance(item, BaseException):
            raise item
        if type(item) is bytes and len(item) > maximum:
            self.events.insert(0, item[maximum:])
            return item[:maximum]
        return item

    def close(self, deadline):
        self.closed = True
        if self.fail_close:
            raise OSError('channel close synthetic')


class Sink:
    def __init__(self, real, faults):
        self.real, self.faults = real, faults

    def write(self, data):
        if 'write' in self.faults:
            raise OSError('write synthetic')
        if 'short' in self.faults:
            return self.real.write(data[:-1])
        return self.real.write(data)

    def flush(self):
        if 'flush' in self.faults:
            raise OSError('flush synthetic')
        self.real.flush()

    def close(self):
        self.real.close()
        if 'close' in self.faults:
            raise OSError('sink close synthetic')


class ControllerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(dir=HERE, prefix='synthetic-')
        self.addCleanup(self.tmp.cleanup)
        self.output = Path(self.tmp.name) / 'new'

    def run_capture(self, events, **kw):
        channel = events if isinstance(events, Channel) else Channel(events)
        result = c.acquire(channel, self.output, '%4', TOKEN, **kw)
        self.assertTrue(channel.closed)
        for key in ('authorization', 'ready_for_build', 'vendor_run'):
            self.assertIs(result[key], False)
        return result

    def incomplete(self, result):
        self.assertEqual(result['assessment']['classification'], 'INCOMPLETE')
        self.assertTrue(result['errors'] or result['assessment']['issues'])

    def test_success_exact_separation_and_boundary(self):
        raw = transcript()
        r = self.run_capture([raw, c.CAPTURE_END])
        self.assertEqual(r['assessment']['classification'], 'COMPLETED')
        self.assertEqual(r['raw'], raw)
        self.assertEqual((self.output / 'control.raw').read_bytes(), raw)
        self.assertEqual((self.output / 'receiver/raw-envelope.bin').read_bytes(), envelope())
        self.assertEqual((self.output / 'receiver/command-stderr.bin').read_bytes(), bytes(reversed(range(256))))
        self.assertEqual((self.output / 'receiver/collector-stderr.bin').read_bytes(), bytes(range(256)))
        self.assertEqual(r['assessment']['command_exit_status'], 0)

    def test_disconnect_before_and_after_terminal(self):
        for events in ([b''], [transcript(), b''], [transcript(), ConnectionResetError('late')]):
            with self.subTest(events=len(events)):
                self.output = self.output.with_name(self.output.name + 'x')
                r = self.run_capture(events)
                self.incomplete(r)
                self.assertTrue(r['errors'])

    def test_setup_read_and_channel_close(self):
        for ch in (Channel([], fail_setup=True), Channel([OSError('read synthetic')]),
                   Channel([transcript()], fail_close=True)):
            self.output = self.output.with_name(self.output.name + 'x')
            self.incomplete(self.run_capture(ch))

    def test_sink_failures_and_multiple_errors(self):
        for target in ('control.raw', 'raw-envelope.bin', 'command-stderr.bin', 'collector-stdout.bin', 'acquisition.json'):
            for faults in ({'open'}, {'write'}, {'short'}, {'flush'}, {'close'}, {'write', 'flush', 'close'}):
                with self.subTest(target=target, faults=faults):
                    self.output = self.output.with_name(self.output.name + 'x')
                    def opener(path):
                        if path.name == target and 'open' in faults:
                            raise OSError('open synthetic')
                        return Sink(path.open('xb'), faults if path.name == target else set())
                    r = self.run_capture(Channel([transcript()], fail_close=True), sink_open=opener)
                    self.incomplete(r)
                    self.assertTrue(any('channel.close' in x for x in r['errors']))
                    self.assertTrue(any(target in x for x in r['errors']))
                    if target != 'control.raw' or 'open' not in faults:
                        self.assertTrue(r['raw'])
                    if len(faults) == 3:
                        for name in ('write', 'flush', 'close'):
                            self.assertTrue(any(target + '.' + name in x for x in r['errors']))

    def test_missing_nonzero_status_restoration(self):
        for status, restore in ((23, True), (None, False), (0, False)):
            self.output = self.output.with_name(self.output.name + 'x')
            r = self.run_capture([transcript(status=status, restoration=restore)])
            self.incomplete(r)
            self.assertEqual(r['assessment']['command_exit_status'], 23 if status == 23 else None)

    def test_late_protocol_errors_and_fragmented_suffix(self):
        marker = ('D1 ' + TOKEN + ' ').encode()
        suffixes = [b'%exit\n', b'%pause %4\n', b'%unknown\n', b'%error x\n',
                    b'too far behind\n', b'%output %4 \\999\n', b'%begin 1 2 3\n',
                    b'%output %4 truncated']
        suffixes += [control(marker[:i]) + control(marker[i:]) for i in range(2, len(marker))]
        for suffix in suffixes:
            self.output = self.output.with_name(self.output.name + 'x')
            self.incomplete(self.run_capture([transcript(), suffix]))

    def test_cap_and_deadline(self):
        r = self.run_capture([transcript()], raw_cap=128)
        self.incomplete(r)
        self.assertLessEqual(len(r['raw']), 129)
        self.output = self.output.with_name('deadline')
        times = iter([0, 0, 0, 1000])
        r = self.run_capture([transcript()], clock=lambda: next(times, 1000), seconds=1)
        self.incomplete(r)
        self.assertTrue(any('deadline' in x for x in r['errors']))

    def test_three_mib_envelope_and_fragmentation(self):
        env = envelope()
        env += b' ' * (3 * 1024 * 1024 - len(env))
        raw = transcript(out=env)
        self.assertGreater(len(raw), len(env))
        r = self.run_capture([raw])
        self.assertEqual(r['assessment']['classification'], 'COMPLETED')
        self.output = self.output.with_name('fragmented')
        raw = transcript()
        r = self.run_capture([raw[i:i+1] for i in range(len(raw))])
        self.assertEqual(r['assessment']['classification'], 'COMPLETED')

    def test_each_sink_fault_alone_prevents_completion(self):
        for fault in ('open', 'write', 'short', 'flush', 'close'):
            for target in ('control.raw', 'raw-envelope.bin', 'acquisition.json'):
                self.output = self.output.with_name(self.output.name + 'x')
                def opener(path):
                    if path.name == target and fault == 'open':
                        raise OSError('open synthetic')
                    return Sink(path.open('xb'), {fault} if path.name == target else set())
                r = self.run_capture([transcript()], sink_open=opener)
                self.incomplete(r)
                self.assertTrue(any(target in x for x in r['errors']))

    def test_late_read_and_cleanup_errors_preserve_valid_bytes(self):
        raw = transcript()
        ch = Channel([raw, OSError('late read')], fail_close=True)
        def opener(path):
            return Sink(path.open('xb'), {'close'} if path.name == 'control.raw' else set())
        r = self.run_capture(ch, sink_open=opener)
        self.incomplete(r)
        self.assertEqual(r['raw'], raw)
        self.assertEqual(r['envelope'], envelope())
        self.assertEqual(r['assessment']['command_exit_status'], 0)
        for text in ('late read', 'control.raw.close', 'channel.close'):
            self.assertTrue(any(text in x for x in r['errors']))
        for error in r['errors']:
            self.assertIn('transport_error:' + error, r['assessment']['issues'])

    def test_invalid_contract_inputs_and_import_inert(self):
        for kw in ({'raw_cap': 0}, {'raw_cap': c.RAW_CAP + 1},
                   {'seconds': float('nan')}, {'seconds': 91}):
            with self.assertRaises(ValueError):
                c.acquire(Channel([]), self.output, '%4', TOKEN, **kw)
        import importlib.util
        spec = importlib.util.spec_from_file_location('inert_controller', HERE / 'controller.py')
        module = importlib.util.module_from_spec(spec)
        with patch.object(Path, 'open', side_effect=AssertionError('import I/O')):
            spec.loader.exec_module(module)
        self.assertFalse(self.output.exists())

    def test_receiver_failure_and_final_cleanup_deadline(self):
        delivery, receiver = c.verified_apis()
        with patch.object(receiver, 'evaluate', side_effect=ValueError('synthetic receiver failure')):
            with patch.object(c, 'verified_apis', return_value=(delivery, receiver)):
                r = self.run_capture([transcript()])
        self.incomplete(r)
        self.assertEqual(r['envelope'], envelope())
        self.assertTrue(any('receiver.evaluate' in x for x in r['errors']))
        self.output = self.output.with_name('late-deadline')
        now = [0]
        class LateClose(Channel):
            def close(self, deadline):
                super().close(deadline)
                now[0] = 91
        r = self.run_capture(LateClose([transcript()]), clock=lambda: now[0])
        self.incomplete(r)
        self.assertEqual(r['envelope'], envelope())
        self.assertTrue(any('deadline' in x for x in r['errors']))

    def test_all_source_length_and_hash_bindings(self):
        for key, (length, sha) in list(c.BINDINGS.items()):
            for wrong in ((length + 1, sha), (length, '0' * 64)):
                with self.subTest(key=key, wrong=wrong):
                    with patch.dict(c.BINDINGS, {key: wrong}):
                        with self.assertRaises(ValueError):
                            c.acquire(Channel([]), self.output, '%4', TOKEN)
                    self.assertFalse(self.output.exists())

    def test_wrong_binding_and_existing_output_refused(self):
        with patch.dict(c.BINDINGS, {'runtime-metadata-delivery-01/delivery.py': (1, '0' * 64)}):
            ch = Channel([transcript()])
            with self.assertRaises(ValueError):
                c.acquire(ch, self.output, '%4', TOKEN)
            self.assertEqual(ch.reads, 0)
            self.assertFalse(self.output.exists())
        self.output.mkdir()
        (self.output / 'sentinel').write_bytes(b'preserved')
        with self.assertRaises(FileExistsError):
            c.acquire(Channel([]), self.output, '%4', TOKEN)
        self.assertEqual((self.output / 'sentinel').read_bytes(), b'preserved')


if __name__ == '__main__':
    unittest.main(verbosity=2)
