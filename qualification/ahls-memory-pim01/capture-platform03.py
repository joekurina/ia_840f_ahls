import os,socket,json,hashlib,base64,gzip,subprocess,traceback
from pathlib import Path
from datetime import datetime,timezone
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
W=Path("/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21")
expected={'ofs-common/src/fpga_family/agilex/sys_pll/sys_pll_pkg.sv': {'sha256': '0f125935d8003f42e57c736ba2ed93984a3224dfe3741fb6466b9fdc3fc5b2fb'}, 'ofs-common/src/common/lib/mux/pf_vf_mux_pkg.sv': {'sha256': '994a331483f02aa77ca6f88ac41405883e2bb6159cea544b4a87275ad74e5a2c'}, 'ipss/pcie/rtl/ofs_fim_pcie_pkg.sv': {'sha256': 'aded8bd04ca3cfc885872186ed6a460ecac0be2da009c96899a623ed26b63a8f'}}
out={"timestamp":datetime.now(timezone.utc).isoformat(),"root":str(W),"files":{},"errors":[]}
for n,e in expected.items():
 try:
  p=W/n;b=p.read_bytes();assert len(b)<=2000000,(n,len(b));h=hashlib.sha256(b).hexdigest()
  out["files"][n]={"bytes":len(b),"sha256":h,"expected_sha256":e["sha256"],"matches_expected":h==e["sha256"],"base64":base64.b64encode(b).decode()}
 except Exception as x:out["errors"].append({"path":n,"exception":repr(x)})
assert sum(e["bytes"] for e in out["files"].values())<80000000
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(["tmux","load-buffer","-b","ia840f_mempim_capture03","-"],input=blob,check=True)
subprocess.run(["tmux","set-buffer","-b","ia840f_mempim_capture03_sha256",hashlib.sha256(blob).hexdigest()],check=True)
print("CAPTURED",len(out["files"]),"SHA256",hashlib.sha256(blob).hexdigest(),flush=True)
