#!/usr/bin/env python3
"""Read four regular ELF files as data; never load or execute OPAE."""
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import socket
import stat
import struct
import subprocess

BUFFER = 'ia840f_opae_binding_01_batch01'
O = Path('/home/uwb_student00/opae-sdk')
PAIRS = [
    ('uio', '/usr/lib64/opae/libopae-u.so', str(O/'build/lib/libopae-u.so')),
    ('vfio_support', '/usr/lib64/libopaevfio.so.2.13.0',
     str(O/'build/lib/libopaevfio.so.2.13.0')),
]
assert os.environ.get('TMUX')
assert socket.gethostname().lower() == 'agilex7workstation'
r: dict = dict(batch=BUFFER, time=datetime.datetime.now().astimezone().isoformat(),
         pane=os.environ['TMUX_PANE'], pid=os.getpid(), files={}, comparisons={},
         scope='ordinary regular ELF file reads; no runtime loading or device access')


def describe(path) -> dict:
    p = Path(path).resolve(strict=True)
    assert not str(p).startswith(('/dev/', '/sys/', '/proc/'))
    s = p.stat()
    assert stat.S_ISREG(s.st_mode) and 64 <= s.st_size <= 4000000
    data = p.read_bytes()
    h = struct.unpack_from('<16sHHIQQQIHHHHHH', data)
    assert h[0][:6] == b'\x7fELF\x02\x01'
    assert h[11] == 64 and 0 < h[12] < 4096 and h[13] < h[12]
    assert h[6] + h[11] * h[12] <= len(data)
    sections = [struct.unpack_from('<IIQQQQIIQQ', data, h[6]+i*h[11])
                for i in range(h[12])]
    st = sections[h[13]]
    assert st[4] + st[5] <= len(data)
    names = data[st[4]:st[4]+st[5]]
    out = {}
    for sec in sections:
        assert sec[0] < len(names)
        name = names[sec[0]:].split(b'\0', 1)[0].decode()
        # File-backed SHF_ALLOC sections, including relocation/dynamic tables.
        if sec[2] & 2 and sec[1] != 8:
            assert sec[4] + sec[5] <= len(data)
            raw = data[sec[4]:sec[4]+sec[5]]
            out[name] = dict(size=len(raw), sha256=hashlib.sha256(raw).hexdigest())
    assert {'.text', '.rodata', '.note.gnu.build-id'} <= set(out)
    argv = ['readelf', '-d', '-n', str(p)]
    c = subprocess.run(argv, capture_output=True, timeout=20)
    assert c.returncode == 0, c.stderr.decode(errors='replace')
    # Re-read the same ordinary file to reject drift during capture.
    digest = hashlib.sha256(data).hexdigest()
    assert hashlib.sha256(p.read_bytes()).hexdigest() == digest
    return dict(resolved=str(p), size=len(data), sha256=digest, sections=out,
                metadata=dict(argv=argv, rc=c.returncode,
                              stdout=c.stdout.decode(errors='replace'),
                              stderr=c.stderr.decode(errors='replace')))


try:
    for label, installed, built in PAIRS:
        a = r['files'][installed] = describe(installed)
        b = r['files'][built] = describe(built)
        keys = sorted(set(a['sections']) | set(b['sections']))
        r['comparisons'][label] = dict(
            installed=installed, built=built,
            whole_file_equal=a['sha256'] == b['sha256'],
            section_equality={key: a['sections'].get(key) == b['sections'].get(key)
                              for key in keys})
    r['complete'] = True
except Exception as e:
    r['complete'] = False
    r['error'] = repr(e)
finally:
    raw = json.dumps(r, sort_keys=True).encode()
    blob = gzip.compress(raw, mtime=0)
    subprocess.run(['tmux', 'load-buffer', '-b', BUFFER, '-'], input=blob, check=True)
    print('EVIDENCE', BUFFER, 'JSON_SHA256', hashlib.sha256(raw).hexdigest(),
          'GZIP_SHA256', hashlib.sha256(blob).hexdigest(),
          'COMPLETE', r.get('complete'), flush=True)
