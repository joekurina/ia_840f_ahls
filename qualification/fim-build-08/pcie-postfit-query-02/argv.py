from pathlib import Path
import json,hashlib,subprocess
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-02')
r=json.loads((E/'candidate.json').read_text());r['runtime_argv'][0]='quartus_sta';r['runtime_argv_status']='launcher CMD_NAME=basename and eval exec; qenv PATH selects linux64; native confirmation pending'
q=Path('/opt/altera/26.1.1/quartus/adm/qtb.sh')
if q.exists():
 (E/'qtb-source.txt').write_text(q.read_text());h=hashlib.sha256(q.read_bytes()).hexdigest();r['files'][str(q)]=h;r['callback_files'][str(q)]=h
(E/'candidate.json').write_text(json.dumps(r,sort_keys=True,indent=2));z=json.loads((E/'result.json').read_text());z['bound_files']=len(r['files']);(E/'result.json').write_text(json.dumps(z,indent=2))
v=json.loads((E/'export-reviewed-inputs.json').read_text())
for n in ['candidate.json','result.json']+(['qtb-source.txt'] if q.exists() else []):v[n]=(E/n).read_text()
(E/'export-final-v2.json').write_text(json.dumps(v));subprocess.run(['tmux','load-buffer','-b','query02_final_v2_357',str(E/'export-final-v2.json')],check=True);print('FINAL_V2',hashlib.sha256((E/'export-final-v2.json').read_bytes()).hexdigest(),z)
