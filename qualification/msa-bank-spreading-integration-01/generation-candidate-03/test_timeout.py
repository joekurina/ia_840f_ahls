"""Linux-only inert S1 regression: actual runner, no vendor executable."""
import ctypes
import json
import os
from pathlib import Path
import signal
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

import compare_memory as c
import run_generation as runner


class TimeoutGroup(unittest.TestCase):
    def test_already_absent_group_preserves_timeout_status(self):
        from unittest.mock import Mock
        import subprocess
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); work, run = root/'work', root/'run'
            (root/'execution-binding.json').write_text('{}')
            binding = {'environment': {}, 'stages': [{'name':'save-reload', 'argv':['inert-not-executed'], 'cwd':str(work), 'timeout_seconds':1}]}
            child = Mock(pid=987654321)
            child.wait.side_effect = [subprocess.TimeoutExpired('inert', 1), 0]
            signals = []
            def absent(pgid, sig):
                # No intermediate wait/poll may reap the group leader.
                self.assertEqual(child.wait.call_count, 1)
                self.assertEqual(pgid, child.pid)
                signals.append(sig)
                raise ProcessLookupError()
            with patch.object(runner, 'PACKAGE', root), patch.object(runner, 'WORK', work), patch.object(runner, 'RUN', run), patch.object(runner, 'preflight', return_value=binding), patch.object(runner, 'check_source_and_dependencies', return_value=binding), patch.object(runner.subprocess, 'Popen', return_value=child), patch.object(runner.os, 'killpg', side_effect=absent), patch.object(runner.time, 'sleep'), patch.object(sys, 'argv', ['run_generation.py']):
                self.assertEqual(runner.main(), 124)
            self.assertEqual(signals, [signal.SIGTERM, signal.SIGKILL])
            self.assertEqual(child.wait.call_count, 2)
            child.poll.assert_not_called()
            result = json.loads((run/'save-reload-result.json').read_text())
            self.assertEqual(result['returncode'], 124)
            self.assertIs(result['timeout_group_terminated'], True)
            self.assertEqual(json.loads((run/'result.json').read_text())['status'], 'failed')

    def test_launcher_exits_descendant_ignores_term(self):
        # Adopt/reap this test's orphan rather than leave a zombie under PID 1.
        libc = ctypes.CDLL(None, use_errno=True)
        previous = ctypes.c_int()
        self.assertEqual(libc.prctl(37, ctypes.byref(previous), 0, 0, 0), 0)
        self.assertEqual(libc.prctl(36, 1, 0, 0, 0), 0)
        root = Path(tempfile.mkdtemp(prefix='msa-inert-timeout-', dir=os.environ.get('MSA_TEST_EVIDENCE')))
        work, run = root/'work', root/'run'
        script = '''import os, signal, time
from pathlib import Path
signal.signal(signal.SIGTERM, lambda *_: os._exit(0))
pid = os.fork()
if pid == 0:
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    Path('descendant.json').write_text(__import__('json').dumps({'pid':os.getpid(),'pgid':os.getpgrp(),'sid':os.getsid(0)}))
while True: time.sleep(.01)
'''
        binding = {'environment': {}, 'stages': [{'name':'save-reload', 'argv':[sys.executable,'-B','-c',script], 'cwd':str(work), 'timeout_seconds':1}]}
        (root/'execution-binding.json').write_text('{}')
        descendant = None
        try:
            with patch.object(runner, 'PACKAGE', root), patch.object(runner, 'WORK', work), patch.object(runner, 'RUN', run), patch.object(runner, 'preflight', return_value=binding), patch.object(runner, 'check_source_and_dependencies', return_value=binding), patch.object(sys, 'argv', ['run_generation.py']):
                started = time.monotonic()
                rc = runner.main()
                elapsed = time.monotonic() - started
                descendant = json.loads((work/'descendant.json').read_text())
                stat = Path('/proc')/str(descendant['pid'])/'stat'
                observed = stat.read_text().rsplit(')', 1)[1].split() if stat.exists() else None
                live = observed is not None and observed[0] not in ('Z', 'X')
                if observed:
                    self.assertEqual(int(observed[2]), descendant['pgid'])
                    self.assertEqual(int(observed[3]), descendant['sid'])
                self.assertEqual(rc, 124)
                self.assertLess(elapsed, 25)
                self.assertEqual(json.loads((run/'save-reload-result.json').read_text())['returncode'], 124)
                result = json.loads((run/'result.json').read_text())
                self.assertEqual(result['status'], 'failed')
                for flag in ('execution_ready','functional_ready','timing_ready','constraint_ready','native_generation_completed'):
                    self.assertIs(result[flag], False)
                snapshot = {str(p.relative_to(root)):c.sha(p) for p in root.rglob('*') if p.is_file()}
                with self.assertRaises(FileExistsError): runner.main()
                self.assertEqual(snapshot, {str(p.relative_to(root)):c.sha(p) for p in root.rglob('*') if p.is_file()})
                observation = {'returncode':rc, 'elapsed_seconds':elapsed, 'descendant':descendant, 'state_on_return':observed[0] if observed else 'absent', 'live_on_return':live, 'rerun_unchanged':True, 'evidence':str(root)}
                (root/'observation.json').write_text(json.dumps(observation,indent=2)+'\n')
                print(json.dumps(observation), flush=True)
                self.assertFalse(live, 'S1: TERM-resistant descendant still live when actual runner returns')
        finally:
            if descendant:
                try: os.kill(descendant['pid'], signal.SIGKILL)
                except ProcessLookupError: pass
                os.waitpid(descendant['pid'], 0)
            libc.prctl(36, previous.value, 0, 0, 0)


if __name__ == '__main__': unittest.main(verbosity=2)
