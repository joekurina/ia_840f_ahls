from pathlib import Path
import os,json,hashlib,subprocess,datetime
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/clock-trial02')
assert os.environ.get('TMUX') and subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
o={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'batch':'ia840f_clock_trial02_status01','files':{},'live_group':[]}
for n in ['launch01/issuance.json','authorization.json','query.claim','native-process.json','native-result.json','execution-status.json','preservation-after.json']:
 p=E/n
 if p.is_file():
  b=p.read_bytes();o['files'][n]={'sha256':hashlib.sha256(b).hexdigest(),'data':json.loads(b)}
p=E/'query.log'
if p.is_file():
 with p.open('rb') as f:f.seek(max(0,p.stat().st_size-14000));o['log_tail']=f.read().decode(errors='replace')
 o['log_bytes']=p.stat().st_size
if 'native-process.json' in o['files']:
 pid=o['files']['native-process.json']['data']['pid']
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   st=(p/'stat').read_text();fs=st[st.rfind(')')+2:].split()
   if int(fs[2])==pid and fs[0]!='Z':o['live_group'].append({'pid':int(p.name),'state':fs[0],'ppid':int(fs[1]),'start':fs[19],'argv':(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(),'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd')})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
raw=json.dumps(o,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_clock_trial02_status01','-'],input=raw,check=True);print('TRIAL02_STATUS01_COMPLETE',hashlib.sha256(raw).hexdigest(),flush=True)
