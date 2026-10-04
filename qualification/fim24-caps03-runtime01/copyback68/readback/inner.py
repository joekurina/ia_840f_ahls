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
 for target in ['/empty','/work','/exec','/sys','/caps03']:
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
 assert sha('/exec/ahls_memory_caps03_startup')==cfg['launcher_sha256']
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
 argv=['/exec/ahls_memory_caps03_startup','--config','/work/source/config/ia840f_caps01_vfio.cfg','--module','/caps03/build/libahls_memory_caps03_entry_vfio_strict.so','--run-qualified-caps03-hls','0000:4f:00.2']
 env={'PATH':'/usr/bin:/bin','HOME':'/diag','TMPDIR':'/diag/tmp','LANG':'C','LC_ALL':'C','LD_LIBRARY_PATH':'/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu','LD_DEBUG':'libs','LD_DEBUG_OUTPUT':'/diag/loader'}
 x['argv']=argv;x['environment']=env;save()
 print('FPGA Test: CAPS03 one HLS invocation, exact data/guards, then normal cleanup only after successful finite completion; uncertain outcomes still retain ownership.',flush=True)
 state=sup['supervise'](argv,env,'/empty',D/'native.log',save_child,45)
 x['native_rc']=state['native_rc'];save()
 out=(D/'native.log').read_bytes();x['native_log']=out.decode(errors='replace');x['native_log_sha256']=hashlib.sha256(out).hexdigest()
 x['loader_logs']={p.name:{'sha256':sha(p),'bytes':p.stat().st_size,'text':p.read_text()} for p in D.glob('loader.*') if p.is_file()}
 assert x['native_rc']==0,x['native_log']
 import re
 expected='FPGA Test HLS DATA PASS: integers=9 result_bytes=36 guard_bytes=156 descriptors=6'
 x['numerical_data_pass']=(x['native_log'].count(expected)==1 and
  x['native_log'].count('FPGA Test CAPS03 frontend PASSED: integers=9 copied_span_bytes=192 descriptors=6 verified_payload_and_guards=1')==1 and
  'FPGA Test HLS ticket=1 completion=0x10002' in x['native_log'] and
  re.findall(r'FPGA Test DMA retired and host pages verified sequence=(\d+)',x['native_log'])==['0','1','2','3','4','5'] and
  not re.search(r'(?m)^FAIL\b|^FPGA Test .*FAILED|HOLD_UNKNOWN_DMA|HOLD_CAPS03_ALLOCATED',x['native_log']))
 assert x['numerical_data_pass'],x['native_log']
 x['native_exit_passed']=True
 x['success']=True
except BaseException as e:x['success']=False;x['error']=repr(e)
finally:
 x['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat();save()
raise SystemExit(0 if x['success'] else 1)
