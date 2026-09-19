base=pathlib.Path('/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg')
for p in base.rglob('*'):
 if p.is_file() and p.suffix in ['.tcl','.terp','.txt','.sv']:
  s=p.read_text(errors='replace')
  if 'app_ss_cold_rst_n' in s and '`pragma protect' not in s:
   print('TEXTJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'text':s}))
