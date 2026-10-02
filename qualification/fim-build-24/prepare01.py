"""Exclusive ordinary-file CLOCK_SPINE2 successor preparation; no vendor/device tool."""
import base64,datetime,gzip,hashlib,json,os,shutil,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP')
OLD=B/'work_ia840f_fim_23';W=B/'work_ia840f_fim_24'
OE=B/'qualification/fim-build-23';E=B/'qualification/fim-build-24'
J=W/'syn/board/ia840f/syn_top'
INPUT='ia840f_migration24_prepare01_inputs';OUTPUT='ia840f_migration24_prepare01_result'
PAYLOAD_SHA='75cf305ff7a7fca915c3f6154aeddffb9883f132e82fb15944920197df1669e0'
R={'batch':OUTPUT,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'native_tools_executed':False,'authority_issued':False};owned=False

def sha(p):
    h=hashlib.sha256()
    with Path(p).open('rb') as f:
        for data in iter(lambda:f.read(1048576),b''):h.update(data)
    return h.hexdigest()

def verify(p,item):
    if 'symlink' in item:
        assert p.is_symlink() and os.readlink(p)==item['symlink'],str(p)
    else:
        assert not p.is_symlink() and p.is_file(),str(p)
        assert p.stat().st_size==item['bytes'] and sha(p)==item['sha256'],str(p)
        assert oct(p.stat().st_mode&0o777)==item['mode'],str(p)

def identity(p):
    if p.is_symlink():return {'symlink':os.readlink(p)}
    return {'bytes':p.stat().st_size,'sha256':sha(p),'mode':oct(p.stat().st_mode&0o777)}

def save(p,data):
    p.parent.mkdir(parents=True,exist_ok=True)
    with p.open('xb') as f:f.write(data)

def sj(p,data):save(p,(json.dumps(data,indent=2,sort_keys=True)+'\n').encode())

try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not E.exists() and not E.is_symlink() and not W.exists() and not W.is_symlink(),'fresh successor required'
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe')
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
    assert mem>80000000000 and shutil.disk_usage(B).free>20000000000
    raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert hashlib.sha256(raw).hexdigest()==PAYLOAD_SHA
    payload=json.loads(gzip.decompress(raw));assert payload['batch']==INPUT and payload['no_native_execution'] is True
    m=payload['manifest23'];assert sha(OE/'stage-inputs/compile.json')==payload['manifest23_sha256']
    assert json.loads((OE/'stage-inputs/compile.json').read_text())==m
    assert sorted(os.sched_getaffinity(0))==m['cpus']
    status=OE/'operations/compile/status.json';assert sha(status)==payload['completion23_status_sha256']
    sr=json.loads(status.read_text());assert sr['complete'] and sr['execution_clean'] and not (OE/'native-operation.lock').exists()
    invfile=OE/'completion24/successor-input-inventory.json';assert sha(invfile)==payload['work23_inputs_sha256']
    inv=payload['work23_inputs'];assert json.loads(invfile.read_text())==inv and len(inv)==3963
    assert not any(set(Path(rel).parts)&{'db','qdb','output_files','dni','incremental_db'} for rel in inv)
    for rel,item in inv.items():verify(OLD/rel,item)
    for group in ('critical_inputs','runtime_hashes','prerequisites'):
        for p,h in m[group].items():assert sha(p)==h,p
    for p,h in m['preflight_only_inputs'].items():assert sha(p)==sr['runtime_output_changes'][p]['after_sha256'],p
    for rel,item in payload['images23'].items():
        p=OLD/rel;assert p.stat().st_size==item['bytes'] and sha(p)==item['sha256'],rel
    qdb=payload['static_qdb23'];assert sha(Path(qdb['path']))==qdb['sha256']
    a=B/'qualification/fim-build-21/compile-authorization.json';assert sha(a)==payload['source_authorization21_sha256']
    auth=json.loads(a.read_text());source={}
    for tree,entries in auth['source_sha256'].items():
        for rel,h in entries.items():
            p=Path(auth['source'])/tree/rel;assert sha(p)==h,str(p);source[str(p)]=h
    for rel,h in auth['pim_sha256'].items():
        p=Path(auth['pim'])/rel;assert sha(p)==h,str(p);source[str(p)]=h
    decoded={}
    for rel,item in payload['files'].items():
        assert not Path(rel).is_absolute() and '..' not in Path(rel).parts
        data=base64.b64decode(item['base64'],validate=True)
        assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256'];decoded[rel]=data
    expected={'candidate01/ia840f_migration_gate.py', 'clock-routing-delta01.qsf', 'candidate01/build_gate.tcl', 'candidate-inert08.json', 'clock-assignment-inert01.tcl', 'candidate02/run-compile30.py', 'predecessor-evidence/reviews-consumed36.json', 'candidate01/CMakeLists.txt', 'predecessor-evidence/RESULT-ACCEPTANCE53.md', 'predecessor-evidence/cpa-implementation-RESULT09.md', 'candidate01/ofs_top.qsf', 'candidate01/top.sdc', 'predecessor-evidence/RESULT33.md', 'compile-runner-inert30.json', 'predecessor-evidence/result-review32.md'}
    assert set(decoded)==expected
    qsfrel='syn/board/ia840f/syn_top/ofs_top.qsf';sdc='syn/shared_config/top.sdc'
    before_qsf=(OLD/qsfrel).read_bytes();assert before_qsf.count(b'set_global_assignment -name SEED 3\n')==1
    assert b'CLOCK_SPINE' not in before_qsf and b'CLOCK_REGION' not in before_qsf
    assert decoded['clock-routing-delta01.qsf']==b'\n# Work24: documented EMIF1 SCLK selection; retain full PR clock coverage.\nset_instance_assignment -name CLOCK_SPINE 2 -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}\nset_instance_assignment -name CLOCK_REGION "SX0 SY0 SX6 SY7" -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}\n'
    assert decoded['candidate01/ofs_top.qsf']==before_qsf+decoded['clock-routing-delta01.qsf']
    assert decoded['candidate01/top.sdc']==(OLD/sdc).read_bytes()
    for rel in ('candidate01/ia840f_migration_gate.py','candidate02/run-compile30.py'):
        assert decoded[rel]==(OE/rel).read_bytes().replace(str(OE).encode(),str(E).encode()).replace(b'qualification/fim-build-23',b'qualification/fim-build-24').replace(b'work_ia840f_fim_23',b'work_ia840f_fim_24')
    assert decoded['candidate01/CMakeLists.txt']==(OE/'candidate01/CMakeLists.txt').read_bytes()
    assert decoded['candidate01/build_gate.tcl']==(OLD/'syn/board/ia840f/setup/build_gate.tcl').read_bytes()
    E.mkdir();owned=True;W.mkdir();sj(E/'original-source-pim-inventory01.json',source)
    for rel,data in decoded.items():save(E/rel,data)
    relocated={}
    for rel,item in inv.items():
        src=OLD/rel;dst=W/rel;dst.parent.mkdir(parents=True,exist_ok=True)
        if 'symlink' in item:
            target=item['symlink'].replace(str(OLD),str(W));os.symlink(target,dst)
            if target!=item['symlink']:relocated[rel]={'kind':'exact-work-root symlink relocation','before':item['symlink'],'after':target}
        else:
            shutil.copy2(src,dst);verify(dst,item);data=dst.read_bytes()
            if str(OLD).encode() in data:
                assert b'\0' not in data;data.decode('utf-8')
                dst.write_bytes(data.replace(str(OLD).encode(),str(W).encode()));shutil.copystat(src,dst)
                relocated[rel]={'kind':'exact-work-root text relocation','before':item['sha256'],'after':sha(dst)}
    overlays={qsfrel:'candidate01/ofs_top.qsf','syn/board/ia840f/setup/ia840f_migration_gate.py':'candidate01/ia840f_migration_gate.py'}
    changes={}
    for rel,key in overlays.items():
        p=W/rel;old=p.read_bytes();save(E/'copied-before'/rel,old);p.write_bytes(decoded[key]);shutil.copystat(OLD/rel,p)
        changes[rel]={'before':hashlib.sha256(old).hexdigest(),'after':sha(p),'role':'CLOCK_SPINE2 plus explicit unchanged full CLOCK_REGION; seed3 retained' if rel==qsfrel else 'fresh authority/WORK root binding only'}
    after={rel:identity(W/rel) for rel in inv}
    for rel,item in after.items():
        if 'symlink' in item:assert (W/rel).resolve(strict=True).is_relative_to(W),rel
    assert after[sdc]['sha256']==inv[sdc]['sha256']
    assert after['syn/board/ia840f/setup/pr_assignments.tcl']['sha256']==inv['syn/board/ia840f/setup/pr_assignments.tcl']['sha256']
    assert not any((J/x).exists() for x in ('db','qdb','output_files','ofs_top.qdb'))
    replacements={str(OE/'candidate01/CMakeLists.txt'):str(E/'candidate01/CMakeLists.txt'),str(OE/'candidate01/ia840f_migration_gate.py'):str(E/'candidate01/ia840f_migration_gate.py'),str(OE/'candidate02/run-compile30.py'):str(E/'candidate02/run-compile30.py')}
    for group in ('critical_inputs','preflight_only_inputs'):
        table={}
        for p,h in m[group].items():
            np=str(W)+p[len(str(OLD)):] if p.startswith(str(OLD)+'/') else replacements.get(p,p)
            table[np]=sha(np)
        m[group]=table
    m['runtime_output_roles']={str(W)+p[len(str(OLD)):]:v for p,v in m['runtime_output_roles'].items()}
    m['critical_links']={str(W)+p[len(str(OLD)):]:target.replace(str(OLD),str(W)) for p,target in m['critical_links'].items()}
    contexts=json.loads(json.dumps(m['contexts']).replace(str(OLD),str(W)))
    assert len(contexts)==135 and contexts[0]['cwd']==str(J)
    m.update(work=str(W),project=str(J),contexts=contexts,parent_execution_accepted=False,runner_sha256=sha(E/'candidate02/run-compile30.py'),cmake_sha256=sha(E/'candidate01/CMakeLists.txt'))
    for rel in expected:
        if rel.startswith('predecessor-evidence/') or rel.endswith('-inert08.json') or rel.endswith('-inert30.json') or rel in ('clock-routing-delta01.qsf','clock-assignment-inert01.tcl'):m['prerequisites'][str(E/rel)]=sha(E/rel)
    m['prerequisites'].update({str(status):sha(status),str(invfile):sha(invfile)})
    m['authority_basis']='Work24 CLOCK_SPINE2/full-region successor of timing-rejected Work23; seed3 retained; DRAFT ONLY pending independent SPEC/execution QUALITY and parent admission.'
    m['validation_scope']='Third full native Quartus26.1.1 compile: exact EMIF1 CLOCK_SPINE2 plus explicit unchanged full region; no other physical/clock/interface change intended; results separate.'
    m['acceptance_requirements'] += ['Exact EMIF1 global source consumes CLOCK_SPINE2 with unchanged SX0 SY0 SX6 SY7 region and root ownership; no ignored/illegal assignment.', 'Compare both CPA COMP roles and exact bit243 all-corner path; preserve both DDR banks, collateral clocks, PR coverage and unchanged signoff.']
    m['predecessor']={'work':str(OLD),'compile_manifest_sha256':payload['manifest23_sha256'],'input_inventory_sha256':payload['work23_inputs_sha256'],'timing_review_sha256':payload['review32_sha256'],'physical_delta':'CLOCK_SPINE2 plus explicit unchanged full CLOCK_REGION; seed3 retained','timing_or_hardware_accepted':False}
    assert set(m['preflight_only_inputs'])==set(m['runtime_output_roles'])
    assert not set(m['critical_inputs'])&set(m['preflight_only_inputs'])
    for group in ('critical_inputs','preflight_only_inputs','runtime_hashes','prerequisites'):
        for p,h in m[group].items():assert sha(p)==h,p
    sj(E/'compile-inputs.draft01.json',m)
    tcp=subprocess.run(['/usr/bin/tclsh',str(E/'clock-assignment-inert01.tcl')],cwd=J,text=True,capture_output=True,timeout=20)
    assert tcp.returncode==0 and tcp.stdout.strip()=='CLOCK_ASSIGNMENT_INERT_PASS exact two calls',(tcp.returncode,tcp.stdout,tcp.stderr)
    sj(E/'clock-assignment-inert01.json',{'rc':tcp.returncode,'stdout':tcp.stdout,'stderr':tcp.stderr,'native_tool_execution':False,'scope':'standalone Tcl argument parsing only, not Quartus assignment consumption'})
    checks=[];env=dict(os.environ);env.pop('IA840F_MIGRATION_AUTHORITY',None);env['PYTHONDONTWRITEBYTECODE']='1'
    for label,argv,marker in [('copied_tcl_missing_authority',['/usr/bin/tclsh',str(W/'syn/board/ia840f/setup/build_gate.tcl')],'IA840F_GATE_REJECTED'),('runner_missing_manifest',['/usr/bin/python3','-B',str(E/'candidate02/run-compile30.py'),'compile','0'*64],'stage-inputs/compile.json')]:
        cp=subprocess.run(argv,cwd=J,env=env,text=True,capture_output=True,timeout=20)
        assert cp.returncode!=0 and marker in cp.stdout+cp.stderr,(label,cp.returncode,cp.stdout,cp.stderr)
        checks.append({'label':label,'argv':argv,'rc':cp.returncode,'stdout':cp.stdout,'stderr':cp.stderr,'native_tool_execution':False})
    assert not (E/'operations').exists() and not (E/'stage-inputs').exists() and not (E/'native-operation.lock').exists()
    assert all(identity(W/rel)==item for rel,item in after.items()),'rejection checks changed WORK'
    for rel,item in inv.items():verify(OLD/rel,item)
    for p,h in source.items():assert sha(p)==h,p
    for rel,item in payload['images23'].items():assert sha(OLD/rel)==item['sha256']
    assert sha(Path(qdb['path']))==qdb['sha256']
    sj(E/'work-input-inventory01.json',after);sj(E/'relocations01.json',relocated);sj(E/'overlay-delta01.json',changes);sj(E/'real-entry-rejection01.json',checks)
    R.update(success=True,input_entries=len(after),relocation_count=len(relocated),overlay_files=len(changes),source_pim_entries=len(source),original_input_bindings_preserved=True,original_images_static_qdb_preserved=True,source_pim_preserved=True,contexts=len(contexts),draft_sha256=sha(E/'compile-inputs.draft01.json'),work_inventory_sha256=sha(E/'work-input-inventory01.json'),checks=checks,resource_preflight={'mem_available_bytes':mem,'disk_free_bytes':shutil.disk_usage(B).free,'cpus':sorted(os.sched_getaffinity(0))})
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    R['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
    if owned:sj(E/'preparation-result01.json',R)
    R['exports']={}
    if owned:
        for name in ('compile-inputs.draft01.json','work-input-inventory01.json','relocations01.json','overlay-delta01.json','real-entry-rejection01.json','preparation-result01.json','original-source-pim-inventory01.json','clock-assignment-inert01.json'):
            p=E/name
            if p.exists():
                data=p.read_bytes();R['exports'][name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',OUTPUT,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',OUTPUT+'_sha256',h],check=True)
    print('MIGRATION24_PREPARE01',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
