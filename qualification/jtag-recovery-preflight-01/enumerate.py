import os,pathlib,subprocess,json,hashlib
P=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/jtag-recovery-preflight-01'); os.chdir(P)
env=os.environ.copy(); env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus'; env['PATH']='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/questa_fe/bin:'+env['PATH']
records=json.loads((P/'commands.json').read_text())
def run(name,cmd):
 try:
  r=subprocess.run(cmd,env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=25); out=r.stdout; rc=r.returncode
 except subprocess.TimeoutExpired as e: out=str(e.stdout); rc=124
 (P/(name+'.log')).write_text(out); records.append(dict(name=name,command=cmd,exit=rc)); print(name,rc,out[:18000],flush=True)
run('jtagconfig-version',['jtagconfig','--version'])
run('jtagconfig-enumeration',['jtagconfig'])
run('programmer-list',['quartus_pgm','--list'])
run('usb',['lsusb'])
run('pci',['lspci','-nnk','-d','8086:'])
r=subprocess.run(['ps','-eo','pid,user,args'],text=True,capture_output=True); text='\n'.join(l for l in r.stdout.splitlines() if 'jtagd' in l); (P/'jtagd.log').write_text(text); print(text)
roots=[pathlib.Path('/home/uwb_student00/IA-840f'),pathlib.Path('/home/uwb_student00/Documents/IA-840f installation'),pathlib.Path('/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F')]
files=[]; hits=[]
for root in roots:
 for base,dirs,names in os.walk(root):
  dirs[:]=[d for d in dirs if d not in ['.git','db','incremental_db','__pycache__','work-ofs-23.1-2-build']]
  for name in names:
   f=pathlib.Path(base)/name
   if f.suffix.lower() in ['.pdf','.md','.txt','.rst','.sof','.pof','.jic','.rbf','.rpd'] or 'readme' in name.lower():
    try: s=f.stat()
    except OSError: continue
    files.append(dict(path=str(f),bytes=s.st_size))
    if f.suffix.lower() in ['.md','.txt','.rst'] and s.st_size<2000000:
     lines=f.read_text(errors='replace').splitlines()
     for i,l in enumerate(lines):
      if any(x in l.lower() for x in ['jtag','factory','recovery','.pof','.jic','quartus_pgm','flash mode']):
       hits.append({'path':str(f),'line':i+1,'text':'\n'.join(lines[max(0,i-2):i+4])})
(P/'inventory.json').write_text(json.dumps(files,indent=2)); (P/'source-hits.json').write_text(json.dumps(hits,indent=2)); (P/'commands.json').write_text(json.dumps(records,indent=2))
print('FILES',json.dumps([f for f in files if not any(x in f['path'] for x in ['/ip/','/src/'])])[:30000]); print('HITS',json.dumps(hits)[:40000],flush=True)
