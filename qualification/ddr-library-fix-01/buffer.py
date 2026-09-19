from pathlib import Path
import subprocess
q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-fix-01')
subprocess.run(['tmux','load-buffer','-b','ddr-library-fix-01-export',str(q/'export.b64')],check=True)
print('BUFFER_READY')
