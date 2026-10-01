#!/usr/bin/env python3
"""Prepare and check the exact upstream delta; do not alter maintained files."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
E = Path(__file__).resolve().parent
OUT = E / 'vendor01'
DONORS = [
    ('fim', 'ofs-agx7-pcie-attach', '599ac052eafbc9cede22561c099233ae4a54cb7d',
     '866c25bb166810f65aae4f6b15374d0a89810e69'),
    ('common', 'ofs-agx7-pcie-attach/ofs-common', '34a8540697fdf3d66fbcaa263fa037bae17cc32f',
     '147cae890b7d1245301cf5cde229f761b287b70d'),
]


def git(path, *args):
    return subprocess.check_output(['git', *args], cwd=path)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def tree(path, commit):
    result = {}
    for row in git(path, 'ls-tree', '-rz', commit).split(b'\0'):
        if row:
            meta, name = row.split(b'\t', 1)
            mode, kind, oid = meta.decode().split()
            result[name.decode()] = {'mode': mode, 'kind': kind, 'oid': oid}
    return result


def main():
    OUT.mkdir(exist_ok=False)
    changes = []
    retained_overlays = {}
    commands = []
    for name, prefix, old, new in DONORS:
        path = ROOT / prefix
        before, after = tree(path, old), tree(path, new)
        # Validate all original donor blobs, including excluded publication files.
        overlays = []
        for relative, item in before.items():
            if item['kind'] != 'blob':
                continue
            local = path / relative
            assert local.exists() or local.is_symlink(), (name, relative, 'missing old donor file')
            data = str(local.readlink()).encode() if local.is_symlink() else local.read_bytes()
            donor_data = git(path, 'cat-file', 'blob', item['oid'])
            if data != donor_data:
                overlays.append({'path': prefix + '/' + relative, 'sha256': sha(data),
                                 'donor_sha256': sha(donor_data)})
        retained_overlays[name] = overlays
        args = ['diff', '--binary', '--no-renames', old, new, '--', '.']
        if name == 'fim':
            args.append(':(exclude)ofs-common')
        patch = git(path, *args)
        patch_file = OUT / (name + '-upstream.patch')
        patch_file.write_bytes(patch)
        command = ['git', 'apply', '--check', '--whitespace=nowarn',
                   '--directory=' + prefix, str(patch_file)]
        check = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        commands.append({'argv': command, 'rc': check.returncode,
                         'stdout': check.stdout, 'stderr': check.stderr,
                         'patch_sha256': sha(patch)})
        assert check.returncode == 0, commands[-1]
        for relative in sorted(before.keys() | after.keys()):
            a, b = before.get(relative), after.get(relative)
            if a == b or (b and b['kind'] == 'commit'):
                continue
            assert b and b['kind'] == 'blob' and b['mode'] in ('100644', '100755'), (name, relative, b)
            local = path / relative
            assert not local.is_symlink(), ('upstream changed symlink', local)
            if not a:
                assert not local.exists(), ('new upstream file already exists', local)
            current = local.read_bytes() if a else None
            target = git(path, 'cat-file', 'blob', b['oid'])
            old_data = git(path, 'cat-file', 'blob', a['oid']) if a else None
            expected = target
            merged = current is not None and current != old_data
            if merged:
                merge_dir = OUT / 'overlaps' / name / relative
                merge_dir.mkdir(parents=True)
                for label, data in [('current', current), ('base', old_data), ('upstream', target)]:
                    (merge_dir / label).write_bytes(data)
                argv = ['git', 'merge-file', '-p', str(merge_dir / 'current'),
                        str(merge_dir / 'base'), str(merge_dir / 'upstream')]
                result = subprocess.run(argv, capture_output=True)
                assert result.returncode == 0, (relative, result.stderr.decode())
                expected = result.stdout
            destination = OUT / 'expected' / prefix / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(expected)
            changes.append({'path': prefix + '/' + relative, 'old_sha256': sha(current) if a else None,
                            'new_sha256': sha(expected), 'upstream_sha256': sha(target),
                            'bytes': len(expected), 'mode': b['mode'], 'merged_overlay': merged})
    before_files = json.loads((E / 'basis01/before-files.json').read_text())
    affected = {row['path'] for row in changes}
    protected = {p: v for p, v in before_files.items() if p not in affected}
    for p, ident in protected.items():
        f = ROOT / p
        data = str(f.readlink()).encode() if f.is_symlink() else f.read_bytes()
        assert sha(data) == ident['sha256'], p
    receipt = {'changes': changes, 'change_count': len(changes), 'preserved': protected,
               'retained_overlays': retained_overlays, 'checks': commands,
               'overlap_paths': [x['path'] for x in changes if x['merged_overlay']],
               'maintained_files_written': False, 'vendor_tools_run': False}
    (OUT / 'manifest.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(json.dumps({k: v for k, v in receipt.items() if k not in ('changes', 'preserved')}, indent=2))


if __name__ == '__main__':
    main()
