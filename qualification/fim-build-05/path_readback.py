from pathlib import Path
import re,json,hashlib,os
N=Path('/home/uwb_student00/ahls/new_BSP');W=N/'work_ia840f_fim_05';E=N/'qualification/fim-build-05'
refs={};qip_missing=[];qip_count=0
for p in W.rglob('*'):
 if p.is_file() and p.suffix in ('.qsf','.qip','.tcl','.ip','.qsys','.sdc'):
  text=p.read_text(errors='replace')
  homes=sorted(set(re.findall(r'/home/[^\s\"\}\]\)<>;]+',text)))
  if homes:refs[str(p.relative_to(W))]=homes
  if p.suffix=='.qip':
   qip_count+=1
   for x in re.findall(r'\[file join \$::quartus\(qip_path\) "([^"]+)"\]',text):
    if not (p.parent/x).exists():qip_missing.append([str(p.relative_to(W)),x])
report=dict(home_refs=refs,qip_files=qip_count,recognized_qip_missing=qip_missing,
 scope='Literal home paths in Tcl/QSF/QIP/IP/QSYS/SDC; literal qip_path joins. Dynamic Tcl closure is native compiler acceptance.')
(E/'literal-path-closure.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
print('REMOTE_HANDOFF_SHA256',json.dumps({f:hashlib.sha256((E/f).read_bytes()).hexdigest() for f in ['issue_authorization.py','launch_native_compile.py','compile-authorization.draft.json','staging-receipt.json','handoff-verification.json']},indent=2))
