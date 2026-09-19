#!/usr/bin/env python3
"""Source bytes/hash preservation only; invokes no project/vendor executables."""
from pathlib import Path
import hashlib, json, shutil, difflib
ROOT = Path(__file__).resolve().parents[3]
NEW = ROOT / 'new'
ASP = NEW / 'oneapi-asp'
UP = ROOT / 'oneapi-asp'
OUT = Path(__file__).resolve().parent
PIN = '1af2ca74c452cb6ebbf54beb86e758e53489e826'
def files(root):
    return {str(p.relative_to(root)): p for p in root.rglob('*') if p.is_file() and '.git' not in p.parts}
def metadata(p):
    b = p.read_bytes()
    return dict(size=len(b), sha256=hashlib.sha256(b).hexdigest(), mode=oct(p.stat().st_mode & 0o777), symlink_target=str(p.readlink()) if p.is_symlink() else None)
a, u = files(ASP), files(UP)
assert not (OUT/'preservation-manifest.json').exists(), 'Never overwrite preservation evidence'
records = []
for f in sorted(a):
    if f in u and a[f].read_bytes() == u[f].read_bytes():
        continue
    target = OUT/'pre-edit'/'oneapi-asp'/f
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(a[f], target)
    assert target.read_bytes() == a[f].read_bytes()
    records.append(dict(source=str(a[f]), snapshot=str(target.relative_to(OUT)), **metadata(a[f]), upstream=metadata(u[f]) if f in u else None))
# Preserve related experiments as context, without changing their original paths.
for base in ['interfaces/dma_hostchannel', 'afu/hostpipe_csr']:
    for f,p in sorted(files(NEW/base).items()):
        target=OUT/'pre-edit'/base/f
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p,target)
        assert target.read_bytes()==p.read_bytes()
        records.append(dict(source=str(p), snapshot=str(target.relative_to(OUT)), **metadata(p), upstream=None))
for f in ['dma-hostchannels-mmd.md','dma-hostchannels-hardware.md','dma-hostchannels-compiler-contract.md','host-pipes.md']:
    p=NEW/'docs'/f
    if p.exists():
        target=OUT/'pre-edit'/'docs'/f
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(p,target)
        assert target.read_bytes()==p.read_bytes()
        records.append(dict(source=str(p),snapshot=str(target.relative_to(OUT)),**metadata(p),upstream=None))
(OUT/'pre-edit-active-inventory.json').write_text(json.dumps({f:metadata(p) for f,p in sorted(a.items())},indent=2)+'\n')
(OUT/'preservation-manifest.json').write_text(json.dumps(dict(schema_version=1, upstream_commit=PIN, upstream_path=str(UP), vendor_path=str(ROOT/'old_bsp/ia-840/IOFS_BUILD_ROOT/oneapi-asp'), policy='Lossless pre-edit snapshots, including every ASP delta against pinned upstream and related experiment context. Sources outside new remain immutable. No builds/tests.', records=records),indent=2)+'\n')
print(json.dumps(dict(preserved_files=len(records),asp_delta_files=sum('/oneapi-asp/' in x['source'] for x in records), verified_bytes=True)))
