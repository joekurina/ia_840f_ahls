import subprocess,shlex,json,gzip,hashlib,base64,time
from pathlib import Path
D=Path('/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ahls-persona-work21-fit01');host='uwb_student00@100.101.227.97';buf='ia840f_persona_fit02'
def call(args,timeout=180):
 return subprocess.run(['ssh','-o','BatchMode=yes','-o','ConnectTimeout=15',host,shlex.join(['tmux',*args])],stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout,check=True).stdout
print('Waiting for the already-running owned fitter; no FPGA access or new build.',flush=True)
p=subprocess.Popen(['ssh','-o','BatchMode=yes','-o','ConnectTimeout=15','-o','ServerAliveInterval=30','-o','ServerAliveCountMax=2',host,shlex.join(['tmux','wait-for',buf+'_done'])],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
try:
 for _ in range(92):
  try:
   stdout,stderr=p.communicate(timeout=120);break
  except subprocess.TimeoutExpired:print('No fitter completion signal received yet; acceptance is still pending.',flush=True)
 else:raise TimeoutError('Completion wait expired; remote state unknown; do not relaunch.')
 if p.returncode:raise RuntimeError('SSH/tmux wait failed; remote state unknown: '+stderr.decode(errors='replace'))
finally:
 if p.poll() is None:p.terminate();p.wait(timeout=10)
outer=int(call(['save-buffer','-b',buf+'_outer','-']));blob=call(['save-buffer','-b',buf,'-']);h=call(['save-buffer','-b',buf+'_sha256','-']).decode().strip();assert hashlib.sha256(blob).hexdigest()==h
out=D/'result-fit02.json.gz';assert not out.exists();out.write_bytes(blob)
(D/'outer-fit02.json').write_text(json.dumps({'outer_rc':outer,'archive_sha256':h,'bytes':len(blob)},indent=2)+'\n')
r=json.loads(gzip.decompress(blob))
for n,e in r['files'].items():
 assert not Path(n).is_absolute() and '..' not in Path(n).parts
 b=base64.b64decode(e['base64'],validate=True);assert len(b)==e['bytes'] and hashlib.sha256(b).hexdigest()==e['sha256']
 f=D/'artifacts-fit02'/n;f.parent.mkdir(parents=True,exist_ok=True);f.write_bytes(b)
print(json.dumps({'outer_rc':outer,'runner_success':r.get('success'),'error':r.get('error'),'archive_sha256':h,'verified_members':len(r['files']),'commands':r.get('commands'),'diagnostics':r.get('diagnostics'),'postflight_errors':r.get('postflight_errors'),'preservation':{k:r.get(k) for k in ('setup_unchanged','release_unchanged','tools_unchanged','bound_inputs_unchanged')}},indent=2),flush=True)
raise SystemExit(outer)
