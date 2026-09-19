#!/usr/bin/env python3
"""INERT Python tests only: synthetic transcripts are never HDL evidence."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('runner', HERE / 'run.py')
r = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r)


def synthetic():
    return '\n'.join([f'# CHECKED {i} synthetic-test-only' for i in range(1, 155)]
                     + ['# ' + r.EXPECTED_PASS])


class InertTests(unittest.TestCase):
    def test_transcript_acceptance_and_mutations(self):
        text = synthetic()
        self.assertTrue(r.transcript_gate(text, 0)['accepted'])
        bad = [text.replace('CHECKED 2 ', 'CHECKED 1 '),
               text.replace('CHECKED 1 ', 'CHECKED 0 '),
               text.replace('CHECKED 154 synthetic-test-only', 'CHECKED nope'),
               text + '\n# ' + r.EXPECTED_PASS,
               text.replace('checks=160007', 'checks=160008'),
               text + '\n# ** Error: synthetic', text + '\n# ** Fatal: synthetic',
               text + '\n# FAIL synthetic', text + '\n# Errors: 1',
               text.replace('# CHECKED 1 synthetic-test-only\n', ''),
               text.replace('# CHECKED 1 synthetic-test-only\n# CHECKED 2 synthetic-test-only',
                            '# CHECKED 2 synthetic-test-only\n# CHECKED 1 synthetic-test-only')]
        for case in bad:
            self.assertFalse(r.transcript_gate(case, 0)['accepted'])
        self.assertFalse(r.transcript_gate(text, 1)['accepted'])
        self.assertFalse(r.diagnostics('Errors: 0, Warnings: 0'))
        self.assertTrue(r.diagnostics('Errors: 0\n** Error: synthetic'))

    def test_real_inert_python_stage_and_timeout(self):
        with tempfile.TemporaryDirectory(dir=HERE, prefix='.inert-test-') as d:
            root = Path(d)
            env = {'PATH': '/usr/bin:/bin'}
            a = r.stage(root, 'exit7', [sys.executable, '-c', 'raise SystemExit(7)'], env, 5)
            self.assertEqual(a['rc'], 7)
            before = {str(p): r.pin(p) for p in root.rglob('*') if p.is_file()}
            with self.assertRaises(FileExistsError):
                r.stage(root, 'exit7', [sys.executable, '-c', 'pass'], env, 5)
            self.assertEqual(before, {str(p): r.pin(p) for p in root.rglob('*') if p.is_file()})
            b = r.stage(root, 'timeout', [sys.executable, '-c', 'import time; time.sleep(10)'], env, 0.05)
            self.assertEqual(b['rc'], 124)
            self.assertTrue(b['timed_out'])

    def test_runtime_identity_rejected(self):
        with patch.object(r.socket, 'gethostname', return_value='NOT-EXECUTION-HOST'):
            with self.assertRaisesRegex(RuntimeError, 'hostname'):
                r.runtime_guard()
        with patch.object(r.socket, 'gethostname', return_value='Agilex7Workstation'), patch.object(r.os, 'getuid', return_value=0):
            with self.assertRaisesRegex(RuntimeError, 'UID'):
                r.runtime_guard()
        with patch.object(r.socket, 'gethostname', return_value='Agilex7Workstation'), patch.object(r.os, 'getuid', return_value=1000), patch.object(r.os, 'geteuid', return_value=1000), patch.dict(os.environ, {'TMUX': ''}):
            with self.assertRaisesRegex(RuntimeError, 'TMUX'):
                r.runtime_guard()

    def test_compile_failure_blocks_simulation_and_preserves_rerun(self):
        # Mocked identities and tool stages only. Never execute fake vendor files.
        with tempfile.TemporaryDirectory(dir=HERE, prefix='.inert-test-') as d:
            root = Path(d)
            pkg = root / 'mock-package'; pkg.mkdir()
            shutil.copytree(HERE / 'inputs', pkg / 'inputs')
            for name in ('sources.f', 'input-manifest.json'):
                shutil.copyfile(HERE / name, pkg / name)
            pins = {str(p.relative_to(pkg)): r.pin(p) for p in pkg.rglob('*') if p.is_file()}
            r.dump(pkg / 'package-sha256.json', pins)
            tools = root / 'mock-tools'; tools.mkdir()
            for name in ('vlib', 'vlog', 'vsim'):
                (tools / name).write_text('INERT NONEXECUTABLE TEST FIXTURE\n')
            license_file = root / 'mock-license'; license_file.write_text('INERT\n')
            called = []
            def fake_stage(out, name, argv, env, timeout):
                called.append(name)
                return {'rc': 17 if name == 'compile' else 0, 'error_or_fatal': False}
            out = root / 'fresh-output'
            with patch.object(r, 'HERE', pkg), patch.object(r, 'TOOLS', tools), patch.object(r, 'LICENSE', str(license_file)), patch.object(r, 'runtime_guard'), patch.object(r, 'stage', side_effect=fake_stage), patch.dict(os.environ, {'TMUX': 'INERT-ONLY'}), contextlib.redirect_stdout(io.StringIO()):
                rc = r.main(['--execute-reviewed', '--output', str(out)])
                self.assertEqual(rc, 17)
                self.assertEqual(called, ['vlog-version', 'vsim-version', 'vlib', 'compile'])
                self.assertEqual(r.stage.call_args_list[0].args[2:5:2],
                                 ([str(tools / 'vlog'), '-version'], 15))
                self.assertEqual(r.stage.call_args_list[1].args[2:5:2],
                                 ([str(tools / 'vsim'), '-version'], 15))
                self.assertEqual(r.stage.call_args_list[2].args[2:5:2],
                                 ([str(tools / 'vlib'), 'work'], 30))
                tool_pins = json.loads((out / 'tools.before.json').read_text())
                self.assertEqual(set(tool_pins), {'vlib', 'vlog', 'vsim'})
                self.assertEqual(tool_pins['vlib']['sha256'], r.pin(tools / 'vlib')['sha256'])
                self.assertEqual(tool_pins, json.loads((out / 'tools.after.json').read_text()))
                result = json.loads((out / 'result.json').read_text())
                self.assertEqual(result['status'], 'FAIL')
                self.assertIsNone(result['simulation_rc'])
                self.assertTrue(result['inputs_unchanged'])
                evidence = {str(p): r.pin(p) for p in out.rglob('*') if p.is_file()}
                with self.assertRaisesRegex(RuntimeError, 'fresh absolute'):
                    r.main(['--execute-reviewed', '--output', str(out)])
                self.assertEqual(evidence, {str(p): r.pin(p) for p in out.rglob('*') if p.is_file()})
                (pkg / 'inputs/tb.sv').write_text('INERT TAMPER')
                with self.assertRaisesRegex(RuntimeError, 'hash mismatch'):
                    r.main(['--execute-reviewed', '--output', str(root / 'tampered-output')])
                self.assertFalse((root / 'tampered-output').exists())


if __name__ == '__main__':
    unittest.main(verbosity=2)
