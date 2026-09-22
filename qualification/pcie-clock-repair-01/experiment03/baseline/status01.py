from pathlib import Path
import json,os,hashlib,datetime,subprocess
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/experiment03/baseline')
result={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'process':None}
for name in ('authorization.json','launch01/issuance.json','native-process.json','query.claim','native-result.json','execution-status.json','preservation-after.json'):
 p=E/name
 if p.is_file():
  data=p.read_bytes();result['files'][name]={'sha256':hashlib.sha256(data).hexdigest(),'value':json.loads(data)}
p=E/'query.log'
if p.is_file():
 with p.open('rb') as f:
  f.seek(0,2);size=f.tell();f.seek(max(0,size-8192));tail=f.read()
 result['log']={'bytes':size,'tail':tail.decode(errors='replace'),'partial':True}
if 'native-process.json' in result['files']:
 pid=result['files']['native-process.json']['value']['pid'];root=Path('/proc')/str(pid)
 try:result['process']={'pid':pid,'stat':(root/'stat').read_text(),'exe':str((root/'exe').resolve()),'argv':(root/'cmdline').read_bytes().rstrip(b'\0').decode().split('\0'),'cwd':str((root/'cwd').resolve())}
 except FileNotFoundError:result['process']={'pid':pid,'absent':True}
result['candidate_authorization_exists']=(E.parent/'candidate/authorization.json').exists()
raw=json.dumps(result,sort_keys=True).encode()
subprocess.run(['tmux','load-buffer','-b','ia840f_clock_baseline03_status01','-'],input=raw,check=True)
print('BASELINE03_STATUS01',hashlib.sha256(raw).hexdigest(),flush=True)
