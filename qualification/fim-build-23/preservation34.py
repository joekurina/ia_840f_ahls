"""Post-run preservation check of named original domains; ordinary files only."""
import datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-23';OLD=B/'work_ia840f_fim_22'
BUFFER='ia840f_migration23_preservation34_result'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False}
def sha(p):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for data in iter(lambda:f.read(1048576),b''):h.update(data)
    return h.hexdigest()
try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    status=json.loads((E/'operations/compile/status.json').read_text());assert status['complete'] and status['execution_clean'] and not (E/'native-operation.lock').exists()
    p=E/'original-source-pim-inventory01.json';assert sha(p)=='ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9';source=json.loads(p.read_text());assert len(source)==1891
    for name,h in source.items():assert sha(name)==h,name
    mf=json.loads((E/'stage-inputs/compile.json').read_text());p=B/'qualification/fim-build-22/completion51/successor-input-inventory.json';assert sha(p)==mf['predecessor']['input_inventory_sha256'];inv=json.loads(p.read_text());assert len(inv)==3963
    for rel,item in inv.items():
        p=OLD/rel
        if 'symlink' in item:assert p.is_symlink() and os.readlink(p)==item['symlink'],rel
        else:assert not p.is_symlink() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256'] and oct(p.stat().st_mode&0o777)==item['mode'],rel
    images={'ofs_top.sof':'3d2996d40bec2e7ae4544aa46aa39049bd3a9d06aef7a5759a2f6517e7e12cf9','ofs_top.green_region.rbf':'88f74cf15971024052c3f8116896a0ebda95376e5a55e4aa07d81f22838bfe94','ofs_top.green_region.pmsf':'5ccf0acd7ad834fd5fd59493641ef2480ac4ac505f0ef31918893b09c956cf8e','ofs_top.static.msf':'4e2af52bc6645da8121860738419c4ed231ef80eab279e0b302ae02fbf869bfb'}
    j=OLD/'syn/board/ia840f/syn_top'
    for name,h in images.items():assert sha(j/'output_files'/name)==h,name
    assert sha(j/'ofs_top.qdb')=='da69c84ae7ec47de9320fa11ead914de0c7b60dd527f6b6e09a18e24b25ed9e8'
    R.update(success=True,original_source_pim_entries=len(source),original_work22_inputs=len(inv),original_images=len(images),original_static_qdb_preserved=True,scope='Named input/image/static-QDB bindings only; not an unrecorded entire-tree claim')
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    p=E/'preservation34.json'
    with p.open('x') as f:json.dump(R,f,indent=2)
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION23_PRESERVATION34',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
