"""Actual maintained/copied shell guards with missing compile record; no vendor.
Failure must precede logs, run claims and bootstrap. Complete SOURCE/WORK checked.
"""
from pathlib import Path
import json,os,subprocess,sys
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';C=B/'ofs-agx7-pcie-attach';W=B/'work_ia840f_fim_12'
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as g
before=g.work_inventory();source={t:g.common.inventory(C/t) for t in g.common.TREES}
env=dict(os.environ,OFS_ROOTDIR=str(C),OFS_PLATFORM_AFU_BBB=str(g.common.PIM),KEEP_WORK_ARG='-k',DO_PR_BUILD_TEMPLATE_GEN='1',QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PYTHONDONTWRITEBYTECODE='1')
for k in list(env):
 if k.startswith('OFS_BUILD_TAG_') or k in ['SEED','ANALYSIS_AND_ELAB_ONLY','USE_OFSS_CONFIG_SCRIPT','OFS_PRE_SETUP_SCRIPT','OFS_POST_SETUP_SCRIPT','OFS_PRE_COMPILE_SCRIPT','OFS_POST_COMPILE_SCRIPT','AFU_WITH_PIM','BUILD_VAR_SETUP_COMPLETE']:env.pop(k)
assert not g.RECORD.exists() and not g.CLAIM.exists() and not (E/'run').exists()
logs={str(p):g.sha(p) for p in C.glob('build_fim*.log')}
results=[]
for root in (C,W):
 commands=[['python3','-B',str(root/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'),'native','compile','ia840f',str(W)],['bash',str(root/'ofs-common/scripts/common/syn/build_top.sh'),'--stage=compile','-k','-p','ia840f',str(W)],['bash',str(root/'ofs-common/scripts/common/syn/build_fim_compile.sh'),'ia840f',str(W)]]
 for cmd in commands:
  r=subprocess.run(cmd,cwd=C,env=env,capture_output=True,text=True)
  assert r.returncode!=0 and str(g.RECORD) in r.stderr and 'No such file' in r.stderr,(cmd,r.stdout,r.stderr)
  results.append(dict(argv=cmd,cwd=str(C),rc=r.returncode,stdout=r.stdout,stderr=r.stderr))
assert g.work_inventory()==before and {t:g.common.inventory(C/t) for t in g.common.TREES}==source
assert logs=={str(p):g.sha(p) for p in C.glob('build_fim*.log')}
assert not g.RECORD.exists() and not g.CLAIM.exists() and not (E/'run').exists()
print(json.dumps(dict(result='PASS',cases=results,source_work_unchanged=True,logs_claims_absent=True,vendor_launched=False),indent=2))
