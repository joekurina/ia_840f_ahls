#!/usr/bin/env python3
"""Exclusive retained local evidence; no namespace/vendor/remote execution."""
import ast
import hashlib
import importlib
import json
import os
from pathlib import Path
import sys
import unittest

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
os.umask(0o077)
OUT = HERE / 'verification-b1b2-01'
OUT.mkdir()  # never overwrite evidence; a repeated invocation refuses
results = []
for name in ('test_local', 'test_b1b2'):
    module = importlib.import_module(name)
    module.BASE = OUT / (name + '-fixtures')
    module.BASE.mkdir()
    with (OUT / (name + '.txt')).open('x') as stream:
        result = unittest.TextTestRunner(stream=stream, verbosity=2).run(
            unittest.defaultTestLoader.loadTestsFromModule(module))
    results.append({'module': name, 'tests': result.testsRun,
                    'failures': len(result.failures), 'errors': len(result.errors)})
files = ('preflight.py', 'probe.py', 'test_local.py', 'test_b1b2.py', 'run_local_b1b2.py')
for name in files:
    ast.parse((HERE / name).read_text(), feature_version=(3, 9))
record = {'python': sys.version, 'results': results, 'python39_grammar': 'pass',
          'command': 'python3 -I -B -S ' + str(HERE / 'run_local_b1b2.py'),
          'tested_sha256': {n: hashlib.sha256((HERE / n).read_bytes()).hexdigest() for n in files},
          'remote_or_namespace_execution': False}
with (OUT / 'results.json').open('x') as stream:
    json.dump(record, stream, indent=2)
print(json.dumps(record, indent=2))
sys.exit(0 if all(r['failures'] == r['errors'] == 0 for r in results) else 1)
