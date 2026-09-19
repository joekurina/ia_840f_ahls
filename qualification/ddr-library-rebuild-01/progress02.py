from pathlib import Path
import json,time
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-rebuild-01')
print('STAGE', (Q/'stage-status.json').read_text() if (Q/'stage-status.json').exists() else 'preflight')
for p in sorted((Q/'run-06').glob('*.log')):
 print(p.name,p.stat().st_size,p.read_text(errors='replace')[-2500:])
if (Q/'launch-result.json').exists():print('LAUNCH', (Q/'launch-result.json').read_text())
if (Q/'run-06/result.json').exists():
 r=json.loads((Q/'run-06/result.json').read_text());print(json.dumps({k:v for k,v in r.items() if k not in ['reuse','imports']},indent=2))
