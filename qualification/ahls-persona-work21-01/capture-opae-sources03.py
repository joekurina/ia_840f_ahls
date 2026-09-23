import os,sys,socket,json,hashlib,base64,gzip,subprocess,sysconfig
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
out={'python':sys.executable,'sys_path':sys.path,'files':{},'roots':[]}
paths=[Path('/usr/bin')/n for n in ('rtl_src_config','afu_platform_info')]
for s in sys.path:
 if not s:continue
 p=Path(s)/'packager'
 if p.is_dir():
  out['roots'].append(str(p));paths.extend(x for x in p.rglob('*') if x.is_file() and x.suffix in ('.py','.json'))

T=Path('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03')
paths.extend(p for p in (T/'hw/lib/platform').rglob('*') if p.is_file())
paths.extend([T/'hw/lib/build/ofs-common/src/fpga_family/agilex/afu_main.tcl',T/'hw/lib/build/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv'])
assert len(paths)<=500,len(paths)
for p in paths:
 b=p.read_bytes();assert len(b)<=2_000_000
 out['files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
assert sum(e['bytes'] for e in out['files'].values())<10_000_000
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_opae_sources03','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_opae_sources03_sha256',hashlib.sha256(b).hexdigest()],check=True)
