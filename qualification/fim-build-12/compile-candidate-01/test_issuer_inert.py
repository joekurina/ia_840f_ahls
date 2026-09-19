"""Issuer review tests in isolated copies; live preflight tested separately.
Only preflight's return value is mocked here. No real authorization is issued.
"""
from pathlib import Path
from unittest.mock import patch
import copy,contextlib,io,json,tempfile
import issue_authorization as issuer
cases=[]
for mutation in ['none','missing_spec','missing_quality','wrong_coverage','wrong_manifest','missing_parent','wrong_report_hash','wrong_order']:
 with tempfile.TemporaryDirectory(prefix='work12-issuer-INERT-') as tmp:
  p=Path(tmp);(p/'review-package-sha256.json').write_text('{}');(p/'compile-authorization.draft.json').write_text('{}')
  (p/'spec.md').write_text('INERT MOCK SPEC');(p/'quality.md').write_text('INERT MOCK QUALITY')
  reviews=dict(parent_acceptance_explicit=True,package_manifest_sha256=issuer.sha(p/'review-package-sha256.json'))
  for section,report in [('spec_review','spec.md'),('quality_review','quality.md')]:
   reviews[section]=dict(accepted=True,files={},report_path=str(p/report),report_sha256=issuer.sha(p/report))
  reviews['quality_review']['spec_report_sha256']=reviews['spec_review']['report_sha256']
  if mutation=='missing_spec':del reviews['spec_review']
  elif mutation=='missing_quality':del reviews['quality_review']
  elif mutation=='wrong_coverage':reviews['quality_review']['files']={'unreviewed':'bad'}
  elif mutation=='wrong_manifest':reviews['package_manifest_sha256']='bad'
  elif mutation=='missing_parent':reviews['parent_acceptance_explicit']=False
  elif mutation=='wrong_report_hash':reviews['quality_review']['report_sha256']='bad'
  elif mutation=='wrong_order':reviews['quality_review']['spec_report_sha256']='bad'
  review=p/'envelope.json';review.write_text(json.dumps(reviews))
  before={str(f):f.read_bytes() for f in p.iterdir()}
  with patch.object(issuer,'P',p),patch.object(issuer.gate,'RECORD',p/'authorization.json'),patch.object(issuer,'preflight',return_value=({'dependency_sha256':{},'ready_for_build':False},{})),contextlib.redirect_stdout(io.StringIO()):
   try:issuer.issue(review)
   except (AssertionError,KeyError):
    assert mutation!='none'
    assert before=={str(f):f.read_bytes() for f in p.iterdir()}
   else:
    assert mutation=='none'
    d=json.loads((p/'authorization.json').read_text());assert d['approved'] and d['ready_for_build'] is False
    after={str(f):f.read_bytes() for f in p.iterdir() if f.is_file()}
    try:issuer.issue(review)
    except FileExistsError:pass
    else:raise AssertionError('reissued')
    assert after=={str(f):f.read_bytes() for f in p.iterdir() if f.is_file()}
  cases.append(dict(mutation=mutation,result='PASS'))
print(json.dumps(dict(result='PASS',cases=cases,fixtures='isolated authorization; mocked preflight only',real_authorization_issued=False),indent=2))
