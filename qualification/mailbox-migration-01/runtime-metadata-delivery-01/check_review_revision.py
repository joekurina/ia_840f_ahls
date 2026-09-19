"""Bounded inert unit/AST checks only; never invokes fixture.main or validate."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent

def main():
    phase = sys.argv[1]
    if phase not in ('red', 'red-confirmed', 'green'): raise SystemExit('red, red-confirmed or green required')
    target = ROOT / ('q1-q2-' + phase)
    target.mkdir()  # Preserve each result; never reuse.
    names = ('delivery.py', 'fixture.py', 'test_delivery.py', 'test_review_regressions.py', 'check_review_revision.py')
    bindings = {}
    for name in names:
        data = (ROOT/name).read_bytes()
        bindings[name] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
        ast.parse(data, feature_version=(3, 9))
    tests = ['test_review_regressions.CaptureTests', 'test_review_regressions.PrefixTests']
    if phase == 'green': tests.insert(0, 'test_delivery')
    command = [sys.executable, '-B', '-m', 'unittest', '-v'] + tests
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=60)
    (target/'unittest.txt').write_bytes(result.stdout)
    record = dict(command=command, cwd=str(ROOT), exit_status=result.returncode,
                  source_bindings=bindings, output_sha256=hashlib.sha256(result.stdout).hexdigest(),
                  grammar='Python 3.9 AST only; not runtime certification',
                  python=sys.version, scope='inert/mocked unit tests only; no live fixture rerun',
                  authorization=False, ready_for_build=False, vendor_run=False, remote_execution=False)
    (target/'checks.json').write_text(json.dumps(record, indent=2)+'\n')
    print(result.stdout.decode(), end='')
    print('Recorded exit status:', result.returncode)
    return result.returncode

if __name__ == '__main__': sys.exit(main())
