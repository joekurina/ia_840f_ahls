import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01');out={'root':str(R),'native_processes':[]}
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  cwd=os.readlink(p/'cwd');exe=os.readlink(p/'exe')
  if cwd.startswith(str(R)) and Path(exe).name.startswith('quartus_'):
   parts=(p/'stat').read_text().rsplit(')',1)[1].split();out['native_processes'].append({'pid':int(p.name),'start_ticks':parts[19],'exe':exe,'cwd':cwd,'argv':(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0)),'cpu_ticks':int(parts[11])+int(parts[12]),'sha256':hashlib.sha256(Path(exe).read_bytes()).hexdigest()})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
out['status']=json.loads((R/'status.json').read_text()) if (R/'status.json').exists() else None
if out['status']:
 out['status']={k:v for k,v in out['status'].items() if k not in ('input_hashes','original_setup_inventory','source_delta','files','qdb_outputs')}
p=R/'synthesis.log';out['log_last_lines']=p.read_text(errors='replace').splitlines()[-25:] if p.exists() else []
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_synth01_snapshot01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_synth01_snapshot01'+'_sha256',hashlib.sha256(b).hexdigest()],check=True)
