import subprocess,shlex,base64,sys,time,pathlib
ROOT=pathlib.Path(__file__).parent
HOST='uwb_student00@100.101.227.97'
def ssh(s):
 return subprocess.check_output(['ssh','-o','BatchMode=yes',HOST,s])
def run(name,code):
 payload=base64.b64encode(code.encode()).decode()
 cmd='python3 -u -c '+shlex.quote('import base64; exec(base64.b64decode('+repr(payload)+'))')
 pane=ssh('tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t ia840f_mailbox_monitored_01 -n '+shlex.quote('pyrepair-'+name)+' '+shlex.quote(cmd+'; read -r _')).decode().strip()
 print(pane,flush=True)
 time.sleep(3)
 out=ssh('tmux capture-pane -p -S -3000 -t '+shlex.quote(pane)).decode()
 (ROOT/(name+'-pane.txt')).write_text(out)
 print(out)
if __name__=='__main__': run(sys.argv[1],pathlib.Path(sys.argv[2]).read_text())
