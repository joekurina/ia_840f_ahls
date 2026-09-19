from pathlib import Path
import subprocess,json,re,hashlib,os
q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-fix-01');t=Path('/opt/altera/26.1.1/questa_fe')
for n in ['vopt-help-licensed.log','vsim-help-licensed.log']:print(n,(q/n).read_text()[:5000])
for f in [t/'readme.txt',t/'RELEASE_NOTES.txt']:
 s=f.read_text(errors='replace');print('DOC',str(f));print('\n'.join(l for l in s.splitlines() if any(x in l.lower() for x in ['precompil','builtin','built-in','encrypted','26.1','iossm'])))
print('DOC_FILES',[(f.name,f.stat().st_size) for f in (t/'docs').iterdir()])
for d in [Path('/opt/intelFPGA_pro'),Path('/opt/intel')]:print('OTHER',str(d),[x.name for x in d.iterdir()])
f=t/'intel/verilog/src/tennm_atoms.sv';s=f.read_text();ls=s.splitlines();print('\n'.join(f'{i+1} {ls[i]}' for i in range(5940,6012)))
# compare installed tennm vs tennm_sm compilation provenance, not retargeting family
for lib in ['tennm','tennm_sm']:
 r=subprocess.run([str(t/'bin/vdir'),'-l','-lib',str(t/'intel/verilog'/lib),'tennm_iossm'],cwd=q,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30);(q/(lib+'-iossm-vdir.log')).write_text(r.stdout);print(lib,r.stdout)
print('DONE')
