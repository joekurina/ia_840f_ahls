#!/usr/bin/env python3
"""Prepare a preserved-copy Work14 query. No vendor invocation or authorization."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess, sys, traceback
from typing import Any
B=Path('/home/uwb_student00/ahls/new_BSP')
W=B/'work_ia840f_fim_15';S=B/'ofs-agx7-pcie-attach';P=B/'ofs-platform-afu-bbb'
E=B/'qualification/emif-hold-objective-01/plan-diagnostic03'
BATCH='ia840f_emif_plan03_preparation02'
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

def native_output(path):
    prefix=str(E/'scratch/syn/board/ia840f/syn_top/qdb/_compiler/ofs_top')+'/'
    if not path.startswith(prefix):return False
    parts=path[len(prefix):].split('/')
    return len(parts)>=4 and parts[0] in {'_flat','root_partition','green_region','auto_fab_0','auto_fab_1'} and parts[1]=='26.1.1' and parts[2] in {'_all','final','legacy','placed','planned','retimed','routed'}

def main():
    global OWNED
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:
        raise RuntimeError('wrong host/user/session/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':raise RuntimeError('wrong tmux session')
    payload=subprocess.check_output(['tmux','save-buffer','-b','ia840f_emif_plan03_inputs02','-'])
    if hashlib.sha256(payload).hexdigest()!=sys.argv[1]:raise RuntimeError('payload digest')
    inputs=json.loads(payload)
    if set(inputs)!=set(['run-query.py', 'ia840f_emif_plan03_gate.py', 'AUTHORITY.md', 'diagnostic.tcl', 'insertion.tcl', 'baseline.json.gz']):raise RuntimeError('payload scope')
    if E.exists() or E.is_symlink():raise RuntimeError('attempt already exists')
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024<80000000000 or shutil.disk_usage(B).free<20000000000:raise RuntimeError('headroom')
    if any(x.strip().startswith(('quartus_','qsys-')) for x in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('native tool busy')
    for rel,digest in {'output_files/ofs_top.sta.rpt': 'e38b1fbfae9afe8efdb3602165c9ec475a7898301172eeff47825742956778d9', 'output_files/ofs_top.fit.rpt': 'a763725d71b02c4fb5687a5e5818e2714ed75ad2c21a0a5b6e6b99c742288aa3'}.items():
        if sha(W/'syn/board/ia840f/syn_top'/rel)!=digest:raise RuntimeError('Work15 result drift '+rel)
    baseline_bytes=base64.b64decode(inputs['baseline.json.gz']['base64'],validate=True)
    if hashlib.sha256(baseline_bytes).hexdigest()!=inputs['baseline.json.gz']['sha256']:raise RuntimeError('baseline hash')
    recorded=json.loads(gzip.decompress(baseline_bytes))
    before={str(root):inv(root) for root in (W,S,P)}
    for root,expected in recorded['originals'].items():
        if before[root]!=expected:raise RuntimeError('accepted original drift '+root)
    for rel,expected in recorded['work_inputs'].items():
        measured_expected={'link':expected['symlink']} if set(expected)=={'symlink'} else expected
        if before[str(W)].get(rel)!=measured_expected:raise RuntimeError('Work15 input drift '+rel)
    E.mkdir(parents=True, exist_ok=False)
    OWNED=True
    (E/'preservation.json.gz').write_bytes(gzip.compress(json.dumps(before,sort_keys=True).encode(),mtime=0))
    (E/'prepare02.py').write_bytes(subprocess.check_output(['tmux','save-buffer','-b','ia840f_emif_plan03_prepare02_script','-']))
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
    if sha(top)!='b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc':raise RuntimeError('accepted PCIe SDC drift')
    sdc=E/'scratch'/'ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra.sdc'
    raw=sdc.read_bytes()
    if hashlib.sha256(raw).hexdigest()!='a265f9ef00b8fecbf865cb534badae68b490e0bae75fe474b4522f01caffb095':raise RuntimeError('exact generated EMIF1 source')
    anchor=b'                  set_clock_uncertainty -from [get_clocks $local_core_clock] -to   [get_clocks [set local_phy_clk_l_${i_phy_clock}]] -suppress_warnings -hold  {*}$add_to_derived $c2p_h\n'
    addition=(E/'insertion.tcl').read_bytes()
    if raw.count(anchor)!=1:raise RuntimeError('setter insertion anchor')
    modified=raw.replace(anchor,anchor+addition)
    if modified.replace(anchor+addition,anchor)!=raw:raise RuntimeError('constraint modification beyond diagnostic')
    sdc.write_bytes(modified)
    put('diagnostic-delta.json',{'source':str(sdc),'before_sha256':hashlib.sha256(raw).hexdigest(),'after_sha256':sha(sdc),'insertion_sha256':sha(E/'insertion.tcl'),'setters_exceptions_unchanged':True,'scope':'logging and documented bounded callback only'})
    shutil.copy2(sdc,E/'instrumented.sdc')
    shutil.copy2(top,E/'top.sdc')
    g=E/'scratch/ofs-common/tools/ofss_config';dispatcher=g/'ia840f_experimental_gate.py'
    text=dispatcher.read_text();anchor='def main():\n    try:\n'
    if text.count(anchor)!=1:raise RuntimeError('dispatcher insertion anchor')
    addition=f"        if sys.argv[1:] == ['quartus'] and Path.cwd() == Path({str(E/'scratch/syn/board/ia840f/syn_top')!r}):\n            import ia840f_emif_plan03_gate\n            ia840f_emif_plan03_gate.validate(runtime=True)\n            return 0\n"
    dispatcher.write_text(text.replace(anchor,anchor+addition))
    shutil.copy2(E/'ia840f_emif_plan03_gate.py',g/'ia840f_emif_plan03_gate.py')
    shutil.copy2(dispatcher,E/'ia840f_experimental_gate.py')
    inventory={};links={}
    for name in ('scratch','pim'):
        for rel,v in inv(E/name).items():
            absolute=str(E/name/rel)
            if 'link' in v:links[absolute]=v['link']
            else:inventory[absolute]=v['sha256']
    for f in [E/n for n in ['run-query.py', 'ia840f_emif_plan03_gate.py', 'AUTHORITY.md', 'diagnostic.tcl', 'insertion.tcl', 'baseline.json.gz', 'diagnostic-delta.json', 'top.sdc', 'preservation.json.gz', 'instrumented.sdc']]+[Path('/opt/altera/26.1.1/quartus/bin/quartus_fit'),Path('/opt/altera/26.1.1/quartus/linux64/quartus_fit')]:inventory[str(f)]=sha(f)
    r: dict[str,Any]=dict(schema=1,approved=False,ready_for_build=False,target='ia840f',part='AGFB027R25A2E2V',permission='exact-offline-emif-plan03',database_origin=str(W),argv=['/opt/altera/26.1.1/quartus/bin/quartus_fit', '--plan', '--read_settings_files=on', '--write_settings_files=off', 'ofs_top', '-c', 'ofs_top'],runtime_argv=['quartus_fit', '--plan', '--read_settings_files=on', '--write_settings_files=off', 'ofs_top', '-c', 'ofs_top'],executable='/opt/altera/26.1.1/quartus/linux64/quartus_fit',cwd=str(E/'scratch/syn/board/ia840f/syn_top'),runner=dict(exe=str(Path(sys.executable).resolve()),argv=['python3','-B',str(E/'run-query.py')],cwd=str(E)),files=inventory,callback_files={p:h for p,h in inventory.items() if Path(p).suffix not in {'.qpf','.rpt','.log','.summary'} and not native_output(p)},links=links)
    put('callback-output-exclusions.json',{p:h for p,h in inventory.items() if native_output(p)})
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
    for name in ['callback-output-exclusions.json','candidate.json', 'tests.json', 'path-relocations.json', 'ia840f_experimental_gate.py', 'prepare02.py', 'run-query.py', 'ia840f_emif_plan03_gate.py', 'AUTHORITY.md', 'diagnostic.tcl', 'insertion.tcl', 'baseline.json.gz', 'diagnostic-delta.json', 'top.sdc', 'preservation.json.gz', 'instrumented.sdc']:
        data=(E/name).read_bytes();exports[name]={'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps({'batch':BATCH,'files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
    print('PREPARATION_COMPLETE',hashlib.sha256(blob).hexdigest(),flush=True)

if __name__=='__main__':
    try:main()
    except Exception as exc:
        if OWNED and E.is_dir() and not (E/'preparation-error.json').exists():put('preparation-error.json',{'error':repr(exc),'traceback':traceback.format_exc()})
        raise
