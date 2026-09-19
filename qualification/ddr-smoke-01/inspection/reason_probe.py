v=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif')
for p in (v/'ip_mem_model').rglob('*'):
 if p.is_file():print('MODEL_IMPL_FILE',p,p.stat().st_size)
for rel in ['ip_top/ex_design/make_sim_design.tcl','ip_top/ex_design/make_qsys.tcl']:
 p=v/rel;lines=p.read_text().splitlines();print('EXAMPLE',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest())
 for n,l in enumerate(lines,1):
  if re.search(r'source|argv|param|ed_sim|FAST_SIM|generate|mem_model|top_level|tb|simulation',l,re.I):print(n,l)
p=r/'ofs-common/src/common/mem_tg/tg_axi_mem/mem_ss_tg/mem_ss_tg_axi_100/sim/altera_emif_avl_tg_2_tb.sv';print('TG_TB',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest());print(p.read_text()[:18000])
for p in (r/'ipss/mem/qip/mem_ss').rglob('*ekzngaq_top.sv'):
 if '/sim/' in str(p):
  lines=p.read_text().splitlines();print('TOP_FAST',p);print('\n'.join(f'{n+1} {lines[n]}' for n in range(2560,2635)))
