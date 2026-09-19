"""Evidence runner. Executes synthetic tests only in a fresh evidence directory."""
import ast
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent

def digest(data):
    return dict(length=len(data), sha256=hashlib.sha256(data).hexdigest())

def main():
    label = sys.argv[1]
    if not label.replace('-', '').isalnum(): raise ValueError('label')
    out = ROOT / label
    out.mkdir()
    sources = {}
    for p in ROOT.glob('*.py'):
        data = p.read_bytes()
        (out/p.name).write_bytes(data)
        sources[p.name] = digest(data)
        ast.parse(data, filename=p.name, feature_version=(3,9))
    inputs = {}
    for p in ROOT.parent.rglob('*'):
        relative = p.relative_to(ROOT.parent)
        top = relative.parts[0]
        if p.is_file() and (top in ['runtime-metadata-'+n+'-01' for n in ('delivery','controller','receiver','launch','diagnostic')] or top.startswith(('u01','u02','u03'))):
            inputs[str(relative)] = digest(p.read_bytes())
    env = dict(os.environ, HS_EVIDENCE=str(out))
    argv = ['/usr/bin/python3','-B','-m','unittest','-v','test_startup']
    p = subprocess.run(argv,cwd=str(ROOT),env=env,capture_output=True,timeout=100)
    (out/'stdout.bin').write_bytes(p.stdout)
    (out/'stderr.bin').write_bytes(p.stderr)
    record = dict(argv=argv,cwd=str(ROOT),exit=p.returncode,stdout=digest(p.stdout),stderr=digest(p.stderr),sources=sources,inputs=inputs,python=sys.version,grammar='Python 3.9 AST only',authorization=False,ready_for_build=False,vendor_run=False,remote_execution=False)
    (out/'checks.json').write_text(json.dumps(record,indent=2)+'\n')
    print(p.stderr.decode())
    print(json.dumps({k:v for k,v in record.items() if k not in ('sources','inputs')},indent=2))
    return p.returncode

if __name__ == '__main__': sys.exit(main())
