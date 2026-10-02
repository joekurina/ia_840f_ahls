"""One-attempt PR-export callback; no build/hardware authority implied."""
import hashlib
import json
import os
from pathlib import Path
import sys

R = Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/export01')
D = Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/base01')
T = Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01')
J = D/'syn/board/ia840f/syn_top'
Q = Path('/opt/altera/26.1.1/quartus')


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def proc(pid):
    root = Path('/proc')/str(pid)
    fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(fields[1]), 'start_ticks': fields[19],
            'exe': os.readlink(root/'exe'), 'cwd': os.readlink(root/'cwd'),
            'argv': (root/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def check():
    assert __debug__ and sys.argv[1:] == ['quartus']
    authority = R/'authority.json'
    assert authority.is_file() and not authority.is_symlink()
    record = json.loads(authority.read_text())
    assert record['approved'] is True and record['ready_for_build'] is False
    assert record['scope'] == 'release-only' and record['project'] == str(J)
    assert record['part'] == 'AGFB027R25A2E2V'
    assert record['toolchain'] == 'Quartus Prime Pro 26.1.1 Build 130'
    assert os.environ.get('OPAE_PLATFORM_GEN') == '1'
    assert os.environ.get('QUARTUS_ROOTDIR_OVERRIDE') == str(Q)
    assert os.environ.get('OFS_ROOTDIR') == str(D)
    allowed_self = {D/'syn/board/ia840f/setup/ia840f_release_gate01.py',
                    T/'hw/lib/build/syn/board/ia840f/setup/ia840f_release_gate01.py'}
    assert Path(__file__).resolve() in allowed_self
    assert sha(Path(__file__)) == record['guard_sha256']
    parent = proc(os.getppid())
    context = {'exe': parent['exe'], 'cwd': parent['cwd'], 'argv': parent['argv'][1:]}
    assert context in record['contexts'], ('unrecorded native context', context)
    executable = Path(parent['exe'])
    assert executable.parent == Q/'linux64' and executable.name in {'quartus_sh', 'quartus_syn'}
    assert parent['argv'][0] in (str(executable), executable.name)
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
    for path, expected in record['critical_inputs'].items():
        assert sha(path) == expected, ('critical input changed', path)
    qsf = (J/'ofs_pr_afu.qsf').read_text()
    for line in ('set_global_assignment -name FAMILY "Agilex 7"',
                 'set_global_assignment -name DEVICE AGFB027R25A2E2V',
                 'set_global_assignment -name TOP_LEVEL_ENTITY top',
                 'set_global_assignment -name REVISION_TYPE PR_IMPL'):
        assert line in qsf, ('PR project identity', line)
    return {'accepted': True, 'parent': parent}


def main():
    event: dict[str, object]
    try:
        event = check()
    except Exception as exc:
        event = {'error': repr(exc)}
        try:
            event['parent'] = proc(os.getppid())
        except Exception:
            pass
        # An unissued/stale callback never appends into consumed evidence.
        print('IA840F_GATE_REJECTED: '+repr(event), file=sys.stderr)
        return 1
    fd = os.open(R/'gate-events.jsonl', os.O_CREAT|os.O_APPEND|os.O_WRONLY, 0o600)
    os.write(fd, (json.dumps(event)+'\n').encode())
    os.close(fd)
    return 0


if __name__ == '__main__':
    sys.exit(main())
