#!/usr/bin/env python3
"""Finite ordinary-file lookup; no vendor tool, project, or device access."""
import base64, datetime, gzip, hashlib, json, os, pathlib, socket, subprocess
BATCH='ia840f_emif_hold_source02'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{session_name}'],text=True).strip()=='ia840f_mailbox_monitored_01'
ROOT=pathlib.Path('/opt/altera/26.1.1/ip/altera')
roots=sorted(p for p in ROOT.iterdir() if p.is_dir() and ('emif' in p.name.lower() or 'mem_if' in p.name.lower()))
assert roots, 'no matching installed catalog root'
result={'batch':BATCH,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'roots':[str(p) for p in roots],'scope':'ordinary installed source lookup only; no vendor execution','files':{},'hits':{},'files_read':0,'bytes_read':0}
needles=('TPARAM_EXTRA_CONFIG',)
for root in roots:
    for parent,dirs,names in os.walk(root,followlinks=False):
        dirs[:]=sorted(d for d in dirs if not pathlib.Path(parent,d).is_symlink())
        for name in sorted(names):
            p=pathlib.Path(parent,name)
            if p.suffix.lower() not in ('.tcl','.xml','.ip','.json','.sdc') or p.is_symlink(): continue
            before=p.stat();assert before.st_size<=8000000,'individual source bound'
            result['files_read']+=1;result['bytes_read']+=before.st_size
            assert result['files_read']<=12000 and result['bytes_read']<=200000000,'source lookup bound'
            b=p.read_bytes();after=p.stat();assert (before.st_size,before.st_mtime_ns,before.st_ino)==(after.st_size,after.st_mtime_ns,after.st_ino) and len(b)==before.st_size
            text=b.decode('utf-8',errors='replace')
            if not any(x in text for x in needles): continue
            assert sum(v['size'] for v in result['files'].values())+len(b)<=15000000,'matched export bound'
            result['files'][str(p)]={'size':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
            result['hits'][str(p)]=[{'line':i+1,'text':s} for i,s in enumerate(text.splitlines()) if any(x in s for x in needles)]
blob=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
print('EMIF_HOLD_SOURCE02_COMPLETE',hashlib.sha256(blob).hexdigest(),flush=True)
