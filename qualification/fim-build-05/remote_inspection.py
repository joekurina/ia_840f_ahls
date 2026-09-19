from pathlib import Path
import json, os
N=Path('/home/uwb_student00/ahls/new_BSP'); C=N/'ofs-agx7-pcie-attach'; W=N/'work_ia840f_ipgen_04'
print('INSTRUCTIONS',Path('/home/uwb_student00/quartus_26/instructions.md').read_text())
print('WORK05 EXISTS',(N/'work_ia840f_fim_05').exists())
for rel in ['syn/board/ia840f/syn_top/build_env_db.txt','syn/board/ia840f/syn_top/ofs_top.qsf','syn/board/ia840f/setup/build_gate.tcl']:
 print('FILE',rel,(W/rel).read_text())
print('SYMLINKS',json.dumps({str(p.relative_to(W)):os.readlink(p) for p in W.rglob('*') if p.is_symlink()},indent=2))
r=json.loads((C/'syn/board/ia840f/setup/experimental-authorization.json').read_text()); r.pop('source_sha256',None);r.pop('pim_sha256',None)
print('AUTH',json.dumps(r,indent=2))
print('CALLBACKS')
for p in (W/'syn').rglob('*'):
 if p.suffix in ('.tcl','.qsf') and p.is_file():
  lines=[x for x in p.read_text(errors='replace').splitlines() if any(s in x for s in ('SCRIPT_FILE','quartus(','exec ', 'qexec '))]
  if lines: print(p, '\n'.join(lines))
