"""Publish one reviewed compile manifest; never invoke a native/device tool."""
import base64,datetime,gzip,hashlib,json,os,re,shutil,socket,subprocess,sys,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-23';W=B/'work_ia840f_fim_23';J=W/'syn/board/ia840f/syn_top'
D=E/'admission04';INPUT='ia840f_migration23_admission04_inputs';OUTPUT='ia840f_migration23_admission04_result'
DRAFT_SHA='51aa191991f930eb9b245c205bef1a4dc867bd7d6045c08a26f6f6016b187165'
SPEC_SHA='592f7c1be51193159c0dc76e507931bf39862ec84a91e79d2664395ba25f4668'
R={'batch':OUTPUT,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'live_authority_issued':False};owned=False

def sha(p):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for block in iter(lambda:f.read(1048576),b''):h.update(block)
    return h.hexdigest()

def save(p,data):
    p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f:f.write(data)

def validate_delta(old,new,added):
    changed={k for k in set(old)|set(new) if old.get(k)!=new.get(k)}
    assert changed=={'parent_execution_accepted','prerequisites','authority_basis','validation_scope'},changed
    assert old['parent_execution_accepted'] is False and new['parent_execution_accepted'] is True
    assert new['stage']=='compile' and new['work']==str(W) and new['project']==str(J)
    assert new['prerequisites']==dict(old['prerequisites'],**added)
    assert new['validation_scope']=='Second full native Quartus26.1.1 compile in the bounded migration campaign: seed3 only; all result/timing/hardware acceptance separate.'
    assert new['authority_basis']=='Work23 seed3 bounded Phase4 successor: independent SPEC and execution QUALITY consumed by parent; source-bound one-time compile only, no timing or hardware acceptance.'

try:
    assert __debug__ and len(sys.argv)==2 and re.fullmatch(r'[0-9a-f]{64}',sys.argv[1]),'exact parent payload hash required'
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert all(not p.exists() and not p.is_symlink() for p in (D,E/'operations',E/'stage-inputs',E/'native-operation.lock')),'admission/stage already used'
    raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==sys.argv[1]
    payload=json.loads(gzip.decompress(raw));assert payload['batch']==INPUT and payload['parent_quality_accepted'] is True
    draft=E/'compile-inputs.draft01.json';assert sha(draft)==DRAFT_SHA==payload['draft_sha256'];old=json.loads(draft.read_text());new=payload['manifest']
    names={'review-spec02.md','spec-consumed03.json','review-quality04.md','quality-consumed05.json'}
    assert set(payload['files'])==names;decoded={};added={}
    for rel,item in payload['files'].items():
        data=base64.b64decode(item['base64'],validate=True);assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256'];decoded[rel]=data;added[str(E/rel)]=item['sha256']
        assert not (E/rel).exists() and not (E/rel).is_symlink(),rel
    assert added[str(E/'review-spec02.md')]==SPEC_SHA
    spec=json.loads(decoded['spec-consumed03.json']);assert spec['report_sha256']==SPEC_SHA and spec['draft_sha256']==DRAFT_SHA
    quality=json.loads(decoded['quality-consumed05.json']);assert quality['accepted'] is True and quality['spec_report_sha256']==SPEC_SHA and quality['draft_sha256']==DRAFT_SHA
    assert quality['report_sha256']==added[str(E/'review-quality04.md')]
    assert Path(__file__).resolve()==E/'admit04.py'
    assert quality['admission_script_sha256']==payload['admission_script_sha256']==sha(Path(__file__))
    validate_delta(old,new,added)
    assert new['part']=='AGFB027R25A2E2V' and new['toolchain']=='Quartus Prime Pro 26.1.1 Build 130'
    assert len(new['contexts'])==135 and sorted(os.sched_getaffinity(0))==new['cpus']
    assert ('set_global_assignment -name NUM_PARALLEL_PROCESSORS '+str(len(new['cpus']))) in (J/'ofs_top.qsf').read_text()
    assert all(os.environ.get(k) for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'))
    mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
    assert mem>80000000000 and shutil.disk_usage(W).free>20000000000
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe')
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    for group in ('critical_inputs','preflight_only_inputs','runtime_hashes','prerequisites'):
        for p,h in new[group].items():
            if p in added:assert added[p]==h
            else:assert sha(p)==h,p
    for p,target in new['critical_links'].items():
        p=Path(p);assert p.is_symlink() and os.readlink(p)==target and p.resolve(strict=True).is_relative_to(W),str(p)
    source=json.loads((E/'original-source-pim-inventory01.json').read_text())
    for p,h in source.items():assert sha(p)==h,p
    inv=json.loads((B/'qualification/fim-build-22/completion51/successor-input-inventory.json').read_text())
    for rel,item in inv.items():
        p=B/'work_ia840f_fim_22'/rel
        if 'symlink' in item:assert p.is_symlink() and os.readlink(p)==item['symlink'],rel
        else:assert not p.is_symlink() and p.stat().st_size==item['bytes'] and sha(p)==item['sha256'],rel
    D.mkdir();owned=True
    for rel,data in decoded.items():save(E/rel,data)
    destination=E/'stage-inputs/compile.json';save(destination,(json.dumps(new,indent=2,sort_keys=True)+'\n').encode());assert json.loads(destination.read_text())==new
    assert not (E/'operations').exists() and not (E/'native-operation.lock').exists()
    R.update(success=True,manifest_path=str(destination),manifest_sha256=sha(destination),stage='compile',parent_manifest_admitted=True,source_pim_entries_verified=len(source),predecessor_inputs_verified=len(inv),critical_inputs=len(new['critical_inputs']),preflight_only_inputs=len(new['preflight_only_inputs']),contexts=len(new['contexts']),resource_preflight={'mem_available_bytes':mem,'disk_free_bytes':shutil.disk_usage(W).free,'cpus':new['cpus']})
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    R['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    if owned:save(D/'result.json',(json.dumps(R,indent=2)+'\n').encode())
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',OUTPUT,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',OUTPUT+'_sha256',h],check=True)
    print('MIGRATION23_ADMISSION04',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
