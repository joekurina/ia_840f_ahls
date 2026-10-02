"""Actual export-runner lifecycle with mocked admission/CMake, real inert children."""
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
import time
import signal
import datetime
from typing import Any
from unittest.mock import patch

E=Path(__file__).resolve().parent
assert len(sys.argv)==3
SOURCE=E/sys.argv[1]
OUT=E/sys.argv[2]
assert OUT.parent==E and not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='pr24-runner-inert-',dir=os.environ['TMPDIR']))
POPEN=subprocess.Popen
RUN=subprocess.run
ROWS=[]
FAILURES=[]


def files(root):
    return {str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file()}


def case(name,code,expected_clean,deadline=4.0,identity_fault=False,postflight_fault=False,preflight_fault=False,log_limit=1048576,bad_version=False,drain_signal=None):
    root=BASE/name;root.mkdir()
    spec=importlib.util.spec_from_file_location('export_fixture_'+name,SOURCE)
    assert spec is not None and spec.loader is not None
    module: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    module.B=root;module.ROOT=root;module.D=root/'base';module.P=root/'prepared';module.R=root/'operation';module.T=root/'release';module.W=root/'original';module.Q=root/'inert-tool';module.PROJECT=module.D/'syn/board/ia840f/syn_top'
    for p in (module.D,module.P,module.W,module.T,module.PROJECT):p.mkdir(parents=True,exist_ok=True)
    artifact_names=['syn/board/ia840f/syn_top/ofs_top.qdb','syn/board/ia840f/syn_top/output_files/ofs_top.sof','syn/board/ia840f/syn_top/output_files/ofs_top.static.msf','syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf']
    artifacts={}
    release_project=module.T/'hw/lib/build/quartus_proj_dir';release_project.mkdir(parents=True)
    for n in artifact_names:
        raw=('INERT ARTIFACT, NOT FPGA DATA: '+n+'\n').encode()
        for p in (module.D/n,module.W/n,release_project/Path(n).relative_to('syn/board/ia840f/syn_top')):
            p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(raw)
        artifacts[n]={'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw)}
    for n in ('bin/afu_synth','bin/update_pim','hw/blue_bits/ofs_top.sof'):
        p=module.T/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('INERT ONLY\n')
    (module.T/'hw/lib/build/platform/ofs_plat_if').mkdir(parents=True)
    uuid='00000000-0000-0000-0000-000000000000'
    (module.T/'hw/lib/fme-ifc-id.txt').write_text(uuid+'\n')
    cpus=sorted(os.sched_getaffinity(0))
    m={'part':'AGFB027R25A2E2V','toolchain':'Quartus Prime Pro 26.1.1 Build 130','pim':str(root/'pim'),'pim_inventory':{},'tools':{},'installed':{},'critical_inputs':{},'contexts':[], 'artifact_bindings':artifacts,'expected_interface_uuid':uuid,'candidate_bindings':{'ia840f_release_gate01.py':{'sha256':'a'*64}},'cpus':cpus,'address_space_limit_bytes':64*1024**3,'deadlines_seconds':{'configure':4.0,'version':4.0,'export':deadline},'log_limit_bytes':log_limit}
    stage={'original_inventory':module.inventory(module.W)}
    prepared=module.inventory(module.D)
    actual=[];buffers={};live_fault_proof={}
    def preflight(_expected):
        if preflight_fault:raise AssertionError('inert rejected admission')
        return copy.deepcopy(m),copy.deepcopy(stage),copy.deepcopy(prepared)
    def popen(argv,**kw):
        assert argv[0]=='/usr/bin/cmake'
        target=argv[argv.index('--target')+1] if '--target' in argv else 'configure'
        child='raise SystemExit(0)'
        if target=='version':child='print("INERT version fixture")' if bad_version else 'print("INERT fixture: 26.1.1 Build 130 SC Pro Edition")'
        if target=='export':child=code
        if identity_fault and target=='configure':
            child='import os,sys,time;from pathlib import Path;Path(sys.argv[1],"live-configure.started").write_text(str(os.getpid()));time.sleep(8)'
        real=[sys.executable,'-c',child,str(root)]
        actual.append({'requested_cmake':argv,'actual_inert':real})
        subject=POPEN(real,**kw)
        if identity_fault and target=='configure':
            try:
                end=time.monotonic()+2.0
                while not (root/'live-configure.started').exists() and time.monotonic()<end:
                    assert subject.poll() is None
                    time.sleep(0.01)
                assert (root/'live-configure.started').read_text()==str(subject.pid) and subject.poll() is None
                live_fault_proof.update(pid=subject.pid,started_marker=True,alive_before_identity_fault=True)
            except BaseException:
                os.killpg(subject.pid,signal.SIGKILL);subject.wait();raise
        return subject
    def command(argv,**kw):
        assert argv[0]=='tmux',argv
        buffers[tuple(argv)]=kw.get('input')
        return subprocess.CompletedProcess(argv,0,b'',b'')
    original_identity=module.identity
    def identity(pid):
        if identity_fault and pid!=os.getpid():raise RuntimeError('inert post-spawn identity fault')
        return original_identity(pid)
    original_postflight=module.postflight
    def postflight(*args):
        if postflight_fault:raise RuntimeError('inert postflight failure')
        return original_postflight(*args)
    before=files(root)
    with patch.object(module,'preflight',side_effect=preflight),patch.object(module,'identity',side_effect=identity),patch.object(module,'postflight',side_effect=postflight),patch.object(module.subprocess,'Popen',side_effect=popen),patch.object(module.subprocess,'run',side_effect=command),patch.object(sys,'argv',['inert-export','f'*64]),contextlib.redirect_stdout(io.StringIO()):
        if preflight_fault:
            try:module.run()
            except AssertionError:pass
            else:raise AssertionError('preflight fault accepted')
            assert not actual and not module.R.exists() and files(root)==before
            ROWS.append({'case':name,'preflight_rejected_before_writes_or_children':True});return
        rc=module.run();result=json.loads((module.R/'status.json').read_text())
        assert result['execution_clean'] is expected_clean and (rc==0) is expected_clean,(name,rc,result)
        for record in result['commands']:assert not record.get('owned_group_live_after'),(name,record)
        if identity_fault:
            assert live_fault_proof.get('alive_before_identity_fault') and not module.live_group(live_fault_proof['pid'])
            live_fault_proof['no_live_group_on_return']=True
        drain_check=None
        if drain_signal:
            rec=result['commands'][-1]
            elapsed=(datetime.datetime.fromisoformat(rec['ended'])-datetime.datetime.fromisoformat(rec['started'])).total_seconds()
            assert rec.get('descendants_observed_at_leader_exit'), 'fixture did not exercise residual draining'
            assert (root/'descendant-emitted').exists(), 'fixture signal never emitted'
            detected=rec.get('gate_rejected') is True if drain_signal=='gate' else rec.get('log_bound_exceeded') is True
            drain_check={'signal':drain_signal,'detected_during_supervision':detected,'not_deadline_only':rec.get('timeout') is False,'elapsed_seconds':elapsed,'prompt_bound_seconds':1.8,'effective_rc':rec.get('effective_rc')}
            if not (detected and rec.get('timeout') is False and elapsed<1.8 and rec.get('effective_rc')==125):
                FAILURES.append({'case':name,'gap':'descendant signal not promptly enforced','observed':drain_check})
        saved=files(root);started=len(actual)
        try:module.run()
        except FileExistsError:pass
        else:raise AssertionError('spent operation replayed')
        assert files(root)==saved and len(actual)==started
    ROWS.append({'case':name,'expected_clean':expected_clean,'actual_runner_rc':rc,'execution_clean':result['execution_clean'],'commands':result['commands'],'diagnostics':result.get('diagnostics'),'postflight_exception':result.get('postflight_exception'),'actual_inert_children':actual,'spent_replay_preserved_bytes':True,'live_fault_proof':live_fault_proof,'drain_check':drain_check})


case('preflight_rejection','pass',False,preflight_fault=True)
case('zero','print("INERT export complete")',True)
case('nonzero','raise SystemExit(7)',False)
case('late_gate_marker','print("Critical Warning (125091): INERT callback rejection")',False)
case('postspawn_exception','import time;time.sleep(2)',False,identity_fault=True)
case('finite_descendant','import os,time;p=os.fork();time.sleep(0.5) if p==0 else None;os._exit(0)',True)
case('timeout_descendant','import os,time,signal;p=os.fork();signal.signal(signal.SIGTERM,signal.SIG_IGN) if p==0 else None;time.sleep(8);os._exit(0)',False,deadline=0.4)
case('postflight_exception','print("INERT export complete")',False,postflight_fault=True)
case('short_lived_log_overflow','print("x"*2048)',False,log_limit=512)
case('wrong_version','print("must not run export")',False,bad_version=True)
def descendant(signal_text,linger):
    return ('import os,sys,time;from pathlib import Path\n'
            'root=Path(sys.argv[1]);pid=os.fork()\n'
            'if pid: os._exit(0)\n'
            'time.sleep(0.45)\n'
            '(root/"descendant-emitted").write_text(str(os.getpid()))\n'
            + 'print('+repr(signal_text)+',flush=True)\n'
            + 'time.sleep('+repr(linger)+')\n'
            + 'os._exit(0)\n')

case('drain_gate_writer',descendant('IA840F_GATE_REJECTED: INERT descendant',8),False,deadline=2.4,drain_signal='gate')
case('drain_log_writer',descendant('x'*2048,8),False,deadline=2.4,log_limit=512,drain_signal='log')
case('drain_short_lived_gate',descendant('Critical Warning (125091): INERT descendant',0.02),False,deadline=2.4,drain_signal='gate')
result={'success':not FAILURES,'failures':FAILURES,'fixture_only':True,'native_tools_executed':False,'scope':'actual runner entry/supervisor/postflight with synthetic artifact/admission data, CMake substituted by real inert Python children, tmux export mocked; not native integration','runner_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'count':len(ROWS),'cases':ROWS,'scratch':str(BASE)}
OUT.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'success':not FAILURES,'cases':len(ROWS),'failed_cases':[x['case'] for x in FAILURES],'native_tools_executed':False,'output':str(OUT)},indent=2))
raise SystemExit(1 if FAILURES else 0)
