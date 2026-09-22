#!/usr/bin/env python3
"""Transport reviewed read-only collector to an owned remote tmux pane."""
import json, shlex, subprocess
from pathlib import Path
root=Path(__file__).resolve().parent
ssh=['ssh','-o','BatchMode=yes','-o','ConnectTimeout=12','uwb_student00@100.101.227.97']
def call(args, data=None):
    p=subprocess.run(ssh+[shlex.join(args)],input=data,capture_output=True,timeout=25)
    receipt=dict(argv=args,rc=p.returncode,stdout=p.stdout.decode(),stderr=p.stderr.decode())
    print(json.dumps(receipt),flush=True)
    if p.returncode: raise RuntimeError(receipt)
    return receipt
receipt=[]
receipt.append(call(['tmux','load-buffer','-b','ia840f_source_resume_01_input01','-'],(root/'collect01.py').read_bytes()))
receipt.append(call(['tmux','new-session','-d','-P','-F','#{session_name} #{window_id} #{pane_id}','-s','ia840f_mailbox_monitored_01','-n','source_resume_01','tmux save-buffer -b ia840f_source_resume_01_input01 - | python3 -B; exec bash']))
(root/'launch01.json').write_text(json.dumps(receipt,indent=2)+'\n')
