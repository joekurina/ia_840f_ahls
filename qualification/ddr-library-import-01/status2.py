from pathlib import Path
import json
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01')
print((Q/'launch.log').read_text());print('FILES',[p.name for p in Q.iterdir()])
