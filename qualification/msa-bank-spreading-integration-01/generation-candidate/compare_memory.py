"""Full serialized memory evidence comparison. No Quartus calls or writes.
No metadata is discarded. Every changed XML atom and HDL line is reported.
Only the two scoped saved FIFO values are automatically accepted; generated
metadata/topology deltas remain review-required, never regex-normalized away.
"""
import difflib
import hashlib
import json
from pathlib import Path
import re
import xml.etree.ElementTree as ET


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def xml_atoms(path):
    parser = ET.XMLParser(target=ET.TreeBuilder(insert_comments=True))
    root = ET.parse(path, parser=parser).getroot()
    atoms = {}
    def visit(node, prefix):
        tag = node.tag if isinstance(node.tag, str) else '#comment'
        # Exact namespace-qualified tag, attributes and ordered sibling indices.
        here = prefix + '/' + tag
        atoms[here + '/#exists'] = True
        atoms.update({here + '/@' + k: v for k, v in node.attrib.items()})
        if node.text is not None and (len(node) == 0 or node.text.strip()):
            atoms[here + '/#text'] = node.text
        if node.tail and node.tail.strip():
            atoms[here + '/#tail'] = node.tail
        for i, child in enumerate(node):
            visit(child, here + '/' + str(i))
    visit(root, '')
    return atoms


def differences(a, b):
    return [{'path': k, 'before_present': k in a, 'after_present': k in b,
             'before': a.get(k), 'after': b.get(k)}
            for k in sorted(a.keys() | b.keys()) if a.get(k) != b.get(k) or (k in a) != (k in b)]


def saved_parameters(path):
    root = ET.parse(path).getroot()
    result = {}
    def local(tag): return tag.rsplit('}', 1)[-1]
    def visit(node, scope, parent_tag='', owner_tag=''):
        if local(node.tag) in ('sub_module', 'altera_internal_packaged_subsystem'):
            names = [v for k, v in node.attrib.items() if local(k) == 'name']
            if len(names) != 1: raise ValueError('ambiguous subsystem name')
            scope = scope + (names[0],)
        if local(node.tag) == 'parameter' and parent_tag == 'parameters' and owner_tag in ('sub_module', 'altera_module_parameters'):
            names = [c.text for c in node if local(c.tag) == 'name']
            values = [c.text or '' for c in node if local(c.tag) == 'value']
            if names and values:
                key = '|'.join(scope + (names[0],))
                if key in result: raise ValueError('duplicate parameter ' + key)
                result[key] = values[0]
        for child in node: visit(child, scope, local(node.tag), parent_tag)
    visit(root, ())
    return result


def compare_saved(before, after):
    a, b = saved_parameters(before), saved_parameters(after)
    expected = {f'mem_ss|msa_{n}|NUM_BANK_FIFOS': ('8', '0') for n in (0, 1)}
    delta = differences(a, b)
    semantic_ok = {x['path']: (x['before'], x['after']) for x in delta} == expected
    semantic_ok = semantic_ok and a.keys() == b.keys()
    semantic_ok = semantic_ok and all(b.get(f'mem_ss|msa_{n}|NUM_COPIES') == '1' for n in (0, 1))
    atoms_a, atoms_b = xml_atoms(before), xml_atoms(after)
    changes = differences(atoms_a, atoms_b)
    # The serialized tree must differ at only the two values, not interfaces,
    # hidden metadata, attributes, connections, resets, boundaries or ports.
    serialized_ok = len(changes) == 2 and all(x['before'] == '8' and x['after'] == '0' and x['path'].endswith('value/#text') for x in changes)
    return {'accepted': semantic_ok and serialized_ok, 'semantic_ok': semantic_ok,
            'parameter_counts': [len(a), len(b)], 'parameter_delta': delta,
            'serialized_delta': changes,
            'raw_unified_diff': ''.join(difflib.unified_diff(Path(before).read_text().splitlines(True), Path(after).read_text().splitlines(True), fromfile=str(before), tofile=str(after))),
            'before_parameters': a, 'after_parameters': b}


def wrapper(path):
    text = Path(path).read_text()
    params = re.findall(r'^\s*\.([A-Za-z_][A-Za-z_0-9]*)\s*\(([^\n]*)\)', text, re.M)
    ports = re.findall(r'^\s*(input|output|inout)\s+(?:wire|reg|logic)\s*(\[[^\]]+\])?\s*(\w+)\s*[,;)]', text, re.M)
    if not params or not ports: raise ValueError('unrecognized wrapper ' + str(path))
    # Ordered complete parameter and connection lists, including repeated names.
    return {'ports': ports, 'parameters_and_connections': params,
            'text': text, 'sha256': sha(path)}


def compare_generated(baseline, generated):
    baseline, generated = Path(baseline), Path(generated)
    out = {'accepted': False, 'files': [], 'execution_ready': False}
    old_dirs = [p.name for p in (baseline / 'mem_ss').glob('mem_ss_mem_ss_501_*') if p.is_dir()]
    new_dirs = [p.name for p in (generated / 'mem_ss').glob('mem_ss_mem_ss_501_*') if p.is_dir()]
    path_map = dict(zip(old_dirs, new_dirs)) if len(old_dirs) == len(new_dirs) == 1 else {}
    out['exact_generated_directory_mapping'] = path_map
    for old in sorted(baseline.rglob('*')):
        if not old.is_file() or '/sim/' in str(old): continue
        rel = str(old.relative_to(baseline))
        # Exact relative name first; if UUID changed, enumerate potential matches
        # but do not choose or normalize them automatically.
        mapped = rel
        for old_token, new_token in path_map.items(): mapped = mapped.replace(old_token, new_token)
        new = generated / mapped
        item = {'baseline': rel, 'generated': mapped, 'before_sha256': sha(old)}
        if not new.is_file():
            suffix = old.name.rsplit('_501_', 1)[-1] if '_501_' in old.name else old.name
            item.update(missing=True, candidates=[str(p.relative_to(generated)) for p in generated.rglob('*') if p.is_file() and p.suffix == old.suffix and (p.name.endswith('_msa_0' + old.suffix) if '_msa_0' in suffix else p.name.endswith('_msa_1' + old.suffix) if '_msa_1' in suffix else p.name == old.name)])
        elif old.suffix in ('.ip', '.sopcinfo', '.qsys'):
            item.update(after_sha256=sha(new), all_xml_changes=differences(xml_atoms(old), xml_atoms(new)))
        elif old.suffix in ('.v', '.sv'):
            a, b = wrapper(old), wrapper(new)
            pairs_a = a['parameters_and_connections']; pairs_b = b['parameters_and_connections']
            deltas = differences(dict(enumerate(pairs_a)), dict(enumerate(pairs_b)))
            msa = old.name.endswith(('_msa_0.v', '_msa_1.v'))
            msa_ok = None
            if msa:
                msa_ok = (a['ports'] == b['ports'] and len(deltas) == 1
                          and deltas[0]['before'] == ('NUM_BANK_FIFOS', '8')
                          and deltas[0]['after'] == ('NUM_BANK_FIFOS', '0')
                          and ('NUM_COPIES', '1') in pairs_b)
            item.update(after_sha256=b['sha256'], ports_equal=a['ports'] == b['ports'],
                        msa_zero_copies1_full_map_preserved=msa_ok,
                        complete_parameter_connection_delta=deltas,
                        unified_diff=''.join(difflib.unified_diff(a['text'].splitlines(True), b['text'].splitlines(True), fromfile=rel, tofile=str(new))))
        out['files'].append(item)
    out['generated_inventory'] = {str(p.relative_to(generated)): sha(p) for p in sorted(generated.rglob('*')) if p.is_file()}
    out['status'] = 'Full generated drift report requires independent review; never automatic functional/timing acceptance'
    return out
