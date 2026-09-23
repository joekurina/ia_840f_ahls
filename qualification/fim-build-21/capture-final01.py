import base64,datetime,gzip,hashlib,json,os,socket,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_21';E=B/'qualification/fim-build-21/final-capture01';batch='ia840f_fim21_final01'
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX') and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
status=json.loads((B/'qualification/fim-build-21/run/status.json').read_bytes())
assert status['state']=='finished' and status['native_returncode']==0 and not status['gate_rejection']
assert not E.exists();E.mkdir()
root=W/'syn/board/ia840f/syn_top/output_files'
names=['ofs_top.asm.rpt', 'ofs_top.fit.finalize.rpt', 'ofs_top.fit.place.rpt', 'ofs_top.fit.plan.rpt', 'ofs_top.fit.retime.rpt', 'ofs_top.fit.route.rpt', 'ofs_top.fit.rpt', 'ofs_top.fit.summary', 'ofs_top.flow.rpt', 'ofs_top.sdc_constraints.rpt', 'ofs_top.sta.rpt', 'ofs_top.sta.summary', 'ofs_top.tq.drc.signoff.rpt']
paths={n:root/n for n in names}
for n in ('ofs_top.qsf','ofs_top.qpf','top.sdc','fme_id.mif','build_env_db.txt'):
 p=root.parent/n
 if p.is_file():paths['project/'+n]=p
for n in ('run/status.json','run/native-status.json'):
 paths['runner/'+n]=(B/'qualification/fim-build-21'/n)
assert int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024>10000000000
assert sum(p.stat().st_size for p in paths.values())<100000000
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'images':{},'hardware_access':False,'vendor_tools_executed':False}
for name,p in paths.items():
 before=p.stat();assert p.is_file() and not p.is_symlink();b=p.read_bytes();after=p.stat()
 assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
 r['files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'mtime_ns':after.st_mtime_ns,'base64':base64.b64encode(b).decode()}
for p in sorted(root.iterdir()):
 if p.is_file() and p.suffix in ('.sof','.rbf','.msf','.pmsf'):
  before=p.stat();h=hashlib.sha256()
  with p.open('rb') as f:
   for chunk in iter(lambda:f.read(2097152),b''):h.update(chunk)
  after=p.stat();assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
  r['images'][p.name]={'bytes':after.st_size,'sha256':h.hexdigest(),'mtime_ns':after.st_mtime_ns}
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),compresslevel=6,mtime=0)
with (E/'result01.json.gz').open('xb') as f:f.write(blob)
assert hashlib.sha256((E/'result01.json.gz').read_bytes()).hexdigest()==hashlib.sha256(blob).hexdigest()
subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=blob,check=True)
print('FINAL_CAPTURE01',len(r['files']),len(blob),hashlib.sha256(blob).hexdigest(),flush=True)
