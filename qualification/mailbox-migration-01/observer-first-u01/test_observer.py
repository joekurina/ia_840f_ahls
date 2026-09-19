"""Inert tests; all evidence stays under this directory, never vendor fixtures."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

import observer as o

HERE = Path(__file__).resolve().parent


class ObserverTests(unittest.TestCase):
    def setUp(self):
        self.root = Path(tempfile.mkdtemp(prefix='test-evidence-', dir=HERE))

    def test_vendor_rejected_before_launch(self):
        with patch.object(subprocess, 'Popen', side_effect=AssertionError('launched')):
            with self.assertRaisesRegex(o.Refusal, 'unsupported'):
                o.vendor_gate()

    def test_exclusive_retention(self):
        p = self.root / 'claim'
        o.claim(p, self.root / 'scratch')
        (p / 'partial').write_text('keep')
        with self.assertRaises(FileExistsError):
            o.claim(p, self.root / 'scratch')
        self.assertEqual((p / 'partial').read_text(), 'keep')
        with self.assertRaises(o.Refusal):
            o.claim(self.root / 'scratch' / 'observation', self.root / 'scratch')

    def test_manifest(self):
        protected = self.root / 'original'
        protected.mkdir()
        (protected / 'data').write_text('before')
        before = o.manifest([protected])
        (protected / 'data').write_text('after')
        self.assertNotEqual(before, o.manifest([protected]))

    def test_unresolved_scope_is_stop(self):
        for event in ['unexpected executable', 'external write', 'dirfd', 'rename', 'mmap', 'unknown']:
            self.assertEqual(o.scope_decision(event), 'stop: unsupported scope audit: ' + event)

    def run_fixture(self, reason, *, deadline=2, grace=.1):
        evidence = self.root / 'run'
        evidence.mkdir()
        code = 'import time,signal; signal.signal(signal.SIGTERM,signal.SIG_IGN); time.sleep(30)'
        p, guard, conn = o.start_supervised(
            [sys.executable, '-I', '-B', '-c', code], evidence,
            {'LANG': 'C', 'PATH': '/usr/bin:/bin'},
            deadline=deadline, grace=grace, poll=.02, trace_limit=1024,
            trace_required=False)
        try:
            if reason:
                conn.send(('stop', reason))
            while guard.is_alive():
                if not reason:
                    try:
                        conn.send(('health', None))
                    except BrokenPipeError:
                        guard.join(2)
                        break
                guard.join(.03)
            p.wait(timeout=2)
        finally:
            conn.close()
            if p.poll() is None:
                p.kill()
                p.wait()
        return json.loads((evidence / 'watchdog.json').read_text()), evidence

    def test_timeout(self):
        result, evidence = self.run_fixture(None, deadline=.2)
        self.assertEqual(result['reason'], 'deadline')
        self.assertEqual(result['survivors'], [])
        self.assertTrue((evidence / 'processes.jsonl').exists())

    def test_trace_loss_stop(self):
        result, _ = self.run_fixture('trace loss')
        self.assertEqual(result['reason'], 'trace loss')

    def test_unexpected_execution_stop(self):
        result, _ = self.run_fixture(o.scope_decision('unexpected executable'))
        self.assertIn('unexpected executable', result['reason'])

    def test_external_write_stop_retains(self):
        result, evidence = self.run_fixture(o.scope_decision('external write'))
        self.assertIn('external write', result['reason'])
        self.assertTrue((evidence / 'stdout').exists())
        self.assertTrue((evidence / 'stderr').exists())

    def test_detect_deleted_trace(self):
        evidence = self.root / 'trace-loss'
        evidence.mkdir()
        trace = evidence / 'syscall.123'
        trace.write_text('inert fixture trace, not real strace output\n')
        p, guard, conn = o.start_supervised(
            [sys.executable, '-I', '-B', '-c', 'import time; time.sleep(30)'],
            evidence, {'LANG': 'C'}, deadline=2, grace=.1, poll=.02)
        time.sleep(.08)
        trace.unlink()  # deliberate fault injection only, fixture evidence lost
        guard.join(3)
        p.wait(timeout=2)
        conn.close()
        self.assertFalse(guard.is_alive())
        result = json.loads((evidence / 'watchdog.json').read_text())
        self.assertEqual(result['reason'], 'trace loss')

    def test_observer_heartbeat_loss(self):
        evidence = self.root / 'health-loss'
        evidence.mkdir()
        p, guard, conn = o.start_supervised(
            [sys.executable, '-I', '-B', '-c', 'import time; time.sleep(30)'],
            evidence, {'LANG': 'C'}, deadline=2, grace=.1, poll=.02,
            trace_required=False)
        guard.join(3)
        p.wait(timeout=2)
        conn.close()
        result = json.loads((evidence / 'watchdog.json').read_text())
        self.assertEqual(result['reason'], 'observer heartbeat lost')

    def test_trace_byte_limit(self):
        evidence = self.root / 'trace-limit'
        evidence.mkdir()
        (evidence / 'syscall.123').write_bytes(b'fixture' * 100)
        p, guard, conn = o.start_supervised(
            [sys.executable, '-I', '-B', '-c', 'import time; time.sleep(30)'],
            evidence, {'LANG': 'C'}, deadline=2, grace=.1, poll=.02,
            trace_limit=500)
        guard.join(3)
        p.wait(timeout=2)
        conn.close()
        result = json.loads((evidence / 'watchdog.json').read_text())
        self.assertEqual(result['reason'], 'trace byte limit')

    def test_setsid_descendant_stop(self):
        evidence = self.root / 'setsid'
        evidence.mkdir()
        code = 'import os,time; p=os.fork(); os.setsid() if p==0 else None; time.sleep(30)'
        p, guard, conn = o.start_supervised(
            [sys.executable, '-I', '-B', '-c', code], evidence, {'LANG': 'C'},
            deadline=2, grace=.1, poll=.02, trace_required=False)
        time.sleep(.15)
        conn.send(('stop', 'descendant fixture'))
        guard.join(3)
        p.wait(timeout=2)
        conn.close()
        result = json.loads((evidence / 'watchdog.json').read_text())
        self.assertGreaterEqual(len(result['known']), 2)
        self.assertEqual(result['survivors'], [])

    def test_missing_strace_no_launch(self):
        with patch.object(o.shutil, 'which', return_value=None), patch.object(subprocess, 'Popen', side_effect=AssertionError('launched')):
            result = o.preflight(self.root / 'preflight', [HERE / 'observer.py'])
        self.assertFalse(result['probe_passed'])
        self.assertIn('strace unavailable', result['error'])
        self.assertTrue((self.root / 'preflight' / 'before.json').exists())
        self.assertTrue((self.root / 'preflight' / 'after.json').exists())


if __name__ == '__main__':
    unittest.main(verbosity=2)
