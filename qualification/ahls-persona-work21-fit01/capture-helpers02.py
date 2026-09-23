import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01');J=R/'persona/build/syn/board/ia840f/syn_top';out={'source':str(R/'persona'),'inventory':{},'files':{},'tools':{},'native_processes':[]}
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  e=os.readlink(p/'exe')
  if Path(e).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate'):out['native_processes'].append({'pid':int(p.name),'exe':e})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['native_processes'],out['native_processes']
out['inventory']={}
for p in (J/'ofs_partial_reconfig').rglob('*.tcl'):
 b=p.read_bytes();assert len(b)<2_000_000;out['files'][str(p.relative_to(J))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_fit_helpers02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_fit_helpers02_sha256',hashlib.sha256(b).hexdigest()],check=True)
