import subprocess, shlex, json, gzip, hashlib, base64, sys
from pathlib import Path
assert __debug__
E=Path('/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ahls-persona-work21-caps01')
name='ia840f_persona_caps01_asm01'
def tmux(args, timeout=120):
    p=subprocess.run(['ssh','-o','BatchMode=yes','-o','ConnectTimeout=15','-o','ServerAliveInterval=30','-o','ServerAliveCountMax=2','uwb_student00@100.101.227.97',shlex.join(['tmux',*args])],capture_output=True,timeout=timeout)
    if p.returncode: raise RuntimeError((p.returncode,p.stderr.decode(errors='replace')))
    return p.stdout
print('Collecting the existing raw-capability native assembler. No new build or hardware access.',flush=True)
tmux(['wait-for',name+'_done'],timeout=2100)
rc=int(tmux(['save-buffer','-b',name+'_outer','-']))
blob=tmux(['save-buffer','-b',name,'-']);h=tmux(['save-buffer','-b',name+'_sha256','-']).decode().strip()
assert hashlib.sha256(blob).hexdigest()==h
r=json.loads(gzip.decompress(blob));assert r['run']=='caps01-asm01'
with (E/'result-asm01.json.gz').open('xb') as f: f.write(blob)
with (E/'outer-asm01.json').open('x') as f: json.dump({'outer_rc':rc,'archive_sha256':h,'bytes':len(blob)},f,indent=2);f.write('\n')
for n,e in r['files'].items():
    p=Path(n);assert not p.is_absolute() and '..' not in p.parts
    b=base64.b64decode(e['base64'],validate=True)
    assert len(b)==e['bytes'] and hashlib.sha256(b).hexdigest()==e['sha256']
    p=E/'artifacts-asm01'/p;p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f:f.write(b)
print(json.dumps({'outer_rc':rc,'success':r.get('success'),'error':r.get('error'),'archive_sha256':h,'members':len(r['files']),'commands':r['commands'],'diagnostics':r.get('diagnostics'),'postflight_errors':r.get('postflight_errors'),'preservation':{k:v for k,v in r.items() if k.endswith('_unchanged')}},indent=2),flush=True)
sys.exit(rc)
