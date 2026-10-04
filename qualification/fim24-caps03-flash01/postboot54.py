"""Verify one normal reboot and migrated static identity via cached accessor only."""
import base64,datetime,gzip,hashlib,json,os,re,socket,subprocess,sys,traceback,uuid
from pathlib import Path
C={'modules': {'fpga_region': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/fpga-region.ko', 'sha256': '7d8a160293985df0b497825db606342f44d67b8399ccb4dc1b71bc26d8488cd7', 'loaded_note': '040000001400000003000000474e550054b90aaa0fb2542566ce663159398310c8e548de'}, 'dfl_fme_mgr': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/dfl-fme-mgr.ko', 'sha256': '1f6493865c025ec4cea9568d6b34660135e8b9111552bdd0784dc9be9cfffcd4', 'loaded_note': '040000001400000003000000474e55006675e340311e4d2379d5906257f61ca933ad2aa7'}, 'dfl_fme_region': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/dfl-fme-region.ko', 'sha256': '687791d091e1cee4ec5eb27c9fd823196b5bff574bae496255c05796aa03aeec', 'loaded_note': '040000001400000003000000474e5500984c9e404e74df6ebf988f728e98a287c96a8f5f'}}, 'expected_interface_uuid': 'fc603c44-5c8f-5e94-bcbe-a5780030947c', 'old_boot': '8121620d-a638-42f8-abab-a547aae32076', 'original_aer': ['00000000', '00100000', '00002000']}
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');W=ROOT/'postboot54';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'postboot durable receipt/PCI/source-module/cached FME/AER/ownership verification; no AFU/MMIO/reset/VF creation','success':False,'hardware_mmio':False,'pci_config_read':False,'exports':{}};owned=False
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def export(p,name):
    b=p.read_bytes();assert len(b)<=4*1024**2;out['exports'][name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not W.exists()
    boot=Path('/proc/sys/kernel/random/boot_id').read_text().strip();out.update(boot=boot,kernel=os.uname().release,old_boot=C['old_boot'])
    for name in ['requested.json','command-result.json']:
        p=ROOT/'reboot53'/name;assert p.is_file();out.setdefault('reboot_receipts',{})[name]={'sha256':sha(p),'data':json.loads(p.read_text())};export(p,'reboot53/'+name)
    requested=out['reboot_receipts']['requested.json']['data'];cmd=out['reboot_receipts']['command-result.json']['data'];assert requested['boot_before']==C['old_boot'] and boot!=C['old_boot'] and cmd['reboot_rc']==0 and cmd['success'] is True
    W.mkdir(exist_ok=False);owned=True;out['reboot_verified']=True
    out['pci']={}
    for bdf in ['0000:4f:00.0','0000:4f:00.1','0000:4f:00.2']:
        p=Path('/sys/bus/pci/devices')/bdf;r={'exists':p.exists()};out['pci'][bdf]=r
        if not p.exists():continue
        for name in ['vendor','device','subsystem_vendor','subsystem_device','sriov_numvfs']:
            if (p/name).is_file():r[name]=(p/name).read_text().strip()
        for name in ['driver','iommu_group','physfn','virtfn0']:
            if (p/name).is_symlink():r[name]=str((p/name).resolve())
    assert out['pci']['0000:4f:00.0']['vendor']=='0x8086' and out['pci']['0000:4f:00.0']['device']=='0xbcce' and out['pci']['0000:4f:00.0']['driver']=='/sys/bus/pci/drivers/dfl-pci'
    assert out['pci']['0000:4f:00.1']['vendor']=='0x12ba' and out['pci']['0000:4f:00.1']['device']=='0x0070' and out['pci']['0000:4f:00.1']['driver']=='/sys/bus/pci/drivers/vfio-pci'
    assert out['pci']['0000:4f:00.0']['sriov_numvfs']=='0' and out['pci']['0000:4f:00.2']['exists'] is False
    out['modules']={}
    for name,m in C['modules'].items():
        note=(Path('/sys/module')/name/'notes/.note.gnu.build-id').read_bytes().hex();digest=sha(m['path']);assert note==m['loaded_note'] and digest==m['sha256'];out['modules'][name]={**m,'actual_loaded_note':note,'actual_sha256':digest}
    pf=Path('/sys/bus/pci/devices/0000:4f:00.0').resolve(strict=True)
    regions=[p.resolve(strict=True) for p in Path('/sys/class/fpga_region').iterdir() if pf in p.resolve(strict=True).parents and any(x.startswith('dfl-fme-region.') for x in p.resolve(strict=True).parts)]
    assert len(regions)==1,regions;region=regions[0];assert str((region.parent.parent/'driver/module').resolve(strict=True))=='/sys/module/dfl_fme_region'
    p=region/'compat_id';fd=os.open(p,os.O_RDONLY|os.O_CLOEXEC|os.O_NOFOLLOW)
    try:b=os.read(fd,128)
    finally:os.close(fd)
    assert b.endswith(b'\n') and re.fullmatch(rb'[0-9a-f]{32}',b[:-1]);out['cached_uuid_raw']=b.decode();out['cached_uuid_path']=str(p);out['cached_uuid']=str(uuid.UUID(hex=b[:-1].decode()));out['matches_migrated_interface']=out['cached_uuid']==C['expected_interface_uuid'];assert out['matches_migrated_interface']
    out['pci_config_read']=True;z=subprocess.run(['sudo','-n','/usr/sbin/setpci','-s','0000:4e:00.0','ECAP_AER+0x04.L','ECAP_AER+0x08.L','ECAP_AER+0x14.L'],capture_output=True,text=True,timeout=30);assert z.returncode==0;out['aer_read']=z.stdout.splitlines();assert out['aer_read'][1:]==C['original_aer'][1:];out['aer_masks_restored']=True
    export(ROOT/'quiesce51/result.json','quiesce51-result.json');export(ROOT/'bmc-cycle52/result.json','bmc-cycle52-result.json')
    z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(ROOT/'activation-pre43/runtime/ownership27.py')],capture_output=True,timeout=60);assert z.returncode==0;out['ownership']=json.loads(z.stdout);assert not any(out['ownership'][k] for k in ['holders','maps','d_state','errors'])
    relevant=out['ownership']['relevant_processes'];assert all(r.get('exe') in ['/usr/bin/bash','/usr/bin/tmux'] and any(BATCH in a for a in r.get('argv',[])) for r in relevant)
    out.update(success=True,cached_accessor_modules_unchanged=True,static_identity_only=True,hardware_ready=False,application_VF_created=False,numerical_test_launched=False)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    with (W/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2);stream.write('\n')
    export(W/'result.json','postboot-result.json')
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'cached_uuid':out.get('cached_uuid'),'reboot_verified':out.get('reboot_verified')}),flush=True)
if not out['success']:raise SystemExit(1)
