#!/usr/bin/env python3
"""Local-only narrow repair verification; invokes only inert Python tests."""
import difflib
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
OLD = HERE.parent / 'byte-line-questa-01'
NEW = HERE.parent / 'byte-line-questa-02'

def pin(p):
    return {'size': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}

def save(name, data):
    with (HERE / name).open('x') as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write('\n')

old_manifest = json.loads((OLD / 'package-sha256.json').read_text())
assert len(old_manifest) == 24
assert pin(OLD / 'package-sha256.json')['sha256'] == 'ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe'
old_all = {str(p.relative_to(OLD)): pin(p) for p in OLD.rglob('*') if p.is_file()}
assert all(old_all[n] == p for n, p in old_manifest.items())
expected_set = set(old_manifest) | {'package-sha256.json'}
assert {str(p.relative_to(NEW)) for p in NEW.rglob('*') if p.is_file()} == expected_set
assert not any(p.is_symlink() for p in NEW.rglob('*'))
new_manifest = {n: pin(NEW / n) for n in old_manifest}
changed = sorted(n for n in old_manifest if old_manifest[n] != new_manifest[n])
assert changed == ['README.md', 'run.py', 'test_runner.py']
assert (NEW / 'run.py').read_text() == (OLD / 'run.py').read_text().replace("                    for name in ('vlib', 'vlog', 'vsim')]", "                    for name in ('vlog', 'vsim')]")
inputs = json.loads((NEW / 'input-manifest.json').read_text())['inputs']
assert len(inputs) == 13
assert all(pin(NEW / i['copy']) == pin(OLD / i['copy']) == {'size': i['size'], 'sha256': i['sha256']} for i in inputs)
# The only rebuilt manifest is the fresh candidate's inventory.
(NEW / 'package-sha256.json').write_text(json.dumps(new_manifest, indent=2) + '\n')
before = {str(p.relative_to(NEW)): pin(p) for p in NEW.rglob('*') if p.is_file()}
with (HERE / 'old-new.diff').open('x') as f:
    for n in [*changed, 'package-sha256.json']:
        f.writelines(difflib.unified_diff((OLD/n).read_text().splitlines(True), (NEW/n).read_text().splitlines(True), fromfile='byte-line-questa-01/'+n, tofile='byte-line-questa-02/'+n))
save('pins-and-diff.json', {
    'old_manifest': pin(OLD / 'package-sha256.json'),
    'new_manifest': pin(NEW / 'package-sha256.json'),
    'manifest_members': len(new_manifest), 'payload_files': len(before),
    'input_count': len(inputs), 'all_inputs_byte_identical': True,
    'changed_members': {n: {'old': old_manifest[n], 'new': new_manifest[n]} for n in changed},
    'unchanged_members': sorted(set(old_manifest)-set(changed)),
    'excluded_unpinned_old_files': sorted(set(old_all)-expected_set),
    'run01_evidence': pin(HERE.parent / 'byte-line-questa-transfer-01/run-01-evidence.json')})
with tempfile.TemporaryDirectory(prefix='byte-line-questa-02-inert-') as d:
    copy = Path(d) / 'package'
    shutil.copytree(NEW, copy)
    cmd = [sys.executable, '-B', str(copy / 'test_runner.py')]
    proc = subprocess.run(cmd, cwd=copy, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=30)
    with (HERE / 'inert-tests-02.log').open('xb') as f:
        f.write(proc.stdout)
    save('inert-test-execution.json', {'argv': cmd, 'cwd': str(copy), 'rc': proc.returncode,
        'disposable_copy': True, 'vendor_executed': False, 'remote_contact': False,
        'log': pin(HERE / 'inert-tests-02.log')})
    print(proc.stdout.decode(), end='')
    assert proc.returncode == 0
assert before == {str(p.relative_to(NEW)): pin(p) for p in NEW.rglob('*') if p.is_file()}
assert old_all == {str(p.relative_to(OLD)): pin(p) for p in OLD.rglob('*') if p.is_file()}
assert json.loads((NEW / 'package-sha256.json').read_text()) == {n: pin(NEW / n) for n in old_manifest}
save('verification.json', {'status': 'PASS', 'candidate_unchanged_by_tests': True,
    'old_directory_unchanged': True, 'exact_payload_set': True, 'all_13_inputs_unchanged': True,
    'runner_diff_only_removes_vlib_version_probe': True, 'inert_suite_rc': proc.returncode,
    'new_manifest': pin(NEW / 'package-sha256.json'), 'hdl_compilation_executed': False,
    'hdl_simulation_executed': False, 'vendor_executed': False, 'remote_contact': False})
print(json.dumps({'changed_members': changed, 'new_manifest': pin(NEW / 'package-sha256.json'), 'status': 'PASS'}, indent=2))
