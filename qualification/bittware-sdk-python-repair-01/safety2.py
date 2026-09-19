import pathlib,ast
S=pathlib.Path.home()/'.local/lib/python3.9/site-packages';R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01')
for f in ['bw_kit/kits.py','bw_kit/kit.py','bw_kit/device_entry.py','bw_agilex/bmc_handlers/bmc_agilex_handler.py','bw_agilex/bmc_handlers/bmc30_agilex_handler.py','bw_core/utils/common_argparse.py']:
 p=S/f;text=p.read_text();q=R/'source'/f;q.parent.mkdir(parents=True,exist_ok=True);q.write_text(text);print('SOURCE',f)
 for n in ast.parse(text).body:
  if isinstance(n,ast.ClassDef):
   print('CLASS',n.name)
   for z in n.body:
    if not isinstance(z,(ast.FunctionDef,ast.AsyncFunctionDef)):print(ast.get_source_segment(text,z))
  elif not isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef)):print(ast.get_source_segment(text,n))
  if isinstance(n,ast.FunctionDef) and n.name=='add_common_arguments':print(ast.get_source_segment(text,n))
print('DONE')
