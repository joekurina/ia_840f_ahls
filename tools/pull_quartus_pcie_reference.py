"""Copy installed PCIe definition text through an authorized tmux pane only."""
import subprocess, shlex, json, base64, zlib, hashlib, time
from pathlib import Path
host='uwb_student00@100.101.227.97'
session='ia840f_ip_source_inspect'
out=Path(__file__).resolve().parents[1]/'reference/quartus-26.1.1-pcie'
def ssh(cmd):
    return subprocess.run(['ssh','-o','BatchMode=yes',host,cmd],check=True,capture_output=True,text=True).stdout
ssh('tmux set-option -g history-limit 100000')
# A new pane inherits the larger history limit; leave the original discovery pane intact.
ssh('tmux new-window -t '+session+' -n transfer')
code='''from pathlib import Path
import json,base64,zlib,hashlib
root=Path('/opt/altera/26.1.1/ip/altera/subsystems/intel_pcie_ss_axi/hwtcl')
records=[]
for p in sorted(root.rglob('*')):
 if p.is_file() and p.suffix in ('.tcl','.odip','.xml'):
  b=p.read_bytes()
  records.append(dict(path=str(p.relative_to(root)),source=str(p),size=len(b),sha256=hashlib.sha256(b).hexdigest(),data=base64.b64encode(b).decode()))
b=json.dumps(records).encode()
s=base64.b64encode(zlib.compress(b)).decode()
print('PCIE_DEFINITION_BEGIN')
for i in range(0,len(s),120): print(s[i:i+120])
print('PCIE_DEFINITION_END')
'''
cmd='python3 -c '+shlex.quote(code)
ssh('tmux send-keys -t '+session+':transfer '+shlex.quote(cmd)+' Enter')
# Bounded readback polling for this synchronous remote file-copy operation.
for attempt in range(60):
    text=ssh('tmux capture-pane -p -J -S - -t '+session+':transfer')
    rows=[x.rstrip() for x in text.splitlines()]
    if 'PCIE_DEFINITION_END' in rows: break
    time.sleep(1)
else: raise RuntimeError('No transfer completion marker')
a=rows.index('PCIE_DEFINITION_BEGIN'); b=rows.index('PCIE_DEFINITION_END',a+1)
records=json.loads(zlib.decompress(base64.b64decode(''.join(rows[a+1:b]),validate=True)))
out.mkdir(parents=True,exist_ok=True)
manifest=[]
for r in records:
    p=Path(r['path']); assert not p.is_absolute() and '..' not in p.parts
    data=base64.b64decode(r.pop('data'),validate=True)
    assert len(data)==r['size'] and hashlib.sha256(data).hexdigest()==r['sha256']
    dst=out/'hwtcl'/p; dst.parent.mkdir(parents=True,exist_ok=True)
    if dst.exists(): assert dst.read_bytes()==data
    else: dst.write_bytes(data)
    assert hashlib.sha256(dst.read_bytes()).hexdigest()==r['sha256']
    manifest.append(r)
receipt={'source_host':host,'source_root':'/opt/altera/26.1.1/ip/altera/subsystems/intel_pcie_ss_axi/hwtcl','transport':'tmux pane; compressed framed payload; per-file size and SHA256','vendor_tools_executed':False,'files':manifest}
(out/'manifest.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({'files_verified':len(manifest),'bytes':sum(r['size'] for r in manifest),'destination':str(out)}))
