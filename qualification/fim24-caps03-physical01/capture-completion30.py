"""Capture completed first-fit files and preservation; no native calls."""
import base64,datetime,gzip,hashlib,json,os,re,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01');D=ROOT/'base01';P=ROOT/'control08';R=ROOT/'fit01';J=D/'build/syn/board/ia840f/syn_top';O=P/'capture30'
BUFFER='ia840f_fim24_caps03_physical_completion30_result';EXPECTED='08acc24c47633076b5abdd0f53de34355d053d6b5f66d6517f7c7076627fa4af'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_launched':False,'hardware_access':False,'native_acceptance':False,'exports':{},'missing':[],'errors':[]};owned=False;total=0
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return h.hexdigest()
def bind(root,inv):
 for n,m in inv.items():
  p=root/n
  if m.get('kind')=='symlink':
   assert p.is_symlink() and os.readlink(p)==m['target'],n
   if 'resolved' in m:assert str(p.resolve(strict=True))==m['resolved'],n
   if 'sha256_of_target' in m:assert sha(p)==m['sha256_of_target'],n
  else:assert p.is_file() and not p.is_symlink() and p.stat().st_size==m['bytes'] and sha(p)==m['sha256'],n
 return True
def capture(p,name,required=True):
 global total
 if not p.exists():
  out['missing'].append({'path':str(p),'name':name,'required':required});return
 try:
  size=p.stat().st_size;item={'source':str(p),'bytes':size,'sha256':sha(p),'symlink':os.readlink(p) if p.is_symlink() else None,'resolved':str(p.resolve(strict=True))}
  if size>128*1024**2 or total+size>384*1024**2:
   item['body_omitted']='finite capture bound';out['errors'].append({'path':str(p),'error':'finite capture bound'});out['exports'][name]=item;return
  b=p.read_bytes();assert len(b)==size and hashlib.sha256(b).hexdigest()==item['sha256'];item['base64']=base64.b64encode(b).decode();total+=size;out['exports'][name]=item
 except BaseException as exc:out['errors'].append({'path':str(p),'error':repr(exc)})
def check(label,fn):
 try:out['preservation'][label]=bool(fn())
 except BaseException as exc:out['preservation'][label]=False;out['errors'].append({'preservation':label,'error':repr(exc)})
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert sha(P/'fit-inputs.admitted.json')==EXPECTED and (R/'result.json').is_file()
 outer=int(subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim24_caps03_physical_fit19_rc','-'],text=True).strip())
 m=json.loads((P/'fit-inputs.admitted.json').read_text());result=json.loads((R/'result.json').read_text());assert result['manifest_sha256']==EXPECTED and result['batch']=='ia840f_fim24_caps03_physical_fit01_result'
 O.mkdir();owned=True;out.update(outer_rc=outer,native_result_sha256=sha(R/'result.json'),native_execution_clean=result['execution_clean'],native_result=result)
 assert json.loads((R/'status.json').read_text())==result
 for n in ('result.json','status.json','authority.json','configure.log','version.log','fitting.log','gate-events.jsonl','gate-rejections.jsonl'):capture(R/n,'operation/'+n,n!='gate-rejections.jsonl')
 for n in ('fit-inputs.admitted.json','prepared-inputs14.json','runtime/run-fit08.py','runtime/CMakeLists.txt'):capture(P/n,'control/'+n)
 for n in m['required_reports']:capture(J/n,'reports/'+Path(n).name)
 out['report_inventory']={}
 for p in sorted((J/'output_files').iterdir()):
  if p.is_file() and p.name.startswith('ofs_pr_afu.') and p.suffix in ('.rpt','.summary','.smsg','.qmsg'):
   out['report_inventory'][p.name]={'bytes':p.stat().st_size,'sha256':sha(p)}
 out['reused_report_metadata']={}
 for name,item in out['report_inventory'].items():
  rel='build/syn/board/ia840f/syn_top/output_files/'+name
  if 'output_files/'+name in m['required_reports']:continue
  before=m['design_inventory'].get(rel)
  if before and before.get('sha256')==item['sha256'] and before.get('bytes')==item['bytes']:
   out['reused_report_metadata'][name]={'source':str(J/'output_files'/name),'bytes':item['bytes'],'sha256':item['sha256'],'basis':'byte-identical copied report already bound to accepted mapped result; not a newly generated physical report'}
  else:capture(J/'output_files'/name,'reports/'+name,False)
 names={'ofs_pr_afu.qsf','ofs_top.qpf','build_env_db.txt','ofs_pr_afu_sources.tcl','afu_main.tcl','afu.tcl','afu.qsf','afu_json_info.vh','ia840f_ahls_memory.json','ofs_plat_if_addenda.qsf','platform_if_addenda.qsf'}
 for n in m['design_inventory']:
  if Path(n).name in names:capture(D/n,'design/'+n)
 for n in ('ia840f_physical_gate08.py','build_gate_physical08.tcl'):capture(D/'build/syn/board/ia840f/setup'/n,'design/build/syn/board/ia840f/setup/'+n)
 capture(Path(m['release_root'])/'hw/lib/fme-ifc-id.txt','release/fme-ifc-id.txt')
 selected=re.findall(r'^set_global_assignment -name (SYSTEMVERILOG_FILE|QIP_FILE) "([^"\n]+)"$',(D/'hw/afu.qsf').read_text(),re.M);assert len(selected)==18 and sum(k=='SYSTEMVERILOG_FILE' for k,n in selected)==16
 out['selected_external_assignments']=[]
 for index,(kind,n) in enumerate(selected):
  assert n in m['external_inputs'];entry={'kind':kind,'path':n,'binding':m['external_inputs'][n],'capture':'external/'+str(index).zfill(2)+'-'+Path(n).name};out['selected_external_assignments'].append(entry);capture(Path(n),entry['capture'])
 for n,item in result.get('reports',{}).items():
  actual=out['exports'].get('reports/'+Path(n).name);assert actual and actual['sha256']==item['sha256'] and actual['bytes']==item['bytes'],n
 for n,item in result.get('logs',{}).items():
  actual=out['exports'].get('operation/'+n);assert actual and actual['sha256']==item['sha256'] and actual['bytes']==item['bytes'],n
 out['preservation']={}
 check('critical_inputs',lambda:all(bind(Path('/'),{n:x}) for n,x in m['critical_inputs'].items()))
 check('original_mapped',lambda:bind(Path(m['source_root']),m['source_inventory']))
 check('mapped_snapshots',lambda:all(bind(Path('/'),{n:x}) for n,x in m['protected_snapshot_inputs'].items()))
 observed_source=set()
 for d,dirs,files in os.walk(Path(m['source_root']),followlinks=False):
  for name in dirs+files:
   p=Path(d)/name
   if p.is_symlink() or p.is_file():observed_source.add(str(p.relative_to(m['source_root'])))
 out['original_source_added_entries']=sorted(observed_source-set(m['source_inventory']));out['original_source_missing_entries']=sorted(set(m['source_inventory'])-observed_source)
 check('original_mapped_entry_set',lambda:observed_source==set(m['source_inventory']))
 check('external_inputs',lambda:all(bind(Path('/'),{n:x}) for n,x in m['external_inputs'].items()))
 check('dni_archive',lambda:bind(Path(m['archive_root']),m['archive_inventory']))
 check('original_setup',lambda:bind(Path(m['original_setup_root']),m['original_setup_inventory']))
 check('original_release',lambda:bind(Path(m['release_root']),m['original_release_inventory']))
 check('controls',lambda:sha(m['runner_path'])==m['runner_sha256'] and sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256'] and all(sha(n)==h for n,h in m['prerequisites'].items()))
 check('tools',lambda:all(sha(n)==x['sha256'] and ('real' not in x or str(Path(n).resolve())==x['real']) and ('bytes' not in x or Path(n).stat().st_size==x['bytes']) for n,x in list(m['tools'].items())+list(m['opae_tools'].items())))
 check('predecessor_results',lambda:all(sha(m[n+'_result_file'])==m[n+'_result_sha256'] for n in ('setup','release','simulation','synthesis')))
 check('qdb_outputs',lambda:all((J/n).stat().st_size==x['bytes'] and sha(J/n)==x['sha256'] for n,x in result.get('qdb_outputs',{}).items()))
 check('static_qdb',lambda:sha(J/'ofs_top.qdb')==m['static_qdb_sha256'])
 out['processes']=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit() or int(p.name)==os.getpid():continue
  try:
   exe=os.readlink(p/'exe');cwd=os.readlink(p/'cwd');cmd=(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0))
   if Path(exe).name not in ('quartus_fit','quartus_sta','quartus_syn','cmake','make','gmake','python3','python3.9','python3.11'):continue
   if str(ROOT) not in cwd and not any(str(ROOT) in a for a in cmd):continue
   s=(p/'stat').read_text().rsplit(') ',1)[1].split();out['processes'].append({'pid':int(p.name),'ppid':int(s[1]),'state':s[0],'start_ticks':s[19],'exe':exe,'cwd':cwd,'argv':cmd})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 out['capture_bytes']=total;out['success']=not out['errors'] and not any(x['required'] for x in out['missing'])
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:
  with (O/'capture30.json').open('x') as f:json.dump({k:v for k,v in out.items() if k!='exports'},f,indent=2)
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('FIT_COMPLETION30',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
