from pathlib import Path
import subprocess,os,json,hashlib
r=Path('/home/uwb_student00/quartus_26/qualification/router-native-capability-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
tcl='''load_package project
load_package device
foreach c {get_assignment_name_info get_all_assignment_names test_assignment_trait get_part_info project_new get_global_assignment} {puts "=== $c ==="; puts [help -cmd $c]}
'''
(r/'metadata.tcl').write_text(tcl)
argv=['/opt/altera/26.1.1/quartus/bin/quartus_sh','-t','metadata.tcl']
with (r/'metadata.log').open('xb') as out:p=subprocess.run(['timeout','--kill-after=5','60',*argv],cwd=r,env=env,stdout=out,stderr=subprocess.STDOUT)
(r/'metadata.json').write_text(json.dumps({'argv':argv,'cwd':str(r),'exit':p.returncode,'input_sha256':hashlib.sha256(tcl.encode()).hexdigest()},indent=2));subprocess.run(['tmux','load-buffer','-b','router-native-metadata-01',str(r/'metadata.log')],check=True)
print('METADATA_DONE',p.returncode)
