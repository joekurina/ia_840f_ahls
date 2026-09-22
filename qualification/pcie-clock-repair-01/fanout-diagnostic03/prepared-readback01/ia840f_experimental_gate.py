"""Fail-closed, Linux-only IA840F experimental authorization (not readiness).

The fixed record is issued after independent source/tool review. No record is
shipped. Environment stage labels never authorize a Quartus operation. This is
an accidental-execution guard, not a sandbox against a user who can edit sources.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

# Exact installed inner PATH identities observed by the no-project probe.
INNER_TOOL_PATHS = {
    'quartus_sh': '/opt/altera/26.1.1/quartus/linux64/quartus_sh',
    'quartus_ipgenerate': '/opt/altera/26.1.1/quartus/linux64/quartus_ipgenerate',
    'ip-deploy': '/opt/altera/26.1.1/qsys/bin/ip-deploy',
    'qsys-script': '/opt/altera/26.1.1/qsys/bin/qsys-script',
}
REJECTION_MARKERS = (b'IA840F_GATE_REJECTED', b'IA840F NOT READY',
                     b'IA840F EXPERIMENTAL GATE:', b'Critical Warning (125091)')

BASE = Path('/home/uwb_student00/ahls/new_BSP')
SOURCE = BASE / 'ofs-agx7-pcie-attach'
WORK = BASE / 'work_ia840f_ipgen_04'
PIM = BASE / 'ofs-platform-afu-bbb'
PROJECT = WORK / 'syn/board/ia840f/syn_top'
RECORD_REL = 'syn/board/ia840f/setup/experimental-authorization.json'
TREES = ('syn', 'src', 'ipss', 'ofs-common', 'tools')
TOOLS = ('quartus_sh', 'quartus_ipgenerate', 'ip-deploy', 'qsys-script',
         'PACSign', 'packager', 'afu_json_mgr', 'afu_synth_setup')
RUNTIME_EXES = {name: '/opt/altera/26.1.1/quartus/linux64/' + name
                for name in ('quartus_sh', 'quartus_ipgenerate')}
VERSION = 'Quartus Prime Pro 26.1.1 Build 130'
PART = 'AGFB027R25A2E2V'


def require(ok, message):
    if not ok:
        raise ValueError('IA840F EXPERIMENTAL GATE: ' + message)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def inventory(root):
    """Full regular-file inventory; reject external/directory symlinks.

    Bytecode and the authorization record itself are not source inputs.
    """
    root = Path(root).resolve(strict=True)
    result = {}
    for path in sorted(root.rglob('*')):
        rel = path.relative_to(root).as_posix()
        if '__pycache__' in path.parts or path.suffix == '.pyc' or rel == 'board/ia840f/setup/experimental-authorization.json':
            continue
        if path.is_symlink():
            resolved = path.resolve(strict=True)
            require(resolved.is_relative_to(root) and resolved.is_file(), 'source symlink escape: ' + rel)
        if path.is_file():
            result[rel] = sha(path)
    require(bool(result), 'empty source inventory')
    return result


def check_inventory(root, expected):
    require(isinstance(expected, dict) and inventory(root) == expected, 'source inventory mismatch: ' + str(root))


def load_record(*, quartus_inner=False):
    require(Path(__file__).resolve().is_relative_to(SOURCE) or
            Path(__file__).resolve().is_relative_to(WORK), 'unapproved checkout location')
    path = SOURCE / RECORD_REL
    require(not path.is_symlink(), 'authorization must be a regular file')
    record = json.loads(path.read_text())
    expected = {'schema': 1, 'approved': True, 'ready_for_build': False,
                'target': 'ia840f', 'part': PART, 'toolchain': VERSION,
                'source': str(SOURCE), 'work': str(WORK), 'pim': str(PIM)}
    for key, value in expected.items():
        require(type(record.get(key)) is type(value) and record[key] == value, 'record field: ' + key)
    require(record.get('permissions') in (['setup'], ['setup', 'generate'],
                                         ['setup', 'generate', 'headers']), 'permissions')
    require(set(record['source_sha256']) == set(TREES), 'source tree coverage')
    for tree in TREES:
        check_inventory(SOURCE / tree, record['source_sha256'][tree])
    check_inventory(PIM, record['pim_sha256'])
    require(SOURCE.resolve() == SOURCE and WORK.resolve() == WORK and PIM.resolve() == PIM,
            'root path alias')
    # Both identity sets are mandatory, hashed on every check, and never used
    # interchangeably. Only the actual Quartus callback selects inner PATH.
    require(set(record['tools']) == set(TOOLS) and
            set(record['quartus_tools']) == set(TOOLS), 'tool identity coverage')
    for name in TOOLS:
        outer = record['tools'][name]
        inner = record['quartus_tools'][name]
        require(inner['path'] == INNER_TOOL_PATHS.get(name, outer['path']),
                'inner tool path: ' + name)
        for tool in (outer, inner):
            require(str(Path(tool['path']).resolve(strict=True)) == tool['path'],
                    'tool path alias: ' + name)
            require(sha(tool['path']) == tool['sha256'], 'tool hash: ' + name)
        found = shutil.which(name)
        selected = inner if quartus_inner else outer
        require(found is not None and str(Path(found).resolve()) == selected['path'],
                'tool path: ' + name)
    return record


def command_kind(executable, args):
    """Closed grammar. Exact observed argv is checked against the record too."""
    if executable == 'quartus_sh' and args in (
            ['--prepare', '-r', 'ofs_top', 'ofs_top'],
            ['--prepare', '-r', 'ofs_pr_afu', 'ofs_top']):
        return 'prepare'
    if executable == 'quartus_sh':
        if args == ['-t', str(SOURCE / 'ofs-common/scripts/common/syn/emit_project_macros.tcl'),
                    '--project=ofs_top', '--revision=ofs_top', '--mode=txt',
                    '--output=' + str(WORK / 'src/top/ofs_agilex.macros')]:
            return 'pim_macros'
        if args == ['-t', str(WORK / 'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),
                    '--project=ofs_top', '--revision=ofs_top']:
            return 'headers'
    if executable == 'quartus_ipgenerate':
        if args == ['-t', str(WORK / 'ofs-common/scripts/common/syn/emit_project_ip.tcl'),
                    '--project=ofs_top', '--revision=ofs_top',
                    '--output=project_ip_for_generation.tcl']:
            return 'project_ip'
        if args == ['-t', str(SOURCE / 'ofs-common/scripts/common/syn/emit_project_ip.tcl'),
                    '--project=ofs_top', '--revision=ofs_top', '--mode=ip_lib']:
            return 'ip_lib'
        # Exact help-supported bounded project generation; no defaults, aliases,
        # arbitrary scripts, extra flags, duplicates or argument reordering.
        if args == ['ofs_top', '-c', 'ofs_top', '--generate_project_ip_files',
                    '--synthesis=verilog', '--simulation=verilog',
                    '--simulator=modelsim', '--parallel=off']:
            return 'generate'
    raise ValueError('IA840F EXPERIMENTAL GATE: unreviewed Quartus command')


def process(pid):
    proc = Path('/proc') / str(pid)
    return (str((proc / 'exe').resolve(strict=True)),
            (proc / 'cmdline').read_bytes().decode().rstrip('\0').split('\0'),
            str((proc / 'cwd').resolve(strict=True)))


def claim_path():
    return WORK.with_name(WORK.name + '.authorization-claim')


def check_claim():
    path = claim_path()
    require(not path.is_symlink() and path.read_text() == sha(SOURCE / RECORD_REL),
            'missing/mismatched single-run claim')


def quartus_context():
    record = load_record(quartus_inner=True)
    check_claim()
    executable, argv, cwd = process(os.getppid())
    name = Path(executable).name
    require(executable == RUNTIME_EXES.get(name), 'Quartus runtime executable')
    require(bool(argv) and argv[0] == name, 'Quartus argv[0]')
    kind = command_kind(name, argv[1:])
    require(cwd == str(PROJECT), 'Quartus output directory')
    require(kind not in ('generate', 'project_ip') or 'generate' in record['permissions'], 'generation not authorized')
    if kind in ('project_ip', 'headers'):
        relative = Path(argv[2]).relative_to(WORK)
        require(sha(WORK / relative) == sha(SOURCE / relative), 'work script source hash mismatch')
    require(kind != 'headers' or 'headers' in record['permissions'], 'headers not authorized')
    require(any(c == {'executable': executable, 'sha256': sha(executable),
                      'argv': argv, 'cwd': cwd, 'kind': kind}
                for c in record['quartus_contexts']), 'unrecorded runtime executable/argv')


def setup_environment():
    require(os.environ.get('COPY_WORK') == '1', 'COPY_WORK=1 required')
    require(os.environ.get('OFS_ROOTDIR') == str(SOURCE), 'source root')
    require(os.environ.get('OFS_PLATFORM_AFU_BBB') == str(PIM), 'pinned PIM required')
    require(os.environ.get('DO_PR_BUILD_TEMPLATE_GEN') == '1', '-p required')
    require(os.environ.get('USE_OFSS_CONFIG_SCRIPT') ==
            'nodefault,' + str(SOURCE / 'syn/board/ia840f/config/ia840f.ofss'), 'exact OFSS selection required')
    for key in ('KEEP_WORK_ARG', 'ANALYSIS_AND_ELAB_ONLY', 'OFS_PRE_SETUP_SCRIPT',
                'OFS_POST_SETUP_SCRIPT', 'OFS_PRE_COMPILE_SCRIPT', 'OFS_POST_COMPILE_SCRIPT',
                'AFU_WITH_PIM'):
        require(not os.environ.get(key), 'forbidden setup option: ' + key)
    require(not any(k.startswith('OFS_BUILD_TAG_') and v for k, v in os.environ.items()), 'variant tags forbidden')


def native(stage, target, work):
    require(stage in ('setup', 'setup-entry'), 'stage prohibited: ' + stage)
    require(target == 'ia840f' and work == str(WORK), 'exact target/work required')
    setup_environment()
    require(not WORK.exists() and not WORK.is_symlink(), 'worktree must be absent')
    require(not os.environ.get('BUILD_VAR_SETUP_COMPLETE'), 'preloaded build variables forbidden')
    load_record()
    require(not claim_path().exists() and not claim_path().is_symlink(), 'authorization already consumed')
    if stage == 'setup-entry':
        # Exclusive creation prevents a second native setup using this record.
        # Preserve this receipt after any failure; never auto-delete/retry.
        with claim_path().open('x') as claim:
            claim.write(sha(SOURCE / RECORD_REL))


def pcie_context(pcie):
    ofss_context(pcie.target_rootdir, pcie.part)


def ofss_context(target, part):
    record = load_record()
    check_claim()
    require(part == PART and target is not None and Path(target).resolve() == WORK, 'PCIe part/output root')
    require(Path.cwd().resolve() == PROJECT, 'OFSS working directory')
    setup_environment()
    # Current process must really be the native OFSS script, not an imported
    # helper called from an unrelated Python command with STAGE=setup.
    require(Path(sys.argv[0]).resolve() == SOURCE / 'ofs-common/tools/ofss_config/gen_ofs_settings.py', 'OFSS entry')
    require(sys.argv[1:] == ['--ofss', str(SOURCE / 'syn/board/ia840f/config/ia840f.ofss'),
                            '--target', '../../../..'], 'OFSS argv')
    require('setup' in record['permissions'], 'setup permission')


def monitor_setup_output(command):
    """Stream merged output in bounded chunks; rc=0 never overrides rejection.

    Quartus can downgrade SOURCE_TCL_SCRIPT_FILE errors to warning 125091.
    This does not interrupt Quartus itself, but prevents the next native stage.
    Kept separate for inert subprocess tests; the CLI always validates first.
    """
    rejected = False
    tail = b''
    overlap = max(map(len, REJECTION_MARKERS)) - 1
    with subprocess.Popen(command, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT) as child:
        assert child.stdout is not None
        while True:
            chunk = os.read(child.stdout.fileno(), 65536)
            if not chunk:
                break
            sys.stdout.buffer.write(chunk)
            sys.stdout.buffer.flush()
            window = tail + chunk
            rejected |= any(marker in window for marker in REJECTION_MARKERS)
            tail = window[-overlap:]
        status = child.wait()
    require(status == 0, 'setup Quartus subprocess exit: ' + str(status))
    require(not rejected, 'setup Quartus subprocess reported gate/Tcl rejection despite exit 0')


def run_setup_quartus(name, args):
    # No arbitrary executable, Tcl script, generation, synthesis or extra flags.
    kind = command_kind(name, args)
    require(kind in ('ip_lib', 'pim_macros', 'prepare'), 'not a setup Quartus command')
    record = load_record()
    check_claim()
    setup_environment()
    require(str(Path.cwd().resolve()) == str(PROJECT), 'Quartus output directory')
    monitor_setup_output([record['tools'][name]['path']] + args)


def run_post_setup_quartus(name, args):
    kind = command_kind(name, args)
    require(kind in ('project_ip', 'generate', 'headers'),
            'not a post-setup Quartus command')
    record = load_record()
    check_claim()
    require(str(Path.cwd().resolve()) == str(PROJECT),
            'Quartus output directory')
    permission = 'headers' if kind == 'headers' else 'generate'
    require(permission in record['permissions'],
            permission + ' not authorized')
    if kind in ('project_ip', 'headers'):
        relative = Path(args[1]).relative_to(WORK)
        require(sha(WORK / relative) == sha(SOURCE / relative),
                'work script source hash mismatch')
    executable = RUNTIME_EXES[name]
    require(any(c == {'executable': executable,
                      'sha256': sha(executable),
                      'argv': [name] + args,
                      'cwd': str(PROJECT), 'kind': kind}
                for c in record['quartus_contexts']),
            'unrecorded runtime executable/argv')
    monitor_setup_output([record['tools'][name]['path']] + args)


def main():
    try:
        if sys.argv[1:] == ['quartus'] and Path.cwd() == Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03/scratch/syn/board/ia840f/syn_top'):
            import ia840f_clock_fanout03_gate
            ia840f_clock_fanout03_gate.validate(runtime=True)
            return 0
        if sys.argv[1:] == ['quartus'] and Path.cwd() == BASE / 'work_ia840f_fim_14/syn/board/ia840f/syn_top':
            import ia840f_compile_gate
            ia840f_compile_gate.quartus_context()
        elif sys.argv[1:] == ['run-native-compile']:
            import ia840f_compile_gate
            ia840f_compile_gate.run_compile()
        elif len(sys.argv) == 5 and sys.argv[1:3] == ['native', 'compile']:
            import ia840f_compile_gate
            ia840f_compile_gate.native(sys.argv[3], sys.argv[4])
        elif sys.argv[1:] == ['quartus']:
            quartus_context()
        elif len(sys.argv) >= 4 and sys.argv[1] == 'run-setup-quartus':
            run_setup_quartus(sys.argv[2], sys.argv[3:])
        elif len(sys.argv) >= 4 and sys.argv[1] == 'run-post-setup-quartus':
            run_post_setup_quartus(sys.argv[2], sys.argv[3:])
        elif len(sys.argv) == 5 and sys.argv[1] == 'native':
            native(sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            raise ValueError('unsupported gate invocation')
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
