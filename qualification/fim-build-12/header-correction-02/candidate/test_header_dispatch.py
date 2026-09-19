"""Inert header records/processes only; real source/tool/path validation."""
from pathlib import Path
from unittest.mock import patch
from contextlib import ExitStack,redirect_stderr
import os,sys,json,copy,io,importlib
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach'
sys.dont_write_bytecode=True;results=[]
for root in [E/'source-overlay',W]:
 path=root/'ofs-common/tools/ofss_config'
 for name in ['ia840f_compile_gate','ia840f_experimental_gate','ia840f_header_gate']:sys.modules.pop(name,None)
 sys.path.insert(0,str(path));common=importlib.import_module('ia840f_experimental_gate');gate=importlib.import_module('ia840f_header_gate')
 record=json.loads((E/'header-authorization.draft.json').read_text());record.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
 read=Path.read_text;sha=gate.sha;inventory=common.inventory
 claim=dict(pid=102,start_time='INERT',record_sha256='INERT-RECORD');ctx=copy.deepcopy(record['contexts'][0]);runner=[gate.PYTHON_EXE,gate.TOP_ARGS,str(gate.PROJECT)]
 def fixture_read(p,*a,**k):
  if p==gate.RECORD:return json.dumps(record)
  if p==gate.CLAIM:return json.dumps(claim)
  return read(p,*a,**k)
 def future_source(p):
  actual=inventory(p)
  if p.parent==C:
   for r,h in json.loads((E/'header-source-changes.json').read_text()).items():
    tree,rest=r.split('/',1)
    if p.name==tree:actual[rest]=h
  return actual
 def proc(pid):
  if pid==102:return tuple(runner)
  assert pid==101;return ctx['executable'],ctx['argv'],ctx['cwd']
 def invoke(label,ok,cwd=None):
  os.chdir(cwd or gate.PROJECT);err=io.StringIO()
  with patch.object(sys,'argv',[str(path/'ia840f_experimental_gate.py'),'quartus']),redirect_stderr(err):rc=common.main()
  assert (rc==0)==ok,(label,rc,err.getvalue());results.append(dict(root=str(root),label=label,rc=rc,error=err.getvalue()))
 with ExitStack() as s:
  s.enter_context(patch.object(Path,'read_text',fixture_read));s.enter_context(patch.object(gate,'sha',lambda p:'INERT-RECORD' if Path(p)==gate.RECORD else sha(p)))
  s.enter_context(patch.object(common,'inventory',future_source));s.enter_context(patch.object(os,'getppid',return_value=101))
  s.enter_context(patch.object(gate,'parent',side_effect=lambda p:102 if p==101 else 1));s.enter_context(patch.object(gate,'start_time',return_value='INERT'))
  s.enter_context(patch.object(common,'process',side_effect=proc));s.enter_context(patch.object(common.shutil,'which',side_effect=lambda n:record['quartus_tools'][n]['path']))
  s.enter_context(patch.object(common,'monitor_setup_output',side_effect=AssertionError('NO VENDOR FIXTURE ALLOWED')))
  s.enter_context(patch.dict(os.environ,dict(OFS_ROOTDIR=str(W),OFS_PLATFORM_AFU_BBB=str(common.PIM),QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus'),clear=True))
  invoke('exact header real-entry grammar',True)
  record['ready_for_build']=True;invoke('readiness mutation',False);record['ready_for_build']=False
  r=next(iter(record['source_sha256']['src']));h=record['source_sha256']['src'][r];record['source_sha256']['src'][r]='WRONG';invoke('source mutation',False);record['source_sha256']['src'][r]=h
  claim['start_time']='WRONG';invoke('claim reuse',False);claim['start_time']='INERT'
  runner[1]=gate.TOP_ARGS+['extra'];invoke('runner argv',False);runner[1]=gate.TOP_ARGS
  ctx['argv']=gate.HEADER_ARGS+['--unexpected'];invoke('extra vendor argument',False);ctx['argv']=gate.HEADER_ARGS
  ctx['executable']='/usr/bin/true';invoke('wrong runtime executable',False);ctx['executable']=record['contexts'][0]['executable']
  ctx['cwd']=str(C);invoke('wrong runtime cwd',False);ctx['cwd']=str(gate.PROJECT)
  for cwd in [C,W,B/'work_ia840f_fim_11/syn/board/ia840f/syn_top']:invoke('wrong actual cwd '+str(cwd),False,cwd)
 sys.path.pop(0)
assert not (E/'header-authorization.json').exists() and not (E/'header-run').exists()
print(json.dumps(dict(result='PASS',cases=results,fixtures='inert future record/source overlays and processes only; native commands never invoked'),indent=2))
