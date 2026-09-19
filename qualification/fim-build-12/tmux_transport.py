import subprocess,base64,json,time,uuid,hashlib,shlex
from pathlib import Path
HOST='uwb_student00@100.101.227.97'; SESSION='ia840f_mailbox_monitored_01'
def remote(code, label, outdir):
 tag='w12-'+label+'-'+uuid.uuid4().hex[:10]; buf=tag+'-out'; incoming=tag+'-in'
 wrapped="import json,traceback,subprocess,base64\ntry:\n exec(compile("+repr(code)+",'remote-payload','exec'))\nexcept BaseException:\n traceback.print_exc()\n raise\n"
 shell="python3 -B -c "+shlex.quote(wrapped)+" 2>&1 | tmux load-buffer -b "+buf+" -"
 subprocess.run(['ssh',HOST,'tmux load-buffer -b '+incoming+' -'],input=shell.encode(),check=True)
 cmd="bash -c "+shlex.quote('eval "$(tmux save-buffer -b '+incoming+' -)"')
 subprocess.run(['ssh',HOST,'tmux new-window -d -t '+SESSION+' -n '+tag+' '+shlex.quote(cmd)],check=True)
 for _ in range(240):
  r=subprocess.run(['ssh',HOST,'tmux save-buffer -b '+buf+' -'],capture_output=True)
  if r.returncode==0:
   Path(outdir,label+'.log').write_bytes(r.stdout);print(r.stdout.decode());return r.stdout.decode()
  time.sleep(2)
 raise TimeoutError(tag)
