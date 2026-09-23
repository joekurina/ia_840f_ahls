import os,socket,json,hashlib,subprocess,time,signal,resource,shutil,gzip,base64
from pathlib import Path
from datetime import datetime,timezone
if not __debug__:raise RuntimeError("optimized Python forbidden")
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
B=Path("/home/uwb_student00/ahls/new_BSP");R=B/"work_ahls_memory_elab25_01/probe01"
assert not R.exists()
TOOLS={'launcher': {'path': '/opt/altera/25.1/quartus/bin/quartus_syn', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, 'runtime': {'path': '/opt/altera/25.1/quartus/linux64/quartus_syn', 'sha256': 'ce5c750beab921b3262e004eb64f2ed11cd875ae226bc4b92c09b6e9069579f4'}}
for t in TOOLS.values():assert hashlib.sha256(Path(t["path"]).read_bytes()).hexdigest()==t["sha256"]
assert int(next(l.split()[1] for l in Path("/proc/meminfo").read_text().splitlines() if l.startswith("MemAvailable:")))*1024>80_000_000_000
assert shutil.disk_usage(B).free>5_000_000_000
R.mkdir(parents=True,exist_ok=False);(R/"home").mkdir();(R/"tmp").mkdir()
qroot=Path("/opt/altera/25.1/quartus");lic="/home/uwb_student00/quartus_25/LR-191011_License.dat"
env={"HOME":str(R/"home"),"USER":"uwb_student00","LOGNAME":"uwb_student00","LANG":"C","PATH":str(qroot/"bin")+":"+str(qroot/"sopc_builder/bin")+":/usr/bin:/bin","TMPDIR":str(R/"tmp"),"QUARTUS_ROOTDIR_OVERRIDE":str(qroot),"LM_LICENSE_FILE":lic,"MGLS_LICENSE_FILE":lic,"SALT_LICENSE_SERVER":lic}
cpus=set(sorted(os.sched_getaffinity(0))[:2]);result={"run":"probe01","commands":[],"tools":TOOLS,"hardware_access":False}
def persist(): (R/"status.json").write_text(json.dumps(result,indent=2)+"\n")

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
 resource.setrlimit(resource.RLIMIT_AS,(16*1024**3,16*1024**3))
 resource.setrlimit(resource.RLIMIT_CORE,(0,0))

def native(label,argv):
 rec={"label":label,"argv":argv,"started":datetime.now(timezone.utc).isoformat()};result["commands"].append(rec);persist()
 timedout=False;descendants_after_leader=False;p=None
 with (R/(label+".log")).open("xb") as log:
  try:
   p=subprocess.Popen(argv,cwd=R,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limit_child)
   rec["pid"]=p.pid;rec["start_ticks"]=(Path("/proc")/str(p.pid)/"stat").read_text().rsplit(")",1)[1].split()[19];persist()
   deadline=time.monotonic()+120
   while os.waitid(os.P_PID,p.pid,os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
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
try:
 for label,arg in [("version","--version"),("help-elaboration","--help=analysis_and_elaboration")]:
  if native(label,[TOOLS["launcher"]["path"],arg]):break
finally:
 result["files"]={}
 for p in R.glob("*.log"):
  b=p.read_bytes();result["files"][p.name]={"bytes":len(b),"sha256":hashlib.sha256(b).hexdigest(),"text":b.decode(errors="replace")}
 result["tools_preserved"]=all(hashlib.sha256(Path(t["path"]).read_bytes()).hexdigest()==t["sha256"] for t in TOOLS.values())
 persist();blob=json.dumps(result,sort_keys=True).encode();(R/"result.json").write_bytes(blob)
 subprocess.run(["tmux","load-buffer","-b","ia840f_memelab25_probe01","-"],input=blob,check=True)
 print("RESULT_SHA256="+hashlib.sha256(blob).hexdigest(),flush=True)
raise SystemExit(0 if len(result["commands"])==2 and all(c["effective_rc"]==0 for c in result["commands"]) and result["tools_preserved"] else 1)
