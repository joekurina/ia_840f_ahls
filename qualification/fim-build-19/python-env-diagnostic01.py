import base64, datetime, gzip, hashlib, json, os, socket, subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim19-python-env01';C=B/'ofs-agx7-pcie-attach';Q=Path('/opt/altera/25.1/quartus')
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
E.mkdir();os.chdir(E)
s='''puts "LD_LIBRARY_PATH=$::env(LD_LIBRARY_PATH)"
set probe {import hashlib,uuid,ssl; print(hashlib.sha256(b"test").hexdigest()); print(uuid.uuid5(uuid.NAMESPACE_DNS,"test")); print(ssl.OPENSSL_VERSION)}
set raw_rc [catch {exec /usr/bin/python3 -c $probe 2>@1} raw]
puts "RAW_RC=$raw_rc"; puts $raw
set clean_rc [catch {exec /usr/bin/env -u LD_LIBRARY_PATH /usr/bin/python3 -c $probe 2>@1} clean]
puts "CLEAN_RC=$clean_rc"; puts $clean
if {$raw_rc != 1 || $clean_rc != 0} {error "unexpected diagnostic result"}
'''
(E/'probe.tcl').write_text(s)
env=dict(os.environ,QUARTUS_ROOTDIR_OVERRIDE=str(Q),PATH=f'{Q}/bin:{Q}/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin')
p=subprocess.run([str(Q/'bin/quartus_sh'),'-t',str(E/'probe.tcl')],cwd=E,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
r={'batch':'ia840f_fim19_pythonenv01','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'rc':p.returncode,'output':p.stdout.decode(errors='replace'),'files':{},'python_tcl_calls':{},'active_native':[]}
for f in [C/'syn/board/ia840f/setup/build_gate.tcl',C/'ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl',B/'qualification/fim-build-19/run/native.log',B/'qualification/fim-build-19/run/status.json',B/'qualification/fim-build-19/run/native-status.json',B/'qualification/fim-build-19/compile-authorization.json']:
 b=f.read_bytes();assert len(b)<2000000;r['files'][str(f)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for root in [C/'syn',C/'ofs-common/scripts',C/'ipss',C/'src']:
 for f in root.rglob('*.tcl'):
  lines=f.read_text(errors='replace').splitlines();hits=[[i,l] for i,l in enumerate(lines,1) if 'python' in l.lower()]
  if hits:r['python_tcl_calls'][str(f.relative_to(C))]=hits
rows=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
r['active_native']=[l for l in rows.splitlines()[1:] if len(l.split())>=3 and l.split()[2].startswith(('quartus_','qsys-'))]
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0);(E/'result.json.gz').write_bytes(blob)
subprocess.run(['tmux','load-buffer','-b',r['batch'],'-'],input=blob,check=True)
print('PYTHON_ENV_DIAGNOSTIC_COMPLETE',hashlib.sha256(blob).hexdigest(),flush=True)
