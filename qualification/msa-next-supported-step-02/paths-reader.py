import os,socket,json,pathlib,hashlib,subprocess
assert os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation'
result={}
roots=['/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT','/home/uwb_student00/IA-840f/ia-840','/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach','/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11']
for root in roots:
 hits=[]
 for dp,ds,fs in os.walk(root):
  ds[:]=[d for d in ds if d not in ['.git','qdb','output_files','simulation','sim','db']]
  for f in fs:
   if (f.endswith(('.ip','.qsys','.ofss')) and ('mem' in f.lower() or 'ddr' in f.lower() or f.endswith('.ofss'))):hits.append(str(pathlib.Path(dp)/f))
 result[root]=hits[:150];result[root+'count']=len(hits)

raw=json.dumps(result,sort_keys=True).encode(); envelope=json.dumps({'sha256':hashlib.sha256(raw).hexdigest(),'payload':raw.decode()}).encode();subprocess.run(['tmux','load-buffer','-b','msa02-paths-286f7536','-'],input=envelope,check=True)
