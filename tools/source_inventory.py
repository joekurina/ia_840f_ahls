#!/usr/bin/env python3
"""Read-only source consistency inventory. Never configures or builds anything.

Exit zero means only that the pinned sources and inventory are consistent.
It is explicitly NOT a build-readiness, compiler, RTL or hardware result.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect_bsp_contract(errors):
    """Parse declarations only; never execute Tcl, shell, CMake or vendor tools."""
    asp = ROOT / 'oneapi-asp/ia840f'
    env = ET.parse(asp / 'board_env.xml').getroot()
    if env.get('name') != 'ia840f':
        errors.append('Unexpected board environment identity')
    hardware = env.find('hardware')
    if hardware is None or hardware.get('default') != 'ofs_ia840f':
        errors.append('Standard BSP must remain the default variant')
    results = {}
    for name in ('ofs_ia840f', 'ofs_ia840f_usm'):
        board = ET.parse(asp / 'hardware' / name / 'board_spec.xml').getroot()
        if board.get('name') != name:
            errors.append('BSP variant name mismatch: ' + name)
        device = board.find('device')
        if device is None or device.get('device_model') != 'agfb027r25a2e2v_dm.xml':
            errors.append('BSP device model mismatch: ' + name)
        compile_flows = board.findall('compile')
        if not compile_flows:
            errors.append('No declared compilation flow: ' + name)
        for flow in compile_flows:
            for action in ('generate', 'synthesize'):
                node = flow.find(action)
                if node is None or node.get('cmd') != 'sh build/scripts/source-only-stop.sh':
                    errors.append('Missing source-only XML gate: ' + name + '/' + action)
        ddr = board.find("global_mem[@name='device0']")
        banks = [] if ddr is None else ddr.findall('interface')
        if len(banks) != 2 or any(int(b.get('size', '0'), 0) != 0x400000000 for b in banks):
            errors.append('Expected two vendor 16-GiB DDR bank declarations: ' + name)
        host = board.find("global_mem[@name='host']")
        usm = name.endswith('_usm')
        if (host is not None) != usm:
            errors.append('Host-memory declaration disagrees with variant: ' + name)
        if usm and host is not None:
            allocations = {v.strip() for v in host.get('allocation_type', '').split(',')}
            if allocations != {'host', 'shared'}:
                errors.append('USM host/shared allocation declaration changed')
        results[name] = {
            'device_model': None if device is None else device.get('device_model'),
            'ddr_bank_sizes_bytes': [int(b.get('size', '0'), 0) for b in banks],
            'host_memory_declared': host is not None,
            'compile_flows_inspected': len(compile_flows),
        }
    return results


def main():
    errors = []
    bsp_contract = inspect_bsp_contract(errors)
    lock = json.loads((ROOT / 'sources.lock.json').read_text())
    revisions = {}
    for name, entry in lock['repositories'].items():
        paths = [(name, entry)] + [
            (name + '/' + sub, spec)
            for sub, spec in entry.get('submodules', {}).items()
        ]
        for rel, spec in paths:
            actual = subprocess.check_output(
                ['git', '-C', str(ROOT / rel), 'rev-parse', 'HEAD'],
                text=True,
            ).strip()
            revisions[rel] = actual
            if actual != spec['commit']:
                errors.append('Revision mismatch: ' + rel)

    fim = ROOT / 'ofs-agx7-pcie-attach'
    manifest = json.loads(
        (fim / 'syn/board/ia840f/source_manifest.json').read_text()
    )
    entries = manifest['files']
    paths = [e['path'] for e in entries]
    if len(set(paths)) != len(paths):
        errors.append('Duplicate FIM manifest entries')
    if len(entries) != manifest['files_excluding_this_manifest']:
        errors.append('FIM manifest declared count mismatch')
    for entry in entries:
        p = fim / entry['path']
        if not p.is_file() or sha256(p) != entry['sha256']:
            errors.append('FIM file hash mismatch: ' + entry['path'])
        if 'source_sha256' in entry:
            source = Path(entry['source'])
            if not source.is_file() or sha256(source) != entry['source_sha256']:
                errors.append('Board reference changed: ' + entry['source'])

    asp = ROOT / 'oneapi-asp/ia840f'
    asp_files = sorted(p for p in asp.rglob('*') if p.is_file())
    xml_files = []
    for p in asp_files:
        if p.suffix == '.xml':
            ET.parse(p)
            xml_files.append(str(p.relative_to(ROOT)))
        if p.suffix == '.json':
            json.loads(p.read_text())
    candidate_roots = [asp, fim / 'syn/board/ia840f',
                       fim / 'src/board/ia840f', fim / 'ipss/ia840f']
    forbidden = {'.qdb', '.sof', '.gbs', '.rbf', '.rpd', '.aocx', '.o', '.a', '.so'}
    artifacts = sorted(str(p.relative_to(ROOT)) for base in candidate_roots
                       for p in base.rglob('*')
                       if p.is_file() and p.suffix.lower() in forbidden)
    if artifacts:
        errors.append('Unexpected compiled artifacts in candidate board paths')
    if manifest['ready_for_build'] is not False:
        errors.append('FIM source-only gate changed')
    if any(lock['execution_policy'].values()):
        errors.append('Source-only execution policy changed')
    hostpipe_sources = {}
    for rel in ['afu/hostpipe_csr/hostpipe_csr.cpp',
                'afu/hostpipe_csr/CMakeLists.txt', 'docs/host-pipes.md']:
        p = ROOT / rel
        if p.is_file():
            hostpipe_sources[rel] = sha256(p)
        # Historical CSR research is optional and outside the BSP baseline.
        # Its absence must not fail a general-purpose standard/USM inventory.
    result = {
        'check_kind': 'read_only_source_inventory',
        'bsp_declaration_contract': bsp_contract,
        'hostpipe_policy': 'Conditional reference-derived feature; historical experiments are not baseline requirements',
        'csr_hostpipe_candidate_source_sha256': hostpipe_sources,
        'source_consistency': 'pass' if not errors else 'fail',
        'ready_for_build': False,
        'host_pipes_qualified': False,
        'builds_configure_simulations_tests_run': False,
        'revisions': revisions,
        'fim_manifest_entries_checked': len(entries),
        'asp_source_files': len(asp_files),
        'parsed_xml_files': xml_files,
        'compiled_artifacts_in_board_paths': artifacts,
        'unresolved_fim_requirements': manifest['blocking_requirements'],
        'errors': errors,
    }
    print(json.dumps(result, indent=2))
    return 0 if not errors else 1


if __name__ == '__main__':
    sys.exit(main())
