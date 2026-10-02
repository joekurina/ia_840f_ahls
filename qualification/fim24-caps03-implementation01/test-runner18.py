"""Actual mapped-synthesis runner exercised with inert children only."""
import contextlib,copy,hashlib,importlib.util,io,json,os,subprocess,sys,tempfile
from pathlib import Path
from typing import Any
from unittest.mock import patch
E=Path(__file__).resolve().parent;SOURCE=E/'candidate18/run-synthesis18.py';OUT=E/'runner-inert18.json';assert not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='persona-synth-runner-',dir=os.environ['TMPDIR']));POPEN=subprocess.Popen;ROWS=[]
def put(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inv(root):return {str(p.relative_to(root)):{'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)} for p in root.rglob('*') if p.is_file()}
def snap(root):return {str(p.relative_to(root)):sha(p) for p in root.rglob('*') if p.is_file()}
def load(label):
 spec=importlib.util.spec_from_file_location(label,SOURCE);assert spec and spec.loader
 mod: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod

def case(mode,clean):
 root=BASE/mode;root.mkdir();mod=load('synth_fixture_'+mode);mod.ROOT=root;mod.D=root/'design';mod.P=root/'control';mod.R=root/'run';mod.J=mod.D/'project';mod.Q=root/'INERT_QUARTUS';mod.MANIFEST=mod.P/'admitted.json'
 for p in (mod.D,mod.P,mod.J):p.mkdir(parents=True,exist_ok=True)
 qpf=mod.J/'ofs_top.qpf';qtext='QUARTUS_VERSION = "26.1"\nDATE = "INERT"\nPROJECT_REVISION = "ofs_pr_afu"\n';put(qpf,qtext)
 critical=mod.D/'selected.sv';put(critical,'INERT SOURCE, NOT HDL\n');external=root/'external.sv';put(external,'INERT EXTERNAL, NOT HDL\n')
 archive=root/'archive';original=root/'original';release=root/'release'
 for p in (archive,original,release):put(p/'entry','INERT\n')
 tool=root/'tool';put(tool,'INERT TOOL, NEVER RUN\n');put(mod.P/'runtime/CMakeLists.txt','# INERT\n');prepared=mod.P/'prepared.json';put(prepared,'{}\n')
 results={}
 for key in ('setup','release','simulation'):
  p=root/(key+'-result.json');put(p,'{}\n');results[key+'_result_file']=str(p);results[key+'_result_sha256']=sha(p)
 context={'exe':'/INERT_NATIVE_EXE','cwd':str(mod.J),'argv':['--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_pr_afu']}
 reports=['output_files/ofs_pr_afu.syn.rpt','output_files/ofs_pr_afu.syn.summary','output_files/ofs_pr_afu.drc.synthesized.rpt']
 m={**results,'scope':'persona-mapped-synthesis-only','interface_uuid':'INERT_STATIC','afu_uuid':'INERT_AFU','critical_inputs':{str(critical):inv(mod.D)['selected.sv']},'external_inputs':{str(external):{'kind':'file','bytes':external.stat().st_size,'sha256':sha(external)}},'archive_root':str(archive),'archive_inventory':inv(archive),'original_setup_root':str(original),'original_setup_inventory':inv(original),'release_root':str(release),'original_release_inventory':inv(release),'tools':{str(tool):{'bytes':tool.stat().st_size,'sha256':sha(tool)}},'opae_tools':{},'runner_sha256':sha(SOURCE),'cmake_sha256':sha(mod.P/'runtime/CMakeLists.txt'),'prepared_metadata_file':str(prepared),'prepared_metadata_sha256':sha(prepared),'prerequisites':{},'contexts':[context],'required_reports':reports,'qpf_before':{'bytes':qpf.stat().st_size,'sha256':sha(qpf),'text':qtext},'cpus':sorted(os.sched_getaffinity(0)),'address_space_limit_bytes':64*1024**3,'log_limit_bytes':1024 if mode=='overflow' else 1048576,'deadlines_seconds':{'configure':4,'version':4,'synthesis':0.5 if mode=='timeout' else 4}}
 actual=[]
 def preflight(_):
  if mode=='unissued':raise AssertionError('INERT unissued')
  return copy.deepcopy(m)
 def popen(argv,**kwargs):
  assert argv[0]=='/usr/bin/cmake';target=argv[argv.index('--target')+1] if '--target' in argv else 'configure';code='print("INERT stage")'
  if target=='version':code='print("INERT 26.1.1 Build 130 SC Pro Edition")'
  if target=='synthesis':
   outputs={n:'INERT REPORT, NOT QUARTUS\n' for n in reports};outputs['qdb/inert.qdb']='INERT DATABASE, NOT FPGA DATA\n'
   if mode=='missing_report':outputs.pop(reports[0])
   if mode=='missing_qdb':outputs.pop('qdb/inert.qdb')
   event={'accepted':True,'manifest_sha256':'a'*64,'native':{'exe':context['exe'],'cwd':context['cwd'],'argv':[context['exe'],*context['argv']]}}
   if mode=='wrong_callback':event['native']['cwd']='/INERT_WRONG'
   code='from pathlib import Path\nimport json\nJ=Path('+repr(str(mod.J))+')\nR=Path('+repr(str(mod.R))+')\nfor n,b in '+repr(outputs)+'.items():\n p=J/n;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(b)\n'
   if mode!='missing_callback':code+='(R/"gate-events.jsonl").write_text('+repr(json.dumps(event)+'\n')+')\n'
   code+='print("INERT: Quartus Prime Synthesis was successful")\n'
   if mode=='nonzero':code+='raise SystemExit(7)\n'
   if mode=='error':code+='print("Error (suppressible): INERT")\n'
   if mode=='gate_marker':code+='print("IA840F_GATE_REJECTED: INERT")\n'
   if mode=='overflow':code+='print("x"*8192)\n'
   if mode=='timeout':code+='import time;time.sleep(8)\n'
   if mode=='drain_marker':code+='import os,time\npid=os.fork()\nif pid:os._exit(0)\ntime.sleep(0.3)\nprint("IA840F_GATE_REJECTED: INERT",flush=True)\ntime.sleep(8)\n'
   mutate={'critical_drift':critical,'external_drift':external,'archive_drift':archive/'entry','setup_drift':original/'entry','release_drift':release/'entry','tool_drift':tool,'control_drift':prepared,'predecessor_drift':Path(m['setup_result_file'])}
   if mode in mutate:code+='Path('+repr(str(mutate[mode]))+').write_text("DRIFT")\n'
   if mode=='qpf_date':code+='Path('+repr(str(qpf))+').write_text('+repr(qtext.replace('DATE = "INERT"','DATE = "INERT LATER"'))+')\n'
   if mode=='qpf_revision':code+='Path('+repr(str(qpf))+').write_text('+repr(qtext.replace('ofs_pr_afu','wrong'))+')\n'
  actual.append({'requested':argv,'actual':[sys.executable,'-c',code]});return POPEN([sys.executable,'-c',code],**kwargs)
 def command(argv,**kwargs):assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0)
 oldpost=mod.postflight
 def post(*args):
  if mode=='postflight_fault':raise RuntimeError('INERT postflight exception')
  return oldpost(*args)
 before=snap(root)
 with patch.object(mod,'preflight',side_effect=preflight),patch.object(mod,'postflight',side_effect=post),patch.object(mod.subprocess,'Popen',side_effect=popen),patch.object(mod.subprocess,'run',side_effect=command),patch.object(sys,'argv',['INERT','a'*64]),patch.dict(os.environ,{'LM_LICENSE_FILE':'INERT','MGLS_LICENSE_FILE':'INERT','SALT_LICENSE_SERVER':'INERT'}),contextlib.redirect_stdout(io.StringIO()):
  if mode=='unissued':
   try:mod.run()
   except AssertionError:pass
   else:raise AssertionError('unissued accepted')
   assert not mod.R.exists() and not actual and snap(root)==before;ROWS.append({'case':mode,'rejected_before_write':True});return
  rc=mod.run();r=json.loads((mod.R/'result.json').read_text());assert r['execution_clean'] is clean and (rc==0) is clean,(mode,r)
  assert all(not c.get('owned_group_live_after') for c in r['commands'])
  if mode=='timeout':assert r['commands'][-1]['effective_rc']==124
  if mode=='drain_marker':assert r['commands'][-1]['gate_rejected'] and not r['commands'][-1]['timeout']
  after=snap(root);n=len(actual)
  try:mod.run()
  except FileExistsError:pass
  else:raise AssertionError('spent replay accepted')
  assert snap(root)==after and len(actual)==n
 ROWS.append({'case':mode,'expected_clean':clean,'actual_rc':rc,'execution_clean':r['execution_clean'],'commands':r['commands'],'postflight_errors':r.get('postflight_errors'),'postflight_exception':r.get('postflight_exception'),'diagnostics':r.get('diagnostics'),'actual_inert_commands':actual,'replay_preserved':True})
case('clean',True);case('qpf_date',True)
for mode in ('unissued','nonzero','error','gate_marker','missing_callback','wrong_callback','missing_report','missing_qdb','critical_drift','external_drift','archive_drift','setup_drift','release_drift','tool_drift','control_drift','qpf_revision','overflow','timeout','drain_marker','postflight_fault','predecessor_drift'):case(mode,False)
OUT.write_text(json.dumps({'success':True,'scope':'actual runner with mocked admission/CMake/tmux, synthetic callback observations, tiny INERT files and literal INERT environment values; real Python children, no vendor execution','runner_sha256':sha(SOURCE),'count':len(ROWS),'cases':ROWS,'scratch':str(BASE)},indent=2)+'\n');print(json.dumps({'success':True,'runner_cases':len(ROWS),'native_tools_executed':False,'output':str(OUT)}))
