from pathlib import Path
import json,hashlib
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02')
q=p.parent/'ddr-library-fix-01';q.mkdir(exist_ok=False)
m=json.loads((p/'manifest.json').read_text())
print('MANIFEST_KEYS',list(m))
for x in m['inputs']:
 f=Path(x['path'])
 if f.suffix in ('.sv','.v','.tcl'):
  s=f.read_text(errors='replace')
  if 'tennm_iossm_model_encrypted' in s or 'tennm_atoms' in s:
   print('MATCH',str(f),x['sha256'])
   for i,l in enumerate(s.splitlines()):
    if any(t in l for t in ['tennm_iossm','EMIF_DISABLE','tennm_atoms','tennm_ver','mentor/']):print(i+1,l)
print('DEVICE_LIBS',m['device_libraries'])
for d in [Path('/opt/altera/26.1.1/quartus/eda/sim_lib'),Path('/opt/altera/26.1.1/questa_fe/intel/verilog/src')]:
 print('DIR',d)
 print([(x.name,x.stat().st_size) for x in d.iterdir() if any(t in x.name.lower() for t in ['tennm','iossm','mentor','fmica'])])
for f in Path('/opt/altera/26.1.1/questa_fe/intel/verilog/src').glob('*tennm*'):
 if f.is_file():print('SOURCE',str(f),hashlib.sha256(f.read_bytes()).hexdigest())
print('DONE')
