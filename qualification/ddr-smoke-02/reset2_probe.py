for base in [r/'ipss/mem',pathlib.Path('/opt/altera/26.1.1/ip/altera')]:
 for p in base.rglob('*reset*'):
  if p.is_file() and ('mem_ss' in str(p) or 'mem_reset' in str(p)) and p.suffix in ['.sv','.v','.tcl']:
   s=p.read_text(errors='replace')
   if 'module ' in s and 'app_ss_cold_rst_n' in s: print('TEXTJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'text':s}))
