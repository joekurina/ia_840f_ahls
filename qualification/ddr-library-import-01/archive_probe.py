from pathlib import Path
import tarfile,json,time,subprocess,sys
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');root=Path('/home/uwb_student00/Documents/IA-840f installation/')
# Streaming member-name inspection only; no extraction or vendor writes.
worker="""import tarfile,json,sys
p=sys.argv[1];rows=[];n=0
with tarfile.open(p,'r|gz') as t:
 for m in t:
  n+=1
  if m.name.rsplit('/',1)[-1] in ['tennm_atoms.sv','tennm_atoms_ncrypt.sv','fmica_atoms_ncrypt.sv','msim_setup.tcl','modelsim.ini','version.txt'] or ('tennm' in m.name and m.name.endswith('/_info')):rows.append({'name':m.name,'bytes':m.size,'type':str(m.type),'link':m.linkname})
print(json.dumps({'archive':p,'members_visited':n,'matches':rows},indent=2))
"""
p=root/'ia840f-ofs-hldasp-2023.1.2-002.tar.gz';start=time.time()
try:
 r=subprocess.run([sys.executable,'-c',worker,str(p)],stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,timeout=180);out={'rc':r.returncode,'stdout':r.stdout,'stderr':r.stderr,'seconds':time.time()-start,'timeout_s':180}
except subprocess.TimeoutExpired:out={'timed_out':True,'seconds':time.time()-start,'timeout_s':180,'archive':str(p),'complete':False}
(Q/'additional-archive-inventory.json').write_text(json.dumps(out,indent=2));print(json.dumps(out,indent=2)[:18000])
