import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01');J=R/'persona/build/syn/board/ia840f/syn_top';out={'source':str(R/'persona'),'inventory':{},'files':{},'tools':{},'native_processes':[]}
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  e=os.readlink(p/'exe')
  if Path(e).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate'):out['native_processes'].append({'pid':int(p.name),'exe':e})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['native_processes'],out['native_processes']
for p in (R/'persona').rglob('*'):
 if p.is_file():
  s=p.stat();b=p.read_bytes();s2=p.stat();assert (s.st_size,s.st_mtime_ns)==(s2.st_size,s2.st_mtime_ns)
  out['inventory'][str(p.relative_to(R/'persona'))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'symlink':os.readlink(p) if p.is_symlink() else None}
for name in ('quartus_fit','quartus_sta','quartus_asm'):
 for d in ('bin','linux64'):
  p=Path('/opt/altera/25.1/quartus')/d/name;b=p.read_bytes();out['tools'][str(p)]={'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
for n in ('ofs_partial_reconfig/user_clocks.sdc','ofs_partial_reconfig/ofs_sta_report_script_pr.tcl','ofs_partial_reconfig/gen_gbs.tcl'):
 p=J/n;b=p.read_bytes();assert len(b)<1_000_000;out['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_fit_prereq01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_fit_prereq01_sha256',hashlib.sha256(b).hexdigest()],check=True)
