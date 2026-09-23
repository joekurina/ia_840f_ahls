import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/sta01');A=json.loads((R/'authority.json').read_text());S=json.loads((R/'status.json').read_text());out={'root':str(R),'hardware_access':False,'native_processes':[],'changed':{},'unchanged_count':0,'files':{}}
assert hashlib.sha256((R/'result.json.gz').read_bytes()).hexdigest()=='387cdff4f13b15f37cbf9155c1d71576aedd13a63ee52447cada56384cdd91b6'
assert S['complete'] and S['commands'][0]['native_rc']==0 and S['commands'][0]['owned_group_live_after']==[]
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  e=os.readlink(p/'exe')
  if Path(e).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate'):out['native_processes'].append({'pid':int(p.name),'exe':e})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['native_processes']
for n,h in A['critical_inputs'].items():
 p=Path(n);before=p.stat() if p.is_file() else None;b=p.read_bytes() if before else None;after=p.stat() if before else None
 if before:assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
 hh=hashlib.sha256(b).hexdigest() if b is not None else None
 if h==hh:out['unchanged_count']+=1
 else:
  out['changed'][n]={'before_sha256':h,'after_sha256':hh,'bytes':len(b) if b is not None else None}
  if b is not None and len(b)<=1000000 and b'\x00' not in b:
   out['files'][n]={'bytes':len(b),'sha256':hh,'base64':base64.b64encode(b).decode()}
out['qdb_inventory']={str(p.relative_to(R/'persona')):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in (R/'persona/build/syn/board/ia840f/syn_top/qdb').rglob('*') if p.is_file()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_sta_delta01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_sta_delta01_sha256',hashlib.sha256(b).hexdigest()],check=True)
