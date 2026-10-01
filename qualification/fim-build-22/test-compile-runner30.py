"""Exercise the actual stage-runner entry with real inert child processes.

Resource/host admission and CMake execution are explicitly synthetic fixtures.
No Quartus, project generation, simulator or device utility is executed.
"""
import contextlib
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
OUT=E/'compile-runner-inert30.json'
assert not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='ia840f-runner06-',dir=os.environ['TMPDIR']))
SOURCE=E/'candidate02/run-compile30.py'
REAL_POPEN=subprocess.Popen
REAL_READ_TEXT=Path.read_text
RESULTS=[]


def files(root):
    return {str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest()
            for p in root.rglob('*') if p.is_file()}


def case(name, code, expected_clean, deadline=4.0, bookkeeping_failure=False, preflight_bad=False):
    root=BASE/name;root.mkdir()
    spec=importlib.util.spec_from_file_location('runner_fixture_'+name,SOURCE)
    assert spec is not None and spec.loader is not None
    module:Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    module.B=root;module.E=root/'evidence';module.W=root/'work';module.J=module.W/'syn/board/ia840f/syn_top';module.Q=root/'inert-quartus'
    module.J.mkdir(parents=True);(module.E/'candidate01').mkdir(parents=True);(module.E/'stage-inputs').mkdir()
    cpus=sorted(os.sched_getaffinity(0))
    qsf=module.J/'ofs_top.qsf';qsf.write_text('set_global_assignment -name NUM_PARALLEL_PROCESSORS '+str(len(cpus))+'\n')
    mutable=module.J/'fme_id.mif';mutable.write_text('inert initial ROM data\n')
    cmake=module.E/'candidate01/CMakeLists.txt';cmake.write_text('# Inert fixture; not executed by CMake.\n')
    manifest={'stage':'compile','work':str(module.W),'project':str(module.J),'parent_execution_accepted':True,
        'toolchain':'Quartus Prime Pro 26.1.1 Build 130','part':'AGFB027R25A2E2V','runner_sha256':module.sha(SOURCE),
        'critical_inputs':{str(qsf):module.sha(qsf)},'critical_links':{},'runtime_hashes':{},'cmake_sha256':module.sha(cmake),
        'prerequisites':{},'cpus':cpus,'contexts':[],
        'preflight_only_inputs':{str(mutable):module.sha(mutable)},'runtime_output_roles':{str(mutable):'synthetic generated FME ROM'}}
    mf=module.E/'stage-inputs/compile.json';mf.write_text(json.dumps(manifest))
    argv=['fixture-driver','compile',module.sha(mf)]
    module.DEADLINES['compile']=deadline
    actual=[]
    def popen(requested,**kw):
        assert requested[0]=='/usr/bin/cmake'
        child_code='raise SystemExit(0)' if '--build' not in requested else code
        real_argv=[sys.executable,'-c',child_code,str(root)]
        actual.append({'requested_cmake_argv':requested,'actual_inert_argv':real_argv})
        return REAL_POPEN(real_argv,**kw)
    real_identity=module.identity
    def identity(pid):
        if bookkeeping_failure and pid!=os.getpid():
            raise RuntimeError('inert injected post-spawn bookkeeping failure')
        return real_identity(pid)
    def read_text(path,*args,**kw):
        if str(path)=='/proc/meminfo':return 'MemAvailable: 130000000 kB\n'
        return REAL_READ_TEXT(path,*args,**kw)
    variables={'TMUX':'inert','TMUX_PANE':'inert','LM_LICENSE_FILE':'INERT','MGLS_LICENSE_FILE':'INERT','SALT_LICENSE_SERVER':'INERT'}
    with patch.dict(os.environ,variables),patch.object(sys,'argv',argv),\
         patch.object(module.socket,'gethostname',return_value='Agilex7Workstation'),\
         patch.object(module.os,'getuid',return_value=1000),\
         patch.object(module.subprocess,'check_output',return_value='ia840f_mailbox_monitored_01\n'),\
         patch.object(module.subprocess,'Popen',side_effect=popen),patch.object(module,'identity',side_effect=identity),\
         patch.object(Path,'read_text',read_text),\
         patch.object(module.shutil,'disk_usage',return_value=type('Disk',(),{'free':10**12})()),\
         contextlib.redirect_stdout(io.StringIO()):
        if preflight_bad:
            mutable.write_text('inert unapproved prelaunch change\n');before=files(root)
            try:module.run()
            except AssertionError:pass
            else:raise AssertionError('bad preflight input accepted')
            assert not actual and not (module.E/'operations').exists() and before==files(root)
            RESULTS.append({'case':name,'fixture_only':True,'preflight_rejected_before_children_and_writes':True})
            return
        rc=module.run()
        record=json.loads((module.E/'operations/compile/status.json').read_text())
        assert record['execution_clean'] is expected_clean,(name,record)
        if name == 'declared_output_update':
            assert record['runtime_output_changes'][str(mutable)]['changed'] is True
            assert record['runtime_output_changes'][str(mutable)]['after_sha256'] == module.sha(mutable)
        assert (rc==0) is expected_clean,(name,rc)
        before=files(root)
        try:module.run()
        except (AssertionError,FileExistsError):pass
        else:raise AssertionError('consumed operation re-ran')
        assert before==files(root),'rejected rerun changed evidence'
    assert (module.E/'native-operation.lock').exists() is (not expected_clean)
    for row in record['commands']:
        assert not row.get('owned_group_live_after',[]),(name,row)
    RESULTS.append({'case':name,'fixture_only':True,'actual_inert_children':actual,'runner_rc':rc,
                    'observed_clean':record['execution_clean'],'commands':record['commands'],
                    'diagnostics':record.get('diagnostics'),'error':record.get('error'),
                    'rejected_rerun_preserved_all_bytes':True})


case('preflight_drift','pass',False,preflight_bad=True)
case('declared_output_update',"from pathlib import Path; import sys; (Path(sys.argv[1])/'work/syn/board/ia840f/syn_top/fme_id.mif').write_text('inert updated ROM data')",True)
case('zero','print("inert child complete")',True)
case('nonzero','raise SystemExit(7)',False)
case('late_gate_marker','print("IA840F_GATE_REJECTED: inert late diagnostic")',False)
case('postspawn_exception','import time; time.sleep(2)',False,bookkeeping_failure=True)
case('finite_descendant','import os,time; p=os.fork(); time.sleep(0.5) if p==0 else None; os._exit(0)',True)
case('timeout_descendant','import os,time,signal; p=os.fork(); signal.signal(signal.SIGTERM,signal.SIG_IGN) if p==0 else None; time.sleep(8); os._exit(0)',False,deadline=0.4)
result={'success':True,'native_tool_execution':False,'fixture_only':True,'runner_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
        'scratch':str(BASE),'cases':RESULTS,'scope':'actual runner entry/supervisor with mocked admission and CMake substitution; not native integration'}
OUT.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'success':True,'cases':len(RESULTS),'native_tool_execution':False,'output':str(OUT)},indent=2))
