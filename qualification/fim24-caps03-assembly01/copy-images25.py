"""Transfer three completed assembly images byte-for-byte; no native/card action."""
import base64,gzip,hashlib,json,os,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');R=ROOT/'asm01';J=ROOT/'base01/build/syn/board/ia840f/syn_top';BATCH=sys.argv[1]
IMAGES={'output_files/ofs_pr_afu.sof': {'bytes': 10067421, 'sha256': '00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f'}, 'output_files/ofs_pr_afu.green_region.pmsf': {'bytes': 9409866, 'sha256': '598bd9e969feffb95653fd0ffef246362257a3605a32098cfe64bdbbe70f023e'}, 'output_files/ofs_pr_afu.green_region.rbf': {'bytes': 10100736, 'sha256': '9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a'}};RESULT_SHA='d8a03af543af01c422af7adac8fdc50a709fa8df4a9e6e68d058157f93760f1c'
out={'batch':BATCH,'scope':'ordinary-file transfer of existing completed assembly images only; no native/hardware','success':False,'hardware_access':False,'exports':{}}
try:
    assert os.environ.get('TMUX') and hashlib.sha256((R/'result.json').read_bytes()).hexdigest()==RESULT_SHA
    result=json.loads((R/'result.json').read_text());assert result['execution_clean'] is True and result['programming_images']==IMAGES
    total=0
    for name,entry in IMAGES.items():
        path=J/name;before=path.stat();total+=before.st_size;assert total<=64*1024**2 and before.st_size==entry['bytes']<=16*1024**2 and not path.is_symlink()
        data=path.read_bytes();after=path.stat();assert len(data)==before.st_size==after.st_size and before.st_mtime_ns==after.st_mtime_ns and hashlib.sha256(data).hexdigest()==entry['sha256']
        out['exports'][name]={'source':str(path),'bytes':len(data),'sha256':entry['sha256'],'base64':base64.b64encode(data).decode()}
    assert len(out['exports'])==3
    out.update(success=True,verified_image_count=3,total_image_bytes=total,assembly_result_sha256=RESULT_SHA)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'verified_image_count':out.get('verified_image_count')}),flush=True)
if not out['success']:raise SystemExit(1)
