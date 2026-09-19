import pathlib,xml.etree.ElementTree as E
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip')
for p in r.rglob('*'):
 if p.suffix in ['.qsys','.sopcinfo']:
  print('FILE',p)
  if p.suffix=='.qsys':
   t=E.parse(p)
   for m in t.findall('.//module'):
    if 'emif' in str(m.attrib).lower():print(m.attrib);print(E.tostring(m,encoding='unicode')[:1800])
