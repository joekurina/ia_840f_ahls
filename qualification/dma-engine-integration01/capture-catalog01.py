import os,socket,json,hashlib,subprocess
from pathlib import Path
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
p=Path('/opt/altera/25.1/questa_fe/modelsim.ini');b=p.read_bytes();assert hashlib.sha256(b).hexdigest()=='17fa715b65c5980355566db472bf92bad020c9579f6c7b464edd1b56fc05ff4d'
lines=[l for l in b.decode().splitlines() if not l.lstrip().startswith(';') and ('altera' in l.lower() or l.startswith('[Library]'))]
r={"batch":"ia840f_dmaeng_catalog01","ini_path":str(p),"ini_sha256":hashlib.sha256(b).hexdigest(),"mappings":lines,"vdir":{}}
v=Path('/opt/altera/25.1/questa_fe/linux_x86_64/vdir');r['vdir']={"path":str(v),"sha256":hashlib.sha256(v.read_bytes()).hexdigest()}
raw=json.dumps(r,indent=2).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_dmaeng_catalog01','-'],input=raw,check=True)
print('CATALOG_SHA256='+hashlib.sha256(raw).hexdigest(),flush=True)
