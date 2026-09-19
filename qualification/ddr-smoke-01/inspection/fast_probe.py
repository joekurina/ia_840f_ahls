v=pathlib.Path('/opt/altera/26.1.1/ip/altera/emif')
for p in (v/'ip_mem_model').rglob('*.tcl'):
 text=p.read_text(errors='replace')
 if 'proc composition_callback' in text or 'DIAG_FAST_SIM' in text:
  print('VENDOR_SOURCE',p,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest())
  lines=text.splitlines(); hits=set()
  for n,l in enumerate(lines):
   if re.search(r'composition_callback|DIAG_FAST_SIM|MEM_HAS_SIM_SUPPORT',l):hits.update(range(max(0,n-6),min(len(lines),n+32)))
  for n in sorted(hits):print(n+1,lines[n])
for p in (r/'ipss/mem/qip/mem_ss').rglob('*'):
 if p.is_file() and '/sim/' in str(p) and p.suffix in ['.sv','.v','.txt']:
  text=p.read_text(errors='replace')
  lines=text.splitlines()
  hits=[(n,l) for n,l in enumerate(lines,1) if re.search(r'DIAG_FAST_SIM|ABSTRACT|abphy|FAST_SIM_MODEL|SIM_CAL_MODE|SKIP_CALIB',l,re.I)]
  if hits:print('FAST_SIM',str(p.relative_to(r)),hits[:18])
print('EXAMPLE_FILES')
for p in (v/'ip_top/ex_design').iterdir(): print(p.name)
print('WORK04_HARNESS_NAMES', [str(p.relative_to(r)) for p in r.rglob('*') if p.is_file() and re.search(r'(make_sim_design|ed_sim_tb|emif.*tb|tb.*emif|mem.*testbench|testbench.*mem)',p.name,re.I)])
