from pathlib import Path
import json,hashlib
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01')
roots=[Path('/opt/intelFPGA_pro/23.1/quartus/eda/sim_lib'),Path('/opt/intelFPGA_pro/23.1/questa_fse'),Path('/home/uwb_student00/IA-840f')]
for p in roots:
 print('ROOT',p,p.exists());print([x.name for x in p.iterdir()] if p.exists() else [])
for p in roots[0].glob('*tennm*'):print('CANDIDATE',p,p.stat().st_size)
for p in (roots[0]/'mentor').glob('*tennm*'):print('ENCRYPTED',p,p.stat().st_size)
print('INVENTORY_DONE',(Q/'inventory.json').exists())
