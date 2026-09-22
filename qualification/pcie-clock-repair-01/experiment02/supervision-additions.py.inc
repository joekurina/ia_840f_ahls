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
