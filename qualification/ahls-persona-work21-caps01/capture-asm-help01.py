import os,sys,socket,json,hashlib,base64,subprocess,time,signal,resource,shutil,gzip,re
from pathlib import Path
from datetime import datetime,timezone
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/asm-help01');J=R
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not R.exists()
R.mkdir();(R/'tmp').mkdir()
cpus=set(os.sched_getaffinity(0));result={'commands':[],'hardware_access':False}
env={'PATH':'/opt/altera/25.1/quartus/bin:/usr/bin:/bin','QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/25.1/quartus','HOME':str(R),'TMPDIR':str(R/'tmp'),'LANG':'C'}
assert hashlib.sha256(Path('/opt/altera/25.1/quartus/linux64/quartus_asm').read_bytes()).hexdigest()=='b7580ae1a942bf02c5f8c974e265edd83caa2da65eefcf5f5b2744348cc60f98'
def persist():(R/'status.json').write_text(json.dumps(result,indent=2)+'\n')

def live_group(gid):
 out=[]
 for p in Path("/proc").iterdir():
  if not p.name.isdigit():continue
  try:
   parts=(p/"stat").read_text().rsplit(")",1)[1].split()
   if int(parts[2])==gid and parts[0]!="Z":out.append(int(p.name))
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 return out

def limit_child():
 os.sched_setaffinity(0,cpus)
 resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3))
 resource.setrlimit(resource.RLIMIT_CORE,(0,0))

def native(label,argv):
 rec={"label":label,"argv":argv,"started":datetime.now(timezone.utc).isoformat()};result["commands"].append(rec);persist()
 timedout=False;descendants_after_leader=False;p=None
 with (R/(label+".log")).open("xb") as log:
  try:
   p=subprocess.Popen(argv,cwd=J,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limit_child)
   rec["pid"]=p.pid;rec["start_ticks"]=(Path("/proc")/str(p.pid)/"stat").read_text().rsplit(")",1)[1].split()[19];persist()
   deadline=time.monotonic()+120
   while os.waitid(os.P_PID,p.pid,os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
    if (R/"gate-rejections.jsonl").exists() or ((R/(label+".log")).exists() and "IA840F_GATE_REJECTED" in (R/(label+".log")).read_text(errors="replace")):raise RuntimeError("owned native callback rejected")
    if time.monotonic()>deadline:timedout=True;break
    time.sleep(0.1)
   residual=live_group(p.pid)
   rec["descendants_observed_at_leader_exit"]=residual
   # Native frontends can finish just before their short-lived helpers.
   while residual and not timedout and time.monotonic()<deadline:
    time.sleep(0.1);residual=live_group(p.pid)
   if residual:timedout=True
   descendants_after_leader=bool(residual)

  finally:
   if p is not None:
    # Leader remains unreaped until all possible process-group signals finish.
    if live_group(p.pid):
     os.killpg(p.pid,signal.SIGTERM);end=time.monotonic()+3
     while live_group(p.pid) and time.monotonic()<end:time.sleep(0.1)
     if live_group(p.pid):os.killpg(p.pid,signal.SIGKILL)
    rec["native_rc"]=p.wait();rec["timeout"]=timedout;rec["descendants_after_leader"]=descendants_after_leader
    rec["ended"]=datetime.now(timezone.utc).isoformat();persist()
    rec["owned_group_live_after"]=live_group(p.pid)
    rec["effective_rc"]=124 if timedout else (125 if descendants_after_leader or rec["owned_group_live_after"] else rec["native_rc"])
    persist()
 return rec["effective_rc"]
rc=native('help',['/opt/altera/25.1/quartus/bin/quartus_asm','--help']);result['log']=(R/'help.log').read_text();blob=json.dumps(result).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_persona_caps01_asm_help01','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_caps01_asm_help01_sha256',hashlib.sha256(blob).hexdigest()],check=True);raise SystemExit(rc)
