"""Only synthetic programs run here; approved decoder is used unchanged."""
import ast
import hashlib
import json
import os
from pathlib import Path
import unittest
import fixture
import startup

ROOT = Path(__file__).resolve().parent
TOKEN = 'c' * 32
PAYLOAD = (b'import os,sys,json\n'
           b'os.write(1,(json.dumps(dict(ppid=os.getppid(),eof=os.read(0,1)==b""))+"\\n").encode())\n'
           b'os.write(1,bytes(range(256))*32)\n'
           b'os.write(2,bytes(reversed(range(256)))*32)\n'
           b'sys.exit(23)\n')

class StartupTests(unittest.TestCase):
    def run_case(self, name, faults=None):
        return fixture.run(name, PAYLOAD, TOKEN, faults or {})

    def test_normal(self):
        r = self.run_case('normal')
        decoded = fixture.decode(r['raw'], TOKEN)
        identity, body = decoded['stdout'].split(b'\n', 1)
        self.assertEqual(json.loads(identity), dict(ppid=r['pid'], eof=True))
        self.assertEqual(body, bytes(range(256))*32)
        self.assertEqual(decoded['stderr'], bytes(reversed(range(256)))*32)
        self.assertEqual(decoded['status'], 23)
        self.assertTrue(r['restored'])
        self.assertEqual(r['traps_before'], r['traps_after'])
        self.assertIn(b' P none C none T 0', r['raw'])

    def test_each_failure_and_timeout_prevents_dispatch(self):
        for role in ('relay', 'O', 'E'):
            for fault in ('fail', 'timeout', 'fd'):
                with self.subTest(role=role, fault=fault):
                    r = self.run_case(role+'-'+fault, {role: fault})
                    self.assertNotIn(b' S ', r['raw'])
                    self.assertNotIn(b' DISPATCH\n', r['raw'])
                    self.assertIn(('P '+role+'_readiness').encode(), r['raw'])
                    self.assertTrue(r['restored'])
                    with self.assertRaises(fixture.Incomplete): fixture.decode(r['raw'], TOKEN)

    def test_partial_setup_and_cleanup_errors_separate(self):
        r = self.run_case('partial-cleanup', {'E':'fail', 'cleanup_O':'fail', 'restore':'fail'})
        self.assertIn(b'P E_readiness', r['raw'])
        self.assertIn(b'O:74', r['raw'])
        self.assertIn(b'restore:75', r['raw'])
        self.assertNotIn(b' DISPATCH\n', r['raw'])
        self.assertFalse(r['restored'])
        with self.assertRaises(fixture.Incomplete): fixture.decode(r['raw'], TOKEN)

    def test_apply_failure_restores(self):
        r = self.run_case('apply-fail', {'apply':'fail'})
        self.assertIn(b'P apply', r['raw'])
        self.assertTrue(r['restored'])
        self.assertNotIn(b' DISPATCH\n', r['raw'])

    def test_restore_failure_rejects_success(self):
        r = self.run_case('restore-fail', {'restore':'fail'})
        self.assertIn(b' S 23 0 0 0', r['raw'])
        self.assertIn(b' R 0 75', r['raw'])
        with self.assertRaises(fixture.Incomplete): fixture.decode(r['raw'], TOKEN)

    def test_bytes_and_grammar(self):
        payload = bytes(range(256))*161
        text = startup.command(payload, TOKEN)
        self.assertEqual(startup.extract_payload(text), payload)
        self.assertLess(max(map(len,text.splitlines())), 1024)
        self.assertIn('d_ps=("${PIPESTATUS[@]}")', text)
        self.assertNotIn('trap ', text)
        for p in ROOT.glob('*.py'):
            ast.parse(p.read_text(), filename=str(p), feature_version=(3,9))
        with self.assertRaises(ValueError): startup.command(b'', 'invalid')

if __name__ == '__main__': unittest.main()
