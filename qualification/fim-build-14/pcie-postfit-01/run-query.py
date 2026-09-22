#!/usr/bin/env python3
"""Persistent, single-use ordinary-file STA query; no FPGA operations."""
from pathlib import Path
import base64, datetime, gzip, hashlib, json, os, resource, socket, subprocess, sys
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01')
sys.dont_write_bytecode=True
sys.path.insert(0,str(E/'scratch/ofs-common/tools/ofss_config'))
from ia840f_w14query01_gate import validate,identity

def inventory(root):
    answer={}
    for folder,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(folder)/name;rel=str(p.relative_to(root))
            if p.is_symlink():answer[rel]={'link':os.readlink(p)}
            elif p.is_file():
                h=hashlib.sha256()
                with p.open('rb') as f:
                    for block in iter(lambda:f.read(4194304),b''):h.update(block)
                answer[rel]={'sha256':h.hexdigest()}
    return answer

def main():
    if socket.gethostname()!='Agilex7Workstation' or os.getuid()!=1000 or not os.environ.get('TMUX'):
        raise RuntimeError('wrong host/user/tmux')
    if subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()!='ia840f_mailbox_monitored_01':
        raise RuntimeError('wrong owned session')
    r=validate(runtime=False)
    claim=identity(os.getpid())
    if any(claim[k]!=r['runner'][k] for k in ('exe','argv','cwd')):raise ValueError('runner context')
    mem=dict(line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())
    if int(mem['MemAvailable'].split()[0])*1024 < 80000000000:raise RuntimeError('insufficient RAM headroom')
    ps=subprocess.check_output(['ps','-eo','comm='],text=True).splitlines()
    if any(x.strip().startswith(('quartus_','qsys-')) for x in ps):raise RuntimeError('competing native tool')
    with (E/'query.claim').open('x') as f:json.dump(claim,f)
    env={k:v for k,v in os.environ.items() if k not in ('PYTHONOPTIMIZE','PYTHONPATH','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL_PRINTED') and not k.startswith('OFS_')}
    env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',PYTHONDONTWRITEBYTECODE='1',OFS_ROOTDIR=str(E/'scratch'),OFS_PLATFORM_AFU_BBB=str(E/'pim'))
    for key in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'):env[key]='/home/uwb_student00/quartus_26/LR-191011_License.dat'
    # Leave substantial host memory headroom; finite Tcl query, no timeout/retry.
    resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3))
    os.nice(10)
    start=datetime.datetime.now(datetime.timezone.utc).isoformat()
    with (E/'query.log').open('x') as f:
        child=subprocess.Popen(r['argv'],cwd=r['cwd'],env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
        with (E/'native-process.json').open('x') as out:json.dump({'pid':child.pid,'start':start,'argv':r['argv'],'cwd':r['cwd']},out)
        rc=child.wait()
    status={'native_rc':rc,'start':start,'end':datetime.datetime.now(datetime.timezone.utc).isoformat(),'acceptance':'PENDING LOG AND INDEPENDENT REVIEW','hardware_access':False}
    with (E/'native-result.json').open('x') as f:json.dump(status,f,indent=2)
    baseline=json.loads(gzip.decompress((E/'preservation.json.gz').read_bytes()))
    post={root:inventory(Path(root))==expected for root,expected in baseline.items()}
    with (E/'preservation-after.json').open('x') as f:json.dump(post,f,indent=2)
    exports={}
    for name in ('query.log','native-result.json','query.claim','native-process.json','preservation-after.json'):
        data=(E/name).read_bytes();exports[name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps({'batch':'ia840f_w14_postfit_result01','files':exports},sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b','ia840f_w14_postfit_result01','-'],input=blob,check=True)
    print('W14_QUERY_RESULT',rc,'EXPORT_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
    if not all(post.values()):return 1
    return rc if rc>=0 else 128-rc

if __name__=='__main__':
    sys.exit(main())
