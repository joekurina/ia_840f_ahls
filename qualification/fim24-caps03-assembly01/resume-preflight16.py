"""Fresh non-consuming assembly preflight in owned tmux; no native/hardware."""
import datetime,gzip,hashlib,importlib.util,json,os,socket,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01')
P=ROOT/'control07';R=ROOT/'asm01';BATCH=sys.argv[1]
EXPECTED={'asm-inputs.draft12.json':'08da0a20947b0c944928b39a9650b58370106c047ef473c761c3b90d8164a349','prepared-inputs12.json':'dcb3662f5d94ce582a25da9c0a86d312cd07803cfea0edfc5fe79e1a7c29a74f','runtime/run-asm07.py':'1e90a0b24b92824edd616f129fc14f34594c23a17525117f21e30f14f225db1d','runtime/CMakeLists.txt':'3eba22d917d297b5ec349357adb0be9afd70b9c1e56c8492e2c3f4159bba22be'}
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
out={'batch':BATCH,'scope':'fresh actual-file/tool/resource preflight with test-only manifest pointer; no authority/native/hardware','started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'authority_issued':False,'assembly_started':False,'hardware_access':False}
receipt=P/'resume-preflight16.json'
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not receipt.exists() and not R.exists() and not (P/'asm-inputs.admitted.json').exists()
    assert all(sha(P/n)==h for n,h in EXPECTED.items())
    draft=json.loads((P/'asm-inputs.draft12.json').read_text())
    fixture=dict(draft);fixture['parent_execution_accepted']=True;fixture['test_only_not_authority']=True
    fp=P/'inert-positive-preflight12.json'
    expected=(json.dumps(fixture,sort_keys=True,indent=2)+'\n').encode()
    assert fp.read_bytes()==expected
    spec=importlib.util.spec_from_file_location('inert_assembly_resume16',P/'runtime/run-asm07.py')
    assert spec is not None and spec.loader is not None
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    production=getattr(module,'MANIFEST')
    try:
        module.MANIFEST=fp
        assert module.preflight(sha(fp))==fixture
    finally:
        module.MANIFEST=production
    assert not R.exists() and not production.exists()
    out.update(success=True,full_positive_preflight_passed=True,production_manifest_absent=True,operation_absent=True,bindings=EXPECTED,cpu_affinity=sorted(os.sched_getaffinity(0)),boot_id=Path('/proc/sys/kernel/random/boot_id').read_text().strip(),window_pane=subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{window_id} #{pane_id}'],text=True).strip())
except BaseException as exc:
    out.update(error=repr(exc),traceback=traceback.format_exc())
out['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
if not receipt.exists():
    with receipt.open('x') as stream:json.dump(out,stream,indent=2);stream.write('\n')
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True)
subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'assembly_started':False}),flush=True)
if not out['success']:raise SystemExit(1)
