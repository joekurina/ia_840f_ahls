"""Established narrow root AER prep and PF1/PF0 removal with reviewed VF cascade."""
import base64,datetime,gzip,hashlib,importlib.util,json,os,re,socket,subprocess,sys,time,traceback
from pathlib import Path
C={'pre_sha256': '0fe6e7849705d50cb7050ea4cb0ba9d407d3324aeef1b6829108a0a73bb295ff', 'guard_sha256': '4e63968f5cae892daf07e00399b475e085baf69ad0cdac00c79de7b60b12c44b'}
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01');P=ROOT/'activation-pre43';W=ROOT/'quiesce48';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'approved exact card-only PCI quiescence; no power/reboot/flash/retry','success':False,'hardware_access':False,'power_change':False,'flash_writes':False,'commands':[],'exports':{}};owned=False
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def now():return datetime.datetime.now(datetime.timezone.utc).isoformat()
def persist():(W/'status.json').write_text(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n')
def run(label,argv):
    row={'label':label,'argv':argv,'started':now()};out['commands'].append(row);persist()
    with (W/(label+'.log')).open('xb') as log:
        child=subprocess.Popen(argv,cwd=W,stdout=log,stderr=subprocess.STDOUT,start_new_session=True);row['pid']=child.pid;persist()
        try:row['native_rc']=child.wait(timeout=60)
        except subprocess.TimeoutExpired:row['execution_state']='UNKNOWN; no signal/retry/rescan/power or further hardware action';persist();raise
    row['ended']=now();persist();b=(W/(label+'.log')).read_bytes();assert len(b)<=4*1024**2;row['log_sha256']=hashlib.sha256(b).hexdigest();persist();assert row['native_rc']==0,(label,row['native_rc']);return b.decode(errors='replace')
def transport(r):
    a=r.get('argv',[])
    return ((r.get('exe')=='/usr/bin/bash' and len(a)==3 and a[:2]==['bash','-c'] and a[2].startswith('tmux save-buffer -b '+BATCH+'_source - | ')) or (r.get('exe')=='/usr/bin/tmux' and a==['tmux','wait-for',BATCH+'_done']))
def scan(label):
    snap=json.loads(run(label,['sudo','-n','/usr/bin/python3','-I','-B',str(P/'runtime/ownership27.py')]));out[label]=snap;persist();assert snap['boot_id']==out['boot'] and not any(snap[k] for k in ['d_state','holders','maps','errors']) and not [r for r in snap['relevant_processes'] if not transport(r)];assert snap['retained_original_owner_scope']==g.retained_owner_scope(pre['population_scope']);return snap
try:
    assert __debug__ and os.getuid()==1000 and socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX') and not W.exists()
    assert sha(P/'result.json')==C['pre_sha256'];pre=json.loads((P/'result.json').read_text());assert pre['success'] is True and pre['daemon_stopped'] is True and pre['activation_ready_for_quiescence_only'] is True
    boot=Path('/proc/sys/kernel/random/boot_id').read_text().strip();assert boot==pre['boot']
    for path,h in pre['source_bindings'].items():assert sha(path)==h,path
    for name,m in pre['loaded_module_bindings'].items():assert sha(m['path'])==m['sha256'] and (Path('/sys/module')/name/'notes/.note.gnu.build-id').read_bytes().hex()==m['loaded_note']
    guard=P/'runtime/activation_guards27.py';assert sha(guard)==C['guard_sha256'];spec=importlib.util.spec_from_file_location('quiescence_exact_VF_guards',guard);assert spec and spec.loader;g=importlib.util.module_from_spec(spec);spec.loader.exec_module(g)
    # Acquire finite readiness before mkdir/status writes can wake PID1 for I/O.
    out.update(boot=boot,pre_result_sha256=C['pre_sha256'],population_scope=pre['population_scope'],source_bindings=pre['source_bindings'])
    prechecks=[]
    for _index in range(3):
        z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(P/'runtime/ownership27.py')],capture_output=True,timeout=60)
        assert z.returncode==0,z.stderr.decode(errors='replace')
        snap=json.loads(z.stdout);assert snap['boot_id']==boot and not any(snap[k] for k in ['d_state','holders','maps','errors']) and not [r for r in snap['relevant_processes'] if not transport(r)]
        assert snap['retained_original_owner_scope']==g.retained_owner_scope(pre['population_scope']);prechecks.append(snap)
        if _index<2:time.sleep(1)
    W.mkdir(exist_ok=False);owned=True;out['readiness_before_evidence_writes']=prechecks;persist()
    parent=Path('/sys/bus/pci/devices')/g.ROOT;assert parent.exists();root=parent.resolve(strict=True)
    def names():return sorted(p.name for p in Path('/sys/bus/pci/devices').iterdir())
    def descendants():return sorted(p.name for p in Path('/sys/bus/pci/devices').iterdir() if root in p.resolve().parents)
    before=prechecks[-1];g.validate_population(before['pci'],descendants());out['ownership-before']=before;out['pci_before']=names();persist()
    out['hardware_access']=True;persist();aer=run('aer-before',['sudo','-n','/usr/sbin/setpci','-s',g.ROOT,'ECAP_AER+0x04.L','ECAP_AER+0x08.L','ECAP_AER+0x14.L']).splitlines();assert aer==pre['aer_before'] and all(re.fullmatch(r'[0-9a-f]{8}',v) for v in aer);out['aer_before']=aer;persist()
    run('aer-surprise-clear',['sudo','-n','/usr/sbin/setpci','-s',g.ROOT,'ECAP_AER+0x04.L=20:20'])
    run('aer-surprise-mask',['sudo','-n','/usr/sbin/setpci','-s',g.ROOT,'ECAP_AER+0x08.L=20:20'])
    afteraer=run('aer-after',['sudo','-n','/usr/sbin/setpci','-s',g.ROOT,'ECAP_AER+0x08.L','ECAP_AER+0x14.L']).splitlines();assert afteraer==[f'{int(aer[1],16)|0x20:08x}',aer[2]];out['aer_after']=afteraer;persist()
    run('remove-management',['sudo','-n','/usr/bin/pci_device',g.PF1,'remove']);mid=names();g.after_pf1(out['pci_before'],mid,descendants());out['pci_after_pf1']=mid;persist()
    run('remove-application-PF',['sudo','-n','/usr/bin/pci_device',g.PF0,'remove']);final=names();g.after_pf0(out['pci_before'],mid,final,descendants());out['pci_after']=final;persist()
    scan('ownership-after');assert parent.exists() and Path('/proc/sys/kernel/random/boot_id').read_text().strip()==boot
    out.update(success=True,endpoints_removed=True,root_preserved=True,VF_cascade_verified=True,removed_exactly=sorted(g.CARD),no_PCI_additions=True)
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
if owned:
    out['ended']=now();persist()
    with (W/'result.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2);stream.write('\n')
    for p in sorted(W.glob('*.log'))+[W/'result.json']:
        if p.is_file():
            b=p.read_bytes();assert len(b)<=4*1024**2;out['exports'][p.name]={'source':str(p),'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'power_change':False}),flush=True)
if not out['success']:raise SystemExit(1)
