"""Actual runner with real inert Python child; mocked host/gate, isolated evidence.
No vendor executable is invoked. Regress raw status before failed log collection.
"""
from pathlib import Path
from unittest.mock import patch
import contextlib, importlib.util, io, json, os, subprocess, sys, tempfile, types
spec=importlib.util.spec_from_file_location('runner',Path(__file__).with_name('launch_native_compile.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
results=[]
for code,fail_log,expected in [(0,False,0),(7,False,7),(7,True,7),(0,True,1),(-15,False,143)]:
 with tempfile.TemporaryDirectory(prefix='work12-compile-runner-INERT-') as tmp:
  base=Path(tmp);(base/'source').mkdir();(base/'record').write_text('INERT')
  child="import sys;sys.exit(%d)"%code if code>=0 else "import os,signal;os.kill(os.getpid(),signal.SIGTERM)"
  gate=types.SimpleNamespace(load_record=lambda:{'work_inventory':{}},environment=lambda:None,work_inventory=lambda:{},CLAIM=base/'claim',RECORD=base/'record',sha=lambda p:'MOCK',TOP_ARGS=[sys.executable,'-c',child],common=types.SimpleNamespace(REJECTION_MARKERS=[b'INERT_REJECTION']))
  read=Path.read_bytes
  def rb(p):
   if fail_log and p.name=='native.log':raise OSError('INERT collection failure')
   return read(p)
  with patch.object(r,'E',base),patch.object(r,'C',base/'source'),patch.object(r.socket,'gethostname',return_value='Agilex7Workstation'),patch.object(r.os,'getuid',return_value=1000),patch.object(r.subprocess,'check_output',return_value='ia840f_mailbox_monitored_01'),patch.dict(sys.modules,{'ia840f_compile_gate':gate}),patch.dict(os.environ,{'TMUX':'INERT'},clear=False),patch.object(Path,'read_bytes',rb),contextlib.redirect_stdout(io.StringIO()):
   rc=r.run();assert rc==expected,(code,fail_log,rc)
   assert json.loads((base/'run/native-status.json').read_text())['native_returncode']==code
   before={str(p):read(p) for p in (base/'run').iterdir()}
   try:r.run()
   except FileExistsError:pass
   else:raise AssertionError('rerun accepted')
   assert before=={str(p):read(p) for p in (base/'run').iterdir()}
  results.append(dict(child_returncode=code,log_collection_failure=fail_log,outer_returncode=rc,raw_status_preserved=True,rerun_preserved=True))
print(json.dumps(dict(result='PASS',vendor_launched=False,mocked='host/tmux/gate only; actual inert children',cases=results),indent=2))
