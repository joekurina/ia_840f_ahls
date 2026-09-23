import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01');a=json.loads((R/'authority.json').read_text());out={'changes':{},'current_inputs':{},'qpf':{}}
for n,h in a['critical_inputs'].items():
 p=Path(n);b=p.read_bytes();now=hashlib.sha256(b).hexdigest();out['current_inputs'][n]={'bytes':len(b),'sha256':now}
 if now!=h:
  e={'before_sha256':h,'sha256':now,'bytes':len(b)}
  if len(b)<2_000_000:e['base64']=base64.b64encode(b).decode()
  out['changes'][n]=e
p=Path(a['project'])/'ofs_top.qpf';b=p.read_bytes();out['qpf']={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_synth01_delta01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_synth01_delta01_sha256',hashlib.sha256(b).hexdigest()],check=True)
