import os,json,hashlib,base64,gzip,subprocess,socket
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/sta01');J=R/'persona/build/syn/board/ia840f/syn_top';out={'source':str(R/'persona'),'inventory':{},'files':{},'tools':{},'native_processes':[],'hardware_access':False,'sta_result_sha256':hashlib.sha256((R/'result.json.gz').read_bytes()).hexdigest()}
assert out['sta_result_sha256']=='1b306237f3f8edebfddd23753cab0a9777f1db725d92e0e0324e2f12be990834'
fr=json.loads(gzip.decompress((R/'result.json.gz').read_bytes()))
assert fr['success'] and fr['complete'] and len(fr['commands'])==1
fc=fr['commands'][0];assert fc['native_rc']==0 and fc['effective_rc']==0 and not fc['timeout'] and not fc['owned_group_live_after']
out['allowed_cpus']=sorted(os.sched_getaffinity(0));assert out['allowed_cpus']

for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  e=os.readlink(p/'exe')
  if Path(e).name in ('quartus_fit','quartus_syn','quartus_sta','quartus_sh','quartus_ipgenerate','quartus_asm','quartus_cpf','vlog','vsim','aoc'):out['native_processes'].append({'pid':int(p.name),'exe':e})
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
assert not out['native_processes'],out['native_processes']
for p in (R/'persona').rglob('*'):
 if p.is_file():
  s=p.stat();b=p.read_bytes();s2=p.stat();assert (s.st_size,s.st_mtime_ns)==(s2.st_size,s2.st_mtime_ns)
  out['inventory'][str(p.relative_to(R/'persona'))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'symlink':os.readlink(p) if p.is_symlink() else None}
for name in ('quartus_asm',):
 for d in ('bin','linux64'):
  p=Path('/opt/altera/25.1/quartus')/d/name;b=p.read_bytes();out['tools'][str(p)]={'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
for n in ('ofs_pr_afu.qsf','ofs_top.out.sdc','ofs_partial_reconfig/ofs_sta_report_script_pr.tcl','ofs_partial_reconfig/user_clock_freqs_compute.tcl','ofs_partial_reconfig/user_clock_defs.tcl','ofs_partial_reconfig/report_timing.tcl','ofs_partial_reconfig/gen_gbs.tcl'):
 p=J/n;b=p.read_bytes();assert len(b)<1_000_000;out['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}


out['installed_files']={}
for name in ('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03/bin/afu_synth','/usr/bin/afu_synth','/usr/bin/packager','/usr/lib/python3.9/site-packages/packager/tools/packager.py','/usr/lib/python3.9/site-packages/packager/utils/gbs.py','/usr/lib/python3.9/site-packages/packager/metadata/metadata.py','/opt/altera/25.1/quartus/common/tcl/internal/flow.tcl'):
 p=Path(name)
 if not p.is_file():out['installed_files'][name]={'missing':True};continue
 b=p.read_bytes();assert len(b)<2_000_000
 out['installed_files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}

b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_persona_caps01_asm_prereq02','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_persona_caps01_asm_prereq02_sha256',hashlib.sha256(b).hexdigest()],check=True)
