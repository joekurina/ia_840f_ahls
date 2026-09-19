from pathlib import Path
import json,hashlib,base64,gzip,subprocess,re
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-rebuild-01');P=Q.parent/'ddr-smoke-02';I=Q.parent/'ddr-library-import-01';O=Q/'run-06'
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(8388608),b''):h.update(b)
 return h.hexdigest()
def inv(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
assert (Q/'launch-result.json').exists()
r=json.loads((O/'result.json').read_text());diag=re.compile(r'\b(?:error|fatal)\s*(?:\([^)]*\))?\s*:',re.I)
logs={p.name:{'sha256':sha(p),'errors':[l for l in p.read_text(errors='replace').splitlines() if diag.search(l)],'warnings':[l for l in p.read_text(errors='replace').splitlines() if re.search(r'\bWarning\s*(?:\([^)]*\))?\s*:',l,re.I)],'summaries':re.findall(r'Errors:\s*\d+, Warnings:\s*\d+',p.read_text(errors='replace'))} for p in O.glob('*.log')}
checks={'attempt_after_inventory_matches':inv(O/'libraries')==json.loads((O/'libraries-after.json').read_text()),'reuse_original_matches':inv(P/'run-02/libraries')==r['reuse']['library_sha256'],'bound_files_match':all(sha(Path(p))==h for p,h in json.loads((Q/'accepted-review.json').read_text())['bound_files'].items()),'source_trio_match':all(sha(Path(x['source']))==sha(Path(x['copy']))==x['sha256'] for x in r['imports'])};assert all(checks.values())
summary={'pass':False,'ready_for_build':False,'hardware_qualified':False,'candidate_compile_pass':r.get('candidate_compile_pass',False),'elaboration_attempted':(O/'elaborate-run.log').exists(),'simulation_ran':False,'channel_completion_markers':0,'pass_markers':0,'steps':[dict(x,elapsed_s=x['finished']-x['started']) for x in r['steps']],'elapsed_attempt_s':r['finished']-r['started'],'logs':logs,'readback_checks':checks,'stop_reason':'4 vlog-13488 incorrect-size integer literal errors inside protected source; no authorized semantics-preserving visible correction. No suppress/decrypt/patch. Third dependency and elaboration not reached.'}
(Q/'execution-summary.json').write_text(json.dumps(summary,indent=2))
(Q/'all-files-readback.json').write_text(json.dumps(inv(O),indent=2))
files=[p for p in Q.iterdir() if p.is_file() and p.suffix in ['.json','.py','.log']]
files += [p for p in O.iterdir() if p.is_file() and p.suffix in ['.json','.log','.ini','.do']]
rows={str(p.relative_to(Q)):{'sha256':sha(p),'data':base64.b64encode(p.read_bytes()).decode()} for p in files}
data=base64.b64encode(gzip.compress(json.dumps(rows).encode()));f=Q/'evidence-export.b64';f.write_bytes(data)
subprocess.run(['tmux','load-buffer','-b','ddr_library_rebuild_01_evidence',str(f)],check=True)
receipt={'export_sha256':sha(f),'bytes':len(data),'files':len(rows),'buffer':'ddr_library_rebuild_01_evidence'};(Q/'export-receipt.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt));print(json.dumps({k:v for k,v in summary.items() if k not in ['logs','steps']},indent=2))
