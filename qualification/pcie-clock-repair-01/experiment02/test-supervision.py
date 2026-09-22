#!/usr/bin/env python3
"""Real INERT Python process regressions; mocked gate/host/resources/tmux only.

Exercises actual main/main_supervised control flow. No vendor executable,
remote connection, authorization issuance, hardware or system resource change.
"""
from pathlib import Path
import ast,base64,contextlib,gzip,hashlib,io,json,os,runpy,signal,subprocess,sys,tempfile,time,types
from unittest.mock import patch
ROOT=Path(__file__).resolve().parent


def live_group(pgid):
    out=[]
    for p in Path('/proc').glob('[0-9]*/stat'):
        try:
            v=p.read_text().rsplit(')',1)[1].split()
            if int(v[2])==pgid and v[0]!='Z':out.append(int(p.parent.name))
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    return out


def until_file(p):
    deadline=time.monotonic()+4
    while not p.exists():
        if time.monotonic()>deadline:raise RuntimeError('inert startup handshake failed')
        time.sleep(0.01)


def trial(scratch, phase, case, legacy=False):
    parent=ROOT.parent/'experiment01' if legacy else ROOT
    suffix='01' if legacy else '02'
    module='ia840f_clock_'+phase+suffix+'_gate'
    fake=types.ModuleType(module);fake.validate=lambda **k:None;fake.identity=lambda p:None
    source=parent/phase/'run-query.py'
    with patch.dict(sys.modules,{module:fake}):namespace=runpy.run_path(str(source))
    fn=namespace['main' if legacy else 'main_supervised'];g=fn.__globals__
    E=scratch/(('old-' if legacy else 'new-')+phase+'-'+case);E.mkdir()
    g['E']=E
    sources=[]
    for i in range(3):
        p=E/('donor'+str(i));p.mkdir();(p/'original').write_text('unchanged');sources.append(p)
    preserved={str(p):g['inventory'](p) for p in sources}
    (E/'preservation.json.gz').write_bytes(gzip.compress(json.dumps(preserved).encode()))
    identity={'exe':'INERT','argv':['INERT'],'cwd':str(E),'pid':os.getpid()}
    g['identity']=lambda pid:identity
    reports=E/'reports';ready=E/'ready';desc=E/'descendant-pid'
    report_init="from pathlib import Path;import os,signal,time,sys;E=Path("+repr(str(E))+");(E/'reports').mkdir();(E/'reports'/'timing.rpt').write_text('INERT ONLY');print('IA840F_CONSTRAINT_COMPARE_COMPLETE "+E.name+"',flush=True);\n"
    # main checks E.name, not our mock phase labels. No result is a native result.
    code=report_init
    has_desc=case in ('metadata-failure','leader-zero-descendant','leader-seven-descendant','wall-descendant')
    if has_desc:
        code+="p=os.fork()\nif p==0:\n signal.signal(signal.SIGTERM,signal.SIG_IGN)\n (E/'descendant-pid').write_text(str(os.getpid()))\n while True:\n  with (E/'heartbeat').open('a') as f:f.write('x')\n  time.sleep(0.02)\nelse:\n while not (E/'descendant-pid').exists():time.sleep(0.01)\n (E/'ready').write_text('ready')\n"
        if case=='leader-zero-descendant':code+=' sys.exit(0)\n'
        elif case=='leader-seven-descendant':code+=' sys.exit(7)\n'
        else:code+=' time.sleep(30)\n'
    else:
        code+="(E/'ready').write_text('ready')\n"
        if case in ('wall','output-cap','wait-failure'):code+='time.sleep(30)\n'
        elif case=='nonzero':code+='sys.exit(7)\n'
    record={'argv':[sys.executable,'-B','-c',code],'cwd':str(E),'runner':identity}
    g['validate']=lambda **k:record
    real_popen=subprocess.Popen;real_dump=json.dump;real_read=Path.read_text
    children=[];fds=[];exports=[];spawn_count=0
    def popen(*args,**kwargs):
        nonlocal spawn_count
        assert args[0]==record['argv'] and kwargs['start_new_session'] is True
        child=real_popen(*args,**kwargs);children.append(child);spawn_count+=1
        fds.append(os.pidfd_open(child.pid))
        until_file(ready)
        if has_desc:
            until_file(desc);fds.append(os.pidfd_open(int(desc.read_text())))
        return child
    def dump(value,out,*args,**kwargs):
        if case=='metadata-failure' and getattr(out,'name',None)==str(E/'native-process.json'):
            raise OSError('inert post-spawn metadata write failure')
        return real_dump(value,out,*args,**kwargs)
    def read(path,*args,**kwargs):
        if str(path)=='/proc/meminfo':return 'MemAvailable: 120000000 kB\n'
        return real_read(path,*args,**kwargs)
    def output(args,**kwargs):
        if args[0]=='tmux':return 'ia840f_mailbox_monitored_01\n'
        if args==['ps','-eo','comm=']:return 'INERT_FIXTURE_ONLY\n'
        raise AssertionError('unexpected subprocess '+repr(args))
    def export(args,**kwargs):
        assert args[:2]==['tmux','load-buffer'];exports.append(kwargs['input'])
        return types.SimpleNamespace(returncode=0)
    if not legacy:
        supervise=g['supervise_native'];peek=g['peek_owned_exit'];group=g['live_group']
        def bounded(*args,**kwargs):
            kwargs['wall_seconds']=0.1 if case.startswith('wall') else 10
            kwargs['bytes_limit']=1 if case=='output-cap' else 1024**2
            return supervise(*args,**kwargs)
        g['supervise_native']=bounded
        n=[0]
        if case=='wait-failure':
            def failed_peek(child):
                n[0]+=1
                if n[0]==1:raise OSError('inert wait observation failure')
                return peek(child)
            g['peek_owned_exit']=failed_peek
        if case in ('inspection-failure','inspection-unconfirmed'):
            def failed_group(pgid):
                n[0]+=1
                if n[0]==1 or case=='inspection-unconfirmed':raise OSError('inert group observation failure')
                return group(pgid)
            g['live_group']=failed_group
    result={'phase':phase,'case':case,'legacy':legacy};buffer=io.StringIO()
    try:
        with contextlib.ExitStack() as stack:
            for ctx in (patch.object(g['socket'],'gethostname',return_value='Agilex7Workstation'),
                        patch.object(os,'getuid',return_value=1000),patch.dict(os.environ,{'TMUX':'INERT','TMUX_PANE':'INERT'}),
                        patch.object(subprocess,'check_output',side_effect=output),patch.object(subprocess,'run',side_effect=export),
                        patch.object(subprocess,'Popen',side_effect=popen),patch.object(g['resource'],'setrlimit'),patch.object(os,'nice'),
                        patch.object(Path,'read_text',read),patch.object(json,'dump',side_effect=dump),contextlib.redirect_stdout(buffer)):
                stack.enter_context(ctx)
            try:rc=fn();result['returncode']=rc
            except Exception as exc:result['exception']=repr(exc)
            assert len(children)==1
            result['live_at_return']=live_group(children[0].pid)
            if not legacy:
                assert not result['live_at_return'],result
                status=json.loads((E/'native-result.json').read_text())
                execution=json.loads((E/'execution-status.json').read_text())
                result.update(native_rc=status['native_rc'],effective_rc=execution['effective_rc'],abort_reason=status['abort_reason'],termination_confirmed=status['termination_confirmed'])
                if case=='success':assert rc==status['native_rc']==0 and status['abort_reason'] is None and status['termination_confirmed'] is True
                elif case=='nonzero':assert rc==status['native_rc']==7 and status['abort_reason'] is None and status['termination_confirmed'] is True
                else:
                    assert rc!=0 and execution['effective_rc']!=0 and status['abort_reason']
                    assert status['termination_confirmed'] is (case!='inspection-unconfirmed')
                if case=='leader-zero-descendant':assert status['native_rc']==0
                if case=='leader-seven-descendant':assert status['native_rc']==7
                assert execution['timing_accepted'] is False
                assert len(exports)==1
                a=json.loads(gzip.decompress(exports[0]))
                for name,v in a['files'].items():
                    b=(E/name).read_bytes();assert b==base64.b64decode(v['base64']) and len(b)==v['bytes'] and hashlib.sha256(b).hexdigest()==v['sha256']
                assert json.loads((E/'preservation-after.json').read_text())=={str(p):True for p in sources}
                if (E/'heartbeat').exists():
                    before=(E/'heartbeat').read_bytes();time.sleep(0.1);assert before==(E/'heartbeat').read_bytes()
                before={str(p.relative_to(E)):hashlib.sha256(p.read_bytes()).hexdigest() for p in E.rglob('*') if p.is_file()}
                try:fn();raise AssertionError('spent rerun allowed')
                except RuntimeError as exc:assert 'spent artifact' in str(exc)
                after={str(p.relative_to(E)):hashlib.sha256(p.read_bytes()).hexdigest() for p in E.rglob('*') if p.is_file()}
                assert before==after and spawn_count==1
                result['spent_rerun_unchanged']=True
            else:
                assert result['live_at_return'],result
                if case=='metadata-failure':assert 'inert post-spawn metadata' in result.get('exception','')
                else:assert result['returncode']==0
                result['predecessor_defect_reproduced']=True
            result['pass']=True
    finally:
        # Fixture cleanup uses PIDFD identity, never a potentially reused PGID.
        for fd in fds:
            try:signal.pidfd_send_signal(fd,signal.SIGKILL)
            except ProcessLookupError:pass
            finally:os.close(fd)
        for child in children:child.wait(timeout=3)
        deadline=time.monotonic()+3
        for child in children:
            while live_group(child.pid) and time.monotonic()<deadline:time.sleep(0.02)
            assert not live_group(child.pid),'fixture cleanup left live child'
    return result


def main():
    if sys.flags.optimize:raise RuntimeError('optimized checks forbidden')
    rows=[]
    with tempfile.TemporaryDirectory(prefix='ia840f-supervision-',dir='/home/joe/.hermes/cache/scratch') as tmp:
        scratch=Path(tmp)
        for phase in ('baseline','candidate'):
            for case in ('metadata-failure','leader-zero-descendant'):
                rows.append(trial(scratch,phase,case,legacy=True))
            for case in ('success','nonzero','metadata-failure','leader-zero-descendant','leader-seven-descendant','wall','wall-descendant','output-cap','wait-failure','inspection-failure','inspection-unconfirmed'):
                rows.append(trial(scratch,phase,case))
            path=ROOT/phase/'run-query.py';tree=ast.parse(path.read_text(),feature_version=(3,9))
            entry=tree.body[-1];assert isinstance(entry,ast.If)
            called=[n.func.id for n in ast.walk(entry) if isinstance(n,ast.Call) and isinstance(n.func,ast.Name)]
            assert 'main_supervised' in called and 'main' not in called
    print(json.dumps({'scope':'INERT actual runner entry/control flow; mocked host/gate/resources/tmux; no vendor/hardware/authorization',
                      'count':len(rows),'tests':rows,'runner_sha256':{p:hashlib.sha256((ROOT/p/'run-query.py').read_bytes()).hexdigest() for p in ('baseline','candidate')}},indent=2))
if __name__=='__main__':main()
