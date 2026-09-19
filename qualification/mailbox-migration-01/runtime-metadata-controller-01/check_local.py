"""Run only local synthetic unit tests and bind the exact tested sources."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import sys


def main():
    here = Path(__file__).resolve().parent
    target = here / sys.argv[1]
    target.mkdir(exist_ok=False)
    sources = [here / 'test_controller.py', here / 'controller.py', here / 'check_local.py']
    sources += [here.parent / x for x in (
        'runtime-metadata-delivery-01/delivery.py',
        'runtime-metadata-delivery-01/fixture.py',
        'runtime-metadata-receiver-01/receiver.py',
        'runtime-metadata-launch-01/transport.py',
        'runtime-metadata-launch-01/launcher.py',
        'runtime-metadata-diagnostic-01/collector.py')]
    bindings = {}
    for path in sources:
        if not path.exists():
            bindings[str(path.relative_to(here.parent))] = {'absent': True}
            continue
        data = path.read_bytes()
        ast.parse(data, feature_version=(3, 9))
        bindings[str(path.relative_to(here.parent))] = dict(length=len(data), sha256=hashlib.sha256(data).hexdigest())
    # Keep exact test/runner versions for RED provenance, not only hashes.
    for name in ('test_controller.py', 'controller.py', 'check_local.py'):
        source = here / name
        if source.exists():
            with (target / name).open('xb') as f:
                f.write(source.read_bytes())
    argv = [sys.executable, '-B', '-m', 'unittest', '-v', 'test_controller']
    run = subprocess.run(argv, cwd=here, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with (target / 'unittest.txt').open('xb') as f:
        f.write(run.stdout)
    record = dict(argv=argv, cwd=str(here), exit_status=run.returncode,
                  python=sys.version, scope='SYNTHETIC_ONLY', sources=bindings,
                  ast_python39_grammar=True, python39_runtime_certified=False,
                  output_sha256=hashlib.sha256(run.stdout).hexdigest(),
                  authorization=False, ready_for_build=False, vendor_run=False)
    with (target / 'checks.json').open('x') as f:
        json.dump(record, f, indent=2)
        f.write('\n')
    print(run.stdout.decode(), end='')
    return run.returncode


if __name__ == '__main__':
    sys.exit(main())
