from pathlib import Path
import json,hashlib,base64,subprocess
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01')
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
checks=[]
for x in json.loads((Q/'prerequisites.json').read_text()):
 if 'sha256' in x:checks.append({'path':x['path'],'unchanged':sha(x['path'])==x['sha256']})
for x in json.loads((Q/'documents-provenance.json').read_text()):
 if 'source' in x and 'member' not in x:checks.append({'path':x['source'],'unchanged':sha(x['source'])==x['sha256']})
assert all(x['unchanged'] for x in checks)
(Q/'final-source-verification.json').write_text(json.dumps(checks,indent=2))
files={str(p.relative_to(Q)):{'sha256':sha(p),'base64':base64.b64encode(p.read_bytes()).decode()} for p in Q.rglob('*') if p.is_file()}
b=json.dumps({'files':files},sort_keys=True).encode();(Q/'export.json').write_bytes(b)
subprocess.run(['tmux','load-buffer','-b','ddr_sdk2026_01_evidence',str(Q/'export.json')],check=True)
print(json.dumps({'file_count':len(files),'export_sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}))
