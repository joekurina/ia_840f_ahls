"""Read the emitted Plan report once; no native query or input changes."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01');P=ROOT/'control08/plan23';FILE=ROOT/'base01/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.plan.rpt';BUFFER='ia840f_fim24_caps03_physical_plan23_result'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_query':False,'hardware_access':False};owned=False
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert FILE.is_file();before=FILE.stat();assert before.st_size<32*1024**2;b=FILE.read_bytes();after=FILE.stat();assert before.st_size==after.st_size==len(b) and before.st_mtime_ns==after.st_mtime_ns
 P.mkdir();owned=True;out.update(success=True,file={'source':str(FILE),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'mtime_ns':after.st_mtime_ns,'base64':base64.b64encode(b).decode()})
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (P/'capture23.json').open('x') as f:json.dump({k:v for k,v in out.items() if k!='file'},f,indent=2)
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('PLAN_REPORT23',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
