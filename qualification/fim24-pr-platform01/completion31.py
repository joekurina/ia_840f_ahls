"""Capture completed export files only; never invoke vendor tools."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01');D=ROOT/'base01';R=ROOT/'export01';T=ROOT/'release01';P=ROOT/'prepared15';BUFFER='ia840f_fim24_pr_completion31_result'
result={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{},'native_processes':[],'missing_optional':[]}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert (R/'result.json').is_file(),'native supervisor result not yet available; do not rerun job'
 status=json.loads((R/'result.json').read_text());result['execution_clean']=status.get('execution_clean');result['manifest_sha256']=status.get('manifest_sha256')
 names=[(R/n,'operation/'+n) for n in ('status.json','result.json','authority.json','gate-events.jsonl','configure.log','version.log','export.log')]
 names.append((P/'export22-outer.log','operation/export22-outer.log'))
 boundary=['bin/afu_synth','bin/build_env_config','hw/lib/fme-ifc-id.txt','hw/lib/fme-platform-class.txt','hw/lib/platform/platform_db/ofs_agilex.ini','hw/lib/build/syn/board/ia840f/syn_top/ofs_top.qpf','hw/lib/build/syn/board/ia840f/syn_top/ofs_pr_afu.qsf','hw/lib/build/syn/board/ia840f/syn_top/ofs_pr_afu_sources.tcl','hw/lib/build/syn/board/ia840f/syn_top/fim_base_ip.tcl','hw/lib/build/syn/board/ia840f/syn_top/fim_project_macros.tcl','hw/lib/build/syn/board/ia840f/syn_top/afu_with_pim/afu.tcl','hw/lib/build/syn/board/ia840f/setup/build_gate_release01.tcl','hw/lib/build/syn/board/ia840f/setup/ia840f_release_gate01.py','hw/lib/build/platform/ofs_plat_if/rtl/ofs_plat_if_top_config.vh','hw/lib/build/platform/ofs_plat_if/par/ofs_plat_if_addenda.qsf']
 names += [(T/n,'release/'+n) for n in boundary]
 names += [(D/'syn/board/ia840f/syn_top'/n,'base-project/'+n) for n in ('ofs_top.qpf','ofs_pr_afu.qsf','fme-ifc-id.txt')]
 for base,label in [(D/'syn/board/ia840f/syn_top/output_files','base-reports'),(T/'hw/lib/build/syn/board/ia840f/syn_top/output_files','release-reports')]:
  if base.is_dir():
   report_paths=[p for p in base.iterdir() if p.is_file() and p.name.startswith('ofs_pr_afu') and p.suffix in ('.rpt','.summary')];assert len(report_paths)<=60
   names += [(p,label+'/'+p.name) for p in report_paths]
 assert len(names)==len({n for p,n in names});total=0
 for p,n in names:
  if not p.is_file():result['missing_optional'].append(n);continue
  before=p.stat();assert before.st_size<=32*1024**2,(n,before.st_size);b=p.read_bytes();after=p.stat();total+=len(b);assert total<=96*1024**2
  assert before.st_size==after.st_size==len(b) and before.st_mtime_ns==after.st_mtime_ns,n
  result['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode(),'mtime_ns':after.st_mtime_ns}
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe')
   if Path(exe).name in ('quartus_sh','quartus_syn','quartus_fit','quartus_sta','quartus_asm'):
    result['native_processes'].append({'pid':int(p.name),'exe':exe,'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 result.update(success=True,total_bytes=total,file_count=len(result['files']))
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_PR_COMPLETION31',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
