from pathlib import Path
import json,hashlib,base64
L=Path(__file__).parent; E=L.parent; B='/home/uwb_student00/ahls/new_BSP'; R=B+'/qualification/fim-build-12/compile-execution-01'
reports={n:base64.b64encode((E/n).read_bytes()).decode() for n in ('compile-spec-review-01.md','compile-quality-review-01.md')}
s='''from pathlib import Path
import sys, json, hashlib, base64, subprocess, socket, os, datetime
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';C=E/'compile-candidate-01';R=E/'compile-execution-01'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
R.mkdir()
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
m=json.loads((C/'review-package-sha256.json').read_text())
assert sha(C/'review-package-sha256.json')=='15687a2e812b78101246a66a57edc8e5991ef596a361d4de46e898afc8cc4836'
assert len(m)==62 and {str(p.relative_to(C)) for p in C.rglob('*') if p.is_file()}==set(m)|{'review-package-sha256.json'}
for p,h in m.items():assert sha(C/p)==h,p
reports=REPORTS
for n,b in reports.items():
 data=base64.b64decode(b)
 with (R/n).open('xb') as f:f.write(data)
 assert (R/n).read_bytes()==data
spec=sha(R/'compile-spec-review-01.md');quality=sha(R/'compile-quality-review-01.md')
assert spec=='aa822df551a0a302e679e7bbe546d92a774d92fb26d667571d4a48cdf519ecf7'
assert quality=='f738066a1ab12d777cef3864a50b27aa51a7046c07b292f67bf1020faab62f46'
env=dict(parent_acceptance_explicit=True,package_manifest_sha256=sha(C/'review-package-sha256.json'),spec_review=dict(accepted=True,files=m,report_path=str(R/'compile-spec-review-01.md'),report_sha256=spec),quality_review=dict(accepted=True,files=m,report_path=str(R/'compile-quality-review-01.md'),report_sha256=quality,spec_report_sha256=spec))
with (R/'parent-envelope.json').open('x') as f:json.dump(env,f,indent=2)
assert json.loads((R/'parent-envelope.json').read_text())==env
sys.path.insert(0,str(C));import issue_authorization as issuer
print('BEGIN FULL LIVE PREFLIGHT',flush=True)
draft,manifest=issuer.preflight()
result=dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),host=socket.gethostname(),uid=os.getuid(),source=sum(len(v) for v in draft['source_sha256'].values()),pim=len(draft['pim_sha256']),work=len(draft['work_inventory']),dependencies=len(draft['dependency_sha256']),contexts=len(draft['contexts']),package_files=63,payloads=62,readiness=False,absent=[str(p) for p in (issuer.gate.RECORD,issuer.gate.CLAIM,E/'run',C/'authorization-issuance.lock',C/'consumed-reviews.json')],report_hashes={n:sha(R/n) for n in reports},envelope_sha256=sha(R/'parent-envelope.json'))
with (R/'preflight.json').open('x') as f:json.dump(result,f,indent=2)
print(json.dumps(result,indent=2),flush=True)
'''.replace('REPORTS',repr(reports))
(L/'remote-preflight.py').write_text(s)
