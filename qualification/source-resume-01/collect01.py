#!/usr/bin/env python3
"""Ordinary source/config/module-file evidence only; never open hardware."""
import datetime, gzip, hashlib, json, os, socket, stat, subprocess
from pathlib import Path
B = Path('/home/uwb_student00/ahls/new_BSP')
BUFFER = 'ia840f_source_resume_01_batch01'
assert os.environ.get('TMUX') and socket.gethostname().lower() == 'agilex7workstation'
r = dict(batch=BUFFER, time=datetime.datetime.now().astimezone().isoformat(),
         pane=os.environ['TMUX_PANE'], pid=os.getpid(), files={}, commands={}, listings={})
def run(name, args):
    print('READ', name, flush=True)
    p = subprocess.run(args, capture_output=True, timeout=45, env=dict(os.environ, LC_ALL='C'))
    r['commands'][name] = dict(argv=args, rc=p.returncode, stdout=p.stdout.decode(errors='replace'), stderr=p.stderr.decode(errors='replace'))
    return p.stdout.decode(errors='replace').strip()
def take(p):
    p = Path(p)
    try:
        q = p.resolve(strict=True)
        assert not str(q).startswith(('/dev/', '/sys/', '/proc/')), q
        s = q.stat()
        assert stat.S_ISREG(s.st_mode), q
        assert s.st_size <= 2000000, (q, s.st_size)
        d = q.read_bytes()
        r['files'][str(p)] = dict(resolved=str(q), sha256=hashlib.sha256(d).hexdigest(), size=len(d), content=d.decode())
    except Exception as e:
        r['files'][str(p)] = dict(error=str(e))
def listing(p):
    p = Path(p)
    try:
        r['listings'][str(p)] = sorted(x.name for x in p.iterdir())
    except Exception as e: r['listings'][str(p)] = dict(error=str(e))
try:
    run('identity', ['uname','-a'])
    run('processes', ['ps','-eo','pid,ppid,stat,etime,args'])
    run('tmux', ['tmux','list-windows','-a','-F','#{session_name} #{window_id} #{window_name} #{pane_current_command}'])
    run('memory', ['free','-h'])
    run('disk', ['df','-h',str(B)])
    run('user', ['id'])
    run('groups', ['getent','group'])
    run('udev_version', ['udevadm','--version'])
    run('udev_help', ['udevadm','--help'])
    run('loaded_modules', ['lsmod'])
    for name in ['dfl_uart','dfl','dfl_pci','dfl_afu']:
        run('modinfo_'+name, ['modinfo', name])
    driver=Path('/home/uwb_student00/linux-dfl-backport')
    run('driver_commit', ['git','-C',str(driver),'rev-parse','HEAD'])
    run('driver_status', ['git','-C',str(driver),'status','--short'])
    listing(driver)
    for root in ['/etc/udev/rules.d','/usr/lib/udev/rules.d','/run/udev/rules.d']:
        listing(root)
        for p in sorted(Path(root).glob('*.rules')):
            if p.is_symlink(): continue
            d=p.read_text(errors='replace')
            if any(s in d.lower() for s in ['dfl','fpga','opae']):
                take(p)
                run('owner_'+p.name, ['rpm','-qf',str(p)])
    for p in driver.rglob('*'):
        if p.is_file() and p.suffix in ['.c','.h'] and (p.name in ['dfl.c','dfl.h','dfl-afu-main.c','dfl-afu.h'] or 'uart' in p.name): take(p)
    for root in [B, B/'work_ia840f_fim_13', B/'work_ahls_persona_01', B/'qualification', B/'afu', B/'src']:
        listing(root)
    for root in [B/'work_ia840f_fim_13',B/'ofs-agx7-pcie-attach']:
        u=root/'ofs-common/src/fpga_family/agilex/uart'
        for p in u.rglob('*'):
            if p.is_file() and p.suffix in ['.sv','.ini','.tcl','.ip']: take(p)
        for f in ['src/board/ia840f/top.sv','src/board/ia840f/fim_afu_instances.sv','syn/board/ia840f/syn_top/afu_with_pim/afu.tcl']:
            take(root/f)
    r['complete']=True
except Exception as e:
    r['complete']=False; r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode(); blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
