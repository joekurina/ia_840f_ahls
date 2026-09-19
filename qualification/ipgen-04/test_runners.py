"""Local inert-child regression; never launches vendor tools."""
from pathlib import Path
import hashlib,json,os,tempfile,unittest
from unittest.mock import patch
from types import SimpleNamespace
ROOT=Path(__file__).parent
class Runners(unittest.TestCase):
 def check_runner(self,name,stage,rc):
  with tempfile.TemporaryDirectory(dir=ROOT) as tmp:
   b=Path(tmp);r=b/'qualification/ipgen-04';r.mkdir(parents=True)
   auth=b/'ofs-agx7-pcie-attach/syn/board/ia840f/setup/experimental-authorization.json';auth.parent.mkdir(parents=True);auth.write_text('{}')
   (r/'authorization-issued.json').write_text(json.dumps({'sha256':hashlib.sha256(auth.read_bytes()).hexdigest()}))
   if stage!='setup':
    (r/'setup-result.json').write_text('{"returncode":0}')
    (r/'setup-full.log').write_text('fixture setup accepted')
   source=(ROOT/name).read_text().replace('/home/uwb_student00/ahls/new_BSP',str(b))
   def run():
    with patch.dict(os.environ,{'TMUX':'inert-fixture'}),patch('subprocess.run',return_value=SimpleNamespace(returncode=rc)) as child:
     try:exec(compile(source,name,'exec'),{'__name__':'__main__'})
     except SystemExit as exc:return exc.code,child.call_count
     return 0,child.call_count
   status,calls=run();self.assertEqual(status,rc);self.assertEqual(calls,1)
   self.assertEqual(json.loads((r/(stage+'-result.json')).read_text())['returncode'],rc)
   before={str(p.relative_to(r)):p.read_bytes() for p in r.rglob('*') if p.is_file()}
   with self.assertRaises((AssertionError,FileExistsError)):run()
   after={str(p.relative_to(r)):p.read_bytes() for p in r.rglob('*') if p.is_file()}
   self.assertEqual(before,after)
 def test_setup_failure_and_duplicate_preservation(self):self.check_runner('run-setup.py','setup',7)
 def test_setup_success_and_duplicate_preservation(self):self.check_runner('run-setup.py','setup',0)
 def test_post_failure_and_duplicate_preservation(self):self.check_runner('run-post-setup.py','project-ip',7)
if __name__=='__main__':unittest.main()
