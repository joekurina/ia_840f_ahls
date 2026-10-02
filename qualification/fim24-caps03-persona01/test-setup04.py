"""Exercise setup control/result checks with real inert children only."""
import contextlib
import copy
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from typing import Any
from unittest.mock import patch

E=Path(__file__).resolve().parent
SOURCE=E/'candidate03/run-setup03.py'
OUT=E/'setup-inert04.json'
assert not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='matching-setup-inert-',dir=os.environ['TMPDIR']))
POPEN=subprocess.Popen
ROWS=[]


def put(p,t):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(t)


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def snap(root):return {str(p.relative_to(root)):sha(p) for p in root.rglob('*') if p.is_file()}


def case(mode,expected_clean):
    root=BASE/mode;root.mkdir();spec=importlib.util.spec_from_file_location('setup_fixture_'+mode,SOURCE)
    assert spec is not None and spec.loader is not None
    mod: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
    mod.B=root;mod.ROOT=root;mod.A=root/'inputs';mod.P=root/'control';mod.R=root/'setup';mod.T=mod.R/'persona';mod.REL=root/'release';mod.G=root/'fabric';mod.Q=root/'fake-quartus'
    for p in (mod.A,mod.P,mod.REL,mod.G):p.mkdir()
    afuuid='00000000-0000-0000-0000-000000000000';ifcid='11111111-1111-1111-1111-111111111111'
    afu_json={'version':1,'afu-image':{'accelerator-clusters':[{'accelerator-type-uuid':afuuid}]}}
    put(mod.A/'afu/a.sv','INERT AFU\n');put(mod.A/'generated/top.qip','# INERT QIP\n');put(mod.A/'ia840f_ahls_memory.json',json.dumps(afu_json));put(mod.A/'sources.txt','INERT SOURCES\n')
    put(mod.P/'runtime/CMakeLists.txt','# INERT CMAKE\n');put(mod.G/'dummy.v','INERT GENERATED\n')
    qdb='hw/lib/build/syn/board/ia840f/syn_top/ofs_top.qdb';put(mod.REL/qdb,'INERT STATIC, NOT FPGA DATA\n');put(mod.REL/'hw/lib/fme-ifc-id.txt',ifcid+'\n')
    def inv(directory):return {str(p.relative_to(directory)):{'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)} for p in directory.rglob('*') if p.is_file()}
    staged=inv(mod.A);release=inv(mod.REL);fabric=inv(mod.G)
    m={'staged_inventory':staged,'setup_tools':{},'runtime_tools':{},'prerequisites':{},'runner_sha256':sha(SOURCE),'cmake_sha256':sha(mod.P/'runtime/CMakeLists.txt'),'afu_uuid':afuuid,'interface_uuid':ifcid,'afu_json':afu_json,'afu_source_order':['afu/a.sv'],'generated_qip_order':['generated/top.qip'],'platform_family':'AGILEX','cpus':sorted(os.sched_getaffinity(0)),'address_space_limit_bytes':64*1024**3,'log_limit_bytes':512 if mode=='overflow' else 1048576,'deadlines_seconds':{'configure':4.0,'version':4.0,'setup':4.0}}
    qsf='set_global_assignment -name SYSTEMVERILOG_FILE "'+str(mod.A/'afu/a.sv')+'"\nset_global_assignment -name QIP_FILE "'+str(mod.A/'generated/top.qip')+'"\n'
    if mode=='wrong_selection':qsf=qsf.replace('afu/a.sv','afu/wrong.sv')
    hdr="`define AFU_ACCEL_UUID 128'h"+afuuid.replace('-','_')+'\n'
    if mode=='wrong_uuid':hdr='INERT WRONG UUID\n'
    outputs={'hw/afu.qsf':qsf,'hw/afu_json_info.vh':hdr,'hw/ia840f_ahls_memory.json':json.dumps(afu_json),'build/platform/platform_afu_top_config.vh':'INERT PLATFORM\n','build/platform/platform_if_addenda.qsf':'INERT ADDENDA\n','build/syn/board/ia840f/syn_top/ofs_top.qdb':'INERT STATIC, NOT FPGA DATA\n'}
    if mode=='missing_header':outputs.pop('build/platform/platform_afu_top_config.vh')
    if mode=='bad_qdb':outputs['build/syn/board/ia840f/syn_top/ofs_top.qdb']='INERT DRIFT\n'
    actual=[]
    def preflight(_):
        if mode=='unissued':raise AssertionError('INERT admission rejected')
        return copy.deepcopy(m),copy.deepcopy(release),copy.deepcopy(fabric)
    def popen(argv,**kw):
        assert argv[0]=='/usr/bin/cmake';target=argv[argv.index('--target')+1] if '--target' in argv else 'configure';code='raise SystemExit(0)'
        if target=='version':code='print("INERT 26.1.1 Build 130 SC Pro Edition")'
        if target=='persona_setup':
            code='from pathlib import Path\nroot=Path('+repr(str(mod.T))+')\nfor name,text in '+repr(outputs)+'.items():\n p=root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)\n'
            if mode=='nonzero':code+='raise SystemExit(7)\n'
            if mode=='diagnostic':code+='print("Error: INERT setup failure")\n'
            if mode=='input_drift':code+='Path('+repr(str(mod.A/'afu/a.sv'))+').write_text("DRIFT")\n'
            if mode=='release_drift':code+='Path('+repr(str(mod.REL/qdb))+').write_text("DRIFT")\n'
            if mode=='overflow':code+='print("x"*2048)\n'
            if mode=='drain_gate':code+='import os,time\npid=os.fork()\nif pid:os._exit(0)\ntime.sleep(0.4)\nprint("IA840F_GATE_REJECTED: INERT setup helper",flush=True)\ntime.sleep(8)\n'
        actual.append({'requested':argv,'actual':[sys.executable,'-c',code]});return POPEN([sys.executable,'-c',code],**kw)
    def command(argv,**kw):assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0,b'',b'')
    orig_post=mod.postflight
    def post(*a):
        if mode=='postflight_exception':raise RuntimeError('INERT postflight fault')
        return orig_post(*a)
    original=snap(root)
    with patch.object(mod,'preflight',side_effect=preflight),patch.object(mod,'postflight',side_effect=post),patch.object(mod.subprocess,'Popen',side_effect=popen),patch.object(mod.subprocess,'run',side_effect=command),patch.object(sys,'argv',['INERT','f'*64]),patch.dict(os.environ,{'LM_LICENSE_FILE':'INERT','MGLS_LICENSE_FILE':'INERT','SALT_LICENSE_SERVER':'INERT'}),contextlib.redirect_stdout(io.StringIO()):
        if mode=='unissued':
            try:mod.run()
            except AssertionError:pass
            else:raise AssertionError('unissued accepted')
            assert not actual and not mod.R.exists() and snap(root)==original;ROWS.append({'case':mode,'rejected_before_writes':True});return
        rc=mod.run();result=json.loads((mod.R/'status.json').read_text());assert result['execution_clean'] is expected_clean and (rc==0) is expected_clean,(mode,result)
        assert all(not c.get('owned_group_live_after') for c in result['commands'])
        if mode=='drain_gate':assert result['commands'][-1]['gate_rejected'] and not result['commands'][-1]['timeout']
        saved=snap(root);n=len(actual)
        try:mod.run()
        except FileExistsError:pass
        else:raise AssertionError('spent replay accepted')
        assert snap(root)==saved and len(actual)==n
    ROWS.append({'case':mode,'expected_clean':expected_clean,'actual_rc':rc,'execution_clean':result['execution_clean'],'commands':result['commands'],'diagnostics':result.get('diagnostics'),'postflight_errors':result.get('postflight_errors'),'postflight_exception':result.get('postflight_exception'),'actual_inert_commands':actual,'replay_preserved':True})


case('clean',True)
for mode in ('unissued','nonzero','wrong_uuid','wrong_selection','missing_header','bad_qdb','diagnostic','input_drift','release_drift','overflow','drain_gate','postflight_exception'):case(mode,False)
result={'success':True,'fixture_only':True,'native_tools_executed':False,'scope':'actual setup runner; mocked admission/CMake/tmux/tinyartifactmaps and literal INERT environment values; real inert Python children—not real license settings or vendor results','runner_sha256':sha(SOURCE),'count':len(ROWS),'cases':ROWS,'scratch':str(BASE)}
OUT.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'success':True,'cases':len(ROWS),'native_tools_executed':False,'output':str(OUT)},indent=2))
