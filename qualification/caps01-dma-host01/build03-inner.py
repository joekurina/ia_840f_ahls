import os,json,re,hashlib,subprocess,resource
from pathlib import Path
D=Path('/diag');W=Path('/work')
r={'success':False,'hardware_access':False,'application_executed':False,'opae_loaded':False,'installed':False,'commands':[]}
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def run(label,argv):
 p=subprocess.run(argv,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env={'PATH':'/usr/bin:/bin','HOME':'/diag','TMPDIR':'/diag/tmp','LANG':'C','LC_ALL':'C'},cwd='/empty',timeout=180)
 b=p.stdout;(D/(label+'.log')).write_bytes(b);r['commands'].append({'label':label,'argv':argv,'rc':p.returncode,'sha256':hashlib.sha256(b).hexdigest()})
 assert p.returncode==0,(label,p.returncode,b.decode(errors='replace'))
 return b.decode()
try:
 resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
 r['cpus']=sorted(os.sched_getaffinity(0));r['page_size']=os.sysconf('SC_PAGE_SIZE');assert r['page_size']==4096
 r['dev_entries']=sorted(p.name for p in Path('/dev').iterdir());assert not any(s.startswith(('vfio','dfl','fpga','uio','dri','mem')) for s in r['dev_entries'])
 mount=Path('/proc/self/mountinfo').read_text();(D/'mounts.log').write_text(mount);assert ' - sysfs ' not in mount
 for target in ['/work','/sdk','/empty']:
  assert any(l.split()[4]==target and 'ro' in l.split()[5].split(',') for l in mount.splitlines()),target
 assert os.getcwd()=='/empty' and not list(Path('/empty').iterdir())
 r['tools']={p:digest(p) for p in ['/usr/bin/cc','/usr/bin/cmake','/usr/bin/ld','/usr/bin/readelf','/usr/bin/nm','/usr/bin/python3']}
 run('compiler_version',['/usr/bin/cc','--version'])
 run('configure',['/usr/bin/cmake','-S','/diag/source','-B','/diag/build','-DCMAKE_BUILD_TYPE=Release','-DFETCHCONTENT_FULLY_DISCONNECTED=ON'])
 run('build',['/usr/bin/cmake','--build','/diag/build','--parallel',str(len(r['cpus'])),'--verbose'])
 r['artifacts']={};r['elf']={}
 for name in ['ahls_memory_dma_vfio_startup','libahls_memory_dma_entry_vfio_strict.so']:
  p=D/'build'/name;p.chmod(0o600);r['artifacts'][name]={'bytes':p.stat().st_size,'sha256':digest(p),'mode':oct(p.stat().st_mode&0o777)}
  text=run(name+'_dynamic',['/usr/bin/readelf','-dW',str(p)])
  symbols=run(name+'_symbols',['/usr/bin/readelf','--dyn-syms','--wide',str(p)])
  run(name+'_headers',['/usr/bin/readelf','-lW',str(p)])
  needed=re.findall(r'\(NEEDED\).*?\[(.*?)\]',text);paths=re.findall(r'\((?:RUNPATH|RPATH)\).*?\[(.*?)\]',text)
  assert paths and all('' not in v.split(':') for v in paths)
  if name=='ahls_memory_dma_vfio_startup':
   assert set(needed)=={'libjson-c.so.5','libc.so.6'} and not re.search(r'\bfpga[A-Za-z_]+',symbols)
  else:
   assert set(needed)=={'libopae-c.so.2','libc.so.6'}
   for symbol in ['ia840f_memory_initialize','ia840f_memory_entry','ia840f_memory_finalize']:
    assert any(symbol in l and ' UND ' not in l for l in symbols.splitlines())
  r['elf'][name]={'needed':needed,'paths':paths}
 r['success']=True
except BaseException as e:r['error']=repr(e)
finally:(D/'inner-result.json').write_text(json.dumps(r,indent=2)+'\n')
raise SystemExit(0 if r['success'] else 1)
