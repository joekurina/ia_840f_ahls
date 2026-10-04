"""Exactly one approved normal workstation reboot after verified activation."""
import datetime,hashlib,json,os,re,socket,subprocess,sys,time,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');W=ROOT/'reboot53';EXPECTED_CYCLE='ab81f372e1323e8502f32e899b1ede5e9e157448d6c46fae9b6ce42290ab7dca'
out={'scope':'one approved normal workstation reboot; no card/reset/reflash operation','success':False,'commands':[],'boot_before':Path('/proc/sys/kernel/random/boot_id').read_text().strip()};owned=False
BATCH=sys.argv[1]
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def transport(r):
    a=r.get('argv',[])
    return ((r.get('exe')=='/usr/bin/bash' and len(a)==3 and a[:2]==['bash','-c'] and a[2].startswith('tmux save-buffer -b '+BATCH+'_source - | ')) or (r.get('exe')=='/usr/bin/tmux' and a==['tmux','wait-for',BATCH+'_done']))
def durable(name,obj):
    with (W/name).open('x') as stream:json.dump(obj,stream,indent=2);stream.flush();os.fsync(stream.fileno())
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not W.exists()
    assert sha(ROOT/'bmc-cycle52/result.json')==EXPECTED_CYCLE;cycle=json.loads((ROOT/'bmc-cycle52/result.json').read_text());assert cycle['success'] is True and cycle['card_cycle_verified'] is True and cycle['off_confirmed'] is True and cycle['on_confirmed'] is True and cycle['boot_after']==out['boot_before']
    assert not Path('/run/systemd/shutdown/scheduled').exists()
    # Readiness before exclusive receipt creation avoids write-triggered PID1 transients.
    snapshots=[]
    for index in range(3):
        z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(ROOT/'activation-pre43/runtime/ownership27.py')],capture_output=True,timeout=60);assert z.returncode==0;s=json.loads(z.stdout)
        assert s['boot_id']==out['boot_before'] and not any(s[k] for k in ['d_state','holders','maps','errors'])
        assert not [r for r in s['relevant_processes'] if not transport(r)];snapshots.append(s)
        if index<2:time.sleep(1)
    W.mkdir(exist_ok=False);owned=True;out.update(cycle_sha256=EXPECTED_CYCLE,readiness=snapshots,argv=['sudo','-n','/usr/bin/systemctl','reboot'],requested=now());durable('requested.json',out)
    z=subprocess.run(out['argv'],capture_output=True,text=True,timeout=20);out.update(reboot_rc=z.returncode,reboot_output=z.stdout+z.stderr,command_returned=now(),success=z.returncode==0);durable('command-result.json',out)
except BaseException as exc:
    out.update(error=repr(exc),traceback=traceback.format_exc())
    if owned:durable('failure.json',out)
if not out['success']:raise SystemExit(1)
