"""Local-only, exclusive successor packaging and original-preservation checks."""
from pathlib import Path
import difflib,hashlib,json,shutil,tarfile
D=Path(__file__).resolve().parent;E=D.parent;C=D/'candidate';O=E/'remote-evidence'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def save(p,data):
    with p.open('x') as f:json.dump(data,f,indent=2);f.write('\n')
original=json.loads((D/'original-before.json').read_text())
assert all(sha(E/p)==h for p,h in original.items())
old=json.loads((O/'review-package-sha256.json').read_text())
assert len(old)==76 and all(sha(O/p)==h for p,h in old.items())
runner_remote='/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/run_headers.py'
draft_path=C/'header-authorization.draft.json'; draft=json.loads(draft_path.read_text())
assert draft['dependency_sha256'][runner_remote]==sha(O/'run_headers.py')
# Change only the runner hash token; preserve original serialization and paths.
text=draft_path.read_text();assert text.count(sha(O/'run_headers.py'))==1
text=text.replace(sha(O/'run_headers.py'),sha(C/'run_headers.py'))
draft_path.write_text(text)
newdraft=json.loads(text);expected=json.loads((O/'header-authorization.draft.json').read_text())
expected['dependency_sha256'][runner_remote]=sha(C/'run_headers.py');assert newdraft==expected
manifest={p:sha(C/p) for p in old}
(C/'review-package-sha256.json').write_text(json.dumps(manifest,indent=2)+'\n')
changes=[]
for p in list(old)+['review-package-sha256.json']:
    if sha(C/p)!=sha(O/p):changes.append(dict(path=p,remote='/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/'+p,expected_old_sha256=sha(O/p),new_sha256=sha(C/p)))
assert {x['path'] for x in changes}=={'run_headers.py','header-authorization.draft.json','review-package-sha256.json'}
save(D/'transfer-overlay.json',{'status':'LOCAL ONLY; TRANSFER DEFERRED; NO LIVE REMOTE CHECK', 'allowed_package_overlay':changes,'source_or_work_writes_allowed':False,'backup_required_before_transfer':True})
with (D/'candidate.diff').open('x') as f:
    for item in changes:
        p=item['path'];f.writelines(difflib.unified_diff((O/p).read_text().splitlines(True),(C/p).read_text().splitlines(True),fromfile='original/'+p,tofile='candidate/'+p))
for phase in ['red-final','green-final']:
    results=json.loads((D/phase/'results.json').read_text())
    for r in results:
        src=Path(r['fixture']);dst=D/phase/'fixtures'/src.name;shutil.copytree(src,dst)
        assert {str(p.relative_to(src)):sha(p) for p in src.rglob('*') if p.is_file()}=={str(p.relative_to(dst)):sha(p) for p in dst.rglob('*') if p.is_file()}
green=json.loads((D/'green-final/results.json').read_text());red=json.loads((D/'red-final/results.json').read_text())
assert len(green)==14 and all(not r['problems'] for r in green)
assert next(r for r in red if r['native']==17 and r['fault']=='postflight')['exit']==1
contexts=json.loads((C/'compile-contexts.json').read_text());assert len(contexts)==135
assert not newdraft['approved'] and not newdraft['ready_for_build'] and not newdraft['compile_authorized']
assert all(p not in newdraft['work_inventory'] for p in newdraft['required_outputs'])
assert all(sha(E/p)==h for p,h in original.items())
assert {str(p.relative_to(C)) for p in C.rglob('*') if p.is_file()}==set(old)|{'review-package-sha256.json'}
with tarfile.open(D/'review-package.tar.gz','x:gz') as tar:
    for p in sorted(list(old)+['review-package-sha256.json']):tar.add(C/p,arcname=p,recursive=False)
with tarfile.open(D/'review-package.tar.gz') as tar:
    members=[m for m in tar.getmembers() if m.isfile()];assert len(members)==77
    for m in members:assert tar.extractfile(m).read()==(C/m.name).read_bytes()
summary=dict(original_files_unchanged=len(original),original_archive_members=77,candidate_archive_members=77,candidate_manifest_payloads=len(manifest),unchanged_package_files=77-len(changes),changed_package_files=changes,compile_contexts_unchanged=len(contexts),required_outputs_absent=len(newdraft['required_outputs']),green_cases=len(green),green_exit=0,red_exit=1,original_archive_sha256=sha(E/'review-package.tar.gz'),candidate_archive_sha256=sha(D/'review-package.tar.gz'),candidate_manifest_sha256=sha(C/'review-package-sha256.json'),issuer_unchanged_sha256=sha(C/'issue_headers.py'),remote_transfer_performed=False,authorization_issued=False,vendor_executed=False)
save(D/'verification.json',summary);print(json.dumps(summary,indent=2))
