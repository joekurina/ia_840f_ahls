"""One-time matching persona file setup; no persona compile/hardware."""
import base64,datetime,gzip,hashlib,json,os,resource,re,shutil,signal,socket,subprocess,sys,time
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');ROOT=B/'work_fim24_caps03_persona01';A=ROOT/'prepare01/afu_sources';P=ROOT/'control03';R=ROOT/'setup01';T=R/'persona';REL=B/'work_fim24_pr_platform01/release01';G=B/'work_fim24_caps03_fabric01/generate01';Q=Path('/opt/altera/26.1.1/quartus')
MANIFEST=P/'setup-inputs.admitted.json';BUFFER='ia840f_fim24_caps03_persona_setup09_result'
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


def bind(root,inv):
    for name,item in inv.items():
        p=root/name
        if item.get('kind')=='symlink':
            if not p.is_symlink() or os.readlink(p)!=item['target']:return False
        elif not p.is_file() or p.stat().st_size!=item['bytes'] or sha(p)!=item['sha256']:return False
    return True


def preflight(expected):
    assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',expected)
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(MANIFEST)==expected;m=json.loads(MANIFEST.read_text())
    assert m['scope']=='persona-file-setup-only' and m['parent_execution_accepted'] is True and m['hardware_ready'] is False
    for key,path in [('afu_source_root',A),('control_root',P),('operation_root',R),('persona_target',T),('release_root',REL),('generated_root',G)]:assert m[key]==str(path),key
    assert Path(__file__).resolve()==P/'runtime/run-setup03.py' and sha(__file__)==m['runner_sha256']
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and m['prerequisites'] and all(sha(p)==h for p,h in m['prerequisites'].items())
    assert len(m['staged_inventory'])==298 and bind(A,m['staged_inventory'])
    assert {str(p.relative_to(A)) for p in A.rglob('*') if p.is_file()}==set(m['staged_inventory'])
    assert len(m['setup_tools'])==92 and all(Path(p).stat().st_size==x['bytes'] and sha(p)==x['sha256'] for p,x in m['setup_tools'].items())
    assert all(sha(p)==x['sha256'] for p,x in m['runtime_tools'].items())
    assert sha(m['release_result_file'])==m['release_result_sha256'] and sha(m['fabric_result_file'])==m['fabric_result_sha256']
    release=json.loads(Path(m['release_result_file']).read_text())['release_inventory'];fabric=json.loads(Path(m['fabric_result_file']).read_text())['generated_inventory']
    assert len(release)==3454 and len(fabric)==294 and bind(REL,release) and bind(G,fabric)
    assert (REL/'hw/lib/fme-ifc-id.txt').read_text().strip()==m['interface_uuid']
    assert json.loads((A/'ia840f_ahls_memory.json').read_text())==m['afu_json']
    assert sorted(os.sched_getaffinity(0))==m['cpus'] and len(m['cpus'])==36 and m['address_space_limit_bytes']==64*1024**3
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
    assert not R.exists() and not R.is_symlink() and not T.exists()
    return m,release,fabric


def postflight(m,release,fabric,result):
    errors=[]
    def check(label,fn):
        try:result[label]=bool(fn())
        except Exception as exc:result[label]=False;errors.append({'label':label,'error':repr(exc)})
    check('release_preserved',lambda:bind(REL,release))
    check('fabric_originals_preserved',lambda:bind(G,fabric))
    check('afu_inputs_preserved',lambda:bind(A,m['staged_inventory']))
    check('setup_tools_preserved',lambda:all(sha(p)==x['sha256'] for p,x in m['setup_tools'].items()))
    check('runtime_tools_preserved',lambda:all(sha(p)==x['sha256'] for p,x in m['runtime_tools'].items()))
    check('controls_preserved',lambda:sha(__file__)==m['runner_sha256'] and sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and all(sha(p)==h for p,h in m['prerequisites'].items()))
    expected=('hw/afu.qsf','hw/afu_json_info.vh','hw/ia840f_ahls_memory.json','build/platform/platform_afu_top_config.vh','build/platform/platform_if_addenda.qsf')
    result['required_outputs']={n:(T/n).is_file() for n in expected}
    check('afu_uuid_header_matches',lambda:("128'h"+m['afu_uuid'].replace('-','_')) in (T/'hw/afu_json_info.vh').read_text())
    check('afu_json_matches',lambda:json.loads((T/'hw/ia840f_ahls_memory.json').read_text())==m['afu_json'])
    def source_selection():
        text=(T/'hw/afu.qsf').read_text();rows=[]
        for line in text.splitlines():
            match=re.match(r'\s*set_global_assignment\s+-name\s+(SYSTEMVERILOG_FILE|QIP_FILE)\s+(.+?)\s*$',line)
            if match:
                value=match.group(2).strip('"');rows.append({'kind':match.group(1),'path':value})
        expected_rows=[{'kind':'SYSTEMVERILOG_FILE','path':str(A/n)} for n in m['afu_source_order']]+[{'kind':'QIP_FILE','path':str(A/n)} for n in m['generated_qip_order']]
        result['actual_afu_qsf_selection']=rows
        return rows==expected_rows
    check('afu_source_selection_matches',source_selection)
    def static_binding():
        path='hw/lib/build/syn/board/ia840f/syn_top/ofs_top.qdb'
        return sha(T/'build/syn/board/ia840f/syn_top/ofs_top.qdb')==release[path]['sha256']
    check('static_qdb_matches',static_binding)
    result['persona_inventory']={};total=0
    if T.exists():
        for directory,dirs,files in os.walk(T,followlinks=False):
            for name in dirs+files:
                p=Path(directory)/name;rel=str(p.relative_to(T))
                if p.is_symlink():
                    resolved=p.resolve(strict=True);assert resolved.is_relative_to(T) or resolved.is_relative_to(A) or resolved.is_relative_to(REL),str(p)
                    result['persona_inventory'][rel]={'kind':'symlink','target':os.readlink(p),'resolved':str(resolved)}
                elif p.is_file():
                    total+=p.stat().st_size;assert total<8*1024**3
                    result['persona_inventory'][rel]={'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)}
            assert len(result['persona_inventory'])<10000
    result['diagnostics']=[]
    for p in R.glob('*.log'):
        if p.stat().st_size>m['log_limit_bytes']:result['diagnostics'].append({'file':p.name,'error':'log threshold exceeded'});continue
        for line_no,line in enumerate(p.read_text(errors='replace').splitlines(),1):
            if ERROR.search(line) or any(marker.decode() in line for marker in MARKERS):result['diagnostics'].append({'file':p.name,'line':line_no,'text':line})
    result['postflight_errors']=errors;result['log_hashes']={p.name:{'bytes':p.stat().st_size,'sha256':sha(p)} for p in R.glob('*.log')}
    flags=('release_preserved','fabric_originals_preserved','afu_inputs_preserved','setup_tools_preserved','runtime_tools_preserved','controls_preserved','afu_uuid_header_matches','afu_json_matches','afu_source_selection_matches','static_qdb_matches')
    return not errors and not result['diagnostics'] and all(result.get(k) is True for k in flags) and all(result['required_outputs'].values())


def run():
    assert len(sys.argv)==2;m,release,fabric=preflight(sys.argv[1]);R.mkdir(exist_ok=False)
    for n in ('home','tmp'):(R/n).mkdir()
    env={k:os.environ[k] for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER')}
    env.update(HOME=str(R/'home'),USER='uwb_student00',LOGNAME='uwb_student00',LANG='C',PATH=str(Q/'bin')+':'+str(Q/'sopc_builder/bin')+':/usr/bin:/bin',TMPDIR=str(R/'tmp'),QUARTUS_ROOTDIR_OVERRIDE=str(Q),QUARTUS_VERSION='26.1',QUARTUS_VERSION_MAJOR='26',OPAE_PLATFORM_ROOT=str(REL),OPAE_PLATFORM_FPGA_FAMILY=m['platform_family'],PYTHONDONTWRITEBYTECODE='1')
    assert 'OPAE_PLATFORM_GEN' not in env and 'BBS_LIB_PATH' not in env and 'OPAE_PLATFORM_DB_PATH' not in env and 'OPAE_AFU_TOP_IFC_DB_PATH' not in env
    result={'batch':BUFFER,'scope':'persona-file-setup-only','started':now(),'commands':[],'complete':False,'hardware_access':False,'hardware_ready':False,'manifest_sha256':sys.argv[1],'runner':identity(os.getpid()),'interface_uuid':m['interface_uuid'],'afu_uuid':m['afu_uuid'],'actual_acceptance':'pending setup/source/configuration review','resources':{'cpus':m['cpus'],'address_space_limit_bytes':m['address_space_limit_bytes'],'deadlines_seconds':m['deadlines_seconds']}}
    operation=R;J=R
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
                    rec['native_rc'] = 0 if label in ('version', 'setup') and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct CMake vendor target: zero propagates child zero; nonzero does not disclose individual vendor exit.'
                                                  if label in ('version', 'setup') else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']
    persist()
    try:
        args=['/usr/bin/cmake','-S',str(P/'runtime'),'-B',str(R/'cmake-build'),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DQUARTUS_ROOT='+str(Q),'-DRELEASE_ROOT='+str(REL),'-DAFU_SOURCES='+str(A),'-DPERSONA_TARGET='+str(T)]
        assert native('configure',args,m['deadlines_seconds']['configure'])==0
        assert native('version',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','version','--parallel','1'],m['deadlines_seconds']['version'])==0
        assert '26.1.1 Build 130' in (R/'version.log').read_text() and 'SC Pro Edition' in (R/'version.log').read_text()
        assert native('setup',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','persona_setup','--parallel','1'],m['deadlines_seconds']['setup'])==0
        result['complete']=True
    except BaseException as exc:result['error']=repr(exc)
    finally:
        try:ok=postflight(m,release,fabric,result)
        except BaseException as exc:ok=False;result['postflight_exception']=repr(exc)
        result['ended']=now();result['execution_clean']=result['complete'] and 'error' not in result and len(result['commands'])==3 and all(x.get('effective_rc')==0 for x in result['commands']) and ok
        persist()
        with (R/'result.json').open('x') as f:json.dump(result,f,indent=2)
        blob=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
        with (R/'result.json.gz').open('xb') as f:f.write(blob)
        subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
        print(json.dumps({'success':result['execution_clean'],'setup_result_acceptance':'pending','result_sha256':h,'commands':[(c['label'],c.get('cmake_rc'),c.get('effective_rc')) for c in result['commands']]},indent=2),flush=True)
    return 0 if result['execution_clean'] else 1


if __name__=='__main__':sys.exit(run())
