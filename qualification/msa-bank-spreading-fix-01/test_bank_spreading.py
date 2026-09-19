"""Pure-Python tests; fixture mutations are confined to TemporaryDirectory."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

P = Path(__file__).resolve().parent
ROOT = P/'candidate/source'
VENDOR = P/'baseline/vendor'
HERE = ROOT/'ipss/ia840f'
CAP = P/'baseline/review/captured'
spec = importlib.util.spec_from_file_location('derive_presets', HERE/'derive_presets.py')
d = importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)
TARGETS = {f'mem_ss|msa_{i}|NUM_BANK_FIFOS' for i in range(2)}


def parameters(data):
    nodes = ET.fromstring(data).findall('.//parameter')
    result = {n.attrib['name']: n.attrib['value'] for n in nodes}
    assert len(result) == len(nodes)
    return result


class Translation(unittest.TestCase):
    def call(self, flag='false', count='8', copies='1', schema=None):
        donor = {'NUM_WRITE_COPIES': copies}
        if flag is not None:
            donor['BANK_SPREADING_EN'] = flag
        if count is not None:
            donor['NUM_BANK_FIFOS'] = count
        return d.translate_bank_spreading(donor, {'NUM_BANK_FIFOS', 'NUM_COPIES'} if schema is None else schema, 'msa_0')

    def test_false_legal(self):
        for count in ('0','2','4','8'):
            with self.subTest(count=count):
                value, record = self.call(count=count)
                self.assertEqual(value, '0')
                self.assertEqual(record['raw_source_values']['NUM_BANK_FIFOS'], count)
                self.assertEqual(record['raw_source_values']['BANK_SPREADING_EN'], 'false')
                self.assertEqual(record['count_role'], 'inactive saved evidence')

    def test_true_positive(self):
        for count in ('2','4','8'):
            with self.subTest(count=count):
                self.assertEqual(self.call('true',count)[0], count)

    def test_absent_flag(self):
        for count in ('0','2','4','8'):
            with self.subTest(count=count):
                value, record = self.call(None,count)
                self.assertEqual(value,count)
                self.assertFalse(record['semantics_resolved'])
                self.assertIsNone(record['raw_source_values']['BANK_SPREADING_EN'])

    def test_invalid_lexical_inputs(self):
        for flag in ('','TRUE','False','false ',' false','0','1','yes','unknown','\nfalse'):
            with self.subTest(flag=flag), self.assertRaises(ValueError):
                self.call(flag)
        for flag in ('false','true',None):
            for count in (None,'','x','-2','1','3','16','8.0','08','+8',' 8','8 ','８'):
                with self.subTest(flag=flag,count=count), self.assertRaises(ValueError):
                    self.call(flag,count)
        with self.assertRaises(ValueError):
            self.call('true','0')

    def test_copies_and_schema(self):
        for flag in ('true',None):
            for copies in ('2','4','8'):
                with self.subTest(flag=flag,copies=copies), self.assertRaises(ValueError):
                    self.call(flag,'8',copies)
        for copies in (None,'','0','3','1.0',' 1'):
            with self.subTest(copies=copies), self.assertRaises(ValueError):
                self.call(copies=copies)
        self.assertEqual(self.call(copies='1')[1]['raw_source_values']['NUM_WRITE_COPIES'],'1')
        # Legal generic zero/copies>1 is not an actual-board acceptance.
        self.assertEqual(self.call(copies='2')[0], '0')
        for schema in (set(), {'NUM_COPIES'}, {'NUM_BANK_FIFOS'}):
            with self.subTest(schema=schema), self.assertRaises(ValueError):
                self.call(schema=schema)


class FullDerivation(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)
        self.root = self.base/'source'
        self.vendor = self.base/'vendor'
        shutil.copytree(ROOT,self.root)
        shutil.copytree(VENDOR,self.vendor)
        shutil.copytree(P/'candidate/reference',self.base/'reference')

    def mutate(self, channel, key, value, duplicate=False):
        path = self.vendor/f'ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_{channel}.ip'
        tree = ET.parse(path)
        group = tree.find('.//a:altera_module_parameters/i:parameters',d.NS)
        node = next(n for n in group if n.find('i:name',d.NS).text==key)
        if duplicate:
            group.append(copy.deepcopy(node))
        elif value is None:
            group.remove(node)
        else:
            node.find('i:value',d.NS).text=value
        tree.write(path,encoding='utf-8',xml_declaration=True)

    def derive(self):
        with patch('subprocess.Popen', side_effect=AssertionError('vendor/process invocation forbidden')):
            return d.derive(self.root,self.vendor)

    def test_actual_complete_map_and_provenance(self):
        out=self.derive()
        old=parameters((CAP/'06-ia840f_mem.qprs').read_bytes())
        new=parameters(out['presets/ia840f_mem.qprs'])
        self.assertEqual(len(new),2930)
        self.assertEqual(old.keys(),new.keys())
        self.assertEqual({k for k in old if old[k]!=new[k]},TARGETS)
        self.assertTrue(all(old[k]=='8' and new[k]=='0' for k in TARGETS))
        before=json.loads((CAP/'05-preset_derivation.json').read_text())
        report=json.loads(out['preset_derivation.json'])
        self.assertFalse(report['execution_ready'])
        self.assertEqual(report['output_parameter_counts'],before['output_parameter_counts'])
        self.assertEqual(report['inputs_sha256'],before['inputs_sha256'])
        for i in range(2):
            name=f'msa_{i}'
            self.assertEqual(new[f'mem_ss|{name}|NUM_COPIES'],'1')
            mapping=report['mappings'][name]
            self.assertNotIn('NUM_BANK_FIFOS',mapping['vendor_mapping'])
            self.assertNotIn('NUM_BANK_FIFOS',mapping['modern_defaults'])
            rec=mapping['bank_spreading_saved_intent']
            self.assertEqual(rec['output'],{'scope':f'mem_ss|{name}|NUM_BANK_FIFOS','value':'0'})
            self.assertIn('saved intent only',rec['qualification'])
            self.assertEqual(rec['raw_source_values'],{'BANK_SPREADING_EN':'false','NUM_BANK_FIFOS':'8','NUM_WRITE_COPIES':'1'})
            self.assertEqual(rec['source_sha256'],before['inputs_sha256'][rec['source']])
            for evidence in rec['supporting_sources']:
                self.assertEqual(hashlib.sha256((P/evidence['review_capture']).read_bytes()).hexdigest(),evidence['sha256'])
            expected=before['unmapped_or_intentionally_not_transplanted'][name].copy()
            expected.pop('BANK_SPREADING_EN')
            self.assertEqual(report['unmapped_or_intentionally_not_transplanted'][name],expected)
        for key,value in before['mappings'].items():
            if key not in ('msa_0','msa_1'):
                self.assertEqual(report['mappings'][key],value)
        for key,value in before['unmapped_or_intentionally_not_transplanted'].items():
            if key not in ('msa_0','msa_1'):
                self.assertEqual(report['unmapped_or_intentionally_not_transplanted'][key],value)
        for name,cap in [('ia840f_sim.qprs','08-ia840f_sim.qprs'),('ia840f_pcie_known_schema.qprs','07-ia840f_pcie_known_schema.qprs')]:
            self.assertEqual(out['presets/'+name],(CAP/cap).read_bytes())
        for name,data in out.items():
            if name!='preset_derivation.json':
                self.assertEqual(hashlib.sha256(data).hexdigest(),report['outputs_sha256'][name])
        self.assertEqual(out,self.derive())

    def test_independent_instances(self):
        self.mutate(1,'BANK_SPREADING_EN','true')
        self.mutate(1,'NUM_BANK_FIFOS','4')
        out=parameters(self.derive()['presets/ia840f_mem.qprs'])
        self.assertEqual((out['mem_ss|msa_0|NUM_BANK_FIFOS'],out['mem_ss|msa_1|NUM_BANK_FIFOS']),('0','4'))
        self.mutate(0,'BANK_SPREADING_EN','true')
        self.mutate(0,'NUM_BANK_FIFOS','2')
        out=parameters(self.derive()['presets/ia840f_mem.qprs'])
        self.assertEqual((out['mem_ss|msa_0|NUM_BANK_FIFOS'],out['mem_ss|msa_1|NUM_BANK_FIFOS']),('2','4'))

    def test_missing_enable_integration(self):
        self.mutate(0,'BANK_SPREADING_EN',None)
        out=self.derive()
        self.assertEqual(parameters(out['presets/ia840f_mem.qprs'])['mem_ss|msa_0|NUM_BANK_FIFOS'],'8')
        report=json.loads(out['preset_derivation.json'])
        self.assertFalse(report['mappings']['msa_0']['bank_spreading_saved_intent']['semantics_resolved'])
        self.assertEqual(report['mappings']['msa_0']['vendor_mapping']['NUM_BANK_FIFOS'],'NUM_BANK_FIFOS')

    def test_no_publication_on_rejection(self):
        here=self.root/'ipss/ia840f'
        before={str(f.relative_to(here)):f.read_bytes() for f in here.rglob('*') if f.is_file()}
        self.mutate(1,'BANK_SPREADING_EN','False')
        proc=subprocess.run([sys.executable,'-B',str(here/'derive_presets.py'),'--vendor-root',str(self.vendor),'--write'],capture_output=True)
        self.assertNotEqual(proc.returncode,0)
        after={str(f.relative_to(here)):f.read_bytes() for f in here.rglob('*') if f.is_file()}
        self.assertEqual(before,after)

    def test_duplicate_xml_rejection(self):
        path=self.vendor/'ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_0.ip'
        original=path.read_bytes()
        for key in ('BANK_SPREADING_EN','NUM_BANK_FIFOS','NUM_WRITE_COPIES'):
            with self.subTest(key=key):
                path.write_bytes(original)
                self.mutate(0,key,'8',duplicate=True)
                with self.assertRaises((ValueError,AssertionError)):
                    self.derive()

    def test_schema_missing_and_duplicate(self):
        path=self.root/'ipss/mem/qip/presets/mem_presets.qprs'
        tree=ET.parse(path)
        node=next(n for n in tree.findall('.//preset') if n.get('name')=='iseries-dk-8g-rdimm')
        target=next(n for n in node if n.get('name')=='mem_ss|msa_0|NUM_BANK_FIFOS')
        node.append(copy.deepcopy(target));tree.write(path)
        with self.assertRaises((ValueError,AssertionError)):
            self.derive()
        node.remove(target);node.remove(next(n for n in node if n.get('name')=='mem_ss|msa_0|NUM_BANK_FIFOS'));tree.write(path)
        with self.assertRaises(ValueError):
            self.derive()

    def test_pinned_source_hash_rejection(self):
        path=self.base/'reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_fileset.tcl'
        path.write_bytes(path.read_bytes()+b'\n')
        with self.assertRaises((ValueError,AssertionError)):
            self.derive()

    def test_rejection_matrix_no_publication(self):
        here=self.root/'ipss/ia840f'
        path=self.vendor/'ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_1.ip'
        original=path.read_bytes()
        before={str(f.relative_to(here)):f.read_bytes() for f in here.rglob('*') if f.is_file()}
        cases=[('true','0','1',False)]
        cases += [(flag,None,'1',False) for flag in ('false','true',None)]
        cases += [(flag,'8','1',False) for flag in ('','unknown','FALSE',' true','true ')]
        cases += [('false',count,'1',False) for count in ('','x','-1','1','3','16','8.0')]
        cases += [('true','8',copies,False) for copies in ('2','4','8')]
        cases += [('false','8','1',True)]
        for flag,count,copies,duplicate in cases:
            with self.subTest(flag=flag,count=count,copies=copies,duplicate=duplicate):
                path.write_bytes(original)
                self.mutate(1,'BANK_SPREADING_EN',flag)
                self.mutate(1,'NUM_BANK_FIFOS',count,duplicate=duplicate)
                self.mutate(1,'NUM_WRITE_COPIES',copies)
                with patch.object(d,'__file__',str(here/'derive_presets.py')), patch.object(sys,'argv',['derive_presets.py','--vendor-root',str(self.vendor),'--write']), patch('subprocess.Popen',side_effect=AssertionError('no vendor calls')):
                    with self.assertRaises(ValueError):
                        d.main()
                after={str(f.relative_to(here)):f.read_bytes() for f in here.rglob('*') if f.is_file()}
                self.assertEqual(before,after)

    def test_compare_only_detects_stale(self):
        here=self.root/'ipss/ia840f'
        for name in ('presets/ia840f_mem.qprs','preset_derivation.json'):
            path=here/name; original=path.read_bytes();path.write_bytes(original+b'\n')
            result=subprocess.run([sys.executable,'-B',str(here/'derive_presets.py'),'--vendor-root',str(self.vendor)],capture_output=True)
            self.assertNotEqual(result.returncode,0)
            self.assertEqual(path.read_bytes(),original+b'\n')
            path.write_bytes(original)


class StagingGuards(unittest.TestCase):
    def test_actual_fixture_copy_invariant(self):
        import stage_candidate as stage
        before=stage.verify_inputs()
        outputs=d.derive(ROOT,VENDOR)
        stage.validate_outputs(outputs,before)
        for copies in ('2','4','8'):
            mutated=dict(outputs)
            tree=ET.fromstring(mutated['presets/ia840f_mem.qprs'])
            node=next(n for n in tree.findall('.//parameter') if n.attrib['name']=='mem_ss|msa_0|NUM_COPIES')
            node.set('value',copies)
            mutated['presets/ia840f_mem.qprs']=ET.tostring(tree)
            with self.subTest(copies=copies), self.assertRaises(ValueError):
                stage.validate_outputs(mutated,before)

    def test_pinned_baseline_and_schema_inputs(self):
        import stage_candidate as stage
        with tempfile.TemporaryDirectory() as tmp:
            base=Path(tmp)
            shutil.copytree(P/'baseline',base/'baseline')
            shutil.copytree(P/'candidate',base/'candidate')
            shutil.copyfile(P/'remote-before.json',base/'remote-before.json')
            with patch.object(stage,'P',base),patch.object(stage,'ROOT',base/'candidate/source'),patch.object(stage,'CAP',base/'baseline/review/captured'):
                stage.verify_inputs()
                for path in (base/'candidate/source/ipss/mem/qip/presets/mem_presets.qprs',base/'baseline/vendor/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_msa_0.ip',base/'baseline/review/captured/18-declare.tcl'):
                    data=path.read_bytes();path.write_bytes(data+b'\n')
                    with self.subTest(path=str(path)),self.assertRaises(ValueError):
                        stage.verify_inputs()
                    path.write_bytes(data)


if __name__=='__main__':
    unittest.main(verbosity=2)
