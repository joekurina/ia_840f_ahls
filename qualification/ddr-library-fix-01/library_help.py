from pathlib import Path
import subprocess,os
q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-fix-01');t=Path('/opt/altera/26.1.1/questa_fe')
for tool in ['vopt','vsim']:
 r=subprocess.run([str(t/'bin'/tool),'-help','Library'],cwd=q,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30);(q/(tool+'-library-help.log')).write_text(r.stdout);print(r.stdout)
# installed text support notes only
for d in [t/'docs/technotes',t/'docs/cmd_help',Path('/opt/altera/26.1.1/quartus/common/tcl/internal')]:
 for f in d.glob('*'):
  if f.is_file() and f.stat().st_size<2000000:
   s=f.read_text(errors='replace')
   if any(x in s for x in ['ENABLE_QE_LIBRARY_COMPILATION','EMIF_DISABLE_CAL_OPTIMIZATIONS','tennm_iossm_model_encrypted']):print('RECIPE',str(f));print('\n'.join(l for l in s.splitlines() if any(x in l for x in ['ENABLE_QE','EMIF_DISABLE','iossm','builtin'])))
print('DONE')
