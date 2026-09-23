import os,json,subprocess,gzip,hashlib,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
W=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21');T=Path('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03');out={'original_paths':[],'release_symlinks':{},'release_symlink_escapes':[]}
for d,dirs,files in os.walk(W,followlinks=False):
 for n in dirs+files:
  p=Path(d)/n
  if p.is_file() or p.is_symlink():out['original_paths'].append(str(p.relative_to(W)))
for d,dirs,files in os.walk(T,followlinks=False):
 for n in dirs+files:
  p=Path(d)/n
  if p.is_symlink():
   r=p.resolve(strict=True);out['release_symlinks'][str(p.relative_to(T))]=os.readlink(p)
   if not r.is_relative_to(T):out['release_symlink_escapes'].append(str(p))
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_pr_release03_closure02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_pr_release03_closure02_sha256',hashlib.sha256(b).hexdigest()],check=True)
