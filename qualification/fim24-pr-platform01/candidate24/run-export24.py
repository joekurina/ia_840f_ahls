"""One-time CMake-native PR export from the preserved Work24 copy."""
import base64,datetime,gzip,hashlib,json,os,resource,re,shutil,signal,socket,subprocess,sys,time
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP')
ROOT=B/'work_fim24_pr_platform01';D=ROOT/'base01';P=ROOT/'prepared15';R=ROOT/'export01';T=ROOT/'release01';PROJECT=D/'syn/board/ia840f/syn_top';W=B/'work_ia840f_fim_24';Q=Path('/opt/altera/26.1.1/quartus')
MANIFEST=P/'export-inputs.admitted.json'
BUFFER='ia840f_fim24_pr_export17_result'
MARKERS=(b'IA840F_GATE_REJECTED',b'Critical Warning (125091)')


def now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()

def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

def identity(pid):
    root = Path('/proc')/str(pid)
    fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'start_ticks': fields[19], 'exe': os.readlink(root/'exe'),
            'cwd': os.readlink(root/'cwd'),
            'argv': (root/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}

def live_group(gid):
    result = []
    for root in Path('/proc').iterdir():
        if not root.name.isdigit():
            continue
        try:
            fields = (root/'stat').read_text().rsplit(')', 1)[1].split()
            if int(fields[2]) == gid and fields[0] != 'Z':
                result.append(int(root.name))
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            pass
    return result


def entry_identity(path):
    if path.is_symlink():
        return {'kind':'symlink','target':os.readlink(path)}
    if not path.is_file():
        return {'missing':True}
    return {'kind':'file','bytes':path.stat().st_size,'sha256':sha(path),'mode':oct(path.stat().st_mode&0o777)}


def inventory(root):
    result={};total=0
    for directory,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(directory)/name
            if p.is_symlink():
                assert p.resolve(strict=True).is_relative_to(root),str(p)
                result[str(p.relative_to(root))]=entry_identity(p)
            elif p.is_file():
                total+=p.stat().st_size
                assert total<64*1024**3
                result[str(p.relative_to(root))]=entry_identity(p)
        assert len(result)<=100000
    return result


def preflight(expected):
    assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',expected)
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(MANIFEST)==expected
    m=json.loads(MANIFEST.read_text())
    assert m['scope']=='release-only' and m['parent_execution_accepted'] is True
    assert m['part']=='AGFB027R25A2E2V' and m['toolchain']=='Quartus Prime Pro 26.1.1 Build 130'
    for k,p in [('base',D),('project',PROJECT),('operation',R),('target',T),('prepared_root',P),('original_work',W)]:
        assert m[k]==str(p),k
    assert m['runner_sha256']==sha(Path(__file__))
    assert Path(__file__).resolve()==P/'candidate24/run-export24.py'
    assert m['prerequisites']
    for path,h in m['prerequisites'].items():assert sha(path)==h,path
    sb=Path(m['stage_file']).read_bytes();assert hashlib.sha256(sb).hexdigest()==m['stage_sha256'];stage=json.loads(gzip.decompress(sb))
    assert stage['success'] and stage['original_root']==str(W) and stage['staged_root']==str(D)
    assert len(stage['original_inventory'])==6160 and inventory(W)==stage['original_inventory']
    pf=Path(m['prepared_inventory']);assert sha(pf)==m['prepared_inventory_sha256'];prepared=json.loads(pf.read_text())
    assert len(prepared)==4285 and inventory(D)==prepared
    for path,h in m['critical_inputs'].items():assert sha(path)==h,path
    for item in list(m['tools'].values())+[dict(v,path=k) for k,v in m['installed'].items()]+list(m['candidate_bindings'].values()):
        assert sha(item['path'])==item['sha256'],item['path']
    pim=Path(m['pim']);assert len(m['pim_inventory'])==276
    for n,item in m['pim_inventory'].items():assert (pim/n).stat().st_size==item['bytes'] and sha(pim/n)==item['sha256'],n
    assert subprocess.check_output(['git','-C',str(pim.parent),'rev-parse','HEAD'],text=True).strip()==m['pim_head']
    assert (PROJECT/'fme-ifc-id.txt').read_text().strip()==m['expected_interface_uuid']
    for n,item in m['artifact_bindings'].items():assert sha(D/n)==item['sha256'] and sha(W/n)==item['sha256'],n
    assert sorted(os.sched_getaffinity(0))==m['available_affinity'] and m['cpus']==m['available_affinity']
    assert m['address_space_limit_bytes']==64*1024**3
    memory=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024
    assert memory>80000000000 and shutil.disk_usage(ROOT).free>20000000000
    assert all(os.environ.get(k) for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'))
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe')
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vlog','vsim')):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    assert all(not p.exists() and not p.is_symlink() for p in (R,T)),'operation/target already consumed'
    return m,stage,prepared


def postflight(m,stage,prepared,result):
    errors=[]
    def check(label,fn):
        try:result[label]=bool(fn())
        except Exception as exc:result[label]=False;errors.append({'label':label,'error':repr(exc)})
    check('original_work24_preserved',lambda:inventory(W)==stage['original_inventory'])
    check('static_artifacts_preserved',lambda:all(sha(D/n)==e['sha256'] and sha(W/n)==e['sha256'] for n,e in m['artifact_bindings'].items()))
    check('critical_inputs_preserved',lambda:all(sha(p)==h for p,h in m['critical_inputs'].items()))
    check('tools_and_installed_preserved',lambda:all(sha(e['path'])==e['sha256'] for e in list(m['tools'].values())+[dict(v,path=k) for k,v in m['installed'].items()]))
    check('pim_preserved',lambda:all(sha(Path(m['pim'])/n)==e['sha256'] for n,e in m['pim_inventory'].items()))
    delta={}
    for n,before in prepared.items():
        after=entry_identity(D/n)
        if before!=after:delta[n]={'before':before,'after':after}
    result['prepared_existing_delta_after_native']=delta
    allowed={'syn/board/ia840f/syn_top/ofs_pr_afu.qsf','syn/board/ia840f/syn_top/ofs_top.qpf'}
    result['only_expected_native_project_metadata_changed']=set(delta)<=allowed
    if not result['only_expected_native_project_metadata_changed']:errors.append({'label':'unexpected_prepared_input_changes','paths':sorted(set(delta)-allowed)})
    result['release_inventory']={}
    if T.exists():
        try:result['release_inventory']=inventory(T)
        except Exception as exc:errors.append({'label':'release_inventory','error':repr(exc)})
    result['release_paths_present']={n:(T/n).exists() for n in ('bin/afu_synth','bin/update_pim','hw/lib/build/quartus_proj_dir','hw/lib/build/platform/ofs_plat_if','hw/blue_bits/ofs_top.sof','hw/lib/fme-ifc-id.txt')}
    check('matched_interface_uuid',lambda:(T/'hw/lib/fme-ifc-id.txt').read_text().strip()==m['expected_interface_uuid'])
    def static_match():
        project=T/'hw/lib/build/quartus_proj_dir'
        names=['syn/board/ia840f/syn_top/ofs_top.qdb','syn/board/ia840f/syn_top/output_files/ofs_top.sof','syn/board/ia840f/syn_top/output_files/ofs_top.static.msf','syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf']
        for n in names:
            suffix=Path(n).relative_to('syn/board/ia840f/syn_top')
            if sha(project/suffix)!=m['artifact_bindings'][n]['sha256']:return False
        return True
    check('matched_release_static_artifacts',static_match)
    diagnostics=[]
    for log in R.glob('*.log'):
        if log.stat().st_size > m['log_limit_bytes']:
            diagnostics.append({'log':log.name,'error':'finite log-size bound exceeded; full text not read'})
            continue
        for number,line in enumerate(log.read_text(errors='replace').splitlines(),1):
            if any(marker.decode() in line for marker in MARKERS) or re.search(r'\b(?:Error|Fatal)(?:\s+\([^)]*\))?\s*:',line,re.I):diagnostics.append({'log':log.name,'line':number,'text':line})
    result['diagnostics']=diagnostics;result['postflight_errors']=errors
    result['log_hashes']={p.name:{'bytes':p.stat().st_size,'sha256':sha(p)} for p in R.glob('*.log')}
    flags=('original_work24_preserved','static_artifacts_preserved','critical_inputs_preserved','tools_and_installed_preserved','pim_preserved','only_expected_native_project_metadata_changed','matched_interface_uuid','matched_release_static_artifacts')
    return not errors and not diagnostics and all(result.get(k) is True for k in flags) and all(result['release_paths_present'].values())


def run():
    assert len(sys.argv)==2
    expected=sys.argv[1];m,stage,prepared=preflight(expected)
    R.mkdir(exist_ok=False)
    for name in ('home','tmp'):(R/name).mkdir()
    env={k:v for k,v in os.environ.items() if not k.startswith(('OFS_','IA840F_')) and k not in ('LD_LIBRARY_PATH','PYTHONPATH','PYTHONOPTIMIZE','QUARTUS_ROOTDIR','QUARTUS_ROOTDIR_OVERRIDE','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL_PRINTED','OPAE_PLATFORM_GEN','BBS_LIB_PATH','AFU_WITH_PIM','PR_COMPILE','Q_REVISION','Q_PROJECT','Q_PR_REVISION','SEED','ANALYSIS_AND_ELAB_ONLY')}
    env.update(HOME=str(R/'home'),TMPDIR=str(R/'tmp'),LANG='C',QUARTUS_ROOTDIR_OVERRIDE=str(Q),OFS_ROOTDIR=str(D),OFS_PLATFORM_AFU_BBB=str(Path(m['pim']).parent),OFS_BUILD_NUMBER='866c25bb',OPAE_PLATFORM_GEN='1',PR_COMPILE='1',PYTHONDONTWRITEBYTECODE='1',PATH=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/local/bin:/usr/bin:/bin')
    authority={'approved':True,'ready_for_build':False,'scope':'release-only','project':str(PROJECT),'part':m['part'],'toolchain':m['toolchain'],'runner':identity(os.getpid()),'contexts':m['contexts'],'runtime_hashes':{e['path']:e['sha256'] for k,e in m['tools'].items() if k.startswith('linux64/')},'critical_inputs':m['critical_inputs'],'guard_sha256':m['candidate_bindings']['ia840f_release_gate01.py']['sha256'],'manifest_sha256':expected}
    with (R/'authority.json').open('x') as f:json.dump(authority,f,indent=2)
    assert json.loads((R/'authority.json').read_text())==authority
    result={'run':'work24-pr-export01','started':now(),'commands':[],'complete':False,'hardware_access':False,'ready_for_build':False,'manifest_sha256':expected,'authority_sha256':sha(R/'authority.json'),'native_acceptance':'PENDING ACTUAL RESULT REVIEW','resource_policy':{'cpus':m['cpus'],'address_space_limit_bytes':m['address_space_limit_bytes'],'deadlines_seconds':m['deadlines_seconds']}}
    operation=R
    J=D  # CMake launch cwd; its targets set their own explicit working directory.
    def persist():
        (R/'status.json').write_text(json.dumps(result,indent=2)+'\n')
    def limits():
        os.sched_setaffinity(0,set(m['cpus']))
        resource.setrlimit(resource.RLIMIT_AS,(m['address_space_limit_bytes'],m['address_space_limit_bytes']))
        resource.setrlimit(resource.RLIMIT_CORE,(0,0))
    def native(label, argv, duration):
        rec = {'label': label, 'argv': argv, 'started': now()}
        result['commands'].append(rec)
        persist()
        child = None
        timedout = False
        rejected = False
        log_bound_exceeded = False
        offset = 0
        tail = b''
        logfile = operation/(label+'.log')
        def inspect_log():
            nonlocal offset, tail, rejected, log_bound_exceeded
            limit = m['log_limit_bytes']
            if logfile.stat().st_size > limit:
                log_bound_exceeded = True
                raise RuntimeError('owned native log exceeded finite bound')
            with logfile.open('rb') as reader:
                reader.seek(offset)
                # Read only the remaining admitted budget plus one sentinel byte.
                data = reader.read(limit-offset+1)
            offset += len(data)
            if offset > limit or logfile.stat().st_size > limit:
                log_bound_exceeded = True
                raise RuntimeError('owned native log exceeded finite bound')
            window = tail+data
            rejected = rejected or any(marker in window for marker in MARKERS)
            tail = window[-128:]
            if rejected:
                raise RuntimeError('owned native callback rejection')
        with logfile.open('xb') as log:
            try:
                child = subprocess.Popen(argv, cwd=J, env=env, stdout=log, stderr=subprocess.STDOUT,
                                         start_new_session=True, preexec_fn=limits)
                # Protection begins immediately after spawn, including bookkeeping failures.
                rec['process'] = identity(child.pid)
                persist()
                deadline = time.monotonic()+duration
                while os.waitid(os.P_PID, child.pid, os.WEXITED|os.WNOHANG|os.WNOWAIT) is None:
                    inspect_log()
                    if time.monotonic() > deadline:
                        timedout = True
                        break
                    time.sleep(0.2)
                residual = live_group(child.pid)
                rec['descendants_observed_at_leader_exit'] = residual
                while residual and not timedout and time.monotonic() < deadline:
                    inspect_log()
                    time.sleep(0.2)
                    residual = live_group(child.pid)
                # Consume final bytes even if the group ended between samples.
                inspect_log()
                if residual:
                    timedout = True
            finally:
                if child is not None:
                    # Keep the leader unreaped until every possible group signal finishes.
                    if live_group(child.pid):
                        os.killpg(child.pid, signal.SIGTERM)
                        end = time.monotonic()+3
                        while live_group(child.pid) and time.monotonic() < end:
                            time.sleep(0.1)
                        if live_group(child.pid):
                            os.killpg(child.pid, signal.SIGKILL)
                    cmake_rc = child.wait()
                    rec.update(cmake_rc=cmake_rc, timeout=timedout, gate_rejected=rejected,
                               log_bound_exceeded=log_bound_exceeded, ended=now())
                    # Persist raw CMake status before fallible postflight acquisition.
                    persist()
                    residual_after = live_group(child.pid)
                    rec['owned_group_live_after'] = residual_after
                    rec['native_rc'] = 0 if label in ('version', 'export') and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct CMake vendor target: zero propagates child zero; nonzero does not disclose individual vendor exit.'
                                                  if label in ('version', 'export') else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']
    persist()
    try:
        configure=['/usr/bin/cmake','-S',str(P/'candidate03'),'-B',str(R/'cmake-build'),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DFIM_BASE='+str(D),'-DRELEASE_TARGET='+str(T),'-DQUARTUS_ROOT='+str(Q)]
        assert native('configure',configure,m['deadlines_seconds']['configure'])==0,'configure failed'
        assert native('version',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','version','--parallel','1'],m['deadlines_seconds']['version'])==0,'version failed'
        version=(R/'version.log').read_text();assert '26.1.1 Build 130' in version and 'SC Pro Edition' in version
        native('export',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','export','--parallel','1'],m['deadlines_seconds']['export'])
        result['complete']=True
    except BaseException as exc:result['error']=repr(exc)
    finally:
        try:ok=postflight(m,stage,prepared,result)
        except BaseException as exc:ok=False;result['postflight_exception']=repr(exc)
        result['ended']=now()
        result['execution_clean']=result['complete'] and 'error' not in result and len(result['commands'])==3 and all(c.get('effective_rc')==0 for c in result['commands']) and ok
        persist()
        with (R/'result.json').open('x') as f:json.dump(result,f,indent=2)
        blob=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
        with (R/'result.json.gz').open('xb') as f:f.write(blob)
        subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
        print(json.dumps({'success':result['execution_clean'],'scope':'execution only, result review pending','result_sha256':h,'commands':[(c['label'],c.get('cmake_rc'),c.get('effective_rc')) for c in result['commands']]},indent=2),flush=True)
    return 0 if result['execution_clean'] else 1


if __name__=='__main__':
    sys.exit(run())
