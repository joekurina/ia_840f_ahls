"""SYNTHETIC FIXTURES ONLY: never import/run launcher, transport or collector."""
import base64
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

import receiver as r

HERE = Path(__file__).resolve().parent


def wire(value):
    return (json.dumps(value, ensure_ascii=True, separators=(',', ':')) + '\n').encode('ascii')


def stream(data):
    return dict(length=len(data), sha256=hashlib.sha256(data).hexdigest(),
                base64=base64.b64encode(data).decode('ascii'))


def fixture():
    # Invented counts, times and paths; these are NOT observations of any host.
    collector = dict(authorization=False, ready_for_build=False, vendor_run=False,
                     terminal=dict(result='completed'), guard='passed', close_errors=[],
                     counts=dict(visited=1, discovered=1), selection=[], roots=['/usr'],
                     identity=dict(host='Agilex7Workstation', uid=1000, euid=1000,
                                   user='uwb_student00', logname='uwb_student00',
                                   tmux='/tmp/tmux-1000/default,7828,4'),
                     last_completed=dict(operation='scandir.close', path='/usr'), elapsed=0.5)
    outer = dict(authorization=False, ready_for_build=False, vendor_run=False,
                 terminal='completed', reaped=True, wait_status=0, timed_out=False,
                 errors=[], elapsed=1.0, collector_length=13851,
                 collector_sha256=r.COLLECTOR_SHA,
                 launcher_binding=dict(length=30087, sha256=r.LAUNCHER_SHA),
                 stdout=stream(wire(collector)), stderr=stream(b'fixture stderr\x00\xff\n'))
    return outer, collector


class ReceiverFixtures(unittest.TestCase):
    def check_incomplete(self, raw, status=0):
        result, _ = r.evaluate(raw, status)
        self.assertEqual(result['classification'], 'INCOMPLETE')
        self.assertTrue(result['issues'])
        return result

    def test_success_and_whitespace(self):
        outer, _ = fixture()
        raw = b' \t\r\n' + wire(outer) + b'\r\n '
        result, streams = r.evaluate(raw, 0)
        self.assertEqual(result['classification'], 'COMPLETED')
        self.assertEqual(result['observation'], 'successful_current_traversal')
        self.assertEqual(streams['stderr'], b'fixture stderr\x00\xff\n')
        self.assertFalse(result['historical_cause_established'])

    def test_missing_nonzero_and_wrong_type_status(self):
        for status in (None, 1, -9, True, False, '0', 0.0):
            with self.subTest(status=status):
                self.check_incomplete(wire(fixture()[0]), status)

    def test_json_corruption(self):
        raw = wire(fixture()[0])
        for bad in (b'', raw[:-3], raw + b'{}', raw + b'x', b'[]', b'null',
                    b'\xef\xbb\xbf' + raw, b'\xff',
                    b'{"terminal":1,"terminal":2}', b'{"n":NaN}',
                    b'{"n":Infinity}', b'[' * 1500 + b']' * 1500):
            with self.subTest(length=len(bad)):
                self.check_incomplete(bad)

    def test_required_envelope_fields(self):
        base, _ = fixture()
        changes = dict(terminal='INCOMPLETE', reaped=False, wait_status=False,
                       timed_out=0, errors=['fixture'], elapsed=-1,
                       collector_length=13850, collector_sha256='0' * 64,
                       launcher_binding=None)
        for key, value in changes.items():
            for missing in (False, True):
                with self.subTest(key=key, missing=missing):
                    obj = copy.deepcopy(base)
                    if missing:
                        del obj[key]
                    else:
                        obj[key] = value
                    self.check_incomplete(wire(obj))
        for binding in (dict(length=30086, sha256=r.LAUNCHER_SHA),
                        dict(length=30087, sha256='0' * 64)):
            obj = copy.deepcopy(base)
            obj['launcher_binding'] = binding
            self.check_incomplete(wire(obj))

    def test_flags_both_layers(self):
        for layer in ('outer', 'collector'):
            for key in r.FLAGS:
                for value in (True, 0, None, 'false'):
                    with self.subTest(layer=layer, key=key, value=value):
                        obj, report = fixture()
                        target = obj if layer == 'outer' else report
                        target[key] = value
                        if layer == 'collector':
                            obj['stdout'] = stream(wire(report))
                        self.check_incomplete(wire(obj))
                obj, report = fixture()
                del (obj if layer == 'outer' else report)[key]
                if layer == 'collector':
                    obj['stdout'] = stream(wire(report))
                self.check_incomplete(wire(obj))

    def test_stream_integrity_and_retention(self):
        for name in ('stdout', 'stderr'):
            for key, value in (('length', 0), ('length', False), ('sha256', 'a' * 64),
                               ('base64', '!!!!'), ('base64', 'YQ==\n'),
                               ('base64', 'YR=='), ('base64', 'YQ==='),
                               ('base64', '\u00e9'), ('base64', None)):
                with self.subTest(name=name, key=key, value=value):
                    obj, _ = fixture()
                    obj[name][key] = value
                    self.check_incomplete(wire(obj))
            obj, _ = fixture()
            obj[name]['sha256'] = 'bad'
            result, decoded = r.evaluate(wire(obj), 0)
            self.assertEqual(result['classification'], 'INCOMPLETE')
            self.assertIn(name, decoded)  # Exact decodable evidence despite hash failure.

    def test_stream_and_outer_limits(self):
        obj, report = fixture()
        data = wire(report)
        obj['stdout'] = stream(data + b' ' * (r.STREAM_CAP - len(data)))
        obj['stderr'] = stream(b'x' * r.STREAM_CAP)
        raw = wire(obj)
        self.assertLess(len(raw), r.OUTER_CAP)
        self.assertEqual(r.evaluate(raw, 0)[0]['classification'], 'COMPLETED')
        self.assertEqual(r.evaluate(raw + b' ' * (r.OUTER_CAP - len(raw)), 0)[0]['classification'], 'COMPLETED')
        self.check_incomplete(raw + b' ' * (r.OUTER_CAP - len(raw) + 1))
        for name in ('stdout', 'stderr'):
            obj, _ = fixture()
            obj[name] = stream(b'x' * (r.STREAM_CAP + 1))
            self.check_incomplete(wire(obj))

    def test_collector_failures(self):
        for data in (b'', b'{}', b'[]', b'{"x":NaN}', wire(fixture()[1]) + b'{}'):
            obj, _ = fixture()
            obj['stdout'] = stream(data)
            self.check_incomplete(wire(obj))
        for key, value in (('terminal', {}), ('guard', 'not_checked'),
                           ('close_errors', [dict(operation='scandir.close', path='/fixture')]),
                           ('elapsed', float('inf')), ('counts', {}), ('identity', {})):
            obj, report = fixture()
            report[key] = value
            obj['stdout'] = stream(wire(report))
            self.check_incomplete(wire(obj))

    def test_exact_error_path_and_coherent_error_observation(self):
        obj, report = fixture()
        failure = dict(phase='traversal', operation='scandir.iterate',
                       path='/usr/FIXTURE/../not-normalized/\udcff\n', exception='PermissionError',
                       errno=13, filename='/usr/FIXTURE/original', filename2=None, reason=None,
                       selected_root='/usr', counts=dict(visited=1, discovered=1), elapsed=0.4)
        report['terminal'] = failure
        obj.update(terminal='INCOMPLETE', wait_status=256)
        obj['stdout'] = stream(wire(report))
        result = self.check_incomplete(wire(obj), 1)
        self.assertEqual(result['observation'], 'observed_current_filesystem_error')
        self.assertEqual(result['collector_terminal'], failure)
        for key, value in (('timed_out', True), ('errors', ['capture_failure'])):
            bad = copy.deepcopy(obj)
            bad[key] = value
            self.assertEqual(self.check_incomplete(wire(bad), 1)['observation'], 'unvalidated_or_incomplete')
        obj['stdout']['sha256'] = 'bad'
        self.assertEqual(self.check_incomplete(wire(obj), 1)['observation'], 'unvalidated_or_incomplete')

    def test_arbitrary_field_types_fail_closed_without_crashing(self):
        bad_values = (None, True, 0, '', [], {}, ['x'])
        base, report = fixture()
        for key in base:
            for value in bad_values:
                if type(value) is type(base[key]) and value == base[key]:
                    continue
                if key == 'elapsed' and type(value) is int and value >= 0:
                    continue
                with self.subTest(layer='outer', key=key, value=value):
                    obj = copy.deepcopy(base)
                    obj[key] = value
                    self.check_incomplete(wire(obj))
        for key in ('terminal', 'guard', 'close_errors', 'counts', 'elapsed', 'identity', 'roots'):
            for value in bad_values:
                if type(value) is type(report[key]) and value == report[key]:
                    continue
                # A numeric nonnegative elapsed, unlike other substitutions, is valid.
                if key == 'elapsed' and type(value) is int and value >= 0:
                    continue
                with self.subTest(layer='collector', key=key, value=value):
                    obj, inner = fixture()
                    inner[key] = value
                    obj['stdout'] = stream(wire(inner))
                    self.check_incomplete(wire(obj))

    def test_transport_error(self):
        result, _ = r.evaluate(wire(fixture()[0]), 0, ['fixture disconnect'])
        self.assertEqual(result['classification'], 'INCOMPLETE')

    def test_cli_preserves_raw_status_and_streams(self):
        with tempfile.TemporaryDirectory(dir=HERE, prefix='fixture-') as tmp:
            p = Path(tmp)
            raw = b' \n' + wire(fixture()[0]) + b'\t'
            (p / 'input').write_bytes(raw)
            (p / 'err').write_bytes(b'outer fixture stderr\xff')
            command = [sys.executable, '-B', str(HERE / 'receiver.py'), '--raw', str(p / 'input'),
                       '--command-stderr', str(p / 'err'), '--output', str(p / 'out')]
            run = subprocess.run(command + ['--exit-status', '0'], capture_output=True)
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertEqual((p / 'out/raw-envelope.bin').read_bytes(), raw)
            self.assertEqual((p / 'out/command-stderr.bin').read_bytes(), b'outer fixture stderr\xff')
            self.assertEqual((p / 'out/collector-stderr.bin').read_bytes(), b'fixture stderr\x00\xff\n')
            self.assertEqual(json.loads((p / 'out/result.json').read_bytes())['command_exit_status'], 0)
            self.assertNotEqual(subprocess.run(command, capture_output=True).returncode, 0)
            # Fresh directory, missing status, still retain exact raw input.
            command[-1] = str(p / 'missing')
            self.assertEqual(subprocess.run(command, capture_output=True).returncode, 1)
            self.assertEqual((p / 'missing/raw-envelope.bin').read_bytes(), raw)
            # Oversize parse rejected, but whole original evidence remains on disk.
            big = b'x' * (r.OUTER_CAP + 1)
            (p / 'input').write_bytes(big)
            command[-1] = str(p / 'oversize')
            self.assertEqual(subprocess.run(command, capture_output=True).returncode, 1)
            self.assertEqual((p / 'oversize/raw-envelope.bin').read_bytes(), big)


if __name__ == '__main__':
    unittest.main(verbosity=2)
