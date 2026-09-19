import base64
paths=list(r.rglob('mem_ss_reset_ctrl*.sv'))
for p in paths:
 s=p.read_text()
 if 'module ' in s: print('TEXTJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'text':s}))
ini=pathlib.Path('/opt/altera/26.1.1/questa_fe/modelsim.ini')
print('INIJSON '+json.dumps({'path':str(ini),'text':ini.read_text()}))
