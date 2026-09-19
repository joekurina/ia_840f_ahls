from pathlib import Path
import os,json,hashlib
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');Q.mkdir(exist_ok=False)
roots=['/opt/intelFPGA_pro/23.1','/home/uwb_student00/IA-840f']
rows=[]; recipes=[]; metadata=[]
for root in roots:
 for d,dirs,files in os.walk(root):
  dirs[:]=[x for x in dirs if x not in ['.git','node_modules']]
  for n in files:
   p=Path(d)/n
   if ('tennm' in n.lower() and any(x in n.lower() for x in ['atom','iossm'])) or n in ['fmica_atoms_ncrypt.sv','modelsim.ini'] or (n=='_info' and 'tennm' in d):
    rows.append({'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
   if n=='msim_setup.tcl':recipes.append(str(p))
   if n in ['version.txt','version','quartus_version.txt'] or n.endswith('.qpf'):metadata.append(str(p))
out={'roots':roots,'candidates':rows,'recipes':recipes,'metadata':metadata}
(Q/'inventory.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2))
