from pathlib import Path
import json,re
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');O=Q/'run-04'
for p in sorted(O.glob('*.log')):
 t=p.read_text(errors='replace');print('LOG',p.name,p.stat().st_size);print(t[-1800:])
for n in ['launch-v2.log','launch-v2-result.json','additional-archive-inventory.json']:
 if (Q/n).exists():print(n,(Q/n).read_text()[:12000])
if (O/'result.json').exists():
 j=json.loads((O/'result.json').read_text());print('RESULT',json.dumps({k:v for k,v in j.items() if k not in ['reuse','imports']},indent=2))
