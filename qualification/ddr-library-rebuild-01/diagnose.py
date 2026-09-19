from pathlib import Path
import json,re,hashlib,importlib.util,subprocess
P=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');Q=P.parent/'ddr-library-rebuild-01';I=P.parent/'ddr-library-import-01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
w=I/'imports/quartus-23.1/tennm_atoms.sv';text=w.read_text()
old=(I/'run-05/elaborate-run.log').read_text();errors=[l for l in old.splitlines() if re.search(r'\b(?:error|fatal)\s*:',l,re.I)]
m=json.loads((P/'manifest.json').read_text());hits=[]
for x in m['inputs']:
 p=Path(x['path'])
 if p.suffix in ['.sv','.v','.tcl']:
  lines=p.read_text(errors='replace').splitlines(); selected=[{'line':i+1,'text':l} for i,l in enumerate(lines) if 'iossm_use_model' in l or 'EMIF_DISABLE_CAL_OPTIMIZATIONS' in l]
  if selected:hits.append({'path':str(p),'sha256':sha(p),'lines':selected})
r={'prior_errors':errors,'prior_error_count':len(errors),'wrapper_defines':[{'line':i+1,'text':l} for i,l in enumerate(text.splitlines()) if 'EMIF_DISABLE_CAL_OPTIMIZATIONS' in l or l.lstrip().startswith(('`ifdef','`ifndef','`define'))], 'generated_iossm_selection':hits,'tool_files':{str(p):{'resolved':str(p.resolve()),'sha256':sha(p)} for p in [Path('/opt/altera/26.1.1/questa_fe/bin')/n for n in ['vlog','vlib','vdir','vsim']]}}
(Q/'diagnosis.json').write_text(json.dumps(r,indent=2))
spec=importlib.util.spec_from_file_location('s',P/'run_smoke.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
base='\n'.join(['DDR_SMOKE_CHANNEL_DONE channel=%d writes=2 reads=2'%c for c in range(2)]+[s.PASS]);tests=[('valid',0,base,True),('timestamp_error',0,base+'\n[1] ERROR: model failure',False),('fatal',0,base+'\nInternal Fatal: failure',False),('missing_channel',0,s.PASS,False),('native_failure',12,base,False),('old_failure',12,old,False)]
results=[{'name':n,'expected':v,'actual':s.accepted(rc,t)} for n,rc,t,v in tests];assert all(x['actual']==x['expected'] for x in results)
(Q/'acceptance-tests.json').write_text(json.dumps(results,indent=2))
print('PRIOR_ERROR_COUNT',len(errors));print('\n'.join(errors));print('DEFINE_AND_SELECTION',json.dumps({k:r[k] for k in ['wrapper_defines','generated_iossm_selection']})[:10000]);print('TESTS',results)
