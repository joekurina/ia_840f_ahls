"""Offline source-route GBS packaging; exact accepted assembly required first."""
import base64,copy,datetime,gzip,hashlib,json,os,re,resource,shutil,signal,struct,subprocess,sys,time,traceback
from pathlib import Path
C={'afu_json_binding': {'bytes': 391, 'sha256': '4391d1756d904ab7fc9125c9cd5dac923f470130223ea21d625081414547bbab'}, 'afu_json_path': '/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources/ia840f_ahls_memory.json', 'afu_uuid': 'd48dde9f-f551-578d-8bb0-69483ac95ec6', 'gen_gbs_path': '/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top/ofs_partial_reconfig/gen_gbs.tcl', 'gen_gbs_sha256': 'b012ad8ae74a5cf79b8d50716a780cff807a320a1ae4dfec653e2469e020e21b', 'hardware_ready': False, 'interface_uuid': 'fc603c44-5c8f-5e94-bcbe-a5780030947c', 'metadata_deltas': ['afu-image/interface-uuid inserted', 'auto-100->100,auto-200->200 MHz in package only', 'afu-image/magic-no default 0x1d1f8680'], 'ready_for_build': False, 'scope': 'source-qualified offline GBS packaging inputs; current assembly must be independently accepted first', 'source_basis_file': 'packaging-basis06.md', 'source_basis_sha256': '414ab7ce74ebc99001efd45da401fc5eda818d1f535b24aebff324869b93ba3e', 'tool_bindings': {'/usr/bin/packager': {'bytes': 224, 'real': '/usr/bin/packager', 'sha256': '3a3e8a5d1747f8f0c7bc6b7663452032b9b6ceaf1477e247c5e6a1c3a940be00'}, '/usr/lib/python3.9/site-packages/packager/__init__.py': {'bytes': 1630, 'real': '/usr/lib/python3.9/site-packages/packager/__init__.py', 'sha256': '7a3d040c65a5c2f991cf56df3d488e071e67d6ed41c28cf44a8d06a8f0c2e3d8'}, '/usr/lib/python3.9/site-packages/packager/metadata/__init__.py': {'bytes': 1628, 'real': '/usr/lib/python3.9/site-packages/packager/metadata/__init__.py', 'sha256': '68f00540818eed63dfecd69b39e96d0c2c906c270d3af89c13e0c571243d1342'}, '/usr/lib/python3.9/site-packages/packager/metadata/constants.py': {'bytes': 1880, 'real': '/usr/lib/python3.9/site-packages/packager/metadata/constants.py', 'sha256': '771c9e49add2b6c6c86939c7b3fe3fc569d0ebbbb2ca998c530d526932309621'}, '/usr/lib/python3.9/site-packages/packager/metadata/metadata.py': {'bytes': 2168, 'real': '/usr/lib/python3.9/site-packages/packager/metadata/metadata.py', 'sha256': 'ae983d64f25a61fa6e88d4d8e15e9af7e1b72a4efcebe2155115e79304a3b5ac'}, '/usr/lib/python3.9/site-packages/packager/schema/__init__.py': {'bytes': 1726, 'real': '/usr/lib/python3.9/site-packages/packager/schema/__init__.py', 'sha256': '334d3624587f945973f716c6e9d9454cfe3da6f77568a4c3c95db215442c116e'}, '/usr/lib/python3.9/site-packages/packager/schema/afu_schema_v01.json': {'bytes': 1683, 'real': '/usr/lib/python3.9/site-packages/packager/schema/afu_schema_v01.json', 'sha256': '5db974b9c2ad67ebc308ebeb39ab086adebda31f75721ec55360b96d9d608eb7'}, '/usr/lib/python3.9/site-packages/packager/schema/afu_template.json': {'bytes': 378, 'real': '/usr/lib/python3.9/site-packages/packager/schema/afu_template.json', 'sha256': 'be50d80f52912f7c52d973577e296fae132db098e832ae6c71c837a74b08af3b'}, '/usr/lib/python3.9/site-packages/packager/tools/__init__.py': {'bytes': 1630, 'real': '/usr/lib/python3.9/site-packages/packager/tools/__init__.py', 'sha256': '7a3d040c65a5c2f991cf56df3d488e071e67d6ed41c28cf44a8d06a8f0c2e3d8'}, '/usr/lib/python3.9/site-packages/packager/tools/afu_json_mgr.py': {'bytes': 9953, 'real': '/usr/lib/python3.9/site-packages/packager/tools/afu_json_mgr.py', 'sha256': '0f70f3aa6c530576e5d5960d544f7bb7e3bee8b1bb93f1433ab175fe4f53d6d1'}, '/usr/lib/python3.9/site-packages/packager/tools/packager.py': {'bytes': 8967, 'real': '/usr/lib/python3.9/site-packages/packager/tools/packager.py', 'sha256': 'f8c1ee77c4bccbca2d9191fc05d39061807435c8fb5c653383d1ad355e564a49'}, '/usr/lib/python3.9/site-packages/packager/utils/__init__.py': {'bytes': 1630, 'real': '/usr/lib/python3.9/site-packages/packager/utils/__init__.py', 'sha256': '7a3d040c65a5c2f991cf56df3d488e071e67d6ed41c28cf44a8d06a8f0c2e3d8'}, '/usr/lib/python3.9/site-packages/packager/utils/afu.py': {'bytes': 8940, 'real': '/usr/lib/python3.9/site-packages/packager/utils/afu.py', 'sha256': '34451ebfac5892e73798b7005d94ef9de9320971189feccefdfcf697dc97ecc5'}, '/usr/lib/python3.9/site-packages/packager/utils/gbs.py': {'bytes': 5367, 'real': '/usr/lib/python3.9/site-packages/packager/utils/gbs.py', 'sha256': '20621b57f106c40aaea5e5f0c3609c1eb2bf9236769f62f51d2ce34106b362da'}, '/usr/lib/python3.9/site-packages/packager/utils/utils.py': {'bytes': 2443, 'real': '/usr/lib/python3.9/site-packages/packager/utils/utils.py', 'sha256': '2d4876fea3593ec5eb14a90c9dbc05c72be3955a5ac2cf8f2516b0a258459f31'}, '/usr/bin/python3': {'bytes': 15448, 'real': '/usr/bin/python3.9', 'sha256': '7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2'}}, 'user_clock_binding': {'bytes': 133, 'kind': 'file', 'sha256': 'f5ed24d88af0253192249260b91cf463d7fbdfe382e695a7d2a2c6030e2c3c71'}, 'user_clock_file': 'output_files/user_clock_freq.txt', 'assembly_result_sha256': 'd8a03af543af01c422af7adac8fdc50a709fa8df4a9e6e68d058157f93760f1c'}
ACCEPTED_SHA='bea9ed759d12c101276635788ae34140b6a00f5d810f937d8ac666c174f5ed2c'
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');D=ROOT/'base01';J=D/'build/syn/board/ia840f/syn_top';G=ROOT/'gbs01';BATCH=sys.argv[1]
A=ROOT/'assembly-acceptance28.json'
out={'batch':BATCH,'scope':'offline packager equivalent of selected gen_gbs route; no project opening/Quartus/hardware','success':False,'hardware_access':False,'hardware_ready':False,'exports':{},'commands':[]};owned=False

def sha(path):
    h=hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda:stream.read(1048576),b''):h.update(block)
    return h.hexdigest()

def inventory(root):
    entries={};total=0
    for directory,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(directory)/name
            if p.is_symlink():
                entry={'kind':'symlink','target':os.readlink(p),'resolved':str(p.resolve(strict=True))}
                if p.is_file():entry['target_sha256']=sha(p)
            elif p.is_file():
                size=p.stat().st_size;total+=size;assert total<=2*1024**3
                entry={'kind':'file','bytes':size,'sha256':sha(p)}
            else:continue
            entries[str(p.relative_to(root))]=entry;assert len(entries)<=6000
    return entries

def group(gid):
    found=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            f=(p/'stat').read_text().rsplit(')',1)[1].split()
            if int(f[2])==gid and f[0]!='Z':found.append(int(p.name))
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    return found

def tools():
    for name,v in C['tool_bindings'].items():
        assert sha(name)==v['sha256'],name
        if 'bytes' in v:assert Path(name).stat().st_size==v['bytes'],name
        if 'real' in v:assert str(Path(name).resolve())==v['real'],name

def persist():
    (G/'status.json').write_text(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n')

def native(label,argv):
    row={'label':label,'argv':argv,'cwd':str(G),'started':datetime.datetime.now(datetime.timezone.utc).isoformat()};out['commands'].append(row);persist();child=None;expired=False
    env={'HOME':str(G/'home'),'PATH':'/usr/bin:/bin','LANG':'C','PYTHONDONTWRITEBYTECODE':'1','TMPDIR':str(G/'tmp')}
    def limits():resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    logfile=G/(label+'.log')
    with logfile.open('xb') as stream:
        try:
            child=subprocess.Popen(argv,cwd=G,env=env,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limits)
            row['pid']=child.pid;persist();deadline=time.monotonic()+60
            while os.waitid(os.P_PID,child.pid,os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
                assert logfile.stat().st_size<=2*1024**2
                if time.monotonic()>=deadline:expired=True;break
                time.sleep(.1)
            remaining=group(child.pid)
            while remaining and not expired and time.monotonic()<deadline:
                assert logfile.stat().st_size<=2*1024**2;time.sleep(.1);remaining=group(child.pid)
            if remaining:expired=True
        finally:
            if child is not None:
                if group(child.pid):
                    os.killpg(child.pid,signal.SIGTERM);end=time.monotonic()+3
                    while group(child.pid) and time.monotonic()<end:time.sleep(.1)
                    if group(child.pid):os.killpg(child.pid,signal.SIGKILL)
                row.update(native_rc=child.wait(),timeout=expired,ended=datetime.datetime.now(datetime.timezone.utc).isoformat());persist()
                row['owned_group_live_after']=group(child.pid);persist()
    assert row['native_rc']==0 and not expired and not row['owned_group_live_after'] and logfile.stat().st_size<=2*1024**2
    assert not re.search(r'\b(?:ERROR|FATAL)\s*:',logfile.read_text(),re.I)

try:
    assert __debug__ and os.environ.get('TMUX') and re.fullmatch(r'[0-9a-f]{64}',ACCEPTED_SHA)
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(A)==ACCEPTED_SHA;accept=json.loads(A.read_text());assert accept['accepted'] is True and accept['scope']=='assembly-only actual-result acceptance'
    assert accept['result_json_sha256']==C['assembly_result_sha256']==sha(ROOT/'asm01/result.json') and not G.exists()
    result=json.loads((ROOT/'asm01/result.json').read_text());assert result['execution_clean'] is True and accept['images']==result['programming_images']
    for n,v in accept['images'].items():assert (J/n).stat().st_size==v['bytes'] and sha(J/n)==v['sha256']
    source=Path(C['afu_json_path']);assert source.stat().st_size==C['afu_json_binding']['bytes'] and sha(source)==C['afu_json_binding']['sha256']
    assert sha(J/C['user_clock_file'])==C['user_clock_binding']['sha256'] and sha(C['gen_gbs_path'])==C['gen_gbs_sha256'];tools()
    original_json=json.loads(source.read_text());assert original_json['afu-image']['accelerator-clusters'][0]['accelerator-type-uuid']==C['afu_uuid']
    tokens=' '.join(x for x in (J/C['user_clock_file']).read_text().splitlines() if not x.startswith('#')).split()
    assert tokens==['afu-image/clock-frequency-low:100','afu-image/clock-frequency-high:200']
    before=inventory(D)
    G.mkdir(exist_ok=False);owned=True
    for n in ['home','tmp']:(G/n).mkdir()
    (G/'before-design-inventory.json').write_text(json.dumps(before,sort_keys=True,indent=2)+'\n')
    (G/'afu.json').write_bytes(source.read_bytes());shutil.copyfile(J/'output_files/ofs_pr_afu.green_region.rbf',G/'persona.rbf')
    assert sha(G/'afu.json')==sha(source) and sha(G/'persona.rbf')==accept['images']['output_files/ofs_pr_afu.green_region.rbf']['sha256']
    gbs=G/'ofs_pr_afu.green_region.gbs'
    native('create',['/usr/bin/packager','create-gbs','--gbs='+str(gbs),'--afu-json='+str(G/'afu.json'),'--rbf='+str(G/'persona.rbf'),'--set-value','interface-uuid:'+C['interface_uuid']]+tokens)
    native('info',['/usr/bin/packager','gbs-info','--gbs='+str(gbs)])
    native('extract',['/usr/bin/packager','get-rbf','--gbs='+str(gbs),'--rbf='+str(G/'extracted.rbf')])
    raw=gbs.read_bytes();assert 20<len(raw)<64*1024**2 and raw[:16]==b'XeonFPGA\xb7GBSv001'
    length=struct.unpack('<I',raw[16:20])[0];assert 0<length<=1024**2 and 20+length<len(raw)
    metadata=json.loads(raw[20:20+length]);expected=copy.deepcopy(original_json)
    expected['afu-image'].update({'interface-uuid':C['interface_uuid'],'clock-frequency-low':100,'clock-frequency-high':200,'magic-no':0x1d1f8680})
    assert metadata==expected==json.loads((G/'info.log').read_text())
    payload=raw[20+length:];original=(J/'output_files/ofs_pr_afu.green_region.rbf').read_bytes()
    assert payload==original==(G/'persona.rbf').read_bytes()==(G/'extracted.rbf').read_bytes()
    assert inventory(D)==before and sha(A)==ACCEPTED_SHA and sha(source)==C['afu_json_binding']['sha256'];tools()
    assert sha(J/C['user_clock_file'])==C['user_clock_binding']['sha256'] and sha(C['gen_gbs_path'])==C['gen_gbs_sha256'] and sha(ROOT/'asm01/result.json')==C['assembly_result_sha256']
    out.update(success=True,metadata=metadata,serialized_metadata_bytes=length,payload_bytes=len(payload),payload_sha256=hashlib.sha256(payload).hexdigest(),byte_for_byte_payload_equal=True,design_preserved=True,source_json_preserved=True,tools_preserved=True,assembly_result_preserved=True,assembly_acceptance_sha256=ACCEPTED_SHA,gbs={'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()},ready_for_build=False,deployment_ready=False)
    for name in ['create.log','info.log','extract.log','afu.json','ofs_pr_afu.green_region.gbs']:
        p=G/name;data=p.read_bytes();assert len(data)<=16*1024**2
        out['exports'][name]={'source':str(p),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    persist()
    with (G/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2);stream.write('\n')
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'hardware_access':False}),flush=True)
if not out['success']:raise SystemExit(1)
