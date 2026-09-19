from pathlib import Path
import json,os,sys,subprocess,hashlib,datetime,re,base64
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';R=E/'compile-execution-01';S=B/'ofs-agx7-pcie-attach';P=B/'work_ia840f_fim_12/syn/board/ia840f/syn_top'
sys.path.insert(0,str(S/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as g
record=json.loads(g.RECORD.read_text());status=json.loads((E/'run/status.json').read_text());claim=json.loads(g.CLAIM.read_text())
result=dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),status=status,claim=claim,own_pane=os.environ['TMUX_PANE'],launch_pane=subprocess.check_output(['tmux','display-message','-t','%483','-p','#S #{window_id} #{pane_id} #{pane_current_command}'],text=True).strip(),identities=[],read_errors=[],diagnostics=[],stage_progress=[],readiness=False)
for pid in (status['runner_pid'],status['native_pid'],176885,176918):
 try:
  exe,argv,cwd=g.common.process(pid);identity=dict(pid=pid,ppid=g.parent(pid),start_ticks=g.start_time(pid),exe=exe,argv=argv,cwd=cwd)
  if pid in (176885,176918):g.check_context(record,exe,argv,cwd);identity['exact_context_hash_verified']=True
  chain=[];cur=pid
  for _ in range(32):
   chain.append(cur)
   if cur<=1:break
   cur=g.parent(cur)
  identity['ancestry']=chain;result['identities'].append(identity)
 except Exception as e:result['read_errors'].append(dict(pid=pid,error=repr(e)))
exports={}
paths=[E/'run/native.log',E/'run/status.json',E/'run/native-status.json',R/'runner.log',R/'runner-returncode.json']+[p for p in P.rglob('*') if p.is_file() and p.suffix in ('.rpt','.summary','.log')]
for p in paths:
 if not p.exists():continue
 try:
  b=p.read_bytes();text=b.decode(errors='replace');exports[str(p)]=dict(sha256=hashlib.sha256(b).hexdigest(),bytes=len(b),base64=base64.b64encode(b).decode())
  result['diagnostics'] += [dict(path=str(p),line=line) for line in text.splitlines() if re.search(r'Critical Warning.*125091|\b(?:error|fatal)(?:\s*\([^)]*\))?\s*:|Error\s*\(\d+\)',line,re.I) or any(m.decode() in line for m in g.common.REJECTION_MARKERS)]
  result['stage_progress'] += [dict(path=str(p),line=line[:400]) for line in text.splitlines() if re.search(r'was successful|Running Quartus|Processing started|Processing ended|Synthesis Status|Flow Status',line)][-12:]
 except Exception as e:result['read_errors'].append(dict(path=str(p),error=repr(e)))
with (R/'handoff-final-check.json').open('x') as f:json.dump(result,f,indent=2)
b=(R/'handoff-final-check.json').read_bytes();exports[str(R/'handoff-final-check.json')]=dict(sha256=hashlib.sha256(b).hexdigest(),bytes=len(b),base64=base64.b64encode(b).decode())
bundle=json.dumps(dict(batch='work12-final-check-01',files=exports)).encode();subprocess.run(['tmux','load-buffer','-b','w12ce01-finalcheck01','-'],input=bundle,check=True)
print(json.dumps(result,indent=2));print('EXPORT',len(exports),hashlib.sha256(bundle).hexdigest())
