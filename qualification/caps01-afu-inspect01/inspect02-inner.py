import os,json,hashlib,subprocess,stat,time,datetime
from pathlib import Path
D=Path('/diag');W=Path('/work');x={'success':False,'application_started':False,'started':datetime.datetime.now(datetime.timezone.utc).isoformat()}
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save():
 with (D/'inner-result.json').open('w') as f:json.dump(x,f,indent=2);f.flush();os.fsync(f.fileno())
try:
 assert os.getcwd()=='/empty' and not list(Path('/empty').iterdir())
 mounts=Path('/proc/self/mountinfo').read_text();(D/'mountinfo.log').write_text(mounts)
 for target in ['/empty','/work','/exec','/sys']:
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
 assert sha('/exec/ahls_memory_vfio_startup')==cfg['launcher_sha256']
 assert sha('/work/source/config/ia840f_caps01_vfio.cfg')==cfg['config_sha256']
 vf=Path('/sys/bus/pci/devices/0000:4f:00.2');pf=Path('/sys/bus/pci/devices/0000:4f:00.0')
 assert (pf/'driver').resolve().name=='dfl-pci' and (vf/'driver').resolve().name=='vfio-pci'
 assert (vf/'physfn').resolve()==pf.resolve() and (vf/'iommu_group').resolve().name=='76'
 assert sorted(p.name for p in (vf/'iommu_group/devices').iterdir())==['0000:4f:00.2']
 assert (vf/'reset_method').read_text()=='flr\n'
 x['runtime_preflight_passed']=True;x['nodes']=nodes;x['mountinfo_sha256']=hashlib.sha256(mounts.encode()).hexdigest();save()
 argv=['/exec/ahls_memory_vfio_startup','--config','/work/source/config/ia840f_caps01_vfio.cfg','--module','/work/build/libahls_memory_entry_vfio_strict.so','--inspect-qualified-memory-afu','0000:4f:00.2']
 env={'PATH':'/usr/bin:/bin','HOME':'/diag','TMPDIR':'/diag/tmp','LANG':'C','LC_ALL':'C','LD_LIBRARY_PATH':'/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu','LD_DEBUG':'libs','LD_DEBUG_OUTPUT':'/diag/loader'}
 x['argv']=argv;x['environment']=env;save()
 print('FPGA Test: starting one OPAE invocation; implicit VFIO FLR/open/close included.',flush=True)
 with (D/'native.log').open('xb') as log:
  p=subprocess.Popen(argv,stdout=log,stderr=subprocess.STDOUT,env=env)
  x['application_started']=True;x['pid']=p.pid
  try:
   raw=Path('/proc/'+str(p.pid)+'/stat').read_text();x['start_ticks']=raw[raw.rfind(')')+2:].split()[19]
  except FileNotFoundError:x['start_ticks_unavailable']='exited before proc read'
  save();x['native_rc']=p.wait();save()
 out=(D/'native.log').read_bytes();x['native_log']=out.decode(errors='replace');x['native_log_sha256']=hashlib.sha256(out).hexdigest()
 x['loader_logs']={p.name:{'sha256':sha(p),'bytes':p.stat().st_size,'text':p.read_text()} for p in D.glob('loader.*') if p.is_file()}
 assert x['native_rc']==0,x['native_log']
 for offset in ['0','8','10']:assert 'FPGA Test identity read 0x'+offset+'\n' in x['native_log']
 for offset in ['98','a0','a8','b0']:assert 'FPGA Test capability read 0x'+offset+'\n' in x['native_log']
 assert 'FPGA Test identity/capability PASSED: banks=2 beat_bytes=64 host_address_bits=57 max_descriptor_beats=130816' in x['native_log']
 assert 'FAIL' not in x['native_log']
 x['success']=True
except BaseException as e:x['error']=repr(e)
finally:
 x['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat();save()
raise SystemExit(0 if x['success'] else 1)
