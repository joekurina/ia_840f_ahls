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
  text=(run/'native.log').read_text(errors='replace')
  rejected=any((m.decode() if isinstance(m,bytes) else m) in text for m in gate.common.REJECTION_MARKERS)
  diagnostics=bool(re.search(r'\b(?:error|fatal)(?:\s*\([^\n)]*\))?\s*:',text,re.I)) or 'Critical Warning' in text
  outputs={p:dict(sha256=gate.sha(W/p),bytes=(W/p).stat().st_size,mtime_ns=(W/p).stat().st_mtime_ns) for p in record['required_outputs'] if (W/p).is_file()}
  complete=len(outputs)==len(record['required_outputs']) and all(v['bytes']>0 and v['mtime_ns']>=started for v in outputs.values())
  gate.load_record()
  save('outputs.json',outputs);save('postheader-work-inventory.json',gate.work_inventory())
  ok=rc==0 and not rejected and not diagnostics and complete
  state.update(native_returncode=rc,gate_rejection=rejected,reject_diagnostics=diagnostics,outputs_complete_fresh=complete,native_exit_accepted=ok,result_review_required=True,compile_authorized=False)
  save('result.json',state)
  return rc if rc else (0 if ok else 1)
 except BaseException as exc:
  state.update(error=repr(exc));save('failure.json',state);raise
if __name__=='__main__':sys.exit(run())
