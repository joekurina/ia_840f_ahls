import pathlib,subprocess,os,json
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
t='package require -exact qsys 26.1\nputs "HELP [info commands *help*]"\nforeach c {load_component save_component set_component_parameter_value add_component set_component_project_property} { puts "API $c"; catch {$c} msg; puts $msg }\n'
(r/'api2.tcl').write_text(t)
cmd=['qsys-script','--quartus-project='+str(r/'api.qpf'),'--script='+str(r/'api2.tcl')];p=subprocess.run(cmd,cwd=r,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(r/'api2.log').write_text(p.stdout);print(p.stdout)
