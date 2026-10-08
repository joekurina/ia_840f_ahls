#!/usr/bin/env python3
"""Install a checksum-bound official Tectonic binary into this document tree."""
import hashlib
import io
import json
from pathlib import Path
import tarfile
import urllib.request

ROOT = Path(__file__).resolve().parent
URL = 'https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.17.0/tectonic-0.17.0-x86_64-unknown-linux-musl.tar.gz'
SHA = '8533d07f9ccbd7a65824b9e0459041bca34af1eb33daba48f59215593753a3b7'
tools = ROOT / '.toolchain'
tools.mkdir(exist_ok=True)
with urllib.request.urlopen(URL, timeout=60) as response:
    data = response.read()
assert hashlib.sha256(data).hexdigest() == SHA, 'Official compiler checksum mismatch'
with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
    members = [m for m in archive if m.isfile() and Path(m.name).name == 'tectonic']
    assert len(members) == 1
    stream = archive.extractfile(members[0])
    assert stream is not None
    binary = tools / 'tectonic'
    binary.write_bytes(stream.read())
    binary.chmod(0o755)
(ROOT / 'sources/latex-compiler.json').write_text(json.dumps({
    'version': '0.17.0', 'distribution_url': URL, 'archive_sha256': SHA,
    'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'installation': str(binary), 'system_TeX_installation_changed': False,
}, indent=2))
print(binary)
