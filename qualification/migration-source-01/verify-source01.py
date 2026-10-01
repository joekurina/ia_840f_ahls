#!/usr/bin/env python3
"""Read-only verification of the source migration, not a native build gate."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
E = Path(__file__).resolve().parent


def sha(path):
    data = str(path.readlink()).encode() if path.is_symlink() else path.read_bytes()
    return hashlib.sha256(data).hexdigest()


def git(cwd, *args):
    return subprocess.check_output(['git', *args], cwd=cwd, text=True).strip()


def main():
    output = E / 'static-checks01.json'
    assert not output.exists(), 'preserve previous verification'
    m = json.loads((E / 'vendor01/manifest.json').read_text())
    checks = {'changed_file_count': len(m['changes']), 'syntax': [], 'checks': {},
              'native_build_run': False, 'simulation_run': False, 'hardware_run': False}
    for row in m['changes']:
        p = ROOT / row['path']
        assert sha(p) == row['new_sha256'], row['path']
        if p.suffix in ('.ip', '.qsys'):
            ET.fromstring(p.read_bytes())
            checks['syntax'].append({'path': row['path'], 'kind': 'XML', 'pass': True})
        elif p.suffix == '.py':
            ast.parse(p.read_text(), filename=str(p))
            checks['syntax'].append({'path': row['path'], 'kind': 'Python AST', 'pass': True})
        elif p.suffix == '.sh':
            x = subprocess.run(['bash', '-n', str(p)], capture_output=True, text=True)
            checks['syntax'].append({'path': row['path'], 'kind': 'bash -n', 'rc': x.returncode,
                                     'stderr': x.stderr})
            assert x.returncode == 0, checks['syntax'][-1]
    preserved = {p: ident for p, ident in m['preserved'].items() if p != 'sources.lock.json'}
    assert all(sha(ROOT / p) == v['sha256'] for p, v in preserved.items())
    checks['preserved_inventory_count'] = len(preserved)
    lock = json.loads((ROOT / 'sources.lock.json').read_text())
    fim = ROOT / 'ofs-agx7-pcie-attach'
    common = fim / 'ofs-common'
    pim = ROOT / 'ofs-platform-afu-bbb'
    checks['pins'] = {n: git(p, 'rev-parse', 'HEAD') for n, p in
                      [('fim', fim), ('common', common), ('pim', pim)]}
    assert checks['pins']['fim'] == lock['repositories']['ofs-agx7-pcie-attach']['commit']
    assert checks['pins']['common'] == lock['repositories']['ofs-agx7-pcie-attach']['submodules']['ofs-common']['commit']
    assert checks['pins']['pim'] == lock['repositories']['ofs-platform-afu-bbb']['commit']
    assert git(fim, 'ls-tree', checks['pins']['fim'], 'ofs-common').split()[2] == checks['pins']['common']
    assert lock['fim_release'] == 'ofs-2026.1-1'
    assert not any(lock['execution_policy'].values())
    samples = ROOT.parents[1] / 'hls-samples'
    sample_head = git(samples, 'rev-parse', '2026.1.0^{commit}')
    assert sample_head == '0abae6d78af5daca3fe5d67e617ab037e58aff89'
    checks['pins']['hls_samples_tag'] = sample_head
    for key, rel in {
        'pr_slot': 'src/fpga_family/agilex/port_gasket/pr_slot.sv',
        'afu_main': 'src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv',
        'pim_port': 'src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv',
    }.items():
        data = (common / rel).read_text()
        assert 'pr_freeze_to_afu' in data, rel
        checks['checks'][key] = {'sha256': sha(common / rel), 'signal_present': True}
    assert 'assign plat_ifc.pr_freeze_to_afu_in = pr_freeze_to_afu;' in (common / 'src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv').read_text()
    assert 'logic pr_freeze_to_afu_in;' in (pim / 'plat_if_develop/ofs_plat_if/src/rtl/ofs_plat_if.template.sv').read_text()
    sdc = fim / 'syn/shared_config/top.sdc'
    assert sha(sdc) == 'b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc'
    assert 'freq = 470' in (fim / 'tools/ofss_config/iopll/iopll_470MHz.ofss').read_text()
    checks['checks']['clock_sources_unchanged'] = True
    checks['checks']['pci_constraint_choice'] = 'UNANSWERED: retaining source does not select compile route'
    checks['protected_refs'] = {ref: git(ROOT, 'rev-parse', ref) for ref in
                               ('main', 'origin/main', 'ia840f-caps03-v1.1.0^{}')}
    assert checks['protected_refs']['main'] == '141b9a4d064dd96f0974c5d2db498aacc602b00e'
    assert checks['protected_refs']['origin/main'] == checks['protected_refs']['main']
    assert checks['protected_refs']['ia840f-caps03-v1.1.0^{}'] == 'c3ddf9f595b68a022ab46008ccd4bdf0e7575e1b'
    checks['success'] = True
    output.write_text(json.dumps(checks, indent=2) + '\n')
    print(json.dumps({k: v for k, v in checks.items() if k != 'syntax'}, indent=2))
    print('syntax_checks', len(checks['syntax']))


if __name__ == '__main__':
    main()
