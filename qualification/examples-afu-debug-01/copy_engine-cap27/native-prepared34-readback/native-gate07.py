"""Fresh tutorial compile guard; normal-account evidence guard, not a sandbox."""
import hashlib
import json
import os
from pathlib import Path
import sys


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()


def proc(pid):
    p = Path('/proc') / str(pid)
    fields = (p / 'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(fields[1]), 'start_ticks': fields[19],
            'exe': os.readlink(p / 'exe'), 'cwd': os.readlink(p / 'cwd'),
            'argv': (p / 'cmdline').read_bytes().decode().rstrip('\0').split('\0')}


def main():
    assert __debug__ and sys.argv[1:] == ['quartus']
    run = Path(__file__).resolve().parent
    authority = json.loads((run / 'compile-authority.json').read_text())
    assert authority['scope'] == 'tutorial PR compile only; no hardware'
    assert authority['approved'] is True
    assert sha(__file__) == authority['gate_sha256']
    assert os.environ['QUARTUS_ROOTDIR_OVERRIDE'] == '/opt/altera/26.1.1/quartus'
    assert 'OPAE_PLATFORM_GEN' not in os.environ
    assert os.environ['OPAE_PLATFORM_ROOT'] == authority['release']
    parent = proc(os.getppid())
    assert parent['cwd'] == authority['project']
    assert parent['exe'] in authority['tools']
    assert sha(parent['exe']) == authority['tools'][parent['exe']]
    owner = authority['owner']
    actual_owner = proc(owner['pid'])
    assert all(actual_owner[k] == owner[k] for k in ('pid', 'start_ticks', 'exe', 'cwd', 'argv'))
    current = parent
    for _ in range(64):
        if current['pid'] == owner['pid']:
            break
        assert current['ppid'] > 1, 'native process is not owned by current compile supervisor'
        current = proc(current['ppid'])
    else:
        raise AssertionError('native ancestor depth exceeded')
    for path, digest in authority['inputs'].items():
        assert sha(path) == digest, ('bound input changed', path)
    event = {'accepted': True, 'native': parent}
    with (run / 'gate-events.jsonl').open('a') as stream:
        stream.write(json.dumps(event) + '\n')
    print('EXAMPLES_AFU_GATE_ACCEPTED', parent['exe'], flush=True)


if __name__ == '__main__':
    try:
        main()
    except BaseException as exc:
        print('EXAMPLES_AFU_GATE_REJECTED', repr(exc), file=sys.stderr, flush=True)
        raise
