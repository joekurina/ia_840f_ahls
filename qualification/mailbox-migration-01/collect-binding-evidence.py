#!/usr/bin/env python3
"""Future workstation-only STATIC collection; never imports/runs migration.py.
Only write: exclusive JSON receipt in existing qualification directory.
No vendor/Tcl/shell/ldd execution, project opening, mkdir, or approval generation.
Run with python3 -B inside the independently authorized named tmux session.
Static candidates are NOT actual loader resolution or complete runtime closure.
"""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import pwd
import re
import stat
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET

BASE = Path('/home/uwb_student00/ahls/new_BSP')
HERE = BASE / 'qualification/mailbox-migration-01'
INSTALL = Path('/opt/altera/26.1.1')
INSTRUCTIONS = Path('/home/uwb_student00/quartus_26/instructions.md')
MAX_TEXT = 2 * 1024 * 1024
MAX_FILES = 512
MAX_INDEX = 250000
API = ('load_system', 'save_system', 'load_component', 'save_component',
       'get_component_parameter_value', 'sync_sysinfo_parameters',
       'reload_component_footprint', 'validate_component_footprint')
SIGNALS = re.compile(r'package\s+(require|provide)|set_module_property\s+(NAME|VERSION)|'
                     r'add_instance|add_fileset_file|\bsource\b|\bexec\b|'
                     r'QUARTUS|JAVA|CLASSPATH|LD_LIBRARY_PATH|\.jar|\.so|'
                     r'include_source|c_source|VERSION|version')


def no_links(path):
    for node in (path, *path.parents):
        if node.is_symlink():
            raise ValueError('symlink not permitted for context/output: ' + str(node))


def chain(path):
    """Record links in ALL components, including links introduced by a target."""
    pending = list(path.parts[1:])
    current = Path('/')
    links = []
    while pending:
        part = pending.pop(0)
        if part in ('', '.'):
            continue
        if part == '..':
            current = current.parent
            continue
        candidate = current / part
        st = candidate.lstat()
        if stat.S_ISLNK(st.st_mode):
            if len(links) >= 40:
                raise ValueError('symlink chain exceeds 40 hops')
            target = os.readlink(candidate)
            links.append({'path': str(candidate), 'target': target})
            t = Path(target)
            if t.is_absolute():
                current = Path('/')
                pending = list(t.parts[1:]) + pending
            else:
                pending = list(t.parts) + pending
        else:
            current = candidate
    return current, links


def elf_metadata(data):
    """Bounded ELF64 little-endian metadata parse, not dependency resolution."""
    result = {'actual_loader_resolution': False}
    if data[:6] != b'\x7fELF\x02\x01':
        return dict(result, unsupported='not ELF64 little-endian')
    try:
        phoff = struct.unpack_from('<Q', data, 32)[0]
        entsize, count = struct.unpack_from('<HH', data, 54)
        if entsize < 56 or count > 4096:
            raise ValueError('invalid/unsupported program-header table')
        headers = [struct.unpack_from('<IIQQQQQQ', data, phoff + i * entsize)
                   for i in range(count)]
        loads = [h for h in headers if h[0] == 1]
        tags = []
        for h in headers:
            _, _, off, _, _, size, _, _ = h
            if h[0] not in (2, 3):
                continue
            if off + size > len(data):
                raise ValueError('required ELF segment beyond static text budget')
            if h[0] == 3:
                result['interpreter_reference'] = bytes(data[off:off + size]).rstrip(b'\0').decode(errors='replace')
            if h[0] == 2:
                for i in range(off, off + size, 16):
                    tag, value = struct.unpack_from('<qQ', data, i)
                    if tag == 0:
                        break
                    tags.append((tag, value))
        address = next((v for t, v in tags if t == 5), None)
        if address is not None:
            segment = next(h for h in loads if h[3] <= address < h[3] + h[5])
            string_base = segment[2] + address - segment[3]
            refs = []
            for tag, value in tags:
                if tag not in (1, 15, 29):
                    continue
                start = string_base + value
                end = data.find(b'\0', start)
                if start >= len(data) or end < 0:
                    raise ValueError('dynamic string beyond static budget')
                refs.append({'tag': {1: 'DT_NEEDED', 15: 'DT_RPATH', 29: 'DT_RUNPATH'}[tag],
                             'value': bytes(data[start:end]).decode(errors='replace')})
            result['dynamic_references'] = refs
    except (ValueError, struct.error, StopIteration) as exc:
        result['incomplete'] = str(exc) or 'unmapped dynamic string table'
    return result


def inspect(path):
    record = {'path': str(path)}
    try:
        resolved, links = chain(path)
        record.update(resolved_path=str(resolved), symlink_chain=links,
                      harness_no_links_compatible=not links)
        st = resolved.stat()
        if not stat.S_ISREG(st.st_mode):
            raise ValueError('not a regular file')
        h = hashlib.sha256()
        preview = bytearray()
        with resolved.open('rb') as stream:
            before = os.fstat(stream.fileno())
            for chunk in iter(lambda: stream.read(1024 * 1024), b''):
                h.update(chunk)
                if len(preview) < MAX_TEXT:
                    preview.extend(chunk[:MAX_TEXT - len(preview)])
            after = os.fstat(stream.fileno())
        stable = (before.st_ino, before.st_size, before.st_mtime_ns) == (
            after.st_ino, after.st_size, after.st_mtime_ns)
        record.update(sha256=h.hexdigest(), size=after.st_size,
                      mode=oct(stat.S_IMODE(after.st_mode)), mtime_ns=after.st_mtime_ns,
                      stable_during_read=stable)
        if not stable:
            record['error'] = 'file changed during read; reject identity'
        if b'\0' not in preview:
            text = preview.decode('utf-8', errors='replace')
            record['text'] = text
            record['text_truncated'] = after.st_size > MAX_TEXT
            record['declarations_and_dependency_lines'] = [
                {'line': i, 'text': line} for i, line in enumerate(text.splitlines(), 1)
                if SIGNALS.search(line) or any(api in line for api in API)]
        else:
            record['binary'] = True
            record['elf_static_metadata'] = elf_metadata(preview)
            strings = [m.group().decode('ascii') for m in re.finditer(rb'[ -~]{8,}', preview)]
            record['binary_reference_strings'] = [s for s in strings if SIGNALS.search(s)]
            record['binary_strings_prefix_only'] = after.st_size > MAX_TEXT
            record['dynamic_dependencies'] = 'NOT resolved: no ldd, ELF execution, or loader invocation'
    except (OSError, ValueError) as exc:
        record['error'] = str(exc)
    return record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tmux-session', required=True)
    parser.add_argument('--receipt-name', required=True,
                        help='new binding-evidence-NAME.json basename; never scratch')
    parser.add_argument('--extra-file', action='append', default=[],
                        help='explicit installed dependency path discovered by static review; repeatable')
    args = parser.parse_args()
    if not re.fullmatch(r'binding-evidence-[A-Za-z0-9_-]+\.json', args.receipt_name):
        parser.error('receipt name must be a fresh binding-evidence-NAME.json basename')
    if pwd.getpwuid(os.getuid()).pw_name != 'uwb_student00':
        parser.error('workstation user mismatch; no local/fixture mode')
    if Path(__file__).absolute().parent != HERE or Path.cwd() != HERE:
        parser.error('collector path and cwd must equal the fixed remote qualification directory')
    no_links(HERE)
    if not os.environ.get('TMUX') or not os.environ.get('TMUX_PANE'):
        parser.error('must already be inside the authorized named tmux session')
    # Only subprocess: read existing tmux metadata; -N forbids server startup.
    tmux_argv = ['/usr/bin/tmux', '-N', 'display-message', '-p', '-t',
                 os.environ['TMUX_PANE'], '#{session_name}\t#{session_id}\t#{pane_id}\t#{pane_pid}']
    tmux = subprocess.run(tmux_argv, capture_output=True, text=True, timeout=10,
                          check=False)
    if tmux.returncode or tmux.stdout.strip().split('\t')[0] != args.tmux_session:
        parser.error('cannot verify exact existing tmux session: ' + tmux.stderr)
    output = HERE / args.receipt_name
    if output.exists() or output.is_symlink():
        parser.error('receipt already exists; never overwrite')
    template = json.loads((HERE / 'binding-template.json').read_text())
    baseline = json.loads((HERE / 'source-baseline.json').read_text())
    source = BASE / 'ofs-agx7-pcie-attach/ipss/ia840f/bwbmc'
    paths = set()
    expected = {}
    for group in ('tool_hashes', 'catalog_hashes', 'evidence_hashes'):
        for path, digest in template[group].items():
            paths.add(Path(path)); expected[path] = digest
    # Historical parent preflight expectations; never substitute for this read.
    expected.update({
        str(INSTALL / 'qsys/bin/qsys-generate'): '10db24cb15ba97694c1385b56f6ffde3bcfcd2249e2901c9a3f0c34b68da14df',
        str(INSTALL / 'qsys/bin/qsys-script'): 'a0c811ed4010961b2ae4e92711492a172be969c900709b380f3c66db875d3f75',
        str(INSTRUCTIONS): 'bc40aa72401c41bba3929fe722baa86b47b98f67b15cdb1de2da6eadcf208d99',
    })
    for name, digest in template['harness_hashes'].items():
        paths.add(HERE / name); expected[str(HERE / name)] = digest
    for name, digest in template['source_hashes'].items():
        paths.add(source / name); expected[str(source / name)] = digest
    for name, digest in baseline['boundary'].items():
        paths.add(BASE / name); expected[str(BASE / name)] = digest
    paths.update((INSTRUCTIONS, HERE / 'binding-template.json', Path(__file__).absolute(),
                  INSTALL / 'quartus/bin/quartus_sh', INSTALL / 'quartus/linux64/quartus_sh',
                  INSTALL / 'quartus/sopc_builder/bin/qsys-script',
                  INSTALL / 'quartus/linux64/java17/jre64/bin/java',
                  INSTALL / 'quartus/linux64/java17/jre64/release',
                  INSTALL / 'ip/altera/sopc_builder_ip/common/embedded_ip_hwtcl_common.tcl',
                  INSTALL / 'ip/altera/pgm/lib/intel_avst_dp_scfifo/intel_avst_dp_scfifo.sv'))
    for name in args.extra_file:
        path = Path(name)
        if not path.is_absolute() or '..' in path.parts or not path.is_relative_to(INSTALL):
            parser.error('--extra-file must be a lexical absolute path under the pinned installation')
        paths.add(path)
    records = {}
    edges = []
    pending = sorted(paths)
    while pending and len(records) < MAX_FILES:
        path = pending.pop(0)
        if str(path) in records:
            continue
        record = inspect(path)
        records[str(path)] = record
        if str(path) in expected:
            record['expected_sha256'] = expected[str(path)]
            record['matches_expected'] = (record.get('sha256') == expected[str(path)]
                                          if expected[str(path)] is not None else None)
        # Narrow resolution only: literal absolute source, known QUARTUS_ROOTDIR,
        # and literal component fileset PATH relative to its defining Tcl file.
        # Never eval/substitute arbitrary shell or Tcl, or assume relative source cwd.
        for item in record.get('declarations_and_dependency_lines', []):
            line = item['text'].strip()
            if line.startswith('#'):
                continue
            dep = None
            basis = None
            m = re.match(r'source\s+(.+?)\s*$', line)
            if m:
                token = m.group(1).strip('"{}')
                token = token.replace('$env(QUARTUS_ROOTDIR)', str(INSTALL / 'quartus'))
                if token.startswith('/') and not re.search(r'[$\[\];\s]', token):
                    dep = Path(os.path.normpath(token)); basis = 'literal/known-root source reference'
            m = re.search(r'\badd_fileset_file\b.*?\bPATH\s+(?:"([^"\n]+)"|([^\s]+))', line)
            if m:
                token = m.group(1) or m.group(2)
                if not re.search(r'[$\[\];]', token):
                    dep = Path(os.path.normpath(str(path.parent / token)))
                    basis = 'fileset-relative literal; callback activation not established'
            edge = {'from': str(path), 'line': item['line'], 'expression': line,
                    'candidate_path': str(dep) if dep else None,
                    'basis': basis or 'unresolved/declaration; manual static review required'}
            edges.append(edge)
            if dep and dep.is_relative_to(INSTALL) and str(dep) not in records:
                pending.append(dep)
    # Filename index is discovery, not catalog selection. No symlink directory descent.
    kinds = {'altera_s10_mailbox_client', 'altera_s10_mailbox_client_core',
             'altera_clock_bridge', 'altera_reset_bridge', 'altera_config_stream_endpoint',
             'intel_memory_initiator_endpoint'}
    for name in template['source_hashes']:
        if name.endswith('.ip'):
            root = ET.fromstring((source / name).read_bytes())
            kinds.update(e.text.strip() for e in root.iter()
                         if e.tag.split('}')[-1] == 'moduleName' and e.text)
    wanted = {kind.lower() + '_hw.tcl' for kind in kinds}
    index = []; index_errors = []; skipped_links = []; entries = 0
    for directory, dirs, files in os.walk(INSTALL, followlinks=False,
                                          onerror=lambda e: index_errors.append(str(e))):
        dirs.sort(); files.sort()
        for name in list(dirs):
            if (Path(directory) / name).is_symlink():
                skipped_links.append(str(Path(directory) / name)); dirs.remove(name)
        entries += len(dirs) + len(files)
        if entries > MAX_INDEX:
            index_errors.append('MAX_INDEX exceeded; index incomplete'); break
        for name in files:
            candidate = Path(directory) / name
            if name.lower() in wanted or name == 'embedded_ip_hwtcl_common.tcl' or name == 'pkgIndex.tcl':
                index.append(str(candidate))
    # Capture matching catalog/package candidates, leaving all limits explicit.
    for name in index:
        if name not in records and len(records) < MAX_FILES:
            records[name] = inspect(Path(name))
    receipt = {
        'schema': 'mailbox-binding-static-evidence-v1',
        'collected_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'host': os.uname().nodename, 'user': pwd.getpwuid(os.getuid()).pw_name,
        'cwd': str(Path.cwd()), 'collector_argv': sys.argv,
        'tmux': {'argv': tmux_argv, 'returncode': tmux.returncode, 'output': tmux.stdout},
        'ready_for_build': False, 'authorization': False,
        'vendor_or_tcl_executed': False, 'project_created_or_opened': False,
        'records': records, 'dependency_references': edges,
        'catalog_candidate_index': index, 'requested_catalog_kinds': sorted(kinds),
        'index_errors': index_errors, 'skipped_symlink_directories': skipped_links,
        'pending_uncollected_paths': sorted({str(x) for x in pending if str(x) not in records}),
        'candidate_index_uncollected': [x for x in index if x not in records],
        'limits': {'max_files': MAX_FILES, 'max_index_entries': MAX_INDEX,
                   'max_text_bytes_per_file': MAX_TEXT},
        'not_established': [
            'complete static closure: new indexed candidates require dependency review/next receipt',
            'actual standard-$ catalog order, aliases, competing resolution or callback activation',
            'shell expansion, Java classpath/JNI, ELF interpreter/DT_NEEDED/dlopen and OS libraries',
            'qsys API 26.1 availability in loader and legacy 15.1/16.0 compatibility',
            'minimal scratch project acceptance, selective upgrade or save behavior',
            'instructions/side-effect/license review or execution permission'],
        'license_environment_presence_only': {k: k in os.environ for k in
                                             ('LM_LICENSE_FILE', 'ALTERAD_LICENSE_FILE')},
    }
    # O_EXCL is the only write; no parent creation, chmod, rename, cleanup, or approval.
    data = (json.dumps(receipt, indent=2, sort_keys=True) + '\n').encode()
    no_links(HERE)
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as stream:
        stream.write(data)
    actual = output.read_bytes()
    if actual != data:
        raise RuntimeError('receipt readback mismatch; preserve partial file')
    print(json.dumps({'receipt': str(output), 'sha256': hashlib.sha256(actual).hexdigest(),
                      'authorization': False, 'ready_for_build': False}))


if __name__ == '__main__':
    main()
