from pathlib import Path
import sys,os,subprocess,json
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-02')
sys.dont_write_bytecode=True
sys.path.insert(0,str(E/'scratch/ofs-common/tools/ofss_config'))
from ia840f_query02_gate import validate
r=validate(runtime=False)
with (E/'query.claim').open('x') as f:f.write('exclusive query02 attempt\n')
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus';env['LM_LICENSE_FILE']='/home/uwb_student00/quartus_26/LR-191011_License.dat'
with (E/'query.log').open('x') as f:
 try:rc=subprocess.run(r['argv'],cwd=r['cwd'],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=80).returncode
 except subprocess.TimeoutExpired:rc=124
(E/'native-result.json').write_text(json.dumps({'native_rc':rc,'acceptance':'REQUIRES_LOG_REVIEW'}))
sys.exit(rc)
