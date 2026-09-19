from pathlib import Path
import os,socket,subprocess,json,hashlib
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01');Q.mkdir(exist_ok=False)
root=Path('/usr/share/bittware-sdk')
files=[]
for p in root.rglob('*'):
 if p.is_file():files.append({'path':str(p),'bytes':p.stat().st_size})
r={'hostname':socket.gethostname(),'uid':os.getuid(),'rpm':subprocess.run(['rpm','-qi','bittware-sdk'],capture_output=True,text=True).__dict__,'files':files}
(Q/'inventory.json').write_text(json.dumps(r,indent=2,default=str))
print('FILES',len(files));print(r['rpm'])
for f in files:
 p=f['path'].lower()
 if any(x in p for x in ['840','release','csp','patch','questa','simulat','readme','tennm','fmica']):print(f)
