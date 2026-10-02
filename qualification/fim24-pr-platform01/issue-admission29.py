"""Issue reviewed release-only admission; execute no native target."""
import base64,copy,datetime,gzip,hashlib,importlib.util,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01');P=ROOT/'prepared15';A=P/'admission29';M=P/'export-inputs.admitted.json';R=ROOT/'export01';T=ROOT/'release01'
INPUT='ia840f_fim24_pr_admission29_inputs';BUFFER='ia840f_fim24_pr_admission29_result';EXPECTED='5601a822596de2393433ac00c943cd8281f5f0dc83856280718efbd8c19b9e1d'
result={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'native_operation_created':False};owned=False
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert all(not p.exists() and not p.is_symlink() for p in (A,M,R,T))
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==EXPECTED;C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT
 draft_bytes=(P/'revision25/export-inputs.draft25.json').read_bytes();assert hashlib.sha256(draft_bytes).hexdigest()==C['draft25_sha256'];draft=json.loads(draft_bytes)
 decoded={}
 for n,meta in C['files'].items():
  assert Path(n).name==n;b=base64.b64decode(meta['base64'],validate=True);assert len(b)==meta['bytes'] and hashlib.sha256(b).hexdigest()==meta['sha256'];decoded[n]=b
 target=json.loads(decoded['export-inputs.admitted.json']);expected=copy.deepcopy(draft)
 expected['parent_execution_accepted']=True;expected['resource_delta']['final_spec_and_quality_pending']=False;expected['runner_revision']['quality_accepted']=True
 for n,b in decoded.items():
  if n!='export-inputs.admitted.json':expected['prerequisites'][str(A/'receipts'/n)]=hashlib.sha256(b).hexdigest()
 consumption=json.loads(decoded['quality-consumed29.json']);assert consumption['accepted'] is True and consumption['I1_closed'] and consumption['M1_closed']
 assert consumption['review_sha256']==hashlib.sha256(decoded['review-quality28.md']).hexdigest() and consumption['draft25_sha256']==C['draft25_sha256']
 expected['final_execution_review']={'sha256':consumption['review_sha256'],'parent_consumption_sha256':hashlib.sha256(decoded['quality-consumed29.json']).hexdigest(),'scope':'release-only; no hardware or future persona authority'}
 assert target==expected and hashlib.sha256(decoded['export-inputs.admitted.json']).hexdigest()==C['admitted_sha256']
 runner=P/'candidate24/run-export24.py';assert hashlib.sha256(runner.read_bytes()).hexdigest()==target['runner_sha256']=='829ec7bb96644f3f2730bf43b571c6f40e7e011d1e42e38931f7b680b2275f14'
 A.mkdir();owned=True;(A/'receipts').mkdir()
 for n,b in decoded.items():
  destination=M if n=='export-inputs.admitted.json' else A/'receipts'/n
  with destination.open('xb') as f:f.write(b)
 assert M.read_bytes()==decoded['export-inputs.admitted.json']
 spec=importlib.util.spec_from_file_location('read_only_export_preflight',runner);assert spec is not None and spec.loader is not None;module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 checked,stage,prepared=module.preflight(C['admitted_sha256'])
 assert checked==target and not R.exists() and not T.exists()
 result.update(success=True,admitted_sha256=hashlib.sha256(M.read_bytes()).hexdigest(),admitted_bytes=M.stat().st_size,admitted_manifest=str(M),runner=str(runner),runner_sha256=target['runner_sha256'],actual_preflight_passed=True,original_work24_entries=len(stage['original_inventory']),prepared_entries=len(prepared),critical_inputs=len(target['critical_inputs']),pim_entries=len(target['pim_inventory']),cpus=target['cpus'],address_space_limit_bytes=target['address_space_limit_bytes'],operation_and_target_absent=True,ready_for_build=False)
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (A/'admission-result29.json').open('x') as f:json.dump(result,f,indent=2)
 b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_PR_ADMISSION29',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
