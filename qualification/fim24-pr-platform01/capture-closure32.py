import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01');D=ROOT/'base01';T=ROOT/'release01';W=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24');R=ROOT/'export01';BUFFER='ia840f_fim24_pr_closure32_result'
result={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 raw=(R/'result.json').read_bytes();assert hashlib.sha256(raw).hexdigest()=='4debead014384dd31b3dda0c072cf2836bf9f7298360e7f39d04fa88dc7d886e';native=json.loads(raw)
 todo=[]
 for n,m in native['prepared_existing_delta_after_native'].items():
  assert n in ('syn/board/ia840f/syn_top/dni/checkpoints/manifest.txt','syn/board/ia840f/syn_top/dni/sandboxes/.properties.folder.kvp')
  todo.extend([(W/n,'dni-before/'+n,m['before']),(D/n,'dni-after/'+n,m['after'])])
 selected={n:m for n,m in native['release_inventory'].items() if n.startswith('hw/lib/build/platform/ofs_plat_if/') or n.endswith('.qip')}
 assert len(selected)==305
 for n,m in selected.items():assert m['kind']=='file';todo.append((T/n,'release/'+n,m))
 total=0
 for p,n,m in todo:
  stat=p.stat();assert stat.st_size==m['bytes'] and stat.st_size<2*1024**2;b=p.read_bytes();end=p.stat();assert len(b)==m['bytes'] and hashlib.sha256(b).hexdigest()==m['sha256'] and stat.st_mtime_ns==end.st_mtime_ns
  total+=len(b);assert total<16*1024**2
  result['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 result.update(success=True,file_count=len(todo),release_members=len(selected),total_bytes=total)
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_PR_CLOSURE32',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
