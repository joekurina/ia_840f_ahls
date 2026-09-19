#!/usr/bin/env python3
"""Reproduce local acceptance evidence; uses Python and git diff checking only."""
import difflib
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

P=Path(__file__).resolve().parent
HERE=P/'candidate/source/ipss/ia840f'
CAP=P/'baseline/review/captured'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    logs=P/'verification'
    logs.mkdir(exist_ok=True)
    before={str(f.relative_to(P)):sha(f) for tree in (P/'baseline',P/'candidate') for f in tree.rglob('*') if f.is_file() and '__pycache__' not in f.parts}
    (logs/'inventory-before.json').write_text(json.dumps(before,indent=2,sort_keys=True)+'\n')
    commands=[
        [sys.executable,'-B','-m','unittest','-v','test_bank_spreading'],
        [sys.executable,'-B','stage_candidate.py'],
        [sys.executable,'-B',str(HERE/'derive_presets.py'),'--vendor-root',str(P/'baseline/vendor')],
        [sys.executable,'-B','stage_candidate.py'],
    ]
    results=[]
    for i,argv in enumerate(commands):
        result=subprocess.run(argv,cwd=P,capture_output=True,text=True,env={**os.environ,'PYTHONDONTWRITEBYTECODE':'1'})
        name=f'{i+1:02d}.log'
        (logs/name).write_text(result.stdout+result.stderr)
        results.append({'argv':argv,'cwd':str(P),'returncode':result.returncode,'log':name})
    spec=importlib.util.spec_from_file_location('original',CAP/'04-derive_presets.py')
    original=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(original)
    baseline=original.derive(P/'candidate/source',P/'baseline/vendor')
    aliases={'derive_presets.py':'04-derive_presets.py','preset_derivation.json':'05-preset_derivation.json',
             'presets/ia840f_mem.qprs':'06-ia840f_mem.qprs','presets/ia840f_pcie_known_schema.qprs':'07-ia840f_pcie_known_schema.qprs','presets/ia840f_sim.qprs':'08-ia840f_sim.qprs'}
    for name,data in baseline.items():
        if data!=(CAP/aliases[name]).read_bytes():
            raise ValueError('original fixture derivation mismatch: '+name)
    changes=[]
    diff=[]
    for name,cap in aliases.items():
        a=CAP/cap;b=HERE/name
        if a.read_bytes()!=b.read_bytes():
            changes.append({'path':'ipss/ia840f/'+name,'before_sha256':sha(a),'after_sha256':sha(b)})
            diff.extend(difflib.unified_diff(a.read_text().splitlines(True),b.read_text().splitlines(True),fromfile='a/ipss/ia840f/'+name,tofile='b/ipss/ia840f/'+name))
    assert {e['path'] for e in changes}=={'ipss/ia840f/derive_presets.py','ipss/ia840f/preset_derivation.json','ipss/ia840f/presets/ia840f_mem.qprs'}
    (P/'candidate.patch').write_text(''.join(diff))
    after={str(f.relative_to(P)):sha(f) for tree in (P/'baseline',P/'candidate') for f in tree.rglob('*') if f.is_file() and '__pycache__' not in f.parts}
    (logs/'inventory-after.json').write_text(json.dumps(after,indent=2,sort_keys=True)+'\n')
    assert before==after,'verification changed inputs or candidate'
    result={'commands':results,'original_four_artifacts_reproduced':True,'baseline_and_candidate_unchanged_by_tests':True,
            'changed_artifacts':changes,'execution_ready':False,'vendor_invocations':0}
    (logs/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
    if any(e['returncode']!=0 for e in results):
        raise SystemExit(1)


if __name__=='__main__':
    main()
