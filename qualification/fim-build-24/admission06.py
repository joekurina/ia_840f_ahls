"""Publish the reviewed admission program, check its extra binding, run once."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,sys,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';J=B/'work_ia840f_fim_24/syn/board/ia840f/syn_top'
BUFFER='ia840f_migration24_admission06_result'
PAYLOAD='e9d0ceb53557f67eaf1133845ec814cf0966287d02e0a6e871397cb529a99b08'
SCRIPT='564093c3435adb01373fdc7da77d9e79a363d91ae3460405f031d1231c414d2d'
INVENTORY='ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9'
MANIFEST='99820e60694b59639a5f542f0a8b70320015462a8d9d74c4a3fb103a6d2e480f'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
try:
    if sys.flags.optimize:raise RuntimeError('transport interpreter must be unoptimized')
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not (E/'admit04.py').exists() and not (E/'stage-inputs').exists() and not (E/'admission04').exists()
    prior=subprocess.run(['tmux','save-buffer','-b','ia840f_migration24_admission04_result','-'],capture_output=True)
    assert prior.returncode!=0,'prior admission buffer present; never replay'
    source=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration24_admission04_source','-'])
    assert hashlib.sha256(source).hexdigest()==SCRIPT
    payload_raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration24_admission04_inputs','-'])
    assert hashlib.sha256(payload_raw).hexdigest()==PAYLOAD
    payload=json.loads(gzip.decompress(payload_raw))
    inv=(E/'original-source-pim-inventory01.json').read_bytes();assert hashlib.sha256(inv).hexdigest()==INVENTORY and len(json.loads(inv))==1891
    R['source_inventory_preflight']={'sha256':INVENTORY,'entries':1891,'verified_before_admission':True}
    preserve={'/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf': {'bytes': 7185637, 'sha256': 'fa45c1573e35db501cf7dd932cb1cf3d9aee060b3185e4ea92355004330a7666'}, '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.rbf': {'bytes': 7233536, 'sha256': 'cef69a708e7449a1cfc1d6ad9f9d305f638e3ee571401f60d181e7a0696f93ca'}, '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23/syn/board/ia840f/syn_top/output_files/ofs_top.sof': {'bytes': 7843324, 'sha256': '6d149d05ec82587f4f61e0e78ba470d3058da0f1263b2d339ecaea7d61c374c9'}, '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23/syn/board/ia840f/syn_top/output_files/ofs_top.static.msf': {'bytes': 3281343, 'sha256': '54118b3bc212aa405761b85c5791185defe4e051af78009e39216d77fdb71b6b'}, '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23/syn/board/ia840f/syn_top/ofs_top.qdb': {'bytes': 78833359, 'sha256': '74aba905b4d6bb65fa0aedca2f0ed4353b17a3a8f6d4c77ab2ed0381e9540846'}}
    observed={}
    for path,expected in preserve.items():
        pth=Path(path);assert pth.is_file() and not pth.is_symlink()
        hh=hashlib.sha256()
        with pth.open('rb') as stream:
            for block in iter(lambda:stream.read(1048576),b''):hh.update(block)
        actual={'bytes':pth.stat().st_size,'sha256':hh.hexdigest()};assert actual==expected,path;observed[path]=actual
    R['predecessor_artifacts_live_preflight']=observed
    with (E/'admit04.py').open('xb') as f:f.write(source)
    assert (E/'admit04.py').read_bytes()==source
    env=dict(os.environ);env.pop('PYTHONOPTIMIZE',None)
    argv=['/usr/bin/python3','-I','-B',str(E/'admit04.py'),PAYLOAD]
    p=subprocess.run(argv,cwd=J,env=env,capture_output=True,text=True,timeout=150)
    R['command']={'argv':argv,'pythonoptimize_unset':True,'rc':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
    blob=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration24_admission04_result','-'])
    expected=subprocess.check_output(['tmux','save-buffer','-b','ia840f_migration24_admission04_result_sha256','-'],text=True).strip()
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
    print('MIGRATION24_ADMISSION06',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
