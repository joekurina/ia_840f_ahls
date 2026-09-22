import os,socket,select,subprocess,json,datetime,hashlib
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-15')
pid=24751;expected='6298611'
p=Path('/proc')/str(pid)
def identity():return (p/'stat').read_text().rsplit(')',1)[1].split()[19]
try:
 assert identity()==expected,'runner PID reused'
 fd=os.pidfd_open(pid,0)
 try:
  try:assert identity()==expected,'runner PID changed'
  except FileNotFoundError:pass
  print('WORK15_EXIT_WAIT_ARMED',pid,expected,flush=True)
  event=select.poll();event.register(fd,select.POLLIN);event.poll()
 finally:os.close(fd)
except ProcessLookupError:pass
except FileNotFoundError:pass
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'event':'recorded runner exited; native results require readback/review','runner_pid':pid,'expected_start_ticks':expected,'files':{}}
for name in ('run/status.json','run/native-status.json'):
 p=E/name
 if p.exists():
  b=p.read_bytes();r['files'][name]={'sha256':hashlib.sha256(b).hexdigest(),'text':b.decode()}
b=json.dumps(r,indent=2).encode()
subprocess.run(['tmux','load-buffer','-b','ia840f_fim15_exit01_result','-'],input=b,check=True)
print('WORK15_RUNNER_EXIT_EVENT',hashlib.sha256(b).hexdigest(),flush=True)
subprocess.run(['tmux','wait-for','-S','ia840f_fim15_exit01'],check=True)
