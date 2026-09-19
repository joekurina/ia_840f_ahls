import os, sys, time, json, re, socket, hashlib, subprocess, pathlib, datetime, io, tarfile, base64
P=pathlib.Path
B=P('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim-build-09'; W=B/'work_ia840f_fim_09'
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
D=E/('monitor-'+stamp); D.mkdir(exist_ok=False)
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
(D/'monitor.py').write_text(os.environ['MONITOR_SOURCE'])
(D/'invocation.json').write_text(json.dumps({'argv':sys.argv,'cwd':os.getcwd(),'host':socket.gethostname(),'uid':os.getuid(),'tmux':os.environ.get('TMUX'),'scope':'read-only Work09 monitoring; writes exclusively to this evidence directory','sample_interval_seconds':30,'maximum_seconds':300},indent=2))
out=W/'syn/board/ia840f/syn_top/output_files'
rx=re.compile(r'IA840F_[A-Z_]*REJECTED|Critical Warning\s*\(125091\)|\b(?:Error|Fatal)(?:\s*\([^\n)]*\))?\s*:',re.I)
exe_hash={}
def sample(n):
 s={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'processes':[],'files':[],'diagnostics':[],'status':None}
 procs={}
 for p in P('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   st=(p/'stat').read_text(); f=st[st.rfind(')')+2:].split(); argv=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace'); procs[int(p.name)]=(p,f,argv)
  except (OSError,ProcessLookupError):pass
 selected={124991,125051,125068,126976}
 for _ in range(8):
  selected.update(pid for pid,(_,f,_) in procs.items() if int(f[1]) in selected)
 for pid in sorted(selected):
  if pid not in procs:continue
  p,f,argv=procs[pid]
  try:
   exe=os.readlink(p/'exe'); cwd=os.readlink(p/'cwd')
   if exe not in exe_hash:exe_hash[exe]=hashlib.sha256(P(exe).read_bytes()).hexdigest()
   s['processes'].append({'pid':pid,'ppid':int(f[1]),'state':f[0],'start_ticks':int(f[19]),'cpu_ticks':int(f[11])+int(f[12]),'exe':exe,'exe_sha256':exe_hash[exe],'cwd':cwd,'argv':argv})
  except OSError:pass
 sd=D/('sample-%02d'%n);sd.mkdir()
 files=[E/'run/native.log',E/'run/status.json',E/'run/invocation.json',E/'runner-console.log']
 files+=sorted(p for p in out.glob('*') if p.is_file() and p.suffix in ['.rpt','.summary','.log'])
 for p in files:
  if not p.exists():continue
  data=p.read_bytes(); stat=p.stat(); rel=str(p.relative_to(B)); dest=sd/rel;dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data)
  text=data.decode(errors='replace'); matches=[{'line':i,'text':line} for i,line in enumerate(text.splitlines(),1) if rx.search(line)]
  s['files'].append({'path':str(p),'size':len(data),'mtime_ns':stat.st_mtime_ns,'sha256':hashlib.sha256(data).hexdigest(),'tail':text.splitlines()[-12:]})
  if matches:s['diagnostics'].append({'path':str(p),'matches':matches})
  if p==E/'run/status.json':s['status']=json.loads(text)
 (D/('sample-%02d.json'%n)).write_text(json.dumps(s,indent=2))
 brief={'utc':s['utc'],'pids':[(p['pid'],p['exe'].split('/')[-1],p['cpu_ticks']) for p in s['processes']],'diagnostic_files':len(s['diagnostics']),'reports':[P(f['path']).name for f in s['files']],'state':s['status'].get('state')}
 print(json.dumps(brief),flush=True)
 return s
samples=[]
for n in range(7):
 s=sample(n);samples.append(s)
 # Preserve two samples to distinguish a quiet buffered log from inactivity.
 if n>=1 and (s['diagnostics'] or s['status'].get('state')!='running' or any(('.fit.place.' in f['path'] or '.fit.route.' in f['path']) and f['path'].endswith(('.rpt','.summary')) for f in s['files'])):break
 if n<6:time.sleep(30)
summary={'evidence':str(D),'first_utc':samples[0]['utc'],'last_utc':samples[-1]['utc'],'samples':len(samples),'last_status':samples[-1]['status'],'last_processes':samples[-1]['processes'],'diagnostics':samples[-1]['diagnostics'],'readiness':False,'timing_acceptance':False,'ddr_simulation':'SKIPPED BY USER'}
(D/'summary.json').write_text(json.dumps(summary,indent=2))
manifest={str(p.relative_to(D)):{'size':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in D.rglob('*') if p.is_file()}
(D/'manifest.json').write_text(json.dumps(manifest,indent=2))
buf=io.BytesIO()
with tarfile.open(fileobj=buf,mode='w:gz') as tar:
 for p in sorted(D.rglob('*')):
  if p.is_file():tar.add(p,arcname=str(p.relative_to(D)),recursive=False)
data=buf.getvalue(); (D/'evidence.tar.gz').write_bytes(data)
transfer={'evidence':str(D),'buffer':'work09-'+stamp,'size':len(data),'sha256':hashlib.sha256(data).hexdigest()}
(D/'transfer.json').write_text(json.dumps(transfer,indent=2))
subprocess.run(['tmux','load-buffer','-b',transfer['buffer'],str(D/'evidence.tar.gz')],check=True)
print('TRANSFER '+json.dumps(transfer),flush=True)
