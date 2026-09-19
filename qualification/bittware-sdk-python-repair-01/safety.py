import pathlib,ast
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');S=pathlib.Path.home()/'.local/lib/python3.9/site-packages'
for f in ['bw_agilex/bmc_handlers/__init__.py','bw_kit/__init__.py','bw_core/utils/common_argparse.py','bw_core/utils/entry_points.py','bw_agilex/bmc_handlers/bmc_handler.py']:
 p=S/f
 if p.exists():
  text=p.read_text();q=R/'source'/f;q.parent.mkdir(parents=True,exist_ok=True);q.write_text(text)
  tree=ast.parse(text);print('SOURCE',f)
  for n in tree.body:
   if not isinstance(n,(ast.FunctionDef,ast.ClassDef)):print(ast.get_source_segment(text,n))
print('REPAIR_LOG');print((R/'pip-check-after.txt').read_text() if (R/'pip-check-after.txt').exists() else 'NOT YET')
print('DONE')
