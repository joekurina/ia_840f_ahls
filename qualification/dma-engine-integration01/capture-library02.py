import os,socket,json,hashlib,subprocess
from pathlib import Path
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
p=Path('/opt/altera/25.1/questa_fe/intel/verilog/altera_mf');files=sorted(x for x in p.rglob('*') if x.is_file());assert 0<len(files)<2000
r={"batch":"ia840f_dmaeng_library02","path":str(p),"files":{}}
for f in files:
 h=hashlib.sha256()
 with f.open('rb') as s:
  for b in iter(lambda:s.read(1048576),b''):h.update(b)
 r['files'][str(f)]={"bytes":f.stat().st_size,"sha256":h.hexdigest()}
raw=json.dumps(r,indent=2).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_dmaeng_library02','-'],input=raw,check=True)
print('LIBRARY_SHA256='+hashlib.sha256(raw).hexdigest(),flush=True)
