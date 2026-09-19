#!/usr/bin/env python3
"""Exclusive local inert evidence; never invokes preflight.main or namespaces."""
import ast
import hashlib
import importlib
import json
import os
from pathlib import Path
import subprocess
import sys
import unittest

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
os.umask(0o077)
OUT = HERE / 'verification-u02-02'
OUT.mkdir()  # retained, exclusive evidence; repeat invocation refuses
files = sorted(p.name for p in HERE.glob('*.py'))
before = {n: hashlib.sha256((HERE / n).read_bytes()).hexdigest() for n in files}
results = []
for name in ('test_local', 'test_b1b2', 'test_tool_roles'):
    module = importlib.import_module(name)
    if hasattr(module, 'BASE'):
        module.BASE = OUT / (name + '-fixtures')
        module.BASE.mkdir()
    with (OUT / (name + '.txt')).open('x') as stream:
        result = unittest.TextTestRunner(stream=stream, verbosity=2).run(
            unittest.defaultTestLoader.loadTestsFromModule(module))
    results.append({'module': name, 'tests': result.testsRun,
                    'failures': len(result.failures), 'errors': len(result.errors),
                    'skipped': len(result.skipped)})
for name in files:
    ast.parse((HERE / name).read_text(), feature_version=(3, 9))
after = {n: hashlib.sha256((HERE / n).read_bytes()).hexdigest() for n in files}
assert before == after, 'source changed during tests'
# Deliberately unapproved template: normal CLI must refuse before host/tool/claim.
manifest = HERE / 'HASHES.json'
template = HERE / 'parent-inputs.template.json'
command = [sys.executable, '-I', '-B', '-S', str(HERE / 'preflight.py'),
           '--bundle-sha256', hashlib.sha256(manifest.read_bytes()).hexdigest(),
           '--inputs', str(template), '--inputs-sha256', hashlib.sha256(template.read_bytes()).hexdigest(),
           '--acknowledge-partial-nonvendor-only']
refusal = subprocess.run(command, capture_output=True, text=True, timeout=5)
with (OUT / 'cli-refusal.json').open('x') as stream:
    json.dump({'command': command, 'returncode': refusal.returncode,
               'stdout': refusal.stdout, 'stderr': refusal.stderr}, stream, indent=2)
assert refusal.returncode == 2 and not refusal.stdout
receipt = json.loads(refusal.stderr)
assert receipt['status'] == 'REFUSED_BEFORE_CLAIM'
assert receipt['error'] == "RuntimeError('approval scope mismatch')"
assert receipt['retained_root'] is None and receipt['authorization'] is False
assert receipt['ready_for_build'] is False
record = {'python': sys.version, 'results': results, 'python39_grammar': 'pass',
          'command': 'python3 -I -B -S ' + str(HERE / 'run_local_u02.py'),
          'tested_sha256': before, 'manifest_sha256': hashlib.sha256(manifest.read_bytes()).hexdigest(),
          'cli_template_refusal': 'pass', 'remote_or_namespace_execution': False,
          'vendor_run': False, 'ready_for_build': False, 'authorization': False}
with (OUT / 'results.json').open('x') as stream:
    json.dump(record, stream, indent=2)
print(json.dumps(record, indent=2))
sys.exit(0 if all(r['failures'] == r['errors'] == r['skipped'] == 0 for r in results) else 1)
