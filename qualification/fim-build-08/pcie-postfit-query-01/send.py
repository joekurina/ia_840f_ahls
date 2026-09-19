from pathlib import Path
import subprocess,shlex,sys
p=Path(__file__).parent
script=Path(sys.argv[1]).read_text()
r=subprocess.run(['python3',str(p/'remote.py'),'python3 -c '+shlex.quote(script),sys.argv[2] if len(sys.argv)>2 else '3'],capture_output=True,text=True)
(p/(Path(sys.argv[1]).stem+'.capture')).write_text(r.stdout)
print(r.stdout[-16000:])
