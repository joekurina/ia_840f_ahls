from pathlib import Path
p=Path('/home/uwb_student00/ahls/new_BSP/qualification')
for d in [p/'ddr-library-fix-01',p/'ddr-smoke-02/run-03']:
 print(str(d),[(f.name,f.stat().st_size) for f in d.iterdir() if f.is_file()])
