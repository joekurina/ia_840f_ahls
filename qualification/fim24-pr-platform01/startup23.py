"""Bounded ordinary-file/process snapshot; never starts or stops a job."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01');R=ROOT/'export01';BUFFER='ia840f_fim24_pr_startup23_result'
result={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{},'native_processes':[],'logs':{}}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 def proc(pid):
  p=Path('/proc')/str(pid);fields=(p/'stat').read_text().rsplit(')',1)[1].split()
  return {'pid':pid,'ppid':int(fields[1]),'state':fields[0],'start_ticks':fields[19],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}
 for name in ('status.json','authority.json','gate-events.jsonl'):
  p=R/name
  if p.exists():
   s=p.stat();assert s.st_size<4*1024**2;b=p.read_bytes();e=p.stat()
   result['files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode(),'stat_before':{'size':s.st_size,'mtime_ns':s.st_mtime_ns},'stat_after':{'size':e.st_size,'mtime_ns':e.st_mtime_ns}}
 if 'authority.json' in result['files']:
  auth=json.loads(base64.b64decode(result['files']['authority.json']['base64']))
  try:result['runner_current']=proc(auth['runner']['pid'])
  except (FileNotFoundError,ProcessLookupError):result['runner_current']=None
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe')
   if exe in ('/opt/altera/26.1.1/quartus/linux64/quartus_sh','/opt/altera/26.1.1/quartus/linux64/quartus_syn'):
    item=proc(int(p.name));item['executable_sha256']=hashlib.sha256(Path(exe).read_bytes()).hexdigest();item['ancestors']=[];parent=item
    for unused in range(40):
     if parent['ppid']<=1:break
     parent=proc(parent['ppid']);item['ancestors'].append(parent)
    result['native_processes'].append(item)
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 for name in ('configure.log','version.log','export.log'):
  p=R/name
  if p.exists():
   s=p.stat()
   with p.open('rb') as f:f.seek(max(0,s.st_size-8192));b=f.read(8192)
   e=p.stat();result['logs'][name]={'size_before':s.st_size,'size_after':e.st_size,'mtime_ns_before':s.st_mtime_ns,'mtime_ns_after':e.st_mtime_ns,'tail_bytes':len(b),'tail_sha256':hashlib.sha256(b).hexdigest(),'tail_base64':base64.b64encode(b).decode(),'scope':'bounded tail, not coherent whole-job snapshot'}
 result['success']=True
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_PR_STARTUP23',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
