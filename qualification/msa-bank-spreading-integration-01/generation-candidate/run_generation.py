"""Reviewed-memory-only successor. No full FIM setup/compile; no old claims.
Run only inside the named owned tmux session after independent package review.
This is a normal-account source-bound guard, not an OS sandbox.
"""
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time

from compare_memory import sha, compare_saved, compare_generated

BASE = Path('/home/uwb_student00/ahls/new_BSP')
SOURCE = BASE / 'ofs-agx7-pcie-attach'
PACKAGE = BASE / 'qualification/msa-bank-spreading-integration-01/generation-candidate'
WORK = BASE / 'work_ia840f_msa_generation_01'
RUN = PACKAGE / 'run'
REVIEW = PACKAGE / 'consumed-review.json'


def require(ok, message):
    if not ok: raise ValueError('MSA_GENERATION_REJECTED: ' + message)


def put(path, obj):
    with path.open('x') as f: json.dump(obj, f, indent=2)


def process(pid):
    root = Path('/proc') / str(pid)
    stat = (root / 'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(stat[1]), 'ticks': stat[19],
            'exe': str((root / 'exe').resolve()),
            'argv': (root / 'cmdline').read_bytes().rstrip(b'\0').decode().split('\0'),
            'cwd': str((root / 'cwd').resolve())}


def check_package():
    manifest_path = PACKAGE / 'package-manifest.json'
    review = json.loads(REVIEW.read_text())
    require(review.get('approved') is True and review.get('spec_accepted') is True and review.get('quality_accepted') is True, 'independent reviews missing')
    require(review.get('package_manifest_sha256') == sha(manifest_path), 'review binding')
    require(review.get('execution_ready') is False, 'readiness must remain false')
    for rel, digest in json.loads(manifest_path.read_text()).items():
        require(sha(PACKAGE / rel) == digest, 'package changed: ' + rel)


def check_source_and_dependencies():
    binding = json.loads((PACKAGE / 'execution-binding.json').read_text())
    gate_path = SOURCE / 'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'
    require(sha(gate_path) == binding['source']['ofs-common']['tools/ofss_config/ia840f_experimental_gate.py'], 'gate source drift before import')
    sys.path.insert(0, str(SOURCE / 'ofs-common/tools/ofss_config'))
    import ia840f_experimental_gate as g
    for tree, expected in binding['source'].items():
        require(g.inventory(SOURCE / tree) == expected, 'source drift: ' + tree)
    require(g.inventory(g.PIM) == binding['pim'], 'PIM drift')
    for path, digest in binding['dependencies'].items():
        require(sha(path) == digest, 'dependency drift: ' + path)
    return binding


def preflight():
    # Review absence rejects before logs, claims, work roots or tool subprocesses.
    check_package()
    require(os.environ.get('TMUX') and socket.gethostname() == 'Agilex7Workstation' and os.getuid() == 1000, 'host/tmux identity')
    require(Path(__file__).resolve().parent == PACKAGE, 'package location')
    require(sys.flags.optimize == 0 and not os.environ.get('PYTHONOPTIMIZE'), 'unoptimized Python required')
    require(bool(os.environ.get('TMUX_PANE')), 'tmux pane identity')
    session = subprocess.check_output(['tmux', 'display-message', '-t', os.environ['TMUX_PANE'], '-p', '#S'], text=True).strip()
    require(session == 'ia840f_mailbox_monitored_01', 'owned session')
    binding = check_source_and_dependencies()
    require(not WORK.exists() and not RUN.exists(), 'exclusive successor already exists')
    return binding


def active(stage):
    check_package()
    require(stage == 'save-reload' and Path.cwd() == WORK, 'callback context')
    claim = json.loads((RUN / 'claim.json').read_text())
    require(process(claim['runner']['pid']) == claim['runner'], 'runner no longer matches claim')
    pid = os.getppid()
    ancestors = []
    while pid > 1:
        p = process(pid); ancestors.append(pid); pid = p['ppid']
    require(claim['runner']['pid'] in ancestors, 'callback not descendant of runner')
    require(json.loads((RUN / 'active-stage.json').read_text())['stage'] == stage, 'inactive callback stage')
    check_source_and_dependencies()


def run():
    binding = preflight()
    RUN.mkdir()
    put(RUN / 'claim.json', {'runner': process(os.getpid()), 'started_unix': time.time(), 'binding_sha256': sha(PACKAGE / 'execution-binding.json')})
    WORK.mkdir()
    env = dict(os.environ)
    env.pop('PYTHONOPTIMIZE', None)
    env.update(binding['environment'])
    final = {'execution_ready': False, 'functional_ready': False, 'timing_ready': False, 'constraint_ready': False}
    try:
        for stage in binding['stages']:
            check_source_and_dependencies()
            argv = stage['argv']
            require(stage['cwd'] == str(WORK), 'stage cwd')
            if stage['name'] == 'generate':
                comparison = compare_saved(PACKAGE / 'baseline/mem_ss.ip', WORK / 'mem_ss.ip')
                put(RUN / 'saved-comparison.json', comparison)
                require(comparison['accepted'], 'saved/hidden/interface drift requires review before generation')
                require((WORK / 'first-save.ip').read_bytes() == (WORK / 'mem_ss.ip').read_bytes(), 'reload changed saved bytes')
            active_path = RUN / 'active-stage.json'
            if active_path.exists(): active_path.unlink()
            put(active_path, {'stage': stage['name']})
            invocation = dict(stage, started_unix=time.time(), environment=binding['environment'])
            put(RUN / (stage['name'] + '-invocation.json'), invocation)
            with (RUN / (stage['name'] + '.log')).open('xb') as log:
                child = subprocess.Popen(argv, cwd=WORK, env=env, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
                try:
                    rc = child.wait(timeout=stage['timeout_seconds'])
                except subprocess.TimeoutExpired:
                    import signal
                    os.killpg(child.pid, signal.SIGTERM)
                    try: child.wait(timeout=10)
                    except subprocess.TimeoutExpired:
                        os.killpg(child.pid, signal.SIGKILL)
                        child.wait()
                    rc = 124
            put(RUN / (stage['name'] + '-result.json'), {'returncode': rc, 'finished_unix': time.time()})
            require(rc == 0, 'native stage failed: ' + stage['name'] + ' rc=' + str(rc))
            text = (RUN / (stage['name'] + '.log')).read_text(errors='replace')
            import re
            require(not re.search(r'(?i)\b(?:error|fatal)(?:\s*\([^\n)]*\))?\s*:|Critical Warning \(125091\)|IA840F.*(?:REJECTED|NOT READY)|assertion.*failed|unmatched.*parameter|ignored.*parameter', text), 'native diagnostic rejection')
        report = compare_generated(PACKAGE / 'baseline', WORK)
        put(RUN / 'generated-comparison.json', report)
        msa_reports = [x for x in report['files'] if x['baseline'].endswith(('_msa_0.v', '_msa_1.v'))]
        require(len(msa_reports) == 2 and all(x.get('msa_zero_copies1_full_map_preserved') is True for x in msa_reports), 'generated MSA zero/copies1/full-map/interface verification failed')
        require(not any(x.get('missing') for x in report['files']), 'missing generated baseline counterpart')
        check_source_and_dependencies()
        final.update(native_generation_completed=True, generated_acceptance=False, status='Await independent full drift/interface review')
        put(RUN / 'result.json', final)
        return 0
    except BaseException as exc:
        final.update(native_generation_completed=False, status='failed', error=str(exc))
        put(RUN / 'result.json', final)
        raise


if __name__ == '__main__':
    if sys.argv[1:] == ['--active', 'save-reload']:
        active('save-reload')
    elif sys.argv[1:] == ['--preflight']:
        preflight()
    elif not sys.argv[1:]:
        sys.exit(run())
    else:
        raise SystemExit('Unsupported invocation')
