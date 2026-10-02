"""Inert issuance protocol fixtures; never contact remote/native tools."""
import base64,copy,hashlib,io,json,os,subprocess,tempfile,types,gzip
from pathlib import Path
from contextlib import redirect_stdout
from unittest.mock import patch
from typing import Any
E=Path(__file__).resolve().parent
S=E/'issue-admission12.py.in';OUT=E/'issuer-inert10b.json';assert not OUT.exists()
source=S.read_text();compile(source,str(S),'exec')
base=Path(tempfile.mkdtemp(prefix='persona-issuer-',dir=os.environ['TMPDIR']));rows=[]
h=lambda b:hashlib.sha256(b).hexdigest()
encode=lambda x:(json.dumps(x,sort_keys=True,indent=2)+'\n').encode()
def snapshot(root):return {str(p.relative_to(root)):h(p.read_bytes()) for p in root.rglob('*') if p.is_file()}
for mode in ('valid','changed_scope','changed_source','hardware_ready','bad_review','extra_file','existing_operation'):
 root=base/mode;P=root/'control03';A=P/'admission12';M=P/'setup-inputs.admitted.json';R=root/'setup01';P.mkdir(parents=True)
 runtime=P/'runtime';runtime.mkdir();runner=runtime/'run-setup03.py';runner.write_text('# INERT: never imported\n')
 draft={'parent_execution_accepted':False,'hardware_ready':False,'scope':'persona-file-setup-only','runner_sha256':h(runner.read_bytes()),'prerequisites':{},'staged_inventory':{'inert':{'sha256':'0'*64}},'cpus':[0],'address_space_limit_bytes':64*1024**3}
 db=encode(draft);(P/'setup-inputs.draft06.json').write_bytes(db)
 sr=b'INERT approved source review\n';qr=b'INERT approved quality review\n'
 sc={'accepted':True,'hardware_ready':False,'authority_issued':False,'draft_sha256':h(db),'review_sha256':h(sr)};scb=encode(sc)
 qc={'accepted':True,'hardware_ready':False,'draft_sha256':h(db),'review_sha256':h(qr),'spec_consumption_sha256':h(scb)};qcb=encode(qc)
 files={'review-setup08.md':sr,'spec-consumed09.json':scb,'review-quality11.md':qr,'quality-consumed12.json':qcb}
 target=copy.deepcopy(draft);target['parent_execution_accepted']=True
 for n,b in files.items():target['prerequisites'][str(A/'receipts'/n)]=h(b)
 target['execution_review']={'sha256':h(qr),'parent_consumption_sha256':h(qcb),'source_spec_review_sha256':h(sr),'scope':'persona-file-setup-only'}
 if mode=='changed_scope':target['scope']='not-approved'
 if mode=='changed_source':target['staged_inventory']['inert']['sha256']='1'*64
 if mode=='hardware_ready':target['hardware_ready']=True
 if mode=='bad_review':files['review-quality11.md']=b'INERT substituted review\n'
 if mode=='extra_file':files['extra.txt']=b'INERT\n'
 if mode=='existing_operation':R.mkdir()
 ab=encode(target);files['setup-inputs.admitted.json']=ab
 packet={'batch':'ia840f_fim24_caps03_persona_admission12_inputs','scope':'persona-file-setup-only','draft_sha256':h(db),'admitted_sha256':h(ab),'files':{n:{'bytes':len(b),'sha256':h(b),'base64':base64.b64encode(b).decode()} for n,b in files.items()}}
 raw=gzip.compress(encode(packet),mtime=0)
 code=source.replace('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01',str(root)).replace('UNISSUED_PACKET_DIGEST',h(raw)).replace('c67ecca4f10f69dccec23458a90a5a6af04d59f268c22fbf4931e0402b78d791',h(db)).replace('a0457610b1f37b63b2241c539ff993bc87b3eb70869ca65e49268ae9353fb74c',h(runner.read_bytes()))
 calls=[];preflight_calls=[]
 def capture(argv,**kw):
  calls.append(argv);assert argv[0]=='tmux'
  if argv[1]=='display-message':return 'ia840f_mailbox_monitored_01\n'
  assert argv[1:4]==['save-buffer','-b',packet['batch']];return raw
 def command(argv,**kw):calls.append(argv);assert argv[0]=='tmux';return subprocess.CompletedProcess(argv,0)
 def preflight(digest):
  preflight_calls.append(digest);assert digest==h(M.read_bytes())==h(ab) and not R.exists()
  return json.loads(M.read_text()),{'INERT_RELEASE':{}},{'INERT_FABRIC':{}}
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
