import pathlib,json,subprocess,hashlib,os
P=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/jtag-recovery-preflight-01')
files=json.loads((P/'inventory.json').read_text()); hashes=[]
for x in files:
 f=pathlib.Path(x['path'])
 if f.suffix in ['.sof','.rpd','.pof','.jic','.pdf'] or str(f).endswith('/oneapi-asp/ia840f/README.md'):
  hashes.append(dict(path=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size))
 if f.suffix=='.pdf':
  r=subprocess.run(['pdftotext','-layout',str(f),'-'],text=True,capture_output=True,timeout=20)
  (P/(f.stem+'.txt')).write_text(r.stdout)
  lines=r.stdout.splitlines(); out=[]
  for i,l in enumerate(lines):
   if any(w in l.lower() for w in ['jtag','factory','recovery','usb-blaster','firmware mode','.jic','.pof']): out.append(str(i+1)+': '+'\n'.join(lines[max(0,i-2):i+5]))
  (P/(f.stem+'-hits.txt')).write_text('\n'.join(out)); print(f.name,r.returncode,'\n'.join(out)[:26000])
(P/'source-hashes.json').write_text(json.dumps(hashes,indent=2))
r=subprocess.run(['lspci','-nnk','-s','4f:00'],text=True,capture_output=True); (P/'target-pci.log').write_text(r.stdout);print(r.stdout)
print('HASHES',json.dumps(hashes))
