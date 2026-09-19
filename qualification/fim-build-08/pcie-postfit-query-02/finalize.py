from pathlib import Path
import json,hashlib,subprocess,os,re
b=Path('/home/uwb_student00/ahls/new_BSP');e=b/'qualification/fim-build-08/pcie-postfit-query-02';s=e/'scratch';p=s/'syn/board/ia840f/syn_top';g=s/'ofs-common/tools/ofss_config/ia840f_query02_gate.py'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
r=json.loads((e/'candidate.json').read_text())
# Callback binds immutable inputs, not the pre-existing output logs that STA overwrites.
r['callback_files']={k:v for k,v in r['files'].items() if Path(k).suffix not in {'.log','.rpt','.summary','.smsg','.qmsg','.qpf'}}
t=g.read_text().replace("for filename,digest in r['files'].items():","for filename,digest in r['callback_files' if runtime else 'files'].items():")
g.write_text(t)
runner='''from pathlib import Path
import sys,os,subprocess,json
E=Path(__E__)
sys.dont_write_bytecode=True
sys.path.insert(0,str(E/'scratch/ofs-common/tools/ofss_config'))
from ia840f_query02_gate import validate
r=validate(runtime=False)
with (E/'query.claim').open('x') as f:f.write('exclusive query02 attempt\\n')
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus';env['LM_LICENSE_FILE']='/home/uwb_student00/quartus_26/LR-191011_License.dat'
with (E/'query.log').open('x') as f:
 try:rc=subprocess.run(r['argv'],cwd=r['cwd'],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=80).returncode
 except subprocess.TimeoutExpired:rc=124
(E/'native-result.json').write_text(json.dumps({'native_rc':rc,'acceptance':'REQUIRES_LOG_REVIEW'}))
sys.exit(rc)
'''.replace('__E__',repr(str(e)))
(e/'run-query.py').write_text(runner)
for x in [g,e/'run-query.py']:
 r['files'][str(x)]=sha(x);r['callback_files'][str(x)]=sha(x)
# Preserve installed launcher source as evidence for exact runtime argv review.
launcher=Path('/opt/altera/26.1.1/quartus/bin/quartus_sta').read_text();(e/'launcher-source.txt').write_text(launcher)
# Check every missing source-script reference explicitly observed in query01.
log=(b/'qualification/fim-build-08/pcie-postfit-query-01/query.log').read_text()
refs=re.findall(r'Tcl Script file (.*?) not found\.',log)
checks={ref:(p/ref).exists() for ref in refs}
checks['BMC arbiter_hw.tcl']=(s/'ipss/bmc/ip/arbiter/arbiter_hw.tcl').exists()
# BMC source is relative to its setup-defined root: retain source for exact review.
(e/'bmc-source.txt').write_text((s/'syn/board/ia840f/setup/bwbmc_design_files.tcl').read_text())
(e/'dependency-check.json').write_text(json.dumps({'query01_missing_tcl_now_present':checks,'copy_scope':['all Work08 files','complete PIM copy'],'broken_links':json.loads((e/'result.json').read_text())['missing_symlinks'],'closure_native_validation':'NOT_RUN'},indent=2))
(e/'candidate.json').write_text(json.dumps(r,indent=2,sort_keys=True))
# No authorization is installed, even for testing. Real entry point rejection only.
test=subprocess.run(['python3','-B',str(e/'run-query.py')],capture_output=True,text=True)
assert test.returncode!=0 and 'missing reviewed authorization' in test.stderr and not (e/'query.claim').exists()
(e/'runner-rejection.json').write_text(json.dumps({'rc':test.returncode,'stderr':test.stderr,'no_claim':not (e/'query.claim').exists(),'no_vendor_log':not (e/'query.log').exists()}))
names=['candidate.json','result.json','missing-auth-test.json','runner-rejection.json','dependency-check.json','relocations.json','query.tcl','run-query.py','launcher-source.txt','bmc-source.txt']
export={n:(e/n).read_text() for n in names};export['ia840f_query02_gate.py']=g.read_text();export['ia840f_experimental_gate.py']=(s/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py').read_text()
(e/'export-final.json').write_text(json.dumps(export));subprocess.run(['tmux','load-buffer','-b','query02_final_357',str(e/'export-final.json')],check=True)
print('FINAL',sha(e/'export-final.json'),checks,'runner rejection',test.returncode,flush=True)
