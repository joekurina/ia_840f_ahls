#!/usr/bin/env python3
"""Finite ordinary-file preservation/snapshot capture after Work17 exit."""
import os, socket, json, datetime, hashlib, gzip, subprocess, base64, stat
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim-build-17'
C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_17'; OLD=B/'work_ia840f_fim_16'
S=W/'syn/board/ia840f/syn_top'; BATCH='ia840f_fim17_postflight02'
assert not __import__('sys').flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
b=subprocess.check_output(['tmux','save-buffer','-b',BATCH+'_inputs','-'])
assert hashlib.sha256(b).hexdigest()=='9ac3c12f883bf21dbe35da3190829b175a100020cd6be457eb45ecebcc14b488'
v=json.loads(gzip.decompress(b)); state=json.loads((E/'run/status.json').read_text())
assert state['state']=='finished' and state['authorization_sha256']==v['authorization_sha256']
assert hashlib.sha256((E/'compile-authorization.json').read_bytes()).hexdigest()==v['authorization_sha256']
def native_processes():
    ps=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
    return [x for x in ps.splitlines()[1:] if x.split(None,3)[2].startswith(('quartus_','qsys-'))]
assert not native_processes()
r={'batch':BATCH,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'payload_sha256':hashlib.sha256(b).hexdigest(),'baseline_archive_sha256':v['baseline_archive_sha256'],'inventories':{},'deltas':{},'original_work16_binding_deltas':{},'work_input_deltas':{},'snapshot_inventory':{},'files':{},'native_tools_active':[],'original_work16_full_prelaunch_inventory_available':False}
read_total=0
file_count=0
def sha(p):
    global read_total,file_count
    before=p.stat(); assert stat.S_ISREG(before.st_mode) and not p.is_symlink() and before.st_size<=2000000000
    read_total+=before.st_size;file_count+=1
    assert read_total<=20000000000 and file_count<=30000
    h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1048576),b''):h.update(chunk)
    after=p.stat();assert (before.st_ino,before.st_size,before.st_mtime_ns)==(after.st_ino,after.st_size,after.st_mtime_ns)
    return h.hexdigest()
def binding(p,root):
    if p.is_symlink():
        assert p.resolve(strict=True).is_relative_to(root)
        return {'link':os.readlink(p)}
    if not p.exists():return None
    assert p.resolve().is_relative_to(root)
    return {'sha256':sha(p)}
def norm(d):
    return {'link':d['symlink']} if d and 'symlink' in d else d
for root,old in v['baseline'].items():
    rootp=Path(root);assert rootp in (C,B/'ofs-platform-afu-bbb');expected=json.loads(json.dumps(old))
    if rootp==C:
        for rel,item in v['source_delta'].items():
            assert expected[rel]=={'sha256':item['old']};expected[rel]={'sha256':item['new']}
    actual={str(p.relative_to(rootp)):binding(p,rootp) for p in sorted(rootp.rglob('*')) if p.is_file() or p.is_symlink()}
    r['inventories'][root]=actual
    r['deltas'][root]={k:{'expected':expected.get(k),'actual':actual.get(k)} for k in sorted(set(expected)|set(actual)) if expected.get(k)!=actual.get(k)}
for rel,old in v['original_work16_expected_bindings'].items():
    now=binding(OLD/rel,OLD)
    if norm(old)!=now:r['original_work16_binding_deltas'][rel]={'expected':old,'actual':now}
actual={}
for p in sorted(W.rglob('*')):
    if not (p.is_file() or p.is_symlink()):continue
    rel=str(p.relative_to(W));actual[rel]=binding(p,W)
    if 'qdb' in p.relative_to(W).parts:
        r['snapshot_inventory'][rel]=dict(actual[rel],size=p.stat().st_size,mtime_ns=p.stat().st_mtime_ns)
r['inventories'][str(W)]=actual
for rel,old in v['work17_inputs'].items():
    if norm(old)!=actual.get(rel):r['work_input_deltas'][rel]={'before':old,'after':actual.get(rel)}
for name in ('ofs_top.fit.plan.rpt','ofs_top.fit.place.rpt','ofs_top.fit.route.rpt','ofs_top.fit.retime.rpt'):
    p=S/'output_files'/name;assert not p.is_symlink() and p.is_file() and p.stat().st_size=={'ofs_top.fit.place.rpt': 8410679, 'ofs_top.fit.plan.rpt': 3314855, 'ofs_top.fit.retime.rpt': 166614, 'ofs_top.fit.route.rpt': 212106}[name]
    b=p.read_bytes();assert hashlib.sha256(b).hexdigest()==actual[str(p.relative_to(W))]['sha256']
    packed=gzip.compress(b,mtime=0)
    r['files']['output_files/'+name]={'size':len(b),'sha256':hashlib.sha256(b).hexdigest(),'gzip_size':len(packed),'gzip_sha256':hashlib.sha256(packed).hexdigest(),'gzip_base64':base64.b64encode(packed).decode()}
r['original_work16_recorded_bindings_unchanged']=not r['original_work16_binding_deltas']
r['pim_full_unchanged']=not r['deltas'][str(B/'ofs-platform-afu-bbb')]
r['hashed_bytes']=read_total;r['hashed_file_operations']=file_count
r['native_tools_active']=native_processes();assert not r['native_tools_active']
raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
print('POSTFLIGHT02 JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
