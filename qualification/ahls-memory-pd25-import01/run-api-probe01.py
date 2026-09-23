import os,socket,json,hashlib,base64,subprocess,time,signal,resource,shutil
from pathlib import Path
from datetime import datetime,timezone
C={'run': 'probe01', 'tools': {'qsys-script': {'path': '/opt/altera/25.1/quartus/sopc_builder/bin/qsys-script', 'sha256': '10812c05ce84320aff1c003c6bc325e99d4619216ff2ef7b3940398e178377e8'}, 'qsys-generate': {'path': '/opt/altera/25.1/quartus/sopc_builder/bin/qsys-generate', 'sha256': '4db7faf8ccaa3ec6cf093a5e781712346f5c50fdb42ddafebe9b7a31f563deb0'}}, 'script': 'cHV0cyAiUERfUEFDS0FHRSBbcGFja2FnZSBwcmVzZW50IHFzeXNdIgpmb3JlYWNoIG5hbWUge2NyZWF0ZV9zeXN0ZW0gc2V0X3Byb2plY3RfcHJvcGVydHkgYWRkX2luc3RhbmNlIHNldF9pbnN0YW5jZV9wYXJhbWV0ZXJfdmFsdWUgYWRkX2ludGVyZmFjZSBzZXRfaW50ZXJmYWNlX3Byb3BlcnR5IGFkZF9jb25uZWN0aW9uIHZhbGlkYXRlX3N5c3RlbSBzYXZlX3N5c3RlbSBnZXRfaW5zdGFuY2VfaW50ZXJmYWNlcyBnZXRfaW5zdGFuY2VfaW50ZXJmYWNlX3Byb3BlcnR5IGdldF9pbnN0YW5jZV9pbnRlcmZhY2VfcHJvcGVydGllcyBnZXRfaW5zdGFuY2VfaW50ZXJmYWNlX3BvcnRzIGdldF9pbnN0YW5jZV9wb3J0X3Byb3BlcnR5IGdldF9pbnN0YW5jZV9wcm9wZXJ0aWVzIGdldF9pbnN0YW5jZV9wcm9wZXJ0eSBsb2FkX2NvbXBvbmVudCBsb2FkX2luc3RhbmNlIGdldF9pbnRlcmZhY2VzIGdldF9pbnRlcmZhY2VfcHJvcGVydHkgZ2V0X2ludGVyZmFjZV9wb3J0cyBnZXRfcG9ydF9wcm9wZXJ0eX0gewogICAgcHV0cyAiUERfQVBJICRuYW1lIFtsbGVuZ3RoIFtpbmZvIGNvbW1hbmRzICRuYW1lXV0iCn0KcHV0cyAiUERfQVBJX1BST0JFX0NPTVBMRVRFIgo=', 'script_sha256': 'db5cb6343cb7daca41dc2f8bc4b9b2552e4dbd9a1f7e523add6ec6a05d201350'}
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
B=Path("/home/uwb_student00/ahls/new_BSP");R=B/"work_ahls_memory_pd25_import01"/C["run"]
assert not R.exists()
assert int(next(x.split()[1] for x in Path("/proc/meminfo").read_text().splitlines() if x.startswith("MemAvailable:")))*1024>80_000_000_000
assert shutil.disk_usage(B).free>5_000_000_000
for info in C["tools"].values():assert hashlib.sha256(Path(info["path"]).read_bytes()).hexdigest()==info["sha256"]
b=base64.b64decode(C["script"],validate=True);assert hashlib.sha256(b).hexdigest()==C["script_sha256"]
R.mkdir(parents=True,exist_ok=False);(R/"probe.tcl").write_bytes(b);assert hashlib.sha256((R/"probe.tcl").read_bytes()).hexdigest()==C["script_sha256"]
(R/"home").mkdir();(R/"tmp").mkdir()
qroot=Path("/opt/altera/25.1/quartus");license_path="/home/uwb_student00/quartus_25/LR-191011_License.dat"
env={"HOME":str(R/"home"),"USER":"uwb_student00","LOGNAME":"uwb_student00","LANG":"C","PATH":str(qroot/"bin")+":"+str(qroot/"sopc_builder/bin")+":/usr/bin:/bin","TMPDIR":str(R/"tmp"),"QUARTUS_ROOTDIR_OVERRIDE":str(qroot),"LM_LICENSE_FILE":license_path,"MGLS_LICENSE_FILE":license_path,"SALT_LICENSE_SERVER":license_path}
cpus=set(sorted(os.sched_getaffinity(0))[:2]);result={"run":C["run"],"started":datetime.now(timezone.utc).isoformat(),"cwd":str(R),"commands":[],"tools":C["tools"],"script_sha256":C["script_sha256"],"hardware_access":False,"complete":False}
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
   descendants_after_leader=bool(live_group(p.pid)) and not timedout
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
 persist()
 commands=[("qsys_script_help",[C["tools"]["qsys-script"]["path"],"--help"]),("qsys_generate_help",[C["tools"]["qsys-generate"]["path"],"--help"]),("api_probe",[C["tools"]["qsys-script"]["path"],"--quartus-project=none","--package-version=25.1","--script="+str(R/"probe.tcl")])]
 for label,argv in commands:
  rc=native(label,argv)
  if rc:break
 result["complete"]=True
except Exception as e:result["error"]=repr(e)
finally:
 result["tools_unchanged"]=all(hashlib.sha256(Path(i["path"]).read_bytes()).hexdigest()==i["sha256"] for i in C["tools"].values())
 result["script_unchanged"]=hashlib.sha256((R/"probe.tcl").read_bytes()).hexdigest()==C["script_sha256"]
 result["ended"]=datetime.now(timezone.utc).isoformat();persist();result["logs"]={}
 for p in R.glob("*.log"):
  b=p.read_bytes();result["logs"][p.name]={"bytes":len(b),"sha256":hashlib.sha256(b).hexdigest(),"text":b.decode(errors="replace") if len(b)<2000000 else None}
 raw=json.dumps(result,indent=2).encode();subprocess.run(["tmux","load-buffer","-b","ia840f_pd25_"+C["run"],"-"],input=raw,check=True);print("RESULT_SHA256="+hashlib.sha256(raw).hexdigest(),flush=True)
last=result["commands"][-1].get("effective_rc",125) if result["commands"] else 125
if not result["complete"] or not result["tools_unchanged"] or not result["script_unchanged"]:last=125
raise SystemExit(128-last if last<0 else last)
