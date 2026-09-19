from pathlib import Path
import zipfile,json,hashlib,re,subprocess
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
root=Path('/usr/share/bittware-sdk');hashes={str(p):sha(p) for p in root.rglob('*') if p.is_file()};(Q/'sdk-hashes-before.json').write_text(json.dumps(hashes,indent=2))
archives=[];hits=[]
for p in (root/'python').glob('bw_*.whl'):
 with zipfile.ZipFile(p) as z:
  entries=z.namelist();archives.append({'path':str(p),'sha256':sha(p),'members':entries})
  for n in entries:
   if n.endswith('/') :continue
   if any(x in n.lower() for x in ['840','csp','readme','release','simul','tennm','patch']):print('MEMBER',p.name,n)
   if n.endswith(('.py','.json','.md','.txt','.yaml','.yml','METADATA')):
    text=z.read(n).decode(errors='replace')
    lines=[{'line':i,'text':l} for i,l in enumerate(text.splitlines(),1) if re.search(r'quartus|questa|modelsim|tennm|csp|2024\.4\.1',l,re.I)]
    if lines:hits.append({'archive':str(p),'member':n,'sha256':hashlib.sha256(z.read(n)).hexdigest(),'matches':lines})
(Q/'wheel-inventory.json').write_text(json.dumps(archives,indent=2));(Q/'wheel-hits.json').write_text(json.dumps(hits,indent=2));print('HITS',json.dumps(hits)[:20000])
files=[]
for d in ['/home/uwb_student00/IA-840f','/home/uwb_student00/Documents/IA-840f installation']:
 for p in Path(d).rglob('*'):
  if p.is_file() and (any(x in p.name.lower() for x in ['2026','sdk','csp','release','readme','patch']) or p.suffix=='.pdf'):
   files.append({'path':str(p),'bytes':p.stat().st_size})
(Q/'vendor-package-files.json').write_text(json.dumps(files,indent=2))
for x in files:print('VENDOR',x)
