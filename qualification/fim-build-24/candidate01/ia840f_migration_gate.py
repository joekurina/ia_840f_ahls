"""Copied-project gate adapted from the exercised CAPS03 native-CMake gate.

Exact process context, live supervisor ancestry and immutable input identities
are required. This is an accidental-execution guard, not an OS sandbox.
"""
import hashlib
import json
import os
from pathlib import Path
import sys

E = Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-24')
W = Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24')
PROJECT = W / 'syn/board/ia840f/syn_top'
STAGES = ('ip_inventory', 'ip_regeneration', 'headers', 'compile')
TOOL_ROOT = Path('/opt/altera/26.1.1/quartus')


def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def proc(pid):
    root = Path('/proc') / str(pid)
    fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(fields[1]), 'start_ticks': fields[19],
            'exe': os.readlink(root/'exe'), 'cwd': os.readlink(root/'cwd'),
            'argv': (root/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def check():
    assert __debug__ and sys.argv[1:] == ['quartus']
    selected = Path(os.environ['IA840F_MIGRATION_AUTHORITY'])
    allowed = {E/'operations'/stage/'authority.json': stage for stage in STAGES}
    assert selected in allowed and not selected.is_symlink(), 'unapproved authority path'
    record = json.loads(selected.read_text())
    assert record['approved'] is True and record['ready_for_build'] is False
    assert record['scope'] == 'ia840f-ofs2026-native-' + allowed[selected]
    assert record['project'] == str(PROJECT)
    assert record['part'] == 'AGFB027R25A2E2V'
    assert record['toolchain'] == 'Quartus Prime Pro 26.1.1 Build 130'
    assert 'OPAE_PLATFORM_GEN' not in os.environ
    assert os.environ.get('QUARTUS_ROOTDIR_OVERRIDE') == str(TOOL_ROOT)
    assert os.environ.get('OFS_ROOTDIR') == str(W)
    parent = proc(os.getppid())
    assert parent['cwd'] == str(PROJECT), 'native project directory'
    context = {'exe': parent['exe'], 'cwd': parent['cwd'], 'argv': parent['argv'][1:]}
    assert context in record['contexts'], ('unrecorded native context', context)
    executable = Path(parent['exe'])
    assert parent['argv'][0] in (executable.name, str(executable)), 'native argv0'
    assert executable.parent == TOOL_ROOT/'linux64'
    assert executable.name in {'quartus_sh', 'quartus_ipgenerate', 'quartus_syn',
                               'quartus_fit', 'quartus_sta', 'quartus_asm',
                               'quartus_cdb', 'quartus_tlg', 'quartus_pow', 'quartus_eda'}
    assert sha(executable) == record['runtime_hashes'][str(executable)]
    runner = record['runner']
    ancestor = parent
    found = False
    for _ in range(40):
        if ancestor['pid'] == runner['pid']:
            assert all(ancestor[k] == runner[k] for k in ('pid', 'start_ticks', 'exe', 'cwd', 'argv'))
            found = True
            break
        if ancestor['ppid'] <= 1:
            break
        ancestor = proc(ancestor['ppid'])
    assert found, 'native command not owned by issued supervisor'
    assert record['critical_inputs'], 'empty source binding'
    for name, target in record['critical_links'].items():
        link = Path(name)
        assert link.is_symlink() and os.readlink(link) == target, ('input link changed', name)
        assert link.resolve(strict=True).is_relative_to(W), ('input link escape', name)
    for name, digest in record['critical_inputs'].items():
        assert sha(Path(name)) == digest, ('critical input changed', name)
    qsf = (PROJECT/'ofs_top.qsf').read_text()
    for line in ('set_global_assignment -name FAMILY "Agilex 7"',
                 'set_global_assignment -name DEVICE AGFB027R25A2E2V',
                 'set_global_assignment -name TOP_LEVEL_ENTITY top',
                 'set_global_assignment -name ENABLE_INTERMEDIATE_SNAPSHOTS ON'):
        assert line in qsf, ('project identity/settings', line)
    return selected.parent, {'accepted': True, 'parent': parent}


def main():
    try:
        root, event = check()
        path = root/'gate-events.jsonl'
    except Exception as exc:
        event: dict[str, object] = {'error': repr(exc)}
        try:
            event['parent'] = proc(os.getppid())
        except Exception:
            pass
        # The owned supervisor persists stderr and rejects this marker. A stale
        # or unauthorized callback must not append to a consumed operation.
        print('IA840F_GATE_REJECTED: '+repr(event), file=sys.stderr)
        return 1
    fd = os.open(path, os.O_CREAT|os.O_APPEND|os.O_WRONLY, 0o600)
    os.write(fd, (json.dumps(event)+'\n').encode())
    os.close(fd)
    return 0


if __name__ == '__main__':
    sys.exit(main())
