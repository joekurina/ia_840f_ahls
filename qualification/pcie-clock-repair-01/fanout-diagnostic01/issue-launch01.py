#!/usr/bin/env python3
"""One-shot review transport/issuance, then exec the unchanged reviewed runner."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess, sys
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01')
L=E/'launch01'
CANDIDATE='39afbfaec768985d9472da0b95c58df676afd0c273d1257a9f40180b9f44a719'
REVIEW_HASHES={'prepared-manifest02.json': '19c972f6e5e173c3b48e1bef4af73359dec0e695ddecf062daa07762b62e52e3', 'spec-review01.md': 'c36f41c60a61bc642d8d1c1ba7312b442d7dd41b4dc66609bae666ab3a54969c', 'quality-review01.md': 'ee30a3a2902a0d0585bc95dd4f057529dfd20dacb8aa4f12d5e06b58a73ee784', 'parent-consumption01.json': '3595a06189f5a3f5358edd41acdc1d102774b8a0511f01ac93f6dc71826f163a', 'ACCEPTANCE.md': '2d7320f41c2c43c6cd5b0b6a33e3bf3545a4e398d0054ed9c3d84cb6f67342cc'}
def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for b in iter(lambda:f.read(4194304),b''):h.update(b)
    return h.hexdigest()
def inventory(root):
    out={}
    for folder,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(folder)/name;key=str(p.relative_to(root))
            if p.is_symlink():out[key]={'link':os.readlink(p)}
            elif p.is_file():out[key]={'sha256':sha(p)}
    return out
def main():
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:raise RuntimeError('host/user/tmux/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':raise RuntimeError('session')
    if E.resolve()!=E or not E.is_dir():raise RuntimeError('attempt root')
    for p in [L]+[E/n for n in ('authorization.json','query.claim','query.log','native-process.json','native-result.json','execution-status.json','preservation-after.json','report-manifest.json','reports')]:
        if p.exists() or p.is_symlink():raise RuntimeError('consumed/existing '+str(p))
    for name in ('authorization.json','query.claim','query.log'):
        p=E.parent/'experiment03'/'candidate'/name
        if p.exists() or p.is_symlink():raise RuntimeError('candidate cannot precede baseline '+str(p))
    if len(sys.argv)!=2:raise RuntimeError('exact payload hash argument required')
    raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_clock_fanout01_launch01_payload','-'])
    if hashlib.sha256(raw).hexdigest()!=sys.argv[1]:raise RuntimeError('payload hash')
    payload=json.loads(raw)
    if set(payload)!={'prepared-manifest02.json','spec-review01.md','quality-review01.md','parent-consumption01.json','ACCEPTANCE.md'}:raise RuntimeError('review payload scope')
    decoded={}
    for name,item in payload.items():
        data=base64.b64decode(item['base64'],validate=True)
        if hashlib.sha256(data).hexdigest()!=item['sha256']:raise RuntimeError('review bytes '+name)
        if name in REVIEW_HASHES and item['sha256']!=REVIEW_HASHES[name]:raise RuntimeError('review identity '+name)
        decoded[name]=data
    manifest=json.loads(decoded['prepared-manifest02.json'])
    for name,item in manifest.items():
        p=E/name
        if Path(name).name!=name or p.is_symlink() or not p.is_file() or p.stat().st_size!=item['bytes'] or sha(p)!=item['sha256']:raise RuntimeError('prepared drift '+name)
    if sha(E/'candidate.json')!=CANDIDATE:raise RuntimeError('candidate')
    r=json.loads((E/'candidate.json').read_text())
    if r['approved'] is not False or r['ready_for_build'] is not False or r['part']!='AGFB027R25A2E2V':raise RuntimeError('target/readiness')
    for filename,digest in r['files'].items():
        if sha(Path(filename))!=digest:raise RuntimeError('candidate file '+filename)
    for filename,target in r['links'].items():
        if os.readlink(filename)!=target:raise RuntimeError('candidate link '+filename)
    baseline=json.loads(gzip.decompress((E/'preservation.json.gz').read_bytes()))
    for root,expected in baseline.items():
        if inventory(Path(root))!=expected:raise RuntimeError('original changed '+root)
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024<80000000000 or shutil.disk_usage(E).free<20000000000:raise RuntimeError('headroom')
    if any(x.strip().startswith(('quartus_','qsys-')) for x in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('competing native tool')
    L.mkdir()
    for name,data in decoded.items():
        with (L/name).open('xb') as f:f.write(data)
        if (L/name).read_bytes()!=data:raise RuntimeError('review readback')
    auth={'approved':True,'candidate_sha256':CANDIDATE,'permission':'exact-offline-fanout-diagnostic01'}
    with (E/'authorization.json').open('x') as f:json.dump(auth,f,indent=2)
    if json.loads((E/'authorization.json').read_text())!=auth:raise RuntimeError('authorization readback')
    receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'pane':os.environ['TMUX_PANE'],'authorization_sha256':sha(E/'authorization.json'),'candidate_sha256':CANDIDATE,'reviews':{k:hashlib.sha256(v).hexdigest() for k,v in decoded.items()},'originals_unchanged_before_launch':True,'native_started_at_receipt':False,'runner_argv':r['runner']['argv'],'runner_cwd':r['runner']['cwd']}
    with (L/'issuance.json').open('x') as f:json.dump(receipt,f,indent=2)
    print('FANOUT01_AUTHORIZATION_ISSUED',json.dumps(receipt),flush=True)
    os.chdir(E)
    os.execv(r['runner']['exe'],r['runner']['argv'])
if __name__=='__main__':main()
