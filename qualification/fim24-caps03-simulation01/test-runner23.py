"""Exercise actual simulation runner with real inert children, no simulator."""
import contextlib,copy,hashlib,importlib.util,io,json,os,subprocess,sys,tempfile
from pathlib import Path
from typing import Any
from unittest.mock import patch
E=Path(__file__).resolve().parent;SOURCE=E/'candidate23/run-simulation23.py';OUT=E/'runner-inert23.json';assert not OUT.exists()
BASE=Path(tempfile.mkdtemp(prefix='simulation-runner-',dir=os.environ['TMPDIR']));POPEN=subprocess.Popen;ROWS=[]
VERSION='Questa Intel FPGA Edition-64 vsim 2024.3 Simulator 2024.09 Sep 10 2024'
PASS='AHLS_PATH_UNIT_PASS cases=6 elements=133 copied_bytes=1600 dma=30 checks=1 mmio_reads=1 mmio_writes=1 bank0_W=1 bank1_W=1'
RESET='BANK1_RESET_INVALIDATION_PASS checks=1'
SPLIT='PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1'
def put(p,s):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(s)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inv(root):return {str(p.relative_to(root)):{'bytes':p.stat().st_size,'sha256':sha(p)} for p in root.rglob('*') if p.is_file()}
def snap(root):return {str(p.relative_to(root)):sha(p) for p in root.rglob('*') if p.is_file()}
def load(name):
 spec=importlib.util.spec_from_file_location(name,SOURCE);assert spec is not None and spec.loader is not None
 mod: Any=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod
# Check the exact scoreboard predicate, including zero-native-exit diagnostics.
scoremod=load('score_fixture');expected={'cases':6,'elements':133,'copied_bytes':1600,'dma':30}
good={'vsim.log':PASS+'\n'+RESET+'\n','split_fault.log':SPLIT+'\n','vlog.log':'Errors: 0, Warnings: 2\n'}
assert scoremod.scoreboards_exact(good,expected)['pass']
score_cases=[]
for label,error in [('plain','Error: INERT'),('qualified','Error (suppressible): INERT'),('timestamp','100 ns DWR ERROR: INERT'),('internal','Internal Error: INERT'),('fatal','Fatal: INERT'),('summary','Errors: 3')]:
 logs=copy.deepcopy(good);logs['vlog.log']+=error+'\n';r=scoremod.scoreboards_exact(logs,expected);assert not r['pass'] and r['diagnostic_errors'];score_cases.append(label)
for label,change in [('duplicate',lambda d:d.update({'vsim.log':d['vsim.log']+PASS+'\n'})),('wrong_count',lambda d:d.update({'vsim.log':d['vsim.log'].replace('elements=133','elements=132')})),('no_reset',lambda d:d.update({'vsim.log':PASS+'\n'})),('no_split',lambda d:d.update({'split_fault.log':''})),('zero_checks',lambda d:d.update({'vsim.log':d['vsim.log'].replace('checks=1 mmio','checks=0 mmio')}))]:
 logs=copy.deepcopy(good);change(logs);assert not scoremod.scoreboards_exact(logs,expected)['pass'];score_cases.append(label)

def case(mode,clean):
 root=BASE/mode;root.mkdir();mod=load('run_fixture_'+mode);mod.ROOT=root;mod.I=root/'inputs';mod.P=root/'control';mod.R=root/'native';mod.TOOLS=root/'inert-tools'
 mod.I.mkdir();mod.P.mkdir();put(mod.I/'rtl/fixture.sv','INERT, NOT HDL\n');put(mod.I/'modelsim.ini','INERT, NOT INI\n');put(mod.P/'runtime/CMakeLists.txt','# INERT\n')
 origin=root/'original';put(origin,'INERT ORIGINAL\n');tool=root/'inert-tool';put(tool,'INERT TOOL, NEVER EXECUTED\n');metadata=root/'prepared.json';put(metadata,'{}\n');setup=root/'setup-result.json';put(setup,'{}\n')
 fields=inv(mod.I)
 m={'files':fields,'originals':{str(origin):{'bytes':origin.stat().st_size,'sha256':sha(origin)}},'simulator_tools':{str(tool):{'bytes':tool.stat().st_size,'sha256':sha(tool)}},'runtime_tools':{},'prerequisites':{},'runner_sha256':sha(SOURCE),'cmake_sha256':sha(mod.P/'runtime/CMakeLists.txt'),'prepared_metadata_file':str(metadata),'prepared_metadata_sha256':sha(metadata),'setup_result_file':str(setup),'setup_result_sha256':sha(setup),'interface_uuid':'INERT_STATIC','afu_uuid':'INERT_AFU','expected_score':expected,'cpus':sorted(os.sched_getaffinity(0)),'address_space_limit_bytes':64*1024**3,'log_limit_bytes':2048 if mode=='overflow' else 1048576,'deadlines_seconds':{k:(0.5 if mode=='timeout' and k=='vsim' else 4) for k in ('configure','version','vlib','vdir','vlog','vsim','split_fault')}}
 actual=[]
 def preflight(_):
  if mode=='unissued':raise AssertionError('INERT unissued')
  return copy.deepcopy(m)
 def popen(argv,**kw):
  assert argv[0]=='/usr/bin/cmake';target=argv[argv.index('--target')+1] if '--target' in argv else 'configure';code='print("INERT stage")'
  if target=='version':code='print('+repr('INERT '+VERSION)+')'
  if target=='vsim':
   text=PASS+'\n'+RESET
   if mode=='wrong_score':text=text.replace('dma=30','dma=29')
   if mode=='missing_reset':text=PASS
   if mode=='reset_suffix':text=text.replace('checks=1\n','checks=10\n') if 'checks=1\n' in text else text.replace(RESET,RESET+'0')
   if mode=='main_suffix':text=text.replace('bank1_W=1','bank1_W=1junk')
   if mode=='duplicate_main_malformed':text+='\nAHLS_PATH_UNIT_PASS malformed'
   if mode=='duplicate_reset_wrong':text+='\nBANK1_RESET_INVALIDATION_PASS checks=0'
   if mode=='fatal':text+='\nFatal: INERT failure after pass text'
   code='print('+repr(text)+')'
   if mode=='nonzero':code+=';raise SystemExit(7)'
   if mode=='timeout':code='import time;time.sleep(8)'
   if mode=='overflow':code='print("x"*8192)'
   if mode=='run_drift':code+=';from pathlib import Path;Path('+repr(str(mod.R/'rtl/fixture.sv'))+').write_text("DRIFT")'
   if mode=='staged_drift':code+=';from pathlib import Path;Path('+repr(str(mod.I/'rtl/fixture.sv'))+').write_text("DRIFT")'
   if mode=='original_drift':code+=';from pathlib import Path;Path('+repr(str(origin))+').write_text("DRIFT")'
   if mode=='tool_drift':code+=';from pathlib import Path;Path('+repr(str(tool))+').write_text("DRIFT")'
   if mode=='drain_marker':code+='\nimport os,time\npid=os.fork()\nif pid:os._exit(0)\ntime.sleep(0.3)\nprint("IA840F_GATE_REJECTED: INERT",flush=True)\ntime.sleep(8)\n'
  if target=='vlog' and mode=='marker_wrong_log':code='print('+repr(PASS)+')'
  if target=='split_fault':
   split_text='INERT no marker' if mode=='missing_split' else SPLIT
   if mode=='split_suffix':split_text+='0'
   if mode=='duplicate_split_wrong':split_text+='\n'+SPLIT.replace('observed_split_errors=1','observed_split_errors=0')
   code='print('+repr(split_text)+')'
  actual.append({'requested':argv,'actual':[sys.executable,'-c',code]});return POPEN([sys.executable,'-c',code],**kw)
 def command(argv,**kw):assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0)
 origpost=mod.postflight
 def post(*args):
  if mode=='postflight_fault':raise RuntimeError('INERT postflight exception')
  return origpost(*args)
 before=snap(root)
 with patch.object(mod,'preflight',side_effect=preflight),patch.object(mod,'postflight',side_effect=post),patch.object(mod.subprocess,'Popen',side_effect=popen),patch.object(mod.subprocess,'run',side_effect=command),patch.object(sys,'argv',['INERT','0'*64]),patch.dict(os.environ,{'LM_LICENSE_FILE':'INERT','MGLS_LICENSE_FILE':'INERT','SALT_LICENSE_SERVER':'INERT'}),contextlib.redirect_stdout(io.StringIO()):
  if mode=='unissued':
   try:mod.run()
   except AssertionError:pass
   else:raise AssertionError('unissued accepted')
   assert not actual and not mod.R.exists() and before==snap(root);ROWS.append({'case':mode,'prewrite_rejection':True});return
  rc=mod.run();r=json.loads((mod.R/'result.json').read_text());assert r['unit_pass'] is clean and r['execution_clean'] is clean and (rc==0) is clean,(mode,r)
  assert all(not c.get('owned_group_live_after') for c in r['commands'])
  if mode=='timeout':assert r['commands'][-1]['timeout'] and r['commands'][-1]['effective_rc']==124
  if mode=='drain_marker':assert r['commands'][-1]['gate_rejected'] and not r['commands'][-1]['timeout']
  after=snap(root);n=len(actual)
  try:mod.run()
  except FileExistsError:pass
  else:raise AssertionError('spent replay accepted')
  assert snap(root)==after and len(actual)==n
 ROWS.append({'case':mode,'expected_clean':clean,'actual_rc':rc,'unit_pass':r['unit_pass'],'commands':r['commands'],'functional':r.get('functional'),'postflight_errors':r.get('postflight_errors'),'postflight_exception':r.get('postflight_exception'),'actual_inert_commands':actual,'replay_preserved':True})
case('clean',True)
for mode in ('unissued','nonzero','wrong_score','missing_reset','missing_split','fatal','run_drift','staged_drift','original_drift','tool_drift','overflow','timeout','drain_marker','postflight_fault','reset_suffix','main_suffix','duplicate_main_malformed','duplicate_reset_wrong','marker_wrong_log','split_suffix','duplicate_split_wrong'):case(mode,False)
OUT.write_text(json.dumps({'success':True,'runner_sha256':sha(SOURCE),'native_simulator_executed':False,'scope':'actual runner with mocked admission/CMake/tmux, tiny artifact maps and literal INERT environment values; real inert Python children, not vendor/license results','scoreboard_negative_cases':score_cases,'scoreboard_positive':True,'runner_case_count':len(ROWS),'cases':ROWS,'scratch':str(BASE)},indent=2)+'\n');print(json.dumps({'success':True,'runner_cases':len(ROWS),'negative_scoreboard_cases':len(score_cases),'native_simulator_executed':False,'output':str(OUT)}))
