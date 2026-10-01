"""Publish the reviewed admission program, check its extra binding, run once."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,sys,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-23';J=B/'work_ia840f_fim_23/syn/board/ia840f/syn_top'
BUFFER='ia840f_migration23_admission06_result'
PAYLOAD='a70d39a074ead7866e5ce9ee82b4dd8ac3c8c4ecccff6254a2fadfb1f2c49173'
SCRIPT='c8f1220e2d8f10e3c3e0dcdb3c902f9c47949e1d7b4b85406f5017f31f4b7a4f'
INVENTORY='ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9'
MANIFEST='cf64d5038defc09a405bac442ba290531b831d987258da801c3f9b4ee2077983'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
try:
    if sys.flags.optimize:raise RuntimeError('transport interpreter must be unoptimized')
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not (E/'admit04.py').exists() and not (E/'stage-inputs').exists() and not (E/'admission04').exists()
    prior=subprocess.run(['tmux','save-buffer','-b','ia840f_migration23_admission04_result','-'],capture_output=True)
    assert prior.returncode!=0,'prior admission buffer present; never replay'
    source=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration23_admission04_source','-'])
    assert hashlib.sha256(source).hexdigest()==SCRIPT
    payload_raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration23_admission04_inputs','-'])
    assert hashlib.sha256(payload_raw).hexdigest()==PAYLOAD
    payload=json.loads(gzip.decompress(payload_raw))
    inv=(E/'original-source-pim-inventory01.json').read_bytes();assert hashlib.sha256(inv).hexdigest()==INVENTORY and len(json.loads(inv))==1891
    R['source_inventory_preflight']={'sha256':INVENTORY,'entries':1891,'verified_before_admission':True}
    with (E/'admit04.py').open('xb') as f:f.write(source)
    assert (E/'admit04.py').read_bytes()==source
    env=dict(os.environ);env.pop('PYTHONOPTIMIZE',None)
    argv=['/usr/bin/python3','-I','-B',str(E/'admit04.py'),PAYLOAD]
    p=subprocess.run(argv,cwd=J,env=env,capture_output=True,text=True,timeout=150)
    R['command']={'argv':argv,'pythonoptimize_unset':True,'rc':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
    blob=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration23_admission04_result','-'])
    expected=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration23_admission04_result_sha256','-'],text=True).strip()
    assert hashlib.sha256(blob).hexdigest()==expected
    admission=json.loads(gzip.decompress(blob));R['admission']=admission;R['admission_capture_sha256']=expected
    assert p.returncode==0 and admission['success'] and admission['manifest_sha256']==MANIFEST
    for rel in ['stage-inputs/compile.json','review-spec02.md','spec-consumed03.json','review-quality04.md','quality-consumed05.json']:
        data=(E/rel).read_bytes();h=hashlib.sha256(data).hexdigest()
        assert h==(MANIFEST if rel=='stage-inputs/compile.json' else payload['files'][rel]['sha256'])
        R['files'][rel]={'bytes':len(data),'sha256':h,'base64':base64.b64encode(data).decode()}
    assert json.loads((E/'stage-inputs/compile.json').read_text())==payload['manifest']
    assert hashlib.sha256((E/'admit04.py').read_bytes()).hexdigest()==SCRIPT
    assert hashlib.sha256((E/'original-source-pim-inventory01.json').read_bytes()).hexdigest()==INVENTORY
    assert not (E/'operations').exists() and not (E/'native-operation.lock').exists()
    R['success']=True
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    data=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(data).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=data,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION23_ADMISSION06',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
