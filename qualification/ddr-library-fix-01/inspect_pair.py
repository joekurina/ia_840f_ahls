from pathlib import Path
import json,subprocess,os
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');q=p.parent/'ddr-library-fix-01'
f=Path('/opt/altera/26.1.1/questa_fe/intel/verilog/src/tennm_atoms.sv');lines=f.read_text().splitlines()
for a,b in [(5815,5845),(6080,6250)]:
 print('\nSOURCE',a,b);print('\n'.join(f'{i+1}: {lines[i]}' for i in range(a-1,b)))
print('INCLUDES',[(i+1,l) for i,l in enumerate(lines) if '`include' in l or 'module tennm_iossm_model' in l])
for root in ['/opt/altera/26.1.1/questa_fe/intel','/opt/altera/26.1.1/quartus/eda']:
 for d,ds,fs in os.walk(root):
  for name in fs:
   if any(t in name.lower() for t in ['iossm','tennm_atoms','tennm_components']):print('CANDIDATE',str(Path(d)/name))
m=json.loads((p/'manifest.json').read_text())
for x in m['inputs']:
 if 'iossm' in x['path']:print('IPIOSSM',x)
print('DONE')
