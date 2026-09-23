import os,json,hashlib,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/export01');out={'status':json.loads((R/'status.json').read_text()) if (R/'status.json').exists() else None,'native_processes':[],'log_last_lines':[]}
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  exe=os.readlink(p/'exe')
  if Path(exe).name in {'quartus_sh','quartus_syn'}:out['native_processes'].append({'pid':int(p.name),'exe':exe,'cwd':os.readlink(p/'cwd'),'stat':(p/'stat').read_text(),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')})
 except (FileNotFoundError,PermissionError,ProcessLookupError):pass
if (R/'release.log').exists():out['log_last_lines']=(R/'release.log').read_text(errors='replace').splitlines()[-24:]
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_pr_export01_status01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_pr_export01_status01_sha256',hashlib.sha256(b).hexdigest()],check=True)
