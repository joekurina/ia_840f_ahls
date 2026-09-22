#!/usr/bin/env python3
"""Finite ordinary-file/OS preflight in owned tmux; no vendor or hardware calls."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess
from typing import Any
B=Path('/home/uwb_student00/ahls/new_BSP')
W=B/'work_ia840f_fim_14'
P=B/'ofs-platform-afu-bbb'
E=B/'qualification/fim-build-14/pcie-postfit-01'
BATCH='ia840f_w14_postfit_preflight01'
if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX'):
    raise RuntimeError('wrong host/uid/tmux')
pane=os.environ['TMUX_PANE']
if subprocess.check_output(['tmux','display-message','-p','-t',pane,'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':
    raise RuntimeError('wrong owned session')
r: dict[str,Any]=dict(batch=BATCH,time=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=pane,files={},trees={},prospective_exists=E.exists(),disk_free=shutil.disk_usage(B).free)
r['memory']=Path('/proc/meminfo').read_text()
r['processes']=[s for s in subprocess.check_output(['ps','-eo','pid,ppid,stat,pcpu,rss,comm,args'],text=True).splitlines() if any(k in s for k in ('quartus_','qsys-','launch_native_compile','run-query'))]
for root in (W,P):
    entries={}
    for d,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            f=Path(d)/name; rel=str(f.relative_to(root))
            if f.is_symlink(): entries[rel]={'link':os.readlink(f),'resolved':str(f.resolve())}
            elif f.is_file(): entries[rel]={'bytes':f.stat().st_size}
    r['trees'][str(root)]=dict(entries=entries,regular_bytes=sum(x.get('bytes',0) for x in entries.values()))
paths=[W/'syn/board/ia840f/syn_top'/n for n in ('ofs_top.qsf','ofs_top.qpf','build_env_db.txt','fim_project_macros.tcl')]
paths += [W/n for n in ('ofs-common/tools/ofss_config/ia840f_experimental_gate.py','ofs-common/tools/ofss_config/ia840f_compile_gate.py','syn/shared_config/top.sdc','syn/shared_config/top_sdc_util.tcl','syn/board/ia840f/setup/config_env.tcl','syn/board/ia840f/setup/ia840f_experimental_gate.tcl')]
paths += [B/'qualification/fim-build-14'/n for n in ('compile-authorization.json','run/status.json')]
for f in paths:
    if not f.exists():
        r['files'][str(f)]={'missing':True}; continue
    if not f.resolve().is_relative_to(B) or not f.is_file():raise RuntimeError('unexpected path '+str(f))
    if f.stat().st_size>2000000:raise RuntimeError('oversize '+str(f))
    data=f.read_bytes();r['files'][str(f)]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
for f in (Path('/opt/altera/26.1.1/quartus/bin/quartus_sta'),Path('/opt/altera/26.1.1/quartus/linux64/quartus_sta')):
    data=f.read_bytes();r['files'][str(f)]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'resolved':str(f.resolve())}
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
print('PREFLIGHT_COMPLETE',hashlib.sha256(blob).hexdigest(),flush=True)
