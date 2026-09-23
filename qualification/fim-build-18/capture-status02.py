import json,os,subprocess,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-18')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{}}
for name in ('issuance-receipt01.json','compile-authorization.json','run/status.json','run/native-status.json'):
 p=E/name
 if p.exists():
  b=p.read_bytes();r['files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
  if name!='compile-authorization.json':r['files'][name]['text']=b.decode()
p=E/'run/native.log'
if p.exists():
 with p.open('rb') as f:f.seek(max(0,p.stat().st_size-16000));r['log_tail']=f.read().decode(errors='replace')
rows=[x.split(None,3) for x in subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True).splitlines()[1:]]
s=json.loads((E/'run/status.json').read_text()) if (E/'run/status.json').exists() else {}
owned={s.get('runner_pid'),s.get('native_pid')}-{None}
for _ in range(32):
 nxt=owned|{int(x[0]) for x in rows if int(x[1]) in owned}
 if nxt==owned:break
 owned=nxt
r['owned_processes']=[x for x in rows if int(x[0]) in owned]
r['identities']={}
for pid in sorted(owned):
 p=Path('/proc')/str(pid)
 try:r['identities'][str(pid)]={'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0'),'start_ticks':(p/'stat').read_text().rsplit(')',1)[1].split()[19]}
 except FileNotFoundError:pass
b=json.dumps(r,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_fim18_status02','-'],input=b,check=True)
print('WORK18_STATUS02',hashlib.sha256(b).hexdigest(),flush=True)
