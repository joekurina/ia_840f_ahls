"""Local inert gate/CMake checks; no Quartus executable is invoked."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from typing import Any
from unittest.mock import patch

E = Path(__file__).resolve().parent
out = E/'candidate-inert08.json'
assert not out.exists(), 'preserve previous test result'
root = Path(tempfile.mkdtemp(prefix='ia840f-migration22-inert-', dir=os.environ['TMPDIR']))
spec = importlib.util.spec_from_file_location('migration_gate_fixture', E/'candidate01/ia840f_migration_gate.py')
assert spec is not None and spec.loader is not None
module: Any = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.E = root/'evidence'
module.W = root/'work'
module.PROJECT = module.W/'syn/board/ia840f/syn_top'
module.PROJECT.mkdir(parents=True)
module.TOOL_ROOT = root/'inert-tool'
(module.TOOL_ROOT/'linux64').mkdir(parents=True)
exe = module.TOOL_ROOT/'linux64/quartus_ipgenerate'
exe.write_text('INERT HASH INPUT ONLY; NEVER EXECUTED\n')
qsf = module.PROJECT/'ofs_top.qsf'
qsf.write_bytes((E/'candidate01/ofs_top.qsf').read_bytes())
operation = module.E/'operations/ip_inventory'
operation.mkdir(parents=True)
authority = operation/'authority.json'
alias = module.W/'bound_qsf'
alias.symlink_to('syn/board/ia840f/syn_top/ofs_top.qsf')
escape = module.W/'escaped_input'
escape.symlink_to(exe)
runner = {'pid': 90101, 'ppid': 1, 'start_ticks': '12345', 'exe': '/usr/bin/python3',
          'cwd': str(root), 'argv': ['python3', 'inert-supervisor']}
parent = {'pid': 90102, 'ppid': runner['pid'], 'start_ticks': '12346', 'exe': str(exe),
          'cwd': str(module.PROJECT), 'argv': ['quartus_ipgenerate', '-t', 'inert-input.tcl']}
record = {'approved': True, 'ready_for_build': False, 'scope': 'ia840f-ofs2026-native-ip_inventory',
          'project': str(module.PROJECT), 'part': 'AGFB027R25A2E2V',
          'toolchain': 'Quartus Prime Pro 26.1.1 Build 130', 'runner': runner,
          'contexts': [{'exe': parent['exe'], 'cwd': parent['cwd'], 'argv': parent['argv'][1:]}],
          'runtime_hashes': {str(exe): module.sha(exe)}, 'critical_inputs': {str(qsf): module.sha(qsf)}, 'critical_links': {str(alias): os.readlink(alias)}}
env = {'IA840F_MIGRATION_AUTHORITY': str(authority), 'QUARTUS_ROOTDIR_OVERRIDE': str(module.TOOL_ROOT),
       'OFS_ROOTDIR': str(module.W)}
results = []


def trial(label, mutate_record=None, mutate_parent=None, mutate_env=None, expected=True):
    rec = copy.deepcopy(record)
    par = copy.deepcopy(parent)
    variables = dict(env)
    if mutate_record:
        mutate_record(rec)
    if mutate_parent:
        mutate_parent(par)
    if mutate_env:
        mutate_env(variables)
    authority.write_text(json.dumps(rec))
    before = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in root.rglob('*') if p.is_file()}
    with patch.dict(os.environ, variables, clear=True), patch.object(sys, 'argv', ['guard', 'quartus']), \
         patch.object(module, 'proc', lambda pid: copy.deepcopy(runner if pid == runner['pid'] else par)):
        try:
            module.check()
            passed = True
            error = None
        except Exception as exc:
            passed = False
            error = type(exc).__name__
    assert passed == expected, (label, passed, expected)
    after = {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
             for p in root.rglob('*') if p.is_file()}
    assert before == after, label
    results.append({'case': label, 'expected_accept': expected, 'observed_accept': passed,
                    'error_type': error, 'fixture_files_unchanged': True})


trial('valid synthetic identity')
trial('changed link target', lambda r: r['critical_links'].update({str(alias): 'wrong-target'}), expected=False)
trial('link escapes WORK', lambda r: r['critical_links'].update({str(escape): str(exe)}), expected=False)
trial('unapproved', lambda r: r.update(approved=False), expected=False)
trial('wrong scope', lambda r: r.update(scope='native-anything'), expected=False)
trial('wrong part', lambda r: r.update(part='OTHER'), expected=False)
trial('wrong version', lambda r: r.update(toolchain='25.1'), expected=False)
trial('extra argv', mutate_parent=lambda p: p['argv'].append('--unreviewed'), expected=False)
trial('wrong cwd', mutate_parent=lambda p: p.update(cwd=str(root)), expected=False)
trial('bad tool hash', lambda r: r['runtime_hashes'].update({str(exe): '0'*64}), expected=False)
trial('bad input hash', lambda r: r['critical_inputs'].update({str(qsf): '0'*64}), expected=False)
trial('reused runner identity', lambda r: r['runner'].update(start_ticks='wrong'), expected=False)
trial('no live ancestry', mutate_parent=lambda p: p.update(ppid=1), expected=False)
trial('wrong authority path', mutate_env=lambda v: v.update(IA840F_MIGRATION_AUTHORITY=str(root/'unknown.json')), expected=False)
trial('stale override', mutate_env=lambda v: v.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/25.1/quartus'), expected=False)
trial('OPAE template mode', mutate_env=lambda v: v.update(OPAE_PLATFORM_GEN='0'), expected=False)
# Real rejection entry also must leave a consumed-like fixture unchanged.
authority.write_text(json.dumps(record))
with patch.dict(os.environ, {}, clear=True), patch.object(sys, 'argv', ['guard', 'quartus']), contextlib.redirect_stderr(io.StringIO()) as stderr:
    assert module.main() == 1
    assert 'IA840F_GATE_REJECTED' in stderr.getvalue()
assert not (operation/'gate-rejections.jsonl').exists() and not (operation/'gate-events.jsonl').exists()
cmake = shutil.which('cmake')
assert cmake, 'local CMake unavailable; fixture configure not run'
commands = []
for label, args, expected in [
    ('configure', ['-S', str(E/'candidate01'), '-B', str(root/'cmake-build'),
                   '-DFIM_PROJECT='+str(module.PROJECT), '-DIP_INVENTORY_OUTPUT='+str(root/'ip-inventory.tcl')], 0),
    ('list-targets', ['--build', str(root/'cmake-build'), '--target', 'help'], 0),
    ('reject-old-toolchain', ['-S', str(E/'candidate01'), '-B', str(root/'cmake-reject'),
                   '-DFIM_PROJECT='+str(module.PROJECT), '-DIP_INVENTORY_OUTPUT='+str(root/'ip-inventory.tcl'),
                   '-DQUARTUS_ROOT=/opt/altera/25.1/quartus'], 1),
]:
    p = subprocess.run([cmake, *args], capture_output=True, text=True, timeout=30)
    assert (p.returncode == 0) == (expected == 0), (label, p.returncode, p.stderr)
    if label == 'list-targets':
        assert all(name in p.stdout for name in module.STAGES), p.stdout
    commands.append({'label': label, 'argv': [cmake, *args], 'rc': p.returncode,
                     'stdout': p.stdout, 'stderr': p.stderr})
result = {'success': True, 'fixture_scope': 'synthetic process/tool identities; hash-only fake tool never executed',
          'native_tool_execution': False, 'scratch_root': str(root), 'gate_cases': results,
          'real_missing_authority_rejection': True, 'cmake_commands': commands,
          'candidate_sha256': {p.name: module.sha(p) for p in (E/'candidate01').iterdir() if p.is_file()}}
out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'success': True, 'gate_case_count': len(results), 'cmake_check_count': len(commands),
                  'native_tool_execution': False, 'output': str(out)}, indent=2))
