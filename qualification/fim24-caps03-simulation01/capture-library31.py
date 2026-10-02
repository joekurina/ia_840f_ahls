"""Capture a bounded plaintext declaration region; no tools executed."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess
from pathlib import Path
BUFFER='ia840f_fim24_caps03_simulation_library31_result';P=Path('/opt/altera/25.1/questa_fe/intel/verilog/src/altera_lnsim.sv')
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'native_tools_executed':False,'hardware_access':False,'path':str(P),'available':P.is_file()}
if P.is_file():
 before=P.stat();assert before.st_size<64*1024**2;b=P.read_bytes();after=P.stat();assert len(b)==before.st_size==after.st_size and before.st_mtime_ns==after.st_mtime_ns
 lines=b.decode(errors='replace').splitlines(keepends=True);start=58260;end=58520;part=''.join(lines[start-1:end]).encode();assert len(part)<100000
 out.update(full_bytes=len(b),full_sha256=hashlib.sha256(b).hexdigest(),region_first_line=start,region_last_line=min(end,len(lines)),region_bytes=len(part),region_sha256=hashlib.sha256(part).hexdigest(),region_base64=base64.b64encode(part).decode())
raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('LIBRARY31',out['available'],h,flush=True)
