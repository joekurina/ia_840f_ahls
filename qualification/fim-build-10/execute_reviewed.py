from pathlib import Path
import os,sys,json,hashlib,socket,subprocess,datetime
N=Path('/home/uwb_student00/ahls/new_BSP');E=N/'qualification/fim-build-10';C=N/'ofs-agx7-pcie-attach';W=N/'work_ia840f_fim_10'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
os.chdir(E)
with (E/'execution-preflight.log').open('x') as log:
 sys.stdout=log;sys.stderr=log
 print(Path('/home/uwb_student00/quartus_26/instructions.md').read_text(),flush=True)
 for name in ['compile-authorization.json','native-compile.claim.json','authorization-issuance.lock','run']:assert not (E/name).exists(),name
 active=[]
 for p in Path('/proc').glob('[0-9]*'):
  try:
   exe=os.readlink(p/'exe');argv=(p/'cmdline').read_bytes().split(b'\0');args=[x.decode(errors='replace') for x in argv if x]
   if '/quartus/linux64/quartus_' in exe or (args and any(Path(x).name in ['build_top.sh','launch_native_compile.py'] for x in args)):active.append({'pid':p.name,'exe':exe,'argv':args})
  except (OSError,ProcessLookupError):pass
 assert not active,active
 reviews=json.loads((E/'consumed-reviews.json').read_text())
 for p,h in reviews['actual_reviews'].items():assert sha(E/p)==h,p
 for p,h in reviews['handoff_files'].items():assert sha(E/p)==h,p
 draft=json.loads((E/'compile-authorization.draft.json').read_text())
 sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate
 prior=json.loads((N/'qualification/fim-build-09/compile-authorization.json').read_text())
 for t in gate.common.TREES:gate.common.check_inventory(C/t,prior['source_sha256'][t])
 gate.common.check_inventory(gate.common.PIM,draft['pim_sha256'])
 assert gate.work_inventory()==draft['work_inventory']
 for p,h in draft['dependency_sha256'].items():assert sha(p)==h,p
 for table in ['tools','quartus_tools']:
  for tool in draft[table].values():assert sha(tool['path'])==tool['sha256']
 for context in {x['executable']:x for x in draft['contexts']}.values():assert sha(context['executable'])==context['sha256']
 with (E/'issuance-preflight.json').open('x') as f:json.dump({'verified':True,'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'full_source_baseline':'Work09 issued record','full_work_entries':len(draft['work_inventory']),'dependencies':len(draft['dependency_sha256']),'reviews':reviews['actual_reviews'],'consumed_sha256':sha(E/'consumed-reviews.json'),'no_active_compile':True,'ready_for_build':False},f,indent=2)
 print('FULL PREFLIGHT VERIFIED',flush=True)
 with (E/'issuance.log').open('xb') as out:subprocess.run([sys.executable,'issue_authorization.py',str(E/'consumed-reviews.json')],stdout=out,stderr=subprocess.STDOUT,check=True)
 auth=json.loads((E/'compile-authorization.json').read_text());assert auth['approved'] and auth['ready_for_build'] is False
 print('ISSUED',sha(E/'compile-authorization.json'),flush=True)
 with (E/'runner-console.log').open('xb') as out:
  rc=subprocess.call([sys.executable,'launch_native_compile.py'],stdout=out,stderr=subprocess.STDOUT)
 print('RUNNER EXIT',rc,flush=True)
 sys.exit(rc)
