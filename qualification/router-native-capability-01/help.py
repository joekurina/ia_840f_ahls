from pathlib import Path
import subprocess,os,json,hashlib,time
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01')
env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
tcl='''load_package project
load_package device
puts [help -pkg project]
puts [help -pkg device]
puts [help -long_help]
'''
(r/'help.tcl').write_text(tcl)
argv=['/opt/altera/26.1.1/quartus/bin/quartus_sh','-t','help.tcl']
with (r/'help.log').open('xb') as out: p=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
(r/'help.json').write_text(json.dumps({'argv':argv,'cwd':str(r),'exit':p.returncode,'input_sha256':hashlib.sha256(tcl.encode()).hexdigest()},indent=2))
subprocess.run(['tmux','load-buffer','-b','router-native-help-01',str(r/'help.log')],check=True)
print('HELP_DONE',p.returncode)
