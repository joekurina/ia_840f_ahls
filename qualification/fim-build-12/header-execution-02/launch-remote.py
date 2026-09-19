from pathlib import Path
import os,sys,json,hashlib,socket,subprocess,base64
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';S=B/'ofs-agx7-pcie-attach';X=E/'header-execution-02'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
sys.dont_write_bytecode=True
sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'))
import ia840f_header_gate as gate

import time
assert not (E/'header-run').exists() and not (X/'runner-process.json').exists()
os.chdir(gate.PROJECT)
with (X/'runner-outer.log').open('xb') as log:
 p=subprocess.Popen(['python3','-B',str(E/'run_headers.py')],cwd=gate.PROJECT,stdout=log,stderr=subprocess.STDOUT)
 with (X/'runner-process.json').open('x') as f:json.dump(dict(pid=p.pid,start_time=gate.start_time(p.pid),argv=['python3','-B',str(E/'run_headers.py')],cwd=str(gate.PROJECT)),f,indent=2)
 rc=p.wait()
 with (X/'runner-exit.json').open('x') as f:json.dump(dict(returncode=rc),f)
print('RUNNER EXIT',rc)
print((X/'runner-outer.log').read_text())
if (E/'header-run/result.json').exists():print((E/'header-run/result.json').read_text())
