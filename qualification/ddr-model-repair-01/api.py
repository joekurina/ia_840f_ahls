import pathlib,subprocess,os,json
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
t='package require -exact qsys 26.1\nforeach c {load_component save_component set_component_parameter_value get_component_parameters get_component_parameter_value} { puts "API $c"; catch {help $c} msg; puts $msg }\n'
(r/'api.tcl').write_text(t)
p=subprocess.run(['qsys-script','--script='+str(r/'api.tcl')],cwd=r,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(r/'api.log').write_text(p.stdout);print(p.stdout)
s=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/ed_sim/ed_sim_mem.ip');print(s.read_text()[:6500])
