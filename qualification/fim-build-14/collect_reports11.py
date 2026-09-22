#!/usr/bin/env python3
"""Finite completed-report capture only; no vendor or device commands."""
import base64
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import socket
import subprocess

ROOT = Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14/syn/board/ia840f/syn_top')
BATCH = 'ia840f_fim14_reports11'
FILES = [
    'output_files/ofs_top.sta.rpt',
    'output_files/ofs_top.sta.summary',
    'output_files/ofs_top.fit.rpt',
    'output_files/ofs_top.fit.summary',
    'output_files/ofs_top.fit.finalize.rpt',
]
if socket.gethostname() != 'Agilex7Workstation' or os.getuid() != 1000 or not os.environ.get('TMUX'):
    raise RuntimeError('unexpected host/session')
session = subprocess.check_output(['tmux', 'display-message', '-p', '-t', os.environ['TMUX_PANE'], '#S'], text=True).strip()
if session != 'ia840f_mailbox_monitored_01':
    raise RuntimeError('unexpected owned session')
result = dict(batch=BATCH, time=datetime.datetime.now(datetime.timezone.utc).isoformat(), pane=os.environ['TMUX_PANE'], root=str(ROOT), files={})
total = 0
for rel in FILES:
    path = ROOT / rel
    if not path.is_file() or path.is_symlink() or not path.resolve().is_relative_to(ROOT):
        raise RuntimeError('not an allowed ordinary file: ' + rel)
    before = path.stat()
    if before.st_size > 65000000:
        raise RuntimeError('file exceeds bound: ' + rel)
    total += before.st_size
    if total > 80000000:
        raise RuntimeError('total exceeds bound')
    data = path.read_bytes()
    after = path.stat()
    if (before.st_size, before.st_mtime_ns, before.st_ino) != (after.st_size, after.st_mtime_ns, after.st_ino) or len(data) != before.st_size:
        raise RuntimeError('report changed during capture: ' + rel)
    packed = gzip.compress(data, mtime=0)
    result['files'][rel] = dict(size=len(data), sha256=hashlib.sha256(data).hexdigest(), mtime_ns=before.st_mtime_ns, gzip_size=len(packed), gzip_sha256=hashlib.sha256(packed).hexdigest(), gzip_base64=base64.b64encode(packed).decode())
raw = json.dumps(result, sort_keys=True).encode()
blob = gzip.compress(raw, mtime=0)
subprocess.run(['tmux', 'load-buffer', '-b', BATCH, '-'], input=blob, check=True)
print('REPORTS11 JSON_SHA256', hashlib.sha256(raw).hexdigest(), 'GZIP_SHA256', hashlib.sha256(blob).hexdigest(), flush=True)
