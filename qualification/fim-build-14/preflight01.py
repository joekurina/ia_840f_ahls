#!/usr/bin/env python3
"""Ordinary source/OS preflight in owned tmux; never opens FPGA devices."""
import base64
import datetime
import gzip
import hashlib
import json
import os
from pathlib import Path
import shutil
import socket
import stat
import subprocess

B = Path('/home/uwb_student00/ahls/new_BSP')
C = B / 'ofs-agx7-pcie-attach'
W = B / 'work_ia840f_fim_13'
BUFFER = 'ia840f_fim14_preflight01_output'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def digest(path):
    resolved = path.resolve(strict=True)
    require(not str(resolved).startswith(('/dev/', '/sys/', '/proc/')), 'not ordinary file')
    require(stat.S_ISREG(resolved.stat().st_mode), 'not regular file')
    h = hashlib.sha256()
    with resolved.open('rb') as f:
        for data in iter(lambda: f.read(1048576), b''):
            h.update(data)
    return h.hexdigest()


def inventory(root):
    result = {}
    for path in sorted(root.rglob('*')):
        rel = path.relative_to(root).as_posix()
        if '__pycache__' in path.parts or path.suffix == '.pyc' or rel == 'board/ia840f/setup/experimental-authorization.json':
            continue
        if path.is_symlink():
            require(path.resolve(strict=True).is_relative_to(root) and path.is_file(), 'source symlink escape: ' + rel)
        if path.is_file():
            result[rel] = digest(path)
    require(bool(result), 'empty inventory')
    return result


require(os.environ.get('TMUX') and socket.gethostname() == 'Agilex7Workstation', 'wrong host/session')
pane = os.environ['TMUX_PANE']
session = subprocess.check_output(['tmux', 'display-message', '-p', '-t', pane, '#S'], text=True).strip()
require(session == 'ia840f_mailbox_monitored_01', 'wrong tmux session')
r: dict = dict(batch=BUFFER, time=datetime.datetime.now().astimezone().isoformat(), pane=pane, pid=os.getpid(), files={}, commands={})
try:
    for name, argv in [('memory', ['free', '-b']), ('processes', ['ps', '-eo', 'pid,ppid,stat,pcpu,pmem,args']), ('work13_size', ['du', '-sk', str(W)])]:
        p = subprocess.run(argv, capture_output=True, text=True, timeout=90)
        output = p.stdout
        if name == 'processes':
            output = '\n'.join(line for line in output.splitlines() if any(key in line.lower() for key in ('quartus', 'qsys', 'aoc', 'ahls', 'verilator', 'vsim', 'python', 'build_top')))
        r['commands'][name] = dict(argv=argv, rc=p.returncode, stdout=output, stderr=p.stderr)
        require(p.returncode == 0, name + ' failed')
    r['disk'] = dict(zip(('total', 'used', 'free'), shutil.disk_usage(B)))
    r['loadavg'] = os.getloadavg()
    previous_path = B / 'qualification/fim-build-13/compile-authorization.json'
    previous = json.loads(previous_path.read_text())
    r['previous_record_sha256'] = digest(previous_path)
    r['source_inventory'] = {tree: inventory(C / tree) for tree in previous['source_sha256']}
    r['source_delta_vs_w13_record'] = {}
    for tree, current in r['source_inventory'].items():
        old = previous['source_sha256'][tree]
        r['source_delta_vs_w13_record'][tree] = {k: dict(old=old.get(k), new=current.get(k)) for k in sorted(set(old) | set(current)) if old.get(k) != current.get(k)}
    pim = B / 'ofs-platform-afu-bbb'
    r['pim_inventory'] = inventory(pim)
    r['pim_matches_w13_record'] = r['pim_inventory'] == previous['pim_sha256']
    r['tool_identity_changes'] = []
    tools = {x['path']: x['sha256'] for group in ('tools', 'quartus_tools') for x in previous[group].values()}
    tools.update({x['executable']: x['sha256'] for x in previous['contexts']})
    for path, expected in tools.items():
        actual = digest(Path(path))
        if actual != expected:
            r['tool_identity_changes'].append(dict(path=path, old=expected, new=actual))
    r['tool_files_checked'] = len(tools)
    paths = [Path('/home/uwb_student00/quartus_26/instructions.md'), C / 'src/board/ia840f/afu_top.sv', W / 'src/board/ia840f/afu_top.sv', W / 'syn/board/ia840f/syn_top/ofs_top.qsf', W / 'syn/board/ia840f/syn_top/build_env_db.txt', C / 'ofs-common/scripts/common/syn/build_top.sh', C / 'ofs-common/scripts/common/syn/build_fim_compile.sh', C / 'syn/board/ia840f/setup/build_gate.tcl']
    for path in paths:
        require(path.stat().st_size < 2000000, 'file too large')
        data = path.read_bytes()
        r['files'][str(path)] = dict(size=len(data), sha256=digest(path), base64=base64.b64encode(data).decode())
    r['successor_exists'] = {str(path): path.exists() or path.is_symlink() for path in (B / 'work_ia840f_fim_14', B / 'qualification/fim-build-14')}
    r['complete'] = True
except Exception as error:
    r.update(complete=False, error=repr(error))
finally:
    raw = json.dumps(r, sort_keys=True).encode()
    blob = gzip.compress(raw, mtime=0)
    subprocess.run(['tmux', 'load-buffer', '-b', BUFFER, '-'], input=blob, check=True)
    print('PREFLIGHT', BUFFER, 'JSON_SHA256', hashlib.sha256(raw).hexdigest(), 'GZIP_SHA256', hashlib.sha256(blob).hexdigest(), 'COMPLETE', r.get('complete'), flush=True)
