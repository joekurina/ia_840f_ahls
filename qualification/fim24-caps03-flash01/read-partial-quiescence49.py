"""Ordinary PCI/process readback of partial quiescence; no retry/card commands."""
import base64,gzip,hashlib,json,os,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');W=ROOT/'partial-quiescence49';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'ordinary full PCI inventory/retained ownership only after stopped partial operation','success':False,'hardware_access':False,'exports':{}}
try:
    assert os.environ.get('TMUX') and not W.exists();W.mkdir(exist_ok=False)
    before=json.loads((ROOT/'quiesce48/result.json').read_text());names=sorted(p.name for p in Path('/sys/bus/pci/devices').iterdir());out['pci_names']=names
    out['removed_since_original']=sorted(set(before['pci_before'])-set(names));out['added_since_original']=sorted(set(names)-set(before['pci_before']))
    root=Path('/sys/bus/pci/devices/0000:4e:00.0');out['root_present']=root.exists()
    resolved=root.resolve(strict=True);out['root_descendants']=sorted(p.name for p in Path('/sys/bus/pci/devices').iterdir() if resolved in p.resolve().parents)
    z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(ROOT/'activation-pre43/runtime/ownership27.py')],capture_output=True,timeout=60);assert z.returncode==0,z.stderr.decode(errors='replace');out['ownership']=json.loads(z.stdout)
    out['success']=True
    raw=json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2).encode()
    with (W/'readback.json').open('xb') as stream:stream.write(raw)
    out['exports']['readback.json']={'source':str(W/'readback.json'),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'base64':base64.b64encode(raw).decode()}
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'removed':out.get('removed_since_original')}),flush=True)
if not out['success']:raise SystemExit(1)
