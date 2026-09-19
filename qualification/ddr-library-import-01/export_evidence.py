from pathlib import Path
import json,hashlib,base64,gzip,subprocess
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');P=Q.parent/'ddr-smoke-02'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert (Q/'run-05/result.json').exists() and (Q/'launch-v3-result.json').exists()
r3=json.loads((P/'run-03/result.json').read_text());inv={str(f.relative_to(P/'run-03/libraries')):sha(f) for f in (P/'run-03/libraries').rglob('*') if f.is_file()};old=r3['reuse']['library_sha256'];diff={'added':sorted(set(inv)-set(old)),'removed':sorted(set(old)-set(inv)),'changed':[n for n in old if n in inv and old[n]!=inv[n]]};(Q/'run03-reuse-rejection.json').write_text(json.dumps(diff,indent=2))
history={str(p):sha(p) for p in [P/'run_smoke.py',P/'manifest.json',P/'tb_mem_ss_smoke.sv',P/'run-01/result.json',P/'run-02/result.json',P/'run-03/result.json',P/'run-01/elaborate-run.log',P/'run-02/elaborate-run.log',P/'run-03/elaborate-run.log']};(Q/'historical-readback-hashes.json').write_text(json.dumps(history,indent=2))
checks=[]
for row in json.loads((Q/'compatibility-evidence.json').read_text())['recipes']:
 if 'sha256' in row:checks.append({'path':row['path'],'unchanged':sha(Path(row['path']))==row['sha256']})
(Q/'vendor-recipe-readback.json').write_text(json.dumps(checks,indent=2));assert all(x['unchanged'] for x in checks)
files=[p for p in Q.iterdir() if p.is_file() and p.suffix in ['.json','.py','.txt','.log']]
for n in ['run-04','run-05']:files += [p for p in (Q/n).iterdir() if p.is_file() and p.suffix in ['.json','.log','.ini','.do']]
rows={str(p.relative_to(Q)):{'sha256':sha(p),'data':base64.b64encode(p.read_bytes()).decode()} for p in files}
data=base64.b64encode(gzip.compress(json.dumps(rows).encode()));f=Q/'evidence-export.b64';f.write_bytes(data);h=sha(f)
subprocess.run(['tmux','load-buffer','-b','ddr_library_import_01_evidence',str(f)],check=True)
receipt={'export_sha256':h,'bytes':len(data),'files':len(rows),'buffer':'ddr_library_import_01_evidence'};(Q/'export-receipt.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt));print('RUN03_REUSE_DIFF',diff)
for n in ['run-04','run-05']:
 j=json.loads((Q/n/'result.json').read_text());print(n,json.dumps({k:v for k,v in j.items() if k not in ['reuse','steps','imports','precompiled_import']},indent=2))
