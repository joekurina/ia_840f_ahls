from pathlib import Path
import json,re
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01')
for n in ['inventory.json','import-manifest.json']:
 p=Q/n;print(n,p.exists())
 if p.exists():
  j=json.loads(p.read_text());print(json.dumps(j,indent=2)[:22000])
p=Q/'donor-iossm-wrapper.txt'
if p.exists():
 t=p.read_text();print('IOSSM',t[:3000]);i=t.find('tennm_iossm_model_encrypted');print('MODEL_INSTANTIATION',t[i:i+7000])
P=Q.parent/'ddr-smoke-02';m=json.loads((P/'manifest.json').read_text());print('RECIPE_PATHS',[(x['path']) for x in m['inputs'] if x['path'].endswith('msim_setup.tcl')]);print('TOOLS',(P/'run-03/result.json').read_text()[:3000])
