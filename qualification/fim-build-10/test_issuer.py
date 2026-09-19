"""Issuer tests with inert files and a mocked inventory gate. No remote writes."""
import importlib.util,json,os,tempfile,types,sys,unittest
from pathlib import Path
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('issuer',Path(__file__).parent/'remote-evidence/issue_authorization.py')
issuer=importlib.util.module_from_spec(spec);spec.loader.exec_module(issuer)
class IssuerTests(unittest.TestCase):
 def exercise(self,mutation=None):
  with tempfile.TemporaryDirectory() as td:
   n=Path(td);c=n/'source';w=n/'work';e=n/'qualification/fim-build-10';e.mkdir(parents=True)
   old=n/'qualification/fim-build-05';old.mkdir()
   source='syn/board/ia840f/setup/emif_loc.tcl';gatefile='ofs-common/tools/ofss_config/ia840f_compile_gate.py'
   overlays={};before={}
   timing='syn/board/ia840f/syn_top/ofs_top.qsf'
   for rel in [source,gatefile,timing]:
    for root,text in [(c,'old'),(w,'candidate'),(e/'source-overlay','candidate')]:
     p=root/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text)
    before[rel]=issuer.sha(c/rel);overlays[rel]=issuer.sha(w/rel)
   inherited={'source_review':{'accepted':True,'files':{source:overlays[source]}}}
   (old/'consumed-reviews.json').write_text(json.dumps(inherited))
   for name,data in [('source-before.json',before),('overlay-sha256.json',overlays),('compile-authorization.draft.json',{'work_inventory':{},'source_sha256':{},'dependency_sha256':{}})]:
    (e/name).write_text(json.dumps(data))
   for name in ['issue_authorization.py','launch_native_compile.py']:(e/name).write_text('inert')
   review={'timing_review':{'accepted':True,'files':{timing:overlays[timing]}},'gate_review':{'accepted':True,'files':{gatefile:overlays[gatefile]}},'handoff_files':{name:issuer.sha(e/name) for name in ['issue_authorization.py','launch_native_compile.py','compile-authorization.draft.json']}}
   if mutation=='timing':review['timing_review']['files']={}
   if mutation=='review':review['gate_review']['accepted']=False
   if mutation=='handoff':review['handoff_files']['issue_authorization.py']='wrong'
   if mutation=='source':(c/source).write_text('mutated')
   if mutation=='inherited':(old/'consumed-reviews.json').write_text('{}')
   rp=e/'reviews.json';rp.write_text(json.dumps(review))
   fake=types.SimpleNamespace(work_inventory=lambda:{},common=types.SimpleNamespace(TREES=[]))
   with patch.object(issuer,'N',n),patch.object(issuer,'C',c),patch.object(issuer,'W',w),patch.object(issuer,'E',e),patch.object(issuer.socket,'gethostname',return_value='Agilex7Workstation'),patch.object(issuer.os,'getuid',return_value=1000),patch.dict(os.environ,{'TMUX':'fixture'}),patch.dict(sys.modules,{'ia840f_compile_gate':fake}):
    if mutation:
     with self.assertRaises((AssertionError,KeyError)):issuer.issue(rp)
     self.assertFalse((e/'compile-authorization.json').exists());self.assertFalse((e/'authorization-issuance.lock').exists())
     self.assertEqual((c/gatefile).read_text(),'old')
    else:
     issuer.issue(rp);out=(e/'compile-authorization.json').read_bytes()
     self.assertTrue(json.loads(out)['approved'])
     with self.assertRaises(AssertionError):issuer.issue(rp)
     self.assertEqual((e/'compile-authorization.json').read_bytes(),out)
 def test_positive_and_exclusive_reissue(self):self.exercise()
 def test_review_handoff_source_and_inherited_rejections(self):
  for case in ['timing','review','handoff','source','inherited']:
   with self.subTest(case=case):self.exercise(case)
if __name__=='__main__':unittest.main()
