import os, pathlib, subprocess, json, hashlib, datetime
P=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/jtag-recovery-preflight-01')
P.mkdir(parents=True,exist_ok=False)
os.chdir(P)
env=os.environ.copy(); env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus'; env['PATH']='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/questa_fe/bin:'+env['PATH']
records=[]
def run(name,cmd):
 try:
  r=subprocess.run(cmd,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=25); out=r.stdout; rc=r.returncode
 except subprocess.TimeoutExpired as e: out=str(e.stdout); rc=124
 (P/(name+'.log')).write_text(out); records.append(dict(name=name,command=cmd,exit=rc)); print(name,rc,out[:16000],flush=True)
run('identity',['bash','-c','hostname; id; command -v jtagconfig quartus_pgm; readlink -f $(command -v jtagconfig); quartus_pgm --version; ps -eo pid,user,args | /usr/bin/python3 -c "import sys; print(\"\".join(l for l in sys.stdin if \"jtagd\" in l))"'])
run('jtagconfig-help',['jtagconfig','--help'])
run('programmer-help',['quartus_pgm','--help'])
(P/'commands.json').write_text(json.dumps(records,indent=2))
roots=[pathlib.Path('/home/uwb_student00/IA-840f'),pathlib.Path('/home/uwb_student00/Documents/IA-840f installation'),pathlib.Path('/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F')]
files=[]
for root in roots:
 for base,dirs,names in os.walk(root):
  dirs[:]=[d for d in dirs if d not in ['.git','db','incremental_db','__pycache__']]
  for name in names:
   f=pathlib.Path(base)/name
   if f.suffix.lower() in ['.pdf','.md','.txt','.rst','.sof','.pof','.jic','.rbf','.rpd'] or 'readme' in name.lower():
    s=f.stat(); files.append(dict(path=str(f),bytes=s.st_size))
(P/'inventory.json').write_text(json.dumps(files,indent=2)); print('INVENTORY',json.dumps(files),flush=True)
