base=r/'ipss/mem/qip'
paths=list((base/'ed_sim').rglob('*.v'))+list((base/'ed_sim').rglob('modelsim_files.tcl'))+[base/'mem_ss/mem_ss/sim/mem_ss.v',base/'mem_ss/mem_ss/sim/common/modelsim_files.tcl']
for p in paths:
 print('\nSOURCE',str(p.relative_to(r)),'SHA256',hashlib.sha256(p.read_bytes()).hexdigest());print(p.read_text())
print('\nHARNESS_CONTENT_SEARCH')
for p in r.rglob('*'):
 if p.is_file() and p.suffix in ['.sv','.v','.tcl','.sh','.txt','.md'] and p.stat().st_size<300000:
  text=p.read_text(errors='replace')
  hits=[(n,l) for n,l in enumerate(text.splitlines(),1) if re.search(r'ed_sim_mem|SIM_SKIP_CAL|SIM_CAL_MODE|SKIP_CALIBRATION|SHORT_SIM|example_design.*sim|sim.*example_design',l,re.I)]
  if hits: print(str(p.relative_to(r)),hits[:24])
