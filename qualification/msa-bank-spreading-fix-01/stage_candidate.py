#!/usr/bin/env python3
"""Bounded candidate verification/publication. Never calls vendor tools.

Default compares without writes. --publish publishes only the two derived
candidate artifacts after ALL outputs and baseline evidence pass in memory.
Run only against this isolated package, never against maintained SOURCE.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import xml.etree.ElementTree as ET

P = Path(__file__).resolve().parent
ROOT = P/'candidate/source'
HERE = ROOT/'ipss/ia840f'
CAP = P/'baseline/review/captured'
BASELINE_FILES = {
    'presets/ia840f_mem.qprs': '06-ia840f_mem.qprs',
    'presets/ia840f_sim.qprs': '08-ia840f_sim.qprs',
    'presets/ia840f_pcie_known_schema.qprs': '07-ia840f_pcie_known_schema.qprs',
    'preset_derivation.json': '05-preset_derivation.json',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def verify_inputs():
    manifest = json.loads((P/'remote-before.json').read_text())
    for label, entry in manifest['files'].items():
        data = (P/'baseline'/label).read_bytes()
        require(digest(data)==entry['sha256'] and len(data)==entry['bytes'], 'baseline mismatch: '+label)
    report = json.loads((CAP/'05-preset_derivation.json').read_text())
    for label, expected in report['inputs_sha256'].items():
        kind, rel = label.split('/',1)
        base = {'modern': ROOT, 'vendor': P/'baseline/vendor', 'evidence': P/'candidate/reference'}[kind]
        require(digest((base/rel).read_bytes())==expected,'pinned input mismatch: '+label)
    require(digest((CAP/'10-ofs_top.qsf').read_bytes())=='ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c','Work11 QSF drift')
    return report


def parameter_map(data):
    nodes = ET.fromstring(data).findall('.//parameter')
    values = {n.attrib['name']:n.attrib['value'] for n in nodes}
    require(len(nodes)==len(values),'duplicate output parameters')
    return values


def validate_outputs(outputs, before):
    require(set(outputs)==set(BASELINE_FILES),'output set drift')
    old = parameter_map((CAP/'06-ia840f_mem.qprs').read_bytes())
    new = parameter_map(outputs['presets/ia840f_mem.qprs'])
    require(len(old)==len(new)==2930 and old.keys()==new.keys(),'full memory map drift')
    targets = {f'mem_ss|msa_{i}|NUM_BANK_FIFOS' for i in range(2)}
    changed = {k for k in old if old[k]!=new[k]}
    require(changed==targets,'unexpected semantic delta')
    require(all(old[k]=='8' and new[k]=='0' for k in targets),'expected exact 8->0 delta')
    report=json.loads(outputs['preset_derivation.json'])
    require(report['execution_ready'] is False,'readiness drift')
    require(report['inputs_sha256']==before['inputs_sha256'],'input provenance drift')
    require(report['output_parameter_counts']==before['output_parameter_counts'],'count metadata drift')
    for i in range(2):
        name=f'msa_{i}'
        require(new[f'mem_ss|{name}|NUM_COPIES']=='1','actual board requires copies1')
        rec=report['mappings'][name]['bank_spreading_saved_intent']
        require(rec['raw_source_values']=={'BANK_SPREADING_EN':'false','NUM_BANK_FIFOS':'8','NUM_WRITE_COPIES':'1'},'actual donor intent drift')
        require(rec['source_sha256']==before['inputs_sha256'][rec['source']],'donor source hash mismatch')
        for source in rec['supporting_sources']:
            require(digest((P/source['review_capture']).read_bytes())==source['sha256'],'installed evidence mismatch')
        expected=before['unmapped_or_intentionally_not_transplanted'][name].copy()
        expected.pop('BANK_SPREADING_EN')
        require(report['unmapped_or_intentionally_not_transplanted'][name]==expected,'unresolved evidence drift')
        expected_mapping=before['mappings'][name]['vendor_mapping'].copy()
        expected_mapping.pop('NUM_BANK_FIFOS')
        require(report['mappings'][name]['vendor_mapping']==expected_mapping,'direct mappings drift')
        require(report['mappings'][name]['modern_defaults']==before['mappings'][name]['modern_defaults'],'modern defaults drift')
    for group in ('mappings','unmapped_or_intentionally_not_transplanted'):
        require(report[group].keys()==before[group].keys(),'provenance group drift')
        for key,value in before[group].items():
            if key not in ('msa_0','msa_1'):
                require(report[group][key]==value,'unrelated provenance drift: '+key)
    for name,cap in BASELINE_FILES.items():
        if name not in ('preset_derivation.json','presets/ia840f_mem.qprs'):
            require(outputs[name]==(CAP/cap).read_bytes(),'non-memory preset drift: '+name)
        if name!='preset_derivation.json':
            require(report['outputs_sha256'][name]==digest(outputs[name]),'output hash mismatch')
    return [{'name':k,'before':old[k],'after':new[k]} for k in sorted(changed)]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--publish',action='store_true')
    args=parser.parse_args()
    before=verify_inputs()
    spec=importlib.util.spec_from_file_location('candidate_derivation',HERE/'derive_presets.py')
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    outputs=module.derive(ROOT,P/'baseline/vendor')
    require(outputs==module.derive(ROOT,P/'baseline/vendor'),'non-deterministic derivation')
    delta=validate_outputs(outputs,before)
    if args.publish:
        # All data has passed validation before the first output write.
        for name in ('presets/ia840f_mem.qprs','preset_derivation.json'):
            (HERE/name).write_bytes(outputs[name])
    for name,data in outputs.items():
        require((HERE/name).read_bytes()==data,'stale candidate: '+name)
    print(json.dumps({'mode':'publish' if args.publish else 'compare-only','memory_parameter_count':2930,
                      'changes':delta,'execution_ready':False,
                      'outputs_sha256':{name:digest(data) for name,data in outputs.items()}},indent=2))


if __name__=='__main__':
    main()
