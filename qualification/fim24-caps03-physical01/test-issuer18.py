"""Inert issuance protocol fixtures; never contact remote/native tools."""
import base64,copy,hashlib,io,json,os,subprocess,tempfile,types,gzip
from pathlib import Path
from contextlib import redirect_stdout
from unittest.mock import patch
from typing import Any
E=Path(__file__).resolve().parent
S=E/'issue-admission18.py.in';OUT=E/'issuer-inert18.json';assert not OUT.exists()
source=S.read_text();compile(source,str(S),'exec')
base=Path(tempfile.mkdtemp(prefix='persona-issuer-',dir=os.environ['TMPDIR']));rows=[]
h=lambda b:hashlib.sha256(b).hexdigest()
encode=lambda x:(json.dumps(x,sort_keys=True,indent=2)+'\n').encode()
def snapshot(root):return {str(p.relative_to(root)):h(p.read_bytes()) for p in root.rglob('*') if p.is_file()}
for mode in ('valid','changed_scope','changed_source','hardware_ready','bad_review','extra_file','existing_operation'):
 root=base/mode;P=root/'control08';A=P/'admission18';M=P/'fit-inputs.admitted.json';R=root/'fit01';P.mkdir(parents=True)
 runtime=P/'runtime';runtime.mkdir();runner=runtime/'run-fit08.py';runner.write_text('# INERT: never imported\n')
 draft={'parent_execution_accepted':False,'hardware_ready':False,'ready_for_build':False,'scope':'persona-fit-only','runner_sha256':h(runner.read_bytes()),'prerequisites':{},'design_inventory':{'inert':{'sha256':'0'*64}},'cpus':[0],'address_space_limit_bytes':64*1024**3,'critical_inputs':{'INERT':{}},'external_inputs':{'INERT':{}},'archive_inventory':{'INERT':{}}}
 db=encode(draft);(P/'fit-inputs.draft14.json').write_bytes(db)
 sr=b'INERT approved source review\n';qr=b'INERT approved quality review\n'
 sc={'accepted':True,'hardware_ready':False,'authority_issued':False,'draft_sha256':h(db),'review_sha256':h(sr)};scb=encode(sc)
 qc={'accepted':True,'hardware_ready':False,'draft_sha256':h(db),'review_sha256':h(qr),'spec_consumption_sha256':h(scb)};qcb=encode(qc)
 files={'source-api-review07.md':sr,'prepared-source-proof15.json':scb,'review-quality17.md':qr,'quality-consumed18.json':qcb}
 target=copy.deepcopy(draft);target['parent_execution_accepted']=True
 for n,b in files.items():target['prerequisites'][str(A/'receipts'/n)]=h(b)
 target['execution_review']={'sha256':h(qr),'parent_consumption_sha256':h(qcb),'source_spec_review_sha256':h(sr),'scope':'persona-fit-only'}
 if mode=='changed_scope':target['scope']='not-approved'
 if mode=='changed_source':target['design_inventory']['inert']['sha256']='1'*64
 if mode=='hardware_ready':target['hardware_ready']=True
 if mode=='bad_review':files['review-quality17.md']=b'INERT substituted review\n'
 if mode=='extra_file':files['extra.txt']=b'INERT\n'
 if mode=='existing_operation':R.mkdir()
 ab=encode(target);files['fit-inputs.admitted.json']=ab
 packet={'batch':'ia840f_fim24_caps03_physical_admission18_inputs','scope':'persona-fit-only','draft_sha256':h(db),'admitted_sha256':h(ab),'files':{n:{'bytes':len(b),'sha256':h(b),'base64':base64.b64encode(b).decode()} for n,b in files.items()}}
 raw=gzip.compress(encode(packet),mtime=0)
 code=source.replace('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01',str(root)).replace('UNISSUED_PACKET_DIGEST',h(raw)).replace('8c875bbf6b43dadc22ebb6aa828a0c8b46d79c94bb6ef8e73b0a2a440688f4c0',h(db)).replace('83571ef6138cfcbbaa1789b6835e86697f38cabb588aaf657a6eccced0297eb5',h(runner.read_bytes()))
 calls=[];preflight_calls=[]
 def capture(argv,**kw):
  calls.append(argv);assert argv[0]=='tmux'
  if argv[1]=='display-message':return 'ia840f_mailbox_monitored_01\n'
  assert argv[1:4]==['save-buffer','-b',packet['batch']];return raw
 def command(argv,**kw):calls.append(argv);assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0)
 def preflight(digest):
  preflight_calls.append(digest);assert digest==h(M.read_bytes())==h(ab) and not R.exists()
  return json.loads(M.read_text())
 fake=types.SimpleNamespace(preflight=preflight);loader=types.SimpleNamespace(exec_module=lambda module:None);spec=types.SimpleNamespace(loader=loader)
 ns: dict[str,Any]={'__name__':'INERT_ISSUER','__file__':str(S)};before=snapshot(root)
 with patch('socket.gethostname',return_value='Agilex7Workstation'),patch('os.getuid',return_value=1000),patch.dict(os.environ,{'TMUX':'INERT','TMUX_PANE':'%INERT'}),patch('subprocess.check_output',side_effect=capture),patch('subprocess.run',side_effect=command),patch('importlib.util.spec_from_file_location',return_value=spec),patch('importlib.util.module_from_spec',return_value=fake),redirect_stdout(io.StringIO()):
  try:exec(compile(code,str(S),'exec'),ns)
  except SystemExit as exc:assert exc.code==1 and mode!='valid'
  result=ns['out'];assert result['success'] is (mode=='valid')
  if mode=='valid':
   assert len(preflight_calls)==1 and not R.exists() and M.read_bytes()==ab and result['manifest_readback']['sha256']==h(ab)
   frozen=snapshot(root);n=len(preflight_calls);ns2={'__name__':'INERT_REPLAY','__file__':str(S)}
   try:exec(compile(code,str(S),'exec'),ns2)
   except SystemExit as exc:assert exc.code==1
   else:raise AssertionError('replay accepted')
   assert snapshot(root)==frozen and len(preflight_calls)==n
  else:assert not A.exists() and not M.exists() and not preflight_calls and snapshot(root)==before
 rows.append({'case':mode,'success':result['success'],'admission_written':result['admission_written'],'native_tools_executed':False,'preflight_calls':len(preflight_calls),'rejection_or_replay_preserved':True})
OUT.write_text(json.dumps({'success':True,'template_sha256':h(S.read_bytes()),'scope':'issuer data/ownership protocol only; host/tmux/imported preflight/root and pinned fixture hashes substituted; no vendor or actual target execution','count':len(rows),'cases':rows,'scratch':str(base)},indent=2)+'\n');print(json.dumps({'success':True,'cases':len(rows),'output':str(OUT)}))
