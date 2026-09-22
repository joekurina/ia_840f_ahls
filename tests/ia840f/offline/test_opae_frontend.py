#!/usr/bin/env python3
"""Exercise real frontend control flow against LOCAL mock symbols only."""
import json,os,re,subprocess,sys
exe=sys.argv[1]
args=[exe,'--run-qualified-csr-test','0000:ab:1f.7']
records=[]
def run(scenario='pass',fail=0,argv=None):
    p=subprocess.run(argv or args,capture_output=True,text=True,timeout=8,
                     env=dict(os.environ,MOCK_SCENARIO=scenario,MOCK_FAIL_AT=str(fail)))
    records.append(dict(scenario=scenario,fail_at=fail,rc=p.returncode,stdout=p.stdout,stderr=p.stderr))
    return p
p=run();assert p.returncode==0,(p.stdout,p.stderr)
m=re.search(r'MOCK_SUMMARY calls=(\d+) starts=12 result_reads=12 failure_injected=0',p.stdout);assert m
count=int(m[1])
for case in ['zero','multiple','wrong_uuid','wrong_result']:
    p=run(case);assert p.returncode==1,(case,p.returncode,p.stdout,p.stderr)
    if case in ['zero','multiple','wrong_uuid']:assert 'starts=0 result_reads=0' in p.stdout
for i in range(1,count+1):
    p=run(fail=i)
    assert p.returncode==1,(i,p.returncode,p.stdout,p.stderr)
    assert 'failure_injected=1' in p.stdout
for bdf in ['0:ab:1f.7','0000:ab:20.7','0000:ab:1f.8','0000:ab:1f.7x']:
    p=run(argv=[exe,'--run-qualified-csr-test',bdf])
    assert p.returncode==2 and 'MOCK_SUMMARY' not in p.stdout
print(json.dumps(dict(offline_only=True,total_process_cases=len(records),injected_API_failures=count,
                     scenarios=['pass','zero','multiple','wrong_uuid','wrong_result','malformed BDF'],records=records)))
