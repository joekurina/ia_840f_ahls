from pathlib import Path
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/run-03')
ls=(p/'elaborate-run.log').read_text().splitlines();hits=set()
for i,l in enumerate(ls):
 if any(x in l for x in ['tennm_iossm','builtin','Built-in','built-in','Errors:','Error loading']):
  hits.update(range(max(0,i-2),min(len(ls),i+4)))
print('\n'.join(f'{i+1}: {ls[i]}' for i in sorted(hits)))
print('DONE')
