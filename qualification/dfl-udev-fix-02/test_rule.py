#!/usr/bin/env python3
"""Inert model of this finite rule grammar. Never invokes udev or RUN commands."""
import copy
import fnmatch
import hashlib
import json
import re
import unittest
from pathlib import Path
from typing import TypedDict


class Event(TypedDict):
    action: str
    kernel: str
    parents: list[dict[str, str]]

HERE = Path(__file__).resolve().parent
RULE = HERE / '90-intel-fpga-opencl.rules.candidate'
ORIGINAL = HERE.parent / 'source-resume-01/remote/etc/udev/rules.d/90-intel-fpga-opencl.rules'
TOKEN = re.compile(r'(ACTION|KERNEL|KERNELS|SUBSYSTEMS|ATTRS\{(?:vendor|device|subsystem_vendor|subsystem_device)\}|OWNER|GROUP|MODE|RUN|LABEL|GOTO)(==|\+=|=)"([^"\n]*)"')


def match(value, pattern):
    return any(fnmatch.fnmatchcase(value, p) for p in pattern.split('|'))


def parse(text):
    lines = []
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        tokens = []
        for token in line.split(','):
            m = TOKEN.fullmatch(token.strip())
            if not m:
                raise ValueError('unsupported rule grammar: ' + token)
            key, op, value = m.groups()
            allowed = '==' if key in {'ACTION', 'KERNEL', 'KERNELS', 'SUBSYSTEMS'} or key.startswith('ATTRS{') else '+=' if key == 'RUN' else '='
            if op != allowed:
                raise ValueError('invalid operator')
            tokens.append((key, op, value))
        lines.append(tokens)
    return lines


def evaluate(event, text=None):
    lines = parse(RULE.read_text() if text is None else text)
    labels = {}
    for i, tokens in enumerate(lines):
        for key, _, value in tokens:
            if key == 'LABEL':
                if value in labels:
                    raise ValueError('duplicate label')
                labels[value] = i
    result = {'permissions': {}, 'run': []}
    pc = 0
    while pc < len(lines):
        tokens = lines[pc]
        pc += 1
        current = [(k, v) for k, op, v in tokens if op == '==' and k in {'ACTION', 'KERNEL'}]
        if any(not match(event[k.lower()], v) for k, v in current):
            continue
        parents = [(k, v) for k, op, v in tokens if op == '==' and k not in {'ACTION', 'KERNEL'}]
        def parent_match(parent):
            for key, value in parents:
                name = {'SUBSYSTEMS': 'subsystem', 'KERNELS': 'kernel'}.get(key, key[6:-1])
                if not match(parent.get(name, ''), value):
                    return False
            return True
        if parents and not any(parent_match(p) for p in event['parents']):
            continue
        for key, op, value in tokens:
            if op == '==':
                continue
            if key == 'GOTO':
                if value not in labels or labels[value] < pc:
                    raise ValueError('missing or backward label')
                pc = labels[value] + 1
            elif key == 'RUN':
                result['run'].append(value)  # data only; never execute
            elif key != 'LABEL':
                result['permissions'][key] = value
    return result


def check_access(event, resources):
    result = evaluate(event)
    if result['permissions'] and 'device_node' not in resources:
        raise FileNotFoundError('required device node absent')
    return result


def fixture(*, action: str = 'add', kernel: str = 'dfl-port.0',
            parents: list[dict[str, str]] | None = None) -> Event:
    if parents is None:
        parents = [dict(subsystem='pci', kernel='0000:4f:00.0',
                        vendor='0x8086', device='0xbcce',
                        subsystem_vendor='0x8086', subsystem_device='0x1771')]
    return {'action': action, 'kernel': kernel, 'parents': parents}


class Rules(unittest.TestCase):
    def unchanged(self, event):
        self.assertEqual(evaluate(event), evaluate(event, ORIGINAL.read_text()))

    def test_target_port(self):
        self.assertEqual(check_access(fixture(), {'device_node', 'errors', 'userclk'}),
                         {'permissions': dict(OWNER='root', GROUP='uwb_student00', MODE='0660'), 'run': []})

    def test_target_fme(self):
        self.assertEqual(evaluate(fixture(kernel='dfl-fme.0')),
                         {'permissions': dict(OWNER='root', GROUP='root', MODE='0600'), 'run': []})

    def test_optional_absent(self):
        self.assertEqual(check_access(fixture(), {'device_node'})['run'], [])

    def test_required_absent(self):
        with self.assertRaises(FileNotFoundError):
            check_access(fixture(), {'errors'})

    def test_change_event(self):
        self.assertEqual(evaluate(fixture(action='change'))['permissions']['MODE'], '0660')

    def test_remove_unchanged(self):
        self.unchanged(fixture(action='remove'))

    def test_unrelated_kernel_unchanged(self):
        self.unchanged(fixture(kernel='ttyS0'))

    def test_wrong_bdf_same_ids_unchanged(self):
        event = fixture()
        event['parents'][0]['kernel'] = '0000:50:00.0'
        self.unchanged(event)

    def test_wrong_domain_unchanged(self):
        event = fixture()
        event['parents'][0]['kernel'] = '0001:4f:00.0'
        self.unchanged(event)

    def test_other_function_unchanged(self):
        event = fixture()
        event['parents'][0]['kernel'] = '0000:4f:00.1'
        self.unchanged(event)

    def test_each_wrong_id_unchanged(self):
        for key in ('vendor', 'device', 'subsystem_vendor', 'subsystem_device'):
            with self.subTest(key=key):
                event = fixture()
                event['parents'][0][key] = '0x0000'
                self.unchanged(event)

    def test_n6000_unchanged(self):
        event = fixture()
        event['parents'][0]['subsystem_device'] = '0x1770'
        self.unchanged(event)

    def test_same_ids_other_board_unchanged(self):
        event = fixture()
        event['parents'][0]['kernel'] = '0000:ab:00.0'
        self.unchanged(event)

    def test_missing_parent_unchanged(self):
        self.unchanged(fixture(parents=[]))

    def test_partial_identity_unchanged(self):
        event = fixture()
        del event['parents'][0]['subsystem_device']
        self.unchanged(event)

    def test_no_split_parent_identity(self):
        event = fixture()
        a = event['parents'][0]
        b = copy.deepcopy(a)
        a['kernel'] = '0000:ab:00.0'
        b['subsystem_device'] = '0x0000'
        event['parents'].append(b)
        self.unchanged(event)

    def test_no_split_parent_ids(self):
        event = fixture()
        a = event['parents'][0]
        b = copy.deepcopy(a)
        a['vendor'] = '0x0000'
        b['device'] = '0x0000'
        event['parents'].append(b)
        self.unchanged(event)

    def test_original_embedded_byte_exact(self):
        embedded = RULE.read_text().split('# BEGIN ORIGINAL: unchanged fallback for all unrelated devices/events.\n')[1].split('# END ORIGINAL\n')[0]
        self.assertEqual(embedded.encode(), ORIGINAL.read_bytes())
        self.assertEqual(hashlib.sha256(ORIGINAL.read_bytes()).hexdigest(),
                         'ea4f25a85c39f0ba6f390c14ff8d990597c6d56626d4854c028bb165d7f5107e')

    def test_group_exists(self):
        record = json.loads((HERE.parent / 'source-resume-01/batch01.json').read_text())
        self.assertIn('uwb_student00:x:1000:', record['commands']['groups']['stdout'])

    def test_reject_unsupported_grammar(self):
        with self.assertRaises(ValueError):
            evaluate(fixture(), 'PROGRAM="do-not-run"')

    def test_forward_labels_exist(self):
        with self.assertRaises(ValueError):
            evaluate(fixture(), 'GOTO="missing"')


if __name__ == '__main__':
    unittest.main(verbosity=2)
