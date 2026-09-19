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

    def test_dtd_and_limits(self):
        result = audit.audit_bytes(b'<!DOCTYPE x [<!ENTITY a "a">]><x>&a;</x>', 'synthetic', 'leaf')
        self.assertFalse(result['parse_complete'])
        result = audit.audit_bytes(b'<x>' * 140 + b'</x>' * 140, 'synthetic', 'leaf')
        self.assertFalse(result['parse_complete'])

if __name__ == '__main__':
    unittest.main(verbosity=2)
