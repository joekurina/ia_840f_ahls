import pathlib,xml.etree.ElementTree as E,json
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss')
for p in r.rglob('*emif_0.sopcinfo'):
 if '/sim/' not in str(p):continue
 t=E.parse(p);print(p);print(p.read_text()[:4000]);print([(m.attrib,len(m.findall('parameter'))) for m in t.findall('.//module')]);
 for m in t.findall('.//module'):
  if m.get('kind')=='altera_emif':print(E.tostring(m,encoding='unicode')[:5000])
