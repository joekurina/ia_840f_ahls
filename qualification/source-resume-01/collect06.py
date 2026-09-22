#!/usr/bin/env python3
"""OPAE backend source/config collection, never dlopen or execute OPAE."""
import base64,datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
O=Path('/home/uwb_student00/opae-sdk');BUFFER='ia840f_source_resume_01_batch06'
assert os.environ.get('TMUX') and socket.gethostname().lower()=='agilex7workstation'
r:dict=dict(batch=BUFFER,time=datetime.datetime.now().astimezone().isoformat(),pane=os.environ['TMUX_PANE'],pid=os.getpid(),files={},commands={},inventory={})
def take(p,content=True):
    p=Path(p)
    try:
        q=p.resolve(strict=True);assert not str(q).startswith(('/dev/','/sys/','/proc/'));s=q.stat();assert stat.S_ISREG(s.st_mode)
        h=hashlib.sha256()
        with q.open('rb') as f:
            for c in iter(lambda:f.read(1048576),b''):h.update(c)
        v=dict(resolved=str(q),size=s.st_size,sha256=h.hexdigest())
        if content:
            assert s.st_size<2000000;v['base64']=base64.b64encode(q.read_bytes()).decode()
        r['files'][str(p)]=v
    except Exception as e:r['files'][str(p)]=dict(error=str(e))
def run(name,args):
    p=subprocess.run(args,capture_output=True,timeout=40);r['commands'][name]=dict(argv=args,rc=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace'));return p.stdout.decode(errors='replace')
try:
    for f in ['libraries/libopae-c/cfg-file.c','libraries/libopae-c/cfg-file.h','libraries/plugins/vfio/dfl.c','libraries/plugins/vfio/dfl.h']:
        take(O/f)
    for f in ['/usr/lib64/opae/libopae-v.so','/usr/lib64/opae/libxfpga.so','/usr/lib64/opae/libopae-u.so']:
        take(f,False)
    for p in (O/'build').rglob('libxfpga.so*'):take(p,False)
    for p in (O/'build').rglob('libopae-v.so*'):take(p,False)
    for p in (O/'build').rglob('libopae-u.so*'):take(p,False)
    for f in ['/home/uwb_student00/.opae.cfg','/home/uwb_student00/.config/opae/opae.cfg']:
        take(f)
    run('native_link',['readelf','-d','/home/uwb_student00/ahls/new_BSP/qualification/ahls-host-offline-01/native-compile-01/build/ahls_opae_qualification'])
    # Hash-read the exact native result/artifact again without executing it.
    take('/home/uwb_student00/ahls/new_BSP/qualification/ahls-host-offline-01/native-compile-01/result.json')
    take('/home/uwb_student00/ahls/new_BSP/qualification/ahls-host-offline-01/native-compile-01/build/ahls_opae_qualification',False)
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
