import os,sys,time,json,hashlib,socket,subprocess,re,base64,io,tarfile
from pathlib import Path
from datetime import datetime,timezone
NAME='monitor-20260919T175342Z'
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12')
W=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12')
D=E/NAME
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert os.environ.get('TMUX')
D.mkdir(parents=True,exist_ok=True)
assert not (D/'identity.json').exists(),'batch dir already consumed'
def now(): return datetime.now(timezone.utc).isoformat()
def save(p,data):
 with p.open('x') as f: json.dump(data,f,indent=2)
def sha(b): return hashlib.sha256(b).hexdigest()
(D/'monitor.py').write_bytes(base64.b64decode(os.environ['MONITOR_SCRIPT']))
save(D/'identity.json',{'time':now(),'host':socket.gethostname(),'uid':os.getuid(),'tmux':os.environ['TMUX'],'pane':os.environ.get('TMUX_PANE'),'argv':sys.argv})
markers=['IA840F_GATE_REJECTED','IA840F NOT READY','IA840F EXPERIMENTAL GATE:','125091']
expected={176866:10610226,176868:10610365,176885:10610686,176918:10611622}
SMSG_ERR=re.compile(r'^\s*Error\s*\(\d+\)|\b(?:Error|Fatal)(?:\s*\([^)]*\))?\s*:',re.I)
diag=re.compile(r'periphery placement|preparation|physical synthesis|router|routing|Early|Global|Final|Optimizer|Fitter|synthesiz|Embarking|Supernode|writing|image|SOF|RBF|stamp|checksum|Elapsed time|successful|unsuccessful|completed|ended|finished|started|Starting',re.I)
def processes():
 rows={}
 for p in Path('/proc').iterdir():
  if not p.name.isdigit(): continue
  try:
   s=(p/'stat').read_text().rsplit(')',1)[1].split(); argv=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace'); cwd=os.readlink(p/'cwd'); exe=os.readlink(p/'exe')
   rows[int(p.name)]={'pid':int(p.name),'ppid':int(s[1]),'state':s[0],'start_ticks':int(s[19]),'cpu_ticks':int(s[11])+int(s[12]),'argv':argv,'cwd':cwd,'exe':exe}
  except (OSError,ValueError): pass
 selected={k:v for k,v in rows.items() if k in expected or str(W) in v['cwd'] or ('quartus' in v['exe'] and '/opt/' in v['exe'])}
 for k in list(selected):
  p=selected[k]['ppid']; seen=set()
  while p in rows and p not in seen:
   seen.add(p); selected[p]=rows[p]; p=rows[p]['ppid']
 for k,v in selected.items():
  if k in expected:v['handoff_start_ticks_match']=v['start_ticks']==expected[k]
 return list(selected.values())
last=None
for i in range(4):
 stamp=now(); status=json.loads((E/'run/status.json').read_text()); procs=processes()
 # STA progress only while running; never re-read giant STA after completion signal.
 sta=W/'syn/board/ia840f/syn_top/output_files/ofs_top.sta.rpt'
 files={}; totals={m:0 for m in markers}; milestones=[]
 watch=[E/'run/native.log',E/'run/native-status.json',E/'compile-execution-01/runner-returncode.json']+sorted(set(list(W.rglob('*.rpt'))+list(W.rglob('*.summary'))+list(W.rglob('*.log'))+list(W.rglob('*.smsg'))))
 if (not (E/'run/native-status.json').exists()) and sta.is_file():
  st_size=sta.stat().st_size
  with sta.open('rb') as f: b=f.read(min(st_size,262144))
  text=b.decode(errors='replace')
  lines=[l for l in text.splitlines() if diag.search(l)]
  if lines: milestones.append({'file':'sta.head','lines':lines[-25:]})
  files[str(sta)]={'bytes':st_size,'sha256':sha(b),'partial_head_only':True}
 for p in watch:
  if not p.is_file():continue
  stt=p.stat()
  if stt.st_size>8*1024*1024:
   with p.open('rb') as f: b=f.read(524288)
   text=b.decode(errors='replace'); hits={m:text.count(m) for m in markers}
   for m in markers:totals[m]+=hits[m]
   errors=[l for l in text.splitlines() if SMSG_ERR.search(l)]
   files[str(p)]={'bytes':stt.st_size,'sha256_head512k':sha(b),'mtime_ns':stt.st_mtime_ns,'markers_head':hits,'error_diagnostic_lines_head':len(errors),'partial_head_only':True}
   continue
  b=p.read_bytes(); text=b.decode(errors='replace'); st=p.stat(); hits={m:text.count(m) for m in markers}
  for m in markers:totals[m]+=hits[m]
  errors=[l for l in text.splitlines() if SMSG_ERR.search(l)]
  files[str(p)]={'bytes':len(b),'sha256':sha(b),'mtime_ns':stt.st_mtime_ns,'markers':hits,'error_diagnostic_lines':len(errors),'error_excerpt':errors[:15]}
  if p.name=='native.log' or 'output_files' in p.parts:
   lines=[l for l in text.splitlines() if diag.search(l) and not re.search(r'Inferred|State machine|File:|Info: Found',l)]
   if lines:milestones.append({'file':str(p),'lines':lines[-30:]})
 inventory=[]
 out=W/'syn/board/ia840f/syn_top/output_files'
 if out.exists():
  for p in sorted(out.iterdir()):
   if p.is_file():inventory.append({'path':str(p),'bytes':p.stat().st_size,'mtime_ns':p.stat().st_mtime_ns})
 last={'time':stamp,'status':status,'processes':procs,'files':files,'marker_totals':totals,'milestones':milestones,'output_inventory':inventory}
 save(D/('snapshot-%02d.json'%i),last)
 print(json.dumps({'time':stamp,'sample':i,'status':status,'markers':totals,'quartus_procs':len([v for v in procs if 'quartus' in v['exe']]),'native_tasks':[{k:v[k] for k in ('pid','start_ticks','cpu_ticks','exe')} for v in procs if 'quartus' in v['exe']],'milestones':milestones[-5:]}),flush=True)
 if status.get('state')!='running':break
 if i<3:time.sleep(75)
completed=last is not None and last['status'].get('state')!='running'
if completed:
 # Immutable final capture: full STA copied once into evidence dir, then hashed locally to D.
 C=D/'captured';C.mkdir()
 for p in [E/'run/status.json',E/'run/native-status.json',E/'run/invocation.json',E/'run/native.log',E/'native-compile.claim.json',E/'compile-execution-01/runner-returncode.json',E/'compile-execution-01/runner-command.json']+sorted((W/'syn/board/ia840f/syn_top/output_files').glob('*')):
  if p.is_file() and (p.suffix in ['.json','.log','.rpt','.summary','.smsg']):
   q=C/('evidence' if E in p.parents else 'output_files')/p.name;q.parent.mkdir(exist_ok=True);q.write_bytes(p.read_bytes())
 images=[]
 for p in sorted(W.rglob('*')):
  if p.is_file() and p.suffix.lower() in ['.sof','.rbf','.pmsf','.msf']:
   h=hashlib.sha256()
   with p.open('rb') as f:
    for b in iter(lambda:f.read(1048576),b''):h.update(b)
   images.append({'path':str(p),'bytes':p.stat().st_size,'sha256':h.hexdigest()})
 save(D/'images.json',images)
else:
 save(D/'still-running.json',{'time':now(),'note':'bounded monitor ended with native still running; see snapshots for progress'})
manifest={str(p.relative_to(D)):{'bytes':p.stat().st_size,'sha256':sha(p.read_bytes())} for p in sorted(D.rglob('*')) if p.is_file()}
save(D/'manifest.json',manifest)
buf=io.BytesIO()
with tarfile.open(fileobj=buf,mode='w:gz') as t:
 for p in sorted(D.rglob('*')):
  if p.is_file():t.add(p,arcname=str(p.relative_to(D)))
b=buf.getvalue(); payload=json.dumps({'batch':NAME,'archive_sha256':sha(b),'archive_bytes':len(b),'archive_base64':base64.b64encode(b).decode()}).encode()
subprocess.run(['tmux','load-buffer','-b',NAME+'-export','-'],input=payload,check=True)
print('MONITOR_EXPORT_READY '+NAME+' '+sha(b),flush=True)
