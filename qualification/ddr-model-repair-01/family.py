import pathlib,re
root=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif')
for p in root.rglob('*.tcl'):
 if p.name in ['device_family.tcl','exports.tcl'] or ('parameter' in p.name):
  t=p.read_text(errors='replace')
  if p.name=='device_family.tcl': print('FILE',p);print(t[:25000])
for p in [pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/ed_sim/ed_sim_mem.ip')]:
 import xml.etree.ElementTree as E
 ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
 d={x.find('i:name',ns).text:x.find('i:value',ns).text for x in E.parse(p).findall('.//i:parameter',ns)}
 print('PARAMS',[(k,v) for k,v in d.items() if any(s in k for s in ['WIDTH','FAMILY','PHY_CONFIG','FORMAT','CAL_MODE','FAST_SIM','ECC','MEM_SIZE'])])
