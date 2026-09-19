#!/usr/bin/env python3
"""Inert fixtures only: no Tcl, vendor binaries, remote access, or source writes."""
import copy
from contextlib import contextmanager
import sys
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as E
import migration as m

LOCAL_N = m.HERE.parents[1]
B = LOCAL_N / 'ofs-agx7-pcie-attach/ipss/ia840f/bwbmc'


def upgraded_fixture(data):
    """Synthetic parser fixture, NEVER vendor output or acceptance evidence."""
    r = E.fromstring(data)
    ip = '{http://www.accellera.org/XMLSchema/IPXACT/1685-2014}'
    alt = '{http://www.altera.com/XMLSchema/IPXact2014/extensions}'
    m.child(r, 'version').text = '23.0.0'
    info = next(e for e in r.iter() if m.local(e) == 'entity_info')
    m.child(info, 'version').text = '23.0.0'
    bus = next(e for e in r.iter() if m.local(e) == 'busInterface' and m.text(e, 'name') == 'avmm')
    maps = next(e for e in bus.iter() if m.local(e) == 'portMaps')
    e = E.SubElement(maps, ip + 'portMap')
    for tag, name in [('logicalPort', 'waitrequest'), ('physicalPort', 'avmm_waitrequest')]:
        E.SubElement(E.SubElement(e, ip + tag), ip + 'name').text = name
    model = next(e for e in r.iter() if m.local(e) == 'model')
    ports = next(e for e in model.iter() if m.local(e) == 'ports')
    p = E.SubElement(ports, ip + 'port')
    E.SubElement(p, ip + 'name').text = 'avmm_waitrequest'
    E.SubElement(E.SubElement(p, ip + 'wire'), ip + 'direction').text = 'out'
    locked = next(e for e in r.iter() if e.attrib.get('parameterId') == 'lockedInterfaceDefinition')
    x = E.fromstring(m.text(locked, 'value'))
    add_boundary_port(x)
    m.child(locked, 'value').text = E.tostring(x, encoding='unicode')
    mapping = next(e for e in r.iter() if m.local(e) == 'interface_mapping')
    E.SubElement(mapping, alt + 'port_mapping', {alt+'name': 'avmm_waitrequest', alt+'internal': 'avmm_waitrequest'})
    return E.tostring(r)


def add_boundary_port(x):
    interface = next(e for e in x.iter() if m.local(e) == 'interface' and m.text(e, 'name') == 'avmm')
    p = E.SubElement(m.child(interface, 'ports'), 'port')
    for k, v in dict(name='avmm_waitrequest', role='waitrequest', direction='Output',
                     width='1', lowerBound='0', vhdlType='STD_LOGIC').items():
        E.SubElement(p, k).text = v


def proxy_fixture(data):
    r = E.fromstring(data)
    mod = m.target_module(r, 'sdm_mailbox')
    for e in mod.iter():
        if e.attrib.get('parameterId') in ('componentDefinition', 'defaultBoundary'):
            x = E.fromstring(m.text(e, 'value'))
            add_boundary_port(x)
            v = x.find('originalModuleInfo/version')
            if v is not None:
                v.text = '23.0.0'
            m.child(e, 'value').text = E.tostring(x, encoding='unicode')
    return E.tostring(r)


class Semantics(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.before = {p: (B/p).read_bytes() for p in m.inventory(B)}
        cls.upgraded = upgraded_fixture(cls.before[m.LEAF])

    def test_full_source_inventory_and_settings(self):
        baseline = json.loads((m.HERE/'source-baseline.json').read_text())
        self.assertEqual(m.inventory(B), baseline['bmc'])
        self.assertEqual(len(self.before), 34)
        self.assertEqual(sum(k.endswith('.ip') for k in self.before), 24)
        self.assertEqual(m.check_settings(self.before[m.LEAF]), m.PARAMS)
        for p, h in baseline['boundary'].items():
            self.assertEqual(m.digest((LOCAL_N/p).read_bytes()), h)

    def test_decoded_snapshot_not_opaque_xml(self):
        s = m.snapshot(self.before['bmc_spi_sub.qsys'])
        self.assertEqual(len(s['decoded']['componentDefinition']), 17)
        self.assertEqual(len(s['decoded']['defaultBoundary']), 17)

    def test_old_leaf_rejected_despite_zero_assumed_exit(self):
        self.assertTrue(m.compare(self.before, self.before, 'upgrade')['errors'])

    def test_synthetic_upgrade_pending_review(self):
        after = dict(self.before, **{m.LEAF: self.upgraded})
        r = m.compare(self.before, after, 'upgrade')
        self.assertEqual(r['errors'], [])
        self.assertFalse(r['accepted'])
        self.assertTrue(r['requires_independent_review'])

    def test_all_parameter_mutations_rejected(self):
        for key in m.PARAMS:
            with self.subTest(key=key):
                r = E.fromstring(self.upgraded)
                p = next(e for e in r.iter() if e.attrib.get('parameterId') == key)
                m.child(p, 'value').text = 'WRONG'
                with self.assertRaises(ValueError):
                    m.check_leaf(E.tostring(r))

    def test_hidden_parameter_addition_rejected(self):
        r = E.fromstring(self.upgraded)
        p = next(e for e in r.iter() if e.attrib.get('parameterId') == 'DEBUG')
        p.attrib['parameterId'] = 'NEW_HIDDEN'
        with self.assertRaises(ValueError):
            m.check_leaf(E.tostring(r))

    def test_unrelated_leaf_and_custom_rtl_rejected(self):
        for name in ['ip/bmc_spi_sub/sdm_pipeline.ip', 'ip/irq_generator/irq_generator.v']:
            with self.subTest(name=name):
                after = dict(self.before, **{m.LEAF: self.upgraded, name: self.before[name]+b'\n'})
                self.assertTrue(m.compare(self.before, after, 'upgrade')['errors'])

    def test_parent_not_upgraded_by_leaf_stage(self):
        after = dict(self.before, **{m.LEAF: self.upgraded})
        after['bmc_spi_sub.qsys'] += b'\n'
        self.assertTrue(m.compare(self.before, after, 'upgrade')['errors'])

    def test_targeted_child_synthetic(self):
        before = dict(self.before, **{m.LEAF: self.upgraded})
        after = dict(before, **{'bmc_spi_sub.qsys': proxy_fixture(before['bmc_spi_sub.qsys'])})
        self.assertEqual(m.compare(before, after, 'child')['errors'], [])

    def test_stale_child_rejected(self):
        before = dict(self.before, **{m.LEAF: self.upgraded})
        self.assertTrue(m.compare(before, before, 'child')['errors'])

    def test_connection_and_logical_path_drift(self):
        for old, new in [(b'0x0000', b'0x0040'), (b'sdm_reset.out_reset', b'system_rst_bridge.out_reset'),
                         (b'ip/bmc_spi_sub/sdm_mailbox.ip', b'/original/sdm_mailbox.ip')]:
            with self.subTest(old=old):
                data = self.before['bmc_spi_sub.qsys']
                self.assertIn(old, data)
                self.assertNotEqual(m.protected_system(data, 'sdm_mailbox'),
                                    m.protected_system(data.replace(old, new), 'sdm_mailbox'))

    def test_lost_old_port_rejected(self):
        bad = self.upgraded.replace(b'avmm_readdatavalid', b'avmm_wrong_valid')
        with self.assertRaises(ValueError):
            m.check_leaf_delta(self.before[m.LEAF], bad)

    def test_no_waitrequest_or_wrong_width_rejected(self):
        for data in [self.upgraded.replace(b'avmm_waitrequest', b'wrong_waitrequest'),
                     self.upgraded.replace(b'&lt;width&gt;1&lt;/width&gt;', b'&lt;width&gt;2&lt;/width&gt;')]:
            with self.assertRaises((ValueError, StopIteration)):
                m.check_leaf(data)


class BindingAndStaging(unittest.TestCase):
    def setUp(self):
        self.base = json.loads((m.HERE/'source-baseline.json').read_text())
        self.mapping = {str(m.SOURCE/k): (B/k).read_bytes() for k in self.base['bmc']}
        self.mapping.update({str(m.N/k): (LOCAL_N/k).read_bytes() for k in self.base['boundary']})
        self.mapping.update({str(m.HERE/k): (m.HERE/k).read_bytes() for k in ['migration.py','source-baseline.json','child.tcl','parent.tcl']})
        # Explicit inert identities: never executed and never vendor evidence.
        for t in m.TOOLS.values():
            self.mapping[t] = b'INERT TEST TOOL IDENTITY'
        catalogs = {}
        for name in m.CATALOG:
            p = '/opt/altera/26.1.1/ip/altera/pgm/altera_s10_mailbox_client/' + name
            self.mapping[p] = (LOCAL_N/'qualification/ipgen-03/installed-mailbox-source'/name).read_bytes()
            catalogs[p] = m.digest(self.mapping[p])
        evidence = str(LOCAL_N/'qualification/ipgen-03/installed-refresh-tool-discovery.json')
        self.mapping[evidence] = Path(evidence).read_bytes()
        self.b = dict(reviewed=True, reviewer='INERT FIXTURE', ready_for_build=False, root=str(m.ROOT),
            source=str(m.SOURCE), part=m.PART, speed_grade='2', argv=m.commands(), cwd=str(m.ROOT/'bwbmc'),
            qpf=m.QPF,qsf=m.QSF,search_path=m.search_path(),source_hashes=self.base['bmc'],
            harness_hashes={k:m.digest(self.mapping[str(m.HERE/k)]) for k in ['migration.py','source-baseline.json','child.tcl','parent.tcl']},
            tool_hashes={v:m.digest(self.mapping[v]) for v in m.TOOLS.values()},catalog_hashes=catalogs,
            evidence_hashes={evidence:m.digest(self.mapping[evidence])},
            env={'HOME':str(m.ROOT/'home'),'TMPDIR':str(m.ROOT/'tmp'),'QUARTUS_ROOTDIR':'/opt/altera/26.1.1/quartus',
                 'PATH':'/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/qsys/bin:/usr/bin:/bin'})
        for k in ('installed_help_reviewed','runtime_identity_closure_reviewed','catalog_search_closure_reviewed',
                  'minimal_project_reviewed','api_26_1_reviewed','workstation_instructions_reviewed',
                  'side_effects_reviewed','tmux_session_reviewed'):
            self.b[k] = True

    def check(self, b):
        with patch.object(m, 'read', side_effect=lambda p: self.mapping[str(p)]), \
             patch.object(m, 'inventory', return_value=self.base['bmc']), \
             patch.dict(m.os.environ, {'TMUX':'INERT TEST SESSION'}):
            m.check_binding(b)

    def test_positive_inert_binding(self):
        self.check(self.b)

    def test_binding_mutations(self):
        changes = {'reviewed':False,'ready_for_build':True,'part':'WRONG','speed_grade':'1',
                   'root':'/tmp/bypass','source':'/tmp/source','qsf':m.QSF+'source FIM.tcl\n',
                   'catalog_hashes':{},'tool_hashes':{},'harness_hashes':{},'evidence_hashes':{},
                   'api_26_1_reviewed':False,'env':{},'search_path':'$','source_hashes':{}}
        for key, val in changes.items():
            with self.subTest(key=key):
                b=copy.deepcopy(self.b);b[key]=val
                with self.assertRaises(ValueError): self.check(b)

    def test_tool_and_catalog_hash_mutations(self):
        for group in ('tool_hashes','catalog_hashes','evidence_hashes'):
            b=copy.deepcopy(self.b);b[group][next(iter(b[group]))]='0'*64
            with self.assertRaises(ValueError):self.check(b)

    def test_extra_or_bypass_argv_rejected(self):
        for flag in ('--bypass-quartus-project','--synthesis=VERILOG','--batch=unrelated.ip'):
            b=copy.deepcopy(self.b);b['argv']['upgrade'].append(flag)
            with self.assertRaises(ValueError): self.check(b)

    def test_unreviewed_rejects_before_writes(self):
        with patch.object(m, 'write_new') as write, patch.object(m.subprocess, 'run') as run:
            with self.assertRaises(ValueError): m.stage({'reviewed':False})
            write.assert_not_called();run.assert_not_called()

    def test_non_symlink_exclusive_staging_no_overwrite(self):
        with tempfile.TemporaryDirectory(prefix='mailbox-inert-') as d:
            root=Path(d)/'scratch'
            # Only the binding checker is mocked here; it is tested independently.
            with patch.object(m,'ROOT',root),patch.object(m,'SOURCE',B),patch.object(m,'check_binding'), \
                 patch.object(m.subprocess,'run') as run:
                m.stage(self.b)
                self.assertEqual(m.inventory(root/'bwbmc'),self.base['bmc'])
                self.assertEqual((root/(m.REV+'.qsf')).read_text(),m.QSF)
                with self.assertRaises(ValueError):m.stage(self.b)
                self.assertTrue((root/'claim.json').exists())
                run.assert_not_called()

    def test_symlinks_rejected(self):
        with tempfile.TemporaryDirectory(prefix='mailbox-inert-') as d:
            p=Path(d);(p/'target').write_bytes(b'inert');(p/'link').symlink_to(p/'target')
            with self.assertRaises(ValueError):m.read(p/'link')
            with self.assertRaises(ValueError):m.inventory(p)

    def test_failed_scratch_claim_preserved(self):
        with tempfile.TemporaryDirectory(prefix='mailbox-inert-') as d:
            root=Path(d)/'scratch'
            original=m.write_new
            def fail_after_claim(path,data):
                if path.name!='claim.json': raise OSError('inert injected copy failure')
                original(path,data)
            with patch.object(m,'ROOT',root),patch.object(m,'SOURCE',B),patch.object(m,'check_binding'), \
                 patch.object(m,'write_new',side_effect=fail_after_claim):
                with self.assertRaises(OSError):m.stage(self.b)
                self.assertTrue((root/'claim.json').exists())
                with self.assertRaises(ValueError):m.stage(self.b)

    def test_mocked_three_stage_sequence_requires_review(self):
        # subprocess.run is intercepted; fixture XML is labelled synthetic.
        with tempfile.TemporaryDirectory(prefix='mailbox-inert-') as d:
            root=Path(d)/'scratch'
            b=copy.deepcopy(self.b)
            with patch.object(m,'ROOT',root),patch.object(m,'SOURCE',B),patch.object(m,'check_binding'):
                m.stage(b)
                def fake_run(argv, **kw):
                    if '--upgrade-ip-cores' in argv:
                        p=root/'bwbmc'/m.LEAF
                        p.write_bytes(upgraded_fixture(p.read_bytes()))
                    elif any('child.tcl' in arg for arg in argv):
                        p=root/'bwbmc/bmc_spi_sub.qsys'
                        p.write_bytes(proxy_fixture(p.read_bytes()))
                        kw['stdout'].write(b'MAILBOX_CHILD_SAVE_COMPLETE\n')
                    else:
                        kw['stdout'].write(b'MAILBOX_PARENT_SAVE_COMPLETE\n')
                    return m.subprocess.CompletedProcess(argv,0)
                with patch.object(m.subprocess,'run',side_effect=fake_run) as proc:
                    m.run(b,'upgrade')
                    self.assert_report_snapshot(root, 'upgrade')
                    with self.assertRaises(ValueError):m.run(b,'child')
                    self.assertFalse((root/'evidence/child-claim.json').exists())
                    for previous,phase in [('upgrade','child'),('child','parent')]:
                        path=root/('evidence/'+previous+'-report.json')
                        self.assertEqual(json.loads(path.read_bytes())['errors'],[])
                        approval={'reviewed':True,'reviewer':'INERT FIXTURE',
                                  'report_sha256':m.digest(path.read_bytes()),
                                  'checks':{'all_target_deltas':True,'catalog_resolution':True,'all_logs':True,
                                            'waitrequest_all_representations':True,'no_unrelated_changes':True}}
                        m.run(b,phase,approval)
                        self.assert_report_snapshot(root, phase)
                    self.assertEqual(proc.call_count,3)
                    self.assertEqual(json.loads((root/'evidence/parent-report.json').read_bytes())['errors'],[])
                    self.assertFalse(json.loads((root/'evidence/parent-report.json').read_bytes())['accepted'])

    @contextmanager
    def staged_fixture(self):
        # Real binding checker; only immutable source/tool reads are substituted.
        original_read, original_inventory = m.read, m.inventory
        source = m.SOURCE
        with tempfile.TemporaryDirectory(prefix='mailbox-inert-') as d:
            root = Path(d) / 'scratch'
            with patch.object(m, 'ROOT', root):
                b = copy.deepcopy(self.b)
                b.update(root=str(root), argv=m.commands(), cwd=str(root/'bwbmc'),
                         search_path=m.search_path())
                b['env'].update(HOME=str(root/'home'), TMPDIR=str(root/'tmp'))
                def fixture_read(p):
                    return self.mapping[str(p)] if str(p) in self.mapping else original_read(p)
                def fixture_inventory(p):
                    return self.base['bmc'] if p == source else original_inventory(p)
                with patch.object(m, 'read', side_effect=fixture_read), \
                     patch.object(m, 'inventory', side_effect=fixture_inventory), \
                     patch.dict(m.os.environ, {'TMUX': 'INERT TEST SESSION'}), \
                     patch.object(m.subprocess, 'run') as proc:
                    m.stage(b)
                    proc.assert_not_called()
                    yield root, b, proc

    def assert_initial_rejected(self, mutate):
        with self.staged_fixture() as (root, b, proc):
            evidence = m.inventory(root/'evidence')
            mutate(root)
            with patch.object(m, 'write_new', wraps=m.write_new) as write:
                with self.assertRaises(ValueError):
                    m.run(b, 'upgrade')
                write.assert_not_called()
            proc.assert_not_called()
            self.assertEqual(m.inventory(root/'evidence'), evidence)
            self.assertEqual(sorted(p.name for p in (root/'evidence').iterdir()), ['staged.json'])

    def replace_environment_directory(self, root, name):
        outside = root.parent/'outside'
        outside.mkdir()
        (root/name).rmdir()
        (root/name).symlink_to(outside, target_is_directory=True)

    def test_initial_home_symlink_rejected_before_stage_evidence(self):
        self.assert_initial_rejected(lambda root: self.replace_environment_directory(root, 'home'))

    def test_initial_tmpdir_symlink_rejected_before_stage_evidence(self):
        self.assert_initial_rejected(lambda root: self.replace_environment_directory(root, 'tmp'))

    def test_initial_unexpected_file_rejected_before_stage_evidence(self):
        self.assert_initial_rejected(lambda root: (root/'home/unexpected').write_bytes(b'inert'))

    def test_initial_unexpected_empty_directory_rejected_before_stage_evidence(self):
        self.assert_initial_rejected(lambda root: (root/'tmp/unexpected').mkdir())

    def test_initial_missing_directory_rejected_before_stage_evidence(self):
        self.assert_initial_rejected(lambda root: (root/'home').rmdir())

    def test_initial_directory_replaced_by_file_rejected_before_stage_evidence(self):
        def mutate(root):
            (root/'tmp').rmdir()
            (root/'tmp').write_bytes(b'inert')
        self.assert_initial_rejected(mutate)

    def test_initial_scratch_ancestor_symlink_rejected_before_stage_evidence(self):
        def mutate(root):
            real = root.parent/'real-scratch'
            root.rename(real)
            root.symlink_to(real, target_is_directory=True)
        # Evidence readback through the deliberately invalid path uses raw Path reads.
        with self.staged_fixture() as (root, b, proc):
            evidence = (root/'evidence/staged.json').read_bytes()
            mutate(root)
            with patch.object(m, 'write_new', wraps=m.write_new) as write:
                with self.assertRaisesRegex(ValueError, 'symlink'):
                    m.run(b, 'upgrade')
                write.assert_not_called()
            proc.assert_not_called()
            self.assertEqual((root/'evidence/staged.json').read_bytes(), evidence)
            self.assertEqual(sorted(p.name for p in (root/'evidence').iterdir()), ['staged.json'])

    def assert_report_snapshot(self, root, phase):
        path = root/('evidence/' + phase + '-report.json')
        receipt = json.loads(path.read_bytes())
        current = m.scratch_snapshot(root)
        current['files'].pop(str(path.relative_to(root)))
        self.assertEqual(receipt['scratch_inventory_without_report'], current)
        self.assertTrue({'home', 'tmp', 'bwbmc', 'evidence'} <= set(current['directories']))
        self.assertIn('evidence/staged.json', current['files'])
        self.assertFalse(receipt['accepted'])
        self.assertFalse(receipt['ready_for_build'])
        self.assertTrue(receipt['requires_independent_review'])

    @contextmanager
    def reviewed_fixture(self, phase):
        with self.staged_fixture() as (root, b, proc):
            def fake_run(argv, **kw):
                if '--upgrade-ip-cores' in argv:
                    leaf = root/'bwbmc'/m.LEAF
                    leaf.write_bytes(upgraded_fixture(leaf.read_bytes()))
                else:
                    child = root/'bwbmc/bmc_spi_sub.qsys'
                    child.write_bytes(proxy_fixture(child.read_bytes()))
                    kw['stdout'].write(b'MAILBOX_CHILD_SAVE_COMPLETE\n')
                return m.subprocess.CompletedProcess(argv, 0)
            proc.side_effect = fake_run
            approval = None
            for prior in ('upgrade', 'child')[:1 if phase == 'child' else 2]:
                report = m.run(b, prior, approval)
                self.assertEqual(report['errors'], [])
                report_path = root/('evidence/' + prior + '-report.json')
                approval = self.approval_for(report_path)
            proc.reset_mock()
            yield root, b, proc, report_path, approval

    def approval_for(self, path):
        return {'reviewed': True, 'reviewer': 'INERT FIXTURE',
                'report_sha256': m.digest(path.read_bytes()),
                'checks': dict.fromkeys(('all_target_deltas', 'catalog_resolution',
                    'all_logs', 'waitrequest_all_representations', 'no_unrelated_changes'), True)}

    def later_directory_mutations(self, phase):
        for mutation in ('missing_home', 'missing_tmp', 'extra_empty', 'file_home',
                         'file_tmp', 'symlink_home', 'symlink_tmp', 'scratch_symlink',
                         'ancestor_symlink', 'old_receipt', 'missing_dir_receipt',
                         'walk_error'):
            with self.subTest(phase=phase, mutation=mutation):
                with self.reviewed_fixture(phase) as (root, b, proc, report_path, approval):
                    restore = None
                    if mutation.startswith(('missing_', 'file_', 'symlink_')) and mutation != 'missing_dir_receipt':
                        kind, name = mutation.split('_')
                        (root/name).rmdir()
                        if kind == 'file':
                            (root/name).write_bytes(b'INERT RETYPED DIRECTORY')
                        elif kind == 'symlink':
                            (root/name).symlink_to(root/'bwbmc', target_is_directory=True)
                    elif mutation == 'extra_empty':
                        (root/'tmp/unreviewed-empty').mkdir()
                    elif mutation in ('scratch_symlink', 'ancestor_symlink'):
                        original = root if mutation == 'scratch_symlink' else root.parent
                        moved = original.with_name(original.name + '-moved')
                        original.rename(moved)
                        original.symlink_to(moved, target_is_directory=True)
                        restore = (original, moved)
                    elif mutation in ('old_receipt', 'missing_dir_receipt'):
                        receipt = json.loads(report_path.read_bytes())
                        if mutation == 'old_receipt':
                            state = m.inventory(root)
                            state.pop(str(report_path.relative_to(root)))
                        else:
                            (root/'home').rmdir()
                            state = m.scratch_snapshot(root)
                            state['files'].pop(str(report_path.relative_to(root)))
                        receipt['scratch_inventory_without_report'] = state
                        report_path.write_bytes(m.packed(receipt))
                        approval = self.approval_for(report_path)
                    # Raw readback intentionally works through invalid ancestors.
                    def evidence_bytes():
                        return {str(f.relative_to(root/'evidence')): f.read_bytes()
                                for f in (root/'evidence').rglob('*') if f.is_file()}
                    evidence = evidence_bytes()
                    original_walk = m.os.walk
                    def failing_walk(path, *args, **kwargs):
                        if path == root:
                            kwargs['onerror'](PermissionError('INERT WALK FAILURE'))
                        yield from original_walk(path, *args, **kwargs)
                    try:
                        with patch.object(m, 'write_new', wraps=m.write_new) as write, \
                             patch.object(m.os, 'walk', side_effect=failing_walk if mutation == 'walk_error' else original_walk):
                            with self.assertRaises((ValueError, PermissionError)):
                                m.run(b, phase, approval)
                            write.assert_not_called()
                        proc.assert_not_called()
                        self.assertEqual(evidence_bytes(), evidence)
                        self.assertFalse(any(f.name.startswith(phase + '-') or f.name == phase + '.log'
                                             for f in (root/'evidence').iterdir()))
                    finally:
                        if restore:
                            original, moved = restore
                            original.unlink()
                            moved.rename(original)

    def test_child_directory_barrier_before_any_evidence(self):
        self.later_directory_mutations('child')

    def test_parent_directory_barrier_before_any_evidence(self):
        self.later_directory_mutations('parent')

    def cli_fixture(self, vendor_rc, upgrade, expected_status):
        with self.staged_fixture() as (root, b, proc):
            binding = root.parent/'binding.json'
            binding.write_bytes(m.packed(b))
            def fake_run(argv, **kw):
                if upgrade:
                    leaf = root/'bwbmc'/m.LEAF
                    leaf.write_bytes(upgraded_fixture(leaf.read_bytes()))
                kw['stdout'].write(b'INERT CLI FIXTURE ONLY\n')
                return m.subprocess.CompletedProcess(argv, vendor_rc)
            proc.side_effect = fake_run
            with patch.object(sys, 'argv', ['migration.py', 'upgrade', '--binding', str(binding)]):
                if expected_status:
                    with self.assertRaises(SystemExit) as caught:
                        m.main()
                    self.assertEqual(caught.exception.code, expected_status)
                else:
                    self.assertIsNone(m.main())
            proc.assert_called_once()
            report = json.loads((root/'evidence/upgrade-report.json').read_bytes())
            self.assertEqual(report['returncode'], vendor_rc)
            self.assertFalse(report['accepted'])
            self.assertFalse(report['ready_for_build'])
            self.assertTrue(report['requires_independent_review'])
            self.assertEqual(bool(report['errors']), bool(expected_status))
            self.assertTrue((root/'evidence/upgrade-claim.json').is_file())
            self.assertEqual((root/'evidence/upgrade.log').read_bytes(), b'INERT CLI FIXTURE ONLY\n')
            return report

    def test_cli_nonzero_vendor_persists_report_then_exits_nonzero(self):
        report = self.cli_fixture(7, True, 1)
        self.assertEqual(report['errors'], ['vendor returncode 7: None'])

    def test_cli_zero_vendor_semantic_error_persists_report_then_exits_nonzero(self):
        report = self.cli_fixture(0, False, 1)
        self.assertTrue(any('saved mailbox:' in e for e in report['errors']))
        self.assertFalse(any('vendor returncode' in e for e in report['errors']))

    def test_cli_success_pending_review_is_not_failure(self):
        self.cli_fixture(0, True, 0)

    def test_exact_command_contract(self):
        argv=m.commands()['upgrade']
        self.assertEqual(argv.count('--batch=./'+m.LEAF),1)
        self.assertEqual(argv[1:3],['--upgrade-ip-cores','bmc_spi_sub.qsys'])
        self.assertTrue(argv[-1].endswith(',$'))
        for stage in ('child','parent'):
            self.assertNotIn('--new-quartus-project', ' '.join(m.commands()[stage]))
            self.assertIn('--quartus-project='+str(m.ROOT/(m.REV+'.qpf')),m.commands()[stage])


if __name__=='__main__':
    unittest.main(verbosity=2)
