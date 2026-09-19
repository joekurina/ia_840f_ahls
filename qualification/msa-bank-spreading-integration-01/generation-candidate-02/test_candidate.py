"""Inert tests with captured Work11 data. Never invoke vendor tools."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import compare_memory as c
import run_generation as runner

HERE = Path(__file__).resolve().parent


class Comparisons(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.before = HERE / 'baseline/mem_ss.ip'
        self.after = self.root / 'mem_ss.ip'
        tree = ET.parse(self.before)
        for p in tree.iter():
            if p.tag.endswith('parameter') and p.attrib.get('parameterId') == 'NUM_BANK_FIFOS':
                for child in p:
                    if child.tag.endswith('value'): child.text = '0'
        tree.write(self.after, encoding='utf-8', xml_declaration=True)

    def test_exact_two_changes(self):
        result = c.compare_saved(self.before, self.after)
        self.assertTrue(result['accepted'])
        self.assertEqual(result['parameter_counts'], [3016, 3016])
        self.assertEqual(len(result['serialized_delta']), 2)

    def test_original_eights_rejected(self):
        self.assertFalse(c.compare_saved(self.before, self.before)['accepted'])

    def test_hidden_or_interface_drift_rejected(self):
        tree = ET.parse(self.after)
        tree.getroot().set('injected_clock_boundary', 'changed')
        tree.write(self.after)
        result = c.compare_saved(self.before, self.after)
        self.assertTrue(result['semantic_ok'])
        self.assertFalse(result['accepted'])

    def test_copy_drift_rejected(self):
        tree = ET.parse(self.after)
        for p in tree.iter():
            if p.tag.endswith('parameter') and p.attrib.get('parameterId') == 'NUM_COPIES':
                for child in p:
                    if child.tag.endswith('value'): child.text = '2'
        tree.write(self.after)
        self.assertFalse(c.compare_saved(self.before, self.after)['accepted'])

    def test_missing_parameter_rejected(self):
        tree = ET.parse(self.after)
        for p in tree.iter():
            for ch in list(p):
                if ch.attrib.get('parameterId') == 'NUM_BANK_FIFOS': p.remove(ch)
        tree.write(self.after)
        self.assertFalse(c.compare_saved(self.before, self.after)['accepted'])

    def test_all_generated_baseline_files_compared(self):
        result = c.compare_generated(HERE / 'baseline', HERE / 'baseline')
        expected = [p for p in (HERE/'baseline').rglob('*') if p.is_file() and '/sim/' not in str(p)]
        self.assertEqual(len(result['files']), len(expected))
        self.assertFalse(result['accepted'])
        self.assertFalse(any(x.get('missing') for x in result['files']))
        self.assertTrue(all(not x.get('all_xml_changes') and not x.get('unified_diff') for x in result['files']))

    def test_full_wrapper_count_and_connections(self):
        p = next((HERE/'baseline').rglob('*msa_0.v'))
        data = c.wrapper(p)
        self.assertEqual(len(data['parameters_and_connections']), 102)
        self.assertIn(('NUM_BANK_FIFOS', '8'), data['parameters_and_connections'])
        self.assertIn(('NUM_COPIES', '1'), data['parameters_and_connections'])
        self.assertIn(('s_reset_n', 's_reset_n'), data['parameters_and_connections'])


class EarlyGuard(unittest.TestCase):
    def test_outer_main_returns_native_status(self):
        import sys
        with patch.object(sys, 'argv', ['run_generation.py']), patch.object(runner, 'run', side_effect=runner.NativeStageFailure('inert', 7)):
            self.assertEqual(runner.main(), 7)
        with patch.object(sys, 'argv', ['run_generation.py']), patch.object(runner, 'run', side_effect=runner.NativeStageFailure('inert-timeout', 124)):
            self.assertEqual(runner.main(), 124)

    def test_native_failure_and_exclusive_rerun_with_inert_child(self):
        import sys
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); work = root/'work'; run = root/'run'
            binding = {'environment': {}, 'stages': [{'name':'save-reload','argv':[sys.executable,'-c','raise SystemExit(7)'],'cwd':str(work),'timeout_seconds':10}]}
            (root/'execution-binding.json').write_text('{}')
            with patch.object(runner, 'PACKAGE', root), patch.object(runner, 'WORK', work), patch.object(runner, 'RUN', run), patch.object(runner, 'preflight', return_value=binding), patch.object(runner, 'check_source_and_dependencies', return_value=binding):
                with self.assertRaisesRegex(ValueError, 'rc=7'): runner.run()
                self.assertEqual(json.loads((run/'save-reload-result.json').read_text())['returncode'], 7)
                self.assertEqual(json.loads((run/'result.json').read_text())['status'], 'failed')
                snapshot = {str(p.relative_to(root)):c.sha(p) for p in root.rglob('*') if p.is_file()}
                with self.assertRaises(FileExistsError): runner.run()
                self.assertEqual(snapshot, {str(p.relative_to(root)):c.sha(p) for p in root.rglob('*') if p.is_file()})

    def test_missing_review_has_no_side_effects(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t)
            with patch.object(runner, 'REVIEW', root/'missing.json'), patch.object(runner, 'WORK', root/'work'), patch.object(runner, 'RUN', root/'run'), patch.object(runner.subprocess, 'Popen', side_effect=AssertionError('must not launch')), patch.object(runner.subprocess, 'check_output', side_effect=AssertionError('must not inspect before review')):
                with self.assertRaises(FileNotFoundError): runner.run()
            self.assertEqual(list(root.iterdir()), [])

    def test_false_review_rejected_before_creation(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); p = root/'review.json'
            p.write_text(json.dumps({'approved': False}))
            with patch.object(runner, 'REVIEW', p), patch.object(runner, 'WORK', root/'work'), patch.object(runner, 'RUN', root/'run'):
                with self.assertRaisesRegex(ValueError, 'independent reviews'): runner.run()
            self.assertEqual(list(root.iterdir()), [p])

    def test_changed_manifest_rejected(self):
        with tempfile.TemporaryDirectory() as t:
            root = Path(t); p = root/'review.json'
            p.write_text(json.dumps({'approved':True,'spec_accepted':True,'quality_accepted':True,'package_manifest_sha256':'wrong','execution_ready':False}))
            (root/'package-manifest.json').write_text('{}')
            with patch.object(runner, 'REVIEW', p), patch.object(runner, 'PACKAGE', root):
                with self.assertRaisesRegex(ValueError, 'review binding'): runner.check_package()


if __name__ == '__main__': unittest.main(verbosity=2)
