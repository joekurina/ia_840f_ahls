from pathlib import Path
import os,json,hashlib,datetime,subprocess,sys,base64,re
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';C=E/'compile-candidate-01';R=E/'compile-execution-01';S=B/'ofs-agx7-pcie-attach';W=B/'work_ia840f_fim_12';P=W/'syn/board/ia840f/syn_top'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sys.path.insert(0,str(S/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate
result=dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),tmux=subprocess.check_output(['tmux','display-message','-p','#S #{window_id} #{pane_id}'],text=True).strip(),readiness=False)
a=json.loads((E/'compile-authorization.json').read_text())
result['source_preserved']={t:gate.common.inventory(S/t) for t in gate.common.TREES}==a['source_sha256'];result['pim_preserved']=gate.common.inventory(gate.common.PIM)==a['pim_sha256']
m=json.loads((C/'review-package-sha256.json').read_text());result['frozen_payloads_preserved']=all(sha(C/p)==h for p,h in m.items())
result['status']=json.loads((E/'run/status.json').read_text()) if (E/'run/status.json').exists() else None
result['claim']=json.loads(gate.CLAIM.read_text()) if gate.CLAIM.exists() else None
procs={}
for q in Path('/proc').glob('[0-9]*'):
 try:
  exe,argv,cwd=gate.common.process(int(q.name));ppid=gate.parent(int(q.name));ticks=gate.start_time(int(q.name))
  procs[int(q.name)]=dict(pid=int(q.name),ppid=ppid,start_ticks=ticks,exe=exe,argv=argv,cwd=cwd)
 except (OSError,ValueError,IndexError,StopIteration):pass
selected=set()
if result['status']:
 for k in ('runner_pid','native_pid'):
  if k in result['status']:selected.add(result['status'][k])
for _ in range(20):selected.update(p for p,v in procs.items() if v['ppid'] in selected)
result['processes']=[procs[p] for p in sorted(selected) if p in procs]
if result['claim']:
 cl=result['claim'];p=procs.get(cl['pid']);result['native_verified']=bool(p and p['start_ticks']==cl['start_time'] and p['exe']=='/usr/bin/bash' and p['argv'] in [gate.TOP_ARGS,['bash']+gate.TOP_ARGS,['/bin/bash']+gate.TOP_ARGS] and p['cwd']==str(S) and cl['record_sha256']==sha(gate.RECORD))
result['stage_files']=[];exports={}
def add(path):
 data=path.read_bytes();exports[str(path)]=dict(sha256=hashlib.sha256(data).hexdigest(),bytes=len(data),base64=base64.b64encode(data).decode())
for p in sorted(P.rglob('*')):
 if p.is_file() and p.suffix in ('.rpt','.summary','.log'):
  st=p.stat();data=p.read_bytes();text=data.decode(errors='replace');lines=text.splitlines()
  diagnostics=[x for x in lines if re.search(r'Critical Warning.*125091|\b(?:error|fatal)(?:\s*\([^)]*\))?\s*:|Error\s*\(\d+\)|IA840F.*REJECT',x,re.I)]
  result['stage_files'].append(dict(path=str(p),bytes=len(data),mtime=st.st_mtime,sha256=hashlib.sha256(data).hexdigest(),diagnostics=diagnostics[-30:],tail=lines[-12:]))
  add(p)
for p in [E/'run/native.log',R/'runner.log']:
 if p.exists():
  data=p.read_bytes();text=data.decode(errors='replace');result[p.name]=dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),tail=text.splitlines()[-45:],gate_markers=[m.decode(errors='replace') for m in gate.common.REJECTION_MARKERS if m in data])
for p in list(R.rglob('*'))+[E/'compile-authorization.json',gate.CLAIM,C/'consumed-reviews.json']+list((E/'run').glob('*')):
 if p.is_file():add(p)
result['hashes']={p:v['sha256'] for p,v in exports.items()}
with (R/'snapshot-01.json').open('x') as f:json.dump(result,f,indent=2)
add(R/'snapshot-01.json')
bundle=json.dumps(dict(batch='work12-compile-execution-01-snapshot-01',files=exports)).encode()
subprocess.run(['tmux','load-buffer','-b','w12ce01-evidence-snapshot01','-'],input=bundle,check=True)
print(json.dumps(result,indent=2),flush=True)
print('EXPORT',len(exports),hashlib.sha256(bundle).hexdigest(),flush=True)
