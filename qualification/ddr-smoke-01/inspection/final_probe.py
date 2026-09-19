v=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif')
for rel in ['ip_mem_model/ip_top/main.tcl','ip_mem_model/ip_core_ddr4/main.tcl']:
 p=v/rel;print('VENDOR_SOURCE',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest());print(p.read_text())
import xml.etree.ElementTree as ET
ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
for p in (r/'ipss/mem/qip/ed_sim').glob('*.ip'):
 print('MODEL_FLAGS',p)
 for e in ET.parse(p).findall('.//i:parameter',ns):
  name=e.findtext('i:name','',ns);value=e.findtext('i:value','',ns)
  if re.search(r'^(FAMILY_ENUM|DIAG_USE_ABSTRACT_PHY|MEM_MODEL|PHY_CONFIG_ENUM|PHY_DDR4_REF_CLK_FREQ_MHZ|MEM_DDR4_ROW_ADDR_WIDTH|MEM_DDR4_COL_ADDR_WIDTH|MEM_DDR4_BANK_GROUP_WIDTH|MEM_DDR4_BANK_ADDR_WIDTH)$',name):print(name,repr(value))
print('ED_SIM_MODULE_DEFINITIONS')
for p in r.rglob('*'):
 if p.is_file() and p.suffix in ['.sv','.v']:
  text=p.read_text(errors='replace')
  if re.search(r'\bmodule\s+ed_sim\b',text):print(p)
print('PARAMS_FILES', [str(p.relative_to(r)) for p in r.rglob('params.tcl')])
