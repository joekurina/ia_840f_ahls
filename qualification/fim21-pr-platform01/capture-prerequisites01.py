import os,socket,json,hashlib,base64,gzip,subprocess,shutil,time
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_21';P=B/'ofs-platform-afu-bbb'
R=B/'work_fim21_pr_platform01'/'capture01';assert not R.exists() and W.is_dir()
C={'selected': ['syn/board/ia840f/syn_top/ofs_top.qpf', 'syn/board/ia840f/syn_top/ofs_top.qsf', 'syn/board/ia840f/syn_top/ofs_pr_afu.qsf', 'syn/board/ia840f/syn_top/ofs_pr_afu_sources.tcl', 'syn/board/ia840f/syn_top/ofs_top_sources.tcl', 'syn/board/ia840f/syn_top/build_env_db.txt', 'syn/board/ia840f/syn_top/fme-ifc-id.txt', 'syn/board/ia840f/syn_top/fim_project_macros.tcl', 'syn/board/ia840f/syn_top/fim_base_ip.tcl', 'syn/board/ia840f/syn_top/ofs_top.out.sdc', 'syn/board/ia840f/setup/build_gate.tcl', 'syn/board/ia840f/setup/config_env.tcl', 'syn/board/ia840f/setup/afu_design_files.tcl', 'ofs-common/scripts/common/syn/generate_pr_release.sh', 'ofs-common/scripts/common/syn/build_var_setup_common.sh', 'ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl', 'ofs-common/scripts/common/syn/emit_project_macros.tcl', 'ofs-common/scripts/common/syn/pim/ofs_pim_setup.sh', 'ofs-common/scripts/common/syn/release_bin/afu_synth', 'ofs-common/scripts/common/syn/release_bin/update_pim', 'ofs-common/scripts/common/syn/release_bin/build_env_config', 'ofs-common/scripts/common/syn/release_bin/README', 'syn/scripts/build_var_setup.sh', 'src/top/ofs_agilex.ini', 'ofs-common/src/fpga_family/agilex/afu_main.tcl', 'ofs-common/src/fpga_family/agilex/afu_main.sv', 'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'], 'artifacts': ['syn/board/ia840f/syn_top/ofs_top.qdb', 'syn/board/ia840f/syn_top/output_files/ofs_top.sof', 'syn/board/ia840f/syn_top/output_files/ofs_top.static.msf', 'syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf', 'syn/board/ia840f/syn_top/ofs_pr_afu.done']}
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(4*1024*1024),b''):h.update(b)
 return h.hexdigest()
out={'scope':'ordinary-file/OS read-only FIM PR prerequisites; no native/vendor/hardware tools','utc':datetime.now(timezone.utc).isoformat(),'work':str(W),'files':{},'artifacts':{},'inventory':{},'processes':[],'resources':{'mem_available':int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024,'disk_free':shutil.disk_usage(B).free}}
for n in C['selected']:
 p=W/n
 if not p.is_file():out['files'][n]={'missing':True};continue
 st=p.stat();assert st.st_size<=4_000_000,n;b=p.read_bytes();en=p.stat();assert (st.st_size,st.st_mtime_ns)==(en.st_size,en.st_mtime_ns)
 out['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode(),'realpath':str(p.resolve())}
for n in C['artifacts']:
 p=W/n
 if not p.is_file():out['artifacts'][n]={'missing':True};continue
 st=p.stat();assert st.st_size<=4*1024**3,n;h=sha(p);en=p.stat();assert (st.st_size,st.st_mtime_ns)==(en.st_size,en.st_mtime_ns)
 out['artifacts'][n]={'bytes':st.st_size,'sha256':h,'mtime_ns':st.st_mtime_ns,'realpath':str(p.resolve())}
for d,dirs,files in os.walk(W,followlinks=False):
 for name in dirs+files:
  p=Path(d)/name;n=str(p.relative_to(W));st=p.lstat()
  if p.is_symlink():out['inventory'][n]={'kind':'symlink','target':os.readlink(p),'bytes':st.st_size}
  elif p.is_file():out['inventory'][n]={'kind':'file','bytes':st.st_size,'mtime_ns':st.st_mtime_ns}
 assert len(out['inventory'])<=100000,'inventory cap'
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:
  exe=os.readlink(p/'exe')
  if Path(exe).name in {'quartus_syn','quartus_fit','quartus_sta','quartus_sh','quartus_cdb','vlog','vsim','aoc'}:out['processes'].append({'pid':int(p.name),'exe':exe,'cwd':os.readlink(p/'cwd')})
 except (FileNotFoundError,PermissionError,ProcessLookupError):pass
out['pim_path']=str(P);out['pim_exists']=P.is_dir()
R.mkdir(parents=True,exist_ok=False);blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);(R/'result.json.gz').write_bytes(blob)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim21_pr_readonly01','-'],input=blob,check=True)
subprocess.run(['tmux','set-buffer','-b','ia840f_fim21_pr_readonly01_sha256',hashlib.sha256(blob).hexdigest()],check=True)
