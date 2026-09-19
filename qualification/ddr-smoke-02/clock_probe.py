base=r/'ipss/mem/qip/mem_ss'
for p in base.rglob('*readme*'):
 if p.is_file():
  s=p.read_text(errors='replace')
  lines=s.splitlines(); hits=[l for l in lines if any(k in l for k in ['33.333','SIM_CAL_MODE','MHz'])]
  if hits: print('CLOCKJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'lines':hits}))
for p in base.rglob('*_top.sv'):
 if '/sim/' in str(p) and 'emif_' in p.name:
  s=p.read_text();hits=[l.strip() for l in s.splitlines() if any(k in l for k in ['DIAG_FAST_SIM','DIAG_USE_ABSTRACT_PHY','DIAG_SIM_CAL_MODE'])]
  if hits:print('MODEJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'lines':hits}))
