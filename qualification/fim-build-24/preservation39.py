"""Post-run preservation check of named original domains; ordinary files only."""
import datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';OLD=B/'work_ia840f_fim_23'
BUFFER='ia840f_migration24_preservation39_result'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False}
def sha(p):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for data in iter(lambda:f.read(1048576),b''):h.update(data)
    return h.hexdigest()
try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    statusfile=E/'operations/compile/status.json';assert sha(statusfile)=='6ea3822e9f7dfb35dfcebb7675de2ac67e3d65f17f09dc5d3dd4e2c93d096adb'
    status=json.loads((E/'operations/compile/status.json').read_text());assert status['complete'] and status['execution_clean'] and not (E/'native-operation.lock').exists()
    p=E/'original-source-pim-inventory01.json';assert sha(p)=='ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9';source=json.loads(p.read_text());assert len(source)==1891
    for name,h in source.items():assert sha(name)==h,name
    assert sha(E/'stage-inputs/compile.json')=='99820e60694b59639a5f542f0a8b70320015462a8d9d74c4a3fb103a6d2e480f'
    mf=json.loads((E/'stage-inputs/compile.json').read_text());p=B/'qualification/fim-build-23/completion24/successor-input-inventory.json';assert sha(p)==mf['predecessor']['input_inventory_sha256'];inv=json.loads(p.read_text());assert len(inv)==3963
    for rel,item in inv.items():
        p=OLD/rel
        if 'symlink' in item:assert p.is_symlink() and os.readlink(p)==item['symlink'],rel
        else:assert not p.is_symlink() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256'] and oct(p.stat().st_mode&0o777)==item['mode'],rel
    images={'ofs_top.green_region.pmsf': 'fa45c1573e35db501cf7dd932cb1cf3d9aee060b3185e4ea92355004330a7666', 'ofs_top.green_region.rbf': 'cef69a708e7449a1cfc1d6ad9f9d305f638e3ee571401f60d181e7a0696f93ca', 'ofs_top.sof': '6d149d05ec82587f4f61e0e78ba470d3058da0f1263b2d339ecaea7d61c374c9', 'ofs_top.static.msf': '54118b3bc212aa405761b85c5791185defe4e051af78009e39216d77fdb71b6b'}
    j=OLD/'syn/board/ia840f/syn_top'
    for name,h in images.items():assert sha(j/'output_files'/name)==h,name
    assert sha(j/'ofs_top.qdb')=='74aba905b4d6bb65fa0aedca2f0ed4353b17a3a8f6d4c77ab2ed0381e9540846'
    R.update(success=True,original_source_pim_entries=len(source),original_work23_inputs=len(inv),original_images=len(images),original_static_qdb_preserved=True,scope='Named input/image/static-QDB bindings only; not an unrecorded entire-tree claim')
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    p=E/'preservation39.json'
    with p.open('x') as f:json.dump(R,f,indent=2)
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION24_PRESERVATION39',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
