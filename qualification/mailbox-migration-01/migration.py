#!/usr/bin/env python3
"""Scratch-only, single-use stages. No vendor execution on import or inspection.
Binding records are review receipts, not a security boundary against their owner.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

N = Path('/home/uwb_student00/ahls/new_BSP')
ROOT = N / 'qualification/mailbox-migration-01/scratch'
SOURCE = N / 'ofs-agx7-pcie-attach/ipss/ia840f/bwbmc'
HERE = Path(__file__).absolute().parent
PART = 'AGFB027R25A2E2V'
REV = 'mailbox_migration'
LEAF = 'ip/bmc_spi_sub/sdm_mailbox.ip'
TARGETS = {'bmc_spi_sub.qsys': 'sdm_mailbox', 'bw_840_support.qsys': 'bmc_spi_sub_0'}
PARAMS = dict(DEVICE_FAMILY='Agilex 7', CMD_FIFO_DEPTH='1024', RSP_FIFO_DEPTH='1024',
              URG_FIFO_DEPTH='4', CMD_USE_MEMORY_BLOCKS='1', RSP_USE_MEMORY_BLOCKS='1',
              URG_USE_MEMORY_BLOCKS='1', DEBUG='0', HAS_URGENT='0', HAS_STREAM='0',
              HAS_OFFLOAD='0', HAS_STATUS='1', STREAM_WIDTH='32',
              CRYPTO_MEMORY_TIMEOUT_VALUE='10000', AUTO_DEVICE=PART,
              AUTO_DEVICE_SPEEDGRADE='2')
QPF = 'PROJECT_REVISION = "mailbox_migration"\n'
QSF = 'set_global_assignment -name FAMILY "Agilex 7"\nset_global_assignment -name DEVICE AGFB027R25A2E2V\n'
TOOLS = {k: '/opt/altera/26.1.1/qsys/bin/' + k for k in ('qsys-generate', 'qsys-script')}
CATALOG = {
'altera_s10_mailbox_client_hw.tcl': 'e20fc216fb32613026c8da82e7081242dabb3ff3f0fb4c63db8a93660106973f',
'altera_s10_mailbox_client_core_hw.tcl': 'bb8a89c2068a5381c405e5b9480fbdbe46b69457f78586a3a809d0a21d07eda1',
'altera_s10_mailbox_client_core.sv': '12692f551cb0a4e22e9dbfa5077b8a0b259826892a9cce613d09d574ea2a3ede',
'altera_s10_mailbox_client_sw.tcl': 'a20eac89555eadb2ae681eff42553711ce7fcb3881359e7ab3f7484a977cb00f'}


def require(ok, message):
    if not ok:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def packed(value):
    return json.dumps(value, sort_keys=True, indent=2).encode() + b'\n'


def no_links(path):
    path = Path(path)
    require(path.is_absolute() and '..' not in path.parts, 'absolute lexical path required')
    for p in [path, *path.parents]:
        require(not p.is_symlink(), 'symlink: ' + str(p))
    return path


def read(path):
    p = no_links(path)
    require(p.is_file(), 'missing regular file: ' + str(p))
    return p.read_bytes()


def inventory(root):
    no_links(root)
    result = {}
    for base, dirs, files in os.walk(root, followlinks=False):
        for name in dirs:
            no_links(Path(base) / name)
        for name in files:
            p = Path(base) / name
            result[str(p.relative_to(root))] = digest(read(p))
    return dict(sorted(result.items()))


def scratch_snapshot(root):
    """Preflight state, including empty directories; not a concurrent-race sandbox."""
    root = no_links(root)
    for p in (root, *root.parents):
        require(p.is_dir(), 'missing directory: ' + str(p))
    directories, files = [], {}

    def walk_error(exc):
        raise exc

    for base, dirs, names in os.walk(root, followlinks=False, onerror=walk_error):
        for name in dirs:
            p = no_links(Path(base) / name)
            require(p.is_dir(), 'not a directory: ' + str(p))
            directories.append(str(p.relative_to(root)))
        for name in names:
            p = Path(base) / name
            files[str(p.relative_to(root))] = digest(read(p))
    return {'directories': sorted(directories), 'files': dict(sorted(files.items()))}


def write_new(path, data):
    no_links(path)
    with open(path, 'xb') as f:
        f.write(data)


def local(e):
    return e.tag.split('}')[-1]


def child(e, name):
    return next((c for c in e if local(c) == name), None)


def text(e, name):
    c = child(e, name)
    return '' if c is None else (c.text or '').strip()


def params(e):
    out = {}
    for p in e.iter():
        if local(p) == 'parameter' and 'parameterId' in p.attrib:
            k = p.attrib['parameterId']
            require(k not in out, 'duplicate parameter ' + k)
            out[k] = text(p, 'value')
    return out


def canonical(e):
    """Preserve namespaces, ordering and every attribute; decode escaped XML."""
    t = (e.text or '').strip()
    if t.startswith('<'):
        t = canonical(ET.fromstring(t))
    return [e.tag, sorted(e.attrib.items()), t, [canonical(c) for c in e]]


def module_name(e):
    info = child(e, 'entity_info')
    return text(info, 'library') if info is not None else ''


def snapshot(data):
    r = ET.fromstring(data)
    decoded = {}
    for p in r.iter():
        if local(p) == 'parameter' and text(p, 'value').startswith('<'):
            key = p.attrib.get('parameterId', '')
            decoded.setdefault(key, []).append(canonical(ET.fromstring(text(p, 'value'))))
    return {'xml': canonical(r), 'decoded': decoded}


def target_module(r, name):
    found = [e for e in r.iter() if local(e) == 'module' and module_name(e) == name]
    require(len(found) == 1, 'missing/duplicate target module ' + name)
    return found[0]


def protected_system(data, target):
    r = ET.fromstring(data)
    m = target_module(r, target)
    retained = params(m)['logicalView']
    # Only target payload may change; all connections, addresses, IRQ/reset,
    # top-level boundaries, device metadata and other module records remain.
    for p in r.iter():
        if m in list(p):
            p.remove(m)
            break
    return {'rest': canonical(r), 'logicalView': retained,
            'proxy_kind': canonical(child(m, 'entity_info'))}


def check_settings(data):
    r = ET.fromstring(data)
    mp = next(e for e in r.iter() if local(e) == 'altera_module_parameters')
    actual = params(mp)
    require(actual == PARAMS, 'mailbox parameter set/value drift (including hidden parameters)')
    sp = params(next(e for e in r.iter() if local(e) == 'altera_system_parameters'))
    require(all(sp.get(k) == v for k, v in {
        'device': PART, 'deviceFamily': 'Agilex 7', 'deviceSpeedGrade': '2'}.items()), 'device drift')
    return actual


def wait_port(boundary):
    interfaces = [e for e in boundary.iter() if local(e) == 'interface' and text(e, 'name') == 'avmm']
    require(len(interfaces) == 1, 'missing AVMM boundary')
    ports = {text(e, 'role'): e for e in interfaces[0].iter() if local(e) == 'port'}
    require(set(ports) == {'address', 'write', 'writedata', 'read', 'readdata', 'readdatavalid', 'waitrequest'}, 'AVMM roles drift')
    p = ports['waitrequest']
    require(all(text(p, k) == v for k, v in dict(name='avmm_waitrequest', role='waitrequest',
        direction='Output', width='1', lowerBound='0', vhdlType='STD_LOGIC').items()), 'invalid waitrequest')
    # Existing boundaries carry terminationValue=0 even on nonterminated ports.
    require(not any(local(e).lower() in ('terminated', 'isterminated', 'termination') and
                    (e.text or '').strip().lower() not in ('', 'false', '0') for e in p.iter()), 'terminated waitrequest')


def check_leaf(data):
    check_settings(data)
    r = ET.fromstring(data)
    info = next(e for e in r.iter() if local(e) == 'entity_info')
    require(text(info, 'name') == 'altera_s10_mailbox_client' and text(info, 'version') == '23.0.0', 'public catalog resolution drift')
    require(text(r, 'version') == '23.0.0', 'leaf version drift')
    require(any(local(e) == 'moduleName' and e.text == 'altera_s10_mailbox_client' for e in r.iter()), 'moduleName drift')
    locked = [text(p, 'value') for p in r.iter() if p.attrib.get('parameterId') == 'lockedInterfaceDefinition']
    require(len(locked) == 1, 'locked boundary missing')
    wait_port(ET.fromstring(locked[0]))
    bus = next(e for e in r.iter() if local(e) == 'busInterface' and text(e, 'name') == 'avmm')
    require(any(local(e) == 'portMap' and text(child(e, 'logicalPort'), 'name') == 'waitrequest' and
                text(child(e, 'physicalPort'), 'name') == 'avmm_waitrequest' for e in bus.iter()), 'IPXACT waitrequest mapping missing')
    model = next(e for e in r.iter() if local(e) == 'model')
    p = next(e for e in model.iter() if local(e) == 'port' and text(e, 'name') == 'avmm_waitrequest')
    require(any(local(e) == 'direction' and e.text == 'out' for e in p.iter()), 'physical waitrequest not output')
    vectors = [e for e in p.iter() if local(e) == 'vector']
    require(not vectors or all(text(e, 'left') == '0' and text(e, 'right') == '0' for e in vectors), 'physical waitrequest width')
    require(any(local(e) == 'port_mapping' and {k.split('}')[-1]: v for k, v in e.attrib.items()} ==
        {'name': 'avmm_waitrequest', 'internal': 'avmm_waitrequest'} for e in r.iter()), 'boundary mapping missing')


def retain_ports(old, new):
    """No old clock/reset/IRQ/data/address/valid role may be removed or edited."""
    old_nodes = [canonical(e) for e in old.iter() if local(e) in ('port', 'portMap', 'port_mapping')]
    new_nodes = [canonical(e) for e in new.iter() if local(e) in ('port', 'portMap', 'port_mapping')]
    require(all(e in new_nodes for e in old_nodes), 'existing port/mapping drift')


def check_leaf_delta(old, new):
    a, b = ET.fromstring(old), ET.fromstring(new)
    retain_ports(a, b)
    for key in ('lockedInterfaceDefinition',):
        ap = next(text(e, 'value') for e in a.iter() if e.attrib.get('parameterId') == key)
        bp = next(text(e, 'value') for e in b.iter() if e.attrib.get('parameterId') == key)
        retain_ports(ET.fromstring(ap), ET.fromstring(bp))
    ai = next(e for e in a.iter() if local(e) == 'entity_info')
    bi = next(e for e in b.iter() if local(e) == 'entity_info')
    require(text(ai, 'library') == text(bi, 'library') == 'sdm_mailbox', 'leaf name drift')


def check_proxy(data):
    p = params(target_module(ET.fromstring(data), 'sdm_mailbox'))
    definition = ET.fromstring(p['componentDefinition'])
    require(definition.findtext('originalModuleInfo/className') == 'altera_s10_mailbox_client' and
            definition.findtext('originalModuleInfo/version') == '23.0.0', 'proxy public resolution')
    wait_port(definition)
    wait_port(ET.fromstring(p['defaultBoundary']))


def compare(before, after, phase):
    """Strict nontarget equivalence; target deltas always need human review."""
    errors, changed, semantic = [], [], {}
    allowed = {LEAF} if phase == 'upgrade' else {LEAF, 'bmc_spi_sub.qsys'} if phase == 'child' else {'bw_840_support.qsys'}
    for name, old in before.items():
        new = after.get(name)
        if new == old:
            continue
        changed.append(name)
        if new is None or name not in allowed:
            errors.append('unexpected source change: ' + name)
            continue
        try:
            semantic[name] = {'before': snapshot(old), 'after': snapshot(new)}
            if name in TARGETS:
                require(protected_system(old, TARGETS[name]) == protected_system(new, TARGETS[name]), 'nontarget system/connection/logicalView drift')
                if name == 'bmc_spi_sub.qsys':
                    check_proxy(new)
                    oldp = params(target_module(ET.fromstring(old), 'sdm_mailbox'))
                    newp = params(target_module(ET.fromstring(new), 'sdm_mailbox'))
                    for key in ('componentDefinition', 'defaultBoundary'):
                        retain_ports(ET.fromstring(oldp[key]), ET.fromstring(newp[key]))
                else:
                    # Internal waitrequest must NOT add a board-facing port.
                    oldp = params(target_module(ET.fromstring(old), 'bmc_spi_sub_0'))
                    newp = params(target_module(ET.fromstring(new), 'bmc_spi_sub_0'))
                    require(canonical(ET.fromstring(oldp['defaultBoundary'])) == canonical(ET.fromstring(newp['defaultBoundary'])), 'outer boundary drift')
                    require(canonical(ET.fromstring(oldp['componentDefinition']).find('boundary')) == canonical(ET.fromstring(newp['componentDefinition']).find('boundary')), 'outer component boundary drift')
            if name == LEAF:
                check_leaf(new)
                check_leaf_delta(old, new)
        except (ValueError, ET.ParseError, StopIteration, TypeError) as exc:
            errors.append(name + ': ' + str(exc))
    if phase in ('upgrade', 'child'):
        try:
            check_leaf(after[LEAF])
        except (ValueError, ET.ParseError, StopIteration, KeyError, TypeError) as exc:
            errors.append('saved mailbox: ' + str(exc))
    if phase in ('child', 'parent'):
        try:
            check_proxy(after['bmc_spi_sub.qsys'])
        except (ValueError, ET.ParseError, StopIteration, KeyError, TypeError) as exc:
            errors.append('saved proxy: ' + str(exc))
    return {'phase': phase, 'errors': errors, 'changed': changed, 'semantic_deltas': semantic,
            'accepted': False, 'requires_independent_review': True, 'ready_for_build': False}


def search_path():
    # Literal $, no shell expansion; default catalog closure is separately bound.
    return str(ROOT / 'bwbmc/ip/arbiter') + ',' + str(ROOT / 'bwbmc/ip/irq_generator') + ',$'


def commands():
    common = ['--quartus-project=' + str(ROOT / (REV + '.qpf')), '--rev=' + REV]
    return {
        'upgrade': [TOOLS['qsys-generate'], '--upgrade-ip-cores', 'bmc_spi_sub.qsys',
                    '--batch=./' + LEAF, *common, '--part=' + PART, '--search-path=' + search_path()],
        **{stage: [TOOLS['qsys-script'], *common, '--package-version=26.1', '--search-path=' + search_path(),
                   '--script=' + str(ROOT / (stage + '.tcl'))] for stage in ('child', 'parent')}}


def check_binding(b):
    """All checks here precede any claim, directory, log, or process creation."""
    require(b.get('reviewed') is True and bool(b.get('reviewer')), 'unreviewed binding')
    require(b.get('ready_for_build') is False, 'readiness must remain false')
    require(b.get('root') == str(ROOT) and b.get('source') == str(SOURCE), 'path binding')
    require(b.get('part') == PART and b.get('speed_grade') == '2', 'part binding')
    require(b.get('argv') == commands() and b.get('cwd') == str(ROOT / 'bwbmc'), 'argv/cwd binding')
    require(b.get('qpf') == QPF and b.get('qsf') == QSF and b.get('search_path') == search_path(), 'project/search binding')
    baseline = json.loads(read(HERE / 'source-baseline.json'))
    require(b.get('source_hashes') == baseline['bmc'], 'unreviewed source inventory')
    require(inventory(SOURCE) == b['source_hashes'], 'source inventory drift')
    check_settings(read(SOURCE / LEAF))
    for rel, h in baseline['boundary'].items():
        require(digest(read(N / rel)) == h, 'board reset/IRQ boundary drift')
    for file in ('migration.py', 'child.tcl', 'parent.tcl', 'source-baseline.json'):
        require(digest(read(HERE / file)) == b.get('harness_hashes', {}).get(file), 'harness binding ' + file)
    # All launcher and transitive runtime/catalog files must be enumerated by review.
    for group in ('tool_hashes', 'catalog_hashes', 'evidence_hashes'):
        require(bool(b.get(group)), 'missing ' + group)
        for path, h in b[group].items():
            require(digest(read(Path(path))) == h, group + ' drift: ' + path)
    require(set(TOOLS.values()) <= set(b['tool_hashes']), 'launcher identities missing')
    for name, h in CATALOG.items():
        path = '/opt/altera/26.1.1/ip/altera/pgm/altera_s10_mailbox_client/' + name
        require(b['catalog_hashes'].get(path) == h, 'mailbox catalog binding')
    require(all(b.get(k) is True for k in ('installed_help_reviewed', 'runtime_identity_closure_reviewed',
        'catalog_search_closure_reviewed', 'minimal_project_reviewed', 'api_26_1_reviewed',
        'workstation_instructions_reviewed', 'side_effects_reviewed')), 'unresolved execution assumptions')
    env = b.get('env', {})
    require(env.get('HOME') == str(ROOT / 'home') and env.get('TMPDIR') == str(ROOT / 'tmp') and
            env.get('QUARTUS_ROOTDIR') == '/opt/altera/26.1.1/quartus' and
            env.get('PATH') == '/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/qsys/bin:/usr/bin:/bin', 'environment isolation')
    require(set(env) <= {'HOME', 'TMPDIR', 'QUARTUS_ROOTDIR', 'PATH', 'LM_LICENSE_FILE', 'ALTERAD_LICENSE_FILE', 'LANG'}, 'unreviewed environment key')
    require(os.environ.get('TMUX') and b.get('tmux_session_reviewed') is True, 'named tmux required')
    no_links(ROOT)


def stage(b):
    check_binding(b)
    require(not ROOT.exists(), 'scratch exists: never overwrite/reuse even after failure')
    require(ROOT.parent.is_dir(), 'qualification directory must already exist')
    payload = {name: read(SOURCE / name) for name in b['source_hashes']}
    require({k: digest(v) for k, v in payload.items()} == b['source_hashes'], 'source changed while staging')
    # Exclusive directory creation is the durable claim; no cleanup on failure.
    ROOT.mkdir()
    write_new(ROOT / 'claim.json', packed({'binding_sha256': digest(packed(b)), 'ready_for_build': False}))
    for name, data in payload.items():
        dst = ROOT / 'bwbmc' / name
        dst.parent.mkdir(parents=True, exist_ok=True)
        write_new(dst, data)
    for d in ('home', 'tmp', 'evidence'):
        (ROOT / d).mkdir()
    for name, data in {REV + '.qpf': QPF.encode(), REV + '.qsf': QSF.encode(),
                       'child.tcl': read(HERE / 'child.tcl'), 'parent.tcl': read(HERE / 'parent.tcl')}.items():
        write_new(ROOT / name, data)
    require(inventory(ROOT / 'bwbmc') == b['source_hashes'], 'copy readback drift')
    # Exclude only this snapshot's own bytes to avoid a self-hash.
    write_new(ROOT / 'evidence/staged.json', packed(scratch_snapshot(ROOT)))


def run(b, phase, approval=None):
    check_binding(b)
    # Required runtime/evidence paths and every ancestor must remain directories.
    for name in ('home', 'tmp', 'bwbmc', 'evidence'):
        path = no_links(ROOT / name)
        for directory in (path, *path.parents):
            require(directory.is_dir(), 'missing directory: ' + str(directory))
    require(json.loads(read(ROOT / 'claim.json'))['binding_sha256'] == digest(packed(b)), 'claim binding drift')
    require(read(ROOT / (REV + '.qpf')) == QPF.encode() and read(ROOT / (REV + '.qsf')) == QSF.encode(), 'project drift/callback or reference insertion')
    for name in ('child.tcl', 'parent.tcl'):
        require(read(ROOT / name) == read(HERE / name), 'script drift')
    previous = {'upgrade': None, 'child': 'upgrade', 'parent': 'child'}[phase]
    if previous:
        report_bytes = read(ROOT / ('evidence/' + previous + '-report.json'))
        receipt = json.loads(report_bytes)
        require(not receipt['errors'] and receipt['returncode'] == 0, 'previous stage failed')
        require(approval and approval.get('reviewed') is True and bool(approval.get('reviewer')) and
                approval.get('report_sha256') == digest(report_bytes) and
                approval.get('checks') == {'all_target_deltas': True, 'catalog_resolution': True,
                   'all_logs': True, 'waitrequest_all_representations': True, 'no_unrelated_changes': True}, 'independent semantic/log/catalog approval required')
        require(inventory(ROOT / 'bwbmc') == receipt['after_inventory'], 'post-review source drift')
        expected = receipt.get('scratch_inventory_without_report')
        require(isinstance(expected, dict) and set(expected) == {'directories', 'files'} and
                isinstance(expected['directories'], list) and isinstance(expected['files'], dict),
                'directory-aware prior snapshot required; old receipts are not accepted')
        current = scratch_snapshot(ROOT)
        current['files'].pop('evidence/' + previous + '-report.json', None)
        require(current == expected, 'post-review scratch drift')
    else:
        expected = json.loads(read(ROOT / 'evidence/staged.json'))
        current = scratch_snapshot(ROOT)
        current['files'].pop('evidence/staged.json', None)
        require(current == expected, 'initial staged scratch drift')
        require(inventory(ROOT / 'bwbmc') == b['source_hashes'], 'staged input drift')
    # Each stage is one attempt, even after failure; never chain automatically.
    before = {name: read(ROOT / 'bwbmc' / name) for name in b['source_hashes']}
    token = ROOT / ('evidence/' + phase + '-claim.json')
    write_new(token, packed({'argv': b['argv'][phase], 'approval': approval}))
    write_new(ROOT / ('evidence/' + phase + '-before.json'), packed({k: snapshot(v) for k, v in before.items() if k.endswith(('.ip', '.qsys'))}))
    # Complete raw before bytes archived as hex, not reconstructed XML.
    write_new(ROOT / ('evidence/' + phase + '-bytes.json'), packed({k: v.hex() for k, v in before.items()}))
    rc = None
    exception = None
    with open(ROOT / ('evidence/' + phase + '.log'), 'xb') as log:
        try:
            rc = subprocess.run(b['argv'][phase], cwd=b['cwd'], env=b['env'],
                                stdout=log, stderr=subprocess.STDOUT, check=False).returncode
        except OSError as exc:
            exception = repr(exc)
    after = {name: read(ROOT / 'bwbmc' / name) for name in before if (ROOT / 'bwbmc' / name).exists()}
    report = compare(before, after, phase)
    extra = set(inventory(ROOT / 'bwbmc')) - set(before)
    for name in sorted(extra):
        if name.endswith(('.ip', '.qsys', '.qpf', '.qsf', '_hw.tcl')) or name.startswith(('ip/arbiter/', 'ip/irq_generator/', 'ip/common/')):
            report['errors'].append('new source/catalog/project file: ' + name)
    log_text = read(ROOT / ('evidence/' + phase + '.log')).decode(errors='replace')
    if any(s in log_text for s in ('Critical Warning', 'Error:', 'MAILBOX_MIGRATION_ERROR')):
        report['errors'].append('tool log contains error/critical-warning marker')
    if phase in ('child', 'parent') and 'MAILBOX_' + phase.upper() + '_SAVE_COMPLETE' not in log_text:
        report['errors'].append('Tcl completion marker missing')
    if rc != 0:
        report['errors'].append('vendor returncode ' + str(rc) + ': ' + str(exception))
    if read(ROOT / (REV + '.qpf')) != QPF.encode() or read(ROOT / (REV + '.qsf')) != QSF.encode():
        report['errors'].append('QPF/QSF changed; stop and review, no automatic rebinding')
    try:
        check_binding(b)
    except ValueError as exc:
        report['errors'].append('post-operation binding: ' + str(exc))
    report.update(returncode=rc, after_inventory=inventory(ROOT / 'bwbmc'),
                  scratch_inventory_without_report=scratch_snapshot(ROOT))
    # Next stage compares inventory excluding this one report, avoiding a self-hash.
    write_new(ROOT / ('evidence/' + phase + '-report.json'), packed(report))
    print(json.dumps({'phase': phase, 'errors': report['errors'], 'accepted': False}))
    return report


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=['stage', 'upgrade', 'child', 'parent', 'commands'])
    p.add_argument('--binding')
    p.add_argument('--approval')
    a = p.parse_args()
    if a.action == 'commands':
        print(json.dumps(commands(), indent=2)); return
    require(a.binding is not None, 'binding required')
    b = json.loads(read(Path(a.binding).absolute()))
    if a.action == 'stage':
        stage(b)
    else:
        approval = json.loads(read(Path(a.approval).absolute())) if a.approval else None
        report = run(b, a.action, approval)
        # Persist the report before returning failure; pending review is not failure.
        if report['returncode'] != 0 or report['errors']:
            raise SystemExit(1)


if __name__ == '__main__':
    main()
