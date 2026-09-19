#!/usr/bin/env python3
"""Remote readback of the exact before-inventory through an owned tmux window."""
import json
from pathlib import Path
import shlex
import subprocess

P=Path(__file__).resolve().parent
before=json.loads((P/'remote-before.json').read_text())
buffer='msa-fix01-after-20260919-d'
remote='''import os,socket,pathlib,json,hashlib,subprocess
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
expected=EXPECTED
actual={}
for label,e in expected.items():
 d=pathlib.Path(e['source']).read_bytes()
 actual[label]={'source':e['source'],'sha256':hashlib.sha256(d).hexdigest(),'bytes':len(d)}
assert actual==expected
payload=json.dumps({'batch':BUFFER,'hostname':socket.gethostname(),'uid':os.getuid(),'files':actual,'unchanged':True},sort_keys=True).encode()
subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=payload,check=True)
'''.replace('EXPECTED',repr(before['files'])).replace('BUFFER',repr(buffer))
(P/'remote-after-reader.py').write_text(remote)
argv=['ssh','uwb_student00@100.101.227.97','tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t ia840f_mailbox_monitored_01 -n msa-fix01-after '+shlex.quote('python3 -c '+shlex.quote(remote))]
r=subprocess.run(argv,capture_output=True,text=True,check=True)
(P/'remote-after-transport.json').write_text(json.dumps({'argv':argv,'stdout':r.stdout,'stderr':r.stderr,'buffer':buffer},indent=2)+'\n')
print(r.stdout)
