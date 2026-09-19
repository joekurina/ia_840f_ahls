"""Prepare Work11 aggressive-hold-only candidate; never issue or launch."""
from pathlib import Path
import base64,hashlib,json,subprocess,os,socket,difflib,sys
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';P=B/'qualification/fim-build-10';E=B/'qualification/fim-build-11';W=B/'work_ia840f_fim_11';OLD=B/'work_ia840f_ipgen_04'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
os.environ['PYTHONDONTWRITEBYTECODE']='1';sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
expected=json.loads((P/'overlay-sha256.json').read_text());q='syn/board/ia840f/syn_top/ofs_top.qsf'
assert {r:sha(C/r) for r in expected}==expected
assert sha(C/q)=='35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293'
for name,h in {'stage_remote.py': '45ad28ac249934a1040e8842256534179bb1cae497bdab04f06793bc00bed077', 'prepare_handoff_remote.py': '726c24cc1cb3caf8eae4f6669da90225a30880a689b43e48d8dad510e80b18c2', 'issue_authorization.py': 'c01c585bd2ac2193f46df49f2630cb9ae56c875e392a849c4b8ee77b70ba81f1', 'launch_native_compile.py': '31beb72d84a1a5bafc4226f7145a8a0414dc8883b44a36825fae089756581895', 'test_real_dispatch.py': 'd2ba0baa8e56a8f89e89e604a0bc0941b030371d8ac12010f19ebdc352759130'}.items():assert sha(P/name)==h
# Read-only historical verification, no compiled Work10 output is copied.
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
def retarget(t):return t.replace('fim-build-10','fim-build-11').replace('work_ia840f_fim_10','work_ia840f_fim_11').replace('Work10','Work11')
over={};before={}
for r,h in expected.items():
 data=(C/r).read_bytes();before[r]=data
 if r.endswith(('ia840f_compile_gate.py','ia840f_experimental_gate.py')):data=retarget(data.decode()).encode()
 if r==q:
  assert b'TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT' not in data
  assert data.count(b'set_global_assignment -name SEED 2\n')==1
  data+=b'set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON\n'
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
# Actual copied entry and both shell stage guards must reject specifically for missing Work11 record.
env=dict(os.environ,OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PYTHONDONTWRITEBYTECODE='1')
for k in list(env):
 if k.startswith('OFS_BUILD_TAG_') or k in ['SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE']:env.pop(k)
rejections=[]
for command in [['python3',str(W/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'),'native','compile','ia840f',str(W)],['bash',str(W/'ofs-common/scripts/common/syn/build_top.sh'),'--stage=compile','-k','-p','ia840f',str(W)],['bash',str(W/'ofs-common/scripts/common/syn/build_fim_compile.sh'),'ia840f',str(W)]]:
 r=subprocess.run(command,cwd=C,env=env,capture_output=True,text=True)
 assert r.returncode!=0 and str(E/'compile-authorization.json') in r.stderr and 'No such file' in r.stderr,(command,r.stdout,r.stderr)
 rejections.append(dict(argv=command,rc=r.returncode,stdout=r.stdout,stderr=r.stderr))
(E/'missing-work11-record-tests.json').write_text(json.dumps(rejections,indent=2))
draft=json.loads((E/'compile-authorization.draft.json').read_text())
assert len(draft['contexts'])==135
assert draft['contexts']==json.loads(retarget(json.dumps(prior['contexts'])))
assert {t:common.inventory(C/t) for t in common.TREES}==source_before
assert {str(p):sha(p) for p in history_paths}==history
assert inv(OLD)==json.loads((E/'work04-before.json').read_text())
assert not (E/'compile-authorization.json').exists() and not (E/'native-compile.claim.json').exists() and not (E/'run').exists() and not (C/'build_fim_work_ia840f_fim_11.log').exists()
(E/'preparation-preflight.json').write_text(json.dumps(dict(source_inventory_before=source_before,work10_preserved=history,instructions_sha256=sha('/home/uwb_student00/quartus_26/instructions.md'),prior_authorization_sha256=sha(P/'compile-authorization.json')),indent=2))
(E/'final-verification.json').write_text(json.dumps(dict(contexts=135,contexts_exact_retarget=True,source_unchanged=True,work04_unchanged=True,work10_evidence_unchanged=True,missing_record_cases=len(rejections),compile_gate_tests_pass=True,real_dispatch_tests_pass=True,ready_for_build=False,authorization_issued=False,quartus_started=False),indent=2))
print('WORK11 PREPARATION PASS; NOT ISSUED; NOT LAUNCHED')
