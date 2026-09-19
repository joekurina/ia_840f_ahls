files=[p for p in r.rglob('*') if p.is_file()]
print('FILES',len(files))
for p in files:
    s=str(p.relative_to(r))
    if re.search(r'(testbench|(^|/)tb[^/]*|example|ed_sim|readme)',s,re.I):
        print(s,p.stat().st_size)
for rel in ['ipss/mem/qip/scripts/README.md','ipss/mem/qip/ed_sim/ed_sim_mem/sim/mentor/msim_setup.tcl','ipss/mem/qip/mem_ss/mem_ss/sim/mentor/msim_setup.tcl']:
    p=r/rel; print('\nSOURCE',rel,'SHA256',hashlib.sha256(p.read_bytes()).hexdigest()); print(p.read_text())
