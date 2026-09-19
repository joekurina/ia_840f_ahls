from pathlib import Path
import os,socket,json,hashlib,base64,zlib,subprocess
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-11'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert (E/'final-verification.json').is_file()
files={str(p.relative_to(E)):p.read_bytes() for p in sorted(E.rglob('*')) if p.is_file() and 'inherited-output' not in p.relative_to(E).parts and '__pycache__' not in p.parts}
manifest={r:hashlib.sha256(data).hexdigest() for r,data in files.items()}
archive={'batch':'work11-review-export-01','manifest':manifest,'files':{r:base64.b64encode(data).decode() for r,data in files.items()}}
wire=base64.b64encode(zlib.compress(json.dumps(archive).encode()))
subprocess.run(['tmux','load-buffer','-b','work11-review-export-01','-'],input=wire,check=True)
print(json.dumps({'batch':archive['batch'],'files':len(files),'wire_sha256':hashlib.sha256(wire).hexdigest(),'bytes':len(wire)}))
