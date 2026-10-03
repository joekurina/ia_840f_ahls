"""Fresh Quartus26.1.1 PFG help/tool binding only; no project or hardware."""
import base64,gzip,hashlib,json,os,resource,signal,socket,subprocess,sys,time,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');H=ROOT/'help01';Q=Path('/opt/altera/26.1.1/quartus');BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'same-release file-generator help and ordinary tool hashes only; no conversion/programming/hardware','success':False,'hardware_access':False,'conversion_started':False,'exports':{}};owned=False;child=None
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def group(gid):
    found=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            f=(p/'stat').read_text().rsplit(')',1)[1].split()
            if int(f[2])==gid and f[0]!='Z':found.append(int(p.name))
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    return found
try:
    assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not H.exists();cpus=sorted(os.sched_getaffinity(0));assert cpus==list(range(36))
    paths=[Q/'bin/quartus_pfg',Q/'linux64/quartus_pfg'];bindings={str(p):{'bytes':p.stat().st_size,'sha256':sha(p),'real':str(p.resolve())} for p in paths}
    H.mkdir(parents=True,exist_ok=False);owned=True
    for n in ['home','tmp']:(H/n).mkdir()
    env={k:os.environ[k] for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER')}
    env.update(HOME=str(H/'home'),TMPDIR=str(H/'tmp'),PATH=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/bin:/bin',LANG='C',QUARTUS_ROOTDIR_OVERRIDE=str(Q))
    def limits():os.sched_setaffinity(0,set(cpus));resource.setrlimit(resource.RLIMIT_AS,(64*1024**3,64*1024**3));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    argv=[str(Q/'bin/quartus_pfg'),'--help'];log=H/'help.log';expired=False
    with log.open('xb') as stream:
        try:
            child=subprocess.Popen(argv,cwd=H,env=env,stdout=stream,stderr=subprocess.STDOUT,start_new_session=True,preexec_fn=limits);deadline=time.monotonic()+60
            while os.waitid(os.P_PID,child.pid,os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
                assert log.stat().st_size<=2*1024**2
                if time.monotonic()>=deadline:expired=True;break
                time.sleep(.1)
            remaining=group(child.pid)
            while remaining and not expired and time.monotonic()<deadline:time.sleep(.1);remaining=group(child.pid)
            if remaining:expired=True
        finally:
            if child is not None:
                if group(child.pid):
                    os.killpg(child.pid,signal.SIGTERM);end=time.monotonic()+3
                    while group(child.pid) and time.monotonic()<end:time.sleep(.1)
                    if group(child.pid):os.killpg(child.pid,signal.SIGKILL)
                out.update(native_rc=child.wait(),timeout=expired)
    assert out['native_rc']==0 and not expired and not group(child.pid) and log.stat().st_size<=2*1024**2
    assert all(sha(p)==v['sha256'] for p,v in bindings.items())
    data=log.read_bytes();text=data.decode(errors='replace');assert '26.1.1' in text and 'Build 130' in text
    out.update(success=True,argv=argv,cwd=str(H),tool_bindings=bindings,cpus=cpus,address_space_limit_bytes=64*1024**3,owned_group_live_after=group(child.pid))
    out['exports']['help.log']={'source':str(log),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    with (H/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2)
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'conversion_started':False}),flush=True)
if not out['success']:raise SystemExit(1)
