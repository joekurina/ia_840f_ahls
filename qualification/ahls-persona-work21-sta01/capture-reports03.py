import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/sta01');J=R/'persona/build/syn/board/ia840f/syn_top';out={'files':{},'output_inventory':{},'hardware_access':False}
for p in (J/'output_files').rglob('*'):
 if p.is_file():
  s=p.stat();out['output_inventory'][str(p.relative_to(R))]={'bytes':s.st_size}
for n in ('ofs_pr_afu.tq.drc.signoff.rpt',):
 p=J/'output_files'/n;s=p.stat();assert 0<s.st_size<120000000;b=p.read_bytes();assert s.st_mtime_ns==p.stat().st_mtime_ns
 out['files'][str(p.relative_to(R))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_sta_reports03','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_sta_reports03_sha256',hashlib.sha256(b).hexdigest()],check=True)
