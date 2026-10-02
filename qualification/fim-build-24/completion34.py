"""Collect final Work23 completion/images and preserved successor input identities."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';W=B/'work_ia840f_fim_24';J=W/'syn/board/ia840f/syn_top';O=E/'operations/compile';D=E/'completion34';BUFFER='ia840f_migration24_completion34_result'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'files':{}}

def sha(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for x in iter(lambda:f.read(1048576),b''):h.update(x)
    return h.hexdigest()

def export(p):
    data=p.read_bytes();assert len(data)<5000000,str(p)
    R['files'][str(p.relative_to(B))]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}

try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    status=json.loads((O/'status.json').read_text());assert status['complete'] and status['execution_clean'];R['status']=status
    assert not (E/'native-operation.lock').exists()
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe')
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active;R['active_vendor_processes']=active
    for p in (O/'status.json',O/'native.log',O/'gate-events.jsonl',J/'output_files/ofs_top.asm.rpt',J/'output_files/ofs_top.flow.rpt',J/'build_env_db.txt',J/'fme_id.mif',J/'fme-ifc-id.txt',J/'ofs_top.qsf',J/'ofs_top.qpf'):
        export(p)
    R['images']={}
    for p in sorted((J/'output_files').iterdir()):
        if p.is_file() and p.suffix in ('.sof','.rbf','.msf','.pmsf','.bin'):
            R['images'][str(p.relative_to(W))]={'bytes':p.stat().st_size,'sha256':sha(p),'programmed':False,'timing_accepted':False}
    if (J/'ofs_top.qdb').is_file():R['static_qdb']={'path':str(J/'ofs_top.qdb'),'bytes':(J/'ofs_top.qdb').stat().st_size,'sha256':sha(J/'ofs_top.qdb')}
    m=json.loads((E/'stage-inputs/compile.json').read_text());inputs={}
    for group in ('critical_inputs','preflight_only_inputs'):
        for path,h in m[group].items():
            if not path.startswith(str(W)+'/'):continue
            p=Path(path);rel=str(p.relative_to(W));data={'sha256':sha(p),'bytes':p.stat().st_size,'mode':oct(p.stat().st_mode&0o777)}
            if group=='critical_inputs':assert data['sha256']==h,rel
            else:
                assert status['runtime_output_changes'][path]['after_sha256']==data['sha256'],rel
            inputs[rel]=data
    for path,target in m['critical_links'].items():
        p=Path(path);assert p.is_symlink() and os.readlink(p)==target and p.resolve(strict=True).is_relative_to(W)
        inputs[str(p.relative_to(W))]={'symlink':target}
    for p in W.glob('syn/board/ia840f/syn_top/*.qpf'):
        inputs[str(p.relative_to(W))]={'sha256':sha(p),'bytes':p.stat().st_size,'mode':oct(p.stat().st_mode&0o777)}
    assert not any(set(Path(p).parts)&{'db','qdb','output_files','dni','incremental_db'} for p in inputs)
    D.mkdir(exist_ok=False);p=D/'successor-input-inventory.json';p.write_text(json.dumps(inputs,indent=2,sort_keys=True)+'\n');export(p)
    R.update(success=True,source_input_count=len(inputs),successor_inventory_sha256=sha(p),native_status='complete,0/0/0; timing failure remains separate',new_fme_uuid=(J/'fme-ifc-id.txt').read_text().strip())
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION24_COMPLETION34',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
