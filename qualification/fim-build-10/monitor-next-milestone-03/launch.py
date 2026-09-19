from pathlib import Path
import base64,shlex,subprocess,json
P=Path(__file__).parent
source=(P/'monitor.py').read_bytes()
compile(source,'monitor.py','exec')
code="import base64; __source=base64.b64decode("+repr(base64.b64encode(source).decode())+"); exec(compile(__source,'monitor.py','exec'))"
inner='python3 -u -c '+shlex.quote(code)+'; exec bash'
remote="tmux new-window -d -P -F '#{pane_id}' -t ia840f_mailbox_monitored_01 -n work10-milestone-03 "+shlex.quote(inner)
argv=['ssh','uwb_student00@100.101.227.97',remote]
(P/'launch-command.json').write_text(json.dumps(argv,indent=2)+'\n')
p=subprocess.run(argv,capture_output=True,text=True,check=True)
(P/'monitor.pane').write_text(p.stdout)
print(p.stdout,p.stderr)
