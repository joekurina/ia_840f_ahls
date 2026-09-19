"""Remote real Work07 paths, production entry+runtime. NO vendor execution.
Only future approved record/claim, post-issuance SOURCE gate hashes and process
identities are fixtures. All paths/cwd, WORK files, dependency/tool hashes and
production dispatch/load_record/claim_ancestor/check_context are real.
"""
from pathlib import Path
from unittest.mock import patch
from contextlib import ExitStack, redirect_stderr
import copy, importlib, io, json, os, sys
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-07';W=B/'work_ia840f_fim_07';C=B/'ofs-agx7-pcie-attach'
results=[]
assert not (E/'compile-authorization.json').exists() and not (E/'native-compile.claim.json').exists()
for root in [E/'source-overlay',W]:
 path=root/'ofs-common/tools/ofss_config'
 for name in ['ia840f_compile_gate','ia840f_experimental_gate']:sys.modules.pop(name,None)
 sys.path.insert(0,str(path))
 common=importlib.import_module('ia840f_experimental_gate');gate=importlib.import_module('ia840f_compile_gate')
 assert Path(common.__file__)==path/'ia840f_experimental_gate.py'
 assert gate.PROJECT==W/'syn/board/ia840f/syn_top'
 record=json.loads((E/'compile-authorization.draft.json').read_text());record.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
 read=Path.read_text;sha=gate.sha;inventory=common.inventory
 claim={'pid':102,'start_time':'INERT-START','record_sha256':'INERT-RECORD'}
 context=next(c for c in record['contexts'] if c['argv']==gate.FLOW)
 calls=[]; trace=[]
 def fixture_read(p,*a,**k):
  if p==gate.RECORD:return json.dumps(record)
  if p==gate.CLAIM:return json.dumps(claim)
  return read(p,*a,**k)
 def future_source(p):
  actual=inventory(p)
  if p==C/'ofs-common':
   for name in ['ia840f_compile_gate.py','ia840f_experimental_gate.py']:
    rel='tools/ofss_config/'+name;actual[rel]=sha(E/'source-overlay/ofs-common'/rel)
  return actual
 def proc(pid):
  if pid==102:return '/usr/bin/bash',['/bin/bash']+gate.TOP_ARGS,str(C)
  assert pid==101
  return context['executable'],context['argv'],context['cwd']
 real_load=gate.load_record
 def traced_load(*a,**k):trace.append(k);return real_load(*a,**k)
 def invoke(args,cwd,success):
  os.chdir(cwd);err=io.StringIO()
  with patch.object(sys,'argv',[str(path/'ia840f_experimental_gate.py')]+args),redirect_stderr(err):rc=common.main()
  assert (rc==0)==success,(root,args,cwd,rc,err.getvalue())
  results.append({'entry':str(path),'args':args,'cwd':str(cwd),'rc':rc,'stderr':err.getvalue()})
 with ExitStack() as s:
  s.enter_context(patch.object(Path,'read_text',fixture_read));s.enter_context(patch.object(gate,'sha',lambda p:'INERT-RECORD' if Path(p)==gate.RECORD else sha(p)))
  s.enter_context(patch.object(common,'inventory',future_source))
  s.enter_context(patch.object(os,'getppid',return_value=101));s.enter_context(patch.object(gate,'parent',side_effect=lambda p:102 if p==101 else 1))
  s.enter_context(patch.object(gate,'start_time',return_value='INERT-START'));s.enter_context(patch.object(common,'process',side_effect=proc))
  s.enter_context(patch.object(common.shutil,'which',side_effect=lambda n:record['quartus_tools'][n]['path']))
  s.enter_context(patch.object(gate,'load_record',traced_load))
  s.enter_context(patch.object(common,'monitor_setup_output',side_effect=lambda a:calls.append(a)))
  env=dict(OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus')
  s.enter_context(patch.dict(os.environ,env,clear=True))
  for args in [gate.FLOW,['quartus_ipgenerate','--ipc_flow=17','--ipc_mode','ofs_top','-c','ofs_top','--run_default_mode_op'],['quartus_syn','--ipc_flow=17','--ipc_mode','--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_top'],['quartus_sh','--ipc_mode','-t','../../../../syn/shared_config/post_module_hook.tcl','quartus_syn','ofs_top','ofs_top']]:
   context=next(c for c in record['contexts'] if c['argv']==args);invoke(['quartus'],gate.PROJECT,True)
  assert trace and all(t=={'inner':True} for t in trace)
  record['ready_for_build']=True;invoke(['quartus'],gate.PROJECT,False);record['ready_for_build']=False
  rel=next(iter(record['source_sha256']['src']));saved=record['source_sha256']['src'][rel];record['source_sha256']['src'][rel]='MUTATED-SOURCE';invoke(['quartus'],gate.PROJECT,False);record['source_sha256']['src'][rel]=saved
  claim['start_time']='WRONG';invoke(['quartus'],gate.PROJECT,False);claim['start_time']='INERT-START'
  context=copy.deepcopy(context);context['argv']=context['argv']+['--unexpected'];invoke(['quartus'],gate.PROJECT,False)
  for cwd in [B/'work_ia840f_ipgen_04/syn/board/ia840f/syn_top',B/'work_ia840f_fim_05/syn/board/ia840f/syn_top',B/'work_ia840f_fim_06/syn/board/ia840f/syn_top',W,C,gate.PROJECT.parent]:invoke(['quartus'],cwd,False)
  with patch.object(common.shutil,'which',side_effect=lambda n:record['tools'][n]['path']):
   invoke(['run-native-compile'],gate.PROJECT,True)
   assert calls==[[record['tools']['quartus_sh']['path']]+gate.FLOW[1:]]
   for work in [str(B/'work_ia840f_ipgen_04'),str(B/'work_ia840f_fim_05'),str(B/'work_ia840f_fim_06'),str(W)+'/../work_ia840f_fim_07']:
    invoke(['native','compile','ia840f',work],C,False)
   real_open=Path.open;opened=[]
   def fixture_open(p,*a,**k):
    if p==gate.CLAIM:
     opened.append((str(p),a));return io.StringIO()
    return real_open(p,*a,**k)
   with patch.object(os,'getppid',return_value=102),patch.object(Path,'open',fixture_open):
    invoke(['native','compile','ia840f',str(W)],C,True)
    assert opened==[(str(gate.CLAIM),('x',))]
  results.append({'entry':str(path),'helper_args':calls,'runtime_load_calls':len(trace)})
 sys.path.pop(0)
assert not (E/'compile-authorization.json').exists() and not (E/'native-compile.claim.json').exists()
print(json.dumps({'result':'PASS','vendor_launched':False,'fixtures':'inert process/claim/record; future SOURCE two gate hashes; real filesystem paths and runtime checks','cases':results},indent=2))
