import pathlib,zipfile
root=pathlib.Path('/opt/altera/26.1.1/quartus')
for d in [root/'sopc_builder',root/'common/help']:
 for p in d.rglob('*'):
  if p.is_file() and p.suffix in ['.tcl','.html','.htm']:
   t=p.read_text(errors='replace')
   if 'load_component' in t and 'save_component' in t: print('DOC',p);print(t[:20000])
  elif p.suffix=='.jar' and ('qsys' in p.name.lower() or 'sopc' in p.name.lower()):
   with zipfile.ZipFile(p) as z:
    for n in z.namelist():
     if ('load_component' in n or 'save_component' in n or 'set_component_parameter_value' in n) and n.endswith(('.html','.xml','.txt')):print(p,n,z.read(n).decode(errors='replace'))
