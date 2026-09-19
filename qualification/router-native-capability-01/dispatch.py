import base64,json,subprocess,sys,time,shlex
from pathlib import Path
ROOT=Path(__file__).parent
REMOTE='/home/uwb_student00/quartus_26/qualification/router-native-capability-01'
def ssh(args):
 return subprocess.check_output(['ssh','uwb_student00@100.101.227.97',shlex.join(args)],text=True)
name=sys.argv[1]
script=Path(sys.argv[2]).read_text()
code="import os,socket; assert socket.gethostname()=='Agilex7Workstation'; assert os.getuid()==1000\n"+script
payload=base64.b64encode(code.encode()).decode()
cmd="python3 -c \"import base64; exec(base64.b64decode('"+payload+"'))\""
(ROOT/(name+'.remote.py')).write_text(code)
ssh(['tmux','send-keys','-t','%392','-l',cmd])
ssh(['tmux','send-keys','-t','%392','Enter'])
print('dispatched',name)
