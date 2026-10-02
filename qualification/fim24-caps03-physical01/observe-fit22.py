"""Single ordinary-file/process observation of the already owned fit."""
import datetime,gzip,hashlib,json,os,re,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01');R=ROOT/'fit01';P=ROOT/'control08';J=ROOT/'base01/build/syn/board/ia840f/syn_top';O=P/'observation22';BUFFER='ia840f_fim24_caps03_physical_observation22_result'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_launched':False,'hardware_access':False};owned=False
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 O.mkdir();owned=True;out['files']={}
 for n in ('authority.json','status.json','result.json','gate-events.jsonl','gate-rejections.jsonl','configure.log','version.log','fitting.log'):
  p=R/n
  if not p.exists():out['files'][n]={'exists':False};continue
  size=p.stat().st_size;assert size<=32*1024**2;b=p.read_bytes();text=b.decode(errors='replace');item={'exists':True,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
  if n.endswith('.json'):
   try:item['data']=json.loads(text)
   except json.JSONDecodeError as exc:item['non_atomic_snapshot_error']=repr(exc)
  elif n.endswith('.jsonl'):item['data']=[json.loads(line) for line in text.splitlines() if line]
  else:
   lines=text.splitlines();item['line_count']=len(lines);item['milestones']=[{'line':i,'text':line[:1800]} for i,line in enumerate(lines,1) if re.search(r'Quartus Prime|Build 130|[Ee]rror|Critical Warning|IA840F_GATE|(?i:starting|completed|complete |successful|routing|placement|periphery|preparation|retiming|fitter stage|finaliz)',line)][-30:]
  out['files'][n]=item
 out['reports']={}
 for n in ('ofs_pr_afu.fit.rpt','ofs_pr_afu.fit.summary','ofs_pr_afu.fit.plan.rpt','ofs_pr_afu.fit.place.rpt','ofs_pr_afu.fit.route.rpt','ofs_pr_afu.fit.retime.rpt','ofs_pr_afu.fit.finalize.rpt'):
  p=J/'output_files'/n
  if p.exists():
   st=p.stat()
   with p.open('rb') as f:b=f.read(16384)
   out['reports'][n]={'bytes':st.st_size,'mtime_ns':st.st_mtime_ns,'header':b.decode(errors='replace').splitlines()[:16]}
 procs=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit() or int(p.name)==os.getpid():continue
  try:
   exe=os.readlink(p/'exe');cwd=os.readlink(p/'cwd');cmd=(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0))
   if Path(exe).name not in ('quartus_fit','quartus_sta','quartus_syn','cmake','make','gmake','python3','python3.9','python3.11'):continue
   if str(ROOT) not in cwd and not any(str(ROOT) in a for a in cmd):continue
   s=(p/'stat').read_text().rsplit(') ',1)[1].split();procs.append({'pid':int(p.name),'ppid':int(s[1]),'state':s[0],'start_ticks':s[19],'user_ticks':s[11],'system_ticks':s[12],'exe':exe,'cwd':cwd,'argv':cmd,'exe_sha256':hashlib.sha256(Path(exe).read_bytes()).hexdigest()})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 out['processes']=procs
 r=subprocess.run(['tmux','save-buffer','-b','ia840f_fim24_caps03_physical_fit19_rc','-'],capture_output=True,text=True);out['outer_completion']={'readback_rc':r.returncode,'outer_rc':int(r.stdout.strip()) if r.returncode==0 else None};out['success']=True
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (O/'snapshot22.json').open('x') as f:json.dump(out,f,indent=2)
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('FIT_OBSERVATION22',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
