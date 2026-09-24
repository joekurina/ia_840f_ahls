import os,socket,hashlib,json,gzip,subprocess,shutil
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and os.environ.get('TMUX') and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_memory_host01/prereq01')
assert not R.exists() and not (R.parent/'native01').exists()
R.mkdir(parents=True,exist_ok=False)
def item(p):
 p=Path(p);b=p.read_bytes();return {'realpath':str(p.resolve()),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
paths=['/usr/bin/cmake','/usr/bin/cc','/usr/bin/gcc','/usr/bin/make','/usr/bin/readelf','/usr/bin/ld','/usr/bin/as','/usr/lib64/libopae-c.so']
tools={p:item(p) for p in paths}
headers={str(p):item(p) for p in sorted(Path('/usr/include/opae').glob('*.h'))}
assert headers and all(Path(p).is_file() for p in paths)
mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
free=shutil.disk_usage(R).free
assert mem>80000000000 and free>10000000000
competing=[]
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  name=(p/'comm').read_text().strip()
  if name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_asm','qsys-generate','aoc','vsim'):competing.append({'pid':int(p.name),'name':name})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not competing
cfg=Path('/etc/opae/opae.cfg')
r={'at':datetime.now(timezone.utc).isoformat(),'host':socket.gethostname(),'uid':os.getuid(),'pane':os.environ['TMUX_PANE'],'tools':tools,'headers':headers,'allowed_cpus':sorted(os.sched_getaffinity(0)),'mem_available':mem,'disk_free':free,'competing':competing,'opae_config':{'path':str(cfg),**item(cfg)},'hardware_access':False,'scope':'ordinary file hashes and OS resource reads only; no OPAE load/execution or device reads'}
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
(R/'result.json.gz').write_bytes(blob)
name='ia840f_memory_host_prereq01'
subprocess.run(['tmux','load-buffer','-b',name,'-'],input=blob,check=True)
subprocess.run(['tmux','set-buffer','-b',name+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
