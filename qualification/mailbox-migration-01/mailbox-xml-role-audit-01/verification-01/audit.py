#!/usr/bin/env python3
"""Independent bounded, read-only XML observation; never a migration approval."""
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import stat
import sys
import xml.etree.ElementTree as ET

MAX_BYTES = 32 * 1024 * 1024
MAX_DECODED_BYTES = 128 * 1024 * 1024
MAX_NODES = 500000
MAX_DEPTH = 128
MAX_EMBEDDED_DEPTH = 8
IPXACT = 'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'
FLAGS = dict(authorized=False, ready_for_build=False, migration_approved=False,
             diagnostic_execution=False, vendor_execution=False, rtl_backpressure_certified=False)


def local(e):
    return e.tag.rsplit('}', 1)[-1]


def children(e, name):
    return [c for c in e if local(c) == name]


def at(e, *names):
    items = [e]
    for name in names:
        items = [c for item in items for c in children(item, name)]
    return items


def text(e, name):
    values = children(e, name)
    return (values[0].text or '').strip() if len(values) == 1 else ''


def sha(data):
    return hashlib.sha256(data).hexdigest()


def xml(e):
    return ET.tostring(e, encoding='unicode')


class Audit:
    def __init__(self, source, kind):
        self.kind = kind
        self.result = dict(source=source, kind=kind, findings=[], representations=[],
                           coverage=[], embedded=[], unmatched=[], parameters=[], documents=[],
                           parse_complete=True, required_coverage_complete=False)
        self.nodes = 0
        self.bytes = 0

    def finding(self, code, path, detail, severity='error'):
        self.result['findings'].append(dict(code=code, path=path, detail=detail, severity=severity))

    def unknown(self, code, path, element):
        self.result['unmatched'].append(dict(path=path, reason=code, xml=xml(element)))
        self.finding(code, path, 'preserved, not interpreted', 'incomplete')

    def parse(self, data):
        self.bytes += len(data)
        if len(data) > MAX_BYTES or self.bytes > MAX_DECODED_BYTES:
            raise ValueError('XML byte limit exceeded')
        # Reject declarations before ElementTree can expand internal entities.
        # UTF-16/32 would evade an ASCII declaration check, so reject NUL input.
        if b'\x00' in data or b'<!DOCTYPE' in data.upper() or b'<!ENTITY' in data.upper():
            raise ValueError('DTD/entities or NUL-encoded XML prohibited')
        parser = ET.XMLPullParser(events=('start', 'end'))
        root = None
        depth = 0
        for offset in range(0, len(data), 4096):
            parser.feed(data[offset:offset + 4096])
            for event, elem in parser.read_events():
                if event == 'start':
                    if root is None:
                        root = elem
                    depth += 1
                    self.nodes += 1
                    if depth > MAX_DEPTH or self.nodes > MAX_NODES:
                        raise ValueError('XML depth/node limit exceeded')
                else:
                    depth -= 1
        parser.close()
        if root is None:
            raise ValueError('empty XML')
        return root

    def paths(self, root, base):
        paths = {}
        def visit(e, path):
            paths[id(e)] = path
            counts = Counter()
            for c in e:
                counts[c.tag] += 1
                visit(c, path + '/' + c.tag + '[' + str(counts[c.tag]) + ']')
        visit(root, base + '/' + root.tag + '[1]')
        return paths

    def duplicate(self, entries, key, code, path):
        # Count the full list; no role-keyed dictionary is ever constructed.
        counts = Counter(e[key] for e in entries)
        for name, count in counts.items():
            if count > 1:
                self.finding(code, path, dict(value=name, count=count,
                             entry_paths=[e['path'] for e in entries if e[key] == name]))

    def semantics(self, e, path):
        evidence = []
        for item in e.iter():
            pairs = [(local(item), (item.text or '').strip())] + list(item.attrib.items())
            if local(item) == 'entry':
                pairs.append((text(item, 'key'), text(item, 'value')))
            if local(item) == 'parameter':
                pairs.append((item.get('parameterId', ''), text(item, 'value')))
            for key, value in pairs:
                k = key.rsplit('}', 1)[-1].lower()
                if 'terminat' not in k and 'constant' not in k and 'tieoff' not in k:
                    continue
                evidence.append(dict(key=key, value=value))
                if k in ('terminationvalue', 'constantburstbehavior'):
                    continue  # Default value / burst protocol, not a tie-off enable.
                if k in ('terminated', 'isterminated', 'termination'):
                    if value.lower() not in ('false', '0'):
                        self.finding('unsafe_port_semantics', path, dict(key=key, value=value))
                elif k in ('constant', 'constantvalue', 'tieoff', 'tieoffvalue'):
                    self.finding('unsafe_port_semantics', path, dict(key=key, value=value))
                else:
                    self.finding('unknown_port_semantics', path, dict(key=key, value=value), 'incomplete')
        return evidence

    def check_interface(self, interface, required):
        entries = interface['entries']
        if interface['type'] == 'avalon':
            self.duplicate(entries, 'logical', 'duplicate_avalon_role', interface['path'])
        self.duplicate(entries, 'physical', 'physical_name_collision', interface['path'])
        for e in entries:
            if not e['logical'] or not e['physical']:
                self.finding('empty_mapping', e['path'], e)
            if e['width'] is None or e['width'] < 1 or e['direction'] not in ('input', 'output', 'inout'):
                self.finding('invalid_port_shape', e['path'], e)
        if not required:
            return
        for role in ('waitrequest', 'readdatavalid'):
            found = [e for e in entries if e['logical'] == role]
            if not found:
                self.finding('missing_required_role', interface['path'], role)
            elif len(found) != 1:
                self.finding('required_role_count', interface['path'], dict(role=role, count=len(found)))
            else:
                e = found[0]
                if (e['physical'] != 'avmm_' + role or e['width'] != 1 or
                        e['direction'] != 'output' or e.get('lower_bound', 0) != 0):
                    self.finding('invalid_required_role', e['path'], e)

    def boundary(self, root, paths, context):
        rep = dict(schema='boundary', root=local(root), path=paths[id(root)],
                   context=context.copy(), interfaces=[])
        parameter = context.get('parameter')
        rep['layout_valid'] = (root.tag in ('boundary', 'boundaryDefinition') and
            ((parameter == 'componentDefinition' and context.get('document_root') == 'componentDefinition' and
              rep['path'] == context.get('document_path', '') + '/boundary[1]') or
             (parameter in ('lockedInterfaceDefinition', 'defaultBoundary') and
              context.get('document_root') == 'boundaryDefinition' and
              rep['path'] == context.get('document_path'))))
        self.result['representations'].append(rep)
        interfaces = at(root, 'interfaces', 'interface')
        if len(children(root, 'interfaces')) != 1 or not interfaces:
            self.finding('boundary_interfaces_missing_or_ambiguous', rep['path'], len(interfaces))
        for i in interfaces:
            row = dict(name=text(i, 'name'), type=text(i, 'type'), path=paths[id(i)], entries=[])
            rep['interfaces'].append(row)
            row['semantics'] = self.semantics(i, paths[id(i)])
            for c in i:
                if local(c) not in ('name', 'type', 'isStart', 'ports', 'assignments', 'parameters'):
                    self.unknown('uninterpreted_interface_child', paths[id(c)], c)
            for p in at(i, 'ports', 'port'):
                for key in ('name', 'role', 'direction', 'width'):
                    if len(children(p, key)) != 1:
                        self.finding('port_field_count', paths[id(p)], key)
                try:
                    width = int(text(p, 'width'))
                    lower = int(text(p, 'lowerBound'))
                except ValueError:
                    width, lower = None, None
                entry = dict(logical=text(p, 'role'), physical=text(p, 'name'),
                             direction={'bidir': 'inout'}.get(text(p, 'direction').lower(),
                                 text(p, 'direction').lower()), width=width,
                             lower_bound=lower, path=paths[id(p)], xml=xml(p),
                             semantics=self.semantics(p, paths[id(p)]))
                row['entries'].append(entry)
                for c in p:
                    if local(c) not in ('name', 'role', 'direction', 'width', 'lowerBound',
                                       'vhdlType', 'terminationValue', 'terminated', 'isTerminated',
                                       'termination', 'constant', 'constantValue', 'tieoff', 'tieoffValue'):
                        self.unknown('uninterpreted_port_child', paths[id(c)], c)
            required = (row['name'] == 'avmm' and row['type'] == 'avalon' and
                        self.kind in ('leaf', 'child') and self.is_target(context))
            self.check_interface(row, required)
        self.duplicate([dict(physical=e['physical'], path=e['path']) for i in rep['interfaces']
                        for e in i['entries']], 'physical', 'physical_name_collision', rep['path'])
        self.duplicate([dict(name=i['name'], path=i['path']) for i in rep['interfaces']],
                       'name', 'duplicate_interface_name', rep['path'])
        if self.is_target(context) and self.kind in ('leaf', 'child'):
            if len([i for i in rep['interfaces'] if i['name'] == 'avmm' and i['type'] == 'avalon']) != 1:
                self.finding('required_avmm_interface_count', rep['path'], 'expected one avalon avmm')

    def ipxact(self, root, paths, context):
        rep = dict(schema='ipxact', path=paths[id(root)], context=context.copy(), interfaces=[], declarations=[])
        self.result['representations'].append(rep)
        if (children(root, 'addressSpaces') and not children(root, 'model') and
                not any(local(n) == 'portMap' for n in root.iter())):
            rep['schema'] = 'ipxact-address-metadata'
            rep['interfaces'] = [dict(name=text(i, 'name'), path=paths[id(i)], entries=[])
                                 for i in at(root, 'busInterfaces', 'busInterface')]
            self.unknown('address_metadata_without_port_maps', rep['path'], root)
            return
        declarations = at(root, 'model', 'ports', 'port')
        for p in declarations:
            wires = children(p, 'wire')
            width, direction = None, ''
            if len(wires) == 1:
                direction = {'in': 'input', 'out': 'output', 'inout': 'inout'}.get(text(wires[0], 'direction'), '')
                vectors = at(wires[0], 'vectors', 'vector')
                if not vectors and len(children(wires[0], 'vectors')) == 1:
                    width = 1
                elif len(vectors) == 1:
                    try:
                        width = abs(int(text(vectors[0], 'left')) - int(text(vectors[0], 'right'))) + 1
                    except ValueError:
                        pass
            rep['declarations'].append(dict(physical=text(p, 'name'), path=paths[id(p)],
                                           width=width, direction=direction, xml=xml(p),
                                           semantics=self.semantics(p, paths[id(p)])))
        self.duplicate(rep['declarations'], 'physical', 'physical_name_collision', rep['path'])
        for d in rep['declarations']:
            if not d['physical'] or d['width'] is None or d['width'] < 1 or d['direction'] not in ('input', 'output', 'inout'):
                self.finding('invalid_physical_declaration', d['path'], d)
        for i in at(root, 'busInterfaces', 'busInterface'):
            types = children(i, 'busType')
            bus = types[0].get('name', '') if len(types) == 1 else ''
            row = dict(name=text(i, 'name'), type=bus, path=paths[id(i)], entries=[])
            rep['interfaces'].append(row)
            row['semantics'] = self.semantics(i, paths[id(i)])
            maps = at(i, 'abstractionTypes', 'abstractionType', 'portMaps', 'portMap')
            if not maps:
                self.unknown('interface_without_port_maps', paths[id(i)], i)
            for p in maps:
                logicals, physicals = children(p, 'logicalPort'), children(p, 'physicalPort')
                logical = text(logicals[0], 'name') if len(logicals) == 1 else ''
                physical = text(physicals[0], 'name') if len(physicals) == 1 else ''
                ds = [d for d in rep['declarations'] if d['physical'] == physical]
                if len(ds) != 1:
                    self.finding('physical_declaration_count', paths[id(p)], dict(name=physical, count=len(ds)))
                entry = dict(logical=logical, physical=physical, path=paths[id(p)],
                             width=ds[0]['width'] if len(ds) == 1 else None,
                             direction=ds[0]['direction'] if len(ds) == 1 else '',
                             xml=xml(p), semantics=self.semantics(p, paths[id(p)]))
                row['entries'].append(entry)
                for c in p.iter():
                    if local(c) not in ('portMap', 'logicalPort', 'physicalPort', 'name'):
                        self.unknown('uninterpreted_port_map_element', paths[id(c)], c)
            self.check_interface(row, self.kind == 'leaf' and row['name'] == 'avmm')
        self.duplicate([dict(physical=e['physical'], path=e['path']) for i in rep['interfaces']
                        for e in i['entries']], 'physical', 'physical_name_collision', rep['path'])
        self.duplicate([dict(name=i['name'], path=i['path']) for i in rep['interfaces']],
                       'name', 'duplicate_interface_name', rep['path'])
        if self.kind == 'leaf' and len([i for i in rep['interfaces'] if i['name'] == 'avmm' and i['type'] == 'avalon']) != 1:
            self.finding('required_avmm_interface_count', rep['path'], 'expected one avalon avmm')

    def is_target(self, context):
        return (self.kind == 'leaf' or context.get('module') ==
                {'child': 'sdm_mailbox', 'parent': 'bmc_spi_sub_0'}.get(self.kind))

    def document(self, root, base='', context=None, embedded_depth=0):
        paths = self.paths(root, base)
        self.result['documents'].append(dict(path=paths[id(root)], root=root.tag,
            tag_counts=dict(Counter(n.tag for n in root.iter())),
            interpretation='role structures only; other metadata retained, not validated'))
        context = dict(context or {})
        context['document_root'] = root.tag
        context['document_path'] = paths[id(root)]
        handled = set()
        def walk(e, ctx):
            ctx = ctx.copy()
            if local(e) == 'module':
                infos = children(e, 'entity_info')
                ctx['module'] = text(infos[0], 'library') if len(infos) == 1 else ''
            if local(e) == 'parameter':
                ctx['parameter'] = e.get('parameterId', '')
                self.result['parameters'].append(dict(path=paths[id(e)], context=ctx.copy(),
                                                      value=text(e, 'value')))
            if local(e) in ('boundary', 'boundaryDefinition'):
                self.boundary(e, paths, ctx)
                handled.update(id(n) for n in at(e, 'interfaces', 'interface'))
                handled.update(id(n) for n in at(e, 'interfaces', 'interface', 'ports', 'port'))
            if e.tag == '{' + IPXACT + '}component':
                self.ipxact(e, paths, ctx)
                handled.update(id(n) for n in at(e, 'busInterfaces', 'busInterface'))
                handled.update(id(n) for n in at(e, 'busInterfaces', 'busInterface', 'abstractionTypes',
                                                  'abstractionType', 'portMaps', 'portMap'))
                handled.update(id(n) for n in at(e, 'model', 'ports', 'port'))
            value = (e.text or '').strip()
            if value.startswith('<'):
                entry = dict(path=paths[id(e)], context=ctx.copy(), sha256=sha(value.encode()),
                             bytes=len(value.encode()), status='parsed')
                self.result['embedded'].append(entry)
                try:
                    if embedded_depth >= MAX_EMBEDDED_DEPTH:
                        raise ValueError('embedded XML depth limit exceeded')
                    decoded = self.parse(value.encode())
                    entry['root'] = decoded.tag
                    self.document(decoded, paths[id(e)] + '::embedded', ctx, embedded_depth + 1)
                except (ET.ParseError, ValueError) as exc:
                    entry['status'] = 'error'
                    entry['raw'] = value
                    self.result['parse_complete'] = False
                    self.finding('embedded_xml_error', paths[id(e)], str(exc))
            for c in e:
                walk(c, ctx)
        walk(root, context)
        for e in root.iter():
            if local(e) in ('interface', 'port', 'busInterface', 'portMap') and id(e) not in handled:
                self.unknown('unmatched_role_structure', paths[id(e)], e)

    def compare_representations(self):
        target = [r for r in self.result['representations'] if self.is_target(r['context']) and
                  r['schema'] in ('boundary', 'ipxact') and
                  (r['context'].get('parameter') in ('lockedInterfaceDefinition', 'componentDefinition', 'defaultBoundary')
                   or r['schema'] == 'ipxact')]
        comparisons = []
        if self.kind in ('leaf', 'child') and len(target) == 2:
            def signature(rep):
                return sorted((i['name'], i['type'], e['logical'], e['physical'],
                               str(e['width']), e['direction'])
                              for i in rep['interfaces'] for e in i['entries'])
            left, right = target
            same = signature(left) == signature(right)
            comparisons.append(dict(left=left['path'], right=right['path'], mappings_equal=same))
            if not same:
                self.finding('representation_mapping_mismatch', left['path'], right['path'])
        self.result['representation_comparisons'] = comparisons

    def coverage(self):
        specs = {'leaf': [('lockedInterfaceDefinition', 'boundary', 'boundaryDefinition', True),
                          (None, 'ipxact', None, True)],
                 'child': [('componentDefinition', 'boundary', 'boundary', True),
                           ('defaultBoundary', 'boundary', 'boundaryDefinition', True)],
                 'parent': [('componentDefinition', 'boundary', 'boundary', True),
                            ('defaultBoundary', 'boundary', 'boundaryDefinition', False)]}[self.kind]
        for parameter, schema, root, required in specs:
            matches = [r for r in self.result['representations'] if self.is_target(r['context']) and
                       r['schema'] == schema and r['context'].get('parameter') == parameter]
            layout_ok = all(root is None or (r.get('root') == root and r.get('layout_valid'))
                            for r in matches)
            params = [p for p in self.result['parameters'] if self.is_target(p['context']) and
                      p['context'].get('parameter') == parameter]
            status = 'covered' if len(matches) == 1 else ('ambiguous' if len(matches) > 1 else 'missing')
            if not layout_ok:
                status = 'unsupported_layout'
            if parameter is not None and len(params) != 1:
                status = 'ambiguous' if len(params) > 1 else 'missing'
            if not matches and not required and len(params) == 1 and params[0]['value'] == '':
                status = 'explicitly_empty_observed'
            self.result['coverage'].append(dict(parameter=parameter, schema=schema, required=required,
                                                status=status, count=len(matches),
                                                paths=[r['path'] for r in matches],
                                                parameter_paths=[p['path'] for p in params]))
        self.result['required_coverage_complete'] = all(c['status'] in ('covered', 'explicitly_empty_observed')
                                                       for c in self.result['coverage'])


def audit_bytes(data, source, kind):
    a = Audit(source, kind)
    a.result.update(sha256=sha(data), bytes=len(data))
    try:
        root = a.parse(data)
        a.document(root)
    except (ET.ParseError, ValueError) as exc:
        a.result['parse_complete'] = False
        a.finding('xml_error', '/', str(exc))
    a.coverage()
    a.compare_representations()
    for rep in a.result['representations']:
        rep['finding_indices'] = []
    for index, finding in enumerate(a.result['findings']):
        owners = [r for r in a.result['representations'] if finding['path'].startswith(r['path'])]
        if owners:
            owner = max(owners, key=lambda r: len(r['path']))
            owner['finding_indices'].append(index)
            finding['representation_path'] = owner['path']
    a.result['parsed_nodes'] = a.nodes
    a.result['scoped_static_checks_satisfied'] = (a.result['parse_complete'] and
        a.result['required_coverage_complete'] and not a.result['findings'])
    a.result['complete_xml_semantic_coverage'] = False
    return a.result


def read_input(path):
    # No FIFO/device reads and no symlink at the input leaf. Ancestors are resolved
    # and recorded; this is not a sandbox or an adversarial filesystem guarantee.
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
    with os.fdopen(fd, 'rb') as f:
        info = os.fstat(f.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_size > MAX_BYTES:
            raise ValueError('input must be a regular file within byte limit')
        data = f.read(MAX_BYTES + 1)
        if len(data) > MAX_BYTES:
            raise ValueError('input byte limit exceeded')
        return data


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    for kind in ('leaf', 'child', 'parent'):
        parser.add_argument('--' + kind, required=True, type=Path)
    parser.add_argument('--output', required=True, type=Path, help='fresh exclusive directory (parent must exist)')
    args = parser.parse_args(argv)
    # Exclusive claim before any output, never reuse or delete failed claims.
    args.output.mkdir(mode=0o700, exist_ok=False)
    report = dict(flags=FLAGS.copy(), argv=sys.argv if argv is None else argv,
                  python=sys.version, executable=sys.executable,
                  checker_sha256=sha(Path(__file__).read_bytes()),
                  upgraded_acceptance=False, complete_xml_semantic_coverage=False,
                  mode='baseline observation with upgraded necessary-role checks', inputs=[])
    try:
        for kind in ('leaf', 'child', 'parent'):
            path = getattr(args, kind)
            data = read_input(path)
            (args.output / (kind + '.input.xml')).write_bytes(data)
            result = audit_bytes(data, str(path.absolute()), kind)
            result['resolved_path'] = str(path.resolve())
            report['inputs'].append(result)
        report['input_hashes_unchanged'] = all(sha(read_input(getattr(args, r['kind']))) == r['sha256']
                                               for r in report['inputs'])
        report['scoped_static_checks_satisfied'] = (report['input_hashes_unchanged'] and
            all(r['scoped_static_checks_satisfied'] for r in report['inputs']))
        report['upgraded_acceptance'] = False
        report['complete_xml_semantic_coverage'] = False
        report['limitations'] = ['No migration/collector/vendor code imported or executed.',
            'Port presence and absence of serialized constant/termination markers are not RTL proof.',
            'Only observed boundary and IP-XACT port shapes interpreted; all input bytes retained.',
            'No parameter, route, reset, timing, version-resolution or old-port retention acceptance.',
            'Parent external proxy does not expose internal avmm_waitrequest.',
            'No stage chaining or authorization; baseline missing waitrequest is expected.']
        rc = 0 if report['scoped_static_checks_satisfied'] else 2
    except (OSError, ValueError) as exc:
        report['fatal_error'] = str(exc)
        report['scoped_static_checks_satisfied'] = False
        rc = 3
    report['exit_code'] = rc
    (args.output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    manifest = {p.name: sha(p.read_bytes()) for p in sorted(args.output.iterdir()) if p.is_file()}
    (args.output / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(output=str(args.output), exit_code=rc, flags=FLAGS)))
    return rc


if __name__ == '__main__':
    raise SystemExit(main())
