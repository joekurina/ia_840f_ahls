import os,socket,json,pathlib,hashlib,subprocess
assert os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation'
result={}
for root in ['/home/uwb_student00/IA-840f','/home/uwb_student00/Documents/IA-840f','/home/uwb_student00/ahls/new_BSP']:
 p=pathlib.Path(root);result[root]= {'exists':p.exists(),'children':[x.name for x in p.iterdir()] if p.exists() else []}
p=pathlib.Path('/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg');result['catalog']=[str(x.relative_to(p)) for x in p.glob('*/*') if x.suffix=='.tcl']

raw=json.dumps(result,sort_keys=True).encode(); envelope=json.dumps({'sha256':hashlib.sha256(raw).hexdigest(),'payload':raw.decode()}).encode();subprocess.run(['tmux','load-buffer','-b','msa02-discovery-26510e28','-'],input=envelope,check=True)
