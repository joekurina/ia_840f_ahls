#!/usr/bin/env python3
"""Copy only recorded Work13 inputs into fresh Work14; no vendor execution.
SOURCE and Work13 stay untouched. Candidate overlays are not authorizations.
"""
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
import sys
import traceback

sys.dont_write_bytecode = True
B = Path('/home/uwb_student00/ahls/new_BSP')
C = B / 'ofs-agx7-pcie-attach'
OLD = B / 'work_ia840f_fim_13'
W = B / 'work_ia840f_fim_14'
E = B / 'qualification/fim-build-14'
P = E / 'compile-candidate-01'
OUTPUT = 'ia840f_fim14_prepare02_output'
INPUT = 'ia840f_fim14_prepare02_payload'
RECORD = B / 'qualification/fim-build-13/compile-authorization.json'
RECORD_SHA = '204cd46e869b7d78ef8978ac01ac88b19cd99f5f7a6e6152de2a1d8fadc51df1'
UART = 'src/board/ia840f/afu_top.sv'
GATES = ('ia840f_experimental_gate.py', 'ia840f_compile_gate.py')

def require(ok, text):
    if not ok:
        raise RuntimeError(text)

def sha(path):
    p = Path(path).resolve(strict=True)
    require(not str(p).startswith(('/dev/', '/sys/', '/proc/')), 'not ordinary file')
    require(stat.S_ISREG(p.stat().st_mode), 'not regular file')
    h = hashlib.sha256()
    with p.open('rb') as f:
        for data in iter(lambda: f.read(1048576), b''):
            h.update(data)
    return h.hexdigest()

def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as f:
        f.write(data)

def savejson(path, obj):
    save(path, (json.dumps(obj, indent=2, sort_keys=True) + '\n').encode())

def inventory(root):
    items = {}
    for path in sorted(root.rglob('*')):
        if '__pycache__' in path.parts or path.suffix == '.pyc':
            continue
        rel = path.relative_to(root).as_posix()
        if path.is_symlink():
            require(path.resolve(strict=True).is_relative_to(root), 'symlink escape ' + rel)
            items[rel] = {'symlink': os.readlink(path)}
        elif path.is_file():
            items[rel] = {'sha256': sha(path)}
    return items

require(not sys.flags.optimize, 'assertions must be enabled')
require(socket.gethostname() == 'Agilex7Workstation' and os.getuid() == 1000 and os.environ.get('TMUX'), 'wrong execution context')
pane = os.environ['TMUX_PANE']
require(subprocess.check_output(['tmux', 'display-message', '-p', '-t', pane, '#S'], text=True).strip() == 'ia840f_mailbox_monitored_01', 'wrong session')
require(E.is_dir() and not E.is_symlink() and not W.exists() and not W.is_symlink(), 'unexpected successor state')
expected_partial = {'work13-input-readback.json': 'a5915d343d861a80b4f4fdf2d838bbc2252ba6b4774482b2d47f617272bb449d', 'preparation-result01.json': '58555508e712cd02fdd32d8dfa807c962d70da9c32e69c0da33e75f107d104dc', 'work13-input-delta.json': 'cee5977b58140e891dfc55a0245c8d216ec8458d1aef6411518553e905cee90c'}
require({str(p.relative_to(E)): sha(p) for p in E.rglob('*') if p.is_file()} == expected_partial, 'partial evidence changed or extra files')
require(all(not p.is_symlink() for p in E.rglob('*')), 'partial evidence symlink')
result: dict = dict(batch=OUTPUT, pane=pane, pid=os.getpid(), started=datetime.datetime.now().astimezone().isoformat(), complete=False, source_modified=False, native_tools_executed=False)
try:
    raw = subprocess.check_output(['tmux', 'save-buffer', '-b', INPUT, '-'])
    require(len(sys.argv) == 2 and hashlib.sha256(raw).hexdigest() == sys.argv[1], 'payload hash mismatch')
    payload = json.loads(raw)
    expected = {'gate-copy/' + name for name in GATES} | {'issue_authorization.py', 'launch_native_compile.py', 'source-inputs/afu_top.sv', 'source-inputs/metadata-disposition.md'}
    require(set(payload) == expected, 'unexpected payload')
    blobs = {}
    for name, item in payload.items():
        data = base64.b64decode(item['base64'], validate=True)
        require(hashlib.sha256(data).hexdigest() == item['sha256'], 'payload member mismatch')
        blobs[name] = data
    require(sha(RECORD) == RECORD_SHA, 'previous issued record drift')
    previous = json.loads(RECORD.read_text())
    sys.path.insert(0, str(C / 'ofs-common/tools/ofss_config'))
    import ia840f_experimental_gate as common
    before_source = {t: common.inventory(C / t) for t in common.TREES}
    require(before_source == previous['source_sha256'], 'SOURCE changed since issued Work13 record')
    require(common.inventory(common.PIM) == previous['pim_sha256'], 'PIM drift')
    procs = subprocess.check_output(['ps', '-eo', 'pid,ppid,comm,args'], text=True)
    active = [line for line in procs.splitlines()[1:] if len(line.split()) >= 3 and line.split()[2].startswith(('quartus_', 'qsys-'))]
    require(not active, 'competing native tasks: ' + repr(active))
    result['free_disk_bytes'] = shutil.disk_usage(B).free
    require(result['free_disk_bytes'] > 20 * 1024 ** 3, 'insufficient copy/build disk headroom')
    result['memory_snapshot'] = subprocess.check_output(['free', '-b'], text=True)
    memory = next(line.split() for line in result['memory_snapshot'].splitlines() if line.startswith('Mem:'))
    require(int(memory[-1]) > 32 * 1024 ** 3, 'insufficient memory headroom')
    original = previous['work_inventory']
    require(not any(set(Path(k).parts) & {'db', 'qdb', 'output_files', 'incremental_db'} for k in original), 'baseline unexpectedly includes databases')
    actual = {}
    for rel, old in original.items():
        path = OLD / rel
        require(path.resolve(strict=True).is_relative_to(OLD), 'original input escapes Work13')
        actual[rel] = {'symlink': os.readlink(path)} if path.is_symlink() else {'sha256': sha(path)}
    drift = {k: {'recorded': original[k], 'actual': actual[k]} for k in original if original[k] != actual[k]}
    savejson(E / 'work13-input-readback02.json', actual)
    savejson(E / 'work13-input-delta02.json', drift)
    result['input_count'] = len(actual)
    result['input_drift'] = drift
    allowed_metadata_drift = {'syn/board/ia840f/syn_top/build_env_db.txt': {'actual': {'sha256': '92241831e340864cace927834818f51c978193d3f8e82907721509853c20c02d'}, 'recorded': {'sha256': 'e5196c254bcd93efc8e0e12d7a4c2c1771300f85339da1aa181fbce1183b4c76'}}, 'syn/board/ia840f/syn_top/fme_id.mif': {'actual': {'sha256': '306da730161da6ede07449f3e8261fd816e1d7eac7e2942bc12a72cbe9462e4e'}, 'recorded': {'sha256': '5fe54a76c9a24164f5e0fe2ef48110ff68b409b59efeea95bb3dd30dc0a6207f'}}, 'syn/board/ia840f/syn_top/ofs_top.qpf': {'actual': {'sha256': '363715b4c5e5117b90f36923dc20378bae26b41361e03d20a2098dd17e31298f'}, 'recorded': {'sha256': 'db1a9ba36dfcd81909a869815427ff48e81913be091f1732ff02707018d33052'}}}
    require(drift == allowed_metadata_drift, 'drift differs from the three inspected native metadata changes')
    savejson(E / 'source-before.json', before_source)
    for name, data in blobs.items():
        save(P / name, data)
    W.mkdir()
    old_root, new_root = str(OLD).encode(), str(W).encode()
    relocations = {}
    for rel, item in actual.items():
        src, dst = OLD / rel, W / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        if 'symlink' in item:
            target = item['symlink'].replace(str(OLD), str(W))
            os.symlink(target, dst)
            if target != item['symlink']:
                relocations[rel] = {'old': item['symlink'], 'new': target, 'kind': 'symlink'}
        else:
            shutil.copy2(src, dst)
            require(sha(dst) == item['sha256'], 'copy mismatch ' + rel)
            data = dst.read_bytes()
            if old_root in data:
                data.decode('utf-8')  # Never rewrite opaque binary databases.
                changed = data.replace(old_root, new_root)
                dst.write_bytes(changed)
                shutil.copystat(src, dst)
                relocations[rel] = {'old': item['sha256'], 'new': sha(dst), 'occurrences': data.count(old_root), 'kind': 'text-root-only'}
    overlays = {UART: 'source-inputs/afu_top.sv', **{'ofs-common/tools/ofss_config/' + name: 'gate-copy/' + name for name in GATES}}
    source_delta = {}
    for rel, member in overlays.items():
        tree, suffix = rel.split('/', 1)
        source_delta[rel] = {'old': before_source[tree][suffix], 'new': hashlib.sha256(blobs[member]).hexdigest()}
        require((W / rel).is_file() and not (W / rel).is_symlink(), 'overlay target not regular')
        (W / rel).write_bytes(blobs[member])
        require(sha(W / rel) == source_delta[rel]['new'], 'overlay readback mismatch')
    after = inventory(W)
    expected_delta = set(relocations) | set(overlays)
    measured = {k for k in set(actual) | set(after) if actual.get(k) != after.get(k)}
    require(measured == expected_delta, 'unexpected copied-work delta')
    require(not any((W / rel).exists() for rel in ('syn/board/ia840f/syn_top/output_files', 'syn/board/ia840f/syn_top/qdb')), 'compiled outputs copied')
    for rel, item in actual.items():
        p = OLD / rel
        got = {'symlink': os.readlink(p)} if p.is_symlink() else {'sha256': sha(p)}
        require(got == item, 'original Work13 changed: ' + rel)
    require({t: common.inventory(C / t) for t in common.TREES} == before_source, 'SOURCE changed during preparation')
    require(common.inventory(common.PIM) == previous['pim_sha256'], 'PIM changed during preparation')
    savejson(P / 'source-inputs/delta-report.json', {'source_delta': source_delta, 'source_state': 'EXPECTED after separately reviewed integration; SOURCE currently untouched'})
    savejson(E / 'work14-prepared-inventory.json', after)
    savejson(E / 'work14-relocations.json', relocations)
    result.update(complete=True, copied_input_count=len(after), source_delta_expected=source_delta, relocation_count=len(relocations), work_delta_count=len(measured), original_recorded_inputs_unchanged=True, source_unchanged=True, pim_unchanged=True)
except BaseException as error:
    result.update(error=repr(error), traceback=traceback.format_exc())
finally:
    result['ended'] = datetime.datetime.now().astimezone().isoformat()
    savejson(E / 'preparation-result02.json', result)
    exports = {}
    for path in sorted(E.rglob('*')):
        if path.is_file():
            data = path.read_bytes()
            require(len(data) < 2000000, 'evidence member over cap: ' + str(path))
            exports[str(path.relative_to(E))] = dict(size=len(data), sha256=hashlib.sha256(data).hexdigest(), base64=base64.b64encode(data).decode())
    packet = json.dumps(dict(batch=OUTPUT, result=result, files=exports), sort_keys=True).encode()
    blob = gzip.compress(packet, mtime=0)
    subprocess.run(['tmux', 'load-buffer', '-b', OUTPUT, '-'], input=blob, check=True)
    print('PREPARE', OUTPUT, 'JSON_SHA256', hashlib.sha256(packet).hexdigest(), 'GZIP_SHA256', hashlib.sha256(blob).hexdigest(), 'COMPLETE', result['complete'], flush=True)
    print(json.dumps(result, indent=2), flush=True)
if not result['complete']:
    raise SystemExit(1)
