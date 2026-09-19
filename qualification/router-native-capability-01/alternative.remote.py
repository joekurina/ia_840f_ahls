import os,socket; assert socket.gethostname()=='Agilex7Workstation'; assert os.getuid()==1000
from pathlib import Path
import subprocess,os,json,hashlib,time,base64
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
tcl='''load_package project
project_open capability
set n TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT
foreach_in_collection a [get_all_assignments -type default -name $n] {puts "DEFAULT [get_assignment_info $a -name]=[get_assignment_info $a -value]"}
puts "GLOBAL-ALL ROUTER_PRESENT=[expr {[lsearch -exact [get_all_assignment_names] ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION]>=0}]"
puts "GLOBAL-AGILEX7 ROUTER_PRESENT=[expr {[lsearch -exact [get_all_assignment_names -family {Agilex 7} -type global] ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION]>=0}]"
set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON
project_close
project_open capability
puts "READBACK TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT=[get_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT]"
project_close
'''
(r/'alternative.tcl').write_text(tcl)
argv=['/opt/altera/26.1.1/quartus/bin/quartus_sh','-t','alternative.tcl']
before={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in r.rglob('*') if p.is_file()}
(r/'capability-before-alternative.qsf.txt').write_bytes((r/'capability.qsf').read_bytes())
start=time.monotonic()
with (r/'alternative.log').open('xb') as out:p=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
after={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in r.rglob('*') if p.is_file()}
(r/'alternative.json').write_text(json.dumps({'argv':argv,'cwd':str(r),'exit':p.returncode,'seconds':time.monotonic()-start,'before':before,'after':after},indent=2))
subprocess.run(['tmux','load-buffer','-b','router-native-alternative-01',str(r/'alternative.log')],check=True)
files={str(p.relative_to(r)):{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'base64':base64.b64encode(p.read_bytes()).decode()} for p in r.rglob('*') if p.is_file()}
(r/'export.json').write_text(json.dumps({'batch':'router-native-capability-01-final','files':files}))
subprocess.run(['tmux','load-buffer','-b','router-native-final-01',str(r/'export.json')],check=True)
print('FINAL_DONE',p.returncode,'EXPORT_SHA256',hashlib.sha256((r/'export.json').read_bytes()).hexdigest())
