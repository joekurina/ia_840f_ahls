import pathlib,subprocess,os,json,time
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');env=os.environ.copy();env.update(json.loads((r/'environment.json').read_text()))
for n in ['ed_sim_mem','ed_sim_mem_group1']:
 cmd=['qsys-generate',n+'.ip','--simulation=VERILOG','--simulator=MODELSIM','--modelsim-flow=TRADITIONAL','--quartus-project=model_repair.qpf','--family=Agilex 7','--part=AGFB027R25A2E2V','--parallel=off'];label=n+'.final-generation'
 (r/(label+'.invocation.json')).write_text(json.dumps({'argv':cmd,'cwd':str(r),'started':time.time()},indent=2))
 with (r/(label+'.log')).open('x') as f:p=subprocess.run(cmd,cwd=r,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=240)
 (r/(label+'.status.json')).write_text(json.dumps({'returncode':p.returncode,'ended':time.time()}));text=(r/(label+'.log')).read_text();print(label,p.returncode);print(text);assert p.returncode==0 and 'ASSERTION ERROR' not in text and ' Error:' not in text
