"""Issue one reviewed setup-only record; never launch the native setup."""
import base64,copy,datetime,gzip,hashlib,importlib.util,json,os,re,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01');P=ROOT/'control03';A=P/'admission12';M=P/'setup-inputs.admitted.json';R=ROOT/'setup01';T=R/'persona'
INPUT='ia840f_fim24_caps03_persona_admission12_inputs';BUFFER='ia840f_fim24_caps03_persona_admission12_result';EXPECTED='fb30467007fe20c932f617d7b265ec11df448646f7ada9132e9512254453f15c'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'operation_created':False,'admission_written':False};owned=False
try:
 assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',EXPECTED)
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert all(not p.exists() and not p.is_symlink() for p in (A,M,R,T))
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert len(raw)<1024**2 and hashlib.sha256(raw).hexdigest()==EXPECTED
 C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT and C['scope']=='persona-file-setup-only'
 draft_raw=(P/'setup-inputs.draft06.json').read_bytes();assert hashlib.sha256(draft_raw).hexdigest()==C['draft_sha256']=='c67ecca4f10f69dccec23458a90a5a6af04d59f268c22fbf4931e0402b78d791';draft=json.loads(draft_raw)
 assert draft['parent_execution_accepted'] is False and draft['hardware_ready'] is False
 names={'setup-inputs.admitted.json','review-setup08.md','spec-consumed09.json','review-quality11.md','quality-consumed12.json'}
 assert set(C['files'])==names
 decoded={}
 for n,item in C['files'].items():
  assert Path(n).name==n;b=base64.b64decode(item['base64'],validate=True);assert len(b)==item['bytes'] and hashlib.sha256(b).hexdigest()==item['sha256'];decoded[n]=b
 source=json.loads(decoded['spec-consumed09.json']);quality=json.loads(decoded['quality-consumed12.json'])
 assert source['accepted'] is True and source['hardware_ready'] is False and source['authority_issued'] is False
 assert source['draft_sha256']==C['draft_sha256'] and source['review_sha256']==hashlib.sha256(decoded['review-setup08.md']).hexdigest()
 assert quality['accepted'] is True and quality['hardware_ready'] is False and quality['draft_sha256']==C['draft_sha256']
 assert quality['review_sha256']==hashlib.sha256(decoded['review-quality11.md']).hexdigest() and quality['spec_consumption_sha256']==hashlib.sha256(decoded['spec-consumed09.json']).hexdigest()
 expected=copy.deepcopy(draft);expected['parent_execution_accepted']=True;expected['hardware_ready']=False
 for n,b in decoded.items():
  if n!='setup-inputs.admitted.json':expected['prerequisites'][str(A/'receipts'/n)]=hashlib.sha256(b).hexdigest()
 expected['execution_review']={'sha256':quality['review_sha256'],'parent_consumption_sha256':hashlib.sha256(decoded['quality-consumed12.json']).hexdigest(),'source_spec_review_sha256':source['review_sha256'],'scope':'persona-file-setup-only'}
 target=json.loads(decoded['setup-inputs.admitted.json']);assert target==expected and hashlib.sha256(decoded['setup-inputs.admitted.json']).hexdigest()==C['admitted_sha256']
 runner=P/'runtime/run-setup03.py';assert hashlib.sha256(runner.read_bytes()).hexdigest()==target['runner_sha256']=='a0457610b1f37b63b2241c539ff993bc87b3eb70869ca65e49268ae9353fb74c'
 A.mkdir();owned=True;(A/'receipts').mkdir()
 for n in sorted(names-{'setup-inputs.admitted.json'}):
  with (A/'receipts'/n).open('xb') as f:f.write(decoded[n])
 with M.open('xb') as f:f.write(decoded['setup-inputs.admitted.json'])
 out['admission_written']=True
 assert M.read_bytes()==decoded['setup-inputs.admitted.json']
 spec=importlib.util.spec_from_file_location('setup_nonconsuming_preflight',runner);assert spec is not None and spec.loader is not None
 module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 verified,release,fabric=module.preflight(C['admitted_sha256']);assert verified==target and not R.exists() and not T.exists()
 out.update(success=True,actual_preflight_passed=True,admitted_sha256=hashlib.sha256(M.read_bytes()).hexdigest(),manifest=str(M),runner=str(runner),runner_sha256=target['runner_sha256'],input_count=len(target['staged_inventory']),release_entries=len(release),fabric_entries=len(fabric),cpus=target['cpus'],address_space_limit_bytes=target['address_space_limit_bytes'],hardware_ready=False)
 out['manifest_readback']={'bytes':M.stat().st_size,'sha256':hashlib.sha256(M.read_bytes()).hexdigest(),'base64':base64.b64encode(M.read_bytes()).decode()}
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (A/'result12.json').open('x') as f:json.dump(out,f,indent=2)
 b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest()
 subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_CAPS03_PERSONA_ADMISSION12',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
