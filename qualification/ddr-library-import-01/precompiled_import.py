from pathlib import Path
import json,hashlib,shutil,subprocess,os
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');D=Path('/opt/intelFPGA_pro/23.1/questa_fe/intel/verilog/tennm');I=Q/'imports/precompiled-23.1/tennm'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
 return h.hexdigest()
rows={str(p.relative_to(D)):{'bytes':p.stat().st_size,'sha256':sha(p)} for p in D.rglob('*') if p.is_file()};print('CANDIDATE_PRECOMPILED',len(rows),sum(x['bytes'] for x in rows.values()),flush=True)
I.parent.mkdir(parents=True,exist_ok=False);shutil.copytree(D,I)
assert all(sha(I/n)==v['sha256'] for n,v in rows.items())
j={'source':str(D),'copy':str(I),'files':rows,'source_version':'23.1.0 Build115 patched0.02iofs,0.10,0.30','wrapper_and_encrypted_source_hashes_match_quartus_donor':True};(Q/'precompiled-import-manifest.json').write_text(json.dumps(j,indent=2))
env=os.environ.copy();env.update(MODELSIM=str(Q.parent/'ddr-smoke-02/run-02/modelsim.ini'))
r=subprocess.run(['/opt/altera/26.1.1/questa_fe/bin/vdir','-l','-lib',str(I),'tennm_iossm'],cwd=Q,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30)
(Q/'precompiled-vdir.log').write_text(r.stdout);print('VDIR_RC',r.returncode);print(r.stdout[:7000])
if (Q/'run-04/result.json').exists():
 j=json.loads((Q/'run-04/result.json').read_text());print('RUN04',{k:v for k,v in j.items() if k not in ['reuse','steps','imports']})
