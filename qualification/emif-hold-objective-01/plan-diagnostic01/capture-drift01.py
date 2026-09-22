from pathlib import Path
import json,os,socket,subprocess,hashlib,datetime
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01')
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
r=json.loads((E/'candidate.json').read_text());out={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'changed':{},'native_tools':[]}
for p,h in r['files'].items():
 q=Path(p)
 if not q.is_file():out['changed'][p]={'before':h,'after':None};continue
 hh=hashlib.sha256()
 with q.open('rb') as f:
  for b in iter(lambda:f.read(4194304),b''):hh.update(b)
 if hh.hexdigest()!=h:out['changed'][p]={'before':h,'after':hh.hexdigest(),'bytes':q.stat().st_size}
for line in subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True).splitlines()[1:]:
 a=line.split(None,3)
 if len(a)>=3 and a[2].startswith(('quartus_','qsys-')):out['native_tools'].append(line)
for n in ('native-result.json','execution-status.json','preservation-after.json'):
 if (E/n).is_file():out[n]=json.loads((E/n).read_text())
blob=json.dumps(out,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_emif_plan01_drift01','-'],input=blob,check=True);print('EMIF_PLAN_DRIFT01',hashlib.sha256(blob).hexdigest(),flush=True)
