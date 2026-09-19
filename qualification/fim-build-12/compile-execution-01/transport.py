import subprocess,shlex,json,sys
from pathlib import Path
ROOT=Path(__file__).parent
HOST='uwb_student00@100.101.227.97'
SESSION='ia840f_mailbox_monitored_01'
def ssh(args,data=None):
 cmd=['ssh',HOST,shlex.join(args)]
 with (ROOT/'transport-commands.jsonl').open('a') as f:f.write(json.dumps(cmd)+'\n')
 p=subprocess.run(cmd,input=data,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 with (ROOT/'transport-results.jsonl').open('a') as f:f.write(json.dumps(dict(command=cmd,rc=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace')))+'\n')
 if p.returncode:raise RuntimeError(p.stderr.decode())
 return p.stdout
def submit(name,path):
 data=Path(path).read_bytes();buf='w12ce01-'+name
 ssh(['tmux','load-buffer','-b',buf,'-'],data)
 command='tmux save-buffer -b '+shlex.quote(buf)+' - | python3 -B; rc=$?; printf "\\nREMOTE_WRAPPER_RC=%s\\n" "$rc"; exec sleep 86400'
 out=ssh(['tmux','new-window','-d','-P','-F','#{window_id} #{pane_id}','-t',SESSION,'-n',buf,command])
 (ROOT/(name+'-window.txt')).write_bytes(out);print(out.decode())
if __name__=='__main__':
 if sys.argv[1]=='submit':submit(sys.argv[2],sys.argv[3])
 elif sys.argv[1]=='capture':print(ssh(['tmux','capture-pane','-p','-S','-1000','-t',sys.argv[2]]).decode())
 elif sys.argv[1]=='get':
  data=ssh(['tmux','save-buffer','-b',sys.argv[2],'-']);(ROOT/sys.argv[3]).write_bytes(data);print(len(data))
