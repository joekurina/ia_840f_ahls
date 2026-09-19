"""Inert IA840F helper tests: mock the gate, never import/run vendor tools."""
import hashlib
import json
from pathlib import Path
import sys
from types import ModuleType, SimpleNamespace
import unittest
from unittest.mock import Mock, patch
import xml.etree.ElementTree as ET

import ia840f_vendor_pcie as helper

LEGACY = 'axi_lite_clk_freq_user_hwtcl'
PORT0 = 'core16_axi_lite_clk_freq_user_hwtcl'
BOARD = Path(helper.__file__).resolve().parents[3] / 'ipss/ia840f'
PRESET = BOARD / 'presets/ia840f_pcie_known_schema.qprs'


class MockGate(ModuleType):
    pcie_context: Mock


class CSRClockCorrectionTests(unittest.TestCase):
    def setUp(self):
        self.data = PRESET.read_bytes()
        self.overrides = {p.attrib['name']: p.attrib['value'] for p in
                          ET.fromstring(self.data).findall('.//preset/parameter')}
        self.gate = MockGate('ia840f_experimental_gate')
        self.gate.pcie_context = Mock()
        self.gate_patch = patch.dict(sys.modules, {'ia840f_experimental_gate': self.gate})
        self.gate_patch.start()
        self.addCleanup(self.gate_patch.stop)

    def pcie(self, **changes):
        fields = dict(platform='ia840f', ip_component='intel_pcie_ss_axi',
                      ip_preset=None, num_pfs=2, pf_vf_count={'pf0': 1, 'pf1': 0},
                      ip_component_params={LEGACY: 100, 'unrelated': 'keep',
                                           'core8_axi_lite_clk_freq_user_hwtcl': '250',
                                           'core4_0_axi_lite_clk_freq_user_hwtcl': '250',
                                           'core4_1_axi_lite_clk_freq_user_hwtcl': '250'})
        fields.update(changes)
        return SimpleNamespace(**fields)

    def test_exact_parameter_delta_and_unchanged_source_hash(self):
        obj = self.pcie()
        old_result = {**obj.ip_component_params, **self.overrides}
        expected = dict(old_result)
        expected[PORT0] = expected.pop(LEGACY)
        helper.apply_ia840f_pcie_source(obj)
        self.assertEqual(obj.ip_component_params, expected)
        self.assertEqual(obj.ip_component_params[PORT0], '100')
        self.assertNotIn(LEGACY, obj.ip_component_params)
        self.assertEqual(obj.pf_vf_count, {'pf0': 1, 'pf1': 0})
        self.assertEqual(obj.ip_component_params['core16_pf1_bar2_address_width_user_hwtcl'], '28')
        self.assertEqual(obj.ip_component_params['core16_pf1_bar2_type_user_hwtcl'],
                         '64-bit prefetchable memory')
        self.gate.pcie_context.assert_called_once_with(obj)
        report = json.loads((BOARD / 'preset_derivation.json').read_text())
        self.assertEqual(hashlib.sha256(PRESET.read_bytes()).hexdigest(),
                         report['outputs_sha256']['presets/ia840f_pcie_known_schema.qprs'])
        self.assertEqual(PRESET.read_bytes(), self.data)

    def test_gate_observes_corrected_parameters_and_denial_propagates(self):
        obj = self.pcie()
        def deny(pcie):
            self.assertNotIn(LEGACY, pcie.ip_component_params)
            self.assertEqual(pcie.ip_component_params[PORT0], '100')
            raise RuntimeError('mock authorization denial')
        self.gate.pcie_context.side_effect = deny
        with self.assertRaisesRegex(RuntimeError, 'mock authorization denial'):
            helper.apply_ia840f_pcie_source(obj)
        self.gate.pcie_context.assert_called_once_with(obj)

    def test_other_boards_return_before_any_source_reads_or_gate(self):
        for platform in ('n6001', 'f2000x', 'other'):
            with self.subTest(platform=platform):
                obj = self.pcie(platform=platform)
                before = dict(obj.ip_component_params)
                with patch.object(Path, 'read_text', side_effect=AssertionError('unexpected read')):
                    helper.apply_ia840f_pcie_source(obj)
                self.assertEqual(obj.ip_component_params, before)
        self.gate.pcie_context.assert_not_called()

    def test_existing_component_preset_and_pf_vf_rejections(self):
        for changes in ({'ip_component': 'pcie_ss'}, {'ip_preset': 'preset'},
                        {'num_pfs': 1}, {'pf_vf_count': {'pf0': 0, 'pf1': 0}}):
            with self.subTest(changes=changes):
                obj = self.pcie(**changes)
                before = dict(obj.ip_component_params)
                with self.assertRaises(ValueError):
                    helper.apply_ia840f_pcie_source(obj)
                self.assertEqual(obj.ip_component_params, before)
        self.gate.pcie_context.assert_not_called()

    def test_preset_hash_mismatch_still_rejected(self):
        obj = self.pcie()
        before = dict(obj.ip_component_params)
        with patch.object(Path, 'read_bytes', return_value=self.data + b' '):
            with self.assertRaisesRegex(ValueError, 'preset hash mismatch'):
                helper.apply_ia840f_pcie_source(obj)
        self.assertEqual(obj.ip_component_params, before)
        self.gate.pcie_context.assert_not_called()

    def test_hash_consistent_but_changed_clock_contract_rejected(self):
        # Synthetic in-memory fixtures only; do not rewrite the donor/report.
        for value in ('125', None):
            root = ET.fromstring(self.data)
            preset = root.find('.//preset')
            assert preset is not None
            node = preset.find("parameter[@name='%s']" % LEGACY)
            assert node is not None
            if value is None:
                preset.remove(node)
            else:
                node.set('value', value)
            data = ET.tostring(root)
            report = {'outputs_sha256': {'presets/ia840f_pcie_known_schema.qprs':
                                         hashlib.sha256(data).hexdigest()}}
            obj = self.pcie()
            before = dict(obj.ip_component_params)
            with patch.object(Path, 'read_bytes', return_value=data), \
                 patch.object(Path, 'read_text', return_value=json.dumps(report)):
                with self.assertRaisesRegex(ValueError, 'must request 100 MHz'):
                    helper.apply_ia840f_pcie_source(obj)
            self.assertEqual(obj.ip_component_params, before)
        self.gate.pcie_context.assert_not_called()

    def test_repeated_application_is_stable(self):
        obj = self.pcie()
        helper.apply_ia840f_pcie_source(obj)
        first = dict(obj.ip_component_params)
        helper.apply_ia840f_pcie_source(obj)
        self.assertEqual(obj.ip_component_params, first)
        self.assertEqual(self.gate.pcie_context.call_count, 2)


if __name__ == '__main__':
    unittest.main()
