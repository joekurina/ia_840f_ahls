import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/fit02');J=R/'persona/build/syn/board/ia840f/syn_top';out={'source':str(R/'persona'),'inventory':{},'files':{},'tools':{},'native_processes':[],'hardware_access':False,'fit_result_sha256':hashlib.sha256((R/'result.json.gz').read_bytes()).hexdigest()}
assert out['fit_result_sha256']=='ff6e3e6a5a92b41e655900862638ca03bb89751ae561e8b6cdeb74db8e4c4aab'

for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  e=os.readlink(p/'exe')
  if Path(e).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate'):out['native_processes'].append({'pid':int(p.name),'exe':e})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['native_processes'],out['native_processes']
for p in (R/'persona').rglob('*'):
 if p.is_file():
  s=p.stat();b=p.read_bytes();s2=p.stat();assert (s.st_size,s.st_mtime_ns)==(s2.st_size,s2.st_mtime_ns)
  out['inventory'][str(p.relative_to(R/'persona'))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'symlink':os.readlink(p) if p.is_symlink() else None}
for name in ('quartus_sta',):
 for d in ('bin','linux64'):
  p=Path('/opt/altera/25.1/quartus')/d/name;b=p.read_bytes();out['tools'][str(p)]={'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
for n in ('ofs_pr_afu.qsf','ofs_top.out.sdc','ofs_partial_reconfig/ofs_sta_report_script_pr.tcl','ofs_partial_reconfig/user_clock_freqs_compute.tcl','ofs_partial_reconfig/user_clock_defs.tcl','ofs_partial_reconfig/report_timing.tcl','ofs_partial_reconfig/gen_gbs.tcl'):
 p=J/n;b=p.read_bytes();assert len(b)<1_000_000;out['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}

import signal,time,resource,shutil
H=R.parent/'sta-prerequisites01';H.mkdir(exist_ok=False);(H/'tmp').mkdir();(H/'home').mkdir()
env={'HOME':str(H/'home'),'USER':'uwb_student00','LOGNAME':'uwb_student00','LANG':'C','PATH':'/opt/altera/25.1/quartus/bin:/usr/bin:/bin','QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/25.1/quartus','TMPDIR':str(H/'tmp')}
expected={'/opt/altera/25.1/quartus/bin/quartus_sta': {'bytes': 2449, 'path': '/opt/altera/25.1/quartus/bin/quartus_sta', 'sha256': '222fa669a9b10a6d443268fdc506e885597b5867e77bbf13ff656b8a272933dd'}, '/opt/altera/25.1/quartus/linux64/quartus_sta': {'bytes': 309992, 'path': '/opt/altera/25.1/quartus/linux64/quartus_sta', 'sha256': '979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b'}}
assert out['tools']==expected
out['help_results']=[]
def limits():
 os.sched_setaffinity(0,set(sorted(os.sched_getaffinity(0))[:2]));resource.setrlimit(resource.RLIMIT_AS,(4*1024**3,4*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
for arg in ('--version','--help'):
 p=subprocess.Popen(['/opt/altera/25.1/quartus/bin/quartus_sta',arg],cwd=H,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limits)
 try:b,_=p.communicate(timeout=60)
 except subprocess.TimeoutExpired:
  os.killpg(p.pid,signal.SIGKILL);p.communicate();raise
 out['help_results'].append({'argv':['quartus_sta',arg],'native_rc':p.returncode,'stdout':b.decode(errors='replace')});assert p.returncode==0
(H/'capture.json').write_text(json.dumps(out,sort_keys=True))

b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_sta_prereq01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_sta_prereq01_sha256',hashlib.sha256(b).hexdigest()],check=True)
