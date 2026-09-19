import os,socket,json,pathlib,hashlib,subprocess
assert os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation'
result={}
paths=[pathlib.Path('/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/ia840f/derive_presets.py')]+list(pathlib.Path('/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/ia840f/presets').glob('*'))
for p in paths:
 if p.is_file():
  b=p.read_bytes();result[str(p)]={'sha256':hashlib.sha256(b).hexdigest(),'text':b.decode()}

raw=json.dumps(result,sort_keys=True).encode(); envelope=json.dumps({'sha256':hashlib.sha256(raw).hexdigest(),'payload':raw.decode()}).encode();subprocess.run(['tmux','load-buffer','-b','msa02-preset-faeccd4b','-'],input=envelope,check=True)
