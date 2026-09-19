import subprocess,shlex,time,sys
from pathlib import Path
cmd='python3 -c '+shlex.quote(Path(sys.argv[1]).read_text())
subprocess.run(['ssh','uwb_student00@100.101.227.97','tmux send-keys -t %357 '+shlex.quote(cmd)+' Enter'],check=True)
time.sleep(float(sys.argv[2]) if len(sys.argv)>2 else 2)
p=subprocess.run(['ssh','uwb_student00@100.101.227.97','tmux capture-pane -p -S -100 -t %357'],capture_output=True,text=True,check=True)
print(p.stdout)
