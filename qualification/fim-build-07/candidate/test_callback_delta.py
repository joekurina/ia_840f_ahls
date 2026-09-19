"""Offline fixtures. No vendor invocation; inherited source/tool/claim checks exercised."""
import copy, importlib.util, json
from pathlib import Path
from unittest.mock import patch
from test_ia840f_compile_gate import CompileTests
import ia840f_compile_gate as gate
import unittest

class CallbackTests(CompileTests):
    def test_closed_grammar_delta(self):
        old_path=Path(__file__).parents[3]/'ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_compile_gate.py'
        spec=importlib.util.spec_from_file_location('original_gate',old_path);old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
        with patch.object(old,'WORK',gate.WORK),patch.object(old,'PROJECT',gate.PROJECT):old_commands=old.allowed_commands()
        commands=gate.allowed_commands()
        self.assertEqual(len(old_commands),135)
        self.assertEqual(commands,old_commands)  # Work07 changes routing, not IPC grammar.
        self.assertEqual(len(commands),len({tuple(x) for x in commands}))
        self.assertTrue(all(x in commands for x in old_commands))
        added=[x for x in commands if x not in old_commands]
        for args in added:
            if args[0]=='quartus_sh':
                self.assertEqual(args[1:3],['--ipc_mode','-t'])
                self.assertIn([args[0]]+args[2:],old_commands)
                self.assertTrue(args[3].endswith('/syn/shared_config/post_module_hook.tcl'))
            else:
                self.assertEqual(args[1:3],['--ipc_flow=17','--ipc_mode'])
                self.assertIn([args[0]]+args[3:],old_commands)
                self.assertNotIn('-t',args)
    def test_observed_callbacks_exact_and_negative_mutations(self):
        commands=gate.allowed_commands()
        observed=[['quartus_sh','--ipc_mode','-t','../../../../syn/shared_config/post_module_hook.tcl','quartus_ipgenerate','ofs_top','ofs_top'],
                  ['quartus_ipgenerate','--ipc_flow=17','--ipc_mode','ofs_top','-c','ofs_top','--run_default_mode_op'],
                  ['quartus_syn','--ipc_flow=17','--ipc_mode','--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_top']]
        gate.native('ia840f',str(self.work)); claim_bytes=self.claim.read_bytes()
        for args in observed:
            self.assertIn(args,commands)
            context=dict(executable='/opt/altera/26.1.1/quartus/linux64/'+args[0],sha256='MOCK-ELF-HASH',argv=args,cwd=str(self.project))
            self.record['contexts']=[context];self.save()
            gate.load_record();gate.check_context(self.record,context['executable'],args,str(self.project))
            mutations=[args+['--unexpected'],args+['-e'],[args[0],'--ipc_mode']+args[1:],[s.replace('=17','=18') for s in args],
                       [s.replace('post_module_hook.tcl','evil.tcl') for s in args],[s.replace('ofs_top','other') for s in args]]
            for bad in mutations:
                if bad==args:continue
                with self.subTest(args=bad):
                    self.assertNotIn(bad,commands)
                    with self.assertRaises(ValueError):gate.check_context(self.record,context['executable'],bad,str(self.project))
            with self.assertRaises(ValueError):gate.check_context(self.record,context['executable'],args,str(self.source))
        self.assertEqual(self.claim.read_bytes(),claim_bytes)
    def test_claim_ancestry_and_source_still_enforced(self):
        gate.native('ia840f',str(self.work));before=self.claim.read_bytes()
        with patch.object(gate,'start_time',return_value='REUSED'),self.assertRaises(ValueError):gate.claim_ancestor()
        with patch.object(gate.os,'getppid',return_value=1),self.assertRaises(ValueError):gate.claim_ancestor()
        (self.source/'src/input').write_text('changed')
        with self.assertRaises(ValueError):gate.load_record()
        self.assertEqual(self.claim.read_bytes(),before)

if __name__=='__main__':unittest.main()
