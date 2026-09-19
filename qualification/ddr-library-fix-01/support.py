from pathlib import Path
import json,hashlib,subprocess,importlib.util
p=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');q=p.parent/'ddr-library-fix-01';t=Path('/opt/altera/26.1.1/questa_fe')
def sha(f):return hashlib.sha256(f.read_bytes()).hexdigest()
r={}
f=next(Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss').rglob('msim_setup.tcl'));s=f.read_text();a=s.find('alias dev_com');b=s.find('alias com',a)
r['generated_recipe']={'path':str(f),'sha256':sha(f),'dev_com':s[a:b],'precompiled_selection_lines':[l for l in s.splitlines() if any(x in l for x in ['ENABLE_QE_LIBRARY_COMPILATION','PRECOMP_DEVICE_LIB_FILE','FORCE_MODELSIM_AE_SELECTION','check_precomp_device'])]}
sim=Path('/opt/altera/26.1.1/quartus/eda/sim_lib');r['quartus_sim_lib']={str(f):{'size':f.stat().st_size,'sha256':sha(f)} for f in sim.iterdir() if f.is_file()}
r['missing_generated_pair']={str(sim/n):(sim/n).exists() for n in ['tennm_atoms.sv','mentor/tennm_atoms_ncrypt.sv']}
f=t/'intel/verilog/src/tennm_atoms.sv';ls=f.read_text().splitlines();r['installed_wrapper']={'path':str(f),'sha256':sha(f),'iossm_source':'\n'.join(f'{i+1}: {ls[i]}' for i in range(5968,6235))}
r['historical_hashes']={str(f.relative_to(p)):sha(f) for f in [p/'run_smoke.py',p/'manifest.json',p/'tb_mem_ss_smoke.sv',p/'accepted-review.json']+[p/n/k for n in ['run-01','run-02'] for k in ['result.json','elaborate-run.log']]}
spec=importlib.util.spec_from_file_location('smoke',p/'run_smoke.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
text=(p/'run-03/elaborate-run.log').read_text();r['acceptance_checks']={'real_run03_rejected':not m.accepted(12,text),'clean_exact_scoreboard':m.accepted(0,'\n'.join([m.PASS]+['DDR_SMOKE_CHANNEL_DONE channel=%d writes=2 reads=2'%i for i in range(2)])),'input_mismatches':m.check_inputs(json.loads((p/'manifest.json').read_text()))}
(q/'support-path-evidence.json').write_text(json.dumps(r,indent=2));print('CHECKS',r['acceptance_checks']);print('MISSING',r['missing_generated_pair']);print('HISTORY',r['historical_hashes']);print('EVIDENCE_SHA256',sha(q/'support-path-evidence.json'))
subprocess.run(['tmux','load-buffer','-b','ddr-library-fix-01-support',str(q/'support-path-evidence.json')],check=True)
