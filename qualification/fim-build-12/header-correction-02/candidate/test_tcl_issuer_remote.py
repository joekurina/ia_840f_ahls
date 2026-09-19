from pathlib import Path
import subprocess,json,os,sys
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach'
p=W/'syn/board/ia840f/setup/build_gate.tcl'
tcl='if {[catch {source {'+str(p)+'}} err]} {puts stderr "HELPER=$ia840f_gate"; puts stderr $err; exit 1}\nexit 0\n'
r=subprocess.run(['tclsh'],input=tcl,text=True,capture_output=True,cwd=W/'syn/board/ia840f/syn_top',env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
assert r.returncode!=0 and 'HELPER='+str(W/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py') in r.stderr and str(E/'compile-authorization.json') in r.stderr,(r.returncode,r.stdout,r.stderr)
s=subprocess.run(['python3','-B',str(E/'issue_headers.py'),str(E/'missing-reviews.json')],capture_output=True,text=True,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'))
assert s.returncode!=0 and 'No such file' in s.stderr and not (E/'header-issuance.lock').exists()
with (E/'tcl-and-issuer-rejection.json').open('x') as f:json.dump(dict(tcl_rc=r.returncode,tcl_stderr=r.stderr,issuer_rc=s.returncode,issuer_stderr=s.stderr,no_issuance_lock=True),f,indent=2)
print('PASS actual Tcl helper resolves Work12; issuer rejects absent reviews before lock')
