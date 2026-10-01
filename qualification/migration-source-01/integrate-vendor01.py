#!/usr/bin/env python3
"""Integrate the already checked, immutable upstream deltas exactly once."""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]
E = Path(__file__).resolve().parent
PREP = E / 'vendor01'
OUT = E / 'integration01'


def digest(path):
    data = str(path.readlink()).encode() if path.is_symlink() else path.read_bytes()
    return hashlib.sha256(data).hexdigest()


def run(argv, cwd=ROOT):
    p = subprocess.run(argv, cwd=cwd, capture_output=True, text=True, timeout=90)
    result = {'argv': argv, 'cwd': str(cwd), 'rc': p.returncode,
              'stdout': p.stdout, 'stderr': p.stderr}
    assert p.returncode == 0, result
    return result


def main():
    manifest = json.loads((PREP / 'manifest.json').read_text())
    originals = json.loads((E / 'basis01/before-git.json').read_text())
    assert run(['git', 'branch', '--show-current'])['stdout'].strip() == 'migration-ofs-2026.1-quartus26.1'
    for row in manifest['changes']:
        p = ROOT / row['path']
        assert (digest(p) if p.exists() else None) == row['old_sha256'], row['path']
        assert digest(PREP / 'expected' / row['path']) == row['new_sha256']
    for path, identity in manifest['preserved'].items():
        assert digest(ROOT / path) == identity['sha256'], path
    for check in manifest['checks']:
        assert digest(Path(check['argv'][-1])) == check['patch_sha256']
        run(check['argv'])
    assert run(['git', 'diff', '--cached', '--name-only'])['stdout'] == ''
    OUT.mkdir(exist_ok=False)
    commands = []
    result = {'complete': False, 'commands': commands}
    try:
        for row in manifest['changes']:
            p = ROOT / row['path']
            if p.exists():
                dest = OUT / 'before' / row['path']
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(p, dest)
        for check in manifest['checks']:
            argv = [x for x in check['argv'] if x != '--check']
            commands.append(run(argv))
        for row in manifest['changes']:
            p = ROOT / row['path']
            assert digest(p) == row['new_sha256'], row['path']
            assert ('100755' if p.stat().st_mode & 0o111 else '100644') == row['mode'], row['path']
        for path, identity in manifest['preserved'].items():
            assert digest(ROOT / path) == identity['sha256'], path
        for name, prefix, commit in [
            ('common', 'ofs-agx7-pcie-attach/ofs-common', '147cae890b7d1245301cf5cde229f761b287b70d'),
            ('fim', 'ofs-agx7-pcie-attach', '866c25bb166810f65aae4f6b15374d0a89810e69')]:
            assert originals['donors'][name]['symbolic_head']['returncode'] == 1
            old = originals['donors'][name]['head']['stdout'].strip()
            assert run(['git', 'rev-parse', 'HEAD'], ROOT / prefix)['stdout'].strip() == old
            # Update only the detached donor index/ref. No checkout/reset of working files.
            commands.append(run(['git', 'read-tree', commit], ROOT / prefix))
            commands.append(run(['git', 'update-ref', '--no-deref', 'HEAD', commit, old], ROOT / prefix))
            assert run(['git', 'rev-parse', 'HEAD'], ROOT / prefix)['stdout'].strip() == commit
        root_refs = run(['git', 'show-ref', '--heads', '--tags'])['stdout']
        assert root_refs == originals['root_refs']['stdout']
        result.update(complete=True, changed_file_count=len(manifest['changes']),
                      preserved_inventory_count=len(manifest['preserved']),
                      root_refs_unchanged=True, vendor_tools_run=False,
                      board_access=False, main_modified=False)
    except Exception as exc:
        result['error'] = repr(exc)
        raise
    finally:
        (OUT / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
