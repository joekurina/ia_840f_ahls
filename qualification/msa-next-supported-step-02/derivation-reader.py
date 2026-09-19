import os,socket,json,pathlib,hashlib,subprocess
assert os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation'
result={}
root=pathlib.Path('/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/ia840f'); result['preset_files']=[str(p) for p in root.glob('*')]
paths=['/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/ia840f/preset_derivation.json']
for p in pathlib.Path('/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/tools').rglob('*.py'):
 if 'NUM_BANK_FIFOS' in p.read_text(errors='replace'):paths.append(str(p))
for p in root.glob('*.qprs'):paths.append(str(p))
paths += ['/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_msa_0/synth/mem_ss_mem_ss_501_qm5zaka_msa_0.v', '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_msa_1/synth/mem_ss_mem_ss_501_qm5zaka_msa_1.v']
for f in paths:
 p=pathlib.Path(f);b=p.read_bytes();result[f]={'sha256':hashlib.sha256(b).hexdigest(),'text':b.decode()}

raw=json.dumps(result,sort_keys=True).encode(); envelope=json.dumps({'sha256':hashlib.sha256(raw).hexdigest(),'payload':raw.decode()}).encode();subprocess.run(['tmux','load-buffer','-b','msa02-derivation-21d5a2d6','-'],input=envelope,check=True)
