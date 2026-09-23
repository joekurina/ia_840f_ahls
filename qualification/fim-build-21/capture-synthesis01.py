import base64,datetime,gzip,hashlib,json,os,socket,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_21';E=B/'qualification/fim-build-21/synthesis-capture01';batch='ia840f_fim21_synthesis01'
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX') and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
assert not E.exists();E.mkdir()
names=['ofs_top.syn.rpt','ofs_top.syn.ae.rpt','ofs_top.syn.summary','ofs_top.drc.synthesized.rpt','ofs_top.drc.partitioned.rpt']
root=W/'syn/board/ia840f/syn_top/output_files'
assert int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024>10000000000
assert sum((root/n).stat().st_size for n in names)<100000000
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'hardware_access':False,'vendor_tools_executed':False}
for name in names:
 p=root/name;before=p.stat();assert p.is_file() and not p.is_symlink();b=p.read_bytes();after=p.stat()
 assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
 r['files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'mtime_ns':after.st_mtime_ns,'base64':base64.b64encode(b).decode()}
assert len(r['files'])==5
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),compresslevel=6,mtime=0)
with (E/'result01.json.gz').open('xb') as f:f.write(blob)
assert hashlib.sha256((E/'result01.json.gz').read_bytes()).hexdigest()==hashlib.sha256(blob).hexdigest()
subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=blob,check=True)
print('SYNTHESIS_CAPTURE01',len(r['files']),len(blob),hashlib.sha256(blob).hexdigest(),flush=True)
