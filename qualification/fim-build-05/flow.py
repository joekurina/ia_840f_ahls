from pathlib import Path
Q=Path('/opt/altera/26.1.1/quartus/common/tcl/internal')
for rel in ['flow/compile_flow.tcl','flow/dni_compile_flow.tcl','qsh_flowengine.tcl']:
 p=Q/rel; print('FILE',p);print(p.read_text())
