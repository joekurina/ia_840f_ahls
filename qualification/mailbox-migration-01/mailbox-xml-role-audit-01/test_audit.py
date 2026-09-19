"""Synthetic mutations of retained actual XML; never vendor execution."""
import copy
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET
import audit

HERE = Path(__file__).resolve().parent

class RoleAuditTests(unittest.TestCase):
    def boundary(self):
        root = ET.parse(HERE / 'fixtures/leaf-boundary.xml').getroot()
        interface = root.find("./interfaces/interface[name='avmm']")
        port = copy.deepcopy(interface.find("./ports/port[role='readdatavalid']"))
        port.find('role').text = 'waitrequest'
        port.find('name').text = 'avmm_waitrequest'
        interface.find('ports').append(port)
        return root, interface, port

    def run_xml(self, root):
        return audit.audit_bytes(ET.tostring(root), 'synthetic', 'leaf')

    def codes(self, result):
        return [f['code'] for f in result['findings']]

    def test_valid_boundary(self):
        r, _, _ = self.boundary()
        self.assertNotIn('invalid_required_role', self.codes(self.run_xml(r)))
        self.assertNotIn('duplicate_avalon_role', self.codes(self.run_xml(r)))

    def test_duplicate_role_preserved_before_dictionary(self):
        r, i, p = self.boundary()
        i.find('ports').append(copy.deepcopy(p))
        result = self.run_xml(r)
        self.assertIn('duplicate_avalon_role', self.codes(result))
        ports = result['representations'][0]['interfaces'][2]['entries']
        self.assertEqual(2, sum(e['logical'] == 'waitrequest' for e in ports))

    def test_invalid_required_fields(self):
        for key, value in [('width', '2'), ('width', 'banana'), ('direction', 'Input'), ('name', 'wrong'), ('lowerBound', '1')]:
            with self.subTest(key=key, value=value):
                r, _, p = self.boundary()
                p.find(key).text = value
                self.assertIn('invalid_required_role', self.codes(self.run_xml(r)))

    def test_physical_collision(self):
        r, i, p = self.boundary()
        p.find('name').text = 'avmm_read'
        self.assertIn('physical_name_collision', self.codes(self.run_xml(r)))

    def test_conduit_repeated_role_is_not_avalon_duplicate(self):
        r, i, p = self.boundary()
        i.find('type').text = 'conduit'
        other = copy.deepcopy(p)
        other.find('name').text = 'second_export'
        i.find('ports').append(other)
        self.assertNotIn('duplicate_avalon_role', self.codes(self.run_xml(r)))

    def test_malformed_embedded_xml(self):
        r = ET.Element('component')
        ET.SubElement(r, 'value').text = '<boundaryDefinition><bad>'
        result = self.run_xml(r)
        self.assertIn('embedded_xml_error', self.codes(result))
        self.assertFalse(result['parse_complete'])

    def test_current_baseline_missing_wait_not_readvalid(self):
        result = audit.audit_bytes((HERE / 'fixtures/leaf-ipxact.xml').read_bytes(), 'baseline', 'leaf')
        missing = [f for f in result['findings'] if f['code'] == 'missing_required_role']
        self.assertEqual(2, len(missing))
        self.assertTrue(all(f['detail'] == 'waitrequest' for f in missing))

    def test_termination_and_constant(self):
        for tag, value in [('terminated', 'true'), ('isTerminated', '1'), ('constant', '0'), ('constantValue', '0')]:
            with self.subTest(tag=tag):
                r, _, p = self.boundary()
                ET.SubElement(p, tag).text = value
                self.assertIn('unsafe_port_semantics', self.codes(self.run_xml(r)))

    def test_default_termination_value_is_not_termination(self):
        r, _, _ = self.boundary()
        self.assertNotIn('unsafe_port_semantics', self.codes(self.run_xml(r)))

    def test_ipxact_duplicate_mapping_and_dangling_physical(self):
        r = ET.parse(HERE / 'fixtures/leaf-ipxact.xml').getroot()
        ns = {'i': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
        maps = r.find("./i:busInterfaces/i:busInterface[i:name='avmm']/i:abstractionTypes/i:abstractionType/i:portMaps", ns)
        p = copy.deepcopy(maps[0]); maps.append(p)
        p.find('./i:physicalPort/i:name', ns).text = 'nonexistent'
        codes = self.codes(self.run_xml(r))
        self.assertIn('duplicate_avalon_role', codes)
        self.assertIn('physical_declaration_count', codes)

    def test_ipxact_physical_declaration_duplicate(self):
        r = ET.parse(HERE / 'fixtures/leaf-ipxact.xml').getroot()
        ns = {'i': 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
        ports = r.find('./i:model/i:ports', ns)
        ports.append(copy.deepcopy(ports[0]))
        self.assertIn('physical_name_collision', self.codes(self.run_xml(r)))

    def test_missing_child_nesting_not_covered(self):
        result = audit.audit_bytes(b'<design/>', 'synthetic', 'child')
        self.assertTrue(any(c['status'] == 'missing' for c in result['coverage']))
        self.assertFalse(result['required_coverage_complete'])

    def test_unknown_role_structure_retained(self):
        r, i, _ = self.boundary()
        ET.SubElement(i, 'mystery').text = 'opaque'
        result = self.run_xml(r)
        self.assertIn('uninterpreted_interface_child', self.codes(result))
        self.assertTrue(result['unmatched'])

    def test_bidir_conduit_is_valid(self):
        r, i, p = self.boundary()
        i.find('type').text = 'conduit'
        p.find('direction').text = 'Bidir'
        self.assertNotIn('invalid_port_shape', self.codes(self.run_xml(r)))

    def test_unexpected_nested_port_not_silently_consumed(self):
        r, i, p = self.boundary()
        wrapper = ET.SubElement(i.find('ports'), 'unexpected')
        wrapper.append(copy.deepcopy(p))
        self.assertIn('unmatched_role_structure', self.codes(self.run_xml(r)))

    def test_interface_termination_is_not_ignored(self):
        r, i, _ = self.boundary()
        entry = ET.SubElement(i.find('./parameters/parameterValueMap'), 'entry')
        ET.SubElement(entry, 'key').text = 'terminated'
        ET.SubElement(entry, 'value').text = 'true'
        self.assertIn('unsafe_port_semantics', self.codes(self.run_xml(r)))

    def upgraded_leaf(self):
        r = ET.parse(HERE / 'fixtures/leaf-ipxact.xml').getroot()
        ns = {'i': audit.IPXACT}
        tag = lambda n: '{' + audit.IPXACT + '}' + n
        ports = r.find('./i:model/i:ports', ns)
        p = copy.deepcopy(ports.find("i:port[i:name='avmm_readdatavalid']", ns))
        p.find('i:name', ns).text = 'avmm_waitrequest'; ports.append(p)
        maps = r.find("./i:busInterfaces/i:busInterface[i:name='avmm']/i:abstractionTypes/i:abstractionType/i:portMaps", ns)
        m = copy.deepcopy(maps[-1]); maps.append(m)
        m.find('./i:logicalPort/i:name', ns).text = 'waitrequest'
        m.find('./i:physicalPort/i:name', ns).text = 'avmm_waitrequest'
        for q in r.iter(tag('parameter')):
            if q.get('parameterId') == 'lockedInterfaceDefinition':
                q.find(tag('value')).text = ET.tostring(self.boundary()[0], encoding='unicode')
        return r, p, m

    def test_complete_synthetic_leaf(self):
        r, _, _ = self.upgraded_leaf()
        result = self.run_xml(r)
        self.assertEqual([], result['findings'])
        self.assertTrue(result['scoped_static_checks_satisfied'])
        self.assertFalse(result['complete_xml_semantic_coverage'])

    def test_ipxact_required_fields(self):
        for mutation in ('width', 'direction', 'mapping'):
            with self.subTest(mutation=mutation):
                r, p, m = self.upgraded_leaf()
                ns = {'i': audit.IPXACT}
                tag = lambda n: '{' + audit.IPXACT + '}' + n
                if mutation == 'width':
                    v = ET.SubElement(p.find('./i:wire/i:vectors', ns), tag('vector'))
                    ET.SubElement(v, tag('left')).text = '1'
                    ET.SubElement(v, tag('right')).text = '0'
                elif mutation == 'direction':
                    p.find('./i:wire/i:direction', ns).text = 'in'
                else:
                    m.find('./i:physicalPort/i:name', ns).text = 'avmm_read'
                self.assertIn('invalid_required_role', self.codes(self.run_xml(r)))

    def test_actual_child_and_parent_duplicate_mutations(self):
        for kind, target, parameter, interface in (
                ('child', 'sdm_mailbox', 'componentDefinition', 'avmm'),
                ('child', 'sdm_mailbox', 'defaultBoundary', 'avmm'),
                ('parent', 'bmc_spi_sub_0', 'componentDefinition', 'host_sdm')):
            with self.subTest(kind=kind, parameter=parameter):
                r = ET.parse(HERE / 'baseline-01' / (kind + '.input.xml')).getroot()
                module = next(m for m in r.iter() if audit.local(m) == 'module' and
                              any(audit.local(c) == 'entity_info' and audit.text(c, 'library') == target for c in m))
                q = next(q for q in module.iter() if q.get('parameterId') == parameter)
                value = audit.children(q, 'value')[0]
                b = ET.fromstring(value.text)
                i = next(i for i in b.iter('interface') if audit.text(i, 'name') == interface)
                ports = i.find('ports'); ports.append(copy.deepcopy(ports[0]))
                value.text = ET.tostring(b, encoding='unicode')
                result = audit.audit_bytes(ET.tostring(r), 'synthetic', kind)
                self.assertIn('duplicate_avalon_role', self.codes(result))
                self.assertTrue(result['required_coverage_complete'])

    def test_missing_actual_child_default_boundary(self):
        r = ET.parse(HERE / 'baseline-01/child.input.xml').getroot()
        for m in r.iter():
            if audit.local(m) == 'module' and any(audit.local(c) == 'entity_info' and audit.text(c, 'library') == 'sdm_mailbox' for c in m):
                for q in m.iter():
                    if q.get('parameterId') == 'defaultBoundary':
                        audit.children(q, 'value')[0].text = ''
        result = audit.audit_bytes(ET.tostring(r), 'synthetic', 'child')
        self.assertFalse(result['required_coverage_complete'])

    def test_representation_mapping_mismatch(self):
        r, p, _ = self.upgraded_leaf()
        ns = {'i': audit.IPXACT}
        p.find('./i:wire/i:direction', ns).text = 'in'
        self.assertIn('representation_mapping_mismatch', self.codes(self.run_xml(r)))

    def test_wrong_embedded_root_not_covered(self):
        r, _, _ = self.upgraded_leaf()
        for q in r.iter():
            if q.get('parameterId') == 'lockedInterfaceDefinition':
                v = audit.children(q, 'value')[0]
                v.text = '<unexpected>' + v.text + '</unexpected>'
        result = self.run_xml(r)
        self.assertFalse(result['required_coverage_complete'])

    def test_duplicate_parameter_not_covered(self):
        r, _, _ = self.upgraded_leaf()
        for parent in list(r.iter()):
            for q in list(parent):
                if q.get('parameterId') == 'lockedInterfaceDefinition':
                    duplicate = copy.deepcopy(q)
                    audit.children(duplicate, 'value')[0].text = ''
                    parent.append(duplicate)
        self.assertFalse(self.run_xml(r)['required_coverage_complete'])

    def test_dtd_and_limits(self):
        result = audit.audit_bytes(b'<!DOCTYPE x [<!ENTITY a "a">]><x>&a;</x>', 'synthetic', 'leaf')
        self.assertFalse(result['parse_complete'])
        result = audit.audit_bytes(b'<x>' * 140 + b'</x>' * 140, 'synthetic', 'leaf')
        self.assertFalse(result['parse_complete'])

if __name__ == '__main__':
    unittest.main(verbosity=2)
