from pathlib import Path
import subprocess,json,hashlib,base64
Q=Path(__file__).parent
b=subprocess.check_output(['ssh','-o','BatchMode=yes','uwb_student00@100.101.227.97','tmux save-buffer -b ddr_sdk2026_01_evidence -'])
h=hashlib.sha256(b).hexdigest();assert h=='3ea20ef57a6a5aa472f826fc3f92a8e865bd2c764d4a4afdc6777b937bdd7dee'
r=json.loads(b);assert len(r['files'])==21
out=Q/'readback';out.mkdir(exist_ok=False)
for n,x in r['files'].items():
 p=out/n;assert p.resolve().is_relative_to(out.resolve());p.parent.mkdir(parents=True,exist_ok=True);data=base64.b64decode(x['base64']);assert hashlib.sha256(data).hexdigest()==x['sha256'];p.write_bytes(data)
verification={'export_sha256':h,'file_count':len(r['files']),'all_files_verified':True,'files':{n:x['sha256'] for n,x in r['files'].items()}}
(Q/'retrieval-verification.json').write_text(json.dumps(verification,indent=2))
print(json.dumps({k:v for k,v in verification.items() if k!='files'},indent=2))
