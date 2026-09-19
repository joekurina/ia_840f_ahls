from pathlib import Path
import base64,hashlib,json,subprocess,os
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';P=B/'qualification/fim-build-08';E=B/'qualification/fim-build-09'
assert os.getuid()==1000 and os.environ.get('TMUX')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
rels=list(json.loads((P/'overlay-sha256.json').read_text()));q='syn/board/ia840f/syn_top/ofs_top.qsf';rels.append(q)
over={};befores={}
for r in rels:
 data=(C/r).read_bytes();befores[r]=base64.b64encode(data).decode()
 if r.endswith(('ia840f_compile_gate.py','ia840f_experimental_gate.py')):data=data.replace(b'fim-build-08',b'fim-build-09').replace(b'work_ia840f_fim_08',b'work_ia840f_fim_09')
 if r==q:
  old=b'set_global_assignment -name OPTIMIZATION_MODE "SUPERIOR PERFORMANCE"'; assert data.count(old)==1
  data=data.replace(old,b'set_global_assignment -name OPTIMIZATION_MODE "SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT"')
 over[r]={'data':base64.b64encode(data).decode(),'sha256':hashlib.sha256(data).hexdigest()}
stage=(B/'qualification/fim-build-07/stage_remote.py').read_text().replace('fim-build-07','fim-build-09').replace('work_ia840f_fim_07','work_ia840f_fim_09')
exec(compile(stage,'stage_remote.py','exec'),{'OVERLAYS':over})
(E/'stage_remote.py').write_text(stage)
for r,d in befores.items():
 p=E/'source-before'/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(base64.b64decode(d))
import difflib
patch=''
for r in rels:
 a=(E/'source-before'/r).read_text();b=(E/'source-overlay'/r).read_text()
 patch+=''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+r,tofile='b/'+r))
(E/'candidate.patch').write_text(patch)
art={}
for f in ['issue_authorization.py','launch_native_compile.py','test_real_dispatch.py']:
 t=(P/f).read_text().replace('fim-build-08','fim-build-09').replace('work_ia840f_fim_08','work_ia840f_fim_09').replace('Work08','Work09')
 if f=='issue_authorization.py':
  t=t.replace("'syn/board/ia840f/setup/bti_refclk.sdc']", "'syn/board/ia840f/setup/bti_refclk.sdc', '"+q+"']").replace('bti_review','timing_review')
 art[f]=base64.b64encode(t.encode()).decode()
prepare=(B/'qualification/fim-build-07/prepare_handoff_remote.py').read_text().replace('fim-build-07','fim-build-09').replace('work_ia840f_fim_07','work_ia840f_fim_09')
(E/'prepare_handoff_remote.py').write_text(prepare)
exec(compile(prepare,'prepare_handoff_remote.py','exec'),{'ARTIFACTS':art})
r=subprocess.run(['python3',str(E/'test_real_dispatch.py')],env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),capture_output=True,text=True)
(E/'real-dispatch-tests.log').write_text(r.stdout+r.stderr);print('DISPATCH RC',r.returncode,r.stderr[-2000:]);assert r.returncode==0
lib=Path('/opt/altera/26.1.1/quartus/linux64/libdb_acf.so');ss=subprocess.check_output(['strings',str(lib)],text=True).splitlines()
evidence={'path':str(lib),'sha256':sha(lib),'method':'installed assignment-library enum/help strings; no compiler invoked','strings':[l for l in ss if l in ['OPTIMIZATION_MODE','Superior Performance','Superior Performance with Maximum Placement Effort','SUPERIOR_PERFORMANCE_WITH_MAXIMUM_PLACEMENT_EFFORT'] or l.startswith("Controls the Compiler's high-level optimization strategy") or l.startswith("Controls the fitter's trade-off")]}
(E/'installed-option-evidence.json').write_text(json.dumps(evidence,indent=2));print('PREPARED',E)
