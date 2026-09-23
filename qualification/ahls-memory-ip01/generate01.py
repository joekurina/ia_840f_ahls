# Native CMake report build, no FPGA opens or executable run.
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess, sys, traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ahls_memory_01';E=B/'qualification/ahls-memory-ip01';batch='ia840f_ahls_memip01'
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX') and not sys.flags.optimize
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
assert not W.exists() and not E.exists()
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>64000000000 and shutil.disk_usage(B).free>20000000000
raw=subprocess.check_output(['tmux','save-buffer','-b',batch+'_inputs','-']);assert hashlib.sha256(raw).hexdigest()==sys.argv[1]
payload=json.loads(raw);assert set(payload)=={'CMakeLists.txt','src/mmhost_ia840f.cpp','include/exception_handler.hpp','License.txt','provenance.json','README.md'}
W.mkdir();E.mkdir();r={'batch':batch,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'pane':os.environ['TMUX_PANE'],'mem_available_before':mem,'hardware_access':False,'complete':False,'commands':[],'inputs':{},'files':{}}
try:
 for rel,v in payload.items():
  b=base64.b64decode(v['base64'],validate=True);assert hashlib.sha256(b).hexdigest()==v['sha256'];p=W/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b);r['inputs'][rel]=v['sha256']
 envcmd=['/bin/bash','-c','source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh > '+str(E/'environment-init.log')+' 2>&1 && env -0']
 out=subprocess.check_output(envcmd,timeout=30);env=dict(x.decode().split('=',1) for x in out.split(b'\0') if x)
 env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/25.1/quartus',LM_LICENSE_FILE='/home/uwb_student00/quartus_25/LR-191011_License.dat',MGLS_LICENSE_FILE='/home/uwb_student00/quartus_25/LR-191011_License.dat',SALT_LICENSE_SERVER='/home/uwb_student00/quartus_25/LR-191011_License.dat')
 env['PATH']='/opt/altera/25.1/quartus/bin:/opt/altera/25.1/quartus/sopc_builder/bin:'+env['PATH']
 ahls=shutil.which('ahls',path=env['PATH']);assert ahls
 r['compiler']={'path':ahls,'sha256':hashlib.sha256(Path(ahls).read_bytes()).hexdigest()}
 commands=[[ahls,'--version'],['cmake','-S',str(W),'-B',str(W/'build'),'-DFPGA_DEVICE=AGFB027R25A2E2V'],['cmake','--build',str(W/'build'),'--target','report','--parallel','1','--verbose']]
 for i,cmd in enumerate(commands):
  lp=E/f'step{i:02d}.log';print('START',cmd,flush=True)
  with lp.open('xb') as log:
   p=subprocess.run(cmd,cwd=W,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=600)
  r['commands'].append({'argv':cmd,'rc':p.returncode,'log':str(lp)});print('END',p.returncode,flush=True)
  assert p.returncode==0,lp.read_text(errors='replace')[-3000:]
  if i==0:assert '2026.1.0' in lp.read_text()
 r['complete']=True
except BaseException as exc:r.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 r['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
 for p in sorted((W/'build').rglob('*')):
  if p.is_file():
   rel=str(p.relative_to(W));b=p.read_bytes();r.setdefault('generated_inventory',{})[rel]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
   if p.name.endswith(('_di_inst.sv','_di_hw.tcl','_register_map.h')) or p.name in ('register_map_offsets.h','acl_quartus_report.txt','aoc.log','quartus_sh_compile.log'):
    assert len(b)<2000000;r['files'][rel]={'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 for p in E.glob('*.log'):
  b=p.read_bytes();assert len(b)<2000000;r['files']['logs/'+p.name]={'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 (E/'result.json').write_text(json.dumps(r,indent=2));blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
 subprocess.run(['tmux','load-buffer','-b',batch+'_output','-'],input=blob,check=True)
 print('AHLS_MEMORY_IP01_RESULT',r['complete'],hashlib.sha256(blob).hexdigest(),flush=True)
sys.exit(0 if r['complete'] else 1)
