from pathlib import Path
import json,subprocess,hashlib,sys,datetime,os
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';C=E/'compile-candidate-01';R=E/'compile-execution-01';S=B/'ofs-agx7-pcie-attach'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert sha(E/'compile-authorization.json')=='ad16f23ca0e03041db913a5f2df45077f26fcdef15804b1c7d970f721bd256fb'
assert sha(C/'consumed-reviews.json')==sha(R/'parent-envelope.json')=='20a20c58240e548f9956490247b449639ce0f6f27e20afca5d5e65f3470d553f'
# Unchanged full live pre-start inventories; production runner repeats its own gates.
sys.path.insert(0,str(S/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate
a=json.loads((E/'compile-authorization.json').read_text())
assert {t:gate.common.inventory(S/t) for t in gate.common.TREES}==a['source_sha256']
assert gate.common.inventory(gate.common.PIM)==a['pim_sha256']
assert gate.work_inventory()==a['work_inventory']
for p,h in a['dependency_sha256'].items():assert sha(p)==h,p
assert not gate.CLAIM.exists() and not (E/'run').exists()
with (R/'prestart.json').open('x') as f:json.dump(dict(timestamp=datetime.datetime.now(datetime.timezone.utc).isoformat(),source_unchanged=True,pim_unchanged=True,work_unchanged=True,dependencies_verified=True,readiness=False),f,indent=2)
cmd=['python3','-B',str(C/'launch_native_compile.py')]
with (R/'runner-command.json').open('x') as f:json.dump(dict(argv=cmd,cwd=str(S)),f,indent=2)
os.chdir(S)
print('STARTING REVIEWED RUNNER ONCE',flush=True)
with (R/'runner.log').open('xb') as f:p=subprocess.run(cmd,cwd=S,stdout=f,stderr=subprocess.STDOUT)
with (R/'runner-returncode.json').open('x') as f:json.dump(dict(returncode=p.returncode,ended=datetime.datetime.now(datetime.timezone.utc).isoformat()),f,indent=2)
print('RUNNER EXIT',p.returncode,flush=True)
sys.exit(p.returncode)
