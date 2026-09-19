import pathlib,json,hashlib,tarfile,os
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');A=json.loads((R/'repair-analysis.json').read_text());D=json.loads((R/'distributions-before.json').read_text());H=pathlib.Path.home();S=H/'.local/lib/python3.9/site-packages'
files=set()
for d in D:
 if d['name'] in A['remove']+A['current']:
  for f in d['files']:
   p=pathlib.Path(os.path.abspath(f));assert str(p).startswith(str(H/'.local')+'/'),p
   if p.is_file():files.add(p)
files.update(p for p in (H/'.local/bin').iterdir() if p.is_file() and p.name.startswith('bw_'))
manifest={str(p):dict(sha256=hashlib.sha256(p.read_bytes()).hexdigest(),mode=oct(p.stat().st_mode),size=p.stat().st_size) for p in sorted(files)}
with tarfile.open(R/'rollback-user-packages.tar.gz','w:gz') as t:
 for p in sorted(files):t.add(p,arcname=str(p.relative_to(H)),recursive=False)
(R/'rollback-manifest.json').write_text(json.dumps(manifest,indent=2));print('BACKUP',len(files), (R/'rollback-user-packages.tar.gz').stat().st_size,hashlib.sha256((R/'rollback-user-packages.tar.gz').read_bytes()).hexdigest())
for f in ['bw_core/product/__main__.py','bw_core/product/__init__.py','bw_agilex/agilex_product.py','bw_core/product/product.py']:
 p=S/f
 if p.exists():print('SOURCE',f);print(p.read_text());q=R/'source'/f;q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(p.read_bytes())
print('ENV', {k:v for k,v in os.environ.items() if k.startswith(('BWSDK','PIP','PYTHON'))});print('DONE')
