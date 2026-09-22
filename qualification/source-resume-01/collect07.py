#!/usr/bin/env python3
"""OPAE backend source/config collection, never dlopen or execute OPAE."""
import base64,datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
O=Path('/home/uwb_student00/opae-sdk');BUFFER='ia840f_source_resume_01_batch07'
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
    import struct
    r['inventory']['config_environment']={k:os.environ.get(k) for k in ['LIBOPAE_CFGFILE','LIBOPAE_PLUGIN_PATH','HOME']}
    for f in ['/home/uwb_student00/.local/opae.cfg','/home/uwb_student00/.local/opae/opae.cfg','/usr/local/etc/opae/opae.cfg']:
        take(f)
    if os.environ.get('LIBOPAE_CFGFILE'):take(os.environ['LIBOPAE_CFGFILE'])
    r['inventory']['elf_sections']={}
    for f in ['/usr/lib64/opae/libopae-v.so',str(O/'build/lib/libopae-v.so'),'/usr/lib64/opae/libxfpga.so',str(O/'build/lib/libxfpga.so')]:
        p=Path(f);data=p.read_bytes();hdr=struct.unpack_from('<16sHHIQQQIHHHHHH',data)
        assert hdr[0][:6]==b'\x7fELF\x02\x01'
        sections=[struct.unpack_from('<IIQQQQIIQQ',data,hdr[6]+i*hdr[11]) for i in range(hdr[12])]
        st=sections[hdr[13]];names=data[st[4]:st[4]+st[5]];out={}
        for sec in sections:
            name=names[sec[0]:].split(b'\0',1)[0].decode()
            if name in ['.text','.rodata','.note.gnu.build-id']:
                raw=data[sec[4]:sec[4]+sec[5]];out[name]=dict(size=len(raw),sha256=hashlib.sha256(raw).hexdigest())
        r['inventory']['elf_sections'][f]=out
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
