#!/usr/bin/env python3
"""Persistent, single-use ordinary-file STA query; no FPGA operations."""
from pathlib import Path
import signal,time,re
import base64, datetime, gzip, hashlib, json, os, resource, socket, subprocess, sys
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03')
sys.dont_write_bytecode=True
sys.path.insert(0,str(E/'scratch/ofs-common/tools/ofss_config'))
from ia840f_clock_fanout03_gate import validate,identity

def inventory(root):
    answer={}
    for folder,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(folder)/name;rel=str(p.relative_to(root))
            if p.is_symlink():answer[rel]={'link':os.readlink(p)}
            elif p.is_file():
                h=hashlib.sha256()
                with p.open('rb') as f:
                    for block in iter(lambda:f.read(4194304),b''):h.update(block)
                answer[rel]={'sha256':h.hexdigest()}
    return answer

def live_group(pgid):
    live=[]
    for path in Path('/proc').glob('[0-9]*/stat'):
        try:
            fields=path.read_text().rsplit(')',1)[1].split()
            if int(fields[2])==pgid and fields[0]!='Z':live.append(int(path.parent.name))
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    return live

def wait_bounded(child, reports, wall_seconds=1800, bytes_limit=1024**3):
    start=time.monotonic(); reason=None
    while True:
        try:return child.wait(timeout=2),reason
        except subprocess.TimeoutExpired:pass
        try:
            size=sum(p.stat().st_size for p in reports.rglob('*') if p.is_file()) if reports.exists() else 0
            if time.monotonic()-start>=wall_seconds:reason='wall-time cap'
            elif size>bytes_limit:reason='report-total cap'
        except Exception as exc:reason='report accounting failed: '+repr(exc)
        if reason:
            # Keep leader unreaped until both group signals reserve PGID identity.
            for sig,delay in ((signal.SIGTERM,2),(signal.SIGKILL,0)):
                try:os.killpg(child.pid,sig)
                except ProcessLookupError:pass
                if delay:time.sleep(delay)
            deadline=time.monotonic()+5
            remaining=live_group(child.pid)
            while remaining and time.monotonic()<deadline:
                time.sleep(0.05);remaining=live_group(child.pid)
            if remaining:reason+='; OWNED_GROUP_TERMINATION_UNCONFIRMED '+repr(remaining)
            # No following phase is eligible if termination or the cap failed.
            return child.wait(timeout=1),reason

def main():
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:
        raise RuntimeError('wrong host/user/tmux/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':
        raise RuntimeError('wrong owned session')
    r=validate(runtime=False)
    claim=identity(os.getpid())
    if any(claim[k]!=r['runner'][k] for k in ('exe','argv','cwd')):raise ValueError('runner context')
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024 < 80000000000:raise RuntimeError('insufficient RAM headroom')
    if any(x.strip().startswith(('quartus_','qsys-')) for x in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('competing native tool')
    for name in ('query.claim','query.log','native-process.json','native-result.json','execution-status.json','preservation-after.json','reports'):
        if (E/name).exists() or (E/name).is_symlink():raise RuntimeError('spent artifact '+name)
    with (E/'query.claim').open('x') as f:json.dump(claim,f)
    env={k:v for k,v in os.environ.items() if k not in ('PYTHONOPTIMIZE','PYTHONPATH','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL_PRINTED') and not k.startswith('OFS_')}
    env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',PYTHONDONTWRITEBYTECODE='1',OFS_ROOTDIR=str(E/'scratch'),OFS_PLATFORM_AFU_BBB=str(E/'pim'))
    for key in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'):env[key]='/home/uwb_student00/quartus_26/LR-191011_License.dat'
    resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3))
    resource.setrlimit(resource.RLIMIT_FSIZE,(128*1024**2,128*1024**2))
    os.nice(10)
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    with (E/'query.log').open('x') as f:
        child=subprocess.Popen(r['argv'],cwd=r['cwd'],env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
        with (E/'native-process.json').open('x') as out:json.dump({'pid':child.pid,'start':start,'argv':r['argv'],'cwd':r['cwd']},out)
        rc,abort=wait_bounded(child,E/'reports')
    status={'native_rc':rc,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'abort_reason':abort,'acceptance':'PENDING LOG AND INDEPENDENT REVIEW','hardware_access':False}
    with (E/'native-result.json').open('x') as f:json.dump(status,f,indent=2)
    effective=(124 if abort else (rc if rc>=0 else 128-rc));errors=[];post={}
    try:
        baseline=json.loads(gzip.decompress((E/'preservation.json.gz').read_bytes()))
        for root,expected in baseline.items():
            try:post[root]=inventory(Path(root))==expected
            except Exception as exc:post[root]=False;errors.append('preservation '+root+': '+repr(exc))
        if len(post)!=3 or not all(v is True for v in post.values()):errors.append('original preservation failed')
    except Exception as exc:errors.append('preservation receipt: '+repr(exc))
    with (E/'preservation-after.json').open('x') as f:json.dump(post,f,indent=2)
    report_files=[]
    try:
        text=(E/'query.log').read_text()
        if text.count('IA840F_FANOUT_CONTRAST_COMPLETE')!=1:errors.append('missing/duplicate completion marker')
        if re.search(r'Error \(|Fatal|125091|_REJECT|Traceback',text):errors.append('native/query/gate diagnostic')
        report_files=sorted(p for p in (E/'reports').rglob('*') if p.is_file())
        if not report_files or len(report_files)>1024:errors.append('report file cardinality/cap')
        if sum(p.stat().st_size for p in report_files)>1024**3:errors.append('report-total cap at completion')
        report_manifest={str(p.relative_to(E)):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in report_files}
        with (E/'report-manifest.json').open('x') as f:json.dump(report_manifest,f,indent=2)
    except Exception as exc:errors.append('report capture: '+repr(exc))
    if errors and effective==0:effective=1
    with (E/'execution-status.json').open('x') as f:json.dump({'effective_rc':effective,'errors':errors,'native_rc':rc,'abort_reason':abort,'timing_accepted':False},f,indent=2)
    exports={}
    names=['query.log','native-result.json','query.claim','native-process.json','preservation-after.json','execution-status.json','report-manifest.json']+[str(p.relative_to(E)) for p in report_files]
    for name in names:
        p=E/name
        if not p.is_file():continue
        data=p.read_bytes();exports[name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps({'batch':'ia840f_clock_fanout03_result01','files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b','ia840f_clock_fanout03_result01','-'],input=blob,check=True)
    print('FANOUT_CONTRAST_RESULT',effective,'NATIVE_RC',rc,'EXPORT_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
    return effective
# Added successor02 functions; predecessor functions remain unmodified.
def peek_owned_exit(child):
    """Observe the direct child without reaping its PGID-reserving leader."""
    if child.returncode is not None:
        raise RuntimeError('leader already reaped; refusing group signaling')
    return os.waitid(os.P_PID, child.pid, os.WEXITED | os.WNOHANG | os.WNOWAIT)


def observed_returncode(info):
    if info is None:
        return None
    if info.si_code == os.CLD_EXITED:
        return info.si_status
    if info.si_code in (os.CLD_KILLED, os.CLD_DUMPED):
        return -info.si_status
    raise RuntimeError('unexpected waitid exit code '+repr(info))


def supervise_native(r, env, log, reports, process_path, start,
                     wall_seconds=1800, bytes_limit=1024**3):
    """Own spawn through group drain, including bookkeeping/wait exceptions.

    Ordinary Linux process-group supervision, not OS containment. No wait/poll
    reaps the leader until all possible group signals and drain checks finish.
    """
    for name in ('waitid', 'P_PID', 'WEXITED', 'WNOHANG', 'WNOWAIT'):
        if not hasattr(os, name):
            raise RuntimeError('required non-reaping wait API unavailable: '+name)
    if signal.getsignal(signal.SIGCHLD) != signal.SIG_DFL:
        raise RuntimeError('SIGCHLD must preserve waitable child status')
    result={'native_rc':None, 'abort_reason':None, 'termination_confirmed':False,
            'supervision_errors':[], 'final_live_pids':None, 'native_started':False}
    errors=result['supervision_errors']
    # Reserve the receipt before launch. Never overwrite a previous attempt.
    with process_path.open('x') as metadata:
        began=time.monotonic()
        child=subprocess.Popen(r['argv'], cwd=r['cwd'], env=env, stdout=log,
                               stderr=subprocess.STDOUT, start_new_session=True)
        try:
            # This whole region is protected immediately after successful spawn.
            result['native_started']=True
            json.dump({'pid':child.pid, 'start':start, 'argv':r['argv'], 'cwd':r['cwd']},metadata)
            metadata.flush()
            metadata.close()
            while True:
                exited=peek_owned_exit(child)
                if exited is not None:
                    result['native_rc']=observed_returncode(exited)
                    if live_group(child.pid):
                        result['abort_reason']='leader exited with live owned descendants'
                    break
                if time.monotonic()-began >= wall_seconds:
                    result['abort_reason']='wall-time cap'
                    break
                size=sum(p.stat().st_size for p in reports.rglob('*') if p.is_file()) if reports.exists() else 0
                if size > bytes_limit:
                    result['abort_reason']='report-total cap'
                    break
                time.sleep(0.05)
        except BaseException as exc:
            result['abort_reason']='native supervision exception: '+repr(exc)
            errors.append(repr(exc))
        finally:
            # All paths resolve group state before the caller can run postflight.
            need_stop=bool(result['abort_reason'])
            try:
                exited=peek_owned_exit(child)
                remaining=live_group(child.pid)
                if exited is None or remaining:
                    need_stop=True
                    if result['abort_reason'] is None:
                        result['abort_reason']='owned group not quiescent at completion'
            except BaseException as exc:
                need_stop=True
                errors.append('initial drain inspection: '+repr(exc))
                result['abort_reason']=result['abort_reason'] or 'owned group inspection failed'
            if need_stop:
                for sig,delay in ((signal.SIGTERM,2),(signal.SIGKILL,0)):
                    try:
                        # ECHILD or a reaped leader rejects signaling, not identity.
                        peek_owned_exit(child)
                        os.killpg(child.pid,sig)
                    except ProcessLookupError:
                        pass
                    except BaseException as exc:
                        errors.append('group signal '+str(sig)+': '+repr(exc))
                    if delay:
                        try:time.sleep(delay)
                        except BaseException as exc:errors.append('signal grace: '+repr(exc))
            try:
                deadline=time.monotonic()+5
                empty_samples=0
                while True:
                    exited=peek_owned_exit(child)
                    remaining=live_group(child.pid)
                    result['final_live_pids']=remaining
                    if exited is not None:
                        result['native_rc']=observed_returncode(exited)
                    if exited is not None and not remaining:
                        empty_samples+=1
                        if empty_samples==2:
                            result['termination_confirmed']=True
                            break
                    else:
                        empty_samples=0
                    if time.monotonic()>=deadline:
                        break
                    time.sleep(0.05)
            except BaseException as exc:
                errors.append('final drain inspection: '+repr(exc))
            if not result['termination_confirmed']:
                result['abort_reason']=(result['abort_reason'] or 'native completion failure')+'; OWNED_GROUP_TERMINATION_UNCONFIRMED'
            # There can be no further killpg after this point, even on exception.
            try:
                exited=peek_owned_exit(child)
                if exited is not None:
                    result['native_rc']=observed_returncode(exited)
                    reaped=child.wait(timeout=1)
                    if reaped!=result['native_rc']:
                        raise RuntimeError('observed/reaped leader status mismatch')
            except BaseException as exc:
                errors.append('leader reap: '+repr(exc))
                result['termination_confirmed']=False
                result['abort_reason']=(result['abort_reason'] or 'native completion failure')+'; LEADER_REAP_UNCONFIRMED'
            if errors and result['abort_reason'] is None:
                result['abort_reason']='native supervision errors'
            try:
                print('CONSTRAINT_SUPERVISION',json.dumps(result,sort_keys=True),file=log,flush=True)
            except BaseException as exc:
                errors.append('supervision log: '+repr(exc))
                result['abort_reason']=result['abort_reason'] or 'supervision log failed'
                try:print('CONSTRAINT_SUPERVISION_LOG_FAILED',repr(result),file=sys.stderr,flush=True)
                except BaseException:pass
    return result


def main_supervised():
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:
        raise RuntimeError('wrong host/user/tmux/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':
        raise RuntimeError('wrong owned session')
    r=validate(runtime=False)
    claim=identity(os.getpid())
    if any(claim[k]!=r['runner'][k] for k in ('exe','argv','cwd')):raise ValueError('runner context')
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024 < 80000000000:raise RuntimeError('insufficient RAM headroom')
    if any(x.strip().startswith(('quartus_','qsys-')) for x in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('competing native tool')
    for name in ('query.claim','query.log','native-process.json','native-result.json','execution-status.json','preservation-after.json','reports'):
        if (E/name).exists() or (E/name).is_symlink():raise RuntimeError('spent artifact '+name)
    with (E/'query.claim').open('x') as f:json.dump(claim,f)
    env={k:v for k,v in os.environ.items() if k not in ('PYTHONOPTIMIZE','PYTHONPATH','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL_PRINTED') and not k.startswith('OFS_')}
    env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',PYTHONDONTWRITEBYTECODE='1',OFS_ROOTDIR=str(E/'scratch'),OFS_PLATFORM_AFU_BBB=str(E/'pim'))
    for key in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'):env[key]='/home/uwb_student00/quartus_26/LR-191011_License.dat'
    resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3))
    resource.setrlimit(resource.RLIMIT_FSIZE,(128*1024**2,128*1024**2))
    os.nice(10)
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    with (E/'query.log').open('x') as f:
        supervision=supervise_native(r,env,f,E/'reports',E/'native-process.json',start)
        rc=supervision['native_rc'];abort=supervision['abort_reason']
    status={'native_rc':rc,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'abort_reason':abort,'acceptance':'PENDING LOG AND INDEPENDENT REVIEW','hardware_access':False}
    status.update(supervision)
    with (E/'native-result.json').open('x') as f:json.dump(status,f,indent=2)
    effective=(124 if abort else (rc if rc>=0 else 128-rc));errors=[];post={}
    try:
        baseline=json.loads(gzip.decompress((E/'preservation.json.gz').read_bytes()))
        for root,expected in baseline.items():
            try:post[root]=inventory(Path(root))==expected
            except Exception as exc:post[root]=False;errors.append('preservation '+root+': '+repr(exc))
        if len(post)!=3 or not all(v is True for v in post.values()):errors.append('original preservation failed')
    except Exception as exc:errors.append('preservation receipt: '+repr(exc))
    with (E/'preservation-after.json').open('x') as f:json.dump(post,f,indent=2)
    report_files=[]
    try:
        text=(E/'query.log').read_text()
        if text.count('IA840F_FANOUT_CONTRAST_COMPLETE')!=1:errors.append('missing/duplicate completion marker')
        if re.search(r'Error \(|Fatal|125091|_REJECT|Traceback',text):errors.append('native/query/gate diagnostic')
        report_files=sorted(p for p in (E/'reports').rglob('*') if p.is_file())
        if not report_files or len(report_files)>1024:errors.append('report file cardinality/cap')
        if sum(p.stat().st_size for p in report_files)>1024**3:errors.append('report-total cap at completion')
        report_manifest={str(p.relative_to(E)):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in report_files}
        with (E/'report-manifest.json').open('x') as f:json.dump(report_manifest,f,indent=2)
    except Exception as exc:errors.append('report capture: '+repr(exc))
    if errors and effective==0:effective=1
    with (E/'execution-status.json').open('x') as f:json.dump({'effective_rc':effective,'errors':errors,'native_rc':rc,'abort_reason':abort,'timing_accepted':False,'termination_confirmed':supervision['termination_confirmed']},f,indent=2)
    exports={}
    names=['query.log','native-result.json','query.claim','native-process.json','preservation-after.json','execution-status.json','report-manifest.json']+[str(p.relative_to(E)) for p in report_files]
    for name in names:
        p=E/name
        if not p.is_file():continue
        data=p.read_bytes();exports[name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps({'batch':'ia840f_clock_fanout03_result01','files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b','ia840f_clock_fanout03_result01','-'],input=blob,check=True)
    print('FANOUT_CONTRAST_RESULT',effective,'NATIVE_RC',rc,'EXPORT_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
    return effective

if __name__=='__main__':
    try:sys.exit(main_supervised())
    except Exception as exc:
        print('CONSTRAINT_RUNNER_FAILURE',repr(exc),file=sys.stderr,flush=True)
        sys.exit(1)
