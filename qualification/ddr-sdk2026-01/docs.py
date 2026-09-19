from pathlib import Path
import json,zipfile,hashlib,subprocess,re,shutil
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01');out=Q/'documents';out.mkdir()
records=[]
def cmd(args,name):
 r=subprocess.run(args,capture_output=True,text=True,timeout=60);(out/name).write_text(r.stdout);records.append({'argv':args,'rc':r.returncode,'stderr':r.stderr,'output':name});return r.stdout
for args,n in [(['rpm','-q','--changelog','bittware-sdk'],'rpm-changelog.txt'),(['rpm','-qd','bittware-sdk'],'rpm-docfiles.txt'),(['rpm','-qpl','/home/uwb_student00/IA-840f/bittware-sdk-2026.1.0-1.el9.rpm'],'downloaded-rpm-files.txt'),(['rpm','-qpl','/home/uwb_student00/IA-840f/bittware-csp-ia840f-2024.3.1-1.el9.rpm'],'historical-csp-files.txt')]:
 text=cmd(args,n);print(n,text[:5000])
p=Path('/usr/share/bittware-sdk/python/bw_agilex_product-0.1.49-py3-none-any.whl')
with zipfile.ZipFile(p) as z:
 for n in z.namelist():
  if n.endswith('METADATA') or n in ['bw_agilex/data/IA-840F/IA-840F.yml','bw_agilex/products/ia840f_product.py']:
   b=z.read(n);dst=n.replace('/','__');(out/dst).write_bytes(b);records.append({'source':str(p),'member':n,'sha256':hashlib.sha256(b).hexdigest(),'output':dst});print(n,b.decode()[:11000])
p=Path('/home/uwb_student00/Documents/IA-840f installation/IA-840f_oneAPI_Support_Guide.pdf');records.append({'source':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
if shutil.which('pdftotext'):
 text=cmd(['pdftotext','-layout',str(p),'-'],'historical-oneapi-guide.txt')
 lines=text.splitlines();indexes=set()
 for i,l in enumerate(lines):
  if re.search(r'quartus|questa|modelsim|patch|simulat|version',l,re.I):indexes.update(range(max(0,i-2),min(len(lines),i+4)))
 print('GUIDE MATCHES','\n'.join(str(i+1)+':'+lines[i] for i in sorted(indexes))[:20000])
else:print('pdftotext absent')
(Q/'documents-provenance.json').write_text(json.dumps(records,indent=2))
