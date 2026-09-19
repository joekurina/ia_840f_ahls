for p in (r/'ipss/mem/qip/ed_sim').glob('*.ip'):
 print('PARAMETERS',p)
 text=p.read_text()
 for n,l in enumerate(text.splitlines(),1):
  if re.search('PROTOCOL|PROTOCOL_ENUM|MEM_FORMAT|DEVICE_FAMILY|EMIF|MEM_DQ|ENABLE|SIM_|COMPONENT|component|generation|GENERAT',l): print(n,l[:500])
for p in (r/'ipss/mem/qip/ed_sim').rglob('*generation.rpt'):
 print('REPORT',p);print(p.read_text())
for parent in ['/opt/altera/26.1.1/quartus/../ip','/opt/altera/26.1.1/quartus/ip']:
 p=pathlib.Path(parent)
 print('INSTALL_ROOT',parent,p.exists())
 if p.exists():
  for d,dirs,files in os.walk(p):
   for f in files:
    if f=='altera_emif_mem_model_hw.tcl' or ('emif' in d.lower() and re.search(r'(example.*(tcl|txt)|readme)',f,re.I)):
     print('VENDOR',str(pathlib.Path(d)/f))
