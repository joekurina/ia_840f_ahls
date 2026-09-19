from pathlib import Path
import subprocess,os,json,hashlib
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
tcl='''load_package project
puts [help -cmd get_all_quartus_defaults]
puts [help -cmd get_all_assignments]
puts [help -cmd get_assignment_info]
puts [help -cmd project_open]
'''
(r/'defaults-help.tcl').write_text(tcl)
argv=['/opt/altera/26.1.1/quartus/bin/quartus_sh','-t','defaults-help.tcl']
with (r/'defaults-help.log').open('xb') as out:p=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
(r/'defaults-help.json').write_text(json.dumps({'argv':argv,'cwd':str(r),'exit':p.returncode,'input_sha256':hashlib.sha256(tcl.encode()).hexdigest()},indent=2))
qdf=Path('/opt/altera/26.1.1/quartus/linux64/assignment_defaults.qdf')
(r/'defaults-source.json').write_text(json.dumps({'path':str(qdf),'sha256':hashlib.sha256(qdf.read_bytes()).hexdigest(),'lines':[(i,l) for i,l in enumerate(qdf.read_text().splitlines(),1) if any(s in l for s in ['TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT','ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION'])]},indent=2))
subprocess.run(['tmux','load-buffer','-b','router-native-defaults-help-01',str(r/'defaults-help.log')],check=True)
print('DEFAULTS_HELP_DONE',p.returncode)
