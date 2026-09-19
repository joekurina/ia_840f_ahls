import pathlib,json,sys,contextlib,io,hashlib
from remote import run
r=pathlib.Path(__file__).resolve().parent
for group in ['metadata','ed_sim_mem','ed_sim_mem_group1']:
 code="""import pathlib,json,hashlib,difflib
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01')
group=GROUP
if group=='metadata':
 for n in ['ed_sim_mem','ed_sim_mem_group1']:
  (r/(n+'.xml.diff')).write_text(''.join(difflib.unified_diff((r/'before'/(n+'.ip')).read_text().splitlines(True),(r/(n+'.ip')).read_text().splitlines(True),fromfile='before/'+n+'.ip',tofile=n+'.ip')))
 files=[p for p in r.iterdir() if p.is_file() and p.suffix in ['.json','.tcl','.log','.txt','.diff','.qpf','.qsf','.ip','.qsys']]+list((r/'before').glob('*.ip'))
else: files=[p for p in (r/group).rglob('*') if p.is_file()]
print(json.dumps({str(p.relative_to(r)):{'content':p.read_text(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in files}))
""".replace('GROUP',repr(group))
 out=r/(group+'-transfer.json')
 with contextlib.redirect_stdout(io.StringIO()):run(code,out)
 data=json.loads(out.read_text())
 for name,item in data.items():
  p=r/'artifacts'/name;p.parent.mkdir(parents=True,exist_ok=True);b=item['content'].encode();assert hashlib.sha256(b).hexdigest()==item['sha256'];p.write_bytes(b)
 print(group,'verified transferred files',len(data))
