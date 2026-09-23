import os,socket,json,hashlib,shutil,subprocess
from pathlib import Path
from datetime import datetime,timezone
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
root=Path("/opt/altera/25.1")
files={}
for pattern in ("*/bin/vsim","*/bin/vlog","*/bin/vlib","*/linux_x86_64/vsim","*/linux_x86_64/vlog","*/linux_x86_64/vlib","*/modelsim.ini"):
 for p in root.glob(pattern):
  assert p.is_file()
  b=p.read_bytes();files[str(p)]={"real":str(p.resolve()),"bytes":len(b),"sha256":hashlib.sha256(b).hexdigest()}
assert len(files)<30
info=Path("/home/uwb_student00/quartus_25/instructions.md").read_text()
res={"batch":"ia840f_ackfix_meta01","utc":datetime.now(timezone.utc).isoformat(),"tools":files,"instructions_selected":[x for x in info.splitlines() if any(k in x for k in ("export ","questa","vsim","vlog","vlib","SALT_LICENSE_SERVER","LM_LICENSE_FILE"))],"meminfo":Path("/proc/meminfo").read_text(),"disk_free":shutil.disk_usage("/home/uwb_student00/ahls/new_BSP").free,"cpus":sorted(os.sched_getaffinity(0)),"fim_status":json.loads(Path("/home/uwb_student00/ahls/new_BSP/qualification/fim-build-21/run/status.json").read_bytes()),"hardware_access":False,"vendor_tools_executed":False}
b=json.dumps(res,indent=2).encode();subprocess.run(["tmux","load-buffer","-b","ia840f_ackfix_meta01","-"],input=b,check=True);print("RESULT_SHA256="+hashlib.sha256(b).hexdigest(),flush=True)
