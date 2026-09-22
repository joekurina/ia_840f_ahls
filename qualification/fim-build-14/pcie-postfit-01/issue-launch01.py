#!/usr/bin/env python3
"""One-shot review transport/issuance, then exec the unchanged reviewed runner."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess, sys
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01')
L=E/'launch01'
CANDIDATE='5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776'
REVIEW_HASHES={'prepared-manifest01.json':'41cacf060bbea75bf4455cb617a5f7b295d7d8c5f78079bb5553fbc0a90ed886','spec-review01.md':'9030581389e80f35927540bc516edc440718dbc5e349a0183fda5c0a7c2979a3','quality-review01.md':'4dc6612f3bb3661a763a39165fe8310d35c7f0789364f32a034b8f48b8c8cdfe'}
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
    for p in [L]+[E/n for n in ('authorization.json','query.claim','query.log','native-process.json','native-result.json','preservation-after.json')]:
        if p.exists() or p.is_symlink():raise RuntimeError('consumed/existing '+str(p))
    raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_w14_postfit_launch01_payload','-'])
    if hashlib.sha256(raw).hexdigest()!=sys.argv[1]:raise RuntimeError('payload hash')
    payload=json.loads(raw)
    if set(payload)!={'prepared-manifest01.json','spec-review01.md','quality-review01.md','parent-consumption01.json','ACCEPTANCE.md'}:raise RuntimeError('review payload scope')
    decoded={}
    for name,item in payload.items():
        data=base64.b64decode(item['base64'],validate=True)
        if hashlib.sha256(data).hexdigest()!=item['sha256']:raise RuntimeError('review bytes '+name)
        if name in REVIEW_HASHES and item['sha256']!=REVIEW_HASHES[name]:raise RuntimeError('review identity '+name)
        decoded[name]=data
    manifest=json.loads(decoded['prepared-manifest01.json'])
    for name,item in manifest.items():
        p=E/name
        if Path(name).name!=name or p.is_symlink() or not p.is_file() or p.stat().st_size!=item['bytes'] or sha(p)!=item['sha256']:raise RuntimeError('prepared drift '+name)
    if sha(E/'candidate.json')!=CANDIDATE:raise RuntimeError('candidate')
    r=json.loads((E/'candidate.json').read_text())
    if r['ready_for_build'] is not False or r['part']!='AGFB027R25A2E2V':raise RuntimeError('target/readiness')
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
    auth={'approved':True,'candidate_sha256':CANDIDATE,'permission':'exact-read-only-postfit-w14query01'}
    with (E/'authorization.json').open('x') as f:json.dump(auth,f,indent=2)
    if json.loads((E/'authorization.json').read_text())!=auth:raise RuntimeError('authorization readback')
    receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'pane':os.environ['TMUX_PANE'],'authorization_sha256':sha(E/'authorization.json'),'candidate_sha256':CANDIDATE,'reviews':{k:hashlib.sha256(v).hexdigest() for k,v in decoded.items()},'originals_unchanged_before_launch':True,'native_started_at_receipt':False,'runner_argv':r['runner']['argv'],'runner_cwd':r['runner']['cwd']}
    with (L/'issuance.json').open('x') as f:json.dump(receipt,f,indent=2)
    print('W14_QUERY_AUTHORIZATION_ISSUED',json.dumps(receipt),flush=True)
    os.chdir(E)
    os.execv('/usr/bin/python3',r['runner']['argv'])
if __name__=='__main__':main()
