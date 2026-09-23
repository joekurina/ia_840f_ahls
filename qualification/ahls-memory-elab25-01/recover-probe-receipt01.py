import os,socket,json,hashlib,subprocess
from pathlib import Path
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
p=Path("/home/uwb_student00/ahls/new_BSP/work_ahls_memory_elab25_01/probe01/result.json")
b=p.read_bytes();h=hashlib.sha256(b).hexdigest();assert h=='3ad57d05cec0dfa816f3acc9c982c533a1260705ba969e40abf75c24c2f8c2b3'
r={"path":str(p),"bytes":len(b),"sha256":h,"kind":"read-only durable probe receipt recovery; native not rerun"}
b=json.dumps(r).encode();subprocess.run(["tmux","load-buffer","-b","ia840f_memelab25_probe01_recovery","-"],input=b,check=True);print("RECOVERY_SHA256="+hashlib.sha256(b).hexdigest(),flush=True)
