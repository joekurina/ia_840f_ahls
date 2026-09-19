import os,socket; assert socket.gethostname()=='Agilex7Workstation'; assert os.getuid()==1000
from pathlib import Path
import subprocess,os,json,hashlib,time
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
tcl='''load_package project
load_package device
puts "PART_FAMILY=[get_part_info -family AGFB027R25A2E2V]"
project_new -family "Agilex 7" -part AGFB027R25A2E2V capability
puts "FAMILY=[get_global_assignment -name FAMILY] DEVICE=[get_global_assignment -name DEVICE]"
set allnames [get_all_assignment_names -family "Agilex 7"]
set fitnames [get_all_assignment_names -family "Agilex 7" -module fit]
set f [open agilex7-assignment-names.txt w]; puts $f [join $allnames "\\n"]; close $f
set f [open agilex7-fit-names.txt w]; puts $f [join $fitnames "\\n"]; close $f
foreach n {ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION ROUTER_REGISTER_DUPLICATION POST_ROUTE_PHYSICAL_SYNTHESIS TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT SEED ROUTER_TIMING_OPTIMIZATION_LEVEL DUPLICATE_ATOM DUPLICATE_REGISTER MAX_FANOUT} {
puts "===NAME $n AGILEX7=[expr {[lsearch -exact $allnames $n]>=0}] FIT=[expr {[lsearch -exact $fitnames $n]>=0}] ==="
puts [get_assignment_name_info $n]
}
puts "===FAMILY LIST===";puts [get_family_list]
project_close
'''
(r/'capability.tcl').write_text(tcl)
argv=['/opt/altera/26.1.1/quartus/bin/quartus_sh','-t','capability.tcl']
before={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in r.rglob('*') if p.is_file()}
start=time.monotonic()
with (r/'capability.log').open('xb') as out:p=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
after={str(p.relative_to(r)):hashlib.sha256(p.read_bytes()).hexdigest() for p in r.rglob('*') if p.is_file()}
(r/'capability.json').write_text(json.dumps({'argv':argv,'cwd':str(r),'exit':p.returncode,'seconds':time.monotonic()-start,'before':before,'after':after},indent=2));subprocess.run(['tmux','load-buffer','-b','router-native-capability-01',str(r/'capability.log')],check=True)
print('CAPABILITY_DONE',p.returncode)
