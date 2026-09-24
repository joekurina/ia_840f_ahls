import os,json,hashlib,subprocess,stat,time,datetime
from pathlib import Path
D=Path('/diag');W=Path('/work');x={'success':False,'application_started':False,'started':datetime.datetime.now(datetime.timezone.utc).isoformat()}
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save():
 tmp=D/'inner-result.tmp'
 with tmp.open('w') as f:json.dump(x,f,indent=2);f.flush();os.fsync(f.fileno())
 os.replace(tmp,D/'inner-result.json')
try:
 assert os.getcwd()=='/empty' and not list(Path('/empty').iterdir())
 mounts=Path('/proc/self/mountinfo').read_text();(D/'mountinfo.log').write_text(mounts)
 for target in ['/empty','/work','/exec','/sys','/dma']:
  assert any(l.split()[4]==target and 'ro' in l.split()[5].split(',') for l in mounts.splitlines()),target
 nodes=sorted(p.name for p in Path('/dev/vfio').iterdir());assert nodes==['76','vfio'],nodes
 assert not any(p.name.startswith(('dfl','fpga','uio','dri')) for p in Path('/dev').iterdir())
 cfg=json.loads((D/'binding.json').read_text())
 for p,rec in cfg['objects'].items():assert sha(p)==rec['sha256'],p
 for p,rec in cfg['objects'].items():
  for soname,dest in rec['resolved'].items():
   found=next((Path(d)/soname for d in cfg['search'] if (Path(d)/soname).exists()),None)
   assert found is not None and str(found.resolve())==dest,(soname,str(found),dest)
 for p in cfg['absent_plugin_prefixes']:assert not Path(p).exists(),p
 assert sha('/exec/ahls_memory_dma_vfio_startup')==cfg['launcher_sha256']
 assert sha('/work/source/config/ia840f_caps01_vfio.cfg')==cfg['config_sha256']
 vf=Path('/sys/bus/pci/devices/0000:4f:00.2');pf=Path('/sys/bus/pci/devices/0000:4f:00.0')
 assert (pf/'driver').resolve().name=='dfl-pci' and (vf/'driver').resolve().name=='vfio-pci'
 assert (vf/'physfn').resolve()==pf.resolve() and (vf/'iommu_group').resolve().name=='76'
 assert sorted(p.name for p in (vf/'iommu_group/devices').iterdir())==['0000:4f:00.2']
 assert (vf/'reset_method').read_text()=='flr\n'
 x['runtime_preflight_passed']=True;x['nodes']=nodes;x['mountinfo_sha256']=hashlib.sha256(mounts.encode()).hexdigest();save()
 assert sha('/diag/runtime-supervisor05.py')=='12e0016b32cbf4e9a0a1c084bdb342fe2c668bd1d8053f3e418c9bfc6ceefa33'
 sup={};exec(compile((D/'runtime-supervisor05.py').read_text(),'/diag/runtime-supervisor05.py','exec'),sup)
 def save_child(state):
  x['process']=dict(state);x['application_started']=state['application_started']
  x['retained_owner']=state.get('retained_owner',False);save()
 argv=['/exec/ahls_memory_dma_vfio_startup','--config','/work/source/config/ia840f_caps01_vfio.cfg','--module','/dma/build/libahls_memory_dma_entry_vfio_strict.so','--roundtrip-qualified-memory-afu','0000:4f:00.2','1']
 env={'PATH':'/usr/bin:/bin','HOME':'/diag','TMPDIR':'/diag/tmp','LANG':'C','LC_ALL':'C','LD_LIBRARY_PATH':'/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu','LD_DEBUG':'libs','LD_DEBUG_OUTPUT':'/diag/loader'}
 x['argv']=argv;x['environment']=env;save()
 print('FPGA Test: one bank1 64-byte H2D/D2H; standard VFIO lifecycle included.',flush=True)
 state=sup['supervise'](argv,env,'/empty',D/'native.log',save_child,45)
 x['native_rc']=state['native_rc'];save()
 out=(D/'native.log').read_bytes();x['native_log']=out.decode(errors='replace');x['native_log_sha256']=hashlib.sha256(out).hexdigest()
 x['loader_logs']={p.name:{'sha256':sha(p),'bytes':p.stat().st_size,'text':p.read_text()} for p in D.glob('loader.*') if p.is_file()}
 assert x['native_rc']==0,x['native_log']
 assert 'FPGA Test data verified bank=1 bytes=64 source_page=4096 destination_page=4096' in x['native_log']
 assert 'FPGA Test DMA roundtrip PASSED: bank=1 bytes=64 transfers=2 verified_payload_and_guards=1' in x['native_log']
 assert x['native_log'].count('FPGA Test DMA submit ')==2
 assert 'FAIL' not in x['native_log'] and 'HOLD_UNKNOWN_DMA' not in x['native_log']
 x['success']=True
except BaseException as e:x['success']=False;x['error']=repr(e)
finally:
 x['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat();save()
raise SystemExit(0 if x['success'] else 1)
