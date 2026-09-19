from pathlib import Path
import os,json,hashlib,subprocess,datetime
N=Path('/home/uwb_student00/ahls/new_BSP');E=N/'qualification/fim-build-11';W=N/'work_ia840f_fim_11'
markers=[b'IA840F_GATE_REJECTED',b'IA840F NOT READY',b'IA840F EXPERIMENTAL GATE:',b'125091']
paths=set(W.rglob('*.log'))|set(W.rglob('*.rpt'))|{E/'run/native.log'}
result={'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'status':json.loads((E/'run/status.json').read_text()),'files':{}}
for p in sorted(paths):
 if p.is_file():
  b=p.read_bytes();result['files'][str(p)]={'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b),'markers':{m.decode():b.count(m) for m in markers}}
p=E/'startup-report-marker-scan.json'
with p.open('x') as f:json.dump(result,f,indent=2)
subprocess.run(['tmux','load-buffer','-b','work11-startup-report-marker-scan',str(p)],check=True)
print('SCAN',hashlib.sha256(p.read_bytes()).hexdigest(),flush=True)
