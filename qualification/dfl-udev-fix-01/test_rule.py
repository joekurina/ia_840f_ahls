#!/usr/bin/env python3
"""Inert subset model of the exact candidate grammar; not udevadm validation."""
import fnmatch,json,re,unittest
from pathlib import Path
HERE=Path(__file__).resolve().parent
RULE=HERE/'90-intel-fpga-opencl.rules.candidate'

def evaluate(event):
    permissions=None
    for line in RULE.read_text().splitlines():
        if not line.strip() or line.lstrip().startswith('#'):continue
        tokens=[x.strip() for x in line.split(',')]
        matches={};assignments={}
        for token in tokens:
            m=re.fullmatch(r'(ACTION|KERNEL|SUBSYSTEMS|ATTRS\{vendor\}|ATTRS\{device\}|OWNER|GROUP|MODE)(==|=)"([^"\n]*)"',token)
            if not m:raise ValueError('unsupported rule grammar: '+token)
            key,op,value=m.groups()
            (matches if op=='==' else assignments)[key]=value
        def match(value,pattern):return any(fnmatch.fnmatchcase(value,x) for x in pattern.split('|'))
        if not match(event['action'],matches['ACTION']) or not match(event['kernel'],matches['KERNEL']):continue
        if not any(p['subsystem']==matches['SUBSYSTEMS'] and p.get('vendor')==matches['ATTRS{vendor}'] and p.get('device')==matches['ATTRS{device}'] for p in event['parents']):continue
        permissions=assignments
    return permissions

def check_access(event,resources):
    p=evaluate(event)
    if p is not None and 'device_node' not in resources:raise FileNotFoundError('required device node absent')
    return p

def fixture(**changes):
    e=dict(action='add',kernel='dfl-port.0',parents=[dict(subsystem='pci',vendor='0x8086',device='0xbcce')]);e.update(changes);return e

class Rules(unittest.TestCase):
    def test_expected_node_permissions(self):
        self.assertEqual(check_access(fixture(),{'device_node','userclk','errors'}),dict(OWNER='root',GROUP='uwb_student00',MODE='0660'))
    def test_optional_resources_absent(self):
        self.assertEqual(check_access(fixture(),{'device_node'})['MODE'],'0660')
    def test_required_node_absent_visible(self):
        with self.assertRaises(FileNotFoundError):check_access(fixture(),{'userclk'})
    def test_fme_stays_admin_only(self):
        self.assertEqual(evaluate(fixture(kernel='dfl-fme.0')),dict(OWNER='root',GROUP='root',MODE='0600'))
    def test_wrong_vendor(self):
        self.assertIsNone(evaluate(fixture(parents=[dict(subsystem='pci',vendor='0x12ba',device='0x0070')])))
    def test_wrong_device(self):
        self.assertIsNone(evaluate(fixture(kernel='ttyS0')))
    def test_remove_event(self):self.assertIsNone(evaluate(fixture(action='remove')))
    def test_change_event(self):self.assertEqual(evaluate(fixture(action='change'))['MODE'],'0660')
    def test_no_split_parent_match(self):
        self.assertIsNone(evaluate(fixture(parents=[dict(subsystem='pci',vendor='0x8086',device='0x0000'),dict(subsystem='pci',vendor='0x0000',device='0xbcce')])))
    def test_no_control_side_effect(self):
        t=RULE.read_text();self.assertNotIn('RUN+=',t);self.assertNotIn('0666',t);self.assertNotIn('/sys/',t)
    def test_original_rule_preserved(self):
        p=HERE.parent/'source-resume-01/remote/etc/udev/rules.d/90-intel-fpga-opencl.rules'
        self.assertIn('chmod 0666 %S%p/dfl*/userclk/frequency %S%p/errors/* /dev/%k',p.read_text())
    def test_private_group_exists(self):
        d=json.loads((HERE.parent/'source-resume-01/batch01.json').read_text())
        self.assertIn('uwb_student00:x:1000:',d['commands']['groups']['stdout'])
if __name__=='__main__':unittest.main(verbosity=2)
