"""Finite CPU-only simulator command and output handling inside bwrap PID isolation."""
import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time


class NativeCommandError(RuntimeError):
    def __init__(self, label, rc):
        self.rc = rc
        super().__init__(f'{label} returned {rc}')


def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def live_namespace_helpers():
    rows = []
    for item in Path('/proc').iterdir():
        if not item.name.isdigit() or int(item.name) in (1, os.getpid()):
            continue
        try:
            fields = (item / 'stat').read_text().rsplit(')', 1)[1].split()
            if fields[0] not in ('Z', 'X'):
                rows.append({'pid': int(item.name), 'state': fields[0],
                             'start_ticks': fields[19],
                             'argv': (item / 'cmdline').read_bytes().replace(b'\0', b' ').decode(errors='replace')})
        except FileNotFoundError:
            continue
    return rows


def abort_namespace(base, result, save, row, logfile, rc, error):
    """Exit the private namespace command; bwrap/init termination kills its children."""
    try:
        result.update(success=False, effective_rc=rc, error=repr(error),
                      ended=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                      namespace_shutdown_requested=True)
        row['ended'] = result['ended']
        row['log'] = logfile.name
        row['log_complete'] = False
        try:
            raw = logfile.read_bytes()
            row['log_prefix_sha256'] = hashlib.sha256(raw).hexdigest()
            row['log_prefix_bytes'] = len(raw)
        except BaseException as capture_error:
            row['capture_error'] = repr(capture_error)
        try:
            save()
        except BaseException as save_error:
            result['save_error'] = repr(save_error)
        with (base / 'result.json').open('x') as stream:
            json.dump(result, stream, indent=2)
            stream.write('\n')
    finally:
        # No PGID is signaled after reaping. This exits the whole fresh bwrap
        # PID namespace, including helpers that created another process group.
        os._exit(rc)


def run_command(base, result, save, label, argv, cwd, timeout):
    assert os.environ['HLS_OUTER_PID_NAMESPACE'] != os.readlink('/proc/self/ns/pid')
    assert os.getppid() in (0, 1), 'Command supervisor must be the isolated entry'
    assert not live_namespace_helpers(), 'Previous command still has live helpers'
    logfile = base / (label + '.log')
    row = {'label': label, 'argv': [str(a) for a in argv], 'cwd': str(cwd),
           'started': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'rc': None}
    result['commands'].append(row)
    save()
    print('START', label, flush=True)
    deadline = time.monotonic() + timeout
    with logfile.open('xb') as output:
        process = None
        try:
            process = subprocess.Popen(row['argv'], cwd=cwd, stdout=output,
                                       stderr=subprocess.STDOUT, start_new_session=True)
            row['namespace_pid'] = process.pid
            save()
            row['rc'] = process.wait(timeout=max(0.001, deadline - time.monotonic()))
            # Preserve native status before postflight, and allow ordinary helper
            # cleanup only within this same original command deadline.
            save()
            while True:
                helpers = live_namespace_helpers()
                if not helpers:
                    break
                row['last_live_helpers'] = helpers
                if time.monotonic() >= deadline:
                    raise subprocess.TimeoutExpired(row['argv'], timeout)
                time.sleep(0.05)
            row['helpers_drained'] = True
        except BaseException as error:
            if process is None:
                raise
            code = 124 if isinstance(error, subprocess.TimeoutExpired) else 1
            row['timed_out'] = isinstance(error, subprocess.TimeoutExpired)
            abort_namespace(base, result, save, row, logfile, code, error)
    row.update(ended=datetime.datetime.now(datetime.timezone.utc).isoformat(),
               log=logfile.name, log_sha256=digest(logfile),
               log_bytes=logfile.stat().st_size, log_complete=True)
    save()
    print('END', label, 'rc=' + str(row['rc']), flush=True)
    if row['rc'] != 0:
        raise NativeCommandError(label, row['rc'])
    return logfile.read_text(errors='replace')


def validate_text(job, output, isolated_simulator=False):
    warning = 'hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.'
    lines = output.splitlines()
    warnings = lines.count(warning)
    if warnings:
        if not isolated_simulator:
            raise ValueError('Expected topology warning lacks verified isolated simulator context')
        output = '\n'.join(line for line in lines if line != warning)
    errors = []
    for pattern in job['required_patterns']:
        if not re.search(pattern, output, re.MULTILINE):
            errors.append('missing required pattern: ' + pattern)
    if len(re.findall(r'\bPASSED\b', output)) < job['minimum_pass_markers']:
        errors.append('missing complete native PASS marker count')
    for pattern in [r'\b(?:FAIL|FAILED)\b', r'\b(?:error|fatal)(?:\s+\([^)]*\))?\s*:',
                    r'^\s*(?:#\s*)?ERROR\s*$', r'Caught[^\n]*SYCL[^\n]*exception',
                    r'\bmismatch\b', r'\bErrors\s*:\s*[1-9]\d*\b']:
        if re.search(pattern, output, re.MULTILINE | re.IGNORECASE):
            errors.append('failure diagnostic: ' + pattern)
    if errors:
        raise ValueError('; '.join(errors))
    return {'required_patterns_found': job['required_patterns'],
            'native_pass_markers': len(re.findall(r'\bPASSED\b', output)),
            'retained_expected_hwloc_warning_count': warnings,
            'verification_scope': job['verification_scope']}
