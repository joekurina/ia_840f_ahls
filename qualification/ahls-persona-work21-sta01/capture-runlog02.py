import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
out={'files':{},'hardware_access':False}
for n,h in {'/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/fit02/persona/build/syn/board/ia840f/syn_top/qdb/_compiler/ofs_pr_afu/_flat/25.1.0/legacy/1/runlog.db': 'a74cf367239a0c48ecc1b352b06fc9f47e783df456d5d313cf08dcb40bbebcb8', '/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/sta01/persona/build/syn/board/ia840f/syn_top/qdb/_compiler/ofs_pr_afu/_flat/25.1.0/legacy/1/runlog.db': '6388e1c05fae09a23a5e203ec3b8332eb62bf6dea6ab28364379d7cf90ddbbc7'}.items():
 p=Path(n);s=p.stat();b=p.read_bytes();assert len(b)==8192 and hashlib.sha256(b).hexdigest()==h;assert s.st_mtime_ns==p.stat().st_mtime_ns
 out['files'][n]={'bytes':len(b),'sha256':h,'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_sta_runlog02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_sta_runlog02_sha256',hashlib.sha256(b).hexdigest()],check=True)
