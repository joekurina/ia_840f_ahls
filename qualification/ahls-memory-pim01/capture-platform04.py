import os,socket,json,hashlib,base64,gzip,subprocess,traceback
from pathlib import Path
from datetime import datetime,timezone
assert socket.gethostname()=="Agilex7Workstation" and os.getuid()==1000 and os.environ.get("TMUX")
W=Path("/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21")
expected={'ipss/pcie/qip/sv_wrapper/pcie_ss_if_info.vh': {'sha256': '5e194ae3669e56b1bcda29745616c66c1899ccfd9708aceb47bc1db91ad4614c'}, 'ipss/pcie/qip/sv_wrapper/pcie_ss_ip_params.vh': {'sha256': 'ff4d6d6d0d5ca28f741836195ad77c1533e966a16e67f3753f3202784e1824e9'}, 'ofs-common/src/common/lib/mux/pf_vf_mux_default_rtable.vh': {'sha256': '1c4fc28db1af9ecbc637d1fa99deacd8f9d5e71efb97e9a5537ddc152323cfd8'}, 'ofs-common/src/fpga_family/agilex/sys_pll/sv_wrapper/sys_pll_if_info.vh': {'sha256': 'baa461dd8e4b1c377734d22dca780cf2932dcaabbd226934bd2ac1d4337e53dc'}, 'ofs-common/src/fpga_family/agilex/sys_pll/sv_wrapper/sys_pll_ip_params.vh': {'sha256': '814728c53a5a2c19e5909e601ac3d16dd18db3b0dde7d171dbdb012ac67bd0c5'}}
out={"timestamp":datetime.now(timezone.utc).isoformat(),"root":str(W),"files":{},"errors":[]}
for n,e in expected.items():
 try:
  p=W/n;b=p.read_bytes();assert len(b)<=2000000,(n,len(b));h=hashlib.sha256(b).hexdigest()
  out["files"][n]={"bytes":len(b),"sha256":h,"expected_sha256":e["sha256"],"matches_expected":h==e["sha256"],"base64":base64.b64encode(b).decode()}
 except Exception as x:out["errors"].append({"path":n,"exception":repr(x)})
assert sum(e["bytes"] for e in out["files"].values())<80000000
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(["tmux","load-buffer","-b","ia840f_mempim_capture04","-"],input=blob,check=True)
subprocess.run(["tmux","set-buffer","-b","ia840f_mempim_capture04_sha256",hashlib.sha256(blob).hexdigest()],check=True)
print("CAPTURED",len(out["files"]),"SHA256",hashlib.sha256(blob).hexdigest(),flush=True)
