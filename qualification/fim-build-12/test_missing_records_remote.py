from pathlib import Path
import os,sys,json,subprocess,hashlib
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach';PROJECT=W/'syn/board/ia840f/syn_top'
sys.dont_write_bytecode=True;sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_header_gate as hg
before=hg.work_inventory()
env=dict(os.environ,OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(hg.common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PYTHONDONTWRITEBYTECODE='1')
for k in list(env):
 if k.startswith('OFS_BUILD_TAG_') or k in ['SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE']:env.pop(k)
commands=[(['python3','-B',str(W/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'),'native','compile','ia840f',str(W)],C,'compile-authorization.json'),(['bash',str(W/'ofs-common/scripts/common/syn/build_top.sh'),'--stage=compile','-k','-p','ia840f',str(W)],C,'compile-authorization.json'),(['bash',str(W/'ofs-common/scripts/common/syn/build_fim_compile.sh'),'ia840f',str(W)],C,'compile-authorization.json'),(['python3','-B',str(E/'run_headers.py')],PROJECT,'header-authorization.json')]
results=[]
for cmd,cwd,record in commands:
 r=subprocess.run(cmd,cwd=cwd,env=env,capture_output=True,text=True)
 assert r.returncode!=0 and str(E/record) in r.stderr and 'No such file' in r.stderr,(cmd,r.stdout,r.stderr)
 results.append(dict(argv=cmd,cwd=str(cwd),rc=r.returncode,stdout=r.stdout,stderr=r.stderr))
assert hg.work_inventory()==before
assert not any((E/p).exists() for p in ['header-run','run','native-compile.claim.json','compile-authorization.json','header-authorization.json'])
assert not (C/'build_fim_work_ia840f_fim_12.log').exists()
with (E/'missing-record-tests.json').open('x') as f:json.dump(dict(cases=results,work_unchanged=True,logs_claims_absent=True),f,indent=2)
print(json.dumps(dict(missing_record_cases=len(results),work_unchanged=True,logs_claims_absent=True)))
