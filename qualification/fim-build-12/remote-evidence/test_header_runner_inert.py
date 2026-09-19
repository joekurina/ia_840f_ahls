"""Exercise header outer runner with real inert children, never vendor fixtures."""
from pathlib import Path
from unittest.mock import patch
import os,sys,json,importlib.util,contextlib,tempfile,hashlib
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12'
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('headers_runner',E/'run_headers.py');mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);gate=mod.gate
orig_env=dict(os.environ);results=[]
for expected in [0,17]:
 tmp=Path(tempfile.mkdtemp(prefix='header-inert-',dir=E));(tmp/'work').mkdir();project=tmp/'work';out=project/'fresh.txt'
 child='from pathlib import Path; Path('+repr(str(out))+').write_text("inert output"); raise SystemExit('+str(expected)+')'
 record=dict(work_inventory={},required_outputs=['fresh.txt'],tools={'quartus_sh':{'path':'/usr/bin/python3'}})
 def inventory():return {}
 with contextlib.ExitStack() as s:
  for name,value in [('E',tmp),('W',project)]:s.enter_context(patch.object(mod,name,value))
  for name,value in [('PROJECT',project),('RECORD',tmp/'header-authorization.json'),('CLAIM',tmp/'header-run/claim.json'),('TOP_ARGS',['python3','-B',str(tmp/'run_headers.py')]),('HEADER_ARGS',['python3','-c',child])]:s.enter_context(patch.object(gate,name,value))
  s.enter_context(patch.object(gate,'load_record',return_value=record));s.enter_context(patch.object(gate,'environment',return_value=None));s.enter_context(patch.object(gate,'work_inventory',side_effect=inventory))
  realsha=gate.sha;s.enter_context(patch.object(gate,'sha',side_effect=lambda p:'INERT' if Path(p)==gate.RECORD else realsha(p)))
  s.enter_context(patch.object(gate.common,'process',return_value=(gate.PYTHON_EXE,gate.TOP_ARGS,str(project))))
  s.enter_context(patch.object(sys,'argv',[str(tmp/'run_headers.py')]))
  os.chdir(project);rc=mod.run();assert rc==expected,(rc,expected)
  before={str(p.relative_to(tmp)):realsha(p) for p in tmp.rglob('*') if p.is_file()}
  try:mod.run()
  except (AssertionError,FileExistsError):pass
  else:raise AssertionError('rerun accepted')
  assert before=={str(p.relative_to(tmp)):realsha(p) for p in tmp.rglob('*') if p.is_file()}
  results.append(dict(inert_dir=str(tmp),rc=rc,rerun_evidence_unchanged=True))
 os.environ.clear();os.environ.update(orig_env)
with (E/'header-runner-inert-results.json').open('x') as f:json.dump(dict(cases=results,vendor_launched=False),f,indent=2)
print(json.dumps(results))
