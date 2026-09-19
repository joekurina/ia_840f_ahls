"""Prepare Work10 seed-only candidate; never issue or launch."""
from pathlib import Path
import base64,hashlib,json,subprocess,os,socket,difflib,sys
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';P=B/'qualification/fim-build-09';E=B/'qualification/fim-build-10';W=B/'work_ia840f_fim_10';OLD=B/'work_ia840f_ipgen_04'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
os.environ['PYTHONDONTWRITEBYTECODE']='1';sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
expected=json.loads((P/'overlay-sha256.json').read_text());q='syn/board/ia840f/syn_top/ofs_top.qsf'
assert {r:sha(C/r) for r in expected}==expected
assert sha(C/q)=='ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3'
for name,h in {'stage_remote.py':'f716f749dd0c56b64f21baaf7d48b537a2de7bf766ae02c2a41cf2d61fecff7a','prepare_handoff_remote.py':'63fce3200d39d1ea48af9352269883f803417eb0082fef20f125fa1faed05f9d','issue_authorization.py':'83c1fd4a165e9842e7b8c5d83548bd01378ae6c89411984ad5c3969fb9af7495','launch_native_compile.py':'205f0f407fcc5ac166b45c9e5a5da6aa468a254bf693027286b36027b98421c7','test_real_dispatch.py':'97cf21942082ce2a833431af55ed2f0214f473906908209c6de098a71170c1de'}.items():assert sha(P/name)==h
# Read-only historical verification, no compiled Work09 output is copied.
def inv(root):
 return {str(p.relative_to(root)):({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)}) for p in sorted(root.rglob('*')) if p.is_symlink() or p.is_file()}
assert inv(OLD)==json.loads((P/'work04-before.json').read_text())
prior=json.loads((P/'compile-authorization.json').read_text())
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'))
import ia840f_experimental_gate as common
source_before={t:common.inventory(C/t) for t in common.TREES}
assert source_before==prior['source_sha256'];assert common.inventory(common.PIM)==prior['pim_sha256']
for group in ['tools','quartus_tools']:
 for tool in prior[group].values():assert sha(tool['path'])==tool['sha256']
history_paths=[P/'native-compile.claim.json',P/'compile-authorization.json',P/'run/status.json',P/'run/native.log']
history={str(p):sha(p) for p in history_paths}
assert json.loads((P/'run/status.json').read_text())['state']=='finished'
def retarget(t):return t.replace('fim-build-09','fim-build-10').replace('work_ia840f_fim_09','work_ia840f_fim_10').replace('Work09','Work10')
over={};before={}
for r,h in expected.items():
 data=(C/r).read_bytes();before[r]=data
 if r.endswith(('ia840f_compile_gate.py','ia840f_experimental_gate.py')):data=retarget(data.decode()).encode()
 if r==q:
  assert data.count(b'set_global_assignment -name SEED 1\n')==1
  data=data.replace(b'set_global_assignment -name SEED 1\n',b'set_global_assignment -name SEED 2\n')
  assert hashlib.sha256(data).hexdigest()=='35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293'
 over[r]={'data':base64.b64encode(data).decode(),'sha256':hashlib.sha256(data).hexdigest()}
stage=retarget((P/'stage_remote.py').read_text())
exec(compile(stage,'stage_remote.py','exec'),{'OVERLAYS':over})
(E/'stage_remote.py').write_text(stage)
for r,data in before.items():
 p=E/'source-before'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
(E/'candidate.patch').write_text(''.join(''.join(difflib.unified_diff(before[r].decode().splitlines(True),(E/'source-overlay'/r).read_text().splitlines(True),fromfile='a/'+r,tofile='b/'+r)) for r in expected))
art={f:base64.b64encode(retarget((P/f).read_text()).encode()).decode() for f in ['issue_authorization.py','launch_native_compile.py','test_real_dispatch.py']}
prepare=retarget((P/'prepare_handoff_remote.py').read_text());(E/'prepare_handoff_remote.py').write_text(prepare)
# Prevent old SOURCE imports from shadowing the candidate dispatcher.
sys.modules.pop('ia840f_experimental_gate',None);sys.modules.pop('ia840f_compile_gate',None)
exec(compile(prepare,'prepare_handoff_remote.py','exec'),{'ARTIFACTS':art})
for script,label in [(E/'test_real_dispatch.py','real-dispatch-tests'),(W/'ofs-common/tools/ofss_config/test_ia840f_compile_gate.py','compile-gate-tests')]:
 r=subprocess.run(['python3',str(script)],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True)
 (E/(label+'.log')).write_text(r.stdout+r.stderr);assert r.returncode==0,(label,r.stdout,r.stderr)
# Actual copied entry and both shell stage guards must reject specifically for missing Work10 record.
env=dict(os.environ,OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PYTHONDONTWRITEBYTECODE='1')
for k in list(env):
 if k.startswith('OFS_BUILD_TAG_') or k in ['SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE']:env.pop(k)
rejections=[]
for command in [['python3',str(W/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'),'native','compile','ia840f',str(W)],['bash',str(W/'ofs-common/scripts/common/syn/build_top.sh'),'--stage=compile','-k','-p','ia840f',str(W)],['bash',str(W/'ofs-common/scripts/common/syn/build_fim_compile.sh'),'ia840f',str(W)]]:
 r=subprocess.run(command,cwd=C,env=env,capture_output=True,text=True)
 assert r.returncode!=0 and str(E/'compile-authorization.json') in r.stderr and 'No such file' in r.stderr,(command,r.stdout,r.stderr)
 rejections.append(dict(argv=command,rc=r.returncode,stdout=r.stdout,stderr=r.stderr))
(E/'missing-work10-record-tests.json').write_text(json.dumps(rejections,indent=2))
draft=json.loads((E/'compile-authorization.draft.json').read_text())
assert len(draft['contexts'])==135
assert draft['contexts']==json.loads(retarget(json.dumps(prior['contexts'])))
assert {t:common.inventory(C/t) for t in common.TREES}==source_before
assert {str(p):sha(p) for p in history_paths}==history
assert inv(OLD)==json.loads((E/'work04-before.json').read_text())
assert not (E/'compile-authorization.json').exists() and not (E/'native-compile.claim.json').exists() and not (E/'run').exists() and not (C/'build_fim_work_ia840f_fim_10.log').exists()
(E/'preparation-preflight.json').write_text(json.dumps(dict(source_inventory_before=source_before,work09_preserved=history,instructions_sha256=sha('/home/uwb_student00/quartus_26/instructions.md'),prior_authorization_sha256=sha(P/'compile-authorization.json')),indent=2))
(E/'final-verification.json').write_text(json.dumps(dict(contexts=135,contexts_exact_retarget=True,source_unchanged=True,work04_unchanged=True,work09_evidence_unchanged=True,missing_record_cases=len(rejections),compile_gate_tests_pass=True,real_dispatch_tests_pass=True,ready_for_build=False,authorization_issued=False,quartus_started=False),indent=2))
print('WORK10 PREPARATION PASS; NOT ISSUED; NOT LAUNCHED')
