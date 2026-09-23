import os,json,hashlib,gzip,subprocess,socket
from pathlib import Path
assert __debug__ and socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/fit02');out={"tools":{},"hardware_access":False}
for n,e in {'/opt/altera/25.1/quartus/bin/quartus_sta': {'bytes': 2449, 'path': '/opt/altera/25.1/quartus/bin/quartus_sta', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, '/opt/altera/25.1/quartus/linux64/quartus_sta': {'bytes': 309992, 'path': '/opt/altera/25.1/quartus/linux64/quartus_sta', 'sha256': '979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b'}}.items():
 b=Path(n).read_bytes();assert len(b)==e["bytes"] and hashlib.sha256(b).hexdigest()==e["sha256"];out["tools"][n]=e
import signal,time,resource,shutil
H=R.parent/'sta-help02';H.mkdir(exist_ok=False);(H/'tmp').mkdir();(H/'home').mkdir()
env={'HOME':str(H/'home'),'USER':'uwb_student00','LOGNAME':'uwb_student00','LANG':'C','PATH':'/opt/altera/25.1/quartus/bin:/usr/bin:/bin','QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/25.1/quartus','TMPDIR':str(H/'tmp')}
expected={'/opt/altera/25.1/quartus/bin/quartus_sta': {'bytes': 2449, 'path': '/opt/altera/25.1/quartus/bin/quartus_sta', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, '/opt/altera/25.1/quartus/linux64/quartus_sta': {'bytes': 309992, 'path': '/opt/altera/25.1/quartus/linux64/quartus_sta', 'sha256': '979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b'}}
assert out['tools']==expected
out['help_results']=[]
def limits():
 os.sched_setaffinity(0,set(sorted(os.sched_getaffinity(0))[:2]));resource.setrlimit(resource.RLIMIT_AS,(4*1024**3,4*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
for arg in ('--help=multicorner','--help=do_report_timing','--help=do_report_cdc_viewer','--help=snapshot','--help=report_script'):
 p=subprocess.Popen(['/opt/altera/25.1/quartus/bin/quartus_sta',arg],cwd=H,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limits)
 try:b,_=p.communicate(timeout=60)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);p.communicate();raise
 out['help_results'].append({'argv':['quartus_sta',arg],'native_rc':p.returncode,'stdout':b.decode(errors='replace')});assert p.returncode==0
(H/'capture.json').write_text(json.dumps(out,sort_keys=True))


b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(["tmux","load-buffer","-b","ia840f_persona_sta_help02","-"],input=b,check=True);subprocess.run(["tmux","set-buffer","-b","ia840f_persona_sta_help02_sha256",hashlib.sha256(b).hexdigest()],check=True)
