#!/usr/bin/env python3
"""Local inert candidate-gate fixtures, no real authorization or vendor call."""
from pathlib import Path
import hashlib,json,runpy,sys,tempfile
ROOT=Path(__file__).resolve().parent

def main():
    if sys.flags.optimize:raise RuntimeError('optimized fixtures forbidden')
    path=ROOT/'candidate/ia840f_clock_candidate02_gate.py'
    ns=runpy.run_path(str(path));validate=ns['validate'];g=validate.__globals__
    rows=[]
    with tempfile.TemporaryDirectory(prefix='ia840f-gate-inert-',dir='/home/joe/.hermes/cache/scratch') as tmp:
        root=Path(tmp);A=root/'baseline';E=root/'candidate';A.mkdir();E.mkdir();g['E']=E
        record={'ready_for_build':False,'part':'AGFB027R25A2E2V','files':{},'callback_files':{},'links':{},'fixture_only':True}
        (E/'candidate.json').write_text(json.dumps(record))
        for label,termination,effective,expected in [('confirmed',True,0,True),('missing','MISSING',0,False),('false',False,0,False),('string_true','true',0,False),('failed_execution',True,124,False)]:
            status={'native_rc':0}
            if termination!='MISSING':status['termination_confirmed']=termination
            (A/'native-result.json').write_text(json.dumps(status))
            (A/'execution-status.json').write_text(json.dumps({'effective_rc':effective}))
            (A/'preservation-after.json').write_text(json.dumps({'INERT_W':True,'INERT_S':True,'INERT_P':True}))
            (A/'query.log').write_text('IA840F_CONSTRAINT_COMPARE_COMPLETE baseline\n')
            (A/'query.claim').write_text('INERT FIXTURE ONLY')
            auth={'approved':True,'candidate_sha256':g['sha'](E/'candidate.json'),'permission':'exact-offline-constraint-candidate02','baseline_results':{n:g['sha'](A/n) for n in ('native-result.json','execution-status.json','preservation-after.json','query.log','query.claim')}}
            (E/'authorization.json').write_text(json.dumps(auth))
            try:validate(runtime=False);accepted=True;error=None
            except ValueError as exc:accepted=False;error=str(exc)
            assert accepted is expected,(label,accepted,error)
            rows.append({'case':label,'accepted':accepted,'error':error,'pass':True})
    print(json.dumps({'scope':'actual validate(runtime=False) in temporary INERT dummy-record fixture only; no real authorization','count':len(rows),'tests':rows,'gate_sha256':hashlib.sha256(path.read_bytes()).hexdigest()},indent=2))
if __name__=='__main__':main()
