"""Finite post-run source metadata; no native tools or source changes."""
import datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01');P=ROOT/'control19';J=ROOT/'base01/build/syn/board/ia840f/syn_top';R=ROOT/'synth01';O=P/'source_collateral29';INPUT='ia840f_fim24_caps03_implementation_sourcecollateral29_inputs';BUFFER='ia840f_fim24_caps03_implementation_sourcecollateral29_result';EXPECTED='4014f1f6ea542f394cfba70ef64b8e371ee060a6b45503c09ba60fbf05d6ef27'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'scope':'post-run observed file metadata, not original prebinding or source-internal requalification','native_launched':False,'hardware_access':False,'files':{}};owned=False
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==EXPECTED;req=json.loads(raw);assert len(req['paths'])==156
 before=hashlib.sha256((R/'result.json').read_bytes()).hexdigest();assert before=='df7592c31ac966987a349a043dfacbc7bf7825d5520657467d58d0162e17b398'
 O.mkdir();owned=True;total=0
 for n,item in req['paths'].items():
  p=Path(n);assert n.startswith(str(J)+'/dni/') or n.startswith(str(J)+'/qdb/') or n.startswith(str(J)+'/tmp-clearbox/ofs_pr_afu/347898/') or n.startswith('/opt/altera/26.1.1/quartus/libraries/')
  row=dict(item);row['exists']=p.is_file()
  if row['exists']:
   size=p.stat().st_size;assert size<32*1024**2 and total+size<256*1024**2;b=p.read_bytes();assert len(b)==size;total+=size
   row.update(bytes=size,sha256=hashlib.sha256(b).hexdigest(),md5=hashlib.md5(b).hexdigest(),resolved=str(p.resolve(strict=True)),native_md5_matches=all(x==hashlib.md5(b).hexdigest() for x in item['native_md5_values']))
  else:row['observation']='reported generated path no longer exists at post-run acquisition; no body identity claim'
  out['files'][n]=row
 assert hashlib.sha256((R/'result.json').read_bytes()).hexdigest()==before
 out.update(success=True,read_bytes=total,native_result_preserved=True)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (O/'metadata29.json').open('x') as f:json.dump(out,f,indent=2)
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('SOURCE_COLLATERAL29',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
