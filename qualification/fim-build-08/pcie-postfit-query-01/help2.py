from pathlib import Path
import subprocess,os
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01')
t='load_package sta\nforeach cmd {project_open create_timing_netlist read_sdc get_pins get_pin_info get_cell_info get_cells get_clock_info get_fanins} {puts "HELP_BEGIN $cmd"; puts [help $cmd]}\n'
(p/'help2.tcl').write_text(t)
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus'
r=subprocess.run(['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(p/'help2.tcl')],cwd=p,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=20)
(p/'api-help2.log').write_text(r.stdout)
for s in r.stdout.split('HELP_BEGIN'): print(s[:4200])
print('GATE',Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08/syn/board/ia840f/setup/build_gate.tcl').read_text())
