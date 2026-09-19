"""Work08-only native compile authorization. Not functional readiness or sandboxing.

Trusted installed native flow children use a finite source-derived context table,
AND must descend from the exclusive native invocation. No arbitrary standalone
Quartus command is authorized. Existing Work04 setup records remain untouched.
"""
import json
import os
from pathlib import Path
import sys
import ia840f_experimental_gate as common

BASE = common.BASE
SOURCE = common.SOURCE
WORK = BASE / 'work_ia840f_fim_09'
PROJECT = WORK / 'syn/board/ia840f/syn_top'
EVIDENCE = BASE / 'qualification/fim-build-09'
RECORD = EVIDENCE / 'compile-authorization.json'
CLAIM = EVIDENCE / 'native-compile.claim.json'
TOP = './ofs-common/scripts/common/syn/build_top.sh'
TOP_ARGS = [TOP, '--stage=compile', '-k', '-p', 'ia840f', str(WORK)]
CHILD = SOURCE / 'ofs-common/scripts/common/syn/build_fim_compile.sh'
FLOW = ['quartus_sh', '--flow', 'compile', 'ofs_top', '-c', 'ofs_top']
require = common.require
sha = common.sha


def parent(pid):
    return int(next(x.split()[1] for x in (Path('/proc') / str(pid) / 'status').read_text().splitlines() if x.startswith('PPid:')))


def start_time(pid):
    # comm may contain spaces or parentheses; starttime is field 22.
    return (Path('/proc') / str(pid) / 'stat').read_text().rsplit(')', 1)[1].split()[19]


def work_inventory():
    """Initial copied tree, including generated cache; symlinks bound separately."""
    result = {}
    for p in sorted(WORK.rglob('*')):
        if '__pycache__' in p.parts or p.suffix == '.pyc':
            continue
        rel = p.relative_to(WORK).as_posix()
        if p.is_symlink():
            require(p.resolve(strict=True).is_relative_to(WORK), 'work symlink escape: ' + rel)
            result[rel] = {'symlink': os.readlink(p)}
        elif p.is_file():
            result[rel] = {'sha256': sha(p)}
    require(bool(result), 'empty work inventory')
    return result


def allowed_commands():
    """Finite argv from installed 26.1.1 flow tasks and OFS hooks.

    Record pins exact contexts; native ancestry is additionally mandatory.
    Project basename/absolute and WORK-relative/absolute callback paths are
    explicit alternatives, not arbitrary flags, scripts or revision aliases.
    """
    commands = [FLOW]
    settings = ['--read_settings_files=on', '--write_settings_files=off']
    for project in ('ofs_top', str(PROJECT / 'ofs_top')):
        tail = [project, '-c', 'ofs_top']
        commands += [['quartus_ipgenerate'] + prefix + tail + ['--run_default_mode_op'] for prefix in ([], ['--classic'])]
        for tool in ('quartus_syn', 'quartus_fit', 'quartus_asm', 'quartus_pow', 'quartus_eda'):
            commands.append([tool] + settings + tail)
        commands += [['quartus_syn', '--classic'] + settings + tail,
                     ['quartus_syn'] + settings + ['--analysis_and_elaboration'] + tail,
                     ['quartus_syn'] + settings + ['--synthesis'] + tail,
                     ['quartus_syn'] + settings + tail + ['--design_analysis'],
                     ['quartus_syn'] + settings + tail + ['--quick_elab'],
                     ['quartus_tlg'] + settings + ['--skip_quick_elaboration'] + tail,
                     ['quartus_tlg', '--tool=hssi_support_logic'] + settings + ['--skip_quick_elaboration'] + tail]
        for flag in ('--plan', '--place', '--route', '--retime', '--finalize'):
            commands.append(['quartus_fit'] + settings + tail + [flag])
        commands.append(['quartus_fit'] + settings + tail + ['--fastforward', '--continue_flow'])
        for flag in ('--post_syn', '--mode=implement', '--mode=finalize'):
            commands.append(['quartus_sta'] + tail + [flag])
    # Installed libsys_flow.so formats the native task IPC prefix exactly here.
    # Work05 observed flow 17 for ipgenerate and syn. Pin that literal, never
    # strip flags or accept arbitrary flow IDs. All tails remain finite.
    commands += [[args[0], '--ipc_flow=17', '--ipc_mode'] + args[1:]
                 for args in commands[1:]]
    for root in ('../../../..', str(WORK)):
        scripts = root + '/ofs-common/scripts/common/syn/'
        for module in ('quartus_ipgenerate', 'quartus_syn', 'quartus_fit', 'quartus_sta', 'quartus_asm', 'quartus_tlg', 'quartus_pow', 'quartus_eda'):
            # Observed post-IP hook; same installed post-module constructor
            # handles only these existing source-bound module/path alternatives.
            for prefix in ([], ['--ipc_mode']):
                commands.append(['quartus_sh'] + prefix + ['-t', root + '/syn/shared_config/post_module_hook.tcl', module, 'ofs_top', 'ofs_top'])
        commands += [
            ['quartus_sh', '-t', scripts + 'emit_project_macros.tcl', '--project=ofs_top', '--revision=ofs_top', '--output=fim_project_macros.tcl', '--mode=tcl'],
            ['quartus_sh', '-t', scripts + 'generate_pr_usage_for_asp.tcl', '--project=ofs_top', '--revision=ofs_top', '--output=ofs_ip_cfg_db/ofs_fim_util_asp.qprs'],
            ['quartus_sta', '-t', scripts + 'create_sdc_for_pr_compile.tcl', 'ofs_top', 'ofs_top', 'ofs_top.out.sdc'],
            ['quartus_ipgenerate', '-t', scripts + 'emit_project_ip.tcl', '--project=ofs_top', '--revision=ofs_top', '--output=fim_base_ip.tcl']]
    commands += [['quartus_cdb', 'ofs_top', '-c', 'ofs_top', '--update_mif'],
                 ['quartus_cdb', 'ofs_top', '-c', 'ofs_top', '--export_partition', 'root_partition', '--snapshot', 'final', '--file', 'ofs_top.qdb', '--include_sdc_entity_in_partition']]
    return commands


def load_record(inner=False):
    require(not RECORD.is_symlink(), 'compile record symlink')
    record = json.loads(RECORD.read_text())
    expected = dict(schema=1, approved=True, accepted_execution=True,
                    ready_for_build=False, source_review_consumed=True,
                    gate_review_consumed=True, target='ia840f', part=common.PART,
                    toolchain=common.VERSION, source=str(SOURCE), work=str(WORK),
                    pim=str(common.PIM), permissions=['native-full-compile'])
    for key, value in expected.items():
        require(type(record.get(key)) is type(value) and record[key] == value, 'compile record field: ' + key)
    for root in (SOURCE, WORK, common.PIM, EVIDENCE):
        require(root.resolve(strict=True) == root, 'compile root alias')
    require(set(record['source_sha256']) == set(common.TREES), 'compile source coverage')
    for tree in common.TREES:
        common.check_inventory(SOURCE / tree, record['source_sha256'][tree])
    common.check_inventory(common.PIM, record['pim_sha256'])
    require(set(record['tools']) == set(common.TOOLS) and set(record['quartus_tools']) == set(common.TOOLS), 'compile tool coverage')
    for name in common.TOOLS:
        outer, inside = record['tools'][name], record['quartus_tools'][name]
        require(inside['path'] == common.INNER_TOOL_PATHS.get(name, outer['path']), 'compile inner path')
        for tool in (outer, inside):
            require(str(Path(tool['path']).resolve(strict=True)) == tool['path'], 'compile tool alias')
            require(sha(tool['path']) == tool['sha256'], 'compile tool hash: ' + name)
        selected = inside if inner else outer
        found = common.shutil.which(name)
        require(found is not None and str(Path(found).resolve()) == selected['path'], 'compile tool PATH: ' + name)
    require(record['contexts'], 'empty compile contexts')
    runtime_hashes = {}
    for context in record['contexts']:
        require(context['cwd'] == str(PROJECT), 'compile context directory')
        exe = context['executable']
        require(exe.startswith('/opt/altera/26.1.1/quartus/linux64/') and
                Path(exe).name in ('quartus_sh', 'quartus_ipgenerate', 'quartus_syn',
                                  'quartus_fit', 'quartus_sta', 'quartus_asm',
                                  'quartus_cdb', 'quartus_pow', 'quartus_eda', 'quartus_tlg'),
                'compile executable outside finite native tool set')
        if exe not in runtime_hashes:
            runtime_hashes[exe] = sha(exe)
        require(runtime_hashes[exe] == context['sha256'], 'compile executable hash')
        require(context['argv'] in allowed_commands(), 'compile command grammar')
        require(context['argv'] and context['argv'][0] == Path(exe).name, 'compile argv0')
    # Flow/task source semantics and independent reviews are immutable pins too.
    for path, digest in record['dependency_sha256'].items():
        require(sha(path) == digest, 'compile dependency hash: ' + path)
    require(record['native_argv'] == TOP_ARGS and record['native_cwd'] == str(SOURCE), 'compile native binding')
    return record


def environment():
    for key, value in dict(OFS_ROOTDIR=str(SOURCE), OFS_PLATFORM_AFU_BBB=str(common.PIM),
                           KEEP_WORK_ARG='-k', DO_PR_BUILD_TEMPLATE_GEN='1',
                           QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus').items():
        require(os.environ.get(key) == value, 'compile environment: ' + key)
    for key in ('SEED', 'ANALYSIS_AND_ELAB_ONLY', 'USE_OFSS_CONFIG_SCRIPT',
                'OFS_PRE_SETUP_SCRIPT', 'OFS_POST_SETUP_SCRIPT', 'OFS_PRE_COMPILE_SCRIPT',
                'OFS_POST_COMPILE_SCRIPT', 'AFU_WITH_PIM', 'BUILD_VAR_SETUP_COMPLETE'):
        require(not os.environ.get(key), 'forbidden compile option: ' + key)
    require(not any(k.startswith('OFS_BUILD_TAG_') and v for k, v in os.environ.items()), 'compile variant tags')


def claim_ancestor():
    require(not CLAIM.is_symlink(), 'compile claim symlink')
    claim = json.loads(CLAIM.read_text())
    require(claim['record_sha256'] == sha(RECORD), 'compile claim record mismatch')
    pid = os.getppid()
    for _ in range(64):
        if pid == claim['pid']:
            require(start_time(pid) == claim['start_time'], 'compile claim process reused')
            exe, argv, cwd = common.process(pid)
            require(exe == '/usr/bin/bash' and argv in [TOP_ARGS, ['bash'] + TOP_ARGS, ['/bin/bash'] + TOP_ARGS] and cwd == str(SOURCE), 'compile native ancestor changed')
            return
        require(pid > 1, 'not a descendant of claimed native compile')
        pid = parent(pid)
    require(False, 'compile process ancestry limit')


def native(target, work):
    require(target == 'ia840f' and work == str(WORK), 'exact compile target/work required')
    environment()
    require(Path.cwd() == SOURCE and WORK.is_dir() and not WORK.is_symlink(), 'compile cwd/work')
    record = load_record()
    require(work_inventory() == record['work_inventory'], 'compile copied work inventory mismatch')
    require((PROJECT / 'build_env_db.txt').read_text().splitlines().count('Q_REVISION=ofs_top') == 1 and
            (PROJECT / 'build_env_db.txt').read_text().splitlines().count('Q_PR_REVISION=ofs_pr_afu') == 1, 'compile revisions')
    exe, argv, cwd = common.process(os.getppid())
    require(exe == '/usr/bin/bash' and cwd == str(SOURCE), 'native compile executable/cwd')
    if argv in [TOP_ARGS, ['bash'] + TOP_ARGS, ['/bin/bash'] + TOP_ARGS]:
        with CLAIM.open('x') as f:
            json.dump(dict(record_sha256=sha(RECORD), pid=os.getppid(), start_time=start_time(os.getppid())), f)
    else:
        require(argv in [[str(CHILD), 'ia840f', str(WORK)], ['bash', str(CHILD), 'ia840f', str(WORK)], ['/bin/bash', str(CHILD), 'ia840f', str(WORK)]], 'native compile argv')
        claim_ancestor()


def check_context(record, executable, argv, cwd):
    require(cwd == str(PROJECT), 'compile runtime cwd')
    context = dict(executable=executable, sha256=sha(executable), argv=argv, cwd=cwd)
    require(context in record['contexts'], 'unrecorded compile executable/argv/cwd: ' + repr(context))


def quartus_context():
    record = load_record(inner=True)
    claim_ancestor()
    check_context(record, *common.process(os.getppid()))


def run_compile():
    environment()
    record = load_record()
    claim_ancestor()
    require(Path.cwd() == PROJECT, 'compile launch directory')
    exe = common.RUNTIME_EXES['quartus_sh']
    check_context(record, exe, FLOW, str(PROJECT))
    common.monitor_setup_output([record['tools']['quartus_sh']['path']] + FLOW[1:])
