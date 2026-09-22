import json,os,subprocess,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-16')
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{}}
for name in ('issuance-receipt01.json','compile-authorization.json','run/status.json','run/native-status.json'):
 p=E/name
 if p.exists():
  b=p.read_bytes();r['files'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
  if name!='compile-authorization.json':r['files'][name]['text']=b.decode()
p=E/'run/native.log'
if p.exists():
 with p.open('rb') as f:f.seek(max(0,p.stat().st_size-16000));r['log_tail']=f.read().decode(errors='replace')
rows=[x.split(None,3) for x in subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True).splitlines()[1:]]
s=json.loads((E/'run/status.json').read_text()) if (E/'run/status.json').exists() else {}
owned={s.get('runner_pid'),s.get('native_pid')}-{None}
for _ in range(32):
 nxt=owned|{int(x[0]) for x in rows if int(x[1]) in owned}
 if nxt==owned:break
 owned=nxt
r['owned_processes']=[x for x in rows if int(x[0]) in owned]
r['process_details']={}
for pid in sorted(owned):
 p=Path('/proc')/str(pid)
 try:
  st=(p/'stat').read_text().rsplit(')',1)[1].split()
  r['process_details'][str(pid)]={'start_ticks':st[19],'cpu_ticks':int(st[11])+int(st[12]),'state':st[0],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd')}
 except FileNotFoundError:pass
out=E.parents[1]/'work_ia840f_fim_16/syn/board/ia840f/syn_top/output_files'
r['stage_reports']={}
for name in ('ofs_top.flow.rpt','ofs_top.syn.summary','ofs_top.fit.plan.summary','ofs_top.fit.place.summary','ofs_top.fit.route.summary','ofs_top.fit.finalize.summary','ofs_top.fit.summary','ofs_top.sta.summary','ofs_top.asm.summary'):
 p=out/name
 if p.exists():
  b=p.read_bytes();r['stage_reports'][name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'text':b.decode(errors='replace')[-20000:]}
# Bounded ordinary-file progress evidence; no vendor commands.
import re
r['progress_files']={}
for p in (E/'run/native.log',out/'ofs_top.fit.rpt'):
 if not p.is_file():continue
 before=p.stat();limit=64000000
 with p.open('rb') as f:data=f.read(limit)
 after=p.stat();text=data.decode(errors='replace');marks=[]
 for i,line in enumerate(text.splitlines(),1):
  if ('IA840F' in line and any(w in line.lower() for w in ('margin','hold','signoff'))) or re.search(r'(?:placement|routing|preparation|physical synthesis|periphery|fitter).*(?:successful|completed|ended|started)|(?:starting|beginning|running|completed).*?(?:placement|routing|preparation|physical synthesis|periphery)',line,re.I):marks.append({'line':i,'text':line[:2500]})
 r['progress_files'][str(p)]={'bytes_read':len(data),'sha256':hashlib.sha256(data).hexdigest(),'size_before':before.st_size,'size_after':after.st_size,'stable':(before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns),'complete_read':len(data)==before.st_size,'markers':marks[-60:]}

b=json.dumps(r,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_fim16_status05','-'],input=b,check=True)
print('WORK16_STATUS05',hashlib.sha256(b).hexdigest(),flush=True)
