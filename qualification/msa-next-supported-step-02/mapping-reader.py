import os,socket,json,pathlib,hashlib,subprocess
assert os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation'
result={}
for root in ['/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/ia840f','/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/ipss/mem/qip/mem_ss','/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config']:
 hits=[]
 for dp,ds,fs in os.walk(root):
  ds[:]=[x for x in ds if x not in ['.git','sim','simulation']]
  for f in fs:
   p=pathlib.Path(dp)/f
   if p.suffix in ['.xml','.json','.py','.sv','.v','.tcl'] and p.stat().st_size<2000000:
    t=p.read_text(errors='replace')
    if 'NUM_BANK_FIFOS' in t or 'BANK_SPREADING_EN' in t:
     hits.append({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'lines':[[i,l] for i,l in enumerate(t.splitlines(),1) if any(x in l for x in ['NUM_BANK_FIFOS','BANK_SPREADING_EN','NUM_COPIES','NUM_WRITE_COPIES'])]})
 result[root]=hits

raw=json.dumps(result,sort_keys=True).encode(); envelope=json.dumps({'sha256':hashlib.sha256(raw).hexdigest(),'payload':raw.decode()}).encode();subprocess.run(['tmux','load-buffer','-b','msa02-mapping-fbd70ed8','-'],input=envelope,check=True)
