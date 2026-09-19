from pathlib import Path
import json,subprocess,os,hashlib
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');q=p.parent/'ddr-library-fix-01';t=Path('/opt/altera/26.1.1/questa_fe')
def cmd(args,name):
 r=subprocess.run(args,cwd=q,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=30);(q/(name+'.log')).write_text(r.stdout);print(name,'RC',r.returncode);return r.stdout
s=cmd([str(t/'bin/vopt'),'-help'],'vopt-help')
print('\n'.join(l for l in s.splitlines() if any(x in l.lower() for x in ['libverbose','libmap','resolve','binding','search','verbose'])))
s=cmd([str(t/'bin/vdir'),'-all','-ini',str(p/'run-02/modelsim.ini')],'vdir-all');print('\n'.join(l for l in s.splitlines() if any(x in l.lower() for x in ['iossm','library','encrypted'])))
f=t/'modelsim.ini';print('INI',f.read_text()[:19000])
for d in [t,Path('/opt/altera'),Path('/opt/altera/26.1.1')]:print('INSTALL_DIR',str(d),[x.name for x in d.iterdir()])
for f in Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss').rglob('msim_setup.tcl'):
 s=f.read_text();start=s.find('alias dev_com');end=s.find('alias com',start);print('DEV_COM',str(f),'SHA',hashlib.sha256(f.read_bytes()).hexdigest(),s[start:end][:20000]);break
print('DONE')
