import base64
p=r/'ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/sim/mem_ss_mem_ss_501_qm5zaka/sim/mem_ss_mem_ss_501_qm5zaka.v'
print('TEXTJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'text':p.read_text()}))
for base in [pathlib.Path('/opt/altera/26.1.1/ip/altera')]:
 for p in base.rglob('*reset*'):
  if p.is_file() and 'mem_ss' in str(p): print('RESETPATH '+str(p))
