"""Materialize exact assembly controls; test-only full preflight, no authority/native."""
import base64,copy,gzip,hashlib,importlib.util,json,os,socket,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');D=ROOT/'base01';P=ROOT/'control07';R=ROOT/'asm01';J=D/'build/syn/board/ia840f/syn_top';BATCH=sys.argv[1];INPUT='ia840f_asm_stage12_inputs';EXPECTED='8d33f2ffbea7891d4d4b987a776d62b312d1d2f3e1d3e1cac4bcd077fd380485'
out={'batch':BATCH,'scope':'exact control materialization and nonconsuming test-only preflight','success':False,'authority_issued':False,'assembly_started':False,'hardware_access':False,'exports':{}};owned=False
def sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''): digest.update(block)
    return digest.hexdigest()

def inventory(root):
    result, total = {}, 0
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            if path.is_symlink():
                entry = {'kind': 'symlink', 'target': os.readlink(path), 'resolved': str(path.resolve(strict=True))}
                if path.is_file(): entry['sha256_of_target'] = sha(path)
            elif path.is_file():
                size = path.stat().st_size; total += size
                assert total <= 8 * 1024**3
                entry = {'kind': 'file', 'bytes': size, 'sha256': sha(path)}
            else: continue
            result[str(path.relative_to(root))] = entry
            assert len(result) <= 20000
    return result, total

def binding(path, entry):
    path = Path(path)
    if entry.get('kind') == 'symlink':
        return path.is_symlink() and os.readlink(path) == entry['target'] and str(path.resolve(strict=True)) == entry['resolved'] and ('sha256_of_target' not in entry or sha(path) == entry['sha256_of_target'])
    return path.is_file() and not path.is_symlink() and path.stat().st_size == entry['bytes'] and sha(path) == entry['sha256']

def preserve(m):
    assert inventory(Path(m['original_fitted_root']))[0] == m['original_fitted_inventory']
    assert inventory(Path(m['original_mapped_root']))[0] == m['original_mapped_inventory']
    for rootkey, mapkey in [('original_setup_root','original_setup_inventory'),
                             ('release_root','original_release_inventory'), ('archive_root','archive_inventory')]:
        assert all(binding(Path(m[rootkey]) / n, item) for n, item in m[mapkey].items()), rootkey
    assert all(binding(n, item) for n, item in m['external_inputs'].items())
    for n, item in {**m['tools'], **m['opae_tools']}.items():
        assert sha(n) == item['sha256']
        if 'bytes' in item: assert Path(n).stat().st_size == item['bytes']
        if 'real' in item: assert str(Path(n).resolve()) == item['real']
    for prefix in ('setup','release','simulation','synthesis','fit','sta'):
        assert sha(m[prefix + '_result_file']) == m[prefix + '_result_sha256']
    return True

def save(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as stream: stream.write(body)

def export(path, name):
    size = path.stat().st_size
    assert size < 16 * 1024**2
    body = path.read_bytes(); assert len(body) == size
    out['exports'][name] = {'source': str(path), 'bytes': size,
                            'sha256': hashlib.sha256(body).hexdigest(),
                            'base64': base64.b64encode(body).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert not P.exists() and not R.exists()
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert len(raw)<2*1024**2 and hashlib.sha256(raw).hexdigest()==EXPECTED
 c=json.loads(gzip.decompress(raw));assert c['root']==str(ROOT)
 before=c['before'];assert before['design_root']==str(D) and inventory(D)[0]==before['design_inventory']
 m=copy.deepcopy(c['inherited_scalars']);m.update(before['inherited_preservation'])
 m.update(original_sta_root=before['source_root'],source_inventory=before['source_inventory'])
 assert inventory(Path(m['original_sta_root']))[0]==m['source_inventory'] and preserve(m)
 decoded={}
 for n,b in c['files'].items():
  assert Path(n).name==n;data=base64.b64decode(b['base64'],validate=True);assert len(data)==b['bytes'] and hashlib.sha256(data).hexdigest()==b['sha256'];decoded[n]=data
 assert json.loads(decoded['runner-inert11.json'])['runner_sha256']==hashlib.sha256(decoded['run-asm07.py']).hexdigest()
 assert json.loads(decoded['identity-inert10.json'])['callback_sha256']==hashlib.sha256(decoded['ia840f_asm_gate07.py']).hexdigest()
 assert json.loads(decoded['source-consumed07.json'])['authority_issued'] is False
 old=(J/'ofs_pr_afu.qsf').read_bytes();assert old.count(b'build_gate_sta06.tcl')==old.count(b'ia840f_sta_gate06.py')==1
 new=old.replace(b'build_gate_sta06.tcl',b'build_gate_asm07.tcl',1).replace(b'ia840f_sta_gate06.py',b'ia840f_asm_gate07.py',1)
 P.mkdir();owned=True;save(P/'before/ofs_pr_afu.qsf',old);(J/'ofs_pr_afu.qsf').write_bytes(new)
 gate=D/'build/syn/board/ia840f/setup/ia840f_asm_gate07.py';gt=D/'build/syn/board/ia840f/setup/build_gate_asm07.tcl'
 save(gate,decoded[gate.name]);save(gt,decoded[gt.name])
 for n in ('run-asm07.py','CMakeLists.txt'):save(P/'runtime'/n,decoded[n])
 prereq={m['sta_result_file']:m['sta_result_sha256']}
 for n in c['receipt_names']:save(P/'prerequisites'/n,decoded[n]);prereq[str(P/'prerequisites'/n)]=sha(P/'prerequisites'/n)
 design=copy.deepcopy(before['design_inventory']);design[str((J/'ofs_pr_afu.qsf').relative_to(D))]={'kind':'file','bytes':len(new),'sha256':sha(J/'ofs_pr_afu.qsf')}
 for p in (gate,gt):design[str(p.relative_to(D))]={'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)}
 runtime=c['runtime'];assert len(runtime)==26 and all(design[n]==v for n,v in runtime.items())
 critical={str(D/n):v for n,v in design.items() if n not in runtime};physical={str(D/n):v for n,v in before['protected_relative'].items()}
 assert len(design)==4040 and len(critical)==4014 and len(physical)==280 and all(critical[n]==v for n,v in physical.items())
 assert all(str(D/n) in critical and n not in runtime for n in c['immutable_sta']) and inventory(D)[0]==design
 for key in ('query_tcl_path','query_tcl_sha256','contract_module_path','contract_sha256','execution_review','runner_path','runner_sha256','prepared_metadata_file','prepared_metadata_sha256','prerequisites','contexts','operation_root','control_root','parent_execution_accepted'):m.pop(key,None)
 m.update(scope='prepared persona-assembly-only; not authority',design_root=str(D),project=str(J),design_inventory=design,critical_inputs=critical,runtime_outputs=runtime,
  protected_snapshot_inputs=physical,ready_for_build=False,hardware_ready=False,required_reports=c['required_reports'],required_new_images=c['required_new_images'],allowed_empty_reports=[],cpus=list(range(36)),address_space_limit_bytes=64*1024**3)
 meta=P/'prepared-inputs12.json';save(meta,(json.dumps(m,sort_keys=True,indent=2)+'\n').encode())
 draft=copy.deepcopy(m);draft.update(scope='persona-asm-only',parent_execution_accepted=False,control_root=str(P),operation_root=str(R),runner_path=str(P/'runtime/run-asm07.py'),runner_sha256=sha(P/'runtime/run-asm07.py'),
  cmake_sha256=sha(P/'runtime/CMakeLists.txt'),gate_sha256=sha(gate),gate_tcl_sha256=sha(gt),prepared_metadata_file=str(meta),prepared_metadata_sha256=sha(meta),prerequisites=prereq,
  contexts=[{'exe':'/opt/altera/26.1.1/quartus/linux64/quartus_asm','cwd':str(J),'argv':['ofs_top','-c','ofs_pr_afu']}],deadlines_seconds={'configure':60,'assembly':1800},log_limit_bytes=32*1024**2)
 draft_path=P/'asm-inputs.draft12.json';save(draft_path,(json.dumps(draft,sort_keys=True,indent=2)+'\n').encode())
 sp=importlib.util.spec_from_file_location('inert_asm_full_positive_preflight12',P/'runtime/run-asm07.py');assert sp and sp.loader
 module=importlib.util.module_from_spec(sp);sp.loader.exec_module(module);production=module.MANIFEST;assert not production.exists()
 fixture=copy.deepcopy(draft);fixture['parent_execution_accepted']=True;fixture['test_only_not_authority']=True
 fp=P/'inert-positive-preflight12.json';save(fp,(json.dumps(fixture,sort_keys=True,indent=2)+'\n').encode())
 module.MANIFEST=fp;assert module.preflight(sha(fp))==fixture and not R.exists();module.MANIFEST=production
 save(P/'positive-preflight12.json',(json.dumps({'scope':'actual live file/tool/resource/context fullpreflight, test-onlypointer; noauthority/noassembly','passed':True,'runner_sha256':draft['runner_sha256'],'production_manifest_absent':not production.exists(),'operation_absent':not R.exists()},indent=2)+'\n').encode())
 reject=[]
 for argv in (['/usr/bin/python3','-I','-B',str(P/'runtime/run-asm07.py'),'0'*64],['/usr/bin/python3','-I','-B',str(gate),'quartus']):
  z=subprocess.run(argv,cwd=J,capture_output=True,text=True,timeout=30);assert z.returncode!=0 and not R.exists();reject.append({'argv':argv,'rc':z.returncode,'stdout':z.stdout,'stderr':z.stderr})
 save(P/'entry-rejection12.json',(json.dumps({'operation_absent':True,'results':reject},indent=2)+'\n').encode())
 assert preserve(m) and inventory(Path(m['original_sta_root']))[0]==m['source_inventory']
 out.update(success=True,active_entries=4040,critical_entries=4014,runtime_entries=26,physical_entries=280,immutable_sta_names=c['immutable_sta'],full_positive_preflight_passed=True,
  originals_preserved=True,production_manifest_absent=True,operation_absent=True,draft_sha256=sha(draft_path),prepared_sha256=sha(meta))
 for n,p in {'asm-inputs.draft12.json':draft_path,'prepared-inputs12.json':meta,'positive-preflight12.json':P/'positive-preflight12.json','entry-rejection12.json':P/'entry-rejection12.json',
  'ofs_pr_afu.qsf':J/'ofs_pr_afu.qsf',gate.name:gate,gt.name:gt,'runtime/run-asm07.py':P/'runtime/run-asm07.py','runtime/CMakeLists.txt':P/'runtime/CMakeLists.txt'}.items():export(p,n)
except BaseException as exc:out['error']=repr(exc);out['traceback']=traceback.format_exc()
finally:
 if owned:save(P/'stage12-result.json',(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n').encode())
 blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
 subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
 print(json.dumps({'success':out['success'],'assembly_started':False}),flush=True)
if not out['success']:raise SystemExit(1)
