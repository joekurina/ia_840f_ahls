"""Read completed generated output bytes; no vendor invocation."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01');G=ROOT/'generate01';R=ROOT/'native01';P=ROOT/'prepare08';BUFFER='ia840f_fim24_caps03_fabric_completion17_result'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'native_tools_executed':False,'files':{},'native_processes':[]}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 raw=(R/'result.json').read_bytes();result=json.loads(raw);assert result['complete'] and result['manifest_sha256']=='2b3ab8c0cd50621130cea579b0de551b5e6bd304f23535e5e30b7e3be0698d1c'
 inv=result['generated_inventory'];assert len(inv)==294
 todo=[(G/n,'generated/'+n,m) for n,m in inv.items()]
 todo += [(R/n,'operation/'+n,None) for n in ('status.json','result.json','configure.log','version.log','import.log','generate.log')]
 todo += [(P/'native15-outer.log','operation/native15-outer.log',None)]
 total=0
 for path,key,expected in todo:
  a=path.stat();assert a.st_size<=32*1024**2;b=path.read_bytes();z=path.stat();assert a.st_size==z.st_size==len(b) and a.st_mtime_ns==z.st_mtime_ns,key
  h=hashlib.sha256(b).hexdigest()
  if expected:assert len(b)==expected['bytes'] and h==expected['sha256'],key
  total+=len(b);assert total<=96*1024**2
  out['files'][key]={'bytes':len(b),'sha256':h,'base64':base64.b64encode(b).decode(),'mtime_ns':z.st_mtime_ns}
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe');cmd=(p/'cmdline').read_bytes()
   if Path(exe).name.startswith(('quartus_','qsys-')) or (Path(exe).name=='java' and b'/opt/altera/' in cmd):out['native_processes'].append({'pid':int(p.name),'exe':exe,'cwd':os.readlink(p/'cwd'),'argv':cmd.decode().rstrip('\0').split('\0')})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 out.update(success=True,generated_members=len(inv),captured_members=len(todo),total_bytes=total,execution_clean=result['execution_clean'],manifest_sha256=result['manifest_sha256'],ended=result['ended'])
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_CAPS03_FABRIC_COMPLETION17',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
