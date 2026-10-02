"""Stage separately reviewed STA inputs/controls; no timing or authority."""
import base64,copy,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01');D=ROOT/'base01';P=ROOT/'control06';R=ROOT/'sta01';J=D/'build/syn/board/ia840f/syn_top';COPY=ROOT/'prepare01/prepared-copy01.json';INPUT='ia840f_fim24_caps03_sta_stage15_inputs';BUFFER='ia840f_fim24_caps03_sta_stage15_result';EXPECTED='f76fa1137e4dfaf2c4cf2df72944e33bb36570387593d9071b59d044aad428bf'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_timing_executed':False,'hardware_access':False,'authority_issued':False,'exports':{}};owned=False
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def bind(root,inv):
 for n,m in inv.items():
  p=root/n
  if m.get('kind')=='symlink':
   assert p.is_symlink() and os.readlink(p)==m['target'],n
   if 'resolved' in m:assert str(p.resolve(strict=True))==m['resolved'],n
   if 'sha256_of_target' in m:assert sha(p)==m['sha256_of_target'],n
  else:assert p.is_file() and not p.is_symlink() and p.stat().st_size==m['bytes'] and sha(p)==m['sha256'],n
 return True
def inventory(root):
 result={};total=0
 for d,dirs,files in os.walk(root,followlinks=False):
  for name in dirs+files:
   p=Path(d)/name;n=str(p.relative_to(root))
   if p.is_symlink():
    x={'kind':'symlink','target':os.readlink(p),'resolved':str(p.resolve(strict=True))}
    if p.is_file():x['sha256_of_target']=sha(p)
   elif p.is_file():
    size=p.stat().st_size;total+=size;assert total<=8*1024**3;x={'kind':'file','bytes':size,'sha256':sha(p)}
   else:continue
   result[n]=x;assert len(result)<=20000
 return result,total
def save(p,b):
 p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('xb') as f:f.write(b)
def capture(p,name):
 b=p.read_bytes();assert len(b)<16*1024**2;out['exports'][name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert all(not p.exists() and not p.is_symlink() for p in (P,R))
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==EXPECTED;C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT and sha(COPY)==C['copy_metadata_sha256']
 original=json.loads(COPY.read_text());beforeinv=original['copied_inventory'];assert len(beforeinv)==4025 and inventory(D)==(beforeinv,original['copied_file_bytes'])
 S=Path(original['source_root']);assert inventory(S)==(original['source_inventory'],original['copied_file_bytes'])
 assert sha(original['source_result_file'])==original['source_result_sha256'] and sha(original['source_admitted_file'])==original['source_admitted_sha256']
 assert bind(Path(original['original_mapped_root']),original['original_mapped_inventory']) and all(bind(Path('/'),{n:x}) for n,x in original['external_inputs'].items())
 assert bind(Path(original['original_setup_root']),original['original_setup_inventory']) and bind(Path(original['release_root']),original['original_release_inventory']) and bind(Path(original['old_archive_root']),original['old_archive_inventory'])
 for n,x in list(original['tools'].items())+list(original['opae_tools'].items()):
  assert sha(n)==x['sha256']
  if 'real' in x:assert str(Path(n).resolve())==x['real']
 active=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe')
   if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 assert not active,active
 decoded={}
 for n,x in C['files'].items():
  assert Path(n).name==n;b=base64.b64decode(x['base64'],validate=True);assert len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256'];decoded[n]=b
 assert hashlib.sha256(decoded['input-output-roles02.json']).hexdigest()==C['roles_sha256'] and hashlib.sha256(decoded['source-consumed09.json']).hexdigest()==C['source_consumption_sha256']
 roles=json.loads(decoded['input-output-roles02.json']);consumed=json.loads(decoded['source-consumed09.json']);plan=json.loads(decoded['source-plan05.json']);assert consumed['accepted'] and not consumed['authority_issued'] and not consumed['timing_accepted']
 assert {n:x['binding'] for n,x in roles['roles'].items()}==beforeinv and roles['copy_metadata_sha256']==C['copy_metadata_sha256']
 assert len(roles['proposed_immutable'])==3999 and len(roles['proposed_runtime_outputs'])==26 and len(roles['protected_physical_snapshots'])==280
 assert set(roles['proposed_immutable']).isdisjoint(roles['proposed_runtime_outputs']) and set(roles['proposed_immutable'])|set(roles['proposed_runtime_outputs'])==set(beforeinv)
 for n in ('numeric-inert10.json','gate-inert11.json','identity-inert12.json','runner-inert13.json','tcl-inert14.json','cmake-inert04.json'):assert json.loads(decoded[n])['success']
 assert json.loads(decoded['numeric-inert10.json'])['module_sha256']==hashlib.sha256(decoded['sta_numeric06.py']).hexdigest()
 assert json.loads(decoded['runner-inert13.json'])['runner_sha256']==hashlib.sha256(decoded['run-sta06.py']).hexdigest() and json.loads(decoded['runner-inert13.json'])['numeric_sha256']==hashlib.sha256(decoded['sta_numeric06.py']).hexdigest()
 assert json.loads(decoded['gate-inert11.json'])['source_sha256']==hashlib.sha256(decoded['ia840f_sta_gate06.py']).hexdigest()
 assert json.loads(decoded['identity-inert12.json'])['producer_sha256']==hashlib.sha256(decoded['run-sta06.py']).hexdigest() and json.loads(decoded['identity-inert12.json'])['callback_sha256']==hashlib.sha256(decoded['ia840f_sta_gate06.py']).hexdigest()
 assert json.loads(decoded['cmake-inert04.json'])['cmake_sha256']==hashlib.sha256(decoded['CMakeLists.txt']).hexdigest() and json.loads(decoded['tcl-inert14.json'])['tcl_sha256']==hashlib.sha256(decoded['build_gate_sta06.tcl']).hexdigest()
 qsf=J/'ofs_pr_afu.qsf';old=qsf.read_bytes();new=decoded['ofs_pr_afu.proposed.qsf'];assert new==old.replace(b'build_gate_physical08.tcl',b'build_gate_sta06.tcl',1).replace(b'ia840f_physical_gate08.py',b'ia840f_sta_gate06.py',1)
 assert old.count(b'build_gate_physical08.tcl')==old.count(b'ia840f_physical_gate08.py')==1
 P.mkdir();owned=True;save(P/'before/ofs_pr_afu.qsf',old)
 gate=D/'build/syn/board/ia840f/setup/ia840f_sta_gate06.py';tcl=D/'build/syn/board/ia840f/setup/build_gate_sta06.tcl'
 save(gate,decoded[gate.name]);save(tcl,decoded[tcl.name]);qsf.write_bytes(new)
 for n in ('run-sta06.py','sta_numeric06.py','CMakeLists.txt'):save(P/'runtime'/n,decoded[n])
 prerequisites={str(COPY):sha(COPY),str(Path(original['source_admitted_file'])):original['source_admitted_sha256'],str(P/'runtime/sta_numeric06.py'):sha(P/'runtime/sta_numeric06.py')}
 for n,b in decoded.items():
  if n in ('run-sta06.py','sta_numeric06.py','CMakeLists.txt',gate.name,tcl.name,'ofs_pr_afu.proposed.qsf'):continue
  save(P/'prerequisites'/n,b);prerequisites[str(P/'prerequisites'/n)]=sha(P/'prerequisites'/n)
 design=copy.deepcopy(beforeinv);design[str(qsf.relative_to(D))]={'kind':'file','bytes':len(new),'sha256':sha(qsf)}
 for p in (gate,tcl):design[str(p.relative_to(D))]={'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)}
 runtime=copy.deepcopy(roles['proposed_runtime_outputs']);critical={str(D/n):x for n,x in design.items() if n not in runtime};snapshots={str(D/n):x for n,x in roles['protected_physical_snapshots'].items()}
 assert len(design)==4027 and len(critical)==4001 and set(snapshots).issubset(critical) and all(critical[n]==x for n,x in snapshots.items())
 assert inventory(D)[0]==design and all((J/n).is_file() and str(J/n) in snapshots for n in C['required_physical_qdb'])
 prepared={'scope':'tested final-snapshot STA inputs; no authority','design_root':str(D),'project':str(J),'design_inventory':design,'critical_inputs':critical,'runtime_outputs':runtime,'protected_snapshot_inputs':snapshots,'source_root':str(S),'source_inventory':original['source_inventory'],'original_mapped_root':original['original_mapped_root'],'original_mapped_inventory':original['original_mapped_inventory'],'external_inputs':original['external_inputs'],'archive_root':original['old_archive_root'],'archive_inventory':original['old_archive_inventory'],'original_setup_root':original['original_setup_root'],'original_setup_inventory':original['original_setup_inventory'],'release_root':original['release_root'],'original_release_inventory':original['original_release_inventory'],'tools':original['tools'],'opae_tools':original['opae_tools'],'interface_uuid':original['interface_uuid'],'afu_uuid':original['afu_uuid'],'qpf_before':original['qpf_before'],'static_qdb_sha256':original['static_qdb_sha256'],'fit_result_file':original['source_result_file'],'fit_result_sha256':original['source_result_sha256'],'copy_metadata_file':str(COPY),'copy_metadata_sha256':C['copy_metadata_sha256'],'role_proposal_file':str(P/'prerequisites/input-output-roles02.json'),'role_proposal_sha256':C['roles_sha256'],'numeric_module_path':str(P/'runtime/sta_numeric06.py'),'numeric_module_sha256':sha(P/'runtime/sta_numeric06.py'),'cpus':plan['resources']['cpus'],'address_space_limit_bytes':plan['resources']['address_space_limit_bytes'],'ready_for_build':False,'hardware_ready':False}
 for n,x in original['predecessor_results'].items():prepared[n+'_result_file']=x['file'];prepared[n+'_result_sha256']=x['sha256']
 assert (J/'ofs_top.qpf').read_text()==prepared['qpf_before']['text'] and sha(J/'ofs_top.qdb')==prepared['static_qdb_sha256']
 meta=P/'prepared-inputs15.json';save(meta,(json.dumps(prepared,sort_keys=True,indent=2)+'\n').encode())
 manifest=copy.deepcopy(prepared);manifest.update(scope='persona-sta-only',parent_execution_accepted=False,control_root=str(P),operation_root=str(R),runner_path=str(P/'runtime/run-sta06.py'),runner_sha256=sha(P/'runtime/run-sta06.py'),cmake_sha256=sha(P/'runtime/CMakeLists.txt'),gate_sha256=sha(gate),gate_tcl_sha256=sha(tcl),prepared_metadata_file=str(meta),prepared_metadata_sha256=sha(meta),prerequisites=prerequisites,contexts=[plan['native_context']],required_reports=C['required_reports'],required_physical_qdb=C['required_physical_qdb'],allowed_empty_reports=C['allowed_empty_reports'],deadlines_seconds=plan['resources']['deadlines_seconds'],log_limit_bytes=plan['resources']['log_limit_bytes'])
 save(P/'sta-inputs.draft15.json',(json.dumps(manifest,sort_keys=True,indent=2)+'\n').encode());assert all(not (J/n).exists() for n in manifest['required_reports'])
 rejects=[]
 for argv in (['/usr/bin/env','-u','PYTHONOPTIMIZE','/usr/bin/python3','-I','-B',str(P/'runtime/run-sta06.py'),'0'*64],['/usr/bin/env','-u','PYTHONOPTIMIZE','/usr/bin/python3','-I','-B',str(gate),'quartus']):
  c=subprocess.run(argv,cwd=P,capture_output=True,text=True,timeout=20);assert c.returncode!=0 and not R.exists();rejects.append({'argv':argv,'rc':c.returncode,'stdout':c.stdout,'stderr':c.stderr})
 assert 'sta-inputs.admitted.json' in rejects[0]['stderr'] and 'FileNotFoundError' in rejects[0]['stderr'] and 'IA840F_GATE_REJECTED' in rejects[1]['stderr']
 save(P/'entry-rejection15.json',(json.dumps({'operation_absent':True,'native_timing_executed':False,'results':rejects},indent=2)+'\n').encode())
 assert inventory(S)==(original['source_inventory'],original['copied_file_bytes']) and inventory(D)[0]==design
 assert bind(Path(original['original_mapped_root']),original['original_mapped_inventory']) and all(bind(Path('/'),{n:x}) for n,x in original['external_inputs'].items()) and bind(Path(original['original_setup_root']),original['original_setup_inventory']) and bind(Path(original['release_root']),original['original_release_inventory']) and bind(Path(original['old_archive_root']),original['old_archive_inventory'])
 assert sha(original['source_result_file'])==original['source_result_sha256'] and sha(original['source_admitted_file'])==original['source_admitted_sha256']
 out.update(success=True,active_design_entries=len(design),critical_entries=len(critical),runtime_output_entries=len(runtime),physical_snapshot_entries=len(snapshots),original_fit_preserved=True,original_mapped_preserved=True,external_originals_archive_preserved=True,static_qdb_preserved=True,qpf_byte_identical=True,exact_two_reference_qsf_delta=True,added_gate_files=[str(gate.relative_to(D)),str(tcl.relative_to(D))],early_runner_and_callback_rejected=True,sta_operation_absent=True,runner_sha256=manifest['runner_sha256'],numeric_sha256=manifest['numeric_module_sha256'],gate_sha256=manifest['gate_sha256'],gate_tcl_sha256=manifest['gate_tcl_sha256'],cmake_sha256=manifest['cmake_sha256'],prepared_metadata_sha256=sha(meta),draft_sha256=sha(P/'sta-inputs.draft15.json'))
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  save(P/'stage15.json',(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n').encode())
  paths={'prepared-inputs15.json':P/'prepared-inputs15.json','sta-inputs.draft15.json':P/'sta-inputs.draft15.json','entry-rejection15.json':P/'entry-rejection15.json','stage15.json':P/'stage15.json','runtime/run-sta06.py':P/'runtime/run-sta06.py','runtime/sta_numeric06.py':P/'runtime/sta_numeric06.py','runtime/CMakeLists.txt':P/'runtime/CMakeLists.txt','design/ofs_pr_afu.qsf':J/'ofs_pr_afu.qsf','design/ia840f_sta_gate06.py':D/'build/syn/board/ia840f/setup/ia840f_sta_gate06.py','design/build_gate_sta06.tcl':D/'build/syn/board/ia840f/setup/build_gate_sta06.tcl'}
  for n,p in paths.items():
   if p.exists():capture(p,n)
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('STA_STAGE15',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
