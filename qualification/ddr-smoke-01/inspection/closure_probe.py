for rel in ['ip_mem_model/ip_top/altera_emif_mem_model_hw.tcl','ip_top/ex_design/readme.txt']:
 p=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif')/rel
 print('VENDOR',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest());print(p.read_text())
import xml.etree.ElementTree as ET
ns={'i':'http://www.accellera.org/XMLSchema/IPXACT/1685-2014'}
for p in (r/'ipss/mem/qip/ed_sim').glob('*.ip'):
 print('MODEL_VALUES',p)
 for e in ET.parse(p).findall('.//i:parameter',ns):
  name=e.findtext('i:name','',ns);value=e.findtext('i:value','',ns)
  if re.search(r'^(PROTOCOL_ENUM|MEM_HAS_SIM_SUPPORT|SYS_INFO_DEVICE_FAMILY|MEM_FORMAT_ENUM|MEM_DDR4_FORMAT_ENUM|DIAG_FAST_SIM|DIAG_DDR4_SIM_CAL_MODE_ENUM|DIAG_SIM_CAL_MODE_ENUM|EX_DESIGN_GUI_GEN_SIM|MEM_DDR4_DQ_WIDTH)$',name): print(name,repr(value))
import subprocess
for name,simdir in [('mem_ss',r/'ipss/mem/qip/mem_ss/mem_ss/sim'),('ed_sim_mem',r/'ipss/mem/qip/ed_sim/ed_sim_mem/sim'),('ed_sim_mem_group1',r/'ipss/mem/qip/ed_sim/ed_sim_mem_group1/sim')]:
 script='source {'+str(simdir/'common/modelsim_files.tcl')+'}\n'
 script+='foreach x [dict values ['+name+'::get_common_design_files {} {} {} {'+str(simdir)+'}]] {puts $x}\n'
 script+='foreach x ['+name+'::get_design_files {} {} {} {'+str(simdir)+'} {/opt/altera/26.1.1/quartus}] {puts $x}\n'
 result=subprocess.run(['tclsh'],input=script,text=True,capture_output=True)
 print('SOURCE_CLOSURE',name,'RC',result.returncode,'STDERR',result.stderr)
 commands=result.stdout.splitlines();print('COMMAND_COUNT',len(commands))
 for cmd in commands:
  paths=re.findall(r'"([^\"]+)"',cmd)
  print('CMD',cmd)
  for s in paths:
   p=pathlib.Path(s)
   if p.is_file(): print('FILE',str(p.resolve()),p.stat().st_size,hashlib.sha256(p.read_bytes()).hexdigest())
   else: print('MISSING',s)
