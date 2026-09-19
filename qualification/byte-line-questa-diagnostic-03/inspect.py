import os, json, hashlib, socket
from pathlib import Path
root=Path('/opt/altera/26.1.1/questa_fe')
def record(p):
    b=p.read_bytes()
    text=b.decode(errors='replace')
    lines=text.splitlines()
    if p.name=='modelsim.ini':
        selected=set()
        for i,line in enumerate(lines):
            if any(x in line.lower() for x in ('vopt','novopt','[vsim]','[vlog]','others =')):
                selected.update(range(max(0,i-3),min(len(lines),i+4)))
        text='\n'.join(str(i+1)+': '+lines[i] for i in sorted(selected))
    return {'path':str(p),'resolved':str(p.resolve()),'size':len(b),'sha256':hashlib.sha256(b).hexdigest(),'text':text}
r={'host':socket.gethostname(),'tmux':os.environ.get('TMUX'),'files':[]}
for p in (root/'modelsim.ini',root/'vco',Path('/home/uwb_student00/modelsim.ini')):
    if p.is_file(): r['files'].append(record(p))
r['root_entries']=[p.name for p in root.iterdir()]
print(json.dumps(r))
