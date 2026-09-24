import os,json,subprocess,hashlib,re
from pathlib import Path
W=Path('/work')
r={'commands':[],'binary_executed':False,'libraries_loaded':False,'hardware_access':False,'installed':False,'success':False}
env={'PATH':'/usr/bin:/bin','HOME':'/work','TMPDIR':'/work/tmp','LANG':'C','LC_ALL':'C','PKG_CONFIG_LIBDIR':'/work/empty-config'}
def digest(p):
 b=Path(p).read_bytes();return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'realpath':str(Path(p).resolve())}
def run(label,argv):
 p=subprocess.run(argv,cwd=W,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=240)
 (W/(label+'.log')).write_bytes(p.stdout)
 r['commands'].append({'label':label,'argv':argv,'rc':p.returncode,'sha256':hashlib.sha256(p.stdout).hexdigest()})
 if p.returncode:raise RuntimeError(label+' rc '+str(p.returncode))
 return p.stdout.decode(errors='replace')
try:
 r['dev_entries']=sorted(p.name for p in Path('/dev').iterdir())
 assert not any(n.startswith(('vfio','dfl','fpga','uio','dri','mem')) for n in r['dev_entries'])
 mounts=Path('/proc/self/mountinfo').read_text();(W/'mounts.log').write_text(mounts)
 assert ' - sysfs ' not in mounts
 (W/'empty-config').mkdir()
 r['tool_bindings']={p:digest(p) for p in ['/usr/bin/python3','/usr/bin/cmake','/usr/bin/cc','/usr/bin/ld','/usr/bin/readelf','/usr/bin/nm']}
 run('compiler_version',['/usr/bin/cc','--version'])
 run('cmake_version',['/usr/bin/cmake','--version'])
 run('configure',['/usr/bin/cmake','-S','/work/source','-B','/work/build','-DCMAKE_BUILD_TYPE=Release','-DFETCHCONTENT_FULLY_DISCONNECTED=ON'])
 run('build',['/usr/bin/cmake','--build','/work/build','--parallel',str(len(os.sched_getaffinity(0))),'--verbose'])
 launcher=W/'build/ahls_memory_startup';entry=W/'build/libahls_memory_entry.so'
 r['artifacts']={str(p):digest(p) for p in [launcher,entry]}
 for p in [launcher,entry]:p.chmod(0o600)
 r['elf']={}
 for name,p in [('launcher',launcher),('entry',entry)]:
  dynamic=run(name+'_dynamic',['/usr/bin/readelf','--dynamic','--wide',str(p)])
  run(name+'_program_headers',['/usr/bin/readelf','--program-headers','--wide',str(p)])
  syms=run(name+'_symbols',['/usr/bin/readelf','--dyn-syms','--wide',str(p)])
  run(name+'_undefined',['/usr/bin/nm','-u',str(p)])
  needed=re.findall(r'\(NEEDED\).*?\[(.*?)\]',dynamic)
  paths=re.findall(r'\((?:RUNPATH|RPATH)\).*?\[(.*?)\]',dynamic)
  assert paths and all('' not in value.split(':') for value in paths)
  r['elf'][name]={'needed':needed,'runtime_paths':paths}
  if name=='launcher':
   assert set(needed)=={'libjson-c.so.5','libc.so.6'},needed
   assert not re.search(r'\bfpga[A-Za-z_]+',syms)
   assert paths==['/work/prefix/usr/lib/x86_64-linux-gnu']
  else:
   assert set(needed)=={'libopae-c.so.2','libc.so.6'},needed
   assert paths==['/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu']
   for symbol in ['ia840f_memory_initialize','ia840f_memory_entry','ia840f_memory_finalize']:
    assert any(symbol in line and ' UND ' not in line for line in syms.splitlines()),symbol
 core=run('core_symbols',['/usr/bin/readelf','--dyn-syms','--wide','/work/sdk-build/lib/libopae-c.so'])
 calls=set(re.findall(r'\b(fpga\w+)\s*\(', '\n'.join((W/'source'/n).read_text() for n in ['ahls_memory_inspect.c','ahls_memory_entry.c'])))
 for symbol in calls:assert any(re.search(r'\b'+symbol+r'(?:@|$)',line) and ' UND ' not in line for line in core.splitlines()),symbol
 r['required_opae_exports']=sorted(calls)
 r['success']=True
except BaseException as e:r['error']=repr(e)
finally:(W/'build-result.json').write_text(json.dumps(r,indent=2)+'\n')
raise SystemExit(0 if r['success'] else 1)
