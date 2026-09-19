from pathlib import Path
import json,hashlib,subprocess,re
b=Path('/home/uwb_student00/ahls/new_BSP');e=b/'qualification/fim-build-08/pcie-postfit-query-02';s=e/'scratch'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
d=json.loads((e/'dependency-check.json').read_text());d['query01_missing_tcl_now_present'].pop('BMC arbiter_hw.tcl')
text=(e/'bmc-source.txt').read_text();block=text.split('foreach ia840f_bmc_source {')[1].split('} {')[0]
d['bmc_checked']={x:(s/'ipss/ia840f/bwbmc'/x).is_file() for x in block.split()};assert all(d['bmc_checked'].values());(e/'dependency-check.json').write_text(json.dumps(d,indent=2))
q=Path('/opt/altera/26.1.1/quartus/adm/qenv.sh');(e/'qenv-source.txt').write_text(q.read_text());r=json.loads((e/'candidate.json').read_text());r['files'][str(q)]=sha(q);r['callback_files'][str(q)]=sha(q)
# qenv source and closure record retained for parent review; still no authorization.
(e/'candidate.json').write_text(json.dumps(r,sort_keys=True,indent=2))
res=json.loads((e/'result.json').read_text());res['bound_files']=len(r['files']);res['dependency_checks_passed']=all(d['query01_missing_tcl_now_present'].values()) and all(d['bmc_checked'].values());(e/'result.json').write_text(json.dumps(res,indent=2))
print('\n'.join(x for x in q.read_text().splitlines() if 'CMD_NAME' in x or 'linux64' in x))
export=json.loads((e/'export-final.json').read_text())
for n in ['candidate.json','dependency-check.json','result.json','qenv-source.txt']:export[n]=(e/n).read_text()
(e/'export-reviewed-inputs.json').write_text(json.dumps(export));subprocess.run(['tmux','load-buffer','-b','query02_inputs_357',str(e/'export-reviewed-inputs.json')],check=True);print('FINAL_SHA',sha(e/'export-reviewed-inputs.json'),res)
