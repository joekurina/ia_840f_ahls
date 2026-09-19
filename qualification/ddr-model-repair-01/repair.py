import pathlib,subprocess,os,json,hashlib,shutil,time
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');src=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def run(label,cmd):
 (r/(label+'.invocation.json')).write_text(json.dumps({'argv':cmd,'cwd':str(r),'started':time.time()},indent=2))
 with (r/(label+'.log')).open('x') as f:p=subprocess.run(cmd,cwd=r,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240)
 (r/(label+'.status.json')).write_text(json.dumps({'returncode':p.returncode,'ended':time.time()}));print(label,p.returncode);print((r/(label+'.log')).read_text());assert p.returncode==0
files=list((src/'ipss/mem/qip').rglob('*.ip'))+list((src/'ipss/mem/qip').rglob('*.qsys'))+list((src/'ipss/mem/qip').rglob('*.v'))+list((src/'ipss/mem/qip').rglob('*.sv'))
(r/'work04-before.json').write_text(json.dumps({str(p):sha(p) for p in files},indent=2))
(r/'before').mkdir()
for name in ['ed_sim_mem','ed_sim_mem_group1']:
 p=src/'ipss/mem/qip/ed_sim'/(name+'.ip');shutil.copy2(p,r/'before'/p.name);shutil.copy2(p,r/p.name)
(r/'project.tcl').write_text('package require ::quartus::project\nproject_new model_repair -overwrite\nset_global_assignment -name FAMILY "Agilex 7"\nset_global_assignment -name DEVICE AGFB027R25A2E2V\nexport_assignments\nproject_close\n')
run('project',['quartus_sh','-t','project.tcl'])
(r/'repair.tcl').write_text('''package require -exact qsys 26.1
create_system model_repair
set_project_property DEVICE_FAMILY {Agilex 7}
set_project_property DEVICE AGFB027R25A2E2V
foreach name {ed_sim_mem ed_sim_mem_group1} {
 add_component $name ${name}.ip
 if {![load_component $name]} {error "Cannot load $name"}
 puts "BEFORE $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
 set_component_parameter_value SYS_INFO_DEVICE_FAMILY {Agilex 7}
 save_component
 puts "AFTER $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
}
save_system model_repair.qsys
''')
run('repair',['qsys-script','--quartus-project=model_repair.qpf','--script=repair.tcl'])
print('SCRATCH_IP_HASHES',{n:sha(r/n) for n in ['ed_sim_mem.ip','ed_sim_mem_group1.ip']})
