"""Local policy tests; no vendor executables are run."""
import copy
import io
import sys
import json
import os
import subprocess
from contextlib import ExitStack, contextmanager
from types import SimpleNamespace
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import ia840f_experimental_gate as gate


def generation_args():
    return ['ofs_top', '-c', 'ofs_top', '--generate_project_ip_files',
            '--synthesis=verilog', '--simulation=verilog',
            '--simulator=modelsim', '--parallel=off']


class PolicyTests(unittest.TestCase):
    def test_only_reviewed_commands(self):
        c = str(gate.SOURCE)
        emit = ['-t', c + '/ofs-common/scripts/common/syn/emit_project_ip.tcl',
                '--project=ofs_top', '--revision=ofs_top', '--mode=ip_lib']
        self.assertEqual(gate.command_kind('quartus_ipgenerate', emit), 'ip_lib')
        for revision in ('ofs_top', 'ofs_pr_afu'):
            self.assertEqual(gate.command_kind('quartus_sh', ['--prepare', '-r', revision, 'ofs_top']), 'prepare')
        self.assertEqual(gate.command_kind('quartus_ipgenerate', generation_args()), 'generate')
        for exe, argv in [('quartus_sh', ['--flow', 'compile', 'ofs_top']),
                          ('quartus_syn', ['ofs_top']), ('quartus_fit', ['ofs_top']),
                          ('quartus_asm', ['ofs_top']), ('quartus_sh', ['-t', 'evil.tcl']),
                          ('quartus_ipgenerate', emit + ['--mode=sync']),
                          ('quartus_ipgenerate', ['-t', 'evil.tcl']),
                          ('quartus_ipgenerate', ['ofs_top', '--generate_project_ip_files', '--foo']),
                          ('quartus_sh', ['--prepare', '-r', 'other', 'ofs_top'])]:
            with self.subTest(exe=exe, argv=argv), self.assertRaises(ValueError):
                gate.command_kind(exe, argv)

    def test_pim_macros_and_header_exact_grammar(self):
        scripts = gate.SOURCE / 'ofs-common/scripts/common/syn'
        cases = [(['-t', str(scripts / 'emit_project_macros.tcl'),
                   '--project=ofs_top', '--revision=ofs_top', '--mode=txt',
                   '--output=' + str(gate.WORK / 'src/top/ofs_agilex.macros')], 'pim_macros'),
                 (['-t', str(gate.WORK / 'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),
                   '--project=ofs_top', '--revision=ofs_top'], 'headers')]
        for args, kind in cases:
            self.assertEqual(gate.command_kind('quartus_sh', args), kind)
            mutations = [args + ['--foo'], args[:-1], args[::-1]]
            for index in range(len(args)):
                changed = args.copy()
                changed[index] += '_unreviewed'
                mutations.append(changed)
            for changed in mutations:
                with self.subTest(kind=kind, argv=changed), self.assertRaises(ValueError):
                    gate.command_kind('quartus_sh', changed)
            with self.assertRaises(ValueError):
                gate.command_kind('quartus_ipgenerate', args)

    def test_generation_has_no_optional_defaults_or_aliases(self):
        args = generation_args()
        mutations = [args[::-1], args + ['--parallel=off'], args + ['--foo'],
                     ['ofs_top', '--generate_project_ip_files', '--revision=ofs_top']]
        for index in range(len(args)):
            mutations.append(args[:index] + args[index + 1:])
            changed = args.copy()
            changed[index] = changed[index].upper()
            mutations.append(changed)
        for old, new in [('--parallel=off', '--parallel=on'),
                         ('--simulator=modelsim', '--simulator=vcs'),
                         ('--synthesis=verilog', '--synthesis=VERILOG'),
                         ('--simulation=verilog', '--simulation=VERILOG')]:
            mutations.append([new if a == old else a for a in args])
        for changed in mutations:
            with self.subTest(argv=changed), self.assertRaises(ValueError):
                gate.command_kind('quartus_ipgenerate', changed)

    def test_installed_elf_paths_and_basename_argv_are_distinct(self):
        # Synthetic process/hash evidence ONLY; no installed ELF is read/run.
        for name, args, kind in [('quartus_sh', ['--prepare', '-r', 'ofs_top', 'ofs_top'], 'prepare'),
                                 ('quartus_ipgenerate', generation_args(), 'generate')]:
            exe = '/opt/altera/26.1.1/quartus/linux64/' + name
            self.assertEqual(gate.RUNTIME_EXES[name], exe)
            argv, cwd = [name] + args, str(gate.PROJECT)
            record = {'permissions': ['setup', 'generate'], 'quartus_contexts':
                      [dict(executable=exe, sha256='fixture-hash', argv=argv, cwd=cwd, kind=kind)]}
            with patch.object(gate, 'load_record', return_value=record), \
                 patch.object(gate, 'check_claim'), patch.object(gate, 'sha', return_value='fixture-hash'):
                with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
                    gate.quartus_context()
                for changed in [(exe.replace('/linux64/', '/bin/'), argv, cwd),
                                (exe, [exe] + args, cwd), (exe, [], cwd)]:
                    with patch.object(gate, 'process', return_value=changed), self.assertRaises(ValueError):
                        gate.quartus_context()

    def test_real_selected_ofss_closure_is_in_inventoried_trees(self):
        import configparser
        source = Path(__file__).resolve().parents[3]
        pending = [source / 'syn/board/ia840f/config/ia840f.ofss']
        visited = set()
        while pending:
            path = pending.pop()
            if path in visited:
                continue
            visited.add(path)
            self.assertIn(path.relative_to(source).parts[0], gate.TREES)
            config = configparser.ConfigParser(allow_no_value=True)
            config.optionxform = lambda optionstr: optionstr
            self.assertEqual(config.read(path), [str(path)])
            for section in ('default', 'include'):
                if section in config:
                    for entry in config[section]:
                        expanded = entry.replace('"', '').replace('$OFS_ROOTDIR', str(source))
                        self.assertNotIn('$', expanded)
                        pending.append(Path(expanded))
        self.assertIn(source / 'tools/ofss_config/iopll/iopll_470MHz.ofss', visited)
        self.assertEqual(len(visited), 5)

    def test_inventory_change_and_escape(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            (root / 'one').write_text('source')
            hashes = gate.inventory(root)
            gate.check_inventory(root, hashes)
            (root / 'one').write_text('changed')
            with self.assertRaises(ValueError):
                gate.check_inventory(root, hashes)
            (root / 'escape').symlink_to('/etc/passwd')
            with self.assertRaises(ValueError):
                gate.inventory(root)

    def test_denied_stages_do_not_read_record(self):
        for stage in ('all', 'compile', 'finish', 'synthesis', 'fit', 'assembler'):
            with self.subTest(stage=stage), patch.object(gate, 'load_record') as load:
                with self.assertRaises(ValueError):
                    gate.native(stage, 'ia840f', str(gate.WORK))
                load.assert_not_called()

    def test_missing_record_and_spoofed_stage(self):
        with patch.dict('os.environ', {'STAGE': 'setup', 'IA840F_STAGE': 'setup'}, clear=True):
            with self.assertRaises((ValueError, OSError)):
                gate.native('setup', 'ia840f', str(gate.WORK))

    def test_wrong_target_work_and_options(self):
        for target, work in [('ia840f:flat', str(gate.WORK)), ('ia840f', '/tmp/work')]:
            with self.assertRaises(ValueError):
                gate.native('setup', target, work)
        for key, value in [('COPY_WORK', '0'), ('KEEP_WORK_ARG', '-k'),
                           ('ANALYSIS_AND_ELAB_ONLY', '1'), ('OFS_PRE_SETUP_SCRIPT', '/tmp/evil')]:
            with patch.dict('os.environ', {key: value}, clear=True), self.assertRaises(ValueError):
                gate.native('setup', 'ia840f', str(gate.WORK))

    def test_runtime_context_uses_actual_process(self):
        # This Python test runner is not a Quartus executable, regardless of env.
        with patch.dict('os.environ', {'STAGE': 'setup'}, clear=True):
            with self.assertRaises((ValueError, OSError)):
                gate.quartus_context()


class RecordTests(unittest.TestCase):
    def setUp(self):
        self.stack = ExitStack()
        self.addCleanup(self.stack.close)
        root = Path(self.stack.enter_context(tempfile.TemporaryDirectory()))
        self.source, self.work, self.pim = root / 'source', root / 'work', root / 'pim'
        for name, value in [('SOURCE', self.source), ('WORK', self.work), ('PIM', self.pim),
                            ('PROJECT', self.work / 'syn/board/ia840f/syn_top'),
                            ('__file__', str(self.source / 'gate.py'))]:
            self.stack.enter_context(patch.object(gate, name, value))
        for tree in gate.TREES:
            (self.source / tree).mkdir(parents=True)
            (self.source / tree / 'input').write_text('test fixture source')
        self.pim.mkdir()
        (self.pim / 'input').write_text('test fixture PIM')
        tools = {}
        for name in gate.TOOLS:
            file = root / name
            file.write_text('identity fixture only, never executed')
            tools[name] = {'path': str(file), 'sha256': gate.sha(file)}
        self.stack.enter_context(patch.object(gate.shutil, 'which', lambda n: tools[n]['path']))
        self.stack.enter_context(patch.object(gate, 'RUNTIME_EXES',
            {n: tools[n]['path'] for n in ('quartus_sh', 'quartus_ipgenerate')}))
        self.stack.enter_context(patch.object(gate, 'INNER_TOOL_PATHS',
            {n: tools[n]['path'] for n in gate.INNER_TOOL_PATHS}))
        self.record: dict = dict(schema=1, approved=True, ready_for_build=False, target='ia840f',
                           part=gate.PART, toolchain=gate.VERSION, source=str(self.source),
                           work=str(self.work), pim=str(self.pim), permissions=['setup'],
                           source_sha256={t: gate.inventory(self.source / t) for t in gate.TREES},
                           pim_sha256=gate.inventory(self.pim), tools=tools,
                           quartus_tools=copy.deepcopy(tools), quartus_contexts=[])
        self.path = self.source / gate.RECORD_REL
        self.path.parent.mkdir(parents=True)
        self.env = dict(COPY_WORK='1', OFS_ROOTDIR=str(self.source),
                        OFS_PLATFORM_AFU_BBB=str(self.pim), DO_PR_BUILD_TEMPLATE_GEN='1',
                        USE_OFSS_CONFIG_SCRIPT='nodefault,' + str(self.source / 'syn/board/ia840f/config/ia840f.ofss'))
        self.stack.enter_context(patch.dict(os.environ, self.env, clear=True))
        self.save()

    def save(self):
        self.path.write_text(json.dumps(self.record))

    def test_valid_record_and_new_work(self):
        gate.native('setup', 'ia840f', str(self.work))
        self.work.mkdir()
        with self.assertRaisesRegex(ValueError, 'absent'):
            gate.native('setup-entry', 'ia840f', str(self.work))

    def test_missing_malformed_record_and_tool_drift(self):
        self.path.unlink()
        with self.assertRaises(OSError):
            gate.load_record()
        self.path.write_text('{')
        with self.assertRaises(ValueError):
            gate.load_record()
        self.save()
        tool = Path(self.record['tools']['quartus_sh']['path'])
        tool.write_text('changed tool fixture')
        with self.assertRaisesRegex(ValueError, 'tool hash'):
            gate.load_record()

    def test_inner_path_identities_do_not_relax_outer_path(self):
        inner = self.record['quartus_tools']
        paths = {}
        for name in gate.INNER_TOOL_PATHS:
            file = self.source.parent / ('inner-' + name)
            file.write_text('inert inner tool identity fixture')
            paths[name] = str(file)
            inner[name] = dict(path=str(file), sha256=gate.sha(file))
        self.stack.enter_context(patch.object(gate, 'INNER_TOOL_PATHS', paths))
        self.save()
        gate.load_record()  # Native PATH remains bound to outer launchers.
        with self.assertRaisesRegex(ValueError, 'tool path: quartus_sh'):
            gate.load_record(quartus_inner=True)
        with patch.object(gate.shutil, 'which', side_effect=lambda n: inner[n]['path']):
            gate.load_record(quartus_inner=True)
            with self.assertRaisesRegex(ValueError, 'tool path: quartus_sh'):
                gate.load_record()
            for name in gate.TOOLS:
                with self.subTest(name=name):
                    original = inner[name]['sha256']
                    inner[name]['sha256'] = 'bad-hash'
                    self.save()
                    with self.assertRaisesRegex(ValueError, 'tool hash'):
                        gate.load_record(quartus_inner=True)
                    inner[name]['sha256'] = original
            self.save()
            inner['quartus_sh']['path'] = self.record['tools']['quartus_sh']['path']
            self.save()
            with self.assertRaisesRegex(ValueError, 'inner tool path'):
                gate.load_record(quartus_inner=True)

    def test_missing_inner_identities_fail_closed(self):
        del self.record['quartus_tools']
        self.save()
        with self.assertRaises(KeyError):
            gate.load_record()

    def test_setup_wrapper_validates_before_spawning(self):
        gate.native('setup-entry', 'ia840f', str(self.work))
        gate.PROJECT.mkdir(parents=True)
        args = ['--prepare', '-r', 'ofs_top', 'ofs_top']
        with patch.object(gate.Path, 'cwd', return_value=gate.PROJECT), \
             patch.object(gate, 'monitor_setup_output') as monitor:
            gate.run_setup_quartus('quartus_sh', args)
            monitor.assert_called_once_with([self.record['tools']['quartus_sh']['path']] + args)
            monitor.reset_mock()
            for name, bad in [('quartus_sh', args + ['--foo']),
                              ('quartus_sh', ['--flow', 'compile', 'ofs_top']),
                              ('quartus_ipgenerate', generation_args()),
                              ('/tmp/quartus_sh', args)]:
                with self.assertRaises(ValueError):
                    gate.run_setup_quartus(name, bad)
            monitor.assert_not_called()
            gate.claim_path().unlink()  # Local fixture only.
            with self.assertRaises(OSError):
                gate.run_setup_quartus('quartus_sh', args)
            monitor.assert_not_called()

    def test_single_run_consumption(self):
        gate.native('setup-entry', 'ia840f', str(self.work))
        gate.check_claim()
        with self.assertRaisesRegex(ValueError, 'consumed'):
            gate.native('setup-entry', 'ia840f', str(self.work))
        self.record['permissions'].append('generate')
        self.save()
        with self.assertRaisesRegex(ValueError, 'single-run claim'):
            gate.check_claim()

    def test_each_binding_fails_closed(self):
        original = copy.deepcopy(self.record)
        for field, value in [('approved', False), ('ready_for_build', True), ('part', 'other'),
                             ('toolchain', 'other'), ('work', '/tmp/work'), ('target', 'other'),
                             ('source_sha256', {}), ('permissions', ['compile'])]:
            self.record = copy.deepcopy(original)
            self.record[field] = value
            self.save()
            with self.subTest(field=field), self.assertRaises(ValueError):
                gate.load_record()
        self.record = original
        self.save()
        (self.source / 'src/input').write_text('drift')
        with self.assertRaisesRegex(ValueError, 'inventory mismatch'):
            gate.load_record()

    def test_actual_context_and_generation_permission(self):
        self.stack.enter_context(patch.object(gate, 'check_claim'))
        exe = self.record['tools']['quartus_sh']['path']
        argv = ['quartus_sh', '--prepare', '-r', 'ofs_top', 'ofs_top']
        cwd = str(gate.PROJECT)
        self.record['quartus_contexts'] = [dict(executable=exe, sha256=gate.sha(exe), argv=argv, cwd=cwd, kind='prepare')]
        self.save()
        with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
            gate.quartus_context()
        for changed in [(exe, argv + ['--flow', 'compile'], cwd), (exe, argv, '/tmp')]:
            with patch.object(gate, 'process', return_value=changed), self.assertRaises(ValueError):
                gate.quartus_context()
        exe = self.record['tools']['quartus_ipgenerate']['path']
        argv = ['quartus_ipgenerate'] + generation_args()
        self.record['quartus_contexts'] = [dict(executable=exe, sha256=gate.sha(exe), argv=argv, cwd=cwd, kind='generate')]
        self.save()
        with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
            with self.assertRaisesRegex(ValueError, 'generation not authorized'):
                gate.quartus_context()
            self.record['permissions'].append('generate')
            self.save()
            gate.quartus_context()
        # Actual /proc test: Python is not the authorized Quartus process.
        with self.assertRaises(ValueError):
            gate.quartus_context()

    def test_pim_and_headers_runtime_permission_and_identity(self):
        rel = Path('ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl')
        (self.source / rel).parent.mkdir(parents=True)
        (self.source / rel).write_text('inert header fixture')
        self.record['source_sha256']['ofs-common'] = gate.inventory(self.source / 'ofs-common')
        self.save()
        gate.native('setup-entry', 'ia840f', str(self.work))
        (self.work / rel).parent.mkdir(parents=True)
        (self.work / rel).write_text('inert header fixture')
        exe = self.record['tools']['quartus_sh']['path']
        cwd = str(gate.PROJECT)
        scripts = self.source / 'ofs-common/scripts/common/syn'
        for kind, args in [('pim_macros', ['-t', str(scripts / 'emit_project_macros.tcl'),
                            '--project=ofs_top', '--revision=ofs_top', '--mode=txt',
                            '--output=' + str(self.work / 'src/top/ofs_agilex.macros')]),
                           ('headers', ['-t', str(gate.WORK / 'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),
                            '--project=ofs_top', '--revision=ofs_top'])]:
            argv = ['quartus_sh'] + args
            self.record['quartus_contexts'] = [dict(executable=exe, sha256=gate.sha(exe),
                                                   argv=argv, cwd=cwd, kind=kind)]
            self.record['permissions'] = ['setup', 'generate']
            self.save()
            # Fixture-only claim renewal allows independent permission cases.
            gate.claim_path().write_text(gate.sha(self.path))
            with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
                if kind == 'headers':
                    with self.assertRaisesRegex(ValueError, 'headers not authorized'):
                        gate.quartus_context()
                    self.record['permissions'].append('headers')
                    self.save()
                    gate.claim_path().write_text(gate.sha(self.path))
                gate.quartus_context()
            for changed in [(exe, [exe] + args, cwd), (exe, argv, '/tmp'),
                            ('/tmp/unreviewed/quartus_sh', argv, cwd)]:
                with patch.object(gate, 'process', return_value=changed), self.assertRaises(ValueError):
                    gate.quartus_context()
            self.record['quartus_contexts'][0]['sha256'] = 'wrong'
            self.save()
            gate.claim_path().write_text(gate.sha(self.path))
            with patch.object(gate, 'process', return_value=(exe, argv, cwd)), self.assertRaisesRegex(ValueError, 'unrecorded'):
                gate.quartus_context()

    def test_post_setup_work_scripts_are_exact_and_source_bound(self):
        self.stack.enter_context(patch.object(gate, 'check_claim'))
        for name, relative, extra, kind in [
                ('quartus_ipgenerate', 'ofs-common/scripts/common/syn/emit_project_ip.tcl',
                 ['--output=project_ip_for_generation.tcl'], 'project_ip'),
                ('quartus_sh', 'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl',
                 [], 'headers')]:
            src, work = self.source / relative, self.work / relative
            src.parent.mkdir(parents=True, exist_ok=True)
            work.parent.mkdir(parents=True, exist_ok=True)
            src.write_text('inert source script fixture')
            work.write_text(src.read_text())
            args = ['-t', str(work), '--project=ofs_top', '--revision=ofs_top'] + extra
            self.assertEqual(gate.command_kind(name, args), kind)
            for bad in [args + ['--foo'], [a.replace(str(self.work), str(self.source)) for a in args],
                        args[:-1], args + ['--mode=sync']]:
                with self.assertRaises(ValueError):
                    gate.command_kind(name, bad)
            exe, argv, cwd = self.record['tools'][name]['path'], [name] + args, str(gate.PROJECT)
            self.record['source_sha256']['ofs-common'] = gate.inventory(self.source / 'ofs-common')
            self.record['permissions'] = ['setup', 'generate', 'headers']
            self.record['quartus_contexts'] = [dict(executable=exe, sha256=gate.sha(exe), argv=argv, cwd=cwd, kind=kind)]
            self.save()
            with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
                gate.quartus_context()
                work.write_text('worktree script drift')
                with self.assertRaisesRegex(ValueError, 'work script source hash mismatch'):
                    gate.quartus_context()
                work.write_text(src.read_text())
                self.record['permissions'] = ['setup']
                self.save()
                with self.assertRaises(ValueError):
                    gate.quartus_context()

    def test_native_ofss_uses_python3(self):
        self.assertEqual(Path(__file__).with_name('gen_ofs_settings.py').read_text().splitlines()[0],
                         '#!/usr/bin/env python3')

    def test_tools_inventory_and_pim_executable_binding(self):
        self.record['source_sha256'].pop('tools')
        self.save()
        with self.assertRaisesRegex(ValueError, 'source tree coverage'):
            gate.load_record()
        self.record['source_sha256']['tools'] = gate.inventory(self.source / 'tools')
        selected = self.source / 'tools/ofss_config/iopll/iopll_470MHz.ofss'
        selected.parent.mkdir(parents=True)
        selected.write_text('fixture IOPLL')
        self.record['source_sha256']['tools'] = gate.inventory(self.source / 'tools')
        self.save()
        gate.load_record()
        selected.write_text('changed IOPLL')
        with self.assertRaisesRegex(ValueError, 'inventory mismatch'):
            gate.load_record()
        selected.write_text('fixture IOPLL')
        original_which = gate.shutil.which
        with patch.object(gate.shutil, 'which', side_effect=lambda n: None if n == 'afu_synth_setup' else original_which(n)):
            with self.assertRaisesRegex(ValueError, 'tool path: afu_synth_setup'):
                gate.load_record()
        Path(self.record['tools']['afu_synth_setup']['path']).write_text('drift')
        with self.assertRaisesRegex(ValueError, 'tool hash: afu_synth_setup'):
            gate.load_record()

    def test_ofss_context_bound_to_native_argv_and_output(self):
        gate.native('setup-entry', 'ia840f', str(self.work))
        gate.PROJECT.mkdir(parents=True)
        argv = [str(self.source / 'ofs-common/tools/ofss_config/gen_ofs_settings.py'),
                '--ofss', str(self.source / 'syn/board/ia840f/config/ia840f.ofss'),
                '--target', '../../../..']
        original_cwd = Path.cwd()
        try:
            os.chdir(gate.PROJECT)
            with patch.object(gate.sys, 'argv', argv):
                gate.ofss_context('../../../..', gate.PART)
                for target, part in [('/tmp', gate.PART), ('../../../..', 'wrong')]:
                    with self.assertRaises(ValueError):
                        gate.ofss_context(target, part)
            with patch.object(gate.sys, 'argv', argv + ['--debug']), self.assertRaises(ValueError):
                gate.ofss_context('../../../..', gate.PART)
        finally:
            os.chdir(original_cwd)

    def test_options_and_missing_tools(self):
        for key, val in [('COPY_WORK', '0'), ('KEEP_WORK_ARG', '-k'), ('ANALYSIS_AND_ELAB_ONLY', '1'),
                         ('OFS_PRE_SETUP_SCRIPT', 'evil'), ('BUILD_VAR_SETUP_COMPLETE', '1'),
                         ('OFS_PLATFORM_AFU_BBB', '/tmp/pim'), ('OFS_BUILD_TAG_FLAT', '1'),
                         ('AFU_WITH_PIM', '/tmp/unbound/filelist.txt')]:
            with patch.dict(os.environ, {key: val}), self.subTest(key=key), self.assertRaises(ValueError):
                gate.native('setup-entry', 'ia840f', str(self.work))
        with patch.object(gate.shutil, 'which', return_value=None), self.assertRaises(ValueError):
            gate.load_record()


def post_setup_commands():
    scripts = gate.WORK / 'ofs-common/scripts/common/syn'
    return [
        ('quartus_ipgenerate', ['-t', str(scripts / 'emit_project_ip.tcl'),
         '--project=ofs_top', '--revision=ofs_top',
         '--output=project_ip_for_generation.tcl'], 'project_ip'),
        ('quartus_ipgenerate', generation_args(), 'generate'),
        ('quartus_sh', ['-t', str(scripts / 'ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),
         '--project=ofs_top', '--revision=ofs_top'], 'headers'),
    ]


@contextmanager
def post_setup_fixture(permissions=('setup', 'generate', 'headers'), before_claim=None):
    # Reuse real record validation with synthetic identities. Each invocation
    # finalizes a fresh record BEFORE exclusive claim creation; never renew it.
    fixture = RecordTests()
    try:
        fixture.setUp()
        commands = post_setup_commands()
        for name, args, kind in commands:
            if kind != 'generate':
                relative = Path(args[1]).relative_to(gate.WORK)
                source = gate.SOURCE / relative
                source.parent.mkdir(parents=True, exist_ok=True)
                source.write_text('inert Tcl identity; never executed')
        # Include the gate/test themselves in the synthetic bound inventory.
        for filename in ('ia840f_experimental_gate.py', 'test_ia840f_experimental_gate.py'):
            (gate.SOURCE / 'ofs-common' / filename).write_bytes(
                Path(__file__).with_name(filename).read_bytes())
        # Deliberately distinct outer launcher and inner runtime identities.
        inner_paths = {}
        for name in gate.INNER_TOOL_PATHS:
            inner = fixture.source.parent / 'linux64' / name
            inner.parent.mkdir(exist_ok=True)
            inner.write_text('inert inner identity; never executed')
            inner_paths[name] = str(inner)
            fixture.record['quartus_tools'][name] = dict(path=str(inner), sha256=gate.sha(inner))
        fixture.stack.enter_context(patch.object(gate, 'INNER_TOOL_PATHS', inner_paths))
        fixture.stack.enter_context(patch.object(gate, 'RUNTIME_EXES',
            {n: inner_paths[n] for n in ('quartus_sh', 'quartus_ipgenerate')}))
        fixture.record['source_sha256'] = {t: gate.inventory(gate.SOURCE / t) for t in gate.TREES}
        fixture.record['permissions'] = list(permissions)
        fixture.record['quartus_contexts'] = [
            dict(executable=gate.RUNTIME_EXES[name], sha256=gate.sha(gate.RUNTIME_EXES[name]),
                 argv=[name] + args, cwd=str(gate.PROJECT), kind=kind)
            for name, args, kind in commands]
        if before_claim:
            before_claim(fixture)
        fixture.save()
        gate.native('setup-entry', 'ia840f', str(gate.WORK))
        gate.PROJECT.mkdir(parents=True)
        for name, args, kind in commands:
            if kind != 'generate':
                relative = Path(args[1]).relative_to(gate.WORK)
                work = gate.WORK / relative
                work.parent.mkdir(parents=True, exist_ok=True)
                work.write_bytes((gate.SOURCE / relative).read_bytes())
        fixture.stack.enter_context(patch.object(gate.Path, 'cwd', return_value=gate.PROJECT))
        yield fixture, commands
    finally:
        fixture.doCleanups()


class PostSetupTests(unittest.TestCase):
    def test_work03_constant(self):
        self.assertEqual(gate.WORK, gate.BASE / 'work_ia840f_ipgen_04')
        self.assertEqual(gate.PROJECT, gate.WORK / 'syn/board/ia840f/syn_top')

    def test_permissions_and_exact_outer_launch(self):
        for permissions in (('setup',), ('setup', 'generate'), ('setup', 'generate', 'headers')):
            with post_setup_fixture(permissions) as (fixture, commands):
                for name, args, kind in commands:
                    allowed = ('headers' if kind == 'headers' else 'generate') in permissions
                    with self.subTest(permissions=permissions, kind=kind), \
                         patch.object(gate, 'monitor_setup_output') as monitor, \
                         patch.object(gate, 'setup_environment', side_effect=AssertionError('setup-only check')):
                        if allowed:
                            gate.run_post_setup_quartus(name, args)
                            monitor.assert_called_once_with([fixture.record['tools'][name]['path']] + args)
                        else:
                            with self.assertRaisesRegex(ValueError, 'not authorized'):
                                gate.run_post_setup_quartus(name, args)
                            monitor.assert_not_called()

    def test_closed_grammar_and_wrapper_separation(self):
        with post_setup_fixture() as (fixture, commands), patch.object(gate, 'monitor_setup_output') as monitor:
            for name, args, kind in commands:
                with self.assertRaisesRegex(ValueError, 'not a setup'):
                    gate.run_setup_quartus(name, args)
                mutations = [args[::-1], args + ['--foo'], args + ['--mode=sync'],
                             [a.replace(str(gate.WORK), str(gate.SOURCE)) for a in args]]
                # The generation command has no WORK path to replace.
                mutations = [a for a in mutations if a != args]
                for index in range(len(args)):
                    mutations += [args[:index] + args[index + 1:], args + [args[index]]]
                    changed = args.copy()
                    changed[index] += '_unreviewed'
                    mutations.append(changed)
                for changed in mutations:
                    with self.subTest(kind=kind, args=changed), self.assertRaises(ValueError):
                        gate.run_post_setup_quartus(name, changed)
                for executable in ('/tmp/' + name, 'arbitrary', 'quartus_syn', 'quartus_fit', 'quartus_asm', 'quartus_pgm'):
                    with self.assertRaises(ValueError):
                        gate.run_post_setup_quartus(executable, args)
            setup_commands = [
                ('quartus_sh', ['--prepare', '-r', 'ofs_top', 'ofs_top']),
                ('quartus_sh', ['-t', str(gate.SOURCE / 'ofs-common/scripts/common/syn/emit_project_macros.tcl'),
                 '--project=ofs_top', '--revision=ofs_top', '--mode=txt',
                 '--output=' + str(gate.WORK / 'src/top/ofs_agilex.macros')]),
                ('quartus_ipgenerate', ['-t', str(gate.SOURCE / 'ofs-common/scripts/common/syn/emit_project_ip.tcl'),
                 '--project=ofs_top', '--revision=ofs_top', '--mode=ip_lib'])]
            for name, args in setup_commands:
                with self.assertRaisesRegex(ValueError, 'not a post-setup'):
                    gate.run_post_setup_quartus(name, args)
            for args in (['--flow', 'compile', 'ofs_top'], ['--flow', 'finish', 'ofs_top'],
                         ['-t', 'arbitrary.tcl'],
                         [a.replace('--parallel=off', '--parallel=on') for a in generation_args()],
                         [a.replace('--simulator=modelsim', '--simulator=vcs') for a in generation_args()]):
                with self.assertRaises(ValueError):
                    gate.run_post_setup_quartus('quartus_ipgenerate', args)
            monitor.assert_not_called()

    def test_context_binding_before_spawn(self):
        for index in range(3):
            for field in ('missing', 'executable', 'sha256', 'argv', 'cwd', 'kind'):
                def mutate(fixture):
                    context = fixture.record['quartus_contexts'][index]
                    if field == 'missing':
                        fixture.record['quartus_contexts'].pop(index)
                    else:
                        context[field] = ['wrong'] if field == 'argv' else 'wrong'
                with self.subTest(index=index, field=field), \
                     post_setup_fixture(before_claim=mutate) as (fixture, commands), \
                     patch.object(gate, 'monitor_setup_output') as monitor:
                    name, args, _ = commands[index]
                    with self.assertRaisesRegex(ValueError, 'unrecorded'):
                        gate.run_post_setup_quartus(name, args)
                    monitor.assert_not_called()

    def test_binding_drift_before_spawn(self):
        cases = ('claim_missing', 'claim_changed', 'claim_symlink', 'record_bytes',
                 'permissions', 'permissions_missing', 'permissions_malformed', 'cwd',
                 'source', 'pim', 'outer', 'inner', 'path', 'ready', 'gate_source', 'test_source')
        for case in cases:
            with self.subTest(case=case), post_setup_fixture() as (fixture, commands), ExitStack() as stack:
                claim = gate.claim_path()
                if case == 'claim_missing':
                    claim.unlink()
                elif case == 'claim_changed':
                    claim.write_text('wrong')
                elif case == 'claim_symlink':
                    target = claim.with_suffix('.copy')
                    target.write_bytes(claim.read_bytes())
                    claim.unlink()
                    claim.symlink_to(target)
                elif case == 'record_bytes':
                    fixture.path.write_bytes(fixture.path.read_bytes() + b'\n')
                elif case in ('permissions', 'permissions_missing', 'permissions_malformed', 'ready'):
                    if case == 'permissions_missing':
                        del fixture.record['permissions']
                    elif case == 'ready':
                        fixture.record['ready_for_build'] = True
                    else:
                        fixture.record['permissions'] = ['setup'] if case == 'permissions' else 'generate'
                    fixture.save()
                elif case == 'cwd':
                    stack.enter_context(patch.object(gate.Path, 'cwd', return_value=fixture.source))
                elif case == 'path':
                    stack.enter_context(patch.object(gate.shutil, 'which', return_value='/unreviewed'))
                else:
                    paths = {'source': fixture.source / 'src/input', 'pim': fixture.pim / 'input',
                             'outer': Path(fixture.record['tools']['quartus_sh']['path']),
                             'inner': Path(fixture.record['quartus_tools']['quartus_sh']['path']),
                             'gate_source': fixture.source / 'ofs-common/ia840f_experimental_gate.py',
                             'test_source': fixture.source / 'ofs-common/test_ia840f_experimental_gate.py'}
                    paths[case].write_text('drift')
                with patch.object(gate, 'monitor_setup_output') as monitor:
                    for name, args, kind in commands:
                        with self.assertRaises((ValueError, OSError, KeyError)):
                            gate.run_post_setup_quartus(name, args)
                    monitor.assert_not_called()

    def test_work_scripts_missing_or_drifted(self):
        for index in (0, 2):
            for missing in (False, True):
                with post_setup_fixture() as (fixture, commands), patch.object(gate, 'monitor_setup_output') as monitor:
                    name, args, kind = commands[index]
                    script = Path(args[1])
                    if missing:
                        script.unlink()
                    else:
                        script.write_text('drift')
                    with self.assertRaises((ValueError, OSError)):
                        gate.run_post_setup_quartus(name, args)
                    monitor.assert_not_called()

    def test_actual_callback_still_checks_all_post_setup_kinds(self):
        for permissions in (('setup',), ('setup', 'generate'), ('setup', 'generate', 'headers')):
            with post_setup_fixture(permissions) as (fixture, commands):
                inner = fixture.record['quartus_tools']
                with patch.object(gate.shutil, 'which', side_effect=lambda n: inner[n]['path']):
                    for name, args, kind in commands:
                        exe, argv, cwd = gate.RUNTIME_EXES[name], [name] + args, str(gate.PROJECT)
                        allowed = ('headers' if kind == 'headers' else 'generate') in permissions
                        with patch.object(gate, 'process', return_value=(exe, argv, cwd)):
                            if allowed:
                                gate.quartus_context()
                            else:
                                with self.assertRaisesRegex(ValueError, 'not authorized'):
                                    gate.quartus_context()
                        for changed in [(fixture.record['tools'][name]['path'], argv, cwd),
                                        (exe, [exe] + args, cwd), (exe, [], cwd),
                                        (exe, argv, str(fixture.source)), (exe, argv + ['--foo'], cwd)]:
                            with patch.object(gate, 'process', return_value=changed), self.assertRaises(ValueError):
                                gate.quartus_context()

    def test_permission_extension_preserves_old_claim_and_distinct_new_run(self):
        with post_setup_fixture(('setup',)) as (old, commands):
            old_claim, old_record = gate.claim_path(), old.path
            claim_bytes, record_bytes = old_claim.read_bytes(), old_record.read_bytes()
            old.record['permissions'] = ['setup', 'generate', 'headers']
            old.save()
            with patch.object(gate, 'monitor_setup_output') as monitor:
                for name, args, kind in commands:
                    with self.assertRaisesRegex(ValueError, 'single-run claim'):
                        gate.run_post_setup_quartus(name, args)
                monitor.assert_not_called()
            self.assertEqual(old_claim.read_bytes(), claim_bytes)
            # Restore original bytes only in this isolated regression fixture.
            old_record.write_bytes(record_bytes)
            with post_setup_fixture() as (new, commands), patch.object(gate, 'monitor_setup_output') as monitor:
                self.assertNotEqual(gate.WORK, old.work)
                self.assertNotEqual(gate.claim_path(), old_claim)
                for name, args, kind in commands:
                    gate.run_post_setup_quartus(name, args)
                self.assertEqual(monitor.call_count, 3)
                self.assertEqual(old_claim.read_bytes(), claim_bytes)
                self.assertEqual(old_record.read_bytes(), record_bytes)

    def cli_with_inert_child(self, name, args, program, split=False):
        output, errors = io.BytesIO(), io.StringIO()
        real_popen, real_read = subprocess.Popen, os.read
        def spawn(command, **kwargs):
            # Substitute only at the process boundary. Never execute fake tools.
            return real_popen([sys.executable, '-c', program], **kwargs)
        with ExitStack() as stack:
            stack.enter_context(patch.object(gate.sys, 'argv', ['gate', 'run-post-setup-quartus', name] + args))
            stack.enter_context(patch.object(gate.sys, 'stdout', SimpleNamespace(buffer=output)))
            stack.enter_context(patch.object(gate.sys, 'stderr', errors))
            stack.enter_context(patch.object(gate.subprocess, 'Popen', side_effect=spawn))
            if split:
                stack.enter_context(patch.object(gate.os, 'read', side_effect=lambda fd, n: real_read(fd, 1)))
            status = gate.main()
        return status, output.getvalue(), errors.getvalue()

    def test_cli_output_and_status_matrix(self):
        with post_setup_fixture() as (fixture, commands):
            for name, args, kind in commands:
                for payload in (b'', b'clean\n', b'\xff\xfe\x00', b'x' * 150000):
                    with self.subTest(kind=kind, size=len(payload)):
                        # Construct large payload in child, not oversized argv.
                        expression = "b'x' * 150000" if len(payload) > 65536 else repr(payload)
                        status, output, errors = self.cli_with_inert_child(name, args,
                            'import sys; sys.stdout.buffer.write(' + expression + ')')
                        self.assertEqual((status, output, errors), (0, payload, ''))
                status, output, errors = self.cli_with_inert_child(name, args,
                    "import os, sys; os.write(1, b'nonzero'); sys.exit(7)")
                self.assertEqual((status, output), (1, b'nonzero'))
                self.assertIn('subprocess exit: 7', errors)
                for marker in gate.REJECTION_MARKERS:
                    for fd in (1, 2):
                        for split in (False, True):
                            with self.subTest(kind=kind, marker=marker, fd=fd, split=split):
                                status, output, errors = self.cli_with_inert_child(name, args,
                                    f'import os; os.write({fd}, {marker!r})', split)
                                self.assertEqual((status, output), (1, marker))
                                self.assertIn('despite exit 0', errors)

    def test_cli_spawn_errors_and_invalid_dispatch(self):
        with post_setup_fixture() as (fixture, commands):
            for name, args, kind in commands:
                with patch.object(gate.sys, 'argv', ['gate', 'run-post-setup-quartus', name] + args), \
                     patch.object(gate.subprocess, 'Popen', side_effect=OSError('fixture spawn failure')), \
                     patch.object(gate.sys, 'stderr', io.StringIO()) as errors:
                    self.assertEqual(gate.main(), 1)
                    self.assertIn('fixture spawn failure', errors.getvalue())
            for argv in (['gate', 'run-post-setup-quartus'], ['gate', 'run-post-setup-quartus', 'quartus_sh'],
                         ['gate', 'run-post-setup-quartus', 'quartus_sh', '--flow', 'compile', 'ofs_top']):
                with patch.object(gate.sys, 'argv', argv), patch.object(gate.sys, 'stderr', io.StringIO()), \
                     patch.object(gate, 'monitor_setup_output') as monitor:
                    self.assertEqual(gate.main(), 1)
                    monitor.assert_not_called()

    def test_cli_process_exit_and_merged_bytes(self):
        # A separate Python process exercises dispatcher status via sys.exit.
        # The imported fixture supplies synthetic evidence, not vendor results.
        harness = '''
import runpy, sys
from pathlib import Path
from unittest.mock import patch
import ia840f_experimental_gate as gate
from test_ia840f_experimental_gate import post_setup_fixture
program, index = sys.argv[1], int(sys.argv[2])
with post_setup_fixture() as (fixture, commands):
    name, args, kind = commands[index]
    path = str(Path(__import__('test_ia840f_experimental_gate').__file__).with_name('ia840f_experimental_gate.py'))
    # runpy has its own module globals; route its dispatcher to the fully
    # fixture-validated wrapper without bypassing any wrapper preflight.
    real_wrapper = gate.run_post_setup_quartus
    real_popen = gate.subprocess.Popen
    def inert(command, **kwargs):
        return real_popen([sys.executable, '-c', program], **kwargs)
    with patch.object(gate.subprocess, 'Popen', side_effect=inert):
        namespace = runpy.run_path(path, run_name='fixture_gate')
        namespace['main'].__globals__['run_post_setup_quartus'] = real_wrapper
        sys.argv = [path, 'run-post-setup-quartus', name] + args
        sys.exit(namespace['main']())
'''
        for index in range(3):
            for payload, code, expected in ((b'clean\xff', 0, 0), (b'failed\xff', 7, 1),
                                             (b'Critical Warning (125091)\xff', 0, 1)):
                program = f'import os, sys; os.write(2, {payload!r}); sys.exit({code})'
                result = subprocess.run([sys.executable, '-c', harness, program, str(index)],
                                        capture_output=True)
                with self.subTest(index=index, code=code, payload=payload):
                    self.assertEqual(result.returncode, expected, result.stderr)
                    self.assertEqual(result.stdout, payload)

    def test_reviewed_sequence_stops_before_next_stage(self):
        # Test-only checked-status orchestration, NOT a deployed shell script.
        # Per-stage logs are written even on failure and cannot mask CLI status.
        for failure in (None, 0, 1, 2):
            for program in ("import sys; sys.exit(7)", "print('Critical Warning (125091)')"):
                with post_setup_fixture() as (fixture, commands):
                    seen = []
                    for index, (name, args, kind) in enumerate(commands):
                        sentinel = gate.PROJECT / ('stage-' + str(index))
                        child = ('from pathlib import Path; '
                                 f'Path({str(sentinel)!r}).write_text({str(index)!r}); ' +
                                 (program if index == failure else "print('clean')"))
                        status, output, errors = self.cli_with_inert_child(name, args, child)
                        (gate.PROJECT / ('log-' + str(index))).write_bytes(output)
                        (gate.PROJECT / ('status-' + str(index))).write_text(str(status))
                        seen.append(index)
                        if status:
                            break
                    else:
                        (gate.PROJECT / 'accepted').write_text('inert sequence only')
                    self.assertEqual(seen, list(range(3 if failure is None else failure + 1)))
                    self.assertEqual((gate.PROJECT / 'accepted').exists(), failure is None)
                    for index in range(3):
                        self.assertEqual((gate.PROJECT / ('stage-' + str(index))).exists(), index in seen)
                        self.assertEqual((gate.PROJECT / ('log-' + str(index))).exists(), index in seen)
                    if failure is not None:
                        self.assertEqual((gate.PROJECT / ('status-' + str(failure))).read_text(), '1')


class OutputPropagationTests(unittest.TestCase):
    def monitor(self, program):
        output = io.BytesIO()
        with patch.object(gate.sys, 'stdout', SimpleNamespace(buffer=output)):
            gate.monitor_setup_output([sys.executable, '-c', program])
        return output.getvalue()

    def test_clean_output_and_nonzero_status(self):
        self.assertEqual(self.monitor("print('Info: setup fixture')"), b'Info: setup fixture\n')
        with self.assertRaisesRegex(ValueError, 'subprocess exit: 7'):
            self.monitor('import sys; sys.exit(7)')

    def test_warning_zero_exit_and_stderr_markers_fail(self):
        for marker in gate.REJECTION_MARKERS:
            for fd in (1, 2):
                with self.subTest(marker=marker, fd=fd), self.assertRaisesRegex(ValueError, 'despite exit 0'):
                    self.monitor(f'import os; os.write({fd}, {marker!r})')

    def test_marker_across_read_boundaries(self):
        original_read = os.read
        with patch.object(gate.os, 'read', side_effect=lambda fd, size: original_read(fd, 1)):
            with self.assertRaisesRegex(ValueError, 'despite exit 0'):
                self.monitor("print('Critical Warning (125091): Tcl error: fixture')")

    def test_native_shell_blocks_stop_before_following_stage(self):
        # Execute actual native command blocks, not a copied implementation.
        # Replace ONLY the python3 entry with an inert output-monitor harness.
        # No vendor tool, native setup initialization or worktree is executed.
        source = Path(__file__).resolve().parents[3]
        syn = source / 'ofs-common/scripts/common/syn'
        setup = (syn / 'build_fim_setup.sh').read_text()
        pim = (syn / 'pim/ofs_pim_and_afu_config.sh').read_text()
        blocks = {
            'ip_lib': setup[setup.index('if [ ! -z ${ENA_SETUP_IP_LIB_SCRIPT} ]'):setup.index('######   OFSS')],
            'prepare': setup[setup.index('if [[ "${ENA_PR_SETUP}" == "1" && ! -z "${Q_PR_REVISION}" ]]'):setup.index('######   optional user post-setup script')],
            'pim_macros': pim[pim.index('if [ ! -z "${WORK_SYN_TOP_PATH}" ]'):pim.index('rm -rf "${PIM_ROOT_DIR}"')],
        }
        harness = ('import ia840f_experimental_gate as g, os, sys; '
                   'g.monitor_setup_output([sys.executable, "-c", os.environ["FIXTURE_PROGRAM"]])')
        with tempfile.TemporaryDirectory() as temp:
            env = dict(os.environ, PYTHONPATH=str(Path(__file__).parent), PYTHON=sys.executable,
                       HARNESS=harness, OFS_BOARD_CORE='ia840f', OFS_ROOTDIR=str(source),
                       ENA_SETUP_IP_LIB_SCRIPT='1', ENA_PR_SETUP='1', Q_PR_REVISION='ofs_pr_afu',
                       Q_REVISION='ofs_top', Q_PROJECT='ofs_top', WORK_SYN_TOP_PATH=temp,
                       PIM_INI_FILE=temp + '/ofs_agilex.ini')
            prefix = 'set -e\npython3() { command "$PYTHON" -c "$HARNESS"; }\n'
            for name, block in blocks.items():
                for program, status in [("print('Critical Warning (125091): Tcl error: IA840F NOT READY')", 1),
                                        ('import sys; sys.exit(7)', 1),
                                        ("print('clean inert fixture')", 0)]:
                    env['FIXTURE_PROGRAM'] = program
                    result = subprocess.run(['bash', '-c', prefix + block + '\nprintf "FOLLOWING_STAGE\\n"\n'],
                                            env=env, capture_output=True, text=True)
                    with self.subTest(block=name, program=program):
                        self.assertEqual(result.returncode, status, result.stderr)
                        self.assertEqual('FOLLOWING_STAGE' in result.stdout, status == 0)
                        if name == 'prepare' and status:
                            self.assertEqual(result.stdout.count('Critical Warning'), 1 if 'Critical Warning' in program else 0)
            subprocess.run(['bash', '-n', str(syn / 'pim/ofs_pim_and_afu_config.sh')], check=True)


class ShellAndPcieTests(unittest.TestCase):
    def test_shell_entries_reject_before_side_effects(self):
        source = Path(__file__).resolve().parents[3]
        scripts = source / 'ofs-common/scripts/common/syn'
        with tempfile.TemporaryDirectory() as temp:
            work = Path(temp) / 'work_ia840f_denied'
            env = dict(os.environ, OFS_ROOTDIR=temp, STAGE='setup', COPY_WORK='1')
            for script in ('build_fim.sh', 'build_fim_setup.sh', 'build_fim_compile.sh', 'build_fim_finish.sh'):
                result = subprocess.run(['bash', str(scripts / script), 'ia840f', str(work)], env=env, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertIn('IA840F EXPERIMENTAL GATE', result.stderr)
                self.assertEqual(list(Path(temp).iterdir()), [])
            for stage in ('all', 'setup', 'compile', 'finish'):
                result = subprocess.run(['bash', str(scripts / 'build_top.sh'), '--stage=' + stage, '-p', 'ia840f', str(work)], env=env, capture_output=True, text=True)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('IA840F EXPERIMENTAL GATE', result.stderr)
                self.assertEqual(list(Path(temp).iterdir()), [])
            env['OFS_BOARD_CORE'] = 'ia840f'
            result = subprocess.run(['bash', '-c', 'source "$1"', 'test', str(scripts / 'setup_opae_sdk.sh')], env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('bootstrap prohibited', result.stderr)
            self.assertEqual(list(Path(temp).iterdir()), [])
        for script in scripts.glob('build_fim*.sh'):
            subprocess.run(['bash', '-n', str(script)], check=True)
        subprocess.run(['bash', '-n', str(scripts / 'build_top.sh')], check=True)
        subprocess.run(['bash', '-n', str(scripts / 'setup_opae_sdk.sh')], check=True)

    def test_original_pcie_checks_retained(self):
        from ia840f_vendor_pcie import apply_ia840f_pcie_source
        obj = SimpleNamespace(platform='ia840f', ip_component='intel_pcie_ss_axi', ip_preset='',
                              num_pfs=2, pf_vf_count={'pf0': 1, 'pf1': 0}, ip_component_params={})
        for field, value in [('ip_component', 'wrong'), ('ip_preset', 'wrong'), ('num_pfs', 1),
                             ('pf_vf_count', {'pf0': 0, 'pf1': 1})]:
            candidate = copy.deepcopy(obj)
            setattr(candidate, field, value)
            with self.subTest(field=field), self.assertRaises(ValueError):
                apply_ia840f_pcie_source(candidate)
        with patch.object(gate, 'pcie_context') as context:
            apply_ia840f_pcie_source(obj)
            context.assert_called_once_with(obj)
        self.assertTrue(obj.ip_component_params)
        with patch('ia840f_vendor_pcie.hashlib.sha256') as digest:
            digest.return_value.hexdigest.return_value = 'wrong'
            with self.assertRaisesRegex(ValueError, 'hash mismatch'):
                apply_ia840f_pcie_source(obj)
        with patch('ia840f_vendor_pcie.ET.fromstring') as xml:
            xml.return_value.find.return_value.get.return_value = 'wrong'
            with self.assertRaisesRegex(ValueError, 'component mismatch'):
                apply_ia840f_pcie_source(obj)


if __name__ == '__main__':
    unittest.main()
