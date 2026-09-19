#!/usr/bin/env python3
"""Finite static follow-up. Workstation-only main; sole write is a new receipt.
No vendor, Java, Tcl, ELF, shell, loader, project or dependency execution.
Import-safe for LOCAL fixture tests; no installed-file reads at import time.
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
import zipfile

HERE = Path('/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01')
INSTALL = Path('/opt/altera/26.1.1')
SESSION = 'ia840f_migration_preflight'
LIVE_SHA = '0c13de271466b3db1fd10585f99d965886a662e67d8421022bceceb9c768c0ed'
REQUEST_SHA = '8ca7745b67b51a1aadbd1ba2ad9982d14e48fee56c31a2ef6584f54659b4e9aa'
INSPECT_SHA = 'b47e32cdcc75e4782e9d8c2a925be7b93deafb44257a4ae989ca38266a77e717'
API = ('load_component', 'save_component', 'reload_component_footprint',
       'validate_component_footprint', 'sync_sysinfo_parameters')
CONFIG_SUFFIX = {'.ini', '.conf', '.cfg', '.properties', '.xml', '.txt', '.sh', '.tcl', '.json', '.ipx'}
SIGNAL = re.compile(r'class.?path|main.class|\.jar\b|catalog|search.?path|package\s+(?:provide|ifneeded)|qsys|sopc', re.I)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pinned(path, digest):
    data = path.read_bytes()
    if sha(data) != digest:
        raise ValueError('pinned input mismatch: ' + str(path))
    return data


def load_inspector(path):
    # Execute only the hash-pinned, reviewed Python definitions; __main__ is false.
    namespace = {'__name__': 'binding_static_helpers', '__file__': str(path)}
    exec(compile(pinned(path, INSPECT_SHA), str(path), 'exec'), namespace)
    return namespace


def report(query):
    return {'id': query['id'], 'limits': {k: v for k, v in query.items()
            if k.startswith('max_') or k in ('recursive_depth_limit', 'follow_symlink_directories')},
            'unresolved': [], 'counts': {}}


def walk(roots, cap, out, depth_limit=None):
    """Streaming scandir: never materialize an unbounded directory or follow links.
    Root entries have depth zero. Files at depth <= depth_limit are eligible.
    Enumeration order is filesystem order, retained in evidence; caps aren't uniqueness.
    """
    count = 0
    for root in roots:
        stack = [(Path(root), 0)]
        while stack:
            directory, depth = stack.pop()
            try:
                if any(p.is_symlink() for p in (directory, *directory.parents)):
                    out['unresolved'].append({'symlink_directory_skipped': str(directory)})
                    continue
                with os.scandir(directory) as it:
                    while True:
                        if count >= cap:
                            out['unresolved'].append('directory entry cap reached; enumeration incomplete')
                            out['counts']['directory_entries'] = count
                            return
                        try:
                            entry = next(it)
                        except StopIteration:
                            break
                        count += 1
                        out['counts']['directory_entries'] = count
                        if entry.is_dir(follow_symlinks=False):
                            if depth_limit is None or depth < depth_limit:
                                stack.append((Path(entry.path), depth + 1))
                            else:
                                out['unresolved'].append({'depth_limit_directory': entry.path})
                        elif entry.is_symlink():
                            out['unresolved'].append({'discovery_symlink_skipped': entry.path})
                        elif entry.is_file(follow_symlinks=False):
                            yield Path(entry.path)
            except OSError as exc:
                out['unresolved'].append({'directory': str(directory), 'error': str(exc)})
    out['counts']['directory_entries'] = count


class Collector:
    def __init__(self, request, live, helper):
        self.request = request
        self.old = live['records']
        self.helper = helper
        self.reused = set()
        self.records = {}

    def old_record(self, path):
        key = str(path)
        if key in self.old:
            self.reused.add(key)
            return self.old[key]
        return None

    def text(self, path, cap, out):
        """Full bounded text only; do not hash beyond a text budget."""
        old = self.old_record(path)
        if old is not None:
            if old.get('text_truncated') or 'text' not in old:
                out['unresolved'].append({'path': str(path), 'reason': 'prior record not full text; not reread'})
                return None
            if old['size'] > cap:
                out['unresolved'].append({'path': str(path), 'reason': 'text byte cap'})
                return None
            return old
        try:
            self.helper['no_links'](path)
            before = path.stat()
            if not stat.S_ISREG(before.st_mode) or before.st_size > cap:
                raise ValueError('not regular or text byte cap')
            with path.open('rb') as f:
                data = f.read(cap)
                after = os.fstat(f.fileno())
            if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
                    after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns) or len(data) != after.st_size:
                raise ValueError('changed during bounded read')
            text = data.decode('utf-8')
            if '\0' in text:
                raise ValueError('binary file, not decoded as config')
            return {'path': str(path), 'sha256': sha(data), 'size': len(data),
                    'text': text, 'stable_during_read': True}
        except (OSError, ValueError) as exc:
            out['unresolved'].append({'path': str(path), 'error': str(exc)})
            return None

    def catalog(self, q):
        out = report(q)
        out.update(matches=[], filename_candidates=[], full_sources={})
        kinds = q['kind_filter']
        token = re.compile(r'(?<![\w])(?:' + '|'.join(map(re.escape, kinds)) + r')(?![\w])')
        ntext = 0
        for path in walk(q['roots'], q['max_directory_entries'], out):
            if any(k.lower() in path.name.lower() for k in kinds):
                out['filename_candidates'].append(str(path))
            if path.suffix.lower() not in CONFIG_SUFFIX:
                continue
            if ntext >= q['max_text_files']:
                out['unresolved'].append('text file cap reached; catalog scan incomplete')
                break
            ntext += 1
            record = self.text(path, q['max_bytes_per_file'], out)
            if not record:
                continue
            text = record['text']
            lines = text.splitlines()
            hits = [{'line': i, 'text': s} for i, s in enumerate(lines, 1) if token.search(s)]
            defaults = [{'line': i, 'text': s} for i, s in enumerate(lines, 1)
                        if re.search(r'catalog|search.?path|IP_SEARCH_PATH', s, re.I)]
            if not hits and not defaults:
                continue
            declarations = [{'line': i, 'text': s} for i, s in enumerate(lines, 1)
                            if re.search(r'set_module_property\s+(?:NAME|VERSION)\b', s, re.I)]
            out['matches'].append({'path': str(path), 'sha256': record['sha256'],
                                   'kind_or_index_references': hits, 'declarations': declarations,
                                   'default_search_references': defaults,
                                   'selection_proven': False})
            # Only SPI source definitions and search/index references get full text.
            full = ('spi_slave_to_avalon_mm_master_bridge' in text) or bool(defaults)
            if full:
                if len(out['full_sources']) < q['max_full_match_files']:
                    out['full_sources'][str(path)] = record
                else:
                    out['unresolved'].append({'full_source_cap': str(path)})
        out['counts'].update(text_files=ntext, full_match_files=len(out['full_sources']))
        out['requested_kinds_without_text_match'] = [k for k in kinds if not any(
            re.search(r'(?<![\w])' + re.escape(k) + r'(?![\w])', hit['text'])
            for match in out['matches'] for hit in match['kind_or_index_references'])]
        out['unresolved'].append('Static references/declarations do not prove catalog order or selected providers')
        return out

    def launcher(self, q):
        out = report(q)
        out.update(candidates=[], configs=[], resources=[], classpath_references=[], archive_scans=[])
        archives = []
        nconfig = 0
        for path in walk(q['roots'], q['max_directory_entries'], out, q['recursive_depth_limit']):
            if path.suffix.lower() == '.jar':
                out['candidates'].append(str(path))
                if len(archives) < q['max_archives']:
                    archives.append(path)
                else:
                    out['unresolved'].append({'archive_cap': str(path)})
            elif path.suffix.lower() in CONFIG_SUFFIX or re.search(r'classpath|\.vmoptions$|\.lax$', path.name, re.I):
                out['candidates'].append(str(path))
                if nconfig >= q['max_text_config_files']:
                    out['unresolved'].append({'text_config_cap': str(path)})
                    continue
                nconfig += 1
                rec = self.text(path, q['max_resource_bytes_each'], out)
                if rec:
                    out['configs'].append(rec)
                    self.classpath(rec['text'], path, out, manifest=False)
        total_members = 0
        for path in archives:
            try:
                self.helper['no_links'](path)
                before = path.stat()
                # Bound central-directory parsing before ZipFile allocates its member table.
                with path.open('rb') as f:
                    f.seek(max(0, before.st_size - 65557))
                    tail = f.read(65557)
                pos = tail.rfind(b'PK\x05\x06')
                if pos < 0 or len(tail) - pos < 22:
                    raise ValueError('missing classic ZIP EOCD')
                _, disk, cd_disk, disk_n, n, cd_size, _, comment = struct.unpack_from('<4s4H2IH', tail, pos)
                if disk or cd_disk or disk_n != n or n == 65535 or cd_size == 0xffffffff:
                    raise ValueError('split/ZIP64 archive not inspected')
                if pos + 22 + comment != len(tail) or cd_size > 64 * 1024 * 1024:
                    raise ValueError('invalid EOCD or supplementary 64MiB central-directory cap')
                if total_members + n > q['max_archive_members_total']:
                    out['unresolved'].append({'member_budget_exceeded': str(path), 'declared_members': n})
                    continue
                with zipfile.ZipFile(path) as archive:
                    members = archive.infolist()
                    if len(members) != n:
                        raise ValueError('central-directory member count mismatch')
                    total_members += len(members)
                    names = [x.filename for x in members if self.resource_name(x.filename)]
                    out['archive_scans'].append({'path': str(path), 'members_count': len(members),
                                                 'matching_member_names': names, 'whole_archive_hashed': False})
                    for info in members:
                        if not self.resource_name(info.filename):
                            continue
                        if len(out['resources']) >= q['max_matching_resources']:
                            out['unresolved'].append({'matching_resource_cap': str(path) + '!' + info.filename})
                            continue
                        if info.file_size > q['max_resource_bytes_each'] or info.flag_bits & 1:
                            out['unresolved'].append({'oversize_or_encrypted_resource': str(path) + '!' + info.filename})
                            continue
                        with archive.open(info) as f:
                            data = f.read(q['max_resource_bytes_each'])
                        if len(data) != info.file_size:
                            raise ValueError('resource size mismatch')
                        rec = {'archive': str(path), 'member': info.filename, 'sha256': sha(data),
                               'size': len(data), 'crc32': info.CRC}
                        try:
                            rec['text'] = data.decode('utf-8')
                        except UnicodeError:
                            rec['binary_resource'] = True
                            rec['api_strings'] = [s for s in API if s.encode() in data]
                        out['resources'].append(rec)
                        if info.filename.upper() == 'META-INF/MANIFEST.MF':
                            self.classpath(rec.get('text', ''), path, out, manifest=True)
                after = path.stat()
                if (before.st_ino, before.st_size, before.st_mtime_ns) != (after.st_ino, after.st_size, after.st_mtime_ns):
                    raise ValueError('archive changed during read; reject its resources')
            except (OSError, ValueError, RuntimeError, zipfile.BadZipFile, NotImplementedError) as exc:
                out['unresolved'].append({'archive': str(path), 'error': str(exc)})
        # One finite batch of explicitly referenced literal archives; no manifests followed recursively.
        hash_paths = sorted({r['candidate_path'] for r in out['classpath_references'] if r.get('candidate_path')})
        archive_budget = {str(p) for p in archives}
        hashed = 0
        for name in hash_paths:
            if name not in archive_budget and len(archive_budget) >= q['max_archives']:
                out['unresolved'].append({'explicit_archive_hash_cap': name})
                continue
            archive_budget.add(name)
            self.identity(Path(name))
            hashed += 1
        out['counts'].update(archives=len(archives), archive_members=total_members,
                             matching_resources=len(out['resources']), text_configs=nconfig,
                             distinct_archives_touched=len(archive_budget),
                             explicit_archives_hashed_or_reused=hashed)
        out['api_tokens_not_observed'] = [api for api in API if not any(
            api in rec.get('text', '') or api in rec.get('api_strings', [])
            for rec in out['resources'] + out['configs'])]
        out['unresolved'].append('Only bounded member-name matched resources read; dynamically registered APIs, classpath expansion and actual selection remain unproven')
        return out

    @staticmethod
    def resource_name(name):
        lower = name.lower()
        return (lower == 'meta-inf/manifest.mf' or any(api in lower for api in API)
                or ((('qsys' in lower or 'sopc' in lower) and
                     any(x in lower for x in ('api', 'version', 'package', 'provider', '.tcl'))))
                or lower.endswith('pkgindex.tcl'))

    @staticmethod
    def classpath(text, origin, out, manifest):
        # Preserve literal order and main class; never interpolate variables or expand wildcards.
        text = re.sub(r'\r?\n ', '', text) if manifest else text
        for line_number, line in enumerate(text.splitlines(), 1):
            if not SIGNAL.search(line):
                continue
            item = {'origin': str(origin), 'line': line_number, 'literal': line,
                    'manifest': manifest}
            out['classpath_references'].append(item)
            if manifest:
                if not line.lower().startswith('class-path:'):
                    continue
                tokens = line.split(':', 1)[1].split()
            elif re.search(r'class.?path|(?:^|\s)-cp\s|(?:^|\s)-classpath\s', line, re.I):
                tokens = re.findall(r'(?:/[A-Za-z0-9_.+/-]+\.jar)\b', line)
            else:
                continue
            for order, token in enumerate(tokens):
                ref = dict(origin=str(origin), token=token, token_order=order,
                           line=line_number, basis='manifest-relative' if manifest else 'explicit absolute classpath token')
                if not re.search(r'[$\[\]{}*?\s:%]', token) and token.endswith('.jar'):
                    candidate = Path(os.path.normpath(str(origin.parent / token)))
                    if candidate.is_relative_to(INSTALL):
                        ref['candidate_path'] = str(candidate)
                out['classpath_references'].append(ref)

    def identity(self, path):
        if self.old_record(path) is None and str(path) not in self.records:
            self.records[str(path)] = self.helper['inspect'](path)
        return self.old.get(str(path), self.records.get(str(path)))

    def native(self, q):
        out = report(q)
        out.update(candidates=[], absent=[])
        matched = 0
        paths = [Path(root) / name for root in q['roots'] for name in q['names']]
        paths += [Path('/lib64/ld-linux-x86-64.so.2'), Path('/etc/ld.so.cache')]
        for path in dict.fromkeys(paths):
            try:
                path.lstat()
            except FileNotFoundError:
                out['absent'].append(str(path))
                continue
            except OSError as exc:
                out['unresolved'].append({'path': str(path), 'error': str(exc)})
                continue
            if matched >= q['max_matched_files']:
                out['unresolved'].append({'matched_file_cap': str(path)})
                continue
            matched += 1
            out['candidates'].append(str(path))
            self.identity(path)
        out['counts']['matched_files'] = matched
        out['unresolved'].append('All direct candidates, not selected loader identities; new DT_NEEDED entries are references only, never expanded')
        return out

    def helpers(self, q):
        out = report(q)
        out.update(input_records=[], references=[], additional_files=[])
        # These exact five live02 texts were inspected locally: no source or package
        # require command exists. Keep possible dependency lines as references only.
        # No Tcl scope/evaluation guesses, and zero extra hops is <= one edge/16 files.
        for name in q['input_files']:
            rec = self.text(Path(name), q['max_bytes_per_file'], out)
            out['input_records'].append({'path': name, 'basis': 'live02, not reread'})
            if not rec:
                continue
            for i, line in enumerate(rec['text'].splitlines(), 1):
                if re.search(r'\bsource\b|package\s+(?:require|ifneeded|provide)|\bexec\b|add_fileset_file', line):
                    out['references'].append({'from': name, 'line': i, 'literal': line,
                                               'followed': False, 'activation_not_inferred': True})
        out['counts']['additional_files'] = 0
        out['unresolved'].append('Generation/conditional/dynamic expressions retained as references only; no automatic provider or helper expansion')
        return out


def context(q, helper, tmux):
    out = report(q)
    scratch = Path(q['scratch'])
    out.update(tmux=tmux, host=os.uname().nodename, scratch_ancestors=[])
    for path in reversed((scratch, *scratch.parents)):
        try:
            st = path.lstat()
            out['scratch_ancestors'].append({'path': str(path), 'mode': oct(st.st_mode),
                'inode': st.st_ino, 'symlink': stat.S_ISLNK(st.st_mode)})
        except FileNotFoundError:
            out['scratch_ancestors'].append({'path': str(path), 'absent': True})
    out['scratch_absent_now'] = not os.path.lexists(scratch)
    license_path = Path(q['license_path'])
    out['license'] = {'path': str(license_path), 'readable_access_check': os.access(license_path, os.R_OK),
                      'contents_read': False}
    out['claim_policy'] = 'Exclusive scratch mkdir is durable claim; preserve failed claims; never cleanup/retry automatically'
    out['never_used_established'] = False
    out['environment_policy'] = 'Experiment must use independently reviewed closed binding env, not collector inherited env; no override/Java injection, no inherited Questa variables; license addition needs review'
    out['environment_presence_only'] = {k: k in os.environ for k in (
        'LM_LICENSE_FILE', 'ALTERAD_LICENSE_FILE', 'LD_LIBRARY_PATH', 'LD_PRELOAD',
        'JAVA_TOOL_OPTIONS', '_JAVA_OPTIONS', 'JDK_JAVA_OPTIONS', 'CLASSPATH',
        'QUARTUS_ROOTDIR_OVERRIDE', 'QUARTUS_BINDIR', 'PYTHONPATH')}
    out['monitoring_plan'] = {'reviewed': False, 'observer': None,
        'required': 'Independently name process/external-write observer or isolation, allowed caches/logs/license effects, stop/retain policy before experiment'}
    out['unresolved'] += ['Absence now cannot prove never-used history',
        'No monitoring mechanism deployed or verified by this collector; side-effect approval remains absent']
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--receipt-name', required=True)
    args = parser.parse_args()
    if not re.fullmatch(r'followup-evidence-[A-Za-z0-9_-]+\.json', args.receipt_name):
        parser.error('fresh followup-evidence-NAME.json basename required')
    if os.uname().nodename != 'Agilex7Workstation' or pwd.getpwuid(os.getuid()).pw_name != 'uwb_student00':
        parser.error('workstation host/user mismatch; no local execution mode')
    if Path(__file__).absolute().parent != HERE or Path.cwd() != HERE:
        parser.error('fixed qualification collector path and cwd required')
    for path in (HERE, *HERE.parents):
        if path.is_symlink():
            parser.error('symlink context rejected')
    if not os.environ.get('TMUX') or not re.fullmatch(r'%[0-9]+', os.environ.get('TMUX_PANE', '')):
        parser.error('must already be in named tmux session')
    argv = ['/usr/bin/tmux', '-N', 'display-message', '-p', '-t', os.environ['TMUX_PANE'],
            '#{session_name}\t#{session_id}\t#{pane_id}\t#{pane_pid}']
    tmux = subprocess.run(argv, capture_output=True, text=True, timeout=10, check=False)
    fields = tmux.stdout.strip().split('\t')
    if tmux.returncode or len(fields) != 4 or fields[0] != SESSION or fields[2] != os.environ['TMUX_PANE']:
        parser.error('cannot verify named existing tmux context')
    output = HERE / args.receipt_name
    if os.path.lexists(output):
        parser.error('receipt exists; never overwrite')
    request = json.loads(pinned(HERE / 'next-evidence-request.json', REQUEST_SHA))
    live = json.loads(pinned(HERE / 'binding-evidence-live02.json', LIVE_SHA))
    if len(live['records']) != 358 or any(not r.get('sha256') or r.get('error') or
            r.get('matches_expected') is False for r in live['records'].values()):
        raise ValueError('live02 record acceptance failed')
    for rec in live['records'].values():
        if 'text' in rec and not rec.get('text_truncated') and sha(rec['text'].encode()) != rec['sha256']:
            raise ValueError('live02 text identity mismatch')
    helper = load_inspector(HERE / 'collect-binding-evidence.py')
    collector = Collector(request, live, helper)
    queries = request['bounded_static_queries']
    ctx = context(queries[4], helper, {'argv': argv, 'output': tmux.stdout})
    # Context mismatch stops before installation scans; no scratch mutation ever.
    if not ctx['scratch_absent_now'] or any(x.get('symlink') for x in ctx['scratch_ancestors']):
        raise ValueError('scratch exists or ancestor symlink; preserve claim, stop')
    results = [collector.catalog(queries[0]), collector.launcher(queries[1]),
               collector.native(queries[2]), collector.helpers(queries[3]), ctx]
    receipt = {'schema': 'mailbox-followup-static-evidence-v1',
        'collected_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'reviewed': False, 'authorization': False, 'ready_for_build': False,
        'vendor_or_tcl_executed': False, 'project_created_or_opened': False,
        'basis_sha256': LIVE_SHA, 'request_sha256': REQUEST_SHA,
        'collector_sha256': sha(Path(__file__).read_bytes()), 'inspector_sha256': INSPECT_SHA,
        'queries': results, 'records': collector.records,
        'reused_live02_records': sorted(collector.reused),
        'reused_records_are_historical_not_revalidated': True,
        'stop_rule': 'Single bounded pass complete; independent residual-risk review, no automatic expansion or authorization'}
    data = (json.dumps(receipt, indent=2, sort_keys=True) + '\n').encode()
    helper['no_links'](HERE)
    fd = os.open(output, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'wb') as f:
        f.write(data)
    actual = output.read_bytes()
    if actual != data:
        raise RuntimeError('receipt readback mismatch; preserve partial receipt')
    print(json.dumps({'receipt': str(output), 'sha256': sha(actual),
                      'authorization': False, 'ready_for_build': False}))


if __name__ == '__main__':
    main()
