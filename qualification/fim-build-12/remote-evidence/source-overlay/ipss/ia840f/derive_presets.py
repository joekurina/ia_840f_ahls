#!/usr/bin/env python3
"""Deterministic XML-to-source derivation only. Never invokes FPGA tools.

Default: compare committed source artifacts in memory. --write: replace ONLY
this directory's presets/*.qprs and preset_derivation.json. No IP generation.
"""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET

NS = {'i': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014',
      'a': 'http://www.altera.com/XMLSchema/IPXact2014/extensions'}
MEM_NAME = 'ia840f_discrete_rdimm_source'
PCIE_NAME = 'ia840f_pf0vf0_pf1_bmc_source'


# Captured installed 26.1.1 schema, not a global vendor-IP default override.
# These hashes identify reviewed evidence; they do not qualify a live installation.
BANK_SPREADING_EVIDENCE = (
    {'source': '/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_msa/declare.tcl',
     'sha256': '9ae7ebc3e99103345563ddd633b2b0f26629c58e7238bd68afc79a823437ef95',
     'lines': '85-87: copies 1/2/4/8; non-derived bank count 0/2/4/8',
     'review_capture': 'baseline/review/captured/18-declare.tcl'},
    {'source': '/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_msa/elaborate.tcl',
     'sha256': 'f939c58f7c4b378faa19d7a4617b0c33ca18f28f29936b0f130dfc9637161c61',
     'lines': '17-18: positive count conflicts with copies greater than one',
     'review_capture': 'baseline/review/captured/19-elaborate.tcl'},
    {'source': '/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_msa/strings/parameters.properties',
     'sha256': '76d0d589373a3c22f0ff7717c771fe7c7e4226d9a539a46f21327c76d910b03c',
     'lines': '17-25: copy capacity and zero means no bank spreading',
     'review_capture': 'baseline/review/captured/20-parameters.properties'},
    {'source': '/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_mem_ss/edit_qsys_fm.tcl',
     'sha256': '409dc24e8fef7cc752a3adbe018ec98cf4065918931917ef63cb6d583c12c551',
     'lines': '191-203: regular DDR4 user control; 375-390: distinct ASSOC_STORAGE branch',
     'review_capture': 'baseline/review/captured/15-edit_qsys_fm.tcl'},
)


def translate_bank_spreading(donor, accepted, instance):
    """Translate exact saved strings; absence is not false. No I/O or mutation."""
    if not {'NUM_BANK_FIFOS', 'NUM_COPIES'}.issubset(accepted):
        raise ValueError(f'{instance}: missing modern bank-count/copies schema')
    flag = donor.get('BANK_SPREADING_EN')
    if 'BANK_SPREADING_EN' in donor and flag not in ('false', 'true'):
        raise ValueError(f'{instance}: invalid BANK_SPREADING_EN: {flag!r}')
    count = donor.get('NUM_BANK_FIFOS')
    if count not in ('0', '2', '4', '8'):
        raise ValueError(f'{instance}: missing or invalid NUM_BANK_FIFOS: {count!r}')
    copies = donor.get('NUM_WRITE_COPIES')
    if copies not in ('1', '2', '4', '8'):
        raise ValueError(f'{instance}: missing or invalid NUM_WRITE_COPIES: {copies!r}')
    if flag == 'true' and count == '0':
        raise ValueError(f'{instance}: enabled bank spreading with zero FIFOs')
    effective = '0' if flag == 'false' else count
    if effective != '0' and copies != '1':
        raise ValueError(f'{instance}: positive bank count conflicts with write copies')
    rule = ('explicit false overrides count to zero' if flag == 'false' else
            'explicit true preserves positive count' if flag == 'true' else
            'absent enable preserves explicit count; enable semantics unresolved')
    record = {
        'raw_source_values': {'BANK_SPREADING_EN': flag, 'NUM_BANK_FIFOS': count,
                              'NUM_WRITE_COPIES': copies},
        'enable_present': 'BANK_SPREADING_EN' in donor,
        'semantics_resolved': flag is not None,
        'count_role': 'inactive saved evidence' if flag == 'false' else 'direct count',
        'output': {'scope': f'mem_ss|{instance}|NUM_BANK_FIFOS', 'value': effective},
        'rule': rule,
        'supporting_sources': [dict(e) for e in BANK_SPREADING_EVIDENCE],
        'qualification': 'saved intent only; no donor generated-behavior, functional, timing or execution qualification',
    }
    return effective, record


def derive(root, vendor):
    inputs = {}
    mappings = {}
    unresolved = {}
    def read(path):
        data = path.read_bytes()
        label = ('vendor/' + str(path.relative_to(vendor)) if path.is_relative_to(vendor)
                 else 'modern/' + str(path.relative_to(root)) if path.is_relative_to(root)
                 else 'evidence/' + str(path.relative_to(root.parent / 'reference')))
        inputs[label] = hashlib.sha256(data).hexdigest()
        return data
    def ip(path):
        tree = ET.fromstring(read(path))
        nodes = tree.findall('.//a:altera_module_parameters/i:parameters/i:parameter', NS)
        result = {}
        for node in nodes:
            name_node = node.find('i:name', NS)
            value_node = node.find('i:value', NS)
            assert name_node is not None and name_node.text is not None and value_node is not None
            key = name_node.text
            if key in result:
                raise ValueError(f'{path}: duplicate module parameter {key}')
            result[key] = value_node.text or ''
        return result
    def preset(path, name):
        node = next(n for n in ET.fromstring(read(path)).findall('.//preset')
                    if n.get('name') == name)
        result = {}
        for parameter in node.findall('parameter'):
            key = parameter.attrib['name']
            if key in result:
                raise ValueError(f'{path}: duplicate preset parameter {key}')
            result[key] = parameter.attrib['value']
        return result
    def xml(presets):
        doc = ET.Element('ip')
        group = ET.SubElement(doc, 'presets', version='12.1')
        for name, kind, values in presets:
            node = ET.SubElement(group, 'preset', name=name, kind=kind, version='All',
                                 board='default', preset_category='IA840F source-only',
                                 description='Vendor-derived candidate; board execution gate remains closed')
            for key, value in sorted(values.items()):
                ET.SubElement(node, 'parameter', name=key, value=str(value))
        ET.indent(doc, space='  ')
        return ET.tostring(doc, encoding='utf-8', xml_declaration=True) + b'\n'
    def automatic(key):
        return key.startswith(('SYS_INFO', 'SYSINFO', 'AUTO_DEVICE', 'AUTO_BOARD',
                               'TRAIT_', 'EX_DESIGN_GUI_'))

    memdir = vendor / 'ipss/mem/qip/mem_ss'
    emif = [ip(memdir / f'ip/mem_ss_fm_0/mem_ss_fm_0_intf_{i}.ip') for i in range(2)]
    msa = [ip(memdir / f'ip/mem_ss_fm_0/mem_ss_fm_0_msa_{i}.ip') for i in range(2)]
    cal = ip(memdir / 'ip/mem_ss_fm_0/mem_ss_fm_0_emif_cal_location_bottom_row.ip')
    # Both vendor channels really connect to the bottom calibration block.
    qsys = ET.fromstring(read(memdir / 'mem_ss_fm_0.qsys'))
    connections = [n.attrib for n in qsys.findall('.//a:connection', NS)]
    for i in range(2):
        assert any(c.get('{'+NS['a']+'}end') == f'intf_{i}.emif_calbus' and
                   c.get('{'+NS['a']+'}start', '').startswith('emif_cal_location_bottom_row.')
                   for c in connections)
    reference = preset(root / 'ipss/mem/qip/presets/mem_presets.qprs', 'iseries-dk-8g-rdimm')
    two = preset(root / 'ipss/mem/qip/presets/mem_presets.qprs', 'iseries-dk-no_dimm')
    mem = {k: v for k, v in reference.items() if '|' not in k}
    mem.update(MEM_INTFS_TYPE='DDR4,DDR4', MEM_INTFS_LOCATION='BOT,BOT',
               APP_INTFS_TYPE='STORAGE,STORAGE')
    for k in mem:
        if k.startswith('MEM_CH_'):
            mem[k] = two[k] if k in ('MEM_CH_0_CONNS', 'MEM_CH_1_CONNS') else '0'
    mappings['memory_topology'] = {'location': 'vendor bottom calibration connections',
        'connections': 'modern iseries-dk-no_dimm two-storage-channel identity mapping',
        'remaining_top_level': 'modern mixed-memory reference defaults, not vendor qualification'}
    for i, source_index in enumerate((0, 2)):
        prefix = f'mem_ss|emif_{source_index}|'
        accepted = {k[len(prefix):] for k in reference if k.startswith(prefix)}
        copied = {k: v for k, v in emif[i].items() if k in accepted and not automatic(k)}
        mem.update({f'mem_ss|emif_{i}|{k}': v for k, v in copied.items()})
        mappings[f'emif_{i}'] = sorted(copied)
        unresolved[f'emif_{i}'] = {k: v for k, v in emif[i].items() if k not in copied}
        # Geometry aliases are explicit, not a bulk prefix substitution.
        aliases = {k: 'DDR4_' + k for k in
                   ('ROW_ADDR_WIDTH', 'COL_ADDR_WIDTH', 'BANK_ADDR_WIDTH', 'BANK_GROUP_WIDTH')}
        aliases.update(RESP_RD_DATA_WIDTH='AMM_DATA_WIDTH', RESP_WR_DATA_WIDTH='AMM_DATA_WIDTH',
                       NUM_COPIES='NUM_WRITE_COPIES')
        accepted_msa = {k.split('|')[-1]: v for k, v in reference.items()
                        if k.startswith(f'mem_ss|msa_{source_index}|') and not automatic(k.split('|')[-1])}
        used = {}
        for key, value in accepted_msa.items():
            source = aliases.get(key, key)
            if source in msa[i] and key != 'AUTO_PRECHARGE':
                value = msa[i][source]
                used[key] = source
            # Modern enum replaces old bool. Preserve modern SS_CONTROLLED,
            # record the unresolved semantic migration instead of bool-casting.
            mem[f'mem_ss|msa_{i}|{key}'] = value
        effective, semantic = translate_bank_spreading(msa[i], accepted_msa, f'msa_{i}')
        source_label = f'vendor/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_{i}.ip'
        semantic.update(source=source_label, source_sha256=inputs[source_label])
        mem[f'mem_ss|msa_{i}|NUM_BANK_FIFOS'] = effective
        # Keep the old unresolved set except the explicitly resolved enable;
        # the overridden count remains evidence in the semantic record, not here.
        unresolved[f'msa_{i}'] = {k: v for k, v in msa[i].items() if k not in used.values()}
        if semantic['semantics_resolved']:
            unresolved[f'msa_{i}'].pop('BANK_SPREADING_EN', None)
        if msa[i].get('BANK_SPREADING_EN') == 'false':
            used.pop('NUM_BANK_FIFOS', None)
        mappings[f'msa_{i}'] = {'vendor_mapping': used,
            'modern_defaults': {k: v for k, v in accepted_msa.items()
                                if k not in used and k != 'NUM_BANK_FIFOS'},
            'bank_spreading_saved_intent': semantic}
    for key in reference:
        if key.startswith('mem_ss|emif_cal_bot|'):
            leaf = key.split('|')[-1]
            if leaf in cal and not automatic(leaf):
                mem[key] = cal[leaf]
    # No calibration-top block and no third channel are copied.
    simref = root / 'ipss/mem/qip/presets/sim_presets.qprs'
    # Vendor's old simulation IP is deliberately inventory-only: TCL=19
    # disagrees with BOTH actual EMIF IPs (TCL=23). Do not copy its derived MR.
    old_model = ip(vendor / 'ipss/mem/qip/ed_sim/ed_sim_mem.ip')
    mappings['old_model_conflict'] = {k: {'old_model': old_model.get(k), 'emif': emif[0].get(k)}
        for k in ('MEM_DDR4_TCL', 'MEM_DDR4_ROW_ADDR_WIDTH', 'MEM_DDR4_TRFC_NS')}
    sims = []
    for i in range(2):
        name = 'iseries-dk-8g-rdimm' + ('_group1' if i else '')
        schema = preset(simref, name)
        model = {k: v for k, v in emif[i].items() if k in schema and not automatic(k)}
        # Explicit generic model aliases for the selected DDR4 protocol.
        aliases = {'MEM_FORMAT_ENUM': 'MEM_DDR4_FORMAT_ENUM',
                   'PHY_MEM_CLK_FREQ_MHZ': 'PHY_DDR4_MEM_CLK_FREQ_MHZ',
                   'PHY_REF_CLK_FREQ_MHZ': 'PHY_DDR4_USER_REF_CLK_FREQ_MHZ',
                   'PHY_RATE_ENUM': 'PHY_DDR4_RATE_ENUM',
                   'PHY_MIMIC_HPS_EMIF': 'PHY_DDR4_MIMIC_HPS_EMIF',
                   'MEM_TTL_DATA_WIDTH': 'MEM_DDR4_DQ_WIDTH',
                   'MEM_DATA_MASK_EN': 'MEM_DDR4_DM_EN'}
        for target, source in aliases.items():
            assert target in schema and source in emif[i]
            model[target] = emif[i][source]
        # Other flattened/derived model fields must be recomputed by the
        # target IP, not guessed. In particular RDIMM latency and mode words.
        mappings[f'sim_{i}'] = {'source_parameters': sorted(model), 'generic_aliases': aliases}
        unresolved[f'sim_{i}_derived_not_transplanted'] = {k: v for k, v in schema.items() if k not in model}
        sims.append((MEM_NAME + ('_group1' if i else ''), 'altera_emif_mem_model', model))

    vendor_pcie = ip(vendor / 'ipss/pcie/qip/pcie_ss.ip')
    schema_path = root / 'ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py'
    tree = ast.parse(read(schema_path))
    dictionaries = {n.targets[0].id: ast.literal_eval(n.value) for n in tree.body
                    if isinstance(n, ast.Assign) and isinstance(n.value, ast.Dict)
                    and isinstance(n.targets[0], ast.Name)}
    pci = {}
    for key, value in dictionaries['default_component_params'].items():
        pci[key] = str(value[0] if isinstance(value, list) else value)
    for func in ('pf0', 'pf1'):
        for group in ('func_params', 'multi_vfs_func_params') if func == 'pf0' else ('func_params',):
            for key, value in dictionaries[group].items():
                key = key.format(func_num=func)
                pci[key] = str(value[0] if isinstance(value, list) else value)
    # Overlay every exact-name vendor key actually exposed by modern schema.
    copied_pcie = {k: vendor_pcie[k] for k in pci if k in vendor_pcie}
    pci.update(copied_pcie)
    # Modern duplicate user fields have explicit equivalent vendor base fields.
    for func in ('pf0', 'pf1'):
        for stem in ('pci_type0_vendor_id', 'revision_id'):
            pci[f'core16_{func}_{stem}_user_hwtcl'] = vendor_pcie[f'core16_{func}_{stem}_hwtcl']
        for bar in (0, 4):
            pci[f'core16_{func}_sriov_vf_bar{bar}_type_user_hwtcl'] = vendor_pcie[f'core16_{func}_sriov_vf_bar{bar}_type_hwtcl']
    # Explicit counts and Gen4x16 workaround from pinned pcie_ip.py.
    read(root / 'ofs-common/tools/ofss_config/pcie_ip.py')
    for key in ('core16_total_pf_count_hwtcl', 'core16_pf0_vf_count_hwtcl', 'core16_pf1_vf_count_hwtcl'):
        pci[key] = vendor_pcie[key]
    pci.update(core16_dwidth_byte_user_hwtcl='64', core16_num_seg_user_hwtcl='2')
    # Board-scoped extension from copied installed Quartus 26.1.1 definitions,
    # NOT additions to the generic OFS Python configuration-key dictionaries.
    # Hash checking and text inspection only: never source/execute these Tcl files.
    evidence = root.parent / 'reference/quartus-26.1.1-pcie'
    evidence_manifest = json.loads(read(evidence / 'manifest.json'))
    evidence_files = {e['path']: e for e in evidence_manifest['files']}
    bar2_evidence = {
        'qhip_hwtcl/intel_pcie_common_core16_parameters.tcl':
            ('7dc7a3eef967a941c9ef3de1b5342d801295626669f8272991b30583cc8059d8',
             '689-702: user fields and width 28; 5018: prefetchable type encoding 1'),
        'qhip_hwtcl/intel_pcie_common_core16_validation_callback.tcl':
            ('9776e38ebaf850244ee935cbe751a2944152c58d5c55b3dc94756a035ac45e73',
             '957-1015: enabled P-Tile endpoint PF BAR user-to-base values; width 28 allowed'),
        'pcie_ss_parameters.tcl':
            ('752416154dc2eebeb37365b924579135d6513a47779326159e0d8921a772e3f0',
             '13582-13626: P-Tile core16 BAR dictionary forwarding'),
        'pcie_ss_fileset.tcl':
            ('25616751a302b3eac05b059dcc2494cf97c5d26d8aa11972195fe9b2549c842b',
             '64-68,146-154: intel_pcie_ptile_ast 11.*.* child and dictionary transfer'),
    }
    for name, (expected, _) in bar2_evidence.items():
        data = read(evidence / 'hwtcl' / name)
        assert hashlib.sha256(data).hexdigest() == expected == evidence_files[name]['sha256']
        assert len(data) == evidence_files[name]['size']
    # TILE is selected by the board/device flow, not this overlay's key subset.
    assert vendor_pcie['TILE'] == 'P-TILE'
    bar2 = {'core16_pf1_bar2_type_user_hwtcl': '64-bit prefetchable memory',
            'core16_pf1_bar2_address_width_user_hwtcl': '28'}
    for key, expected in bar2.items():
        assert vendor_pcie[key] == expected
        pci[key] = vendor_pcie[key]
    copied_pcie.update(bar2)
    mappings['pcie_pf1_bar2_installed_source_schema'] = {
        'tile': 'P-TILE', 'vendor_values': bar2,
        'evidence': {name: {'sha256': digest, 'source_trace': trace}
                     for name, (digest, trace) in bar2_evidence.items()},
        'qualification': 'subsystem source schema resolved; child IP acceptance, generated interfaces and toolchain unqualified',
        'missing_dependencies': ['intel_pcie_ptile_ast 11.*.* child definition',
                                 'external Lampas/WHR helpers', 'rtl/ptile_pciess_top.sv.terp'],
    }
    missing_bars = {k: v for k, v in vendor_pcie.items()
                    if k.startswith(('core16_pf0_', 'core16_pf1_')) and
                    ('_bar' in k) and k not in pci}
    unresolved['pcie_bars_require_modern_schema'] = missing_bars
    unresolved['pcie_other_vendor_parameters'] = {k: v for k, v in vendor_pcie.items() if k not in pci and k not in missing_bars}
    mappings['pcie_exact_vendor_overrides'] = copied_pcie
    mappings['pcie_modern_defaults'] = {k: v for k, v in pci.items() if k not in copied_pcie}
    outputs = {'presets/ia840f_mem.qprs': xml([(MEM_NAME, 'mem_ss', mem)]),
               'presets/ia840f_sim.qprs': xml(sims),
               'presets/ia840f_pcie_known_schema.qprs': xml([(PCIE_NAME, 'intel_pcie_ss_axi', pci)])}
    report = {'format': 1, 'execution_ready': False,
        'status': 'source transformation only; PF1 BAR2 subsystem schema resolved; remaining child-IP, interface and toolchain qualification',
        'inputs_sha256': inputs, 'mappings': mappings, 'unmapped_or_intentionally_not_transplanted': unresolved,
        'output_parameter_counts': {'memory': len(mem), 'simulation': [len(s[2]) for s in sims], 'pcie': len(pci)},
        'outputs_sha256': {k: hashlib.sha256(v).hexdigest() for k, v in outputs.items()}}
    outputs['preset_derivation.json'] = (json.dumps(report, indent=2, sort_keys=True) + '\n').encode()
    return outputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--vendor-root', type=Path, required=True)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    outputs = derive(here.parents[1], args.vendor_root.resolve())
    for name, data in outputs.items():
        path = here / name
        if args.write:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
        else:
            assert path.read_bytes() == data, f'derivation mismatch: {path}'
    print(json.dumps({'source_artifacts': len(outputs), 'match': True, 'execution_ready': False}))


if __name__ == '__main__':
    main()
