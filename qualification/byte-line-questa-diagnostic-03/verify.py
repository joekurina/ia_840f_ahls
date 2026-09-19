import ast,difflib,hashlib,json
from pathlib import Path
D=Path(__file__).resolve().parent
source=D.parent/'byte-line-questa-02/run.py'
old=source.read_text()
a="        (out / 'modelsim.ini').write_text('[Library]\\nwork = work\\n')"
b="        (out / 'modelsim.ini').write_text('[Library]\\nwork = work\\n\\n[vsim]\\nVoptFlow = 1\\n')"
assert old.count(a)==1
new=old.replace(a,b)
assert ''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/run.py',tofile='b/run.py'))==(D/'run.py.candidate.patch').read_text()
ast.parse(new)
evidence=json.loads((D/'probes.result.json').read_text())
assert len(evidence['probes'])==7
assert evidence['protected_unchanged'] and evidence['tools_unchanged']
expected={'minimal':1,'empty-vsim':1,'vopt-on':0,'vopt-off':1,'installed-ini':0,'no-explicit-ini':0}
for x in evidence['probes']:
 assert x['rc']==expected[x['case']]
 assert hashlib.sha256(x['output'].encode()).hexdigest()==x['output_pin']['sha256']
 if x['case']=='vopt-on':assert x['ini']['content']==(D/'modelsim.candidate.ini').read_text()
run02=json.loads((D.parent/'byte-line-questa-transfer-02/run-02-evidence.json').read_text())
assert evidence['probes'][0]['output']==run02['byte-line-questa-run-02/vlog-version/output.log']['content']
remote='/home/uwb_student00/ahls/new_BSP/qualification/byte-line-questa-package-02/run.py'
assert hashlib.sha256(source.read_bytes()).hexdigest()==evidence['protected_before'][remote]['sha256']
r={'patch_exact_single_replacement':True,'candidate_python_ast_valid':True,'source_matches_remote_package02':True,'probe_count':len(evidence['probes']),'protected_remote_file_count':len(evidence['protected_before']),'remote_files_unchanged':True,'installed_tools_and_ini_unchanged':True,'minimal_failure_matches_run02_byte_for_byte':True,'candidate_ini_matches_remote_successful_probe':True,'hdl_compilation_or_simulation_executed':False}
(D/'verification.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r,indent=2))
