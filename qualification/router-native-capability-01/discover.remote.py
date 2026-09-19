import os,socket; assert socket.gethostname()=='Agilex7Workstation'; assert os.getuid()==1000
from pathlib import Path
import subprocess,os,hashlib,json,time
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01');r.mkdir(parents=True,exist_ok=False)
q=Path('/opt/altera/26.1.1/quartus')
env=os.environ.copy();env.update(QUARTUS_ROOTDIR_OVERRIDE=str(q),PATH=str(q/'bin')+':/opt/altera/26.1.1/questa_fe/bin:'+env['PATH'],LM_LICENSE_FILE='/home/uwb_student00/quartus_26/LR-191011_License.dat',MGLS_LICENSE_FILE='/home/uwb_student00/quartus_26/LR-191011_License.dat',SALT_LICENSE_SERVER='/home/uwb_student00/quartus_26/LR-191011_License.dat')
(r/'environment.json').write_text(json.dumps({k:env[k] for k in ['QUARTUS_ROOTDIR_OVERRIDE','PATH','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']},indent=2))
(r/'instructions.md').write_bytes(Path('/home/uwb_student00/quartus_26/instructions.md').read_bytes())
tcl='''puts "===PUBLIC PACKAGES==="
puts [package names]
load_package project
load_package device
puts "===PROJECT HELP==="
help -pkg project
puts "===DEVICE HELP==="
help -pkg device
puts "===HELP HELP==="
help -long_help
'''
(r/'discover.tcl').write_text(tcl)
argv=[str(q/'bin/quartus_sh'),'-t','discover.tcl']
meta={'argv':argv,'cwd':str(r),'timeout':60,'before':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in r.iterdir() if p.is_file()},'tools':{str(q/p):hashlib.sha256((q/p).read_bytes()).hexdigest() for p in ['bin/quartus_sh','linux64/quartus_sh','linux64/libdb_acf.so','linux64/assignment_defaults.qdf']}}
start=time.monotonic()
with (r/'discover.log').open('xb') as out:
 result=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
meta.update(exit=result.returncode,seconds=time.monotonic()-start,after={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in r.iterdir() if p.is_file()})
(r/'discover.json').write_text(json.dumps(meta,indent=2));subprocess.run(['tmux','load-buffer','-b','router-native-discover-01',str(r/'discover.log')],check=True)
print('DISCOVER_DONE',result.returncode)
