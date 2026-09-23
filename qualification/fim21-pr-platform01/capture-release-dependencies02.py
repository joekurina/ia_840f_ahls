import os,socket,subprocess,hashlib,json,gzip,base64,re,shutil
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
B=Path('/home/uwb_student00/ahls/new_BSP');D=B/'work_fim21_pr_platform01/base01';P=B/'ofs-platform-afu-bbb/plat_if_develop';R=B/'work_fim21_pr_platform01/preflight02';assert not R.exists()
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(4*1024*1024),b''):h.update(b)
 return h.hexdigest()
out={'paths':{},'tools':{},'pim_inventory':{},'source_files':{},'installed_archive_files':[],'hardware_access':False,'native_execution':False}
for n in ('bin/quartus_sh','linux64/quartus_sh','bin/quartus_syn','linux64/quartus_syn'):
 p=Path('/opt/altera/25.1/quartus')/n;out['tools'][n]={'path':str(p),'sha256':sha(p)}
for root in [P]:
 for d,dirs,files in os.walk(root,followlinks=False):
  dirs[:]=[n for n in dirs if n not in ('.git','__pycache__')]
  for n in files:
   p=Path(d)/n
   if p.suffix=='.pyc':continue
   assert p.resolve().is_relative_to(root),str(p)
   out['pim_inventory'][str(p.relative_to(root))]={'bytes':p.stat().st_size,'sha256':sha(p)}
for d,dirs,files in os.walk(D,followlinks=False):
 dirs[:]=[n for n in dirs if n not in ('output_files','qdb','db','__pycache__')]
 for n in files:
  p=Path(d)/n
  if p.suffix not in {'.qsf','.qpf','.qip','.ip','.qsys','.tcl','.sdc','.json','.xml','.py','.sh','.sv','.v','.txt','.ini'} or p.stat().st_size>4_000_000:continue
  s=p.read_text(errors='replace');hits=[]
  for i,l in enumerate(s.splitlines(),1):
   if any(x in l for x in ('/home/uwb_student00/ahls/new_BSP/work_','/opt/altera/23.1','/opt/altera/26.1','/tmp/')):hits.append({'line':i,'text':l[:500]})
  if hits:out['paths'][str(p.relative_to(D))]=hits
for d,dirs,files in os.walk('/opt/altera/25.1/quartus/common/tcl',followlinks=False):
 for n in files:
  if n.endswith('.tcl') and any(x in n.lower() for x in ('archive','qar','restore','prepare')):
   p=Path(d)/n;out['installed_archive_files'].append(str(p))
   if p.stat().st_size<=500000:
    b=p.read_bytes();out['source_files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for n in ['ofs-common/scripts/common/syn/emit_project_macros.tcl','syn/shared_config/afu_if_design_files.tcl','ofs-common/src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv']:
 p=D/n;b=p.read_bytes();out['source_files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
R.mkdir();b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);(R/'result.json.gz').write_bytes(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_pr_export_preflight02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_pr_export_preflight02_sha256',hashlib.sha256(b).hexdigest()],check=True)
