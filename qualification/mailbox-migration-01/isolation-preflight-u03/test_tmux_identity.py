"""Execute only the actual two tmux statements with a synthetic subprocess.

Never invoke main, tmux, namespaces, or external programs in these tests.
The positive bytes below are an expectation, not a live workstation observation.
"""
import ast
import json
from types import SimpleNamespace
import unittest
from unittest import mock
import preflight as p

EXPECTED = b'ia840f_migration_preflight|$4|%4|25387\n'
FORMAT = '#{session_name}|#{session_id}|#{pane_id}|#{pane_pid}'


class TmuxIdentity(unittest.TestCase):
    def setUp(self):
        tree = ast.parse((p.HERE / 'preflight.py').read_text())
        main = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'main')
        indexes = [i for i, n in enumerate(main.body) if isinstance(n, ast.Assign)
                   and any(isinstance(t, ast.Name) and t.id == 'tmux' for t in n.targets)]
        self.assertEqual(len(indexes), 1)
        i = indexes[0]
        statements = main.body[i:i + 2]
        self.assertEqual(statements[1].value.func.id, 'require')
        # Restricted globals: no real subprocess or filesystem/namespace functions.
        self.code = compile(ast.Module(body=statements, type_ignores=[]), '<actual-tmux-statements>', 'exec')

    def check(self, stdout=EXPECTED, error=None):
        run = mock.Mock(return_value=SimpleNamespace(stdout=stdout), side_effect=error)
        fake = SimpleNamespace(run=run, DEVNULL=-3, PIPE=-1)
        try:
            exec(self.code, {'subprocess': fake, 'ENV': p.ENV, 'require': p.require})
        finally:
            run.assert_called_once_with(
                ['/usr/bin/tmux', '-S', '/tmp/tmux-1000/default', 'display-message',
                 '-p', '-t', 'ia840f_migration_preflight', FORMAT],
                stdin=-3, stdout=-1, stderr=-1, env={'PATH': '/usr/bin:/bin', 'LANG': 'C'},
                timeout=3, check=True)

    def refuse(self, stdout):
        with self.assertRaisesRegex(RuntimeError, '^named tmux pane identity drift$'):
            self.check(stdout)

    def test_exact_printable_representation_equal(self):
        self.check()

    def test_prior_recorded_underscore_return_refused(self):
        record = json.loads((p.HERE.parent / 'u02-stop-evidence.json').read_text())
        stdout = bytes.fromhex(record['stdout_hex'])
        self.assertEqual(stdout, b'ia840f_migration_preflight_$4_%4_25387\n')
        self.refuse(stdout)

    def test_session_name_mutation_refused(self):
        self.refuse(EXPECTED.replace(b'preflight', b'preflight_changed'))

    def test_session_id_mutation_refused(self):
        self.refuse(EXPECTED.replace(b'$4', b'$5'))

    def test_pane_id_mutation_refused(self):
        self.refuse(EXPECTED.replace(b'%4', b'%5'))

    def test_pane_pid_mutation_refused(self):
        self.refuse(EXPECTED.replace(b'25387', b'25388'))

    def test_no_whitespace_or_line_normalization(self):
        for value in (EXPECTED.replace(b'|', b'\t'), EXPECTED.replace(b'|', b' '),
                      EXPECTED.rstrip(b'\n'), EXPECTED + b'\n', b' ' + EXPECTED,
                      EXPECTED.replace(b'\n', b'\r\n'), EXPECTED.replace(b'|', b' | ')):
            with self.subTest(stdout=value):
                self.refuse(value)

    def test_no_field_loss_reordering_or_extra_output(self):
        fields = EXPECTED[:-1].split(b'|')
        for value in (b'|'.join(fields[:-1]) + b'\n', EXPECTED + b'extra',
                      b'|'.join([fields[0], fields[2], fields[1], fields[3]]) + b'\n',
                      EXPECTED.replace(b'|', b'||')):
            with self.subTest(stdout=value):
                self.refuse(value)

    def test_failed_query_propagates_without_retry(self):
        with self.assertRaisesRegex(OSError, 'inert failure'):
            self.check(error=OSError('inert failure'))


if __name__ == '__main__':
    unittest.main(verbosity=2)
