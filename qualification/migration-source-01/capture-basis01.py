#!/usr/bin/env python3
"""Capture the local migration basis and fetch only exact public donor refs."""
import concurrent.futures
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = Path(__file__).resolve().parent
OUTPUT = EVIDENCE / 'basis01'
FIM = ROOT / 'ofs-agx7-pcie-attach'
COMMON = FIM / 'ofs-common'
PIM = ROOT / 'ofs-platform-afu-bbb'
TARGETS = [
    ('fim', FIM, '866c25bb166810f65aae4f6b15374d0a89810e69'),
    ('common', COMMON, '147cae890b7d1245301cf5cde229f761b287b70d'),
]


def git(cwd, *args, timeout=60):
    proc = subprocess.run(['git', *args], cwd=cwd, capture_output=True, timeout=timeout)
    return {'cwd': str(cwd), 'argv': ['git', *args], 'returncode': proc.returncode,
            'stdout': proc.stdout.decode(), 'stderr': proc.stderr.decode()}


def file_identity(path):
    if path.is_symlink():
        data = str(path.readlink()).encode()
        return {'kind': 'symlink', 'target': str(path.readlink()),
                'sha256': hashlib.sha256(data).hexdigest()}
    data = path.read_bytes()
    return {'kind': 'file', 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(),
            'mode': oct(path.stat().st_mode & 0o777)}


def main():
    OUTPUT.mkdir(exist_ok=False)
    status = git(ROOT, 'status', '--porcelain=v1', '-z')
    (OUTPUT / 'root-status.nul').write_bytes(status['stdout'].encode())
    tracked = git(ROOT, 'ls-files', '-z')
    paths = tracked['stdout'].split('\0')
    watched = [p for p in paths if p and (p.startswith('ofs-agx7-pcie-attach/')
               or p.startswith('ofs-platform-afu-bbb/'))]
    watched += ['sources.lock.json', 'GOAL-PROMPT-MIGRATION.md', '.gitignore',
                'docs/hw-programming-recovery.md']
    identities = {p: file_identity(ROOT / p) for p in watched}
    (OUTPUT / 'before-files.json').write_text(json.dumps(identities, indent=2) + '\n')
    old = {'root_refs': git(ROOT, 'show-ref', '--heads', '--tags'), 'donors': {}}
    for name, path in [('fim', FIM), ('common', COMMON), ('pim', PIM)]:
        old['donors'][name] = {'head': git(path, 'rev-parse', 'HEAD'),
            'symbolic_head': git(path, 'symbolic-ref', '-q', 'HEAD'),
            'status': git(path, 'status', '--porcelain=v1', '-z'),
            'diff': git(path, 'diff', '--binary', 'HEAD')}
    (OUTPUT / 'before-git.json').write_text(json.dumps(old, indent=2) + '\n')

    def fetch(row):
        name, path, commit = row
        result = {'commit': commit, 'tag_before': git(path, 'ls-remote', 'origin',
                     'refs/tags/ofs-2026.1-1', 'refs/tags/ofs-2026.1-1^{}')}
        requested_ref = 'refs/tags/ofs-2026.1-1' if name == 'fim' else commit
        result['fetch'] = git(path, 'fetch', '--no-tags', 'origin', requested_ref,
                              timeout=150)
        if result['fetch']['returncode'] == 0:
            result['fetched_commit'] = git(path, 'rev-parse', 'FETCH_HEAD^{commit}')
            result['object'] = git(path, 'cat-file', '-t', commit)
            result['expected_matches'] = result['fetched_commit']['stdout'].strip() == commit
        return name, result

    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:
        fetched = dict(pool.map(fetch, TARGETS))
    fetched['pim_master'] = git(PIM, 'ls-remote', 'origin', 'refs/heads/master',
                               'refs/tags/ofs-2026.1-1', 'refs/tags/ofs-2026.1-1^{}')
    (OUTPUT / 'fetch-results.json').write_text(json.dumps(fetched, indent=2) + '\n')
    assert all(fetched[n].get('expected_matches') for n, _, _ in TARGETS), fetched
    gitlink = git(FIM, 'ls-tree', TARGETS[0][2], 'ofs-common')
    assert gitlink['stdout'].split()[2] == TARGETS[1][2], gitlink
    result = {'gitlink': gitlink, 'preserved_files': len(identities), 'deltas': {}}
    for name, path, commit in TARGETS:
        base = old['donors'][name]['head']['stdout'].strip()
        result['deltas'][name] = {'base': base, 'target': commit,
            'ancestry': git(path, 'merge-base', '--is-ancestor', base, commit),
            'commit_count': git(path, 'rev-list', '--count', f'{base}..{commit}'),
            'changes': git(path, 'diff', '--name-status', base, commit),
            'stat': git(path, 'diff', '--stat', base, commit),
            'log': git(path, 'log', '--format=%H %s', f'{base}..{commit}')}
    assert all(file_identity(ROOT / p) == v for p, v in identities.items())
    result['maintained_source_unchanged'] = True
    (OUTPUT / 'verified-basis.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
