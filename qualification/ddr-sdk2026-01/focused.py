from pathlib import Path
import json,zipfile
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01')
for x in json.loads((Q/'wheel-hits.json').read_text()):print('HIT',json.dumps(x))
for x in json.loads((Q/'wheel-inventory.json').read_text()):
 if 'agilex' in x['path']:
  print('IA840F MEMBERS',json.dumps([n for n in x['members'] if '840' in n.lower()]))
for x in json.loads((Q/'vendor-package-files.json').read_text()):
 p=x['path']
 if 'IOFS_BUILD_ROOT' not in p and (p.endswith('.pdf') or any(s in Path(p).name.lower() for s in ['sdk','csp','2026','release'])): print('PACKAGE',x)
