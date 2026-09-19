"""Inert policy fixtures only. Never launches a vendor executable."""
import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from contextlib import ExitStack
from unittest.mock import patch
import ia840f_compile_gate as gate
import ia840f_experimental_gate as common


class CompileTests(unittest.TestCase):
    def setUp(self):
        self.s = ExitStack(); self.addCleanup(self.s.close)
        root = Path(self.s.enter_context(tempfile.TemporaryDirectory()))
        self.source, self.work, self.pim, self.evidence = [root/x for x in ('source','work','pim','evidence')]
        self.project = self.work/'syn/board/ia840f/syn_top'
        self.project.mkdir(parents=True); self.pim.mkdir(); self.evidence.mkdir()
        for t in common.TREES:
            (self.source/t).mkdir(parents=True); (self.source/t/'input').write_text('source fixture')
        (self.pim/'input').write_text('pim fixture')
        (self.project/'build_env_db.txt').write_text('Q_REVISION=ofs_top\nQ_PR_REVISION=ofs_pr_afu\n')
        self.record_path = self.evidence/'compile-authorization.json'
        self.claim = self.evidence/'native-compile.claim.json'
        for module, name, value in [(gate,'SOURCE',self.source),(gate,'WORK',self.work),
                (gate,'PROJECT',self.project),(gate,'EVIDENCE',self.evidence),(gate,'RECORD',self.record_path),
                (gate,'CLAIM',self.claim),(common,'PIM',self.pim)]:
            self.s.enter_context(patch.object(module,name,value))
        self.args = [gate.TOP,'--stage=compile','-k','-p','ia840f',str(self.work)]
        self.s.enter_context(patch.object(gate,'TOP_ARGS',self.args))
        self.child = self.source/'ofs-common/scripts/common/syn/build_fim_compile.sh'
        self.s.enter_context(patch.object(gate,'CHILD',self.child))
        tools={}
        for n in common.TOOLS:
            p=root/n; p.write_text('INERT NEVER EXECUTED '+n)
            tools[n]=dict(path=str(p),sha256=common.sha(p))
        self.s.enter_context(patch.object(common,'INNER_TOOL_PATHS',{n:tools[n]['path'] for n in common.INNER_TOOL_PATHS}))
        self.s.enter_context(patch.object(common.shutil,'which',lambda n:tools[n]['path']))
        real_sha=common.sha
        self.s.enter_context(patch.object(gate,'sha',lambda p:'MOCK-ELF-HASH' if str(p).startswith('/opt/') else real_sha(p)))
        self.context: dict = dict(executable=common.RUNTIME_EXES['quartus_sh'],sha256='MOCK-ELF-HASH',argv=gate.FLOW,cwd=str(self.project))
        self.record: dict = dict(schema=1,approved=True,accepted_execution=True,ready_for_build=False,
            source_review_consumed=True,gate_review_consumed=True,target='ia840f',part=common.PART,
            toolchain=common.VERSION,source=str(self.source),work=str(self.work),pim=str(self.pim),
            permissions=['native-full-compile'],source_sha256={t:common.inventory(self.source/t) for t in common.TREES},
            pim_sha256=common.inventory(self.pim),tools=tools,quartus_tools=copy.deepcopy(tools),
            contexts=[self.context],dependency_sha256={},native_argv=self.args,native_cwd=str(self.source),
            work_inventory=gate.work_inventory())
        self.save()
        self.env=dict(OFS_ROOTDIR=str(self.source),OFS_PLATFORM_AFU_BBB=str(self.pim),KEEP_WORK_ARG='-k',
                      DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus')
        self.s.enter_context(patch.dict(os.environ,self.env,clear=True))
        self.s.enter_context(patch.object(Path,'cwd',return_value=self.source))
        self.s.enter_context(patch.object(common,'process',return_value=('/usr/bin/bash',['/bin/bash']+self.args,str(self.source))))

    def save(self): self.record_path.write_text(json.dumps(self.record))

    def test_record_and_native_claim_positive_inert(self):
        gate.load_record(); gate.native('ia840f',str(self.work))
        data=self.claim.read_bytes()
        with self.assertRaises(FileExistsError): gate.native('ia840f',str(self.work))
        self.assertEqual(self.claim.read_bytes(),data)

    def test_wrong_source_tool_part_readiness_review_work(self):
        mutations=[('part','OTHER'),('work',str(common.WORK)),('ready_for_build',True),
                   ('accepted_execution',False),('approved',False),('source_review_consumed',False),
                   ('gate_review_consumed',False),('permissions',['setup'])]
        for k,v in mutations:
            old=self.record[k];self.record[k]=v;self.save()
            with self.subTest(k=k),self.assertRaises(ValueError):gate.load_record()
            self.record[k]=old
        self.save()
        (self.source/'src/input').write_text('stale')
        with self.assertRaises(ValueError):gate.load_record()
        (self.source/'src/input').write_text('source fixture')
        tool=Path(self.record['tools']['quartus_sh']['path']);tool.write_text('WRONG TOOL')
        with self.assertRaises(ValueError):gate.load_record()

    def test_missing_record_and_work_mutation(self):
        self.record_path.unlink()
        with self.assertRaises(FileNotFoundError):gate.native('ia840f',str(self.work))
        self.save();(self.work/'evil.tcl').write_text('mutation')
        with self.assertRaises(ValueError):gate.native('ia840f',str(self.work))
        self.assertFalse(self.claim.exists())

    def test_native_wrong_argv_cwd_work_and_options(self):
        for work in (str(common.WORK),str(self.work)+'/../work','/tmp/work'):
            with self.assertRaises(ValueError):gate.native('ia840f',work)
        for key in ('SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_BUILD_TAG_X'):
            with patch.dict(os.environ,{key:'1'}),self.assertRaises(ValueError):gate.native('ia840f',str(self.work))
        for argv in (self.args+['-e'], self.args[:-1],['bash','evil.sh']):
            with patch.object(common,'process',return_value=('/usr/bin/bash',argv,str(self.source))),self.assertRaises(ValueError):
                gate.native('ia840f',str(self.work))
        with patch.object(Path,'cwd',return_value=self.project),self.assertRaises(ValueError):gate.native('ia840f',str(self.work))
        self.assertFalse(self.claim.exists())

    def test_exact_runtime_and_native_ancestry(self):
        c=self.context
        gate.check_context(self.record,c['executable'],c['argv'],c['cwd'])
        for exe,args,cwd in [(c['executable'],c['argv']+['-end','dni_elaboration'],c['cwd']),
                (c['executable'],['quartus_sh','--prepare','-r','ofs_top','ofs_top'],c['cwd']),
                (c['executable'].replace('/linux64/','/bin/'),c['argv'],c['cwd']),
                (c['executable'],c['argv'],str(common.PROJECT))]:
            with self.assertRaises(ValueError):gate.check_context(self.record,exe,args,cwd)
        with patch.object(gate,'load_record',return_value=self.record),self.assertRaises(FileNotFoundError):gate.quartus_context()
        gate.native('ia840f',str(self.work));gate.claim_ancestor()
        with patch.object(gate,'start_time',return_value='stale'),self.assertRaises(ValueError):gate.claim_ancestor()

    def test_runtime_requires_recorded_hash(self):
        self.record['contexts'][0]['sha256']='WRONG'
        with self.assertRaises(ValueError):gate.check_context(self.record,self.context['executable'],gate.FLOW,str(self.project))

    def test_symlink_escape(self):
        (self.work/'escape').symlink_to(self.source/'src/input')
        with self.assertRaises(ValueError):gate.work_inventory()


class RealShellRejection(unittest.TestCase):
    def test_native_no_record_no_side_effects(self):
        source=Path(__file__).resolve().parents[3]
        log=source/'build_fim_work_ia840f_fim_05.log'
        old=log.read_bytes() if log.exists() else None
        env=dict(os.environ,OFS_ROOTDIR=str(source),OFS_PLATFORM_AFU_BBB=str(common.PIM),
                 QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus')
        for work in (str(gate.WORK),str(common.WORK)):
            result=subprocess.run(['bash',str(source/'ofs-common/scripts/common/syn/build_top.sh'),
                '--stage=compile','-k','-p','ia840f',work],cwd=source,env=env,capture_output=True)
            self.assertNotEqual(result.returncode,0)
        self.assertEqual(log.read_bytes() if log.exists() else None,old)

if __name__=='__main__':unittest.main()
