"""Recover existing PFG topic bytes after collector banner rejection; no native rerun."""
import base64,gzip,hashlib,json,os,subprocess,sys,traceback
from pathlib import Path
H=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/help02');BATCH=sys.argv[1];PINS={'/opt/altera/26.1.1/quartus/bin/quartus_pfg': {'bytes': 2448, 'real': '/opt/altera/26.1.1/quartus/bin/quartus_pfg', 'sha256': '06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14'}, '/opt/altera/26.1.1/quartus/linux64/quartus_pfg': {'bytes': 745600, 'real': '/opt/altera/26.1.1/quartus/linux64/quartus_pfg', 'sha256': 'e9b5587f7308bdc245bfea0bd5d6d135f47b96faba006798b95b8e5a371ca3b1'}}
out={'batch':BATCH,'scope':'ordinary-file recovery of completed help02 log; no native/card action','success':False,'hardware_access':False,'native_rerun':False,'exports':{}}
try:
    assert os.environ.get('TMUX')
    record=json.loads((H/'result.json').read_text());assert record['native_rc']==0 and record['timeout'] is False and record['success'] is False
    for p,v in PINS.items():assert Path(p).stat().st_size==v['bytes'] and hashlib.sha256(Path(p).read_bytes()).hexdigest()==v['sha256'] and str(Path(p).resolve())==v['real']
    for n in ['help.log','result.json']:
        p=H/n;before=p.stat();assert 0<before.st_size<=2*1024**2
        b=p.read_bytes();after=p.stat();assert len(b)==before.st_size==after.st_size and before.st_mtime_ns==after.st_mtime_ns
        out['exports'][n]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
    out.update(success=True,current_tools_unchanged=True,original_native_rc=record['native_rc'],original_success=record['success'])
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'native_rerun':False}),flush=True)
if not out['success']:raise SystemExit(1)
