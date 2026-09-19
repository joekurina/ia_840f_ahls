import pathlib,subprocess,os,json,hashlib,time,xml.etree.ElementTree as ET
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
def params(p):return {x.find('i:name',ns).text:x.find('i:value',ns).text for x in ET.parse(p).findall('.//i:parameter',ns)}
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 a=params(r/'before'/(n+'.ip'));b=params(r/(n+'.ip'));diff={k:[a.get(k),b.get(k)] for k in a.keys()|b.keys() if a.get(k)!=b.get(k)};print(n,'DIFF',json.dumps(diff,indent=2));(r/(n+'.parameter-diff.json')).write_text(json.dumps(diff,indent=2))
(r/'repair2.tcl').write_text('''package require -exact qsys 26.1
load_system model_repair.qsys
foreach name {ed_sim_mem ed_sim_mem_group1} {
 if {![load_component $name]} {error "Cannot load $name"}
 puts "READBACK $name [get_component_parameter_value SYS_INFO_DEVICE_FAMILY]"
 if {[get_component_parameter_value SYS_INFO_DEVICE_FAMILY] ne "Agilex 7"} {error "Bad family"}
 save_component
 reload_component_footprint $name
}
save_system model_repair.qsys
''')
cmd=['qsys-script','--quartus-project=model_repair.qpf','--script=repair2.tcl'];(r/'repair2.invocation.json').write_text(json.dumps({'argv':cmd,'cwd':str(r)}))
p=subprocess.run(cmd,cwd=r,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=240);(r/'repair2.log').write_text(p.stdout);(r/'repair2.status.json').write_text(json.dumps({'returncode':p.returncode}));print(p.stdout);assert p.returncode==0
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 cmd=['qsys-generate',n+'.ip','--simulation=VERILOG','--simulator=MODELSIM','--modelsim-flow=TRADITIONAL','--quartus-project=model_repair.qpf','--family=Agilex 7','--part=AGFB027R25A2E2V','--parallel=off'];(r/(n+'.invocation.json')).write_text(json.dumps({'argv':cmd,'cwd':str(r),'started':time.time()},indent=2))
 with (r/(n+'.generation.log')).open('x') as f:p=subprocess.run(cmd,cwd=r,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240)
 (r/(n+'.status.json')).write_text(json.dumps({'returncode':p.returncode,'ended':time.time()}));print(n,p.returncode);print((r/(n+'.generation.log')).read_text());assert p.returncode==0
