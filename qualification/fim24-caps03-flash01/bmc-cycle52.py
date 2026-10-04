"""One established USB BMC Off/On with separate readbacks; no reboot here."""
import base64,datetime,gzip,hashlib,json,os,re,socket,subprocess,sys,time,traceback
from pathlib import Path
C={'quiescence_sha256': '35e71c63dfe8622e386132f3d8d749d974bdb2eae72d64bd05daca2111b84936', 'pre43_sha256': '0fe6e7849705d50cb7050ea4cb0ba9d407d3324aeef1b6829108a0a73bb295ff'}
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');P=ROOT/'activation-pre43';W=ROOT/'bmc-cycle52';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'one approved BMC Off/readback then On/readback after verified card quiescence','success':False,'hardware_access':False,'power_change':False,'reboot':False,'flash_writes':False,'commands':[],'exports':{}};owned=False
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def persist():(W/'status.json').write_text(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n')
def durable(n,d):
    with (W/n).open('x') as stream:json.dump(d,stream,indent=2);stream.flush();os.fsync(stream.fileno())
def run(label,argv):
    row={'label':label,'argv':argv,'started':now()};out['commands'].append(row);persist()
    with (W/(label+'.log')).open('xb') as log:
        child=subprocess.Popen(argv,cwd=W,stdout=log,stderr=subprocess.STDOUT,start_new_session=True);row['pid']=child.pid;persist()
        try:row['native_rc']=child.wait(timeout=60)
        except subprocess.TimeoutExpired:row['execution_state']='UNKNOWN; no signal/retry/further power/hardware operation';persist();raise
    row['ended']=now();persist();b=(W/(label+'.log')).read_bytes();assert len(b)<=4*1024**2;row['log_sha256']=hashlib.sha256(b).hexdigest();persist();assert row['native_rc']==0,(label,row['native_rc']);return b.decode(errors='replace')
def transport(r):
    a=r.get('argv',[]);return ((r.get('exe')=='/usr/bin/bash' and len(a)==3 and a[:2]==['bash','-c'] and a[2].startswith('tmux save-buffer -b '+BATCH+'_source - | ')) or (r.get('exe')=='/usr/bin/tmux' and a==['tmux','wait-for',BATCH+'_done']))
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not W.exists()
    assert sha(ROOT/'quiesce51/result.json')==C['quiescence_sha256'] and sha(P/'result.json')==C['pre43_sha256']
    q=json.loads((ROOT/'quiesce51/result.json').read_text());pre=json.loads((P/'result.json').read_text());assert q['success'] is True and q['root_preserved'] is True and q['VF_cascade_verified'] is True
    boot=Path('/proc/sys/kernel/random/boot_id').read_text().strip();assert boot==q['boot']==pre['boot']
    for path,h in pre['source_bindings'].items():assert sha(path)==h,path
    parent=Path('/sys/bus/pci/devices/0000:4e:00.0');assert parent.exists();root=parent.resolve(strict=True)
    assert not [p for p in Path('/sys/bus/pci/devices').iterdir() if root in p.resolve().parents]
    z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(P/'runtime/ownership27.py')],capture_output=True,timeout=60);assert z.returncode==0;snap=json.loads(z.stdout)
    assert snap['boot_id']==boot and not any(snap[k] for k in ['d_state','holders','maps','errors']) and not [r for r in snap['relevant_processes'] if not transport(r)]
    usb=Path('/sys/bus/usb/devices/1-3.4');assert [(usb/n).read_text().strip() for n in ['idVendor','idProduct','serial']]==['2528','0005','8110055']
    W.mkdir(exist_ok=False);owned=True;out.update(boot=boot,ownership_before=snap,quiescence_sha256=C['quiescence_sha256'],hardware_access=True,power_change=True);persist()
    bw=['sudo','-n','/usr/bin/env','PYTHONPATH=/home/uwb_student00/.local/lib/python3.9/site-packages','PATH=/home/uwb_student00/.local/bin:/usr/bin:/bin','/home/uwb_student00/.local/bin/bw_bmc_configure','-i','USB','-d','USB:0','power']
    off=run('power-off',bw+['-p','Off']);assert re.search(r'Power:\s+OFF\b',off);read_off=run('off-readback',bw);assert re.search(r'Power:\s+OFF\b',read_off);out['off_confirmed']=True;durable('off-confirmed.json',{'at':now(),'setter':off,'readback':read_off});persist()
    time.sleep(12)
    on=run('power-on',bw+['-p','On']);assert re.search(r'Power:\s+ON\b',on);read_on=run('on-readback',bw);assert re.search(r'Power:\s+ON\b',read_on);out['on_confirmed']=True;durable('on-confirmed.json',{'at':now(),'setter':on,'readback':read_on});persist()
    time.sleep(30)
    assert Path('/proc/sys/kernel/random/boot_id').read_text().strip()==boot
    out.update(success=True,card_cycle_verified=True,boot_after=boot,electrical_waveforms_measured=False,reboot=False)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    out['ended']=now();persist()
    with (W/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2);stream.write('\n')
    for p in sorted(W.glob('*.log'))+sorted(W.glob('*-confirmed.json'))+[W/'result.json']:
        if p.is_file():
            b=p.read_bytes();out['exports'][p.name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'card_cycle_verified':out.get('card_cycle_verified'),'reboot':False}),flush=True)
if not out['success']:raise SystemExit(1)
