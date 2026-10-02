"""Bounded ordinary startup snapshot; no vendor execution or process control."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01');R=ROOT/'native01';BUFFER='ia840f_fim24_caps03_fabric_startup16_result'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'native_tools_executed':False,'files':{},'native_processes':[],'logs':{}}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 def proc(pid):
  p=Path('/proc')/str(pid);s=(p/'stat').read_text().rsplit(')',1)[1].split()
  return {'pid':pid,'ppid':int(s[1]),'state':s[0],'start_ticks':s[19],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}
 status=R/'status.json'
 if status.is_file():
  a=status.stat();assert a.st_size<4*1024**2;b=status.read_bytes();z=status.stat()
  out['files']['status.json']={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode(),'before_size':a.st_size,'after_size':z.st_size,'before_mtime_ns':a.st_mtime_ns,'after_mtime_ns':z.st_mtime_ns}
  r=json.loads(b)
  try:out['runner_current']=proc(r['runner']['pid'])
  except (FileNotFoundError,ProcessLookupError):out['runner_current']=None
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe');cmd=(p/'cmdline').read_bytes()
   if ('/opt/altera/26.1.1/' in exe and Path(exe).name.startswith(('quartus_','qsys-'))) or (Path(exe).name=='java' and b'/opt/altera/26.1.1/' in cmd):
    item=proc(int(p.name));item['executable_sha256']=hashlib.sha256(Path(exe).read_bytes()).hexdigest();item['ancestors']=[];parent=item
    for unused in range(40):
     if parent['ppid']<=1:break
     parent=proc(parent['ppid']);item['ancestors'].append(parent)
    out['native_processes'].append(item)
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 for label in ('configure','version','import','generate'):
  p=R/(label+'.log')
  if p.is_file():
   a=p.stat()
   with p.open('rb') as f:f.seek(max(0,a.st_size-8192));b=f.read(8192)
   z=p.stat();out['logs'][label]={'before_size':a.st_size,'after_size':z.st_size,'tail_bytes':len(b),'tail_sha256':hashlib.sha256(b).hexdigest(),'tail_base64':base64.b64encode(b).decode(),'scope':'bounded tail; not coherent full-job snapshot'}
 out['success']=True
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_CAPS03_FABRIC_STARTUP16',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
