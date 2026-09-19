"""Persistent single-use native FIM runner. No wall-clock watchdog.
Run only inside ia840f_mailbox_monitored_01 after independent review consumption.
"""
import datetime, hashlib, json, os, socket, subprocess, sys
from pathlib import Path
N=Path('/home/uwb_student00/ahls/new_BSP');C=N/'ofs-agx7-pcie-attach';E=N/'qualification/fim-build-13';W=N/'work_ia840f_fim_13'
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def run():
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
 assert os.environ.get('TMUX') and subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 # Explicit current instructions; no shell startup file and no simulator use.
 env=dict(os.environ)
 for key in list(env):
  if key.startswith('OFS_BUILD_TAG_') or key in ('SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL','BUILD_ROOT_REL_PRINTED'):
   env.pop(key,None)
 license='/home/uwb_student00/quartus_26/LR-191011_License.dat'
 env.update(OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(N/'ofs-platform-afu-bbb'),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',
            QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',
            LM_LICENSE_FILE=license,MGLS_LICENSE_FILE=license,SALT_LICENSE_SERVER=license,PYTHONDONTWRITEBYTECODE='1')
 os.environ.clear();os.environ.update(env)
 sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate
 record=gate.load_record();gate.environment()
 assert gate.work_inventory()==record['work_inventory']
 assert not gate.CLAIM.exists()
 run_dir=E/'run';run_dir.mkdir() # exclusive; rejected rerun cannot overwrite evidence
 state=dict(state='starting',started=now(),runner_pid=os.getpid(),argv=gate.TOP_ARGS,cwd=str(C),
            authorization_sha256=gate.sha(gate.RECORD),ready_for_build=False,accepted_execution=True,
            ddr_simulation='SKIPPED BY USER',functional_acceptance=False)
 status=run_dir/'status.json';status.write_text(json.dumps(state,indent=2))
 with (run_dir/'invocation.json').open('x') as f:json.dump(dict(state,environment={k:env[k] for k in ('OFS_ROOTDIR','OFS_PLATFORM_AFU_BBB','QUARTUS_ROOTDIR_OVERRIDE','PATH','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER')}),f,indent=2)
 try:
  with (run_dir/'native.log').open('xb') as log:
   p=subprocess.Popen(gate.TOP_ARGS,cwd=C,env=env,stdout=log,stderr=subprocess.STDOUT)
   state.update(state='running',native_pid=p.pid);status.write_text(json.dumps(state,indent=2))
   rc=p.wait()
  # Persist raw native status before fallible diagnostics collection.
  with (run_dir/'native-status.json').open('x') as f:json.dump(dict(native_returncode=rc,ended=now()),f,indent=2)
  data=(run_dir/'native.log').read_bytes()
  rejected=any(m in data for m in gate.common.REJECTION_MARKERS)
  state.update(state='finished',ended=now(),native_returncode=rc,gate_rejection=rejected,
               native_exit_accepted=rc==0 and not rejected,
               compile_fit_assembly_timing_acceptance='PENDING REPORT REVIEW',functional_acceptance=False)
  status.write_text(json.dumps(state,indent=2))
  print(json.dumps(state,indent=2))
  return (128-rc if rc<0 else rc) if rc else (1 if rejected else 0)
 except BaseException as exc:
  state.update(state='runner-error',error=repr(exc),ended=now())
  try:status.write_text(json.dumps(state,indent=2))
  except OSError:pass
  if 'rc' in locals():return (128-rc if rc<0 else rc) if rc else 1
  raise
if __name__=='__main__':sys.exit(run())
