from pathlib import Path
import os,json,hashlib
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');root=Path('/home/uwb_student00/Documents/IA-840f installation/')
rows=[];recipes=[];meta=[];archives=[]
if root.exists():
 for d,dirs,files in os.walk(root):
  dirs[:]=[x for x in dirs if x not in ['.git','node_modules']]
  for n in files:
   p=Path(d)/n
   if n in ['tennm_atoms.sv','tennm_atoms_ncrypt.sv','fmica_atoms_ncrypt.sv','modelsim.ini'] or (n=='_info' and 'tennm' in d):
    h=hashlib.sha256()
    if p.exists():
     with p.open('rb') as f:
      for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
     rows.append({'path':str(p),'bytes':p.stat().st_size,'sha256':h.hexdigest()})
   if n=='msim_setup.tcl':recipes.append({'path':str(p),'exists':p.exists(),'lines':[l for l in p.read_text().splitlines() if 'tennm_atoms' in l or 'fmica_atoms' in l] if p.exists() else []})
   if n in ['version.txt','readme.txt'] or n.endswith('.qpf'):meta.append(str(p))
   if n.endswith(('.tar','.tar.gz','.run','.rpm','.zip')):archives.append({'path':str(p),'bytes':p.stat().st_size if p.exists() else None})
out={'root':str(root),'exists':root.exists(),'top_level':[p.name for p in root.iterdir()] if root.exists() else [],'candidates':rows,'recipes':recipes,'metadata_paths':meta,'archive_inventory':archives}
(Q/'additional-vendor-inventory.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2)[:18000])
O=Q/'run-04'
for p in O.glob('*.log'):
 print('LOG',p.name,p.stat().st_size);print(p.read_text(errors='replace')[-1500:])
if (O/'result.json').exists():
 j=json.loads((O/'result.json').read_text());print('RESULT',json.dumps({k:v for k,v in j.items() if k not in ['reuse','imports']},indent=2))
