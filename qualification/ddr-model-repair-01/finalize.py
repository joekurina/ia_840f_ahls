import pathlib,json,hashlib,contextlib,io
from remote import run
r=pathlib.Path(__file__).resolve().parent
files={p.name:p.read_text() for p in r.iterdir() if p.suffix=='.py' or p.name=='REPORT.md'}
code="""import pathlib,json,hashlib,re
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');files=PAYLOAD
for name,text in files.items():
 p=r/('REPORT.md' if name=='REPORT.md' else 'execution-evidence/'+name);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text);assert p.read_text()==text
v=json.loads((r/'verification.json').read_text())
for n,m in v['models'].items():
 p=pathlib.Path(m['top']);ports={k:{'direction':dr,'width':int(hi)-int(lo)+1} for dr,hi,lo,k in re.findall(r'\\b(input|output|inout)\\s+wire\\s+\\[(\\d+):(\\d+)\\]\\s+(mem_\\w+)',p.read_text())};assert ports==m['ports'];assert hashlib.sha256(p.read_bytes()).hexdigest()==m['top_sha256']
for p,h in json.loads((r/'work04-before.json').read_text()).items():assert hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()==h
out={'report_sha256':hashlib.sha256((r/'REPORT.md').read_bytes()).hexdigest(),'verified_top_ports':True,'work04_unchanged':True,'ready_for_build':False,'uploaded_files':len(files),'provenance':json.loads((r/'provenance.json').read_text())};(r/'handoff-readback.json').write_text(json.dumps(out,indent=2));print((r/'handoff-readback.json').read_text())
""".replace('PAYLOAD',repr(files))
run(code,r/'22-handoff-readback.json')
print('local report SHA256',hashlib.sha256((r/'REPORT.md').read_bytes()).hexdigest())
