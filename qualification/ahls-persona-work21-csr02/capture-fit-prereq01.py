import os,socket,json,hashlib,subprocess,gzip
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/synth01');b=(R/'result.json.gz').read_bytes();assert hashlib.sha256(b).hexdigest()=='24caf48cc162519ef1a1a0256df76077b2e9f47d22cff15f7937c5e267ba537d'
r=json.loads(gzip.decompress(b));assert r['success'] and r['complete'] and r['commands'][0]['native_rc']==0 and not r['commands'][0]['owned_group_live_after']
for n,h in r['input_hashes'].items():assert hashlib.sha256(Path(n).read_bytes()).hexdigest()==h,n
out={'root':str(R),'hardware_access':False,'inventory':{},'competing':[]}
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  exe=os.readlink(p/'exe')
  if Path(exe).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate','vlog','vsim','aoc'):out['competing'].append({'pid':int(p.name),'exe':exe})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['competing'],out['competing']
for p in (R/'persona').rglob('*'):
 if p.is_file():
  st=p.stat();b=p.read_bytes();assert st.st_size==len(b) and st.st_mtime_ns==p.stat().st_mtime_ns
  out['inventory'][str(p.relative_to(R/'persona'))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'symlink':os.readlink(p) if p.is_symlink() else None}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_csr02_fit_prereq01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_csr02_fit_prereq01'+'_sha256',hashlib.sha256(b).hexdigest()],check=True)
