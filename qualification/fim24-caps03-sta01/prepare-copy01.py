"""Prepare a fresh fitted copy for STA; no native timing or authority."""
import base64,copy,datetime,gzip,hashlib,json,os,shutil,socket,subprocess,traceback
from pathlib import Path
SOURCE=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01');S=SOURCE/'base01';SR=SOURCE/'fit01';SM=SOURCE/'control08/fit-inputs.admitted.json';ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01');D=ROOT/'base01';P=ROOT/'prepare01';J=D/'build/syn/board/ia840f/syn_top'
INPUT='ia840f_fim24_caps03_sta_copy01_inputs';BUFFER='ia840f_fim24_caps03_sta_copy01_result';EXPECTED='3eeff2711338b670f3d43eb84455729ea96a86c0a3f38ce4b973fc847c107680'
out={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_timing_executed':False,'hardware_access':False,'authority_issued':False,'ready_for_build':False,'exports':{}};owned=False
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
def inventory(root):
 result={};total=0
 for d,dirs,files in os.walk(root,followlinks=False):
  for name in dirs+files:
   p=Path(d)/name;n=str(p.relative_to(root))
   if p.is_symlink():
    x={'kind':'symlink','target':os.readlink(p),'resolved':str(p.resolve(strict=True))}
    if p.is_file():x['sha256_of_target']=sha(p)
   elif p.is_file():
    size=p.stat().st_size;total+=size;assert total<=8*1024**3;x={'kind':'file','bytes':size,'sha256':sha(p)}
   else:continue
   result[n]=x;assert len(result)<=20000
 return result,total
def save(p,b):
 p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('xb') as f:f.write(b)
def capture(p,name):
 b=p.read_bytes();assert len(b)<8*1024**2;out['exports'][name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert not ROOT.exists() and not ROOT.is_symlink()
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==EXPECTED;C=json.loads(gzip.decompress(raw));assert C['batch']==INPUT
 B=C['basis'];assert B['success'] and B['source_root']==str(S) and len(B['inventory'])==B['inventory_count']==4025
 assert sha(SM)==C['fit_admitted_sha256'] and sha(SR/'result.json')==B['native_result_sha256'];m=json.loads(SM.read_text());r=json.loads((SR/'result.json').read_text());assert r['execution_clean']
 assert inventory(S)==(B['inventory'],B['file_bytes']) and all(bind(Path('/'),{n:x}) for n,x in m['critical_inputs'].items())
 assert all(bind(Path('/'),{n:x}) for n,x in m['external_inputs'].items()) and bind(Path(m['source_root']),m['source_inventory']) and bind(Path(m['original_setup_root']),m['original_setup_inventory']) and bind(Path(m['release_root']),m['original_release_inventory']) and bind(Path(m['archive_root']),m['archive_inventory'])
 for n,x in list(m['tools'].items())+list(m['opae_tools'].items()):
  assert sha(n)==x['sha256']
  if 'real' in x:assert str(Path(n).resolve())==x['real']
 for n in ('setup','release','simulation','synthesis'):assert sha(m[n+'_result_file'])==m[n+'_result_sha256']
 assert sorted(os.sched_getaffinity(0))==list(range(36)) and shutil.disk_usage(SOURCE).free>B['file_bytes']*2+10_000_000_000
 active=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe')
   if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 assert not active,active
 decoded={}
 for n,x in C['acceptance'].items():
  b=base64.b64decode(x['base64'],validate=True);assert Path(n).name==n and len(b)==x['bytes'] and hashlib.sha256(b).hexdigest()==x['sha256'];decoded[n]=b
 assert json.loads(decoded['result-reviews-consumed37.json'])['accepted'] and not json.loads(decoded['result-reviews-consumed37.json'])['timing_accepted']
 assert json.loads(decoded['result-reviews-consumed37.json'])['raw_result_sha256']==B['native_result_sha256']
 ROOT.mkdir();P.mkdir();owned=True
 for n,b in decoded.items():save(P/'receipts'/n,b)
 shutil.copytree(S,D,symlinks=True);prepared=copy.deepcopy(B['inventory']);relocations=[]
 for n,x in prepared.items():
  if x['kind']=='symlink' and x['resolved'].startswith(str(S)+'/'):
   old=x['resolved'];x['resolved']=str(D)+old[len(str(S)):];relocations.append({'path':n,'target_unchanged':x['target'],'old_resolved':old,'new_resolved':x['resolved']})
 assert len(relocations)==2 and inventory(D)==(prepared,B['file_bytes']) and inventory(S)==(B['inventory'],B['file_bytes'])
 for n,x in r['qdb_outputs'].items():
  p=J/n;assert p.stat().st_size==x['bytes'] and sha(p)==x['sha256']
 assert len(r['qdb_outputs'])==729 and sha(J/'ofs_top.qdb')==m['static_qdb_sha256']
 assert all(bind(Path('/'),{n:x}) for n,x in m['external_inputs'].items()) and bind(Path(m['source_root']),m['source_inventory']) and bind(Path(m['original_setup_root']),m['original_setup_inventory']) and bind(Path(m['release_root']),m['original_release_inventory']) and bind(Path(m['archive_root']),m['archive_inventory'])
 assert sha(SR/'result.json')==B['native_result_sha256'] and sha(SM)==C['fit_admitted_sha256']
 metadata={'scope':'fresh copied final fit; old spent fitter gate remains, no timing/open/admission','source_root':str(S),'source_inventory':B['inventory'],'design_root':str(D),'project':str(J),'copied_inventory':prepared,'copied_file_bytes':B['file_bytes'],'relative_link_resolution_changes':relocations,'source_result_file':str(SR/'result.json'),'source_result_sha256':B['native_result_sha256'],'source_admitted_file':str(SM),'source_admitted_sha256':C['fit_admitted_sha256'],'physical_qdb_outputs':r['qdb_outputs'],'static_qdb_sha256':m['static_qdb_sha256'],'original_mapped_root':m['source_root'],'original_mapped_inventory':m['source_inventory'],'external_inputs':m['external_inputs'],'original_setup_root':m['original_setup_root'],'original_setup_inventory':m['original_setup_inventory'],'release_root':m['release_root'],'original_release_inventory':m['original_release_inventory'],'old_archive_root':m['archive_root'],'old_archive_inventory':m['archive_inventory'],'tools':m['tools'],'opae_tools':m['opae_tools'],'predecessor_results':{n:{'file':m[n+'_result_file'],'sha256':m[n+'_result_sha256']} for n in ('setup','release','simulation','synthesis')},'interface_uuid':m['interface_uuid'],'afu_uuid':m['afu_uuid'],'qpf_before':r['qpf_after'],'cpus':list(range(36)),'address_space_limit_bytes':64*1024**3,'ready_for_build':False,'hardware_ready':False,'authority_issued':False}
 save(P/'prepared-copy01.json',(json.dumps(metadata,sort_keys=True,indent=2)+'\n').encode());capture(P/'prepared-copy01.json','prepared-copy01.json')
 for n in ('ofs_pr_afu.qsf','ofs_top.qpf','ofs_top.out.sdc','build_env_db.txt','ofs_pr_afu_sources.tcl'):capture(J/n,'project/'+n)
 for n in ('user_clocks.sdc','user_clock_defs.tcl','user_clock_freqs_compute.tcl','ofs_sta_report_script_pr.tcl','report_timing.tcl'):capture(J/'ofs_partial_reconfig'/n,'project/ofs_partial_reconfig/'+n)
 out.update(success=True,copied_entries=len(prepared),copied_file_bytes=B['file_bytes'],physical_qdb_members=729,source_fit_preserved=True,original_mapped_preserved=True,external_setup_release_archive_preserved=True,static_qdb_preserved=True,relative_link_resolution_changes=relocations,prepared_metadata_sha256=sha(P/'prepared-copy01.json'),old_fit_gate_still_selected=True)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 if owned:save(P/'preparation01.json',(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n').encode())
 raw=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('STA_COPY01',out['success'],h,flush=True)
if not out['success']:raise SystemExit(1)
