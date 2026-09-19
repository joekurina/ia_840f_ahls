"""Local, fail-closed receiver. No remote access and no diagnostic execution."""
import argparse
import base64
import binascii
import hashlib
import json
import math
from pathlib import Path
import sys

STREAM_CAP = 1048576
OUTER_CAP = 3 * 1048576
LAUNCHER_SHA = '2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2'
COLLECTOR_SHA = '6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897'
FLAGS = ('authorization', 'ready_for_build', 'vendor_run')
FS_OPERATIONS = frozenset(('candidate.lstat', 'candidate.recheck', 'resolve.lstat',
                          'resolve.readlink', 'resolve.recheck', 'qualification.lstat',
                          'mountinfo.open', 'mountinfo.read', 'mountinfo.close',
                          'directory.recheck', 'lstat', 'readlink', 'scandir.open',
                          'scandir.iterate', 'scandir.close', 'entry.recheck'))
OS_ERRORS = frozenset(('OSError', 'PermissionError', 'FileNotFoundError',
                       'NotADirectoryError', 'IsADirectoryError', 'BlockingIOError',
                       'InterruptedError', 'FileExistsError', 'TimeoutError',
                       'ChildProcessError', 'ProcessLookupError', 'ConnectionError',
                       'BrokenPipeError', 'ConnectionAbortedError',
                       'ConnectionRefusedError', 'ConnectionResetError'))


def digest(data):
    return hashlib.sha256(data).hexdigest()


def unique_object(pairs):
    obj = {}
    for key, value in pairs:
        if key in obj:
            raise ValueError('duplicate JSON key: ' + key)
        obj[key] = value
    return obj


def reject_constant(value):
    raise ValueError('nonfinite JSON constant: ' + value)


def finite_float(value):
    number = float(value)
    if not math.isfinite(number):
        raise ValueError('nonfinite JSON number')
    return number


def document(raw):
    # json.loads permits only JSON whitespace and exactly one complete document.
    value = json.loads(raw.decode('ascii'), object_pairs_hook=unique_object,
                       parse_constant=reject_constant, parse_float=finite_float)
    if type(value) is not dict:
        raise ValueError('JSON object required')
    return value


def nonnegative_number(value):
    return ((type(value) is int and value >= 0) or
            (type(value) is float and value >= 0 and math.isfinite(value)))


def counts_valid(value):
    return (type(value) is dict and all(type(value.get(k)) is int and
            0 <= value[k] <= 250000 for k in ('visited', 'discovered')))


def filesystem_failure(value):
    """Recognize the collector's actual failure shape, never normalize paths."""
    return (type(value) is dict and 'result' not in value and
            value.get('phase') in ('selection', 'mount_guard', 'traversal') and
            type(value.get('operation')) is str and value['operation'] in FS_OPERATIONS and
            type(value.get('path')) is str and
            type(value.get('exception')) is str and value['exception'] in OS_ERRORS and
            type(value.get('errno')) is int and value['errno'] > 0 and
            all(k in value and (value[k] is None or type(value[k]) is str)
                for k in ('filename', 'filename2', 'selected_root')) and
            'reason' in value and value['reason'] is None and
            counts_valid(value.get('counts')) and nonnegative_number(value.get('elapsed')))


def evaluate(raw, exit_status=None, transport_errors=()):
    """Return derived assessment and exact decoded bytes; never alter raw input.

    exit_status is the captured command's exit code, NOT the collector's raw
    waitpid status. Only an actual int zero accepts. None means missing capture.
    """
    result = dict(classification='INCOMPLETE', observation='unvalidated_or_incomplete',
                  command_exit_status=exit_status, issues=[], authorization=False,
                  ready_for_build=False, vendor_run=False, historical_cause_established=False,
                  raw_length=len(raw), raw_sha256=digest(raw))
    issues = result['issues']
    decoded = {}
    if type(exit_status) is not int or exit_status != 0:
        issues.append('command_exit_status_missing_invalid_or_nonzero')
    issues.extend('transport_error:' + str(x) for x in transport_errors)
    if len(raw) > OUTER_CAP:
        issues.append('outer_input_exceeds_3MiB')
        return result, decoded
    try:
        outer = document(raw)
    except (ValueError, TypeError, RecursionError) as exc:
        issues.append('outer_JSON:' + str(exc))
        return result, decoded

    # Structural/integrity errors are distinct from a valid diagnostic failure.
    integrity = []
    for key in FLAGS:
        if outer.get(key) is not False:
            integrity.append('outer_flag:' + key)
    binding = outer.get('launcher_binding')
    if not (type(binding) is dict and type(binding.get('length')) is int and
            binding['length'] == 30087 and binding.get('sha256') == LAUNCHER_SHA):
        integrity.append('launcher_binding')
    if (type(outer.get('collector_length')) is not int or
            outer['collector_length'] != 13851 or outer.get('collector_sha256') != COLLECTOR_SHA):
        integrity.append('collector_binding')
    if not nonnegative_number(outer.get('elapsed')):
        integrity.append('outer_elapsed')
    for name in ('stdout', 'stderr'):
        try:
            item = outer.get(name)
            if type(item) is not dict or type(item.get('base64')) is not str:
                raise ValueError('stream_object_or_base64_type')
            encoded = item['base64']
            if len(encoded) > 4 * ((STREAM_CAP + 2) // 3):
                raise ValueError('encoded_stream_limit')
            value = base64.b64decode(encoded.encode('ascii'), validate=True)
            if len(value) > STREAM_CAP:
                raise ValueError('decoded_stream_limit')
            decoded[name] = value  # Retain even if subsequent binding checks fail.
            if base64.b64encode(value).decode('ascii') != encoded:
                raise ValueError('noncanonical_base64')
            if type(item.get('length')) is not int or item['length'] != len(value):
                raise ValueError('length_mismatch')
            if item.get('sha256') != digest(value):
                raise ValueError('sha256_mismatch')
        except (ValueError, TypeError, binascii.Error) as exc:
            integrity.append(name + ':' + str(exc))

    report = None
    if 'stdout' in decoded:
        try:
            report = document(decoded['stdout'])
        except (ValueError, TypeError, RecursionError) as exc:
            integrity.append('collector_JSON:' + str(exc))
    else:
        integrity.append('collector_stdout_unavailable')
    terminal = None
    if report is not None:
        terminal = report.get('terminal')
        result['collector_terminal'] = terminal  # Exact values, not resolved paths.
        result['collector_close_errors'] = report.get('close_errors')
        for key in FLAGS:
            if report.get(key) is not False:
                integrity.append('collector_flag:' + key)
        if not counts_valid(report.get('counts')):
            integrity.append('collector_counts')
        if not nonnegative_number(report.get('elapsed')):
            integrity.append('collector_elapsed')
        if type(report.get('selection')) is not list:
            integrity.append('collector_selection')
        if type(report.get('close_errors')) is not list:
            integrity.append('collector_close_errors_type')
        identity = report.get('identity')
        expected = dict(host='Agilex7Workstation', uid=1000, euid=1000,
                        user='uwb_student00', logname='uwb_student00',
                        tmux='/tmp/tmux-1000/default,7828,4')
        if not (type(identity) is dict and all(type(identity.get(k)) is type(v) and
                identity[k] == v for k, v in expected.items())):
            integrity.append('collector_identity')

    issues.extend(integrity)
    control_ok = (outer.get('reaped') is True and type(outer.get('wait_status')) is int and
                  outer.get('timed_out') is False and outer.get('errors') == [])
    for key, expected in (('terminal', 'completed'), ('reaped', True), ('wait_status', 0),
                          ('timed_out', False), ('errors', [])):
        if type(outer.get(key)) is not type(expected) or outer[key] != expected:
            issues.append('outer_not_accepted:' + key)
    completed = type(terminal) is dict and terminal == {'result': 'completed'}
    if not completed:
        issues.append('collector_not_completed')
    if report is not None:
        if report.get('close_errors') != []:
            issues.append('collector_close_errors')
        if completed and (report.get('guard') != 'passed' or
                          type(report.get('roots')) is not list or not report['roots'] or
                          not all(type(x) is str and (x in ('/usr', '/bin', '/lib', '/lib64') or
                                  x.startswith('/usr/')) for x in report['roots'])):
            issues.append('collector_traversal_guard_or_roots')
    if not issues:
        result.update(classification='COMPLETED', observation='successful_current_traversal')
    elif (not integrity and not transport_errors and type(exit_status) is int and
          exit_status == 1 and control_ok and outer.get('terminal') == 'INCOMPLETE' and
          outer.get('wait_status') == 256 and filesystem_failure(terminal)):
        result['observation'] = 'observed_current_filesystem_error'
    return result, decoded


def preserve(source, destination):
    """Copy captured file verbatim with bounded memory; do not truncate oversize evidence."""
    size, h = 0, hashlib.sha256()
    with open(source, 'rb') as src, open(destination, 'xb') as dst:
        while True:
            block = src.read(65536)
            if not block:
                break
            dst.write(block)
            h.update(block)
            size += len(block)
    return dict(length=size, sha256=h.hexdigest())


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--raw', type=Path, required=True, help='captured raw stdout file')
    parser.add_argument('--exit-status', type=int, help='exact captured command exit code; omitted fails closed')
    parser.add_argument('--command-stderr', type=Path, help='separate captured outer stderr file')
    parser.add_argument('--transport-error', action='append', default=[])
    parser.add_argument('--output', type=Path, required=True, help='NEW local evidence directory')
    args = parser.parse_args(argv)
    # Never overwrite an existing evidence directory or write back to input files.
    args.output.mkdir(exist_ok=False)
    raw_path = args.output / 'raw-envelope.bin'
    capture = preserve(args.raw, raw_path)
    stderr_capture = None
    if args.command_stderr is not None:
        stderr_capture = preserve(args.command_stderr, args.output / 'command-stderr.bin')
    if capture['length'] <= OUTER_CAP:
        result, streams = evaluate(raw_path.read_bytes(), args.exit_status, args.transport_error)
    else:
        result, streams = evaluate(b'', args.exit_status, args.transport_error)
        result['issues'] = [x for x in result['issues'] if not x.startswith('outer_JSON:')]
        result['issues'].append('outer_input_exceeds_3MiB')
        result.update(raw_length=capture['length'], raw_sha256=capture['sha256'])
    result['command_stderr_capture'] = stderr_capture
    for name, value in streams.items():
        (args.output / ('collector-' + name + '.bin')).write_bytes(value)
    (args.output / 'result.json').write_text(json.dumps(result, ensure_ascii=True, indent=2) + '\n', encoding='ascii')
    print(result['classification'])
    return 0 if result['classification'] == 'COMPLETED' else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except OSError as exc:
        print('INCOMPLETE: local evidence I/O failed: ' + str(exc), file=sys.stderr)
        sys.exit(2)
