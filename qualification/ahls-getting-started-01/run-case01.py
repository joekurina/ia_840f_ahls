"""Run one named upstream CMake target in a private CPU-only namespace."""
import datetime
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import resource
import shutil
import shlex

R = Path('/home/uwb_student00/ahls/new_BSP/work_ahls_getting_started_01')
job = json.loads((R / 'jobs.json').read_text())[os.environ['GS_JOB']]
B = R / 'runs' / os.environ['GS_JOB']
S = R / 'source'
spec = importlib.util.spec_from_file_location('native_support', R / 'native-support.py')
assert spec is not None and spec.loader is not None
support = importlib.util.module_from_spec(spec)
spec.loader.exec_module(support)
result = {'job': job, 'success': False, 'hardware_access': False, 'commands': [],
          'started': datetime.datetime.now(datetime.timezone.utc).isoformat()}


def save():
    temporary = B / 'status.tmp'
    temporary.write_text(json.dumps(result, indent=2) + '\n')
    temporary.replace(B / 'status.json')


def run(label, argv, cwd=B, timeout=600):
    return support.run_command(B, result, save, label, argv, cwd, timeout)


def record_files(root, patterns):
    paths = {p for pattern in patterns for p in root.rglob(pattern) if p.is_file()}
    return {str(p.relative_to(B)): {'bytes': p.stat().st_size, 'sha256': support.digest(p)}
            for p in sorted(paths)}


try:
    assert __debug__ and Path.cwd() == B and not (B / 'result.json').exists()
    resource.setrlimit(resource.RLIMIT_AS, (64 * 1024**3, 64 * 1024**3))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    result['cpus'] = sorted(os.sched_getaffinity(0))
    assert result['cpus'] == json.loads((R / 'preflight.json').read_text())['cpus']
    result['address_space_limit_bytes'] = resource.getrlimit(resource.RLIMIT_AS)[0]
    result['pid_namespace'] = os.readlink('/proc/self/ns/pid')
    result['outer_pid_namespace'] = os.environ['HLS_OUTER_PID_NAMESPACE']
    assert result['pid_namespace'] != result['outer_pid_namespace']
    result['device_entries'] = sorted(p.name for p in Path('/dev').iterdir())
    assert not any(x.startswith(('vfio', 'dfl', 'fpga', 'uio', 'dri', 'mem'))
                   for x in result['device_entries'])
    assert not list(Path('/sys').iterdir())
    mounts = Path('/proc/self/mountinfo').read_text()
    (B / 'mountinfo.log').write_text(mounts)
    assert any(line.split()[4] == str(S) and 'ro' in line.split()[5].split(',')
               for line in mounts.splitlines())
    provenance = json.loads((S / 'UPSTREAM.json').read_text())
    for relative, record in provenance['files'].items():
        assert support.digest(S / relative) == record['sha256'], relative
    for path, record in json.loads((R / 'preflight.json').read_text())['tools'].items():
        assert support.digest(path) == record['sha256'], path
    assert os.environ['LD_LIBRARY_PATH'].split(':')[0] == str(R / 'runtime')
    expected_icd = 'libintelocl_emu.so:libalteracl.so' if job['target'] == 'fpga_sim' else 'libintelocl_emu.so'
    assert os.environ['OCL_ICD_FILENAMES'] == expected_icd
    result['versions'] = run('versions', ['/bin/bash', '-c', 'ahls --version && cmake --version'])
    assert 'HLS IP Gen, Version 2026.1.0 ' in result['versions']
    if job['target'] == 'fpga_sim':
        run('simulator-license', ['/opt/altera/25.1/questa_fe/bin/vsim', '-c', '-do', 'quit -f'], timeout=90)
    source = S / 'Tutorials/GettingStarted' / job['sample']
    if job.get('host_only_recompile'):
        source_copy = B / 'host-demo' / job['sample']
        shutil.copytree(source, source_copy)
        result['original_host_sha256'] = support.digest(source / 'src/host.cpp')
        assert support.digest(source_copy / 'src/host.cpp') == result['original_host_sha256']
        source = source_copy
    build = B / 'build'
    configure = ['cmake', '-S', str(source), '-B', str(build),
                 '-DFPGA_DEVICE=AGFB027R25A2E2V', '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
                 '-DUSER_INCLUDE_PATHS=' + str(S / 'include')]
    configure += ['-D' + key + '=' + value for key, value in job.get('selectors', {}).items()]
    run('configure', configure)
    build_argv = ['cmake', '--build', str(build), '--parallel', str(len(result['cpus'])),
                  '--verbose', '--target', job['target']]
    run('build', build_argv, timeout=job['build_timeout_seconds'])
    result['cmake_target_completed'] = True
    commands = json.loads((build / 'compile_commands.json').read_text())
    selected = [item for item in commands if 'CMakeFiles/' + job['target'] + '.dir/' in item['command']]
    assert selected
    for command in selected:
        tokens = shlex.split(command['command'])
        expected = '-DFPGA_SIMULATOR' if job['target'] == 'fpga_sim' else '-DFPGA_HARDWARE'
        assert expected in tokens
    result['compile_commands'] = selected
    project = build / (job['stem'] + '.' + job['target'] + '.prj')
    result['backend_target_logs'] = [str(p.relative_to(B)) for p in (project / 'logs').glob('*.log')
                                     if '-target=AGFB027R25A2E2V' in p.read_text(errors='replace')]
    assert result['backend_target_logs'], 'No exact-part backend log'
    if job['target'] == 'fpga_sim':
        executable = build / (job['stem'] + '.fpga_sim')
        result['executable_before'] = support.digest(executable)
        output = run('run', [str(executable)], cwd=build, timeout=600)
        assert os.environ['CL_CONTEXT_MPSIM_DEVICE_INTELFPGA'] == '1'
        assert 'SimulatorDevice' in output and 'FPGA Emulation Device' not in output
        result['numerical_verification'] = support.validate_text(job, output, isolated_simulator=True)
        assert support.digest(executable) == result['executable_before']
        result['waveforms'] = record_files(build, ['*.wlf'])
        assert result['waveforms']
        result['rtl_simulation_passed'] = True
        if job.get('host_only_recompile'):
            before = record_files(build, ['*.aocx', '*.aocr', '*.fpga.bin', '*.qdb'])
            result['device_artifacts_before_recompile'] = before
            host = source / 'src/host.cpp'
            text = host.read_text()
            old = 'PASSED: results are correct\\n'
            new = 'PASSED: results are correct (host-only recompile)\\n'
            assert text.count(old) == 1
            host.write_text(text.replace(old, new))
            result['modified_host_sha256'] = support.digest(host)
            result['host_only_change'] = {'old': old, 'new': new, 'preserved_import': str(S)}
            save()
            reuse_output = run('host-only-recompile', build_argv, timeout=job['build_timeout_seconds'])
            result['reuse_diagnostic_lines'] = [line for line in reuse_output.splitlines()
                                               if 'reus' in line.lower()]
            result['executable_after'] = support.digest(executable)
            after_output = run('host-only-run', [str(executable)], cwd=build, timeout=600)
            assert 'PASSED: results are correct (host-only recompile)' in after_output
            result['host_only_numerical_verification'] = support.validate_text(job, after_output, isolated_simulator=True)
            result['device_artifacts_after_recompile'] = record_files(build, ['*.aocx', '*.aocr', '*.fpga.bin', '*.qdb'])
            result['reuse_acceptance'] = 'pending independent inspection of compiler diagnostics and artifact comparison'
    else:
        result['full_ip_acceptance'] = 'native CMake target completed; inspect retained Quartus reports before acceptance'
        result['real_card_execution'] = False
    result['report_files'] = record_files(build, ['*.summary', '*.rpt', '*.log'])
    for relative, record in provenance['files'].items():
        assert support.digest(S / relative) == record['sha256'], relative
    result['source_unchanged'] = True
    result['success'] = True
    result['effective_rc'] = 0
except BaseException as error:
    result['error'] = repr(error)
    native_rc = int(getattr(error, 'rc')) if isinstance(error, support.NativeCommandError) else 1
    result['effective_rc'] = native_rc if native_rc >= 0 else 128 - native_rc
finally:
    result['ended'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    save()
    with (B / 'result.json').open('x') as output:
        output.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'success': result['success'], 'error': result.get('error'), 'job': job}), flush=True)
raise SystemExit(result.get('effective_rc', 1))
