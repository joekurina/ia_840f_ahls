"""Inert file/identity fixtures for the actual synthesis callback."""
import contextlib,copy,hashlib,importlib.util,io,json,os,sys,tempfile,subprocess
from pathlib import Path
from typing import Any
from unittest.mock import patch
E=Path(__file__).resolve().parent;assert len(sys.argv)==4;SOURCE=Path(sys.argv[1]).resolve();PRODUCER=Path(sys.argv[2]).resolve();OUT=Path(sys.argv[3]).resolve();assert not OUT.exists()
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
owner={'pid':111,'ppid':1,'start_ticks':123,'state':'S','exe':'/inert/python','cwd':str(P),'argv':['/inert/python','INERT_RUNNER']}
native={'pid':222,'ppid':333,'start_ticks':234,'state':'S','exe':str(tool),'cwd':str(J),'argv':[str(tool),*context['argv']]}
bridge={'pid':333,'ppid':111,'start_ticks':200,'state':'S','exe':'/inert/cmake','cwd':str(J),'argv':['/inert/cmake','INERT']}
base={'scope':'persona-fit-only','parent_execution_accepted':True,'ready_for_build':False,'hardware_ready':False,'project':str(J),'design_root':str(D),'operation_root':str(R),'control_root':str(P),'gate_sha256':sha(GATE),'runner_path':str(runner),'runner_sha256':sha(runner),'contexts':[context],'tools':{str(tool):entry(tool)},'release_root':'/INERT_RELEASE','prepared_metadata_file':str(prepared),'critical_inputs':critical,'external_inputs':external,'prerequisites':{str(prereq):sha(prereq)}}
env={'QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/26.1.1/quartus','OPAE_PLATFORM_ROOT':'/INERT_RELEASE','BUILD_ROOT_REL':'../../../..','PR_COMPILE':'1'}

# Use the real producer function, JSON round-trip and actual /proc readers.
pspec=importlib.util.spec_from_file_location('real_identity_producer',PRODUCER);assert pspec and pspec.loader
producer: Any=importlib.util.module_from_spec(pspec);pspec.loader.exec_module(producer)
real_owner=producer.identity(os.getpid());owner_bytes=json.dumps(real_owner,sort_keys=True).encode();decoded_owner=json.loads(owner_bytes)
rows=[]
def expect(name,fn,want):
 error=None
 try:fn();accepted=True
 except BaseException as exc:accepted=False;error=repr(exc)
 rows.append({'case':name,'expected_accept':want,'accepted':accepted,'correct':accepted==want,'error':error})
expect('real_owner_json_roundtrip',lambda:mod.owner_live({'runner':decoded_owner}),True)
for key,value in [('start_ticks',str(int(decoded_owner['start_ticks'])+1)),('exe','/INERT_WRONG_EXE'),('cwd','/INERT_WRONG_CWD'),('argv',['INERT_WRONG_ARGV'])]:
 changed=copy.deepcopy(decoded_owner);changed[key]=value;expect('reject_changed_'+key,lambda changed=changed:mod.owner_live({'runner':changed}),False)
child=subprocess.Popen([sys.executable,'-B','-c','import sys; print("INERT_READY",flush=True); sys.stdin.readline()'],cwd=P,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
child_identity=None
try:
 assert child.stdout and child.stdout.readline().strip()=='INERT_READY'
 child_identity=producer.identity(child.pid);real_native=mod.proc(child.pid)
 context={'exe':real_native['exe'],'cwd':real_native['cwd'],'argv':real_native['argv'][1:]};mod.CONTEXT=copy.deepcopy(context)
 m=copy.deepcopy(base);m['contexts']=[context];native_exe=Path(real_native['exe']);m['tools']={str(native_exe):{'bytes':native_exe.stat().st_size,'sha256':sha(native_exe)}}
 prepared.write_text(json.dumps({'critical_inputs':m['critical_inputs'],'external_inputs':m['external_inputs']}));m['prepared_metadata_sha256']=sha(prepared);mod.MANIFEST.write_text(json.dumps(m))
 authority={'scope':m['scope'],'ready_for_build':False,'hardware_ready':False,'manifest':str(mod.MANIFEST),'manifest_sha256':sha(mod.MANIFEST),'project':str(J),'runner':decoded_owner,'contexts':m['contexts']}
 (R/'authority.json').write_text(json.dumps(authority))
 # The Python fixture substitutes only where the callback sees its parent;
 # owner/child identities and their ancestor relationship come from real /proc.
 with patch.object(mod.os,'getppid',return_value=child.pid),patch.object(sys,'argv',[str(GATE),'quartus']),patch.dict(os.environ,env,clear=True):
  expect('actual_validate_real_child_to_real_owner',mod.validate,True)
  bad=copy.deepcopy(authority);bad['runner']['start_ticks']=str(int(decoded_owner['start_ticks'])+1);(R/'authority.json').write_text(json.dumps(bad))
  expect('actual_validate_changed_owner_start',mod.validate,False)
 # Evaluate the actual ancestor-equality fields using the consumer reader,
 # starting from the real inert child's true parent relation.
 def ancestry():
  ancestor=mod.proc(child.pid);found=False
  for _ in range(40):
   if ancestor['pid']==decoded_owner['pid']:
    assert all(ancestor[k]==decoded_owner[k] for k in ('pid','start_ticks','exe','cwd','argv'));found=True;break
   if ancestor['ppid']<=1:break
   ancestor=mod.proc(ancestor['ppid'])
  assert found
 expect('real_proc_ancestry_serialized_owner',ancestry,True)
finally:
 try:child.communicate(input='exit\n',timeout=5)
 except BaseException:child.kill();child.communicate(timeout=5);raise
assert child.returncode==0 and child_identity is not None
expect('exited_real_owner_rejected',lambda:mod.owner_live({'runner':json.loads(json.dumps(child_identity))}),False)
failures=[r['case'] for r in rows if not r['correct']]
result={'success':not failures,'scope':'real local identity()/JSON/proc()/owner_live and validate ancestry integration; inert Python child, file/context/environment fixture, no Quartus or remote/hardware','callback_source':str(SOURCE),'callback_sha256':sha(SOURCE),'producer_source':str(PRODUCER),'producer_sha256':sha(PRODUCER),'producer_start_ticks_type':type(decoded_owner['start_ticks']).__name__,'consumer_start_ticks_type':type(mod.proc(os.getpid())['start_ticks']).__name__,'count':len(rows),'cases':rows,'failures':failures,'inert_child_returncode':child.returncode,'scratch':str(B)}
OUT.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'success':not failures,'cases':len(rows),'failures':failures,'producer_type':result['producer_start_ticks_type'],'consumer_type':result['consumer_start_ticks_type'],'output':str(OUT)}));raise SystemExit(0 if not failures else 1)
