from pathlib import Path
import os,hashlib,json,subprocess
w=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08')
e=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01'); e.mkdir(parents=True,exist_ok=False)
print('IDENTITY',os.uname().nodename,os.getuid())
p=w/'syn/board/ia840f/syn_top'
print('PROJECT',[(x.name,x.is_symlink()) for x in p.iterdir()]); print((p/'ofs_top.qsf').read_text())
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus';env['LM_LICENSE_FILE']='/home/uwb_student00/quartus_26/LR-191011_License.dat'
r=subprocess.run(['/opt/altera/26.1.1/quartus/bin/quartus_sta','--help'],cwd=e,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=20);(e/'sta-help.log').write_text(r.stdout); print(r.stdout)
