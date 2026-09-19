# IA840F-only source integration. No vendor tools are invoked here.
"""Apply the vendor-derived subset, then require source-bound authorization.

Hook from PCIe.process_configuration after ordinary PF/VF processing. This is
not a compatibility shim for unknown IP parameters: those remain inventory in
the derivation report. Never bypass the rejection by ignoring BAR2.
"""
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET


def apply_ia840f_pcie_source(pcie):
    if pcie.platform != 'ia840f':
        return
    if pcie.ip_component != 'intel_pcie_ss_axi' or pcie.ip_preset:
        raise ValueError('IA840F requires non-preset intel_pcie_ss_axi PF/VF processing')
    if pcie.num_pfs != 2 or pcie.pf_vf_count != {'pf0': 1, 'pf1': 0}:
        raise ValueError('IA840F contract requires PF0VF0 AFU and enabled PF1 BMC (no PF1 VF)')
    # Resolve from this source tree, not a potentially populated output work tree.
    root = Path(__file__).resolve().parents[3]
    board = root / 'ipss/ia840f'
    report = json.loads((board / 'preset_derivation.json').read_text())
    path = 'presets/ia840f_pcie_known_schema.qprs'
    data = (board / path).read_bytes()
    if hashlib.sha256(data).hexdigest() != report['outputs_sha256'][path]:
        raise ValueError('IA840F PCIe source preset hash mismatch')
    preset = ET.fromstring(data).find('.//preset')
    if preset is None or preset.get('kind') != pcie.ip_component:
        raise ValueError('IA840F source preset component mismatch')
    overrides = {n.attrib['name']: n.attrib['value'] for n in preset.findall('parameter')}
    # The donor requests 100 MHz CSR. Quartus 26.1.1 names the enabled
    # port-0 AXI-Lite field core16_*; the legacy unprefixed key is ignored.
    # Translate only this reviewed IA840F contract, without changing the
    # hash-bound donor preset or claiming the PLL's actual frequency is 100.
    legacy_clock = 'axi_lite_clk_freq_user_hwtcl'
    port0_clock = 'core16_axi_lite_clk_freq_user_hwtcl'
    if overrides.get(legacy_clock) != '100':
        raise ValueError('IA840F source preset must request 100 MHz CSR clock')
    overrides[port0_clock] = overrides.pop(legacy_clock)
    pcie.ip_component_params.pop(legacy_clock, None)
    pcie.ip_component_params.update(overrides)
    # BAR2 names/values are now backed by the installed subsystem source.
    # This is not child-IP acceptance or permission to run the toolchain.
    from ia840f_experimental_gate import pcie_context
    pcie_context(pcie)
