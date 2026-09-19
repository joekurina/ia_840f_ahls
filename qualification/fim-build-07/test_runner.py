"""Exercise outer runner persistence/exit semantics with real inert Python children."""
import importlib.util,json,os,subprocess,sys,tempfile,types,unittest
from pathlib import Path
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('runner',Path(__file__).with_name('launch_native_compile.py'))
runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)

class RunnerTests(unittest.TestCase):
 def exercise(self,rc,text):
  with tempfile.TemporaryDirectory() as d:
   root=Path(d);(root/'source').mkdir();(root/'evidence').mkdir();record=root/'auth';record.write_text('inert fixture')
   gate=types.SimpleNamespace(load_record=lambda:{'work_inventory':{'fixture':True}},environment=lambda:None,
        work_inventory=lambda:{'fixture':True},CLAIM=root/'claim',RECORD=record,sha=lambda p:'inert-fixture-hash',
        TOP_ARGS=[sys.executable,'-c',f'import sys;print({text!r});sys.exit({rc})'],
        common=types.SimpleNamespace(REJECTION_MARKERS=(b'IA840F_GATE_REJECTED',b'Critical Warning (125091)')))
   # Only child is an actual Python print/exit process. No vendor commands.
   with patch.object(runner,'N',root),patch.object(runner,'C',root/'source'),patch.object(runner,'E',root/'evidence'),\
        patch.object(runner,'W',root/'work'),patch.object(runner.socket,'gethostname',return_value='Agilex7Workstation'),\
        patch.object(runner.os,'getuid',return_value=1000),patch.dict(os.environ,{'TMUX':'fixture'},clear=True),\
        patch.object(runner.subprocess,'check_output',return_value='ia840f_mailbox_monitored_01\n'),\
        patch.dict(sys.modules,{'ia840f_compile_gate':gate}):
    got=runner.run();status=json.loads((root/'evidence/run/status.json').read_text())
    saved={p.name:p.read_bytes() for p in (root/'evidence/run').iterdir()}
    with self.assertRaises(FileExistsError):runner.run()
    self.assertEqual(saved,{p.name:p.read_bytes() for p in (root/'evidence/run').iterdir()})
    self.assertEqual(status['native_returncode'],rc)
    self.assertFalse(status['functional_acceptance'])
    return got,status
 def test_native_error_propagated(self):
  got,status=self.exercise(7,'inert error fixture');self.assertEqual(got,7)
 def test_zero_rejection_not_accepted(self):
  got,status=self.exercise(0,'Critical Warning (125091): IA840F_GATE_REJECTED');self.assertEqual(got,1);self.assertFalse(status['native_exit_accepted'])
 def test_zero_is_exit_only_not_functional_acceptance(self):
  got,status=self.exercise(0,'inert pass fixture');self.assertEqual(got,0);self.assertTrue(status['native_exit_accepted'])
if __name__=='__main__':unittest.main()
