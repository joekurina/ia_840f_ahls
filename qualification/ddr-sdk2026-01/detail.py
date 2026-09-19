from pathlib import Path
import json,subprocess,hashlib
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01')
r=json.loads((Q/'inventory.json').read_text())
for f in r['files']:print(f)
p=subprocess.run(['rpm','-ql','bittware-sdk'],capture_output=True,text=True);(Q/'rpm-files.txt').write_text(p.stdout);print('RPMFILES',p.stdout)
