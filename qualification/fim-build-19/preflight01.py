# Ordinary OS/files-only Work19 preflight. No FPGA access.
import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP')
batch='ia840f_fim19_preflight01'
assert os.environ.get('TMUX') and socket.gethostname()=='Agilex7Workstation'
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
paths=[Path.home()/'quartus_25/instructions.md',B/'qualification/fim-build-18/compile-authorization.json',B/'qualification/fim-build-18/run/status.json',B/'qualification/fim-build-18/metadata-delta.json',B/'work_ia840f_fim_18/syn/board/ia840f/syn_top/build_env_db.txt',B/'work_ia840f_fim_18/syn/board/ia840f/syn_top/fme_id.mif',B/'work_ia840f_fim_18/syn/board/ia840f/syn_top/ofs_top.qsf',B/'ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_compile_gate.py',B/'ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py']
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'hostname':socket.gethostname(),'pane':os.environ['TMUX_PANE'],'meminfo':Path('/proc/meminfo').read_text(),'disk':shutil.disk_usage(B)._asdict(),'processes':subprocess.check_output(['ps','-eo','pid,ppid,stat,comm,args'],text=True),'work19_exists':(B/'work_ia840f_fim_19').exists(),'evidence19_exists':(B/'qualification/fim-build-19').exists(),'files':{}}
for p in paths:
 b=p.read_bytes();assert len(b)<2000000
 r['files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
out=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=out,check=True)
print('PREFLIGHT19_COMPLETE',hashlib.sha256(out).hexdigest(),flush=True)
