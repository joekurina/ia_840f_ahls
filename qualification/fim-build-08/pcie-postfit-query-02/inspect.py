from pathlib import Path
import os,socket
w=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08')
print(socket.gethostname(),os.getuid());print('ROOT',[(p.name,p.is_symlink(),str(p.resolve())) for p in w.iterdir()])
for rel in ['syn/board/ia840f/setup/build_gate.tcl','ofs-common/tools/ofss_config/ia840f_experimental_gate.py']:
 t=(w/rel).read_text();print(rel,t if rel.endswith('.tcl') else t[t.index('def main'):])
print('LINKS',[(str(p.relative_to(w)),os.readlink(p)) for p in w.rglob('*') if p.is_symlink()][:100])
