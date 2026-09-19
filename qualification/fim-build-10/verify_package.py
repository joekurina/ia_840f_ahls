"""Verify exported candidate without issuing authorization or running vendor tools."""
from pathlib import Path
import hashlib,json,difflib,ast
E=Path(__file__).parent;R=E/'remote-evidence';P=E.parent/'fim-build-09/remote-evidence'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((R/'export-sha256.json').read_text())
assert len(manifest)==44
for r,h in manifest.items():assert sha(R/r)==h,r
over=json.loads((R/'overlay-sha256.json').read_text());before=json.loads((R/'source-before.json').read_text())
draft=json.loads((R/'compile-authorization.draft.json').read_text());prior=json.loads((P/'compile-authorization.draft.json').read_text())
patch='';changed=[]
for r,h in over.items():
 assert sha(R/'source-overlay'/r)==h and sha(R/'source-before'/r)==before[r]
 a=(R/'source-before'/r).read_text();b=(R/'source-overlay'/r).read_text()
 if a!=b:changed.append(r)
 patch+=''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+r,tofile='b/'+r))
 t,rest=r.split('/',1);assert draft['source_sha256'][t][rest]==h
 assert draft['work_inventory'][r]=={'sha256':h}
assert patch==(R/'candidate.patch').read_text()
q='syn/board/ia840f/syn_top/ofs_top.qsf'
assert (R/'source-before'/q).read_text().replace('set_global_assignment -name SEED 1\n','set_global_assignment -name SEED 2\n')==(R/'source-overlay'/q).read_text()
assert sha(R/'source-before'/q)=='ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3'
assert 'SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT' in (R/'source-overlay'/q).read_text()
retarget=lambda t:t.replace('fim-build-09','fim-build-10').replace('work_ia840f_fim_09','work_ia840f_fim_10').replace('Work09','Work10')
for r in changed:
 if r!=q:assert retarget((R/'source-before'/r).read_text())==(R/'source-overlay'/r).read_text()
assert len(changed)==3 and len(draft['contexts'])==135
assert draft['contexts']==json.loads(retarget(json.dumps(prior['contexts'])))
source_changes=[t+'/'+r for t,items in draft['source_sha256'].items() for r,h in items.items() if prior['source_sha256'][t].get(r)!=h]
assert sorted(source_changes)==sorted(changed)
assert draft['work_inventory']==json.loads((R/'staged-work-inventory.json').read_text())
for name in ['issue_authorization.py','launch_native_compile.py']:
 ast.parse((R/name).read_text());assert retarget((P/name).read_text())==(R/name).read_text()
 assert draft['dependency_sha256']['/home/uwb_student00/ahls/new_BSP/qualification/fim-build-10/'+name]==sha(R/name)
for key in ['approved','accepted_execution','ready_for_build','source_review_consumed','gate_review_consumed']:assert draft[key] is False
cases=json.loads((R/'real-dispatch-tests.log').read_text())['cases'];invocations=[c for c in cases if 'rc' in c]
summary=dict(exported_files_verified=len(manifest),overlay_files=len(over),changed_files=changed,contexts=len(draft['contexts']),work_inventory_entries=len(draft['work_inventory']),dependency_pins=len(draft['dependency_sha256']),dispatch_invocations=len(invocations),dispatch_positive=sum(c['rc']==0 for c in invocations),dispatch_negative=sum(c['rc']!=0 for c in invocations),missing_record_cases=len(json.loads((R/'missing-work10-record-tests.json').read_text())),patch_sha256=sha(R/'candidate.patch'),qsf_sha256=sha(R/'source-overlay'/q),issuer_sha256=sha(R/'issue_authorization.py'),runner_sha256=sha(R/'launch_native_compile.py'),draft_sha256=sha(R/'compile-authorization.draft.json'),ready_for_build=False,authorized=False,launched=False)
(E/'local-verification.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
