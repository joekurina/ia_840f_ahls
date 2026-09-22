import pathlib,os,socket,subprocess,json,gzip,hashlib,base64,datetime
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{session_name}'],text=True).strip()=='ia840f_mailbox_monitored_01'
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic03')
BATCH='ia840f_emif_plan03_reports01'
assert json.loads((R/'native-result.json').read_text())['termination_confirmed']
OUT=R/'scratch/syn/board/ia840f/syn_top/output_files'
record={'batch':BATCH,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'inventory':{}}
total=0
for p in sorted(OUT.iterdir()):
 if not p.is_file() or p.is_symlink():continue
 if p.suffix not in ('.rpt','.summary','.log'):continue
 st=p.stat();record['inventory'][p.name]={'bytes':st.st_size,'mtime_ns':st.st_mtime_ns}
 if 'fit' not in p.name:continue
 assert st.st_size<=30000000
 total+=st.st_size;assert total<=40000000
 b=p.read_bytes();after=p.stat();assert (st.st_size,st.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
 record['files'][p.name]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
blob=gzip.compress(json.dumps(record,sort_keys=True).encode(),mtime=0)
assert len(blob)<10000000
with (R/'native-reports01.json.gz').open('xb') as f:f.write(blob)
subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
print('PLAN03_REPORTS01_COMPLETE',hashlib.sha256(blob).hexdigest(),len(record['files']),flush=True)
