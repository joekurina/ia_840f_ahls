import os,socket,json,hashlib,base64,gzip,subprocess,shutil
from pathlib import Path
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
T=Path('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03');names=['bin/afu_synth', 'bin/build_env_config', 'hw/lib/fme-ifc-id.txt', 'hw/lib/fme-platform-class.txt', 'hw/lib/platform/platform_db/ofs_agilex.ini', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_top.qpf', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_pr_afu.qsf', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_pr_afu_sources.tcl', 'hw/lib/build/syn/board/ia840f/syn_top/fim_base_ip.tcl', 'hw/lib/build/syn/board/ia840f/syn_top/fim_project_macros.tcl', 'hw/lib/build/syn/board/ia840f/syn_top/afu_with_pim/afu.tcl', 'hw/lib/build/syn/board/ia840f/setup/build_gate_release01.tcl', 'hw/lib/build/syn/board/ia840f/setup/ia840f_release_gate01.py', 'hw/lib/build/platform/ofs_plat_if/rtl/ofs_plat_if_top_config.vh', 'hw/lib/build/platform/ofs_plat_if/par/ofs_plat_if_addenda.qsf'];out={'files':{},'tools':{}}
for n in names:
 p=T/n;assert p.is_file(),n;b=p.read_bytes();assert len(b)<2_000_000
 out['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for name in ('afu_synth_setup','afu_json_mgr','afu_platform_config','packager'):
 path=shutil.which(name);out['tools'][name]={'which':path}
 if path:
  p=Path(path);b=p.read_bytes();out['tools'][name].update(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);subprocess.run(['tmux','load-buffer','-b','ia840f_pr_release03_boundary01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_pr_release03_boundary01_sha256',hashlib.sha256(b).hexdigest()],check=True)
