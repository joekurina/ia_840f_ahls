"""Owned tmux transport; only supplied preparation/readback scripts."""
from pathlib import Path
import base64, subprocess, shlex, sys
ROOT=Path(__file__).parent
HOST='uwb_student00@100.101.227.97'
SESSION='ia840f_mailbox_monitored_01'
if __name__=='__main__':
 p=Path(sys.argv[1]);code=p.read_bytes()
 cmd='python3 -c '+shlex.quote('import base64;exec(compile(base64.b64decode('+repr(base64.b64encode(code).decode())+'),'+repr(p.name)+',"exec"))')+'; exec bash'
 pane=subprocess.check_output(['ssh',HOST,'tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t '+SESSION+' -n work10-prepare '+shlex.quote(cmd)],text=True).strip()
 (ROOT/(p.stem+'.pane')).write_text(pane)
 print(pane)
