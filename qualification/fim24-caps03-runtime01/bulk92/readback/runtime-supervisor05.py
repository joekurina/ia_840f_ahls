"""Keep the container command alive while a DMA owner is uncertain.
No kill/reset/cleanup API. The caller may observe the saved result from outside.
"""
import os,signal,subprocess,time
from pathlib import Path

def retain(state,save,reason):
    state.update(success=False,retained_owner=True,execution_state='UNKNOWN',reason=reason)
    try:save(state)
    except BaseException as exc:
        try:os.write(2,('SUPERVISOR_SAVE_FAILED '+repr(exc)+'\n').encode())
        except BaseException:pass
    try:os.write(2,('SUPERVISOR_RETAINED '+reason+'\n').encode())
    except BaseException:pass
    while True:
        try:time.sleep(3600)
        except BaseException:pass

def supervise(argv,env,cwd,log_path,save,deadline_seconds):
    if deadline_seconds<=0:raise ValueError('positive observation deadline required')
    # Block before spawning, including ordinary supervisor-termination signals.
    signal.pthread_sigmask(signal.SIG_BLOCK,signal.valid_signals()-{signal.SIGKILL,signal.SIGSTOP})
    p=None
    state={'application_started':False,'success':False,'retained_owner':False,'argv':argv}
    log_path=Path(log_path)
    try:
        with log_path.open('xb') as log:
            p=subprocess.Popen(argv,env=env,cwd=cwd,stdin=subprocess.DEVNULL,
                               stdout=log,stderr=subprocess.STDOUT)
            state.update(application_started=True,pid=p.pid)
            # Everything after successful spawn is inside this lifetime boundary.
            try:
                stat=Path('/proc/'+str(p.pid)+'/stat').read_text()
                state['start_ticks']=stat.rsplit(')',1)[1].split()[19]
            except FileNotFoundError:state['start_ticks_unavailable']='child exited before metadata read'
            save(state)
            end=time.monotonic()+deadline_seconds
            while True:
                rc=p.poll()
                if rc is not None:
                    state.update(native_rc=rc,execution_state='EXITED',success=(rc==0))
                    save(state)
                    return state
                # This file is ordinary native output, never an FPGA accessor.
                with log_path.open('rb') as f:data=f.read(131073)
                if len(data)>131072:retain(state,save,'native log limit exceeded')
                if b'HOLD_UNKNOWN_DMA' in data:retain(state,save,'application ownership hold')
                if time.monotonic()>=end:retain(state,save,'observation deadline; child not terminated')
                time.sleep(.02)
    except BaseException as exc:
        if p is not None:retain(state,save,'post-spawn supervisor error: '+repr(exc))
        raise
