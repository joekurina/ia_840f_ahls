#!/usr/bin/env python3
"""One no-project STA documentation capture, inside the owned tmux."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, resource, socket, subprocess, sys
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/api-help01')
PREFIX='ia840f_clock_repair_api_help01'
TOOLS={
 '/opt/altera/26.1.1/quartus/bin/quartus_sta':'06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14',
 '/opt/altera/26.1.1/quartus/linux64/quartus_sta':'d675f96e7dffe1f7c736dfe2a20e1d3f4e576a5a53f714a644d2082c00fd4fae'}
def main():
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX') or sys.flags.optimize:
        raise RuntimeError('wrong host/user/tmux/python')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':raise RuntimeError('session')
    for path,digest in TOOLS.items():
        if hashlib.sha256(Path(path).read_bytes()).hexdigest()!=digest:raise RuntimeError('STA identity')
    data=subprocess.check_output(['tmux','save-buffer','-b',PREFIX+'_input','-'])
    if hashlib.sha256(data).hexdigest()!=sys.argv[1]:raise RuntimeError('script hash')
    if E.exists() or E.is_symlink():raise RuntimeError('spent help directory')
    if any(p.strip().startswith(('quartus_','qsys-')) for p in subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()):raise RuntimeError('native tool busy')
    mem=dict(l.split(':',1) for l in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024<16000000000:raise RuntimeError('memory headroom')
    E.mkdir(parents=True)
    (E/'help.tcl').write_bytes(data)
    env={k:v for k,v in os.environ.items() if not k.startswith('OFS_') and k not in ('QUARTUS_ROOTDIR_OVERRIDE','PYTHONOPTIMIZE','PYTHONPATH')}
    env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/usr/bin:/bin')
    resource.setrlimit(resource.RLIMIT_AS,(8*1024**3,8*1024**3));os.nice(10)
    argv=['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(E/'help.tcl')]
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    with (E/'help.log').open('x') as log:
        p=subprocess.Popen(argv,cwd=E,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        rc=p.wait()
    status={'native_rc':rc,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'pid':p.pid,'argv':argv,'cwd':str(E),'pane':os.environ['TMUX_PANE'],'tools':TOOLS,'scope':'documentation only; no project/netlist/constraint evaluation/hardware','script_sha256':hashlib.sha256(data).hexdigest()}
    with (E/'result.json').open('x') as f:json.dump(status,f,indent=2)
    exports={}
    for name in ('help.tcl','help.log','result.json'):
        b=(E/name).read_bytes();exports[name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
    blob=gzip.compress(json.dumps({'batch':PREFIX+'_result','files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b',PREFIX+'_result','-'],input=blob,check=True)
    print('API_HELP01_RESULT',rc,'EXPORT_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
    return rc if rc>=0 else 128-rc
if __name__=='__main__':sys.exit(main())
