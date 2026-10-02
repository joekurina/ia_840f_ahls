"""One admitted mapped persona synthesis; no fit/STA/programming/hardware."""
import datetime,gzip,hashlib,json,os,re,resource,shutil,signal,socket,subprocess,sys,time
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01');D=ROOT/'base01';P=ROOT/'control19';R=ROOT/'synth01';J=D/'build/syn/board/ia840f/syn_top';Q=Path('/opt/altera/26.1.1/quartus')
MANIFEST=P/'synthesis-inputs.admitted.json';BUFFER='ia840f_fim24_caps03_implementation_synth01_result'
MARKERS=(b'IA840F_GATE_REJECTED',b'Critical Warning (125091)')
ERROR=re.compile(r'\b(?:Error|Fatal)(?:\s+\([^)]*\))?\s*:',re.I)

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


def binding(path,item):
    path=Path(path)
    if item.get('kind')=='symlink':
        if not path.is_symlink() or os.readlink(path)!=item['target'] or str(path.resolve(strict=True))!=item['resolved']:return False
        return 'sha256_of_target' not in item or sha(path)==item['sha256_of_target']
    return path.is_file() and not path.is_symlink() and path.stat().st_size==item['bytes'] and sha(path)==item['sha256']


def tree_bound(root,inv):return all(binding(root/n,m) for n,m in inv.items())


def tools_bound(inv):
    for name,m in inv.items():
        p=Path(name)
        if not p.is_file() or sha(p)!=m['sha256']:return False
        if 'bytes' in m and p.stat().st_size!=m['bytes']:return False
        if 'real' in m and str(p.resolve())!=m['real']:return False
    return True


def preflight(expected):
    assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',expected)
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(MANIFEST)==expected;m=json.loads(MANIFEST.read_text())
    assert m['scope']=='persona-mapped-synthesis-only' and m['parent_execution_accepted'] is True and m['ready_for_build'] is False and m['hardware_ready'] is False
    for key,path in [('design_root',D),('control_root',P),('operation_root',R),('project',J)]:assert m[key]==str(path),key
    assert Path(__file__).resolve()==P/'runtime/run-synthesis18.py' and m['runner_path']==str(P/'runtime/run-synthesis18.py') and sha(__file__)==m['runner_sha256']
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and m['prerequisites'] and all(sha(p)==h for p,h in m['prerequisites'].items())
    assert sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256'];prepared=json.loads(Path(m['prepared_metadata_file']).read_text())
    for key in ('design_inventory','critical_inputs','external_inputs','archive_inventory','tools','opae_tools','original_setup_inventory','original_release_inventory'):assert m[key]==prepared[key],key
    assert len(m['design_inventory'])==2589 and len(m['critical_inputs'])==2588 and len(m['external_inputs'])==298 and len(m['archive_inventory'])==857
    assert tree_bound(D,m['design_inventory']) and all(binding(p,x) for p,x in m['external_inputs'].items()) and tree_bound(Path(m['archive_root']),m['archive_inventory'])
    observed=set()
    for directory,dirs,files in os.walk(D,followlinks=False):
        for name in dirs+files:
            p=Path(directory)/name
            if p.is_symlink() or p.is_file():observed.add(str(p.relative_to(D)))
    assert observed==set(m['design_inventory'])
    assert len(m['original_setup_inventory'])==3443 and tree_bound(Path(m['original_setup_root']),m['original_setup_inventory'])
    assert len(m['original_release_inventory'])==3454 and tree_bound(Path(m['release_root']),m['original_release_inventory'])
    assert len(m['tools'])==8 and tools_bound(m['tools']) and len(m['opae_tools'])==92 and tools_bound(m['opae_tools'])
    for prefix in ('setup','release','simulation'):assert sha(m[prefix+'_result_file'])==m[prefix+'_result_sha256'],prefix
    assert sha(D/'build/syn/board/ia840f/setup/ia840f_persona_gate09.py')==m['gate_sha256']
    assert sha(D/'build/syn/board/ia840f/setup/build_gate_persona09.tcl')==m['gate_tcl_sha256']
    expected_context={'exe':str(Q/'linux64/quartus_syn'),'cwd':str(J),'argv':['--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_pr_afu']}
    assert m['contexts']==[expected_context]
    assert not any((J/n).exists() for n in ('dni','db','qdb'))
    for name in m['required_reports']:assert not (J/name).exists(),name
    assert sha(J/'ofs_top.qdb')==m['static_qdb_sha256'] and (Path(m['release_root'])/'hw/lib/fme-ifc-id.txt').read_text().strip()==m['interface_uuid']
    assert sorted(os.sched_getaffinity(0))==m['cpus']==list(range(36)) and m['address_space_limit_bytes']==64*1024**3
    assert int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024>80_000_000_000
    assert shutil.disk_usage(ROOT).free>10_000_000_000 and all(os.environ.get(k) for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'))
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe');cmd=(p/'cmdline').read_bytes()
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')) or (Path(exe).name=='java' and b'/opt/altera/' in cmd):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    assert not R.exists() and not R.is_symlink()
    return m


def qpf_assignments(text):
    values={}
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith('#'):continue
        match=re.fullmatch(r'\s*([A-Z_]+)\s*=\s*"([^"\r\n]*)"\s*',line)
        assert match is not None,('unsupported QPF record',line)
        key,value=match.groups();assert key not in values,('duplicate QPF key',key);values[key]=value
    assert set(values)=={'QUARTUS_VERSION','DATE','PROJECT_REVISION'}
    return values


def postflight(m,result):
    errors=[]
    def verify(label,fn):
        try:result[label]=bool(fn())
        except Exception as exc:result[label]=False;errors.append({'label':label,'error':repr(exc)})
    verify('critical_inputs_preserved',lambda:all(binding(p,x) for p,x in m['critical_inputs'].items()))
    verify('external_inputs_preserved',lambda:all(binding(p,x) for p,x in m['external_inputs'].items()))
    verify('dni_archive_preserved',lambda:tree_bound(Path(m['archive_root']),m['archive_inventory']))
    verify('original_setup_preserved',lambda:tree_bound(Path(m['original_setup_root']),m['original_setup_inventory']))
    verify('original_release_preserved',lambda:tree_bound(Path(m['release_root']),m['original_release_inventory']))
    verify('tools_preserved',lambda:tools_bound(m['tools']) and tools_bound(m['opae_tools']))
    verify('controls_preserved',lambda:sha(__file__)==m['runner_sha256'] and sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256'] and all(sha(p)==h for p,h in m['prerequisites'].items()))
    verify('predecessor_results_preserved',lambda:all(sha(m[prefix+'_result_file'])==m[prefix+'_result_sha256'] for prefix in ('setup','release','simulation')))
    result['logs']={};diagnostics=[];texts={}
    for name in ('configure.log','version.log','synthesis.log'):
        p=R/name
        try:
            size=p.stat().st_size;assert size<=m['log_limit_bytes'];b=p.read_bytes();assert len(b)==size;text=b.decode(errors='replace');texts[name]=text;result['logs'][name]={'bytes':size,'sha256':hashlib.sha256(b).hexdigest()}
            for i,line in enumerate(text.splitlines(),1):
                if ERROR.search(line) or any(mark.decode() in line for mark in MARKERS):diagnostics.append({'file':name,'line':i,'text':line})
        except Exception as exc:errors.append({'file':name,'error':repr(exc)})
    result['diagnostics']=diagnostics
    result['synthesis_success_marker']='Quartus Prime Synthesis was successful' in texts.get('synthesis.log','')
    result['version_matches']='26.1.1 Build 130' in texts.get('version.log','') and 'SC Pro Edition' in texts.get('version.log','')
    result['gate_events']=[];result['gate_rejections']=[]
    for filename,key in [('gate-events.jsonl','gate_events'),('gate-rejections.jsonl','gate_rejections')]:
        p=R/filename
        if p.exists():
            try:
                assert p.stat().st_size<=m['log_limit_bytes'];result[key]=[json.loads(line) for line in p.read_text().splitlines() if line]
            except Exception as exc:errors.append({'file':filename,'error':repr(exc)})
    result['owned_callbacks_accepted']=bool(result['gate_events']) and not result['gate_rejections'] and all(e.get('accepted') is True and e.get('manifest_sha256')==result['manifest_sha256'] and {'exe':e['native']['exe'],'cwd':e['native']['cwd'],'argv':e['native']['argv'][1:]} in m['contexts'] for e in result['gate_events'])
    result['reports']={}
    for name in m['required_reports']:
        p=J/name
        try:
            assert p.is_file() and p.stat().st_size>0;result['reports'][name]={'bytes':p.stat().st_size,'sha256':sha(p)}
        except Exception as exc:errors.append({'report':name,'error':repr(exc)})
    result['qdb_outputs']={};total=0
    try:
        for p in (J/'qdb').rglob('*'):
            if not p.is_file():continue
            assert not p.is_symlink();total+=p.stat().st_size;assert total<=8*1024**3 and len(result['qdb_outputs'])<20000
            result['qdb_outputs'][str(p.relative_to(J))]={'bytes':p.stat().st_size,'sha256':sha(p)}
    except Exception as exc:errors.append({'qdb_inventory':repr(exc)})
    result['qpf_after']={'bytes':(J/'ofs_top.qpf').stat().st_size,'sha256':sha(J/'ofs_top.qpf'),'text':(J/'ofs_top.qpf').read_text()}
    result['qpf_before']=m['qpf_before'];result['qpf_changed']=result['qpf_after']['sha256']!=m['qpf_before']['sha256']
    def qpf_semantics():
        before=qpf_assignments(result['qpf_before']['text']);after=qpf_assignments(result['qpf_after']['text'])
        return after['PROJECT_REVISION']==before['PROJECT_REVISION']=='ofs_pr_afu' and after['QUARTUS_VERSION']==before['QUARTUS_VERSION']=='26.1'
    verify('qpf_semantics_preserved',qpf_semantics)
    result['postflight_errors']=errors
    flags=('critical_inputs_preserved','external_inputs_preserved','dni_archive_preserved','original_setup_preserved','original_release_preserved','tools_preserved','controls_preserved','predecessor_results_preserved','version_matches','synthesis_success_marker','owned_callbacks_accepted','qpf_semantics_preserved')
    return not errors and not diagnostics and all(result.get(k) is True for k in flags) and len(result['reports'])==len(m['required_reports']) and bool(result['qdb_outputs'])


def run():
    assert len(sys.argv)==2;m=preflight(sys.argv[1]);R.mkdir(exist_ok=False)
    result={'batch':BUFFER,'scope':'persona-mapped-synthesis-only','started':now(),'commands':[],'complete':False,'hardware_access':False,'hardware_ready':False,'manifest_sha256':sys.argv[1],'runner':identity(os.getpid()),'project':str(J),'interface_uuid':m['interface_uuid'],'afu_uuid':m['afu_uuid'],'result_acceptance':'pending actual mapped-source/diagnostic/preservation review','resources':{'cpus':m['cpus'],'address_space_limit_bytes':m['address_space_limit_bytes'],'deadlines_seconds':m['deadlines_seconds']}}
    env={k:os.environ[k] for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER')}
    env.update(HOME=str(R/'home'),USER='uwb_student00',LOGNAME='uwb_student00',LANG='C',PATH=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/bin:/bin',TMPDIR=str(R/'tmp'),QUARTUS_ROOTDIR_OVERRIDE=str(Q),OPAE_PLATFORM_ROOT=m['release_root'],BUILD_ROOT_REL='../../../..',PR_COMPILE='1',PYTHONDONTWRITEBYTECODE='1')
    assert 'OPAE_PLATFORM_GEN' not in env
    operation=R
    def persist():(R/'status.json').write_text(json.dumps(result,indent=2)+'\n')
    def limits():
        os.sched_setaffinity(0,set(m['cpus']));resource.setrlimit(resource.RLIMIT_AS,(m['address_space_limit_bytes'],m['address_space_limit_bytes']));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
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
                    rec['native_rc'] = 0 if label in ('version', 'synthesis') and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct CMake vendor target: zero propagates child zero; nonzero does not disclose individual vendor exit.'
                                                  if label in ('version', 'synthesis') else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']
    try:
        persist()
        for name in ('home','tmp'):(R/name).mkdir()
        authority={'scope':m['scope'],'ready_for_build':False,'hardware_ready':False,'manifest':str(MANIFEST),'manifest_sha256':sys.argv[1],'project':str(J),'runner':result['runner'],'contexts':m['contexts']}
        with (R/'authority.json').open('x') as f:json.dump(authority,f,indent=2)
        args=['/usr/bin/cmake','-S',str(P/'runtime'),'-B',str(R/'cmake-build'),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DPERSONA_PROJECT='+str(J),'-DQUARTUS_ROOT='+str(Q)]
        assert native('configure',args,m['deadlines_seconds']['configure'])==0
        assert native('version',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','version','--parallel','1'],m['deadlines_seconds']['version'])==0
        assert '26.1.1 Build 130' in (R/'version.log').read_text() and 'SC Pro Edition' in (R/'version.log').read_text()
        assert native('synthesis',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','synthesis','--parallel','1'],m['deadlines_seconds']['synthesis'])==0
        result['complete']=True
    except BaseException as exc:result['error']=repr(exc)
    finally:
        try:ok=postflight(m,result)
        except BaseException as exc:ok=False;result['postflight_exception']=repr(exc)
        result['ended']=now();result['execution_clean']=result['complete'] and 'error' not in result and len(result['commands'])==3 and all(c.get('effective_rc')==0 for c in result['commands']) and ok
        persist()
        with (R/'result.json').open('x') as f:json.dump(result,f,indent=2)
        blob=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
        with (R/'result.json.gz').open('xb') as f:f.write(blob)
        subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
        print(json.dumps({'execution_clean':result['execution_clean'],'result_sha256':h,'commands':[(c['label'],c.get('cmake_rc'),c.get('effective_rc')) for c in result['commands']]},indent=2),flush=True)
    return 0 if result['execution_clean'] else 1


if __name__=='__main__':sys.exit(run())
