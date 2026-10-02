"""Bounded ordinary-file/process readback of completed file setup."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01');P=ROOT/'control03';R=ROOT/'setup01';T=R/'persona';BUFFER='ia840f_fim24_caps03_persona_completion13_result'
SELECTED=['build/platform/ofs_plat_if/par/afu_json.tcl', 'build/platform/ofs_plat_if/par/ofs_plat_if_addenda.qsf', 'build/platform/ofs_plat_if/par/user_clock_config.tcl', 'build/platform/ofs_plat_if/rtl/ofs_plat_if_top_config.vh', 'build/platform/ofs_plat_if/sim/ofs_plat_if_addenda.txt', 'build/platform/ofs_plat_if/sim/ofs_plat_if_includes.txt', 'build/platform/ofs_plat_if/sim/platform_if_addenda.txt', 'build/platform/ofs_plat_if/sim/platform_if_includes.txt', 'build/platform/platform_afu_top_config.vh', 'build/platform/platform_if_addenda.qsf', 'build/platform/sim/fim_afu_if_addenda.txt', 'build/platform/sim/fim_afu_if_includes.txt', 'build/platform/sim/fim_afu_if_modules.txt', 'build/platform/sim/fim_project_macros.txt', 'build/syn/board/ia840f/syn_top/ofs_pr_afu.qsf', 'build/syn/board/ia840f/syn_top/ofs_top.qpf', 'build/syn/board/ia840f/syn_top/ofs_top.qsf', 'hw/afu.qsf', 'hw/afu_json_info.vh', 'hw/ia840f_ahls_memory.json'];SEMANTIC='b1a975ff0432d6e6ac4cac6829f45486cbb78762fa96ad63a52cc20aba5a9779';ADMITTED='3e1923e703bbc4925c7162a4718a00469dcfa7faf930e426b302035a3b84e094'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def take(p,name):
 before=p.stat();assert before.st_size<=2_000_000,(name,before.st_size);b=p.read_bytes();after=p.stat();assert before.st_size==len(b)==after.st_size and before.st_mtime_ns==after.st_mtime_ns
 out['files'][name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'mtime_ns_before':before.st_mtime_ns,'mtime_ns_after':after.st_mtime_ns,'base64':base64.b64encode(b).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 native=json.loads((R/'result.json').read_text());assert hashlib.sha256(json.dumps(native,sort_keys=True).encode()).hexdigest()==SEMANTIC and native['manifest_sha256']==ADMITTED
 assert sha(P/'setup-inputs.admitted.json')==ADMITTED and native['execution_clean'] is True
 inv=native['persona_inventory'];observed=set()
 for d,dirs,files in os.walk(T,followlinks=False):
  for name in dirs+files:
   p=Path(d)/name
   if p.is_symlink() or p.is_file():observed.add(str(p.relative_to(T)))
 assert observed==set(inv)
 for n,m in inv.items():
  p=T/n
  if m['kind']=='symlink':assert p.is_symlink() and os.readlink(p)==m['target'] and str(p.resolve(strict=True))==m['resolved'],n
  else:assert p.is_file() and p.stat().st_size==m['bytes'] and sha(p)==m['sha256'],n
 for n in SELECTED:take(T/n,'persona/'+n)
 for n in ('result.json','status.json','configure.log','version.log','setup.log'):take(R/n,'operation/'+n)
 take(P/'setup09-outer.log','operation/setup09-outer.log')
 rc=subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim24_caps03_persona_setup09_rc','-'],text=True).strip();assert rc=='0'
 active=[]
 for d in Path('/proc').iterdir():
  if not d.name.isdigit():continue
  try:
   stat=(d/'stat').read_text().rsplit(') ',1)[1].split();pid=int(d.name);cmd=(d/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
   if stat[0] in ('Z','X') or pid==os.getpid():continue
   if str(R) in cmd or str(P/'runtime/run-setup03.py') in cmd:active.append({'pid':pid,'ppid':int(stat[1]),'start_ticks':int(stat[19]),'exe':os.readlink(d/'exe'),'argv_text':cmd,'cwd':os.readlink(d/'cwd')})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 assert not active,active
 out.update(success=True,outer_rc=0,persona_inventory_entries_verified=len(inv),selected_persona_files=len(SELECTED),source_bound_manifest=ADMITTED,operation_result_sha256=sha(R/'result.json'),native_ended=native['ended'],active_setup_processes=active,process_scope='current argv/recorded operation-root matches, not an exhaustive host ownership proof')
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('PERSONA_COMPLETION13',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
