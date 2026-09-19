from pathlib import Path
import os,socket,subprocess,hashlib,json
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
b=Path('/home/uwb_student00/ahls/new_BSP');w=b/'work_ia840f_fim_08';e=b/'qualification/fim-build-08/pcie-postfit-query-02';e.mkdir(exist_ok=False);s=e/'scratch';p=s/'syn/board/ia840f/syn_top'
def sha(x):
 h=hashlib.sha256()
 with open(x,'rb') as f:
  for v in iter(lambda:f.read(4194304),b''):h.update(v)
 return h.hexdigest()
def inv(root):
 return {str(x.relative_to(root)):({'link':os.readlink(x)} if x.is_symlink() else {'sha256':sha(x)}) for x in sorted(root.rglob('*')) if x.is_symlink() or x.is_file()}
before=inv(w);(e/'work08-before.json').write_text(json.dumps(before,sort_keys=True))
subprocess.run(['cp','-a','--reflink=auto',str(w),str(s)],check=True,timeout=120)
pim=b/'ofs-platform-afu-bbb';subprocess.run(['cp','-a','--reflink=auto',str(pim),str(e/'pim')],check=True,timeout=90)
relocations=[]
mapping={str(w):str(s),str(pim):str(e/'pim')}
for x in s.rglob('*'):
 if x.is_symlink():
  old=os.readlink(x);new=old
  for a,z in mapping.items():new=new.replace(a,z)
  if new!=old:x.unlink();x.symlink_to(new);relocations.append({'path':str(x.relative_to(s)),'old':old,'new':new})
 elif x.is_file() and x.suffix in {'.tcl','.qsf','.qip','.ip','.qsys','.xml','.sdc','.json','.sh','.py','.txt','.ini'}:
  raw=x.read_bytes()
  if b'\x00' in raw:continue
  new=raw
  for a,z in mapping.items():new=new.replace(a.encode(),z.encode())
  if new!=raw:x.write_bytes(new);relocations.append({'path':str(x.relative_to(s)),'before':hashlib.sha256(raw).hexdigest(),'after':sha(x)})
(e/'relocations.json').write_text(json.dumps(relocations,indent=2))
# Keep the original QSF and build_gate.tcl active; extend only the isolated Python dispatcher.
g=s/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py';original=g.read_text();needle='    try:\n        if sys.argv[1:]'
assert needle in original
original=original.replace(needle,'    try:\n        if sys.argv[1:] == ["quartus"] and Path.cwd() == Path('+repr(str(p))+'):\n            import ia840f_query02_gate\n            ia840f_query02_gate.validate(runtime=True)\n            return 0\n        if sys.argv[1:]',1);g.write_text(original)
query=(b/'qualification/fim-build-08/pcie-postfit-query-01/query.tcl').read_text()
# Add only documented read-only information queries; no candidate SDC loaded.
query=query.replace('DIV [get_clock_info -divide_by $c]','DIV [get_clock_info -divide_by $c] TARGETS [get_clock_info -targets $c] MASTER_PIN [get_clock_info -master_clock_pin $c]')
(e/'query.tcl').write_text(query)
gate='''import hashlib,json,os,sys
from pathlib import Path
E=Path(__E__)
P=E/'scratch/syn/board/ia840f/syn_top'
def sha(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for v in iter(lambda:f.read(4194304),b''):h.update(v)
 return h.hexdigest()
def validate(runtime=False):
 r=json.loads((E/'candidate.json').read_text())
 a=E/'authorization.json'
 if not a.is_file():raise ValueError('QUERY02_REJECT missing reviewed authorization')
 auth=json.loads(a.read_text())
 if auth!={'approved':True,'candidate_sha256':sha(E/'candidate.json'),'permission':'exact-read-only-postfit-query02'}:raise ValueError('QUERY02_REJECT authorization binding')
 if r['ready_for_build'] is not False or r['part']!='AGFB027R25A2E2V':raise ValueError('QUERY02_REJECT target/readiness')
 for filename,digest in r['files'].items():
  if sha(filename)!=digest:raise ValueError('QUERY02_REJECT source binding '+filename)
 for filename,target in r['links'].items():
  if os.readlink(filename)!=target:raise ValueError('QUERY02_REJECT link binding '+filename)
 if runtime:
  proc=Path('/proc')/str(os.getppid())
  exe=str((proc/'exe').resolve());argv=(proc/'cmdline').read_bytes().rstrip(b'\\0').decode().split('\\0')
  if exe!=r['executable'] or argv!=r['runtime_argv'] or (proc/'cwd').resolve()!=P:raise ValueError('QUERY02_REJECT runtime context')
 return r
if __name__=='__main__':
 try:validate(runtime=True)
 except Exception as exc:print(exc,file=sys.stderr);sys.exit(1)
'''.replace('__E__',repr(str(e)))
(s/'ofs-common/tools/ofss_config/ia840f_query02_gate.py').write_text(gate)
files={};links={}
for root in [s,e/'pim']:
 for x in root.rglob('*'):
  if x.is_symlink():links[str(x)]=os.readlink(x)
  elif x.is_file():files[str(x)]=sha(x)
for x in [e/'query.tcl',Path('/opt/altera/26.1.1/quartus/bin/quartus_sta'),Path('/opt/altera/26.1.1/quartus/linux64/quartus_sta')]:files[str(x)]=sha(x)
candidate={'schema':1,'approved':False,'ready_for_build':False,'status':'PREPARED_UNREVIEWED_NOT_LAUNCHED','permission':'exact-read-only-postfit-query02','part':'AGFB027R25A2E2V','target':'ia840f','cwd':str(p),'executable':'/opt/altera/26.1.1/quartus/linux64/quartus_sta','argv':['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(e/'query.tcl')],'runtime_argv':['/opt/altera/26.1.1/quartus/linux64/quartus_sta','-t',str(e/'query.tcl')],'runtime_argv_status':'source-derived launcher convention; native confirmation pending','files':files,'links':links,'database_origin':str(w),'work08_inventory_sha256':sha(e/'work08-before.json'),'timeout_seconds':80,'read_only_api':['project_open','create_timing_netlist','read_sdc','update_timing_netlist','get_cells','get_cell_info','get_clocks','get_clock_info','delete_timing_netlist','project_close']}
(e/'candidate.json').write_text(json.dumps(candidate,indent=2,sort_keys=True))
r=subprocess.run(['python3','-B',str(g),'quartus'],cwd=p,capture_output=True,text=True)
(e/'missing-auth-test.json').write_text(json.dumps({'rc':r.returncode,'stdout':r.stdout,'stderr':r.stderr,'vendor_launched':False},indent=2));assert r.returncode!=0 and 'missing reviewed authorization' in r.stderr
missing=[str(x) for x in s.rglob('*') if x.is_symlink() and not x.exists()]
after=inv(w);(e/'work08-after.json').write_text(json.dumps(after,sort_keys=True));assert before==after
result={'status':'PREPARED_UNREVIEWED_NOT_LAUNCHED','original_work08_unchanged':before==after,'bound_files':len(files),'relocations':len(relocations),'missing_symlinks':missing,'missing_authorization_rejected':True,'vendor_query_launched':False,'work09_modified':False}
(e/'result.json').write_text(json.dumps(result,indent=2));print('QUERY02_RESULT',json.dumps(result),flush=True)
# Exact readback of created candidate and tests; export concise artifacts via a unique tmux buffer.
export={n:(e/n).read_text() for n in ['candidate.json','result.json','missing-auth-test.json','relocations.json','query.tcl']}
payload=json.dumps(export);(e/'export.json').write_text(payload);subprocess.run(['tmux','load-buffer','-b','query02_prepared_357',str(e/'export.json')],check=True)
print('EXPORT_SHA256',sha(e/'export.json'),flush=True)
