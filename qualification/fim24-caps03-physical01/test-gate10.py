"""Inert file/identity fixtures for the actual first-fit callback."""
import contextlib,copy,hashlib,importlib.util,io,json,os,sys,tempfile
from pathlib import Path
from typing import Any
from unittest.mock import patch
E=Path(__file__).resolve().parent;SOURCE=E/'candidate08/ia840f_physical_gate08.py';OUT=E/'gate-inert10.json';assert not OUT.exists()
B=Path(tempfile.mkdtemp(prefix='persona-gate-',dir=os.environ['TMPDIR']));D=B/'design';P=B/'control';R=B/'run';J=D/'project';GATE=D/'setup/ia840f_physical_gate08.py'
for p in (D,P,R,J,GATE.parent):p.mkdir(parents=True,exist_ok=True)
GATE.write_bytes(SOURCE.read_bytes());spec=importlib.util.spec_from_file_location('inert_persona_gate',GATE);assert spec and spec.loader
mod: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
mod.ROOT=B;mod.D=D;mod.P=P;mod.R=R;mod.J=J;mod.GATE=GATE;mod.MANIFEST=P/'admitted.json'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def put(p,b):p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
def entry(p):return {'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)}
qsf=J/'ofs_pr_afu.qsf';put(qsf,('\n'.join(['set_global_assignment -name FAMILY "Agilex 7"','set_global_assignment -name DEVICE AGFB027R25A2E2V','set_global_assignment -name TOP_LEVEL_ENTITY top','set_global_assignment -name REVISION_TYPE PR_IMPL','set_global_assignment -name NUM_PARALLEL_PROCESSORS 36'])+'\n').encode())
critical={str(qsf):entry(qsf),str(GATE):entry(GATE)}
for i in range(3031):
 p=D/'data'/f'{i:04d}';put(p,b'INERT\n');critical[str(p)]=entry(p)
external={}
for i in range(298):
 p=B/'external'/f'{i:04d}';put(p,b'INERT\n');external[str(p)]=entry(p)
assert len(critical)==3033 and len(external)==298
runner=P/'runner.py';put(runner,b'INERT RUNNER, NEVER EXECUTED\n');tool=B/'native-tool';put(tool,b'INERT QUARTUS, NEVER EXECUTED\n');prereq=P/'scope.md';put(prereq,b'INERT APPROVED SCOPE\n');prepared=P/'prepared.json'
context={'exe':str(tool),'cwd':str(J),'argv':['--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_pr_afu']};mod.CONTEXT=copy.deepcopy(context)
owner={'pid':111,'ppid':1,'start_ticks':'123','state':'S','exe':'/inert/python','cwd':str(P),'argv':['/inert/python','INERT_RUNNER']}
native={'pid':222,'ppid':333,'start_ticks':'234','state':'S','exe':str(tool),'cwd':str(J),'argv':[str(tool),*context['argv']]}
bridge={'pid':333,'ppid':111,'start_ticks':'200','state':'S','exe':'/inert/cmake','cwd':str(J),'argv':['/inert/cmake','INERT']}
base={'scope':'persona-fit-only','parent_execution_accepted':True,'ready_for_build':False,'hardware_ready':False,'project':str(J),'design_root':str(D),'operation_root':str(R),'control_root':str(P),'gate_sha256':sha(GATE),'runner_path':str(runner),'runner_sha256':sha(runner),'contexts':[context],'tools':{str(tool):entry(tool)},'release_root':'/INERT_RELEASE','prepared_metadata_file':str(prepared),'critical_inputs':critical,'external_inputs':external,'prerequisites':{str(prereq):sha(prereq)}}
env={'QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/26.1.1/quartus','OPAE_PLATFORM_ROOT':'/INERT_RELEASE','BUILD_ROOT_REL':'../../../..','PR_COMPILE':'1'}
rows=[]
def write_manifest(m):
 prepared.write_text(json.dumps({'critical_inputs':m['critical_inputs'],'external_inputs':m['external_inputs']}));m['prepared_metadata_sha256']=sha(prepared);mod.MANIFEST.write_text(json.dumps(m))
 auth={'scope':m['scope'],'ready_for_build':False,'hardware_ready':False,'manifest':str(mod.MANIFEST),'manifest_sha256':sha(mod.MANIFEST),'project':str(J),'runner':owner,'contexts':m['contexts']}
 (R/'authority.json').write_text(json.dumps(auth));return auth

def trial(mode,expect):
 m=copy.deepcopy(base);procs={111:copy.deepcopy(owner),222:copy.deepcopy(native),333:copy.deepcopy(bridge)};environment=dict(env);mutated=None
 if mode=='bad_scope':m['scope']='not-allowed'
 if mode=='ready':m['ready_for_build']=True
 if mode=='hardware_ready':m['hardware_ready']=True
 if mode=='empty_critical':m['critical_inputs']={}
 if mode=='empty_external':m['external_inputs']={}
 if mode=='unissued_parent':m['parent_execution_accepted']=False
 authority=write_manifest(m)
 if mode=='wrong_argv':procs[222]['argv'].append('--unreviewed')
 if mode=='wrong_cwd':procs[222]['cwd']='/INERT_WRONG'
 if mode=='wrong_exe':procs[222]['exe']='/INERT_WRONG'
 if mode=='unowned_ancestry':procs[222]['ppid']=1
 if mode=='stale_owner':procs[111]['start_ticks']='124'
 if mode=='export_mode_zero':environment['OPAE_PLATFORM_GEN']='0'
 if mode=='wrong_version':environment['QUARTUS_ROOTDIR_OVERRIDE']='/INERT_OLD'
 if mode=='source_drift':mutated=Path(next(k for k in critical if '/data/' in k))
 if mode=='external_drift':mutated=Path(next(iter(external)))
 if mode=='tool_drift':mutated=tool
 if mode=='runner_drift':mutated=runner
 if mode=='metadata_drift':mutated=prepared
 if mode=='prerequisite_drift':mutated=prereq
 before=mutated.read_bytes() if mutated else None
 if mutated:mutated.write_bytes(b'DRIFT\n')
 events=R/'gate-events.jsonl';old_events=events.read_bytes() if events.exists() else b''
 error=None
 try:
  with patch.object(mod,'proc',side_effect=lambda pid:copy.deepcopy(procs[pid])),patch.object(mod.os,'getppid',return_value=222),patch.object(sys,'argv',[str(GATE),'quartus']),patch.dict(os.environ,environment,clear=True):mod.validate()
 except BaseException as exc:error=repr(exc)
 finally:
  if mutated:
   assert before is not None
   mutated.write_bytes(before)
 passed=error is None;assert passed is expect,(mode,error)
 if not expect:assert (events.read_bytes() if events.exists() else b'')==old_events
 rows.append({'case':mode,'expected_accept':expect,'accepted':passed,'error':error,'no_accept_event_on_reject':True})
trial('positive_exact_context',True)
for mode in ('bad_scope','ready','hardware_ready','empty_critical','empty_external','unissued_parent','wrong_argv','wrong_cwd','wrong_exe','unowned_ancestry','stale_owner','export_mode_zero','wrong_version','source_drift','external_drift','tool_drift','runner_drift','metadata_drift','prerequisite_drift'):trial(mode,False)
# Actual missing-authority entry must not create output state in an absent root.
empty=B/'absent-run';mod.R=empty
with patch.object(sys,'argv',[str(GATE),'quartus']),contextlib.redirect_stderr(io.StringIO()):rc=mod.main()
assert rc==1 and not empty.exists();rows.append({'case':'missing_authority_no_write','rc':rc,'root_absent':True})
OUT.write_text(json.dumps({'success':True,'scope':'actual callback with synthetic identity/ancestry and inert files; no Quartus/project/native execution','source_sha256':sha(SOURCE),'count':len(rows),'critical_fixture_files':len(critical),'external_fixture_files':len(external),'cases':rows,'scratch':str(B)},indent=2)+'\n');print(json.dumps({'success':True,'gate_cases':len(rows),'native_tools_executed':False,'output':str(OUT)}))
