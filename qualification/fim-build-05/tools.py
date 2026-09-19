from pathlib import Path
import hashlib,json
Q=Path('/opt/altera/26.1.1/quartus')
for n in ['quartus_sh','quartus_ipgenerate','quartus_syn','quartus_fit','quartus_fit2','quartus_sta','quartus_asm','quartus_cdb','quartus_pow','quartus_eda','quartus_tlg']:
 p=Q/'linux64'/n
 print(n,p.exists(),str(p.resolve()),hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else '')
for p in (Q/'common/tcl/internal/flow').glob('*task.tcl'):
 for line in p.read_text().splitlines():
  if 'shell_command_template' in line and ('tlg' in line or 'dni' in line):print(p.name,line)
