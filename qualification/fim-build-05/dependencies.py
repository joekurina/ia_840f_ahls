from pathlib import Path
import json
N=Path('/home/uwb_student00/ahls/new_BSP');W=N/'work_ia840f_ipgen_04';Q=Path('/opt/altera/26.1.1/quartus')
for rel in ['syn/shared_config/post_module_hook.tcl','ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl','ofs-common/scripts/common/syn/config_env.tcl']:
 print('FILE',rel,(W/rel).read_text())
print('FLOWS')
for p in (Q/'common/tcl').rglob('*'):
 if p.is_file() and ('flow' in p.name or 'compile' in p.name):
  print(p)
  if p.suffix in ('.tcl','.tm'):
   text=p.read_text(errors='replace')
   print('\n'.join(x for x in text.splitlines() if any(t in x for t in ('quartus_syn','quartus_fit','quartus_asm','quartus_sta','quartus_ipgenerate','execute_module','post_module'))))
old=str(W).encode();refs=[]; bins=[];total=0
for p in W.rglob('*'):
 if p.is_file() and not p.is_symlink():
  total+=p.stat().st_size
  data=p.read_bytes()
  if old in data:
   refs.append(str(p.relative_to(W)))
   if b'\0' in data: bins.append(str(p.relative_to(W)))
print('BYTES',total,'OLDPATHFILES',json.dumps(refs),'BINARYOLDPATH',json.dumps(bins))
