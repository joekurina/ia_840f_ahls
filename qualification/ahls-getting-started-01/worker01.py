"""Run only the finite GettingStarted jobs; each gets private devices/PID space."""
import datetime
import json
import os
from pathlib import Path
import shlex
import subprocess

R = Path('/home/uwb_student00/ahls/new_BSP/work_ahls_getting_started_01')
assert os.environ.get('TMUX')
with (R / 'worker-claim.json').open('x') as stream:
    json.dump({'pid': os.getpid(), 'started': datetime.datetime.now(datetime.timezone.utc).isoformat()}, stream)
state = {'finished': False, 'success': False, 'hardware_access': False, 'jobs': []}
jobs = json.loads((R / 'jobs.json').read_text())


def save():
    temporary = R / 'worker-status.tmp'
    temporary.write_text(json.dumps(state, indent=2) + '\n')
    temporary.replace(R / 'worker-status.json')


save()
for identifier, job in jobs.items():
    B = R / 'runs' / identifier
    B.mkdir()
    (B / 'home').mkdir()
    (B / 'tmp').mkdir()
    icd = 'libintelocl_emu.so:libalteracl.so' if job['target'] == 'fpga_sim' else 'libintelocl_emu.so'
    setup = ('source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh >/dev/null 2>&1 || exit $?; '
             'export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/25.1/quartus; '
             'export PATH=/opt/altera/25.1/questa_fe/bin:/opt/altera/25.1/quartus/bin:/opt/altera/25.1/quartus/sopc_builder/bin:$PATH; '
             'export LD_LIBRARY_PATH=' + shlex.quote(str(R / 'runtime')) + ':$LD_LIBRARY_PATH; '
             'export OCL_ICD_FILENAMES=' + shlex.quote(icd) + '; '
             'export CL_CONTEXT_MPSIM_DEVICE_INTELFPGA=1; '
             'exec /usr/bin/python3 -I -B ' + shlex.quote(str(R / 'run-case.py')))
    argv = ['/usr/bin/bwrap', '--die-with-parent', '--unshare-pid', '--ro-bind', '/', '/',
            '--bind', str(B), str(B), '--ro-bind', str(R / 'source'), str(R / 'source'),
            '--ro-bind', str(R / 'icd'), '/etc/OpenCL/vendors', '--dev', '/dev', '--proc', '/proc',
            '--tmpfs', '/sys', '--tmpfs', '/tmp', '--chdir', str(B),
            '--setenv', 'HOME', str(B / 'home'), '--setenv', 'TMPDIR', str(B / 'tmp'),
            '--setenv', 'GS_JOB', identifier,
            '--setenv', 'HLS_OUTER_PID_NAMESPACE', os.readlink('/proc/self/ns/pid'),
            '--', '/bin/bash', '-c', setup]
    row = {'id': identifier, 'started': datetime.datetime.now(datetime.timezone.utc).isoformat(),
           'namespace_rc': None, 'success': False}
    state['jobs'].append(row)
    save()
    print('START', identifier, flush=True)
    with (B / 'outer.log').open('xb') as output:
        child = subprocess.Popen(argv, stdout=output, stderr=subprocess.STDOUT)
        row['namespace_leader_pid'] = child.pid
        save()
        row['namespace_rc'] = child.wait()
    row['ended'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    if (B / 'result.json').is_file():
        result = json.loads((B / 'result.json').read_text())
        row['success'] = row['namespace_rc'] == 0 and result['success'] is True
        row['error'] = result.get('error')
    save()
    print('END', identifier, 'rc=' + str(row['namespace_rc']), 'success=' + str(row['success']), flush=True)
    if not row['success']:
        state['stopped_on_failure'] = identifier
        break
state['finished'] = True
state['success'] = len(state['jobs']) == len(jobs) and all(row['success'] for row in state['jobs'])
save()
with (R / 'worker-result.json').open('x') as stream:
    stream.write(json.dumps(state, indent=2) + '\n')
raise SystemExit(0 if state['success'] else 1)
