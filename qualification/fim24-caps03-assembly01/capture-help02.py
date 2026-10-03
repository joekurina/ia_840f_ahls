"""Finite same-release assembler help/source snapshot; never open a Quartus project."""
import base64,datetime,gzip,hashlib,json,os,signal,socket,subprocess,sys,time,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');H=ROOT/'help02';BATCH=sys.argv[1];Q=Path('/opt/altera/26.1.1/quartus')
out={'batch':BATCH,'scope':'no-project assembler help and bounded source readback only','success':False,'project_opened':False,'assembly_started':False,'hardware_access':False,'exports':{}}
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(path,b):
 path.parent.mkdir(parents=True,exist_ok=True)
 with path.open('xb') as f:f.write(b)
def export(path,name):
 b=path.read_bytes();assert len(b)<8*1024**2
 out['exports'][name]={'source':str(path),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
def live(gid):
 found=[]
 for d in Path('/proc').iterdir():
  if not d.name.isdigit():continue
  try:
   f=(d/'stat').read_text().rsplit(')',1)[1].split()
   if int(f[2])==gid and f[0]!='Z':found.append(int(d.name))
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 return found
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert not H.exists();H.mkdir(parents=True,exist_ok=False)
 expected={str(Q/'bin/quartus_asm'):'06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14',str(Q/'linux64/quartus_asm'):'05804d6ea551490177d86a0ca64e994077b88d8fb129ab8e9706a3faa2a3f463'}
 assert all(sha(p)==v for p,v in expected.items());out['tools']=expected
 out['commands']=[]
 for option in ('--help','--help=return_codes'):
  argv=[str(Q/'bin/quartus_asm'),option];log=H/('help.log' if option=='--help' else 'return-codes.log');child=None;rc=None;timed=False
  with log.open('xb') as f:
   try:
    env=dict(os.environ);env['QUARTUS_ROOTDIR_OVERRIDE']=str(Q);env['PATH']=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/bin:/bin'
    child=subprocess.Popen(argv,cwd=H,env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
    deadline=time.monotonic()+60
    while os.waitid(os.P_PID,child.pid,os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
     if time.monotonic()>deadline:timed=True;break
     if log.stat().st_size>2*1024**2:raise RuntimeError('help log limit')
     time.sleep(.1)
    while live(child.pid) and not timed and time.monotonic()<deadline:time.sleep(.1)
    if live(child.pid):timed=True
   finally:
    if child is not None:
     if live(child.pid):
      os.killpg(child.pid,signal.SIGTERM);end=time.monotonic()+3
      while live(child.pid) and time.monotonic()<end:time.sleep(.1)
      if live(child.pid):os.killpg(child.pid,signal.SIGKILL)
     rc=child.wait()
  assert child is not None and rc==0 and not timed and not live(child.pid)
  out['commands'].append({'argv':argv,'cwd':str(H),'rc':rc,'timeout':timed,'owned_group_live_after':live(child.pid)});export(log,log.name)
 text=(H/'help.log').read_text();assert 'Version26.1.1' in text.replace(' ','') and 'Build 130' in text and '-c <revision name>' in text
 source=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01/base01');J=source/'build/syn/board/ia840f/syn_top'
 names=['ofs_pr_afu.qsf','ofs_pr_afu_sources.tcl','ofs_top.qpf','build_env_db.txt','ofs_partial_reconfig/gen_gbs.tcl','output_files/user_clock_freq.txt']
 for name in names:export(J/name,'source/'+name)
 out['source_root']=str(source);out['cpu_affinity']=sorted(os.sched_getaffinity(0));out['source_qpf_sha256']=sha(J/'ofs_top.qpf');out['success']=True
except BaseException as exc:out['error']=repr(exc);out['traceback']=traceback.format_exc()
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'assembly_started':False}),flush=True)
if not out['success']:raise SystemExit(1)
