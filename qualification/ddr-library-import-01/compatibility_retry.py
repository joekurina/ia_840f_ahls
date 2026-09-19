from pathlib import Path
import json,hashlib,re
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-import-01');j=json.loads((Q/'import-manifest.json').read_text());inv=json.loads((Q/'inventory.json').read_text())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
print('VERSION',j['version']);print('INCLUDES',j['includes'])
e={'version':j['version'],'includes':j['includes'],'recipes':[],'metadata':{},'encrypted_header':None,'ready_for_build':False}
paths=[Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss/mem_ss/sim/mentor/msim_setup.tcl')]+[Path(p) for p in inv['recipes'] if p.startswith('/home/uwb_student00/IA-840f/')]
for p in paths:
 if not p.exists():
  e['recipes'].append({'path':str(p),'exists':False,'symlink':str(p.readlink()) if p.is_symlink() else None});continue
 t=p.read_text();lines=[l for l in t.splitlines() if any(w in l for w in ['tennm_atoms','fmica_atoms','QUARTUS_VERSION','Generated','Quartus Prime'])];e['recipes'].append({'path':str(p),'sha256':sha(p),'lines':lines});print(p,lines)
for p in [Path('/opt/intelFPGA_pro/23.1/quartus/version.txt')]+[Path(p) for p in inv['metadata'] if p.startswith('/home/uwb_student00/IA-840f/')][:8]:
 e['metadata'][str(p)]={'sha256':sha(p),'text':p.read_text()[:2000]}
f=Path(j['imports'][1]['copy']);e['encrypted_header']=f.open().read(4000);print('ENCRYPTED HEADER',e['encrypted_header'][:1400]);print('VENDOR_CANDIDATES',[x for x in inv['candidates'] if '/IA-840f/' in x['path']]);(Q/'compatibility-evidence.json').write_text(json.dumps(e,indent=2))
