import base64, json, subprocess, shlex, time
from pathlib import Path
D=Path(__file__).resolve().parent
import sys
name=sys.argv[1]
script=(D/(name+'.py')).read_bytes()
# The entire remote operational program runs inside the specified tmux.
program='import base64;exec(base64.b64decode('+repr(base64.b64encode(script).decode())+'))'
# Short framed base64 records prevent terminal wrapping from changing data.
wrapper='import base64,io,contextlib,traceback; o=io.StringIO();\nwith contextlib.redirect_stdout(o):\n try: exec('+repr(program)+')\n except: traceback.print_exc(file=o)\ns=base64.b64encode(o.getvalue().encode()).decode();print("DIAG_BEGIN");[print(s[i:i+60]) for i in range(0,len(s),60)];print("DIAG_END")'
remote='python3 -c '+shlex.quote(wrapper)+'; exec bash --noprofile --norc'
args=['ssh','-o','BatchMode=yes','uwb_student00@100.101.227.97','tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t ia840f_mailbox_monitored_01 -n '+shlex.quote('diag03-'+name)+' '+shlex.quote(remote)]
p=subprocess.run(args,capture_output=True,text=True,timeout=30)
(D/(name+'.launch.json')).write_text(json.dumps({'argv':args,'rc':p.returncode,'stdout':p.stdout,'stderr':p.stderr},indent=2))
if p.returncode: raise RuntimeError(p.stderr)
pane=p.stdout.strip()
for i in range(30):
    q=subprocess.run(['ssh','-o','BatchMode=yes','uwb_student00@100.101.227.97','tmux capture-pane -p -J -S -2000 -t '+shlex.quote(pane)],capture_output=True,text=True,timeout=30)
    if 'DIAG_END' in q.stdout:
        raw=q.stdout.split('DIAG_BEGIN',1)[1].split('DIAG_END',1)[0]
        text=base64.b64decode(''.join(raw.split())).decode()
        (D/(name+'.result.json')).write_text(text)
        print(text)
        break
    time.sleep(1)
else: raise RuntimeError('Probe did not finish; inspect pane '+pane)
