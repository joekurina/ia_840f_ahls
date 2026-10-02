"""Real inert children exercise fabric control flow; no vendor execution."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
from typing import Any
from unittest.mock import patch

E=Path(__file__).resolve().parent
SOURCE=E/'candidate08/run-fabric08.py'
OUT=E/'runner-inert09.json'
assert not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='fabric-inert09-',dir=os.environ['TMPDIR']))
POPEN=subprocess.Popen
ROWS=[]


def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def snapshot(root):return {str(p.relative_to(root)):digest(p) for p in root.rglob('*') if p.is_file()}


def put(p,text):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)


def case(name,expected_clean,mode='normal'):
    root=BASE/name;root.mkdir()
    spec=importlib.util.spec_from_file_location('fabric_fixture_'+name,SOURCE)
    assert spec is not None and spec.loader is not None
    mod: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
    mod.B=root;mod.ROOT=root;mod.G=root/'generate';mod.D=mod.G/'mmhost_ia840f.report.prj';mod.P=root/'prepare';mod.R=root/'operation';mod.Q=root/'fake-tool';mod.S=root/'original';mod.REL=root/'release'
    for p in (mod.G,mod.D,mod.P,mod.S,mod.REL):p.mkdir(parents=True,exist_ok=True)
    qsf='set_global_assignment -name FAMILY "Agilex 7"\nset_global_assignment -name DEVICE AGFB027R25A2E2V\nset_global_assignment -name TOP_LEVEL_ENTITY ahls_memory_dma_fabric\nset_global_assignment -name NUM_PARALLEL_PROCESSORS 36\n'
    for n,t in [('ahls_memory_dma_fabric.qpf','PROJECT_REVISION = "ahls_memory_dma_fabric"\n'),('ahls_memory_dma_fabric.qsf',qsf),('make-system.tcl','# INERT\n'),('component.tcl','# INERT\n')]:put(mod.G/n,t)
    put(mod.S/'core.sv','INERT CORRECTED HLS\n');put(mod.D/'core.sv','INERT CORRECTED HLS\n')
    put(mod.P/'runtime/CMakeLists.txt','# INERT CMAKE\n')
    uuid='00000000-0000-0000-0000-000000000000'
    put(mod.REL/'hw/lib/fme-ifc-id.txt',uuid+'\n')
    release={'hw/lib/fme-ifc-id.txt':{'kind':'file','bytes':(mod.REL/'hw/lib/fme-ifc-id.txt').stat().st_size,'sha256':digest(mod.REL/'hw/lib/fme-ifc-id.txt')}}
    prepared={str(p.relative_to(mod.G)):{'bytes':p.stat().st_size,'sha256':digest(p)} for p in mod.G.rglob('*') if p.is_file()}
    m={'prepared_inputs':prepared,'original_report_inventory':{'core.sv':{'bytes':(mod.S/'core.sv').stat().st_size,'sha256':digest(mod.S/'core.sv')}},'current_hls':{'core.sv':{'current_sha256':digest(mod.D/'core.sv')}},'tools':{},'vendor_sources':{},'prerequisites':{},'interface_uuid':uuid,'runner_sha256':digest(SOURCE),'cmake_sha256':digest(mod.P/'runtime/CMakeLists.txt'),'cpus':sorted(os.sched_getaffinity(0)),'address_space_limit_bytes':64*1024**3,'deadlines_seconds':{'configure':4.0,'version':4.0,'import':4.0,'generate':3.0},'log_limit_bytes':512 if mode=='overflow' else 1048576}
    hpath='ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth/core.sv'
    ipath='ip/ahls_memory_dma_fabric/fabric.ip'
    qips=['ahls_memory_dma_fabric/ahls_memory_dma_fabric.qip','ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/ahls_memory_dma_fabric_fabric.qip']
    outputs={hpath:'INERT CORRECTED HLS\n',**{n:'# INERT QIP\n' for n in qips}}
    if mode=='hls_drift':outputs[hpath]='INERT DRIFT\n'
    if mode=='missing_output':outputs.pop(qips[1])
    names=sorted(mod.INTERFACES)
    if mode=='missing_interface':names.remove('bank_out1')
    import_outputs={'ahls_memory_dma_fabric.qsys':'<system/>\n',ipath:'<component><altera_has_errors>'+('true' if mode=='child_error' else 'false')+'</altera_has_errors></component>\n'}
    def writer(mapping):
        return 'from pathlib import Path\nroot=Path('+repr(str(mod.G))+')\nfor n,t in '+repr(mapping)+'.items():\n p=root/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(t)\n'
    actual=[];live_proof={}
    def preflight(_):
        if mode=='preflight_reject':raise AssertionError('INERT ADMISSION REJECT')
        return copy.deepcopy(m),copy.deepcopy(release)
    def popen(argv,**kw):
        assert argv[0]=='/usr/bin/cmake'
        target=argv[argv.index('--target')+1] if '--target' in argv else 'configure'
        code='raise SystemExit(0)'
        if target=='version':code='print("INERT 26.1.1 Build 130 SC Pro Edition")' if mode!='wrong_version' else 'print("INERT wrong version")'
        if target=='fabric_import':
            code=writer(import_outputs)+'print('+repr('FABRIC_INTERFACES='+' '.join(names))+')\nprint("PD_VALIDATE_OK")\n'
            if mode!='missing_marker':code+='print("PD_IMPORT_COMPLETE")\n'
        if target=='fabric_generate':
            code=writer(outputs)
            if mode=='nonzero':code+='raise SystemExit(7)\n'
            if mode=='native_error':code+='print("# 0: ERROR: INERT generated failure")\n'
            if mode=='copy_drift':code+='Path('+repr(str(mod.D/'core.sv'))+').write_text("DRIFT")\n'
            if mode=='release_drift':code+='Path('+repr(str(mod.REL/'hw/lib/fme-ifc-id.txt'))+').write_text("DRIFT")\n'
            if mode=='overflow':code+='print("x"*2048)\n'
            if mode=='drain_gate':code+='import os,time\npid=os.fork()\nif pid:os._exit(0)\ntime.sleep(0.4)\nprint("IA840F_GATE_REJECTED: INERT helper",flush=True)\ntime.sleep(8)\n'
        if mode=='postspawn_fault' and target=='configure':code='import os,time;from pathlib import Path;Path('+repr(str(root/'live.started'))+').write_text(str(os.getpid()));time.sleep(8)'
        real=[sys.executable,'-c',code];actual.append({'requested':argv,'actual':real});p=POPEN(real,**kw)
        if mode=='postspawn_fault' and target=='configure':
            try:
                until=time.monotonic()+2
                while not (root/'live.started').exists() and time.monotonic()<until:assert p.poll() is None;time.sleep(0.01)
                assert (root/'live.started').read_text()==str(p.pid) and p.poll() is None
                live_proof.update(pid=p.pid,alive_before_fault=True)
            except BaseException:os.killpg(p.pid,signal.SIGKILL);p.wait();raise
        return p
    orig_identity=mod.identity
    def identity(pid):
        if mode=='postspawn_fault' and pid!=os.getpid():raise RuntimeError('INERT post-spawn identity fault')
        return orig_identity(pid)
    orig_post=mod.postflight
    def post(*args):
        if mode=='postflight_fault':raise RuntimeError('INERT postflight failure')
        return orig_post(*args)
    def command(argv,**kw):assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0,b'',b'')
    before=snapshot(root)
    with patch.object(mod,'preflight',side_effect=preflight),patch.object(mod,'identity',side_effect=identity),patch.object(mod,'postflight',side_effect=post),patch.object(mod.subprocess,'Popen',side_effect=popen),patch.object(mod.subprocess,'run',side_effect=command),patch.object(sys,'argv',['INERT','f'*64]),contextlib.redirect_stdout(io.StringIO()):
        if mode=='preflight_reject':
            try:mod.run()
            except AssertionError:pass
            else:raise AssertionError('admission accepted')
            assert not actual and not mod.R.exists() and snapshot(root)==before
            ROWS.append({'case':name,'preflight_rejected_before_writes':True});return
        rc=mod.run();result=json.loads((mod.R/'status.json').read_text())
        assert result['execution_clean'] is expected_clean and (rc==0) is expected_clean,(name,result)
        assert all(not c.get('owned_group_live_after') for c in result['commands'])
        if mode in ('missing_interface','missing_marker','child_error','wrong_version'):assert all('fabric_generate' not in c['requested'] for c in actual)
        if live_proof:assert not mod.live_group(live_proof['pid']);live_proof['group_empty_on_return']=True
        if mode=='drain_gate':assert result['commands'][-1]['gate_rejected'] and not result['commands'][-1]['timeout'] and result['commands'][-1]['effective_rc']==125
        saved=snapshot(root);n=len(actual)
        try:mod.run()
        except FileExistsError:pass
        else:raise AssertionError('spent operation replayed')
        assert snapshot(root)==saved and len(actual)==n
    ROWS.append({'case':name,'expected_clean':expected_clean,'actual_runner_rc':rc,'execution_clean':result['execution_clean'],'commands':result['commands'],'diagnostics':result.get('diagnostics'),'error':result.get('error'),'postflight_errors':result.get('postflight_errors'),'postflight_exception':result.get('postflight_exception'),'live_fault_proof':live_proof,'replay_preserved_bytes':True,'actual_inert_commands':actual})


case('clean',True)
for mode in ('preflight_reject','wrong_version','missing_marker','missing_interface','child_error','nonzero','hls_drift','missing_output','copy_drift','release_drift','native_error','drain_gate','overflow','postspawn_fault','postflight_fault'):case(mode,False,mode)
result={'success':True,'fixture_only':True,'native_tools_executed':False,'scope':'actual fabric runner with mocked admission/CMake/tmux and tiny synthetic artifact maps; real inert Python children, not vendor integration','runner_sha256':digest(SOURCE),'count':len(ROWS),'cases':ROWS,'scratch':str(BASE)}
OUT.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'success':True,'cases':len(ROWS),'native_tools_executed':False,'output':str(OUT)},indent=2))
