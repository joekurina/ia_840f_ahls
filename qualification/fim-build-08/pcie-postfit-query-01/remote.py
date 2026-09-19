import subprocess,shlex,time,sys
host='uwb_student00@100.101.227.97'
cmd=sys.argv[1]
subprocess.run(['ssh',host,'tmux send-keys -t %356 '+shlex.quote(cmd)+' Enter'],check=True)
time.sleep(float(sys.argv[2]) if len(sys.argv)>2 else 2)
p=subprocess.run(['ssh',host,'tmux capture-pane -p -S -2000 -t %356'],capture_output=True,text=True,check=True)
print(p.stdout)
