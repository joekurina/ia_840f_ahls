"""Issue one reviewed simulation-only record; never launch the simulator."""
import base64,copy,datetime,gzip,hashlib,importlib.util,json,os,re,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_simulation01');P=ROOT/'control23';A=P/'admission27';M=P/'simulation-inputs.admitted.json';R=ROOT/'native01'
INPUT='ia840f_fim24_caps03_simulation_admission27_inputs';BUFFER='ia840f_fim24_caps03_simulation_admission27_result';EXPECTED='bd5fd53cda6570ddf322928e02370294cf57430ca73d20e1a8a343dc560c32fa'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'operation_created':False,'admission_written':False};owned=False
try:
 assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',EXPECTED)
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert all(not p.exists() and not p.is_symlink() for p in (A,M,R))
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert len(raw)<1024**2 and hashlib.sha256(raw).hexdigest()==EXPECTED
 C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT and C['scope']=='migrated-integrated-unit-simulation-only'
 draft_raw=(P/'simulation-inputs.draft24.json').read_bytes();assert hashlib.sha256(draft_raw).hexdigest()==C['draft_sha256']=='d0faa4194c4f783454e3e1ca1cc90ce41390cf4352d0e52cdd9fd34f5c01122c';draft=json.loads(draft_raw)
 assert draft['parent_execution_accepted'] is False and draft['hardware_ready'] is False
 names={'simulation-inputs.admitted.json','source-spec-review14.md','source-continuity25.json','review-quality26.md','quality-consumed27.json'}
 assert set(C['files'])==names
 decoded={}
 for n,item in C['files'].items():
  assert Path(n).name==n;b=base64.b64decode(item['base64'],validate=True);assert len(b)==item['bytes'] and hashlib.sha256(b).hexdigest()==item['sha256'];decoded[n]=b
 source=json.loads(decoded['source-continuity25.json']);quality=json.loads(decoded['quality-consumed27.json'])
 assert source['accepted'] is True and source['hardware_ready'] is False and source['authority_issued'] is False
 assert source['draft_sha256']==C['draft_sha256'] and source['review_sha256']==hashlib.sha256(decoded['source-spec-review14.md']).hexdigest()
 assert quality['accepted'] is True and quality['hardware_ready'] is False and quality['draft_sha256']==C['draft_sha256']
 assert quality['review_sha256']==hashlib.sha256(decoded['review-quality26.md']).hexdigest() and quality['spec_consumption_sha256']==hashlib.sha256(decoded['source-continuity25.json']).hexdigest()
 expected=copy.deepcopy(draft);expected['parent_execution_accepted']=True;expected['hardware_ready']=False
 for n,b in decoded.items():
  if n!='simulation-inputs.admitted.json':expected['prerequisites'][str(A/'receipts'/n)]=hashlib.sha256(b).hexdigest()
 expected['execution_review']={'sha256':quality['review_sha256'],'parent_consumption_sha256':hashlib.sha256(decoded['quality-consumed27.json']).hexdigest(),'source_spec_review_sha256':source['review_sha256'],'scope':'migrated-integrated-unit-simulation-only'}
 target=json.loads(decoded['simulation-inputs.admitted.json']);assert target==expected and hashlib.sha256(decoded['simulation-inputs.admitted.json']).hexdigest()==C['admitted_sha256']
 runner=P/'runtime/run-simulation23.py';assert hashlib.sha256(runner.read_bytes()).hexdigest()==target['runner_sha256']=='e5497e7b4590bb59fd681a06dc0156f33b86484ff11bc08f5ba7f5e73c3f20a6'
 A.mkdir();owned=True;(A/'receipts').mkdir()
 for n in sorted(names-{'simulation-inputs.admitted.json'}):
  with (A/'receipts'/n).open('xb') as f:f.write(decoded[n])
 with M.open('xb') as f:f.write(decoded['simulation-inputs.admitted.json'])
 out['admission_written']=True
 assert M.read_bytes()==decoded['simulation-inputs.admitted.json']
 spec=importlib.util.spec_from_file_location('simulation_nonconsuming_preflight',runner);assert spec is not None and spec.loader is not None
 module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 verified=module.preflight(C['admitted_sha256']);assert verified==target and not R.exists()
 out.update(success=True,actual_preflight_passed=True,admitted_sha256=hashlib.sha256(M.read_bytes()).hexdigest(),manifest=str(M),runner=str(runner),runner_sha256=target['runner_sha256'],input_count=len(target['files']),original_entries=len(target['originals']),simulator_bindings=len(target['simulator_tools']),compile_entries=len(target['compile_order']),cpus=target['cpus'],address_space_limit_bytes=target['address_space_limit_bytes'],hardware_ready=False)
 out['manifest_readback']={'bytes':M.stat().st_size,'sha256':hashlib.sha256(M.read_bytes()).hexdigest(),'base64':base64.b64encode(M.read_bytes()).decode()}
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (A/'result27.json').open('x') as f:json.dump(out,f,indent=2)
 b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest()
 subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_CAPS03_SIMULATION_ADMISSION27',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
