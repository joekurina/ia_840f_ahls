"""One finite tmux completion wait; it never starts or retries a native job."""
import datetime,json,shlex,subprocess
from pathlib import Path
E=Path(__file__).resolve().parent
output=E/'sta20-completion-event.json'
assert not output.exists(), 'completion already captured'
base=['ssh','-o','BatchMode=yes','-o','ConnectTimeout=15','uwb_student00@100.101.227.97']
channel='ia840f_fim24_caps03_sta_native20_done';buffer='ia840f_fim24_caps03_sta_native20_rc'
r={'stage':'persona-multicorner-sta','done_channel':channel,'rc_buffer':buffer,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'native_acceptance':False}
try:
    p=subprocess.run(base+[shlex.join(['tmux','wait-for',channel])],capture_output=True,text=True,timeout=2400)
    r.update(wait_rc=p.returncode,wait_stderr=p.stderr)
    if p.returncode==0:
        q=subprocess.run(base+[shlex.join(['tmux','save-buffer','-b',buffer,'-'])],capture_output=True,text=True,timeout=30)
        r.update(readback_rc=q.returncode,readback_stderr=q.stderr,outer_rc=int(q.stdout.strip()) if q.returncode==0 else None)
except BaseException as exc:r['error']=repr(exc)
finally:
    r['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    with output.open('x') as f:json.dump(r,f,indent=2)
    print(json.dumps(r,indent=2),flush=True)
raise SystemExit(0 if r.get('wait_rc')==0 and r.get('readback_rc')==0 else 1)
