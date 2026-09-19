from pathlib import Path
import subprocess,json,hashlib,sys,datetime
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';C=E/'compile-candidate-01';R=E/'compile-execution-01'
cmd=['python3','-B',str(C/'issue_authorization.py'),str(R/'parent-envelope.json')]
with (R/'issuer-command.json').open('x') as f:json.dump(cmd,f)
with (R/'issuer.log').open('xb') as f:p=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
with (R/'issuer-returncode.json').open('x') as f:json.dump({'returncode':p.returncode},f)
print((R/'issuer.log').read_text(),flush=True)
assert p.returncode==0
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
a=json.loads((E/'compile-authorization.json').read_text());env=json.loads((R/'parent-envelope.json').read_text());assert json.loads((C/'consumed-reviews.json').read_text())==env
expected=json.loads((C/'compile-authorization.draft.json').read_text());expected.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
for path in (C/'consumed-reviews.json',C/'review-package-sha256.json',C/'compile-authorization.draft.json',R/'parent-envelope.json',R/'compile-spec-review-01.md',R/'compile-quality-review-01.md'):expected['dependency_sha256'][str(path)]=sha(path)
assert a==expected
assert a['ready_for_build'] is False and a['functional_acceptance'] is False
assert not (E/'native-compile.claim.json').exists() and not (E/'run').exists()
result=dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),authorization_sha256=sha(E/'compile-authorization.json'),consumed_sha256=sha(C/'consumed-reviews.json'),envelope_sha256=sha(R/'parent-envelope.json'),exact_draft_transition=True,native_claim_absent=True,run_absent=True)
with (R/'issued-readback.json').open('x') as f:json.dump(result,f,indent=2)
print(json.dumps(result,indent=2))
