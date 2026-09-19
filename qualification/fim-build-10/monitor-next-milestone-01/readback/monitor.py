from pathlib import Path
import os,json,hashlib,datetime,time,re,subprocess,base64,zlib,socket
B=Path('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim-build-10'; W=B/'work_ia840f_fim_10'; O=E/'monitor-next-milestone-01'
O.mkdir(exist_ok=False)
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
sha=lambda b:hashlib.sha256(b).hexdigest()
(O/'monitor.py').write_bytes(__source)
expected={140682:8387716,140684:8387852,140702:8388162}
patterns={'error':r'\bError\s*(?:\([^\n)]*\))?\s*:', 'fatal':r'\bFatal\s*(?:\([^\n)]*\))?\s*:', 'critical_warning_125091':r'Critical Warning\s*\(125091\)', 'IA840F_GATE_REJECTED':r'IA840F_GATE_REJECTED','IA840F_NOT_READY':r'IA840F NOT READY','IA840F_EXPERIMENTAL_GATE':r'IA840F EXPERIMENTAL GATE:'}
samples=[]; initial=None; stop=time.monotonic()+240

def capture():
 rows={}
 for p in Path('/proc').glob('[0-9]*'):
  try:
   stat=(p/'stat').read_text().rsplit(')',1)[1].split();pid=int(p.name)
   rows[pid]={'pid':pid,'ppid':int(stat[1]),'start_ticks':int(stat[19]),'utime':int(stat[11]),'stime':int(stat[12]),'state':stat[0]}
  except OSError:pass
 selected=set(expected)
 for pid in list(rows):
  cur=pid;seen=set()
  while cur in rows and cur not in seen:
   seen.add(cur)
   if cur==140682:selected.add(pid);break
   cur=rows[cur]['ppid']
 procs=[]
 for pid in sorted(selected):
  if pid not in rows:continue
  p=Path('/proc')/str(pid);r=rows[pid]
  try:r.update(exe=os.readlink(p/'exe'),argv=[x.decode(errors='replace') for x in (p/'cmdline').read_bytes().split(b'\0') if x],cwd=os.readlink(p/'cwd'),exe_sha256=sha((p/'exe').read_bytes()))
  except OSError:r['read_race']=True
  procs.append(r)
 files={}; milestones=[]; counts={k:0 for k in patterns}; texts={}
 paths=sorted(set(list(W.glob('syn/board/ia840f/syn_top/output_files/*.rpt'))+list(W.glob('syn/board/ia840f/syn_top/output_files/*.summary'))+[E/'run/native.log',E/'run/status.json']))
 for p in paths:
  if not p.is_file():continue
  data=p.read_bytes();text=data.decode(errors='replace');rel=str(p.relative_to(B));texts[rel]=data
  localcounts={k:len(re.findall(v,text,re.I)) for k,v in patterns.items()}
  for k,v in localcounts.items():counts[k]+=v
  marks=[line.strip() for line in text.splitlines() if re.search(r'(Synthesis|Fitter|Plan|Place|Route|Assembler|Timing Analyzer).*successful|Flow Status|Synthesis Status|Fitter Status|Assembler Status',line,re.I)]
  milestones.extend((rel+': '+x) for x in marks)
  files[rel]={'size':len(data),'sha256':sha(data),'mtime_ns':p.stat().st_mtime_ns,'diagnostics':localcounts,'milestones':marks}
 sample={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'host':socket.gethostname(),'uid':os.getuid(),'processes':procs,'expected_identity_matches':{str(pid):rows.get(pid,{}).get('start_ticks')==ticks for pid,ticks in expected.items()},'files':files,'diagnostics_occurrences_across_files':counts,'milestones':milestones,'status':json.loads((E/'run/status.json').read_text()),'ready_for_build':False,'timing_acceptance':False,'functional_acceptance':False}
 return sample,texts
while True:
 sample,texts=capture();samples.append(sample)
 with (O/'samples.jsonl').open('a') as f:f.write(json.dumps(sample,sort_keys=True)+'\n')
 active=[(p['pid'],Path(p.get('exe','')).name,p['utime']+p['stime']) for p in sample['processes']]
 print(json.dumps({'sample':len(samples),'utc':sample['utc'],'processes':active,'milestones':sample['milestones'],'diagnostics':sample['diagnostics_occurrences_across_files']}),flush=True)
 current=set(sample['milestones'])
 if initial is None:initial=current
 elif current-initial:reason='new report milestone';break
 if sample['status'].get('state')!='running':reason='native status changed';break
 if time.monotonic()>=stop:reason='bounded observation elapsed';break
 time.sleep(min(30,max(0,stop-time.monotonic())))
# Export one final snapshot, not repeated report bodies.
for rel,data in texts.items():
 p=O/'snapshot'/rel;p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('xb') as f:f.write(data)
images=[]
for p in W.glob('syn/board/ia840f/syn_top/output_files/*'):
 if p.suffix.lower() in ['.sof','.rbf','.pmsf','.msf'] and p.is_file():images.append({'path':str(p),'size':p.stat().st_size,'sha256':sha(p.read_bytes())})
result={'reason':reason,'sample_count':len(samples),'first_utc':samples[0]['utc'],'last_utc':samples[-1]['utc'],'new_milestones':sorted(set(samples[-1]['milestones'])-initial),'images':images,'ready_for_build':False,'timing_acceptance':False,'functional_acceptance':False,'note':'Read-only observation of WORK/SOURCE; diagnostic counts are occurrences across files, not deduplicated. No native exit or quiet log establishes timing acceptance.'}
(O/'result.json').write_text(json.dumps(result,indent=2)+'\n')
payload={str(p.relative_to(O)):{'size':p.stat().st_size,'sha256':sha(p.read_bytes()),'base64':base64.b64encode(p.read_bytes()).decode()} for p in O.rglob('*') if p.is_file()}
blob=zlib.compress(json.dumps({'batch':'monitor-next-milestone-01','files':payload}).encode());out=O/'export.json.zlib'
with out.open('xb') as f:f.write(blob)
buffer='work10-milestone-01-'+str(os.getpid());subprocess.run(['tmux','load-buffer','-b',buffer,str(out)],check=True)
print('EXPORT '+json.dumps({'buffer':buffer,'size':len(blob),'sha256':sha(blob),'result':result}),flush=True)
