import os,socket,json,hashlib,gzip,subprocess
from pathlib import Path
from datetime import datetime,timezone
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
p=Path('/proc/122381');parts=(p/'stat').read_text().rsplit(')',1)[1].split();assert parts[19]=='14010045'
assert os.readlink(p/'cwd')=='/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/fit02/persona/build/syn/board/ia840f/syn_top'
assert os.readlink(p/'exe')=='/opt/altera/25.1/quartus/linux64/quartus_fit'
o={'captured_utc':datetime.now(timezone.utc).isoformat(),'pid':122381,'start_ticks':parts[19],'limits':(p/'limits').read_text(),'status':{a.split(':',1)[0]:a.split(':',1)[1].strip() for a in (p/'status').read_text().splitlines() if a.split(':',1)[0] in ('VmPeak','VmSize','VmRSS','Cpus_allowed_list','Threads')},'mem_available':next(a for a in Path('/proc/meminfo').read_text().splitlines() if a.startswith('MemAvailable:'))}
b=gzip.compress(json.dumps(o,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_fit02_resources01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_fit02_resources01_sha256',hashlib.sha256(b).hexdigest()],check=True)
