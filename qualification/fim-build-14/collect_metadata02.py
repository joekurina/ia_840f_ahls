#!/usr/bin/env python3
"""Read only the three changed metadata inputs and comparison sources."""
import base64, gzip, hashlib, json, os, socket, stat, subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP')
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
r={'batch':'ia840f_fim14_metadata02_output','files':{},'errors':{}}
paths=[B/work/'syn/board/ia840f/syn_top'/name for work in ('work_ia840f_fim_13','work_ia840f_fim_12') for name in ('build_env_db.txt','fme_id.mif','ofs_top.qpf')]
paths += [B/'ofs-agx7-pcie-attach/syn/board/ia840f/syn_top'/name for name in ('ofs_top.qpf','fme_id.mif')]
for p in paths:
    try:
        q=p.resolve(strict=True)
        assert q.is_relative_to(B) and stat.S_ISREG(q.stat().st_mode) and q.stat().st_size<100000
        data=q.read_bytes()
        r['files'][str(p)]=dict(size=len(data),sha256=hashlib.sha256(data).hexdigest(),base64=base64.b64encode(data).decode())
    except Exception as exc:r['errors'][str(p)]=repr(exc)
raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
subprocess.run(['tmux','load-buffer','-b',r['batch'],'-'],input=blob,check=True)
print('METADATA',r['batch'],'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
