from pathlib import Path
import hashlib,json,shutil,re,subprocess
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');D=Path('/opt/intelFPGA_pro/23.1/quartus/eda/sim_lib');I=Q/'imports/quartus-23.1';I.mkdir(parents=True,exist_ok=False)
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
 return h.hexdigest()
rows=[]
for n in ['tennm_atoms.sv','mentor/tennm_atoms_ncrypt.sv','fmica_atoms_ncrypt.sv']:
 src=D/n;dst=I/n;dst.parent.mkdir(parents=True,exist_ok=True);h=sha(src);shutil.copyfile(src,dst);assert sha(dst)==h
 rows.append({'source':str(src),'copy':str(dst),'bytes':src.stat().st_size,'sha256':h});print('IMPORTED',rows[-1],flush=True)
text=(I/'tennm_atoms.sv').read_text();match=re.search(r'(?ms)^module tennm_iossm\b.*?^endmodule',text)
(Q/'donor-iossm-wrapper.txt').write_text(match.group(0) if match else 'NOT FOUND')
evidence={'imports':rows,'includes':re.findall(r'`include\s+"([^"]+)"',text),'header':text[:2000],'version_path':str(D.parents[1]),'version':subprocess.run(['/opt/intelFPGA_pro/23.1/quartus/bin/quartus_sh','--version'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30).stdout}
for f in [Path('/home/uwb_student00/IA-840f/readme.txt'),Path('/home/uwb_student00/IA-840f/setup_pro.sh')]:
 evidence[str(f)]={'sha256':sha(f),'text':f.read_text()[:15000]}
(Q/'import-manifest.json').write_text(json.dumps(evidence,indent=2));print(json.dumps(evidence,indent=2));print('IMPORT_DONE')
