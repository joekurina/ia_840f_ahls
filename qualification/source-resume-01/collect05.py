#!/usr/bin/env python3
"""OPAE backend source/config collection, never dlopen or execute OPAE."""
import base64,datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
O=Path('/home/uwb_student00/opae-sdk');BUFFER='ia840f_source_resume_01_batch05'
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
    take(O/'build/install_manifest.txt')
    run('source_status',['git','-C',str(O),'status','--short'])
    files=run('source_files',['git','-C',str(O),'ls-files']).splitlines()
    selected=[]
    for f in files:
        name=Path(f).name
        if f.startswith(('libraries/plugins/','libraries/libopae-c/','libraries/libopaevfio/','libraries/libopaeuio/')) and name.endswith(('.c','.cpp','.h','.json')) and any(x in name.lower() for x in ['enum','plugin','token','config','feature','discovery','opae','vfio']):
            selected.append(f);take(O/f)
    r['inventory']['selected']=selected
    for root in ['/usr/share/opae','/usr/lib64/opae','/etc/opae','/home/uwb_student00/.config/opae']:
        p=Path(root)
        if p.exists():
            r['inventory'][root]=[str(x) for x in p.rglob('*') if x.is_file()]
            for x in p.rglob('*'):
                if x.is_file() and x.suffix in ['.json','.cfg']:take(x)
    for p in (O/'build').rglob('libopae*.so*'):
        if p.is_file():take(p,False)
    for pattern in ['libopae*.so*','libxfpga*.so*']:
        for p in Path('/usr/lib64').glob(pattern):
            if p.is_file():take(p,False)
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
