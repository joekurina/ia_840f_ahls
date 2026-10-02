"""Read completed simulator evidence only; no execution or device access."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_simulation01');P=ROOT/'control23';R=ROOT/'native01';I=ROOT/'prepare10/inputs';BUFFER='ia840f_fim24_caps03_simulation_completion28_result';SEMANTIC='a8ef9f4e84cf90ecd87a69ddec21e539c778cd734a0d1f47622127319b8acb1e';ADMITTED='c68c0b4df38710e8c323dbc6cb46abad0c012ff3b1fa704f556c9c9ef1c4b765'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def take(p,name):
 before=p.stat();assert before.st_size<=2_000_000,(name,before.st_size);b=p.read_bytes();after=p.stat();assert len(b)==before.st_size==after.st_size and before.st_mtime_ns==after.st_mtime_ns
 out['files'][name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'mtime_ns_before':before.st_mtime_ns,'mtime_ns_after':after.st_mtime_ns,'base64':base64.b64encode(b).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert sha(P/'simulation-inputs.admitted.json')==ADMITTED;m=json.loads((P/'simulation-inputs.admitted.json').read_text())
 result=json.loads((R/'result.json').read_text());assert hashlib.sha256(json.dumps(result,sort_keys=True).encode()).hexdigest()==SEMANTIC and result['manifest_sha256']==ADMITTED and result['unit_pass']
 for n,item in m['files'].items():
  for base in (I,R):assert (base/n).is_file() and (base/n).stat().st_size==item['bytes'] and sha(base/n)==item['sha256'],n
 for n,item in list(m['originals'].items())+list(m['simulator_tools'].items())+list(m['runtime_tools'].items()):
  p=Path(n);assert p.is_file() and sha(p)==item['sha256'],n
  if 'bytes' in item:assert p.stat().st_size==item['bytes'],n
  if 'real' in item:assert str(p.resolve())==item['real'],n
 assert sha(m['setup_result_file'])==m['setup_result_sha256']
 for name in ('result.json','status.json','configure.log','version.log','vlib.log','vdir.log','vlog.log','vsim.log','split_fault.log'):take(R/name,'operation/'+name)
 take(P/'native22-outer.log','operation/native22-outer.log');take(R/'modelsim.ini','configuration/modelsim.ini')
 rc=subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim24_caps03_simulation_native22_rc','-'],text=True).strip();assert rc=='0'
 work={}
 for p in (R/'work').rglob('*'):
  if p.is_file():work[str(p.relative_to(R))]={'bytes':p.stat().st_size,'sha256':sha(p)}
 assert work
 active=[]
 for d in Path('/proc').iterdir():
  if not d.name.isdigit():continue
  try:
   stat=(d/'stat').read_text().rsplit(') ',1)[1].split();pid=int(d.name);cmd=(d/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
   if stat[0] in ('Z','X') or pid==os.getpid():continue
   if str(R) in cmd or str(P/'runtime/run-simulation23.py') in cmd:active.append({'pid':pid,'ppid':int(stat[1]),'start_ticks':int(stat[19]),'exe':os.readlink(d/'exe'),'argv_text':cmd,'cwd':os.readlink(d/'cwd')})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 assert not active,active
 out.update(success=True,outer_rc=0,source_bound_manifest=ADMITTED,operation_result_sha256=sha(R/'result.json'),native_ended=result['ended'],inputs_verified=len(m['files']),originals_verified=len(m['originals']),simulator_bindings_verified=len(m['simulator_tools']),runtime_tools_verified=len(m['runtime_tools']),work_library_inventory=work,active_simulation_processes=active,process_scope='operation-root/runner argv match only, not exhaustive host/device ownership')
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('SIMULATION_COMPLETION28',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
