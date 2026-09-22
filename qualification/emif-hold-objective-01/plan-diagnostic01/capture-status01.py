#!/usr/bin/env python3
"""Passive ordinary-file/process snapshot of this Plan invocation only."""
from pathlib import Path
import os,socket,subprocess,json,hashlib,datetime
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01')
batch='ia840f_emif_plan01_status01'
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'processes':[]}
for name in ('launch01/issuance.json','authorization.json','query.claim','native-process.json','native-result.json','execution-status.json','preservation-after.json'):
    p=E/name
    if p.is_file():
        b=p.read_bytes();r['files'][name]={'sha256':hashlib.sha256(b).hexdigest(),'json':json.loads(b)}
p=E/'query.log'
if p.is_file():
    with p.open('rb') as f:f.seek(max(0,p.stat().st_size-20000));r['log_tail']=f.read().decode(errors='replace')
    r['log_bytes']=p.stat().st_size
roots=set()
for name in ('query.claim','native-process.json'):
    if name in r['files']:roots.add(r['files'][name]['json']['pid'])
rows=[x.split(None,3) for x in subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True).splitlines()[1:]]
for _ in range(32):
    more={int(x[0]) for x in rows if len(x)>=3 and int(x[1]) in roots}
    if more<=roots:break
    roots|=more
for row in rows:
    if len(row)>=3 and int(row[0]) in roots:
        p=Path('/proc')/row[0]
        try:r['processes'].append({'pid':int(row[0]),'ppid':int(row[1]),'comm':row[2],'args':row[3] if len(row)>3 else '', 'stat':(p/'stat').read_text(),'exe':str((p/'exe').resolve()),'cwd':str((p/'cwd').resolve())})
        except FileNotFoundError:pass
blob=json.dumps(r,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=blob,check=True)
print('EMIF_PLAN_STATUS01',hashlib.sha256(blob).hexdigest(),flush=True)
