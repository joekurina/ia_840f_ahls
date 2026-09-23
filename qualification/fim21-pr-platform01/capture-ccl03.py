import os,socket,json,hashlib,base64,gzip,subprocess
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
root=Path('/opt/altera/25.1/quartus/common/tcl/packages/qpm');out={}
for p in root.glob('*.tcl'):
 if any(s in p.name for s in ('ccl','pkgIndex','auto','qsf')):
  assert p.stat().st_size<1_000_000;b=p.read_bytes();out[str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b','ia840f_pr_export_ccl03','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_pr_export_ccl03_sha256',hashlib.sha256(b).hexdigest()],check=True)
