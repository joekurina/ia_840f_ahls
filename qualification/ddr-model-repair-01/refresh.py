import pathlib,subprocess,os,json,time,hashlib
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
t=['package require -exact qsys 26.1','load_system model_repair.qsys']
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 d=json.loads((r/(n+'.controller-parameters.json')).read_text());updates={k:x['actual']['value'] for k,x in d['diff'].items() if (x['actual']['derived']=='true' and k!='DIAG_SIM_VERBOSE_LEVEL') or k.startswith('TRAIT_') or (k.startswith('SYS_INFO_DEVICE'))}
 # Values are literal Tcl brace words, never hand-edited IP XML.
 assert all('{' not in v and '}' not in v for v in updates.values())
 (r/(n+'.approved-derived-refresh.json')).write_text(json.dumps(updates,indent=2))
 t+=['load_component '+n]+['set_component_parameter_value '+k+' {'+v+'}' for k,v in updates.items()]+['save_component','reload_component_footprint '+n]
t+=['save_system model_repair.qsys'];(r/'repair3.tcl').write_text('\n'.join(t)+'\n')
def run(label,cmd):
 (r/(label+'.invocation.json')).write_text(json.dumps({'argv':cmd,'cwd':str(r),'started':time.time()},indent=2))
 with (r/(label+'.log')).open('x') as f:p=subprocess.run(cmd,cwd=r,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240)
 (r/(label+'.status.json')).write_text(json.dumps({'returncode':p.returncode,'ended':time.time()}));print(label,p.returncode);print((r/(label+'.log')).read_text());assert p.returncode==0
run('repair3',['qsys-script','--quartus-project=model_repair.qpf','--script=repair3.tcl'])
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 run(n+'.generation',['qsys-generate',n+'.ip','--simulation=VERILOG','--simulator=MODELSIM','--modelsim-flow=TRADITIONAL','--quartus-project=model_repair.qpf','--family=Agilex 7','--part=AGFB027R25A2E2V','--parallel=off'])
