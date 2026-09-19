"""Exclusive header-only runner. Requires independently issued exact record."""
from pathlib import Path
import os,sys,json,socket,subprocess,time,re
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_12';E=B/'qualification/fim-build-12'
sys.dont_write_bytecode=True
sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'))
import ia840f_header_gate as gate
def run():
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert Path.cwd()==gate.PROJECT and sys.argv==[''+str(E/'run_headers.py')]
 env=dict(os.environ)
 for k in list(env):
  if k.startswith('OFS_BUILD_TAG_') or k in ('SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL','BUILD_ROOT_REL_PRINTED'):env.pop(k)
 license='/home/uwb_student00/quartus_26/LR-191011_License.dat'
 env.update(OFS_ROOTDIR=str(W),OFS_PLATFORM_AFU_BBB=str(gate.common.PIM),QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',LM_LICENSE_FILE=license,MGLS_LICENSE_FILE=license,SALT_LICENSE_SERVER=license,PYTHONDONTWRITEBYTECODE='1')
 os.environ.clear();os.environ.update(env)
 # No writes or vendor process before exact record and all current inputs pass.
 gate.environment();record=gate.load_record()
 assert gate.work_inventory()==record['work_inventory']
 assert not any((W/p).exists() for p in record['required_outputs'])
 assert gate.common.process(os.getpid())==(gate.PYTHON_EXE,gate.TOP_ARGS,str(gate.PROJECT))
 run=E/'header-run';run.mkdir()
 started=time.time_ns();state=dict(ready_for_build=False,header_native_started=False,started_ns=started)
 def save(name,data):
  with (run/name).open('x') as f:json.dump(data,f,indent=2)
 save('claim.json',dict(pid=os.getpid(),start_time=gate.start_time(os.getpid()),record_sha256=gate.sha(gate.RECORD)))
 cmd=[record['tools']['quartus_sh']['path']]+gate.HEADER_ARGS[1:]
 save('invocation.json',dict(argv=cmd,cwd=str(gate.PROJECT),environment=env,started_ns=started))
 try:
  with (run/'native.log').open('xb') as log:
   state['header_native_started']=True
   rc=subprocess.run(cmd,cwd=gate.PROJECT,env=env,stdout=log,stderr=subprocess.STDOUT).returncode
   # Persist the child status before even closing its log or doing postflight.
   state.update(native_returncode=rc,native_exit_accepted=False,result_review_required=True,compile_authorized=False)
   save('native-status.json',state)
  errors=[];state['collection_errors']=errors
  def collect(label,fn):
   try:return fn()
   except Exception as exc:
    errors.append(dict(stage=label,error=repr(exc)))
    return None
  text=collect('diagnostics',lambda:(run/'native.log').read_text(errors='replace'))
  rejected=None if text is None else any((m.decode() if isinstance(m,bytes) else m) in text for m in gate.common.REJECTION_MARKERS)
  diagnostics=None if text is None else bool(re.search(r'\b(?:error|fatal)(?:\s*\([^\n)]*\))?\s*:',text,re.I)) or 'Critical Warning' in text
  outputs={}
  for p in record['required_outputs']:
   item={};outputs[p]=item
   digest=collect('output hash: '+p,lambda:gate.sha(W/p))
   if digest is not None:item['sha256']=digest
   st=collect('output stat: '+p,lambda:(W/p).stat())
   if st is not None:item.update(bytes=st.st_size,mtime_ns=st.st_mtime_ns)
  complete=all(set(v)=={'sha256','bytes','mtime_ns'} and v['bytes']>0 and v['mtime_ns']>=started for v in outputs.values())
  collect('outputs persistence',lambda:save('outputs.json',outputs))
  collect('postflight verification',gate.load_record)
  inventory=collect('postheader inventory',gate.work_inventory)
  if inventory is None:
   # Retain available entries even when strict inventory rejects one entry.
   inventory={}
   def entry(p):
    rel=p.relative_to(W).as_posix()
    if p.is_symlink():inventory[rel]={'symlink':os.readlink(p)}
    elif p.is_file():inventory[rel]={'sha256':gate.sha(p)}
   def walk_error(exc):errors.append(dict(stage='inventory walk',error=repr(exc)))
   for directory,dirs,files in os.walk(W,onerror=walk_error,followlinks=False):
    dirs[:]=[d for d in dirs if d!='__pycache__']
    for name in dirs+files:
     p=Path(directory)/name
     if p.suffix!='.pyc':collect('inventory entry: '+str(p.relative_to(W)),lambda:entry(p))
  collect('inventory persistence',lambda:save('postheader-work-inventory.json',inventory))
  ok=rc==0 and not errors and rejected is False and diagnostics is False and complete
  state.update(gate_rejection=rejected,reject_diagnostics=diagnostics,outputs_complete_fresh=complete,native_exit_accepted=ok)
  if errors:save('failure.json',state)
  save('result.json',state)
  return (128-rc if rc<0 else rc) if rc else (0 if ok else 1)
 except BaseException as exc:
  state.update(error=repr(exc),native_exit_accepted=False,compile_authorized=False)
  try:save('failure.json',state)
  except Exception as evidence_exc:print('failure evidence persistence:',repr(evidence_exc),file=sys.stderr)
  if 'native_returncode' in state:
   rc=state['native_returncode']
   return (128-rc if rc<0 else rc) if rc else 1
  raise
if __name__=='__main__':sys.exit(run())
