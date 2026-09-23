import os,sys,socket,json,hashlib,base64,subprocess,time,signal,resource,shutil,gzip,re
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
C={'root': '/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/csr-help03', 'tools': {'bin/quartus_sh': {'path': '/opt/altera/25.1/quartus/bin/quartus_sh', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, 'bin/quartus_syn': {'path': '/opt/altera/25.1/quartus/bin/quartus_syn', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, 'linux64/quartus_sh': {'path': '/opt/altera/25.1/quartus/linux64/quartus_sh', 'sha256': 'bf780907d9ad8eccb81e5a3070084507ca1ab821a8f2ff048006e5658df01f90'}, 'linux64/quartus_syn': {'path': '/opt/altera/25.1/quartus/linux64/quartus_syn', 'sha256': 'ce5c750beab921b3262e004eb64f2ed11cd875ae226bc4b92c09b6e9069579f4'}, '/opt/altera/25.1/quartus/bin/quartus_fit': {'bytes': 2449, 'path': '/opt/altera/25.1/quartus/bin/quartus_fit', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, '/opt/altera/25.1/quartus/linux64/quartus_fit': {'bytes': 167656, 'path': '/opt/altera/25.1/quartus/linux64/quartus_fit', 'sha256': 'c5cef4cc906aaffdfc177728e4ade3de6d40bb844d794dc8d6c59bbb894e91e0'}, '/opt/altera/25.1/quartus/bin/quartus_sta': {'bytes': 2449, 'path': '/opt/altera/25.1/quartus/bin/quartus_sta', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, '/opt/altera/25.1/quartus/linux64/quartus_sta': {'bytes': 309992, 'path': '/opt/altera/25.1/quartus/linux64/quartus_sta', 'sha256': '979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b'}}, 'script': 'load_package project\nload_package sta\nputs {BEGIN_HELP index_collection}\nif {[catch {help -cmd index_collection} q_help]} {puts "HELP_UNAVAILABLE $q_help"} else {puts $q_help}\nputs {END_HELP index_collection}\nputs {BEGIN_HELP add_to_collection}\nif {[catch {help -cmd add_to_collection} q_help]} {puts "HELP_UNAVAILABLE $q_help"} else {puts $q_help}\nputs {END_HELP add_to_collection}\nputs {BEGIN_HELP remove_from_collection}\nif {[catch {help -cmd remove_from_collection} q_help]} {puts "HELP_UNAVAILABLE $q_help"} else {puts $q_help}\nputs {END_HELP remove_from_collection}\n', 'buffer': 'ia840f_persona_csr02_csr_help03'}
R=Path(C['root']);assert not R.exists()
for e in C['tools'].values():assert hashlib.sha256(Path(e['path']).read_bytes()).hexdigest()==e['sha256']
mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
assert mem>80_000_000_000 and shutil.disk_usage(R.parent).free>10_000_000_000
comp=[]
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  exe=os.readlink(p/'exe')
  if Path(exe).name in {'quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate'}:comp.append(int(p.name))
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not comp,comp
R.mkdir();(R/'tmp').mkdir();(R/'home').mkdir();J=R;cpus=set(os.sched_getaffinity(0))
(R/'help.tcl').write_text(C['script'])
env={'HOME':str(R/'home'),'PATH':'/opt/altera/25.1/quartus/bin:/usr/bin:/bin','QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/25.1/quartus','TMPDIR':str(R/'tmp'),'LANG':'C'}
result={'run':'csr02-csr-help03','commands':[],'hardware_access':False,'cpus':sorted(cpus),'rlimit_as':64*1024**3}
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
   deadline=time.monotonic()+180
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
rc=native('help',['/opt/altera/25.1/quartus/bin/quartus_sta','-t',str(R/'help.tcl')]);result['stdout']=(R/'help.log').read_text();result['tools']=C['tools'];result['tcl_sha256']=hashlib.sha256(C['script'].encode()).hexdigest();persist()
b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);(R/'result.json.gz').write_bytes(b)
subprocess.run(['tmux','load-buffer','-b',C['buffer'],'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',C['buffer']+'_sha256',hashlib.sha256(b).hexdigest()],check=True)
raise SystemExit(rc)
