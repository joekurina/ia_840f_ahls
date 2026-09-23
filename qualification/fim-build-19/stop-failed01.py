# Stop only the identity-bound failed Work19 offline build.
import datetime, json, os, signal, socket, subprocess, time
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-19')
root=80598;expected='10222195';B='/home/uwb_student00/ahls/new_BSP'
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'reason':'Observed 125091 guard ImportError OPENSSL_3.4.0 during native Work19, not hardware','signals':[]}
def info(pid):
 p=Path('/proc')/str(pid);s=(p/'stat').read_text().rsplit(')',1)[1].split()
 return {'pid':pid,'ppid':int(s[1]),'state':s[0],'start':s[19],'exe':os.readlink(p/'exe'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0'),'cwd':os.readlink(p/'cwd')}
try:
 i=info(root)
 assert i['start']==expected and i['exe']=='/usr/bin/bash' and i['cwd']==B+'/ofs-agx7-pcie-attach'
 assert i['argv']==['/bin/bash','./ofs-common/scripts/common/syn/build_top.sh','--stage=compile','-k','-p','ia840f',B+'/work_ia840f_fim_19']
 rows={}
 for p in Path('/proc').iterdir():
  if p.name.isdigit():
   try:rows[int(p.name)]=info(int(p.name))
   except (FileNotFoundError,PermissionError,ProcessLookupError):pass
 owned={root}
 for _ in range(32):
  new=owned|{p for p,v in rows.items() if v['ppid'] in owned}
  if new==owned:break
  owned=new
 handles=[]
 for pid in sorted(owned,reverse=True):
  try:
   fd=os.pidfd_open(pid);new=info(pid)
   assert new['start']==rows[pid]['start']
   handles.append((pid,fd,new))
  except ProcessLookupError:pass
 r['processes']=[v for _,_,v in handles]
 for sig in (signal.SIGTERM,signal.SIGKILL):
  for pid,fd,v in handles:
   try:signal.pidfd_send_signal(fd,sig);r['signals'].append({'pid':pid,'signal':int(sig)})
   except ProcessLookupError:pass
  if sig==signal.SIGTERM:time.sleep(3)
 time.sleep(1)
 remaining=[]
 for pid,fd,v in handles:
  try:
   live=info(pid)
   if live['start']==v['start'] and live['state']!='Z':remaining.append(live)
  except (FileNotFoundError,ProcessLookupError):pass
  os.close(fd)
 r['remaining_owned_non_zombies']=remaining
 r['termination_confirmed']=not remaining
except FileNotFoundError:r['root_already_absent']=True
with (E/'stop-failed01.json').open('x') as f:json.dump(r,f,indent=2)
print(json.dumps(r,indent=2),flush=True)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim19_stop01','-'],input=json.dumps(r).encode(),check=True)
