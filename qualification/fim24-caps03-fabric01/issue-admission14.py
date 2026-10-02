"""Issue exact reviewed admission and exercise non-consuming preflight."""
import base64,copy,datetime,gzip,hashlib,importlib.util,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_fabric01');P=ROOT/'prepare08';A=P/'admission14';M=P/'fabric-inputs.admitted.json';R=ROOT/'native01';G=ROOT/'generate01'
INPUT='ia840f_fim24_caps03_fabric_admission14_inputs';BUFFER='ia840f_fim24_caps03_fabric_admission14_result';EXPECTED='08370616a7c9c4fdabc75761a753e9894c4a0ab04264a3a131a1ee5c1d661a2a'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'operation_created':False};owned=False
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert all(not p.exists() and not p.is_symlink() for p in (A,M,R,G/'ahls_memory_dma_fabric.qsys',G/'ip'))
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==EXPECTED;C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT
 draft_raw=(P/'fabric-inputs.draft11.json').read_bytes();assert hashlib.sha256(draft_raw).hexdigest()==C['draft_sha256'];draft=json.loads(draft_raw)
 decoded={}
 for n,item in C['files'].items():
  assert Path(n).name==n;b=base64.b64decode(item['base64'],validate=True);assert len(b)==item['bytes'] and hashlib.sha256(b).hexdigest()==item['sha256'];decoded[n]=b
 target=json.loads(decoded['fabric-inputs.admitted.json']);expected=copy.deepcopy(draft);expected['parent_execution_accepted']=True;expected['hardware_ready']=False
 for n,b in decoded.items():
  if n!='fabric-inputs.admitted.json':expected['prerequisites'][str(A/'receipts'/n)]=hashlib.sha256(b).hexdigest()
 consumed=json.loads(decoded['quality-consumed14.json']);assert consumed['accepted'] is True and consumed['hardware_ready'] is False
 assert consumed['draft11_sha256']==C['draft_sha256'] and consumed['review_sha256']==hashlib.sha256(decoded['review-quality13.md']).hexdigest()
 expected['execution_review']={'sha256':consumed['review_sha256'],'parent_consumption_sha256':hashlib.sha256(decoded['quality-consumed14.json']).hexdigest(),'scope':'fabric-import-generate-only'}
 assert target==expected and hashlib.sha256(decoded['fabric-inputs.admitted.json']).hexdigest()==C['admitted_sha256']
 runner=P/'runtime/run-fabric08.py';assert hashlib.sha256(runner.read_bytes()).hexdigest()==target['runner_sha256']=='ac5bcb4ba87b8f3c519967381dea70d6ef8e7c64301779cc5ef5ad37d64ea80a'
 A.mkdir();owned=True;(A/'receipts').mkdir()
 for n,b in decoded.items():
  p=M if n=='fabric-inputs.admitted.json' else A/'receipts'/n
  with p.open('xb') as f:f.write(b)
 assert M.read_bytes()==decoded['fabric-inputs.admitted.json']
 spec=importlib.util.spec_from_file_location('fabric_nonconsuming_preflight',runner);assert spec is not None and spec.loader is not None;module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 verified,release=module.preflight(C['admitted_sha256']);assert verified==target and not R.exists() and not (G/'ip').exists()
 out.update(success=True,actual_preflight_passed=True,admitted_sha256=hashlib.sha256(M.read_bytes()).hexdigest(),manifest=str(M),runner=str(runner),runner_sha256=target['runner_sha256'],prepared_input_count=len(target['prepared_inputs']),original_report_count=len(target['original_report_inventory']),expected_hls_count=len(target['current_hls']),release_entries=len(release),cpus=target['cpus'],address_space_limit_bytes=target['address_space_limit_bytes'],hardware_ready=False)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (A/'result14.json').open('x') as f:json.dump(out,f,indent=2)
 b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_CAPS03_FABRIC_ADMISSION14',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
