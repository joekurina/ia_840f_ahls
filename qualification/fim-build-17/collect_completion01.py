#!/usr/bin/env python3
"""One finite ordinary-file completion capture; never execute FPGA tools."""
import base64
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess
from typing import Any

B = Path('/home/uwb_student00/ahls/new_BSP')
E = B / 'qualification/fim-build-17'
S = B / 'work_ia840f_fim_17/syn/board/ia840f/syn_top'
BATCH = 'ia840f_fim17_completion01'
if socket.gethostname() != 'Agilex7Workstation' or os.getuid() != 1000 or not os.environ.get('TMUX'):
    raise RuntimeError('wrong host/session')
if subprocess.check_output(['tmux', 'display-message', '-p', '-t', os.environ['TMUX_PANE'], '#S'], text=True).strip() != 'ia840f_mailbox_monitored_01':
    raise RuntimeError('wrong owned session')
r: dict[str, Any] = dict(batch=BATCH, time=datetime.datetime.now(datetime.timezone.utc).isoformat(), pane=os.environ['TMUX_PANE'], files={}, missing=[], artifacts={}, processes=[], output_listing=[])

def read_regular(p, root, limit):
    if not p.is_file() or p.is_symlink() or not p.resolve().is_relative_to(root):
        raise RuntimeError('not an allowed regular file: ' + str(p))
    before = p.stat()
    if before.st_size > limit:
        raise RuntimeError('file over size bound: ' + str(p))
    data = p.read_bytes()
    after = p.stat()
    stable = (before.st_size, before.st_mtime_ns, before.st_ino) == (after.st_size, after.st_mtime_ns, after.st_ino) and len(data) == before.st_size
    return data, dict(size=len(data), sha256=hashlib.sha256(data).hexdigest(), mtime_ns=before.st_mtime_ns, stable=stable)

def export(p, root):
    if not p.exists():
        r['missing'].append(str(p))
        return
    data, meta = read_regular(p, root, 12000000)
    packed = gzip.compress(data, mtime=0)
    meta.update(gzip_size=len(packed), gzip_sha256=hashlib.sha256(packed).hexdigest(), gzip_base64=base64.b64encode(packed).decode())
    r['files'][str(p)] = meta

for rel in ('run/status.json', 'run/native-status.json', 'run/invocation.json', 'run/native.log', 'native-compile.claim.json', 'issuance-receipt01.json'):
    export(E / rel, E)
state = json.loads(read_regular(E / 'run/status.json', E, 100000)[0])
r['runner_state'] = state
for folder in (S, S / 'output_files'):
    for p in sorted(folder.iterdir()):
        if not p.is_file() or p.is_symlink():
            continue
        if folder.name == 'output_files':
            r['output_listing'].append(dict(name=p.name, size=p.stat().st_size, mtime_ns=p.stat().st_mtime_ns))
        if p.name.startswith('ofs_top.') and (p.name.endswith('.summary') or p.name.endswith(('.asm.rpt', '.flow.rpt', '.done'))):
            export(p, S)
for rel in ('build_env_db.txt', 'fme_id.mif', 'ofs_top.qpf', 'ofs_top.qsf', 'fim_project_macros.tcl'):
    export(S / rel, S)
ps = subprocess.check_output(['ps', '-eo', 'pid,ppid,stat,pcpu,rss,comm,args'], text=True).splitlines()
for line in ps[1:]:
    f = line.split(None, 6)
    if len(f) != 7 or not (f[5].startswith(('quartus_', 'qsys-')) or 'work_ia840f_fim_17' in f[6] or 'fim-build-17/compile-candidate-01/launch_native_compile.py' in f[6]):
        continue
    pid = f[0]
    item: dict[str, Any] = dict(ps=line)
    try:
        item.update(exe=os.readlink('/proc/' + pid + '/exe'), cwd=os.readlink('/proc/' + pid + '/cwd'), argv=Path('/proc/' + pid + '/cmdline').read_bytes().decode(errors='replace').rstrip('\0').split('\0'), stat=Path('/proc/' + pid + '/stat').read_text())
    except OSError as error:
        item['process_read_error'] = repr(error)
    r['processes'].append(item)
# Never hash an in-flight programming image as a completed artifact.
if state.get('state') == 'finished':
    for p in sorted((S / 'output_files').iterdir()):
        if p.suffix not in ('.sof', '.rbf', '.msf', '.pmsf', '.jic', '.rpd'):
            continue
        _, meta = read_regular(p, S, 300000000)
        r['artifacts'][str(p)] = meta
    for rel in ('output_files/ofs_top.sta.rpt', 'output_files/ofs_top.fit.rpt'):
        _, meta = read_regular(S / rel, S, 65000000)
        r['artifacts'][str(S / rel)] = dict(meta, purpose='identity comparison with existing full local capture; not retransferred')
else:
    r['artifact_hashing'] = 'NOT DONE: native run not finished'
raw = json.dumps(r, sort_keys=True).encode()
blob = gzip.compress(raw, mtime=0)
subprocess.run(['tmux', 'load-buffer', '-b', BATCH, '-'], input=blob, check=True)
print('COMPLETION01 JSON_SHA256', hashlib.sha256(raw).hexdigest(), 'GZIP_SHA256', hashlib.sha256(blob).hexdigest(), flush=True)
