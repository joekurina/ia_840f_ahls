"""One approved SDK QSPI write with built-in readback; no activation/retry."""
import ast,base64,datetime,gzip,hashlib,json,os,re,resource,socket,subprocess,sys,time,traceback
from pathlib import Path
C={'target_result_sha256': 'bcbc8297c9da1ee659a487b99362507858b938521d9da744637d7d883233face', 'package_acceptance_sha256': '93c0bd941a332fd14b0e5e184bbb1b11565c059553c775e0d754193b481ea902', 'ownership_helper_sha256': '59d48b9f7c906e10e91d4becb0d1e1a446bf3ad51c230aa06e5c5cb4d6beee9f', 'sdk_sources': {'/home/uwb_student00/.local/bin/bw_agilex_flash_programmer': 'd07c0450ce5a4b6a30bcd8b5ecad8112071ea604b2b762b920e310d89f1b92ac', '/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/tools/bw_agilex_flash_programmer.py': 'd114deddc47bd4daf7d0dfa4ca012f5b6e24adb27535a39f3b1c2a86a4351c63', '/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/components/sdm_mailbox.py': 'f51ccfe1804709042dc8c221fbf8c7eca685355d7ff23e09a1a7dc3ab7c31084'}, 'daemon': {'argv': ['/usr/bin/bwvfiod_server', '-d'], 'comm': 'bwvfiod_server', 'cwd': '/', 'exe': '/usr/bin/bwvfiod_server', 'pid': 395200, 'start_ticks': '60597442', 'state': 'S'}, 'card': {'bdf': '0000:4f:00.1', 'device_id': '112', 'index': '0', 'slot_uid': '0000:4e:00.0/4f:00.1', 'vendor_id': '4794'}, 'boot_id': '8121620d-a638-42f8-abab-a547aae32076', 'rpd_bytes': 10670080, 'rpd_sha256': '96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e', 'writer_transformed_sha256': 'f7cc592f86182c792a5a8fdfc1347dfefd3299c538760a1d98e51fb50976772e', 'erase_footprint': {'bytes': 10682368, 'formula_basis': 'literal captured sdm_mailbox.py:207-209,631-678; no idealized ceil substitution', 'input_bytes': 10670080, 'last_byte': 10682367, 'padding_bytes': 12288, 'sdk_adjusted_numbytes': 10633216, 'sector_size': 65536, 'sectors': 163, 'start': 0}, 'recovery_rpd': '/home/uwb_student00/ahls/new_BSP/work_caps03_flash01/sdk-convert21/caps03-sdk.rpd', 'recovery_rpd_sha256': '0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf'}
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');W=ROOT/'sdk-program18';H=ROOT/'os11/ownership.py';RPD=ROOT/'convert05/migrated-caps03-sdk.rpd';BIN=Path('/home/uwb_student00/.local/bin');BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'one approved complete non-RSU SDK flash including built-in comparison; no BMC/reboot/retry','success':False,'programming_verified':False,'native_started':False,'hardware_access':False,'activation':False,'retry':False,'commands':[],'exports':{}};owned=False

def sha(path):
    h=hashlib.sha256()
    with Path(path).open('rb') as stream:
        for b in iter(lambda:stream.read(1048576),b''):h.update(b)
    return h.hexdigest()
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def persist():(W/'status.json').write_text(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n')
def env():return {'HOME':'/home/uwb_student00','USER':'uwb_student00','LOGNAME':'uwb_student00','PATH':str(BIN)+':/usr/bin:/bin','LANG':'C','PYTHONDONTWRITEBYTECODE':'1'}
def identity(pid):
    p=Path('/proc')/str(pid);f=(p/'stat').read_text().rsplit(')',1)[1].split()
    return {'pid':int(pid),'start_ticks':f[19],'state':f[0],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}
def run(label,argv,seconds):
    row={'label':label,'argv':argv,'started':now()};out['commands'].append(row);persist()
    with (W/(label+'.log')).open('xb') as log:
        p=subprocess.Popen(argv,cwd=W,env=env(),stdout=log,stderr=subprocess.STDOUT,start_new_session=True);row['pid']=p.pid;persist()
        try:row['native_rc']=p.wait(timeout=seconds)
        except subprocess.TimeoutExpired:row['execution_state']='UNKNOWN; no signal/retry/further hardware operation';persist();raise
    row['ended']=now();persist();b=(W/(label+'.log')).read_bytes();assert len(b)<=4*1024**2
    row['log_sha256']=hashlib.sha256(b).hexdigest();persist();assert row['native_rc']==0,(label,row['native_rc'])
    return b.decode(errors='replace')
def transport(row):
    a=row.get('argv',[])
    return ((row.get('exe')=='/usr/bin/bash' and len(a)==3 and a[:2]==['bash','-c'] and a[2].startswith('tmux save-buffer -b '+BATCH+'_source - | ')) or (row.get('exe')=='/usr/bin/tmux' and a==['tmux','wait-for',BATCH+'_done']))
def owner(label):
    assert sha(H)==C['ownership_helper_sha256'];s=json.loads(run(label,['sudo','-n','/usr/bin/python3','-I','-B',str(H)],60));out[label]=s;persist()
    assert s['boot_id']==C['boot_id'] and not s['d_state'] and not s['errors'];d=C['daemon']
    ds=[r for r in s['relevant_processes'] if r['pid']==d['pid']];assert len(ds)==1 and all(ds[0].get(k)==d[k] for k in ['pid','start_ticks','exe','cwd','argv'])
    assert not [r for r in s['relevant_processes'] if not transport(r) and r['pid']!=d['pid']]
    assert s['holders'] and all(r['pid']==d['pid'] and r['start_ticks']==d['start_ticks'] and r['target'] in ['/dev/vfio/vfio','/dev/vfio/5'] for r in s['holders'])
    assert all(r['pid']==d['pid'] and r['start_ticks']==d['start_ticks'] and ('/'+C['card']['bdf']+'/resource' in r['mapping'] or r['mapping'].split()[-1] in ['/dev/vfio/vfio','/dev/vfio/5']) for r in s['maps'])
    mg=[r for r in s['pci'] if r['bdf']==C['card']['bdf']];assert len(mg)==1 and mg[0]['vendor']=='0x12ba' and mg[0]['device']=='0x0070' and mg[0]['driver']=='/sys/bus/pci/drivers/vfio-pci' and mg[0]['group_members']==[C['card']['bdf']] and Path(mg[0]['iommu_group']).name=='5'
    return s
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not W.exists()
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(ROOT/'PACKAGE-ACCEPTANCE13.json')==C['package_acceptance_sha256'] and sha(ROOT/'sdk-target16/result.json')==C['target_result_sha256']
    t=json.loads((ROOT/'sdk-target16/result.json').read_text());assert t['success'] is True and t['card_identity']==C['card'] and t['daemon_identity']==C['daemon']
    assert all(sha(p)==h for p,h in C['sdk_sources'].items()) and RPD.stat().st_size==C['rpd_bytes'] and sha(RPD)==C['rpd_sha256']
    assert sha(C['recovery_rpd'])==C['recovery_rpd_sha256'] and Path('/proc/sys/kernel/random/boot_id').read_text().strip()==C['boot_id']
    cpus=sorted(os.sched_getaffinity(0));assert cpus==list(range(36))
    W.mkdir(exist_ok=False);owned=True;out.update(started=now(),boot_before=C['boot_id'],cpus=cpus,address_space_limit_bytes=64*1024**3,input_rpd_sha256=C['rpd_sha256'],writer_transformed_sha256=C['writer_transformed_sha256'],erase_footprint=C['erase_footprint'],recovery_rpd={'path':C['recovery_rpd'],'sha256':C['recovery_rpd_sha256'],'meaning':'retained accepted prior image, not a fresh device snapshot'},prewrite_device_backup=False,window_pane=subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{window_id} #{pane_id}'],text=True).strip());persist()
    owner('ownership-before-readiness')
    # Fresh readiness is adjacent to the write; earlier target16 identity is reused, not re-enumerated.
    out['hardware_access']=True;persist();status=run('fresh-config-status',[str(BIN/'bw_agilex_flash_programmer'),'-i','PCI','-c',C['card']['index'],'-s'],120)
    assert status.count('config_status:')==1;cfg=ast.literal_eval(status.split('config_status:',1)[1].strip());assert cfg['conf_done']==cfg['init_done']==cfg['nStatus']==1 and cfg['error_details']==cfg['error_location']==cfg['state']==0 and cfg['msel']=='ASx4 Normal'
    out['fresh_config_status']=cfg;persist();owner('ownership-immediate-prewrite')
    assert all(sha(p)==h for p,h in C['sdk_sources'].items()) and sha(RPD)==C['rpd_sha256']
    argv=[str(BIN/'bw_agilex_flash_programmer'),'-i','PCI','-c',C['card']['index'],'program','--force','-a','0x00000000',str(RPD)]
    row={'label':'program','argv':argv,'started':now(),'deadline_seconds':18000};out['commands'].append(row);persist()
    def limits():os.sched_setaffinity(0,set(cpus));resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    with (W/'program.log').open('xb') as log:
        child=subprocess.Popen(argv,cwd=W,env=env(),stdout=log,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limits)
        out['native_started']=True;row['pid']=child.pid
        # Bookkeeping failure does not signal or abandon an already-started writer.
        try:
            row['identity']=identity(child.pid)
            with (W/'native-process.json').open('x') as stream:json.dump(row,stream,indent=2);stream.flush();os.fsync(stream.fileno())
            persist()
        except Exception as exc:row['bookkeeping_error']=repr(exc)
        try:row['native_rc']=child.wait(timeout=18000)
        except subprocess.TimeoutExpired:
            row['execution_state']='UNKNOWN; preserve original owner; no kill/retry/reset/activation';persist();raise
        row['ended']=now()
        with (W/'native-result.json').open('x') as stream:json.dump(row,stream,indent=2);stream.flush();os.fsync(stream.fileno())
        persist()
    raw=(W/'program.log').read_bytes();assert len(raw)<=16*1024**2
    text=raw.decode(errors='replace');out['program_log']={'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest()}
    phases=dict(re.findall(r'(QSPI Erase|QSPI Program|QSPI Readback):[^\r\n]*?(\d+(?:\.\d+)?)% Complete',text))
    out['phase_progress']=phases;out['comparison_success']='Flash programmed successfully.' in text;persist()
    assert row['native_rc']==0 and out['comparison_success'] and 'Refusing' not in text and all(phases.get(p)=='100.0' for p in ['QSPI Erase','QSPI Program','QSPI Readback'])
    assert 'bookkeeping_error' not in row and all(sha(p)==h for p,h in C['sdk_sources'].items()) and sha(RPD)==C['rpd_sha256'] and Path('/proc/sys/kernel/random/boot_id').read_text().strip()==C['boot_id']
    owner('ownership-after-program');out.update(success=True,programming_verified=True,boot_after=C['boot_id'],activation=False,hardware_ready=False,deployment_ready=False)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    persist()
    with (W/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2);stream.write('\n')
    for p in sorted(W.glob('*.log'))+sorted(W.glob('native-*.json'))+[W/'result.json']:
        if not p.is_file():continue
        size=p.stat().st_size
        if size>16*1024**2:out.setdefault('capture_errors',[]).append({'path':str(p),'bytes':size,'sha256':sha(p)});continue
        b=p.read_bytes();out['exports'][p.name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'programming_verified':out['programming_verified'],'native_started':out['native_started']}),flush=True)
if not out['success']:raise SystemExit(1)
