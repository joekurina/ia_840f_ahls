#!/usr/bin/env python3
"""Prepare a preserved-copy Work17 query. No vendor invocation or authorization."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess, sys, traceback
from typing import Any
B=Path('/home/uwb_student00/ahls/new_BSP')
W=B/'work_ia840f_fim_17';S=B/'ofs-agx7-pcie-attach';P=B/'ofs-platform-afu-bbb'
E=B/'qualification/fim-build-17/retiming-eligibility01'
BATCH='ia840f_w17retimeelig01_preparation01'
OWNED=False

def sha(p):
    h=hashlib.sha256()
    with open(p,'rb') as f:
        for chunk in iter(lambda:f.read(4194304),b''):h.update(chunk)
    return h.hexdigest()

def inv(root, allowed_link_roots=()):
    values={}
    for folder,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(folder)/name;rel=str(p.relative_to(root))
            if p.is_symlink():
                if not any(p.resolve().is_relative_to(r) for r in (root,*allowed_link_roots)):raise RuntimeError('escaping donor link '+str(p))
                values[rel]={'link':os.readlink(p)}
            elif p.is_file():values[rel]={'sha256':sha(p)}
    return values

def put(name,obj):
    with (E/name).open('x') as f:json.dump(obj,f,indent=2,sort_keys=True)

def main():
    global OWNED
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:
        raise RuntimeError('wrong host/user/session/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':raise RuntimeError('wrong tmux session')
    payload=subprocess.check_output(['tmux','save-buffer','-b','ia840f_w17retimeelig01_inputs01','-'])
    if hashlib.sha256(payload).hexdigest()!=sys.argv[1]:raise RuntimeError('payload digest')
    inputs=json.loads(payload)
    if set(inputs)!= {'query.tcl','run-query.py','ia840f_w17retimeelig01_gate.py','AUTHORITY.md','baseline.json.gz'}:raise RuntimeError('payload scope')
    if E.exists() or E.is_symlink():raise RuntimeError('attempt already exists')
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024<80000000000 or shutil.disk_usage(B).free<20000000000:raise RuntimeError('headroom')
    if any(x.strip().startswith(('quartus_','qsys-')) for x in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('native tool busy')
    if sha(B/'qualification/fim-build-17/compile-authorization.json')!='22cf3d1428e9a6de430bcad40f477374cf9e25a3a1de22f4b444306c701cbcce':raise RuntimeError('Work17 authorization identity')
    for rel,digest in {'syn/board/ia840f/syn_top/output_files/ofs_top.sta.rpt':'c476ad6df2779530328d4d1326b5d2cb7ab9381522ab3f9e318d401420c4ac27','syn/board/ia840f/syn_top/output_files/ofs_top.fit.rpt':'2a29087fa7aeb784fb479234122a738d8e152daa1c89cb2cc4a11c17a106a7f2'}.items():
        if sha(W/rel)!=digest:raise RuntimeError('Work17 result drift '+rel)
    before={str(root):inv(root) for root in (W,S,P)}
    baseline_bytes=base64.b64decode(inputs['baseline.json.gz']['base64'],validate=True)
    if hashlib.sha256(baseline_bytes).hexdigest()!=inputs['baseline.json.gz']['sha256']:raise RuntimeError('baseline payload mismatch')
    if before!=json.loads(gzip.decompress(baseline_bytes))['originals']:raise RuntimeError('postflight original inventory drift')
    E.mkdir(parents=True, exist_ok=False)
    OWNED=True
    (E/'preservation.json.gz').write_bytes(gzip.compress(json.dumps(before,sort_keys=True).encode(),mtime=0))
    (E/'prepare01.py').write_bytes(subprocess.check_output(['tmux','save-buffer','-b','ia840f_w17retimeelig01_prepare01_script','-']))
    for name,v in inputs.items():
        data=base64.b64decode(v['base64'])
        if hashlib.sha256(data).hexdigest()!=v['sha256']:raise RuntimeError('input hash')
        (E/name).write_bytes(data)
    for original,name in ((W,'scratch'),(P,'pim')):
        subprocess.run(['cp','-a','--reflink=auto',str(original),str(E/name)],check=True)
        if inv(E/name,(original,))!=before[str(original)]:raise RuntimeError('copy mismatch '+name)
    replacements=[(str(W),str(E/'scratch')),(str(S),str(E/'scratch')),(str(P),str(E/'pim'))]
    changes=[]
    for name in ('scratch','pim'):
        root=E/name
        for folder,dirs,files in os.walk(root,followlinks=False):
            for leaf in dirs+files:
                p=Path(folder)/leaf
                if p.is_symlink():
                    old=os.readlink(p);new=old
                    for a,b in replacements:new=new.replace(a,b)
                    if old!=new:p.unlink();p.symlink_to(new);changes.append({'path':str(p),'old_link':old,'new_link':new})
                elif p.is_file() and p.suffix in {'.tcl','.qsf','.qip','.ip','.qsys','.xml','.sdc','.json','.sh','.py','.txt','.ini'}:
                    raw=p.read_bytes();new=raw
                    if b'\0' not in raw:
                        for a,b in replacements:new=new.replace(a.encode(),b.encode())
                        if raw!=new:
                            p.write_bytes(new);changes.append({'path':str(p),'old_sha256':hashlib.sha256(raw).hexdigest(),'new_sha256':sha(p)})
    top=E/'scratch/syn/shared_config/top.sdc'
    raw=top.read_bytes()
    if hashlib.sha256(raw).hexdigest()!='3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814':raise RuntimeError('original top.sdc identity')
    delta={'variant':'baseline','before_sha256':sha(top),'exception_statements_unchanged':True}
    delta['after_sha256']=sha(top)
    put('constraint-delta.json',delta)
    shutil.copy2(top,E/'top.sdc')
    g=E/'scratch/ofs-common/tools/ofss_config';dispatcher=g/'ia840f_experimental_gate.py'
    text=dispatcher.read_text();anchor='def main():\n    try:\n'
    if text.count(anchor)!=1:raise RuntimeError('dispatcher insertion anchor')
    addition=f"        if sys.argv[1:] == ['quartus'] and Path.cwd() == Path({str(E/'scratch/syn/board/ia840f/syn_top')!r}):\n            import ia840f_w17retimeelig01_gate\n            ia840f_w17retimeelig01_gate.validate(runtime=True)\n            return 0\n"
    dispatcher.write_text(text.replace(anchor,anchor+addition))
    shutil.copy2(E/'ia840f_w17retimeelig01_gate.py',g/'ia840f_w17retimeelig01_gate.py')
    shutil.copy2(dispatcher,E/'ia840f_experimental_gate.py')
    inventory={};links={}
    for name in ('scratch','pim'):
        for rel,v in inv(E/name).items():
            absolute=str(E/name/rel)
            if 'link' in v:links[absolute]=v['link']
            else:inventory[absolute]=v['sha256']
    for f in [E/n for n in ('query.tcl','run-query.py','ia840f_w17retimeelig01_gate.py','AUTHORITY.md','baseline.json.gz','constraint-delta.json','top.sdc','preservation.json.gz')]+[Path('/opt/altera/26.1.1/quartus/bin/quartus_sta'),Path('/opt/altera/26.1.1/quartus/linux64/quartus_sta')]:inventory[str(f)]=sha(f)
    r: dict[str,Any]=dict(schema=1,approved=False,ready_for_build=False,target='ia840f',part='AGFB027R25A2E2V',permission='exact-offline-w17retimeelig01',database_origin=str(W),argv=['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(E/'query.tcl')],runtime_argv=['quartus_sta','-t',str(E/'query.tcl')],executable='/opt/altera/26.1.1/quartus/linux64/quartus_sta',cwd=str(E/'scratch/syn/board/ia840f/syn_top'),runner=dict(exe=str(Path(sys.executable).resolve()),argv=['python3','-B',str(E/'run-query.py')],cwd=str(E)),files=inventory,callback_files={p:h for p,h in inventory.items() if Path(p).suffix not in {'.qpf','.rpt','.log','.summary'}},links=links)
    put('candidate.json',r)
    checks: dict[str,Any]={}
    for label,args,cwd in [('runner',['python3','-B',str(E/'run-query.py')],E),('dispatcher',['python3','-B',str(dispatcher),'quartus'],Path(r['cwd']))]:
        v=subprocess.run(args,cwd=cwd,capture_output=True,text=True)
        if v.returncode!=1 or 'missing reviewed authorization' not in v.stderr:raise RuntimeError('inert missing-authorization check '+label+repr(v))
        checks[label]=dict(rc=v.returncode,stderr=v.stderr)
    if (E/'query.claim').exists() or (E/'query.log').exists():raise RuntimeError('unexpected native artifacts')
    for root,expected in before.items():
        if inv(Path(root))!=expected:raise RuntimeError('donor changed '+root)
    checks.update(donors_unchanged=True,copies_initially_hash_identical=True,vendor_launched=False,authorization_issued=False,pane=os.environ['TMUX_PANE'],time=datetime.datetime.now(datetime.timezone.utc).isoformat())
    put('tests.json',checks);put('path-relocations.json',changes)
    exports={}
    for name in ('candidate.json','tests.json','path-relocations.json','query.tcl','run-query.py','ia840f_w17retimeelig01_gate.py','ia840f_experimental_gate.py','prepare01.py','AUTHORITY.md','baseline.json.gz','constraint-delta.json','top.sdc','preservation.json.gz'):
        data=(E/name).read_bytes();exports[name]={'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps({'batch':BATCH,'files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
    print('PREPARATION_COMPLETE',hashlib.sha256(blob).hexdigest(),flush=True)

if __name__=='__main__':
    try:main()
    except Exception as exc:
        if OWNED and E.is_dir() and not (E/'preparation-error.json').exists():put('preparation-error.json',{'error':repr(exc),'traceback':traceback.format_exc()})
        raise
