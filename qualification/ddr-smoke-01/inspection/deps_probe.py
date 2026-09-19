import subprocess
simdir=r/'ipss/mem/qip/mem_ss/mem_ss/sim'
script='source {'+str(simdir/'common/modelsim_files.tcl')+'}\nforeach x [mem_ss::get_memory_files {'+str(simdir)+'} {/opt/altera/26.1.1/quartus}] {puts $x}\nputs "DPI [mem_ss::get_dpi_libraries {'+str(simdir)+'}]"\n'
z=subprocess.run(['tclsh'],input=script,text=True,capture_output=True)
print('MEMORY_FILES_RC',z.returncode,'STDERR',z.stderr)
for s in z.stdout.splitlines():
 if s.startswith('DPI'):print(s);continue
 p=pathlib.Path(s);print('MEMORY_FILE',str(p.resolve()),'EXISTS',p.is_file(),'SHA256',hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else '')
for p in (r/'ipss/mem/qip/mem_ss').rglob('*readme.txt'):
 if '/sim/' in str(p) and 'arch_fm' in str(p):
  print('EMIF_CONFIG',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest())
  for n,l in enumerate(p.read_text().splitlines(),1):
   if re.search(r'^\s+(PHY_DDR4_REF_CLK_FREQ_MHZ|MEM_DDR4_(FORMAT_ENUM|DQ_WIDTH|ROW_ADDR_WIDTH|COL_ADDR_WIDTH)|DIAG_(DDR4_SIM_CAL_MODE_ENUM|FAST_SIM|USE_ABSTRACT_PHY))\s+:',l):print(n,l)
for p in (r/'ipss/mem/qip/ed_sim').glob('*.ip'):
 print('MODEL_IP_HASH',p,hashlib.sha256(p.read_bytes()).hexdigest())
