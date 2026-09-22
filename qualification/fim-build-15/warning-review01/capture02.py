import os,socket,json,datetime,hashlib,gzip,base64,subprocess,re
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-15';O=B/'work_ia840f_fim_15/syn/board/ia840f/syn_top/output_files'
targets={'native.log':E/'run/native.log','status.json':E/'run/status.json','ofs_top.syn.rpt':O/'ofs_top.syn.rpt','ofs_top.syn.summary':O/'ofs_top.syn.summary','ofs_top.fit.rpt':O/'ofs_top.fit.rpt','ofs_top.fit.summary':O/'ofs_top.fit.summary'}
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'ordinary-file warning snapshot, no build modification; in-progress fitter evidence is partial','files':{}}
for name,p in targets.items():
 if not p.exists():r['files'][name]={'missing':True,'path':str(p)};continue
 a=p.stat();assert a.st_size<=512*1024**2,'bounded diagnostic source read'
 if name.endswith('.rpt'):
  selected=[];context=0;h=hashlib.sha256();n=0
  with p.open('rb') as f:
   while n<a.st_size:
    line=f.readline(a.st_size-n);n+=len(line);h.update(line)
    if not line:break
    text=line.decode(errors='replace');ln=locals().get('ln',0)+1
    if re.search(r'Critical Warning|Warning\s*(?:\(|;)|Error\s*(?:\(|;)',text,re.I):context=6
    if context:selected.append({'line':ln,'text':text.rstrip('\r\n')});context-=1
  r['files'][name]={'path':str(p),'source_bytes_read':n,'source_sha256':h.hexdigest(),'extraction':'diagnostic lines plus following five lines; not complete report','rows':selected};ln=0
 else:
  assert a.st_size<=32*1024**2,'full log bound'
  with p.open('rb') as f:b=f.read(a.st_size)
  r['files'][name]={'path':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 z=p.stat();r['files'][name].update(before_size=a.st_size,after_size=z.st_size,before_mtime_ns=a.st_mtime_ns,after_mtime_ns=z.st_mtime_ns,changed_during_capture=(a.st_size,a.st_mtime_ns)!=(z.st_size,z.st_mtime_ns))
b=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim15_warnings02','-'],input=base64.b64encode(b),check=True)
print('WORK15_WARNINGS02',hashlib.sha256(b).hexdigest(),flush=True)
