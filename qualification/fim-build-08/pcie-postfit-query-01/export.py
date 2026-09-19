from pathlib import Path
import json,hashlib,subprocess
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01')
names=['sta-help.log','api-help2.log','atoms-help.log','query.tcl','query-binding.json','query.log','before.json','after.json','result.json']
data={n:{'text':(p/n).read_text(),'sha256':hashlib.sha256((p/n).read_bytes()).hexdigest()} for n in names}
f=p/'evidence.json';f.write_text(json.dumps(data));subprocess.run(['tmux','load-buffer','-b','pcie_postfit_query_01_final',str(f)],check=True);print('EXPORT_READY',hashlib.sha256(f.read_bytes()).hexdigest());print((p/'result.json').read_text())
