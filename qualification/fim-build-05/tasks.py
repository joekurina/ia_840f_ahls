from pathlib import Path
import hashlib,json
Q=Path('/opt/altera/26.1.1/quartus/common/tcl/internal')
for p in Q.rglob('*.tcl'):
 if 'task' not in str(p):continue
 text=p.read_text(errors='replace')
 if any(x in text for x in ('quartus_ipgenerate','quartus_syn','quartus_fit','quartus_sta','quartus_asm','quartus_pow','quartus_eda','quartus_dni')):
  lines=text.splitlines();print('TASK',p)
  for i,x in enumerate(lines):
   if any(t in x for t in ('command','executable','arguments','cmd','quartus_')):print(i+1,x)
