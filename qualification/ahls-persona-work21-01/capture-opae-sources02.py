import os,sys,socket,json,hashlib,base64,gzip,subprocess,sysconfig
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
out={'python':sys.executable,'sys_path':sys.path,'files':{},'roots':[]}
paths=[Path('/usr/bin')/n for n in ()]
for s in sys.path:
 if not s:continue
 p=Path(s)/'platmgr'
 if p.is_dir():
  out['roots'].append(str(p));paths.extend(p.rglob('*.py'))
assert len(paths)<=500,len(paths)
for p in paths:
 b=p.read_bytes();assert len(b)<=2_000_000
 out['files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
assert sum(e['bytes'] for e in out['files'].values())<10_000_000
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_opae_sources02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_opae_sources02_sha256',hashlib.sha256(b).hexdigest()],check=True)
