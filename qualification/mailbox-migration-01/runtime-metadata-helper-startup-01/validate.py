"""Static-only proposal validation. Never executes transport or generated shell."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import startup

ROOT = Path(__file__).resolve().parent

def digest(data):
    return dict(length=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    source = ROOT.parent/'runtime-metadata-launch-01/transport.py'
    payload = source.read_bytes()
    assert digest(payload) == dict(length=41045,sha256='29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60')
    text = startup.command(payload,'d'*32)
    assert startup.extract_payload(text) == payload
    assert max(map(len,text.splitlines())) < 1024
    with (ROOT/'proposed-command.txt').open('x') as f: f.write(text)
    argv = ['/bin/bash','--noprofile','--norc','-n',str(ROOT/'proposed-command.txt')]
    p = subprocess.run(argv,capture_output=True,timeout=5)
    assert p.returncode == 0, p.stderr
    (ROOT/'syntax.stdout.bin').write_bytes(p.stdout)
    (ROOT/'syntax.stderr.bin').write_bytes(p.stderr)
    grammar = []
    for path in ROOT.glob('*.py'):
        ast.parse(path.read_bytes(),filename=path.name,feature_version=(3,9))
        grammar.append(path.name)
    old = json.loads((ROOT/'red/checks.json').read_text())['inputs']
    current = {name:digest((ROOT.parent/name).read_bytes()) for name in old}
    assert current == old, 'immutable input drift'
    green = json.loads((ROOT/'green/checks.json').read_text())
    assert green['exit'] == 0
    for name,binding in green['sources'].items():
        assert digest((ROOT/name).read_bytes()) == binding, 'green source drift: '+name
    fixtures = sorted((ROOT/'green').glob('*/result.json'))
    for path in fixtures:
        result = json.loads(path.read_text())
        cleanup = json.loads((path.parent/'fixture-cleanup.json').read_text())
        assert not cleanup['forced_bash_kill']
        assert result['exit'] == 0
        assert all(result[k] is False for k in ('authorization','ready_for_build','vendor_run','remote_execution'))
    result = dict(argv=sys.argv,python=sys.version,transport_read_only=digest(payload),proposal=digest(text.encode()),
                  syntax=dict(argv=argv,exit=p.returncode,stdout=digest(p.stdout),stderr=digest(p.stderr)),
                  grammar=sorted(grammar),grammar_only_not_python39_runtime=True,
                  immutable_inputs_verified=len(old),green_source_bindings_verified=True,
                  synthetic_fixtures=len(fixtures),no_forced_fixture_kills=True,
                  authorization=False,ready_for_build=False,vendor_run=False,remote_execution=False)
    with (ROOT/'validation.json').open('x') as f: json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps(result,indent=2))

if __name__ == '__main__': main()
