from pathlib import Path
import os,sys,json,hashlib,subprocess,base64,tarfile,io
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12'
for name in ['test_header_dispatch.py','test_real_dispatch.py']:
 r=subprocess.run(['python3','-B',str(E/name)],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
 with (E/(Path(name).stem+'.final.log')).open('x') as f:f.write(r.stdout+r.stderr)
 assert r.returncode==0,(name,r.stdout,r.stderr)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
files=[p for p in sorted(E.rglob('*')) if p.is_file() and not p.is_symlink() and 'inherited-output' not in p.relative_to(E).parts and '__pycache__' not in p.parts]
assert not (E/'review-package-sha256.json').exists()
manifest={str(p.relative_to(E)):sha(p) for p in files}
with (E/'review-package-sha256.json').open('x') as f:json.dump(manifest,f,indent=2)
files.append(E/'review-package-sha256.json')
transfer={str(p.relative_to(E)):dict(sha256=sha(p),bytes=p.stat().st_size) for p in files}
archive=io.BytesIO()
with tarfile.open(fileobj=archive,mode='w:gz') as tf:
 for p in files:tf.add(p,arcname=str(p.relative_to(E)),recursive=False)
data=archive.getvalue()
print(json.dumps(dict(batch='work12-final-review-package',files=transfer,archive_sha256=hashlib.sha256(data).hexdigest(),archive_bytes=len(data),archive_b64=base64.b64encode(data).decode())))
