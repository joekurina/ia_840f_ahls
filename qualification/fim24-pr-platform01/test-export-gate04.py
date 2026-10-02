"""Inert release-gate/CMake fixtures; no vendor/project/hardware execution."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import Any
from unittest.mock import patch

E = Path(__file__).resolve().parent
OUT = E/'export-gate-inert04.json'
assert not OUT.exists()
root = Path(tempfile.mkdtemp(prefix='ia840f-pr24-inert-', dir=os.environ['TMPDIR']))
source = E/'candidate03/ia840f_release_gate01.py'
spec = importlib.util.spec_from_file_location('release_gate_fixture', source)
assert spec is not None and spec.loader is not None
module: Any = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
module.R = root/'operation'
module.D = root/'base'
module.T = root/'release'
module.J = module.D/'syn/board/ia840f/syn_top'
module.Q = root/'inert-tool'
module.R.mkdir()
module.J.mkdir(parents=True)
(module.Q/'linux64').mkdir(parents=True)
exe = module.Q/'linux64/quartus_sh'
exe.write_text('INERT HASH INPUT ONLY; NEVER EXECUTED\n')
qsf = module.J/'ofs_pr_afu.qsf'
qsf.write_text('set_global_assignment -name FAMILY "Agilex 7"\nset_global_assignment -name DEVICE AGFB027R25A2E2V\nset_global_assignment -name TOP_LEVEL_ENTITY top\nset_global_assignment -name REVISION_TYPE PR_IMPL\n')
self_base = module.D/'syn/board/ia840f/setup/ia840f_release_gate01.py'
self_release = module.T/'hw/lib/build/syn/board/ia840f/setup/ia840f_release_gate01.py'
for p in (self_base, self_release):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_bytes(source.read_bytes())
runner = {'pid': 90101, 'ppid': 1, 'start_ticks': '12345', 'exe': '/usr/bin/python3', 'cwd': str(root), 'argv': ['python3', 'inert-owner']}
parent = {'pid': 90102, 'ppid': 90101, 'start_ticks': '12346', 'exe': str(exe), 'cwd': str(module.J), 'argv': ['quartus_sh', '--prepare', '-r', 'ofs_pr_afu', 'ofs_top']}
restore = dict(parent, cwd=str(module.T/'hw/lib/build'), argv=['quartus_sh', '--restore', str(root/'owned.qar')])
contexts = [{'exe': p['exe'], 'cwd': p['cwd'], 'argv': p['argv'][1:]} for p in (parent, restore)]
record = {'approved': True, 'ready_for_build': False, 'scope': 'release-only', 'project': str(module.J), 'part': 'AGFB027R25A2E2V', 'toolchain': 'Quartus Prime Pro 26.1.1 Build 130', 'guard_sha256': module.sha(self_base), 'runner': runner, 'contexts': contexts, 'runtime_hashes': {str(exe): module.sha(exe)}, 'critical_inputs': {str(qsf): module.sha(qsf)}}
env = {'OPAE_PLATFORM_GEN': '1', 'QUARTUS_ROOTDIR_OVERRIDE': str(module.Q), 'OFS_ROOTDIR': str(module.D)}
rows = []


def inventory():
    return {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file()}


def trial(name, record_change=None, parent_change=None, env_change=None, self_path=None, accept=False):
    r = copy.deepcopy(record)
    p = copy.deepcopy(parent)
    e = dict(env)
    if record_change:
        record_change(r)
    if parent_change:
        parent_change(p)
    if env_change:
        env_change(e)
    (module.R/'authority.json').write_text(json.dumps(r))
    module.__file__ = str(self_path or self_base)
    before = inventory()
    with patch.dict(os.environ, e, clear=True), patch.object(sys, 'argv', ['inert-gate', 'quartus']), patch.object(module, 'proc', lambda pid: copy.deepcopy(runner if pid == runner['pid'] else p)):
        try:
            module.check()
            passed = True
            error = None
        except Exception as exc:
            passed = False
            error = type(exc).__name__
    assert passed is accept, (name, passed, accept, error)
    assert before == inventory(), name
    rows.append({'case': name, 'expected_accept': accept, 'observed_accept': passed, 'error': error, 'fixture_bytes_unchanged': True})


trial('valid synthetic prepare', accept=True)
trial('valid synthetic restored callback', parent_change=lambda p: p.update(restore), self_path=self_release, accept=True)
trial('approval false', record_change=lambda r: r.update(approved=False))
trial('readiness true', record_change=lambda r: r.update(ready_for_build=True))
trial('wrong scope', record_change=lambda r: r.update(scope='compile'))
trial('wrong part', record_change=lambda r: r.update(part='OTHER'))
trial('wrong version', record_change=lambda r: r.update(toolchain='25.1'))
trial('missing OPAE mode', env_change=lambda e: e.pop('OPAE_PLATFORM_GEN'))
trial('OPAE zero is not release mode', env_change=lambda e: e.update(OPAE_PLATFORM_GEN='0'))
trial('old tool override', env_change=lambda e: e.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/25.1/quartus'))
trial('wrong source root', env_change=lambda e: e.update(OFS_ROOTDIR=str(root)))
trial('wrong self location', self_path=root/'unexpected.py')
trial('bad guard bytes', record_change=lambda r: r.update(guard_sha256='0'*64))
trial('extra native argument', parent_change=lambda p: p['argv'].append('--unreviewed'))
trial('wrong native cwd', parent_change=lambda p: p.update(cwd=str(root)))
trial('bad tool hash', record_change=lambda r: r['runtime_hashes'].update({str(exe): '0'*64}))
trial('bad input hash', record_change=lambda r: r['critical_inputs'].update({str(qsf): '0'*64}))
trial('empty inputs', record_change=lambda r: r.update(critical_inputs={}))
trial('no live ancestry', parent_change=lambda p: p.update(ppid=1))
trial('stale supervisor start', record_change=lambda r: r['runner'].update(start_ticks='wrong'))
module.__file__ = str(self_base)
before = inventory()
with patch.dict(os.environ, {}, clear=True), patch.object(sys, 'argv', ['inert-gate', 'quartus']), contextlib.redirect_stderr(io.StringIO()) as captured:
    assert module.main() == 1
    assert 'IA840F_GATE_REJECTED' in captured.getvalue()
assert inventory() == before and not (module.R/'gate-events.jsonl').exists() and not (module.R/'gate-rejections.jsonl').exists()

fake_base = root/'cmake-base'
script = fake_base/'ofs-common/scripts/common/syn/generate_pr_release.sh'
script.parent.mkdir(parents=True)
script.write_text('# INERT FILE PRESENCE ONLY; NEVER EXECUTED\n')
target = root/'absent-release'
commands = []
base_args = ['-S', str(E/'candidate03'), '-DFIM_BASE='+str(fake_base), '-DRELEASE_TARGET='+str(target)]
for name, args, expected in [
    ('configure', [*base_args, '-B', str(root/'cmake-build')], True),
    ('target-list', ['--build', str(root/'cmake-build'), '--target', 'help'], True),
    ('reject-old-tool', [*base_args, '-B', str(root/'cmake-old'), '-DQUARTUS_ROOT=/opt/altera/25.1/quartus'], False),
    ('reject-existing-release', [*base_args, '-B', str(root/'cmake-existing'), '-DRELEASE_TARGET='+str(root)], False),
    ('reject-relative-base', [*base_args, '-B', str(root/'cmake-relative'), '-DFIM_BASE=relative'], False),
]:
    p = subprocess.run(['cmake', *args], capture_output=True, text=True, timeout=30)
    assert (p.returncode == 0) is expected, (name, p.returncode, p.stderr)
    if name == 'target-list':
        assert 'export' in p.stdout and 'version' in p.stdout
    commands.append({'case': name, 'argv': ['cmake', *args], 'rc': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr})
result = {'success': True, 'native_tool_execution': False, 'scope': 'synthetic identities, hash-only fake tools, actual gate entry rejection and CMake configure/help only; not native integration', 'gate_cases': rows, 'gate_case_count': len(rows), 'rejected_main_preserved_all_bytes': True, 'cmake_checks': commands, 'cmake_check_count': len(commands), 'scratch': str(root), 'candidate_hashes': {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (E/'candidate03').iterdir() if p.is_file()}}
OUT.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'success': True, 'gate_cases': len(rows), 'cmake_checks': len(commands), 'native_tool_execution': False, 'output': str(OUT)}, indent=2))
