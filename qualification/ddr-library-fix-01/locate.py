from pathlib import Path
import os,json,subprocess,hashlib
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');q=p.parent/'ddr-library-fix-01';t=Path('/opt/altera/26.1.1/questa_fe');env=os.environ.copy();lic='/home/uwb_student00/quartus_26/LR-191011_License.dat'
env.update(SALT_LICENSE_SERVER=lic,LM_LICENSE_FILE=lic,MGLS_LICENSE_FILE=lic)
for tool in ['vopt','vsim']:
 r=subprocess.run([str(t/'bin'/tool),'-help'],env=env,cwd=q,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30);(q/(tool+'-help-licensed.log')).write_text(r.stdout)
 print(tool,'HELP',r.returncode, '\n'.join(l for l in r.stdout.splitlines() if any(x in l.lower() for x in ['libverbose','libmap','resolve','binding','search','verbose'])))
print('TOP_INSTALLS',[(str(d),[x.name for x in d.iterdir()]) for d in [Path('/opt'),Path('/home/uwb_student00/quartus_26')]])
found=[]
for d,ds,fs in os.walk('/opt/altera/26.1.1'):
 for n in fs:
  if ('tennm' in n.lower() and any(x in n.lower() for x in ['atom','ncrypt','model'])) or ('iossm' in n.lower() and 'model' in n.lower()):
   f=Path(d)/n;found.append({'path':str(f),'size':f.stat().st_size})
(q/'installed-source-candidates.json').write_text(json.dumps(found,indent=2));print('CANDIDATES',json.dumps(found))
# vdir runs against the original library with correct cwd; no compilation.
r=subprocess.run([str(t/'bin/vdir'),'-all','-ini',str(p/'run-02/modelsim.ini')],cwd=p/'run-02',stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30);(q/'vdir-all-correct-cwd.log').write_text(r.stdout)
lib='';hits=[]
for l in r.stdout.splitlines():
 if l.startswith('vdir for Library'):lib=l
 if 'iossm' in l.lower():hits.append([lib,l])
print('IOSSM_UNITS',hits)
print('DONE')
