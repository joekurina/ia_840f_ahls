from pathlib import Path
import os,subprocess
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01')
s=(p/'api-help2.log').read_text();print(s[s.index('HELP_BEGIN project_open'):s.index('HELP_BEGIN get_pins')])
(p/'atoms-help.tcl').write_text('load_package atoms\nforeach c {read_atom_netlist get_atom_nodes get_atom_node_info} {puts [help $c]}\n')
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus'
r=subprocess.run(['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(p/'atoms-help.tcl')],cwd=p,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=20);(p/'atoms-help.log').write_text(r.stdout);print(r.stdout[:16000])
