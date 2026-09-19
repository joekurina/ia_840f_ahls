"""Inert Q1/Q2 regressions. No main(), tmux, shell or diagnostic execution."""
import ast
from pathlib import Path
import threading
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch
import delivery
import fixture
from test_delivery import DeliveryTests, TOKEN, transcript


def run_worker(stdout, path, stop, errors, raw, clean):
    if hasattr(fixture, 'capture_worker'):
        return fixture.capture_worker(stdout, path, stop, errors, raw, clean)
    # RED-only adapter: execute the original nested worker in isolation, not main.
    tree = ast.parse(Path(fixture.__file__).read_text())
    main = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
    worker = next(n for n in main.body if isinstance(n, ast.FunctionDef) and n.name == 'capture')
    namespace = dict(vars(fixture), ctl=SimpleNamespace(stdout=stdout),
                     run=path.parent, stop=stop, errors=errors, raw=raw)
    exec(compile(ast.Module(body=[worker], type_ignores=[]), '<original capture>', 'exec'), namespace)
    namespace['capture']()


class CaptureTests(unittest.TestCase):
    def exercise(self, failure=None):
        good = DeliveryTests().good()
        raw = bytearray(); errors = []; clean = threading.Event(); stop = threading.Event()
        sel = Mock(); sel.select.return_value = [(SimpleNamespace(fd=123), 1)]
        sink = Mock(); sink.__enter__ = Mock(return_value=sink); sink.__exit__ = Mock(return_value=False)
        counts = {'read': 0, 'write': 0, 'flush': 0}
        def operation(kind):
            counts[kind] += 1
            if failure == kind and counts[kind] == 2:
                raise OSError('injected '+kind+' failure after R')
        def read(fd, size):
            operation('read')
            if counts['read'] == 1: return good
            stop.set()
            return transcript(b'ordinary prompt$ ')
        def write(data):
            operation('write')
            return len(data)
        def flush(): operation('flush')
        sink.write.side_effect = write; sink.flush.side_effect = flush
        if failure == 'open': sink_open = OSError('injected open failure')
        else: sink_open = None
        if failure == 'register': sel.register.side_effect = OSError('injected register failure')
        if failure == 'select': sel.select.side_effect = OSError('injected select failure')
        if failure == 'close': sink.__exit__.side_effect = OSError('injected close failure after R')
        if failure == 'selector-close': sel.close.side_effect = OSError('injected selector-close failure after R')
        escaped = []
        with patch.object(fixture.selectors, 'DefaultSelector', return_value=sel), \
             patch.object(fixture.os, 'read', side_effect=read), \
             patch.object(Path, 'open', return_value=sink, side_effect=sink_open):
            try:
                run_worker(object(), Path('unused/control.raw'), stop, errors, raw, clean)
            except BaseException as exc:
                escaped.append(exc)  # Old thread exception would not reach join's caller.
        return good, raw, errors, clean, escaped

    def test_io_failure_after_complete_prefix_is_incomplete(self):
        for failure in ('read', 'write', 'flush', 'close', 'selector-close'):
            with self.subTest(failure=failure):
                good, raw, errors, clean, escaped = self.exercise(failure)
                self.assertEqual(delivery.decode(bytes(raw), '%0', TOKEN)['status'], 23)
                self.assertTrue(errors, 'worker exception disappeared: '+repr(escaped))
                self.assertIn('injected '+failure+' failure', repr(errors))
                self.assertFalse(clean.is_set())
                with self.assertRaises(delivery.Incomplete):
                    fixture.require_clean_capture(SimpleNamespace(is_alive=lambda: False), errors, clean)

    def test_setup_errors_are_reported(self):
        for failure in ('open', 'register', 'select'):
            with self.subTest(failure=failure):
                _, _, errors, clean, escaped = self.exercise(failure)
                self.assertTrue(errors, repr(escaped))
                self.assertIn('injected '+failure+' failure', repr(errors))
                self.assertFalse(clean.is_set())

    def test_clean_completion_is_explicit(self):
        _, raw, errors, clean, escaped = self.exercise()
        self.assertFalse(escaped)
        self.assertFalse(errors)
        self.assertTrue(clean.is_set())
        fixture.require_clean_capture(SimpleNamespace(is_alive=lambda: False), errors, clean)
        result = delivery.decode(bytes(raw), '%0', TOKEN)
        for flag in ('authorization', 'ready_for_build', 'vendor_run'):
            self.assertIs(result[flag], False)

    def test_join_without_clean_completion_cannot_pass(self):
        for alive, clean_value in ((False, False), (True, True)):
            clean = threading.Event()
            if clean_value: clean.set()
            with self.subTest(alive=alive, clean=clean_value):
                with self.assertRaises(delivery.Incomplete):
                    fixture.require_clean_capture(SimpleNamespace(is_alive=lambda: alive), [], clean)


class PrefixTests(unittest.TestCase):
    def test_unterminated_reserved_prefixes_with_complete_outer_record(self):
        marker = ('D1 '+TOKEN+' ').encode()
        for length in range(2, len(marker)+1):
            suffix = marker[:length]
            with self.subTest(suffix=suffix):
                raw = DeliveryTests().good()+transcript(suffix)
                self.assertTrue(raw.endswith(b'\n'))
                with self.assertRaises(delivery.Incomplete): delivery.decode(raw, '%0', TOKEN)

    def test_ordinary_prompts_and_preframe_echo_remain_allowed(self):
        for prompt in (b'user@host:~$ ', b'D', b'D1-tools$ ', b'D1 other$ ', b'prompt D1 '+TOKEN.encode()):
            with self.subTest(prompt=prompt):
                echo = transcript(("> builtin printf 'D1 "+TOKEN+" S %s 0 0 0\\n'\r\n").encode())
                result = delivery.decode(echo+DeliveryTests().good()+transcript(prompt), '%0', TOKEN)
                self.assertEqual(result['status'], 23)


if __name__ == '__main__': unittest.main()
