"""Exercise the actual supervised runner with real inert processes and parser."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
from unittest.mock import patch

E = Path(__file__).resolve().parent
SOURCE = E/'candidate07/run-asm07.py'
OUT = E/'runner-inert11.json'
assert not OUT.exists()
BASE = Path(tempfile.mkdtemp(prefix='cdc-runner33-', dir=os.environ['TMPDIR']))
POPEN = subprocess.Popen
ROWS = []


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True); path.write_text(text)


def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def inv(root): return {str(p.relative_to(root)):{'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)} for p in root.rglob('*') if p.is_file()}
def snap(root): return {str(p.relative_to(root)):sha(p) for p in root.rglob('*') if p.is_file()}
def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec); spec.loader.exec_module(mod); return mod


def case(mode, expected_clean):
    root = BASE/mode; root.mkdir()
    mod = load('cdc_runner_'+mode, SOURCE)
    mod.ROOT=root; mod.D=root/'design'; mod.P=root/'control'; mod.R=root/'run'; mod.J=mod.D/'project'; mod.Q=root/'INERT_QUARTUS'; mod.MANIFEST=mod.P/'admitted.json'
    for directory in (mod.D,mod.P,mod.J): directory.mkdir(parents=True,exist_ok=True)
    qpf = mod.J/'ofs_top.qpf'; qtext='QUARTUS_VERSION = "26.1"\nDATE = "INERT"\nPROJECT_REVISION = "ofs_pr_afu"\n'; put(qpf,qtext)
    critical = mod.D/'selected.sv'; external = root/'external.sv'
    put(critical,'INERT SOURCE\n'); put(external,'INERT EXTERNAL\n')
    originals = {key:root/key for key in ('original_sta','original_fitted','original_mapped','original_setup','release','archive')}
    for directory in originals.values(): put(directory/'entry','INERT original input\n')
    tool=root/'tool'; put(tool,'INERT tool bytes, never executed\n')
    prepared=mod.P/'prepared.json'; put(prepared,'{}\n')
    cmake=mod.P/'runtime/CMakeLists.txt'; put(cmake,'# INERT CMake substitute\n')
    protected={}
    for name in mod.REQUIRED_PHYSICAL_QDB:
        path=mod.J/name; put(path,'INERT accepted fitted input\n')
        protected[str(path)]={'kind':'file','bytes':path.stat().st_size,'sha256':sha(path)}
    critical_map={str(critical):{'kind':'file','bytes':critical.stat().st_size,'sha256':sha(critical)}, str(qpf):{'kind':'file','bytes':qpf.stat().st_size,'sha256':sha(qpf)},**protected}
    sta_protected=[]
    for name in mod.IMMUTABLE_STA:
        path=mod.J/name;put(path,'INERT completedSTA immutable artifact\n');sta_protected.append(path);critical_map[str(path)]={'kind':'file','bytes':path.stat().st_size,'sha256':sha(path)}
    results={}
    for name in ('setup','release','simulation','synthesis','fit','sta'):
        path=root/(name+'-result.json'); put(path,'{}\n')
        results[name+'_result_file']=str(path); results[name+'_result_sha256']=sha(path)
    runtime=mod.D/'runtime-report'; put(runtime,'INERT before report\n')
    ctx={'exe':'/INERT_VENDOR_EXE','cwd':str(mod.J),'argv':['ofs_top','-c','ofs_pr_afu']}
    m={**results,'scope':'persona-asm-only','interface_uuid':'INERT_STATIC','afu_uuid':'INERT_AFU',
       'critical_inputs':critical_map,'external_inputs':{str(external):{'kind':'file','bytes':external.stat().st_size,'sha256':sha(external)}},
       'protected_snapshot_inputs':protected,'required_physical_qdb':mod.REQUIRED_PHYSICAL_QDB,
       'runtime_outputs':{'runtime-report':inv(mod.D)['runtime-report']},
       'original_sta_root':str(originals['original_sta']),'source_inventory':inv(originals['original_sta']),
       'original_fitted_root':str(originals['original_fitted']),'original_fitted_inventory':inv(originals['original_fitted']),
       'original_mapped_root':str(originals['original_mapped']),'original_mapped_inventory':inv(originals['original_mapped']),
       'original_setup_root':str(originals['original_setup']),'original_setup_inventory':inv(originals['original_setup']),
       'release_root':str(originals['release']),'original_release_inventory':inv(originals['release']),
       'archive_root':str(originals['archive']),'archive_inventory':inv(originals['archive']),
       'tools':{str(tool):{'bytes':tool.stat().st_size,'sha256':sha(tool)}},'opae_tools':{},
       'runner_path':str(SOURCE),'runner_sha256':sha(SOURCE),'cmake_sha256':sha(cmake),
       'prepared_metadata_file':str(prepared),'prepared_metadata_sha256':sha(prepared),
       'prerequisites':{},'contexts':[ctx],'cpus':sorted(os.sched_getaffinity(0)),
       'address_space_limit_bytes':64*1024**3,'log_limit_bytes':1024 if mode=='overflow' else 1024**2,
       'deadlines_seconds':{'configure':4,'assembly':0.5 if mode=='timeout' else 4},
       'qpf_before':{'bytes':qpf.stat().st_size,'sha256':sha(qpf),'text':qtext}}
    launched=[]
    def preflight(_):
        if mode=='unissued': raise AssertionError('INERT admission absent')
        return copy.deepcopy(m)
    def popen(argv, **kwargs):
        assert argv[0]=='/usr/bin/cmake'
        target=argv[argv.index('--target')+1] if '--target' in argv else 'configure'
        code='print("INERT configure, not CMake")'
        if target=='assembly':
            event={'accepted':True,'manifest_sha256':'a'*64,'native':{'exe':ctx['exe'],'cwd':ctx['cwd'],'argv':[ctx['exe'],*ctx['argv']]}}
            if mode=='wrong_callback': event['native']['cwd']='/WRONG_INERT_CWD'
            code='from pathlib import Path\nimport json\nR=Path('+repr(str(mod.R))+')\nJ=Path('+repr(str(mod.J))+')\n'
            for name in mod.REQUIRED_IMAGES+mod.REQUIRED_REPORTS:
                code+='p=J/'+repr(name)+';p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b"INERT newly emitted assembly artifact\\n")\n'
            if mode!='missing_callback': code+='(R/"gate-events.jsonl").write_text('+repr(json.dumps(event)+'\n')+')\n'
            code+='print("INERT Version 26.1.1 Build 130 SC Pro Edition",flush=True)\nprint("Quartus Prime Assembler was successful",flush=True)\n'
            if mode=='nonzero': code+='raise SystemExit(7)\n'
            if mode=='native_error': code+='print("Error (suppressible): INERT")\n'
            if mode=='marker': code+='print("IA840F_ASM_GATE_REJECTED INERT")\n'
            if mode=='overflow': code+='print("x"*8192)\n'
            if mode=='timeout': code+='import time;time.sleep(8)\n'
            if mode=='drain_marker': code+='import os,time\npid=os.fork()\nif pid:os._exit(0)\ntime.sleep(0.3)\nprint("IA840F_ASM_GATE_REJECTED INERT",flush=True)\ntime.sleep(8)\n'
            if mode=='missing_report':code+='(J/'+repr(mod.REQUIRED_REPORTS[0])+').unlink()\n'
            if mode.startswith('missing_image_'):code+='(J/'+repr(mod.REQUIRED_IMAGES[int(mode.rsplit('_',1)[1])])+').unlink()\n'
            if mode=='empty_pmsf':code+='(J/'+repr(mod.REQUIRED_IMAGES[1])+').write_bytes(b"")\n'
            mutate={'critical_drift':critical,'metadata_drift':prepared,
                    'sta_drift':originals['original_sta']/'entry','fitted_drift':originals['original_fitted']/'entry',
                    'mapped_drift':originals['original_mapped']/'entry','external_drift':external,'tool_drift':tool}
            if mode in mutate: code+='Path('+repr(str(mutate[mode]))+').write_text("INERT DRIFT")\n'
            if mode.startswith('protected_sta_'):code+='Path('+repr(str(sta_protected[int(mode.rsplit('_',1)[1])]))+').write_text("INERT forbiddenSTA drift")\n'
            if mode=='sta_extra': code+='Path('+repr(str(originals['original_sta']/'extra'))+').write_text("INERT extra")\n'
            if mode=='qpf_date': code+='Path('+repr(str(qpf))+').write_text('+repr(qtext.replace('INERT','INERT LATER'))+')\n'
            if mode=='runtime_changed': code+='Path('+repr(str(runtime))+').write_text("INERT updated runtime")\n'
        launched.append({'requested':argv,'actual_inert_child':[sys.executable,'-B','-c',code]})
        return POPEN([sys.executable,'-B','-c',code],**kwargs)
    def tmux(argv,**kwargs):
        assert argv[0]=='tmux'
        return subprocess.CompletedProcess(argv,0)
    post=mod.postflight
    def postflight(*args):
        if mode=='postflight_fault': raise RuntimeError('INERT postflight exception')
        return post(*args)
    before=snap(root)
    with patch.object(mod,'preflight',side_effect=preflight), patch.object(mod,'postflight',side_effect=postflight), \
         patch.object(mod.subprocess,'Popen',side_effect=popen), patch.object(mod.subprocess,'run',side_effect=tmux), \
         patch.object(sys,'argv',['INERT','a'*64]), patch.dict(os.environ,{'LM_LICENSE_FILE':'INERT','MGLS_LICENSE_FILE':'INERT','SALT_LICENSE_SERVER':'INERT'}), \
         contextlib.redirect_stdout(io.StringIO()):
        if mode=='unissued':
            try: mod.run()
            except AssertionError: pass
            else: raise AssertionError('Unissued runner accepted')
            assert not mod.R.exists() and not launched and snap(root)==before
            ROWS.append({'case':mode,'rejected_before_write':True}); return
        rc=mod.run(); result=json.loads((mod.R/'result.json').read_text())
        assert result['execution_clean'] is expected_clean and (rc==0) is expected_clean,(mode,rc,result.get('postflight_errors'),result.get('postflight_exception'))
        assert result.get('coverage_accepted',False) is False
        assert all(not row.get('owned_group_live_after') for row in result['commands'])
        if mode=='timeout': assert result['commands'][-1]['effective_rc']==124
        if mode=='drain_marker': assert result['commands'][-1]['gate_rejected'] and not result['commands'][-1]['timeout']
        after=snap(root); count=len(launched)
        try: mod.run()
        except FileExistsError: pass
        else: raise AssertionError('Spent replay accepted')
        assert snap(root)==after and len(launched)==count
    ROWS.append({'case':mode,'expected_execution_clean':expected_clean,'actual_rc':rc,
                 'execution_clean':result['execution_clean'],'coverage_accepted':False,
                 'commands':result['commands'],'postflight_errors':result.get('postflight_errors'),
                 'postflight_exception':result.get('postflight_exception'),'replay_preserved':True,
                 'actual_inert_commands':launched})


for mode in ('clean','runtime_changed'): case(mode,True)
for mode in ('unissued','nonzero','native_error','marker','missing_callback','wrong_callback','missing_report','missing_image_0','missing_image_1','missing_image_2','empty_pmsf',
             'critical_drift','metadata_drift','sta_drift','fitted_drift','mapped_drift',
             'external_drift','tool_drift','sta_extra','qpf_date','overflow','timeout','drain_marker','postflight_fault','protected_sta_0','protected_sta_1','protected_sta_2','protected_sta_3'):
    case(mode,False)
with OUT.open('x') as stream:
    json.dump({'success':True,'scope':'actual supervisor/postflight/image checks and real inert children; mocked admission/CMake/tmux/callback, no vendor tool',
               'count':len(ROWS),'runner_sha256':sha(SOURCE),
               'cases':ROWS,'scratch':str(BASE)},stream,indent=2)
    stream.write('\n')
print(json.dumps({'success':True,'runner_cases':len(ROWS),'vendor_tools_executed':False,'output':str(OUT)}))
