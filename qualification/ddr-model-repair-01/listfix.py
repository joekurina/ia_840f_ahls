import pathlib,subprocess,os,json,time,shutil
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
t=['package require -exact qsys 26.1','load_system model_repair.qsys']
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 u=json.loads((r/(n+'.approved-derived-refresh.json')).read_text());t+=['load_component '+n]
 for k,v in u.items():
  if k=='SYS_INFO_DEVICE_DIE_REVISIONS' or '_DERIVED_ODT' in k:t+=['set_component_parameter_value '+k+' [list '+' '.join('{'+x+'}' for x in v.split(','))+']']
 t+=['save_component','reload_component_footprint '+n]
t+=['save_system model_repair.qsys'];(r/'repair4.tcl').write_text('\n'.join(t)+'\n')
def run(label,cmd):
 (r/(label+'.invocation.json')).write_text(json.dumps({'argv':cmd,'cwd':str(r),'started':time.time()},indent=2))
 with (r/(label+'.log')).open('x') as f:p=subprocess.run(cmd,cwd=r,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240)
 (r/(label+'.status.json')).write_text(json.dumps({'returncode':p.returncode,'ended':time.time()}));print(label,p.returncode);text=(r/(label+'.log')).read_text();print(text);assert p.returncode==0 and 'ASSERTION ERROR' not in text and ' Error:' not in text
run('repair4',['qsys-script','--quartus-project=model_repair.qpf','--script=repair4.tcl'])
(r/'intermediate-generation').mkdir()
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 shutil.move(str(r/n),str(r/'intermediate-generation'/n))
 run(n+'.final-generation',['qsys-generate',n+'.ip','--simulation=VERILOG','--simulator=MODELSIM','--modelsim-flow=TRADITIONAL','--quartus-project=model_repair.qpf','--family=Agilex 7','--part=AGFB027R25A2E2V','--parallel=off'])
