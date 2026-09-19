import os,pathlib,json,hashlib,base64,datetime,subprocess,re,socket
E=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-07')
W=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_07')
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
stamp=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')
D=E/('monitor-'+stamp);D.mkdir()
procs=[]
for p in pathlib.Path('/proc').glob('[0-9]*'):
 try:
  argv=(p/'cmdline').read_bytes().decode().strip('\0').split('\0');cwd=os.readlink(p/'cwd');stat=(p/'stat').read_text();s=stat[stat.rfind(')')+2:].split()
  if (str(W) in cwd or str(E) in ' '.join(argv) or p.name in ['104427','104429','104446','104566']) and int(p.name)!=os.getpid():
   procs.append(dict(pid=int(p.name),ppid=int(s[1]),starttime_ticks=int(s[19]),exe=os.readlink(p/'exe'),cwd=cwd,argv=argv,stat=stat))
 except (OSError,UnicodeError):pass
paths=[E/'run/status.json',E/'run/native.log',E/'run/invocation.json',E/'compile-authorization.json']
P=W/'syn/board/ia840f/syn_top'
for p in P.rglob('*'):
 if p.is_file() and (p.suffix in ['.rpt','.summary','.smsg','.sof','.rbf','.jic'] or p.name.endswith('timing.json')) and 'qdb' not in p.parts:paths.append(p)
files={};inventory=[]
for i,p in enumerate(sorted(set(paths))):
 b=p.read_bytes();h=hashlib.sha256(b).hexdigest();name=str(i)+'--'+p.name
 inventory.append(dict(path=str(p),size=len(b),sha256=h,mtime=p.stat().st_mtime,snapshot=name))
 if p.suffix not in ['.sof','.rbf','.jic']:
  (D/name).write_bytes(b);files[name]=base64.b64encode(b).decode()
log=(E/'run/native.log').read_text(errors='replace').splitlines()
pattern=re.compile(r'Command:|Processing (started|ended)|was successful|was unsuccessful|Error \(|Critical Warning|125091|gate.*(reject|fail)|authorization.*(reject|fail)|Design Assistant|Fitter.*(Stage|successful)|Flow Status',re.I)
matches=[{'line':i+1,'text':t} for i,t in enumerate(log) if pattern.search(t)]
r=dict(observed_utc=stamp,host=socket.gethostname(),uid=os.getuid(),remote_dir=str(D),processes=procs,inventory=inventory,runner_status=json.loads((E/'run/status.json').read_text()),milestones=matches,log_tail=log[-45:])
(D/'report.json').write_text(json.dumps(r,indent=2));files['report.json']=base64.b64encode((D/'report.json').read_bytes()).decode()
payload=json.dumps(dict(files=files,hashes={n:hashlib.sha256(base64.b64decode(b)).hexdigest() for n,b in files.items()})).encode()
(D/'payload.json').write_bytes(payload)
subprocess.run(['tmux','load-buffer','-b','work07-monitor-payload',str(D/'payload.json')],check=True)
print('PAYLOAD_SHA256',hashlib.sha256(payload).hexdigest(),flush=True)
print('REMOTE_DIR',D,flush=True)
print('OBSERVED',stamp,'STATUS',r['runner_status'],flush=True)
print('PROCESSES',json.dumps(procs),flush=True)
print('MILESTONES',json.dumps(matches[-25:]),flush=True)
