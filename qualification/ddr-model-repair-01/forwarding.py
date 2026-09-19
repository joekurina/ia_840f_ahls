import pathlib
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04')
print('EMIF_IPS',[str(p) for p in (r/'ipss/mem/qip').rglob('*.ip') if 'emif' in p.name])
for p in pathlib.Path('/opt/altera/26.1.1/ip/altera/emif').rglob('*.tcl'):
 if 'ex_design' not in str(p) and p.name!='exports.tcl':continue
 t=p.read_text(errors='replace');lines=t.splitlines()
 for i,l in enumerate(lines):
  if ('altera_emif_mem_model' in l or 'inherit_top_level_parameter_defs' in l):print('SOURCE',p,i+1);print('\n'.join(lines[max(0,i-15):i+40]))
