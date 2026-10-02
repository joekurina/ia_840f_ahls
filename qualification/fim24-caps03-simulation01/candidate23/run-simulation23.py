"""One source-bound migrated unit simulation; no FPGA/hardware access."""
import base64,datetime,gzip,hashlib,json,os,resource,re,shutil,signal,socket,subprocess,sys,time
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_simulation01');I=ROOT/'prepare10/inputs';P=ROOT/'control23';R=ROOT/'native01';TOOLS=Path('/opt/altera/25.1/questa_fe/linux_x86_64')
MANIFEST=P/'simulation-inputs.admitted.json';BUFFER='ia840f_fim24_caps03_simulation_native01_result'
MARKERS=(b'IA840F_GATE_REJECTED',b'Critical Warning (125091)')
ERROR=re.compile(r'\b(?:Error|Fatal)(?:\s+\([^)]*\))?\s*:|\bErrors:\s*[1-9]\d*',re.I)

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


def bind(root,entries):
    return all((root/n).is_file() and not (root/n).is_symlink() and (root/n).stat().st_size==m['bytes'] and sha(root/n)==m['sha256'] for n,m in entries.items())


def tools_bound(entries):
    for name,m in entries.items():
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
    assert m['scope']=='migrated-integrated-unit-simulation-only' and m['parent_execution_accepted'] is True and m['hardware_ready'] is False
    assert m['input_root']==str(I) and m['control_root']==str(P) and m['operation_root']==str(R)
    assert Path(__file__).resolve()==P/'runtime/run-simulation23.py' and sha(__file__)==m['runner_sha256']
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256']
    assert m['prerequisites'] and all(sha(path)==h for path,h in m['prerequisites'].items())
    assert sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256']
    prepared=json.loads(Path(m['prepared_metadata_file']).read_text())
    assert m['files']==prepared['files'] and m['originals']==prepared['originals'] and m['simulator_tools']==prepared['simulator_tools'] and m['runtime_tools']==prepared['runtime_tools']
    assert len(m['files'])==560 and bind(I,m['files']) and {str(p.relative_to(I)) for p in I.rglob('*') if p.is_file()}==set(m['files'])
    assert len(m['originals'])==542 and tools_bound(m['originals']) and len(m['simulator_tools'])==19 and tools_bound(m['simulator_tools']) and len(m['runtime_tools'])==3 and tools_bound(m['runtime_tools'])
    assert m['compile_order']==prepared['compile_order'] and len(m['compile_order'])==len(set(m['compile_order']))==458
    assert m['vlog_args']==prepared['vlog_args'] and m['vsim_runtime_plusargs']==prepared['vsim_runtime_plusargs']==[]
    assert m['expected_score']==prepared['expected_score']=={'cases':6,'elements':133,'copied_bytes':1600,'dma':30}
    assert sha(m['setup_result_file'])==m['setup_result_sha256'];s=json.loads(Path(m['setup_result_file']).read_text());assert s['execution_clean'] and s['interface_uuid']==m['interface_uuid'] and s['afu_uuid']==m['afu_uuid']
    assert sorted(os.sched_getaffinity(0))==m['cpus']==list(range(36)) and m['address_space_limit_bytes']==64*1024**3
    assert int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024>80_000_000_000
    assert shutil.disk_usage(ROOT).free>10_000_000_000 and all(os.environ.get(k) for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'))
    active=[]
    for p in Path('/proc').iterdir():
        if not p.name.isdigit():continue
        try:
            exe=os.readlink(p/'exe');cmd=(p/'cmdline').read_bytes()
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog','vopt','vlib','vdir')) or (Path(exe).name=='java' and b'/opt/altera/' in cmd):active.append({'pid':int(p.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    assert not R.exists() and not R.is_symlink()
    return m


def scoreboards(logs,expected):
    diagnostics=[]
    for name,text in logs.items():
        for i,line in enumerate(text.splitlines(),1):
            if ERROR.search(line) or any(marker.decode() in line for marker in MARKERS):diagnostics.append({'log':name,'line':i,'text':line})
    main=logs.get('vsim.log','');split=logs.get('split_fault.log','')
    found=re.findall(r'AHLS_PATH_UNIT_PASS cases=(\d+) elements=(\d+) copied_bytes=(\d+) dma=(\d+) checks=(\d+) mmio_reads=(\d+) mmio_writes=(\d+) bank0_W=(\d+) bank1_W=(\d+)',main)
    rows=[dict(zip(('cases','elements','copied_bytes','dma','checks','mmio_reads','mmio_writes','bank0_W','bank1_W'),map(int,row))) for row in found]
    split_count=split.count('PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1')
    reset_count=main.count('BANK1_RESET_INVALIDATION_PASS checks=1')
    good=not diagnostics and len(rows)==1 and all(rows[0][k]==v for k,v in expected.items()) and rows[0]['checks']>0 and split_count==1 and reset_count==1
    return {'pass':bool(good),'rows':rows,'split_marker_count':split_count,'reset_marker_count':reset_count,'diagnostic_errors':diagnostics}


def scoreboards_exact(logs,expected):
    """Count every marker-family occurrence and parse complete records."""
    fields={
        'AHLS_PATH_UNIT_PASS':('cases','elements','copied_bytes','dma','checks','mmio_reads','mmio_writes','bank0_W','bank1_W'),
        'BANK1_RESET_INVALIDATION_PASS':('checks',),
        'PAGE_SPLIT_ERROR_PASS':('native_AW','native_W','native_B','upstream_B','observed_split_errors'),
    }
    locations={'AHLS_PATH_UNIT_PASS':'vsim.log','BANK1_RESET_INVALIDATION_PASS':'vsim.log','PAGE_SPLIT_ERROR_PASS':'split_fault.log'}
    patterns={name:re.compile(r'(?:# )?'+re.escape(name)+''.join(' '+re.escape(field)+r'=([0-9]+)' for field in names)) for name,names in fields.items()}
    counts={name:0 for name in fields};parsed={name:[] for name in fields};records=[];record_errors=[];diagnostics=[]
    for log,text in logs.items():
        for line_number,line in enumerate(text.splitlines(),1):
            if ERROR.search(line) or any(marker.decode() in line for marker in MARKERS):diagnostics.append({'log':log,'line':line_number,'text':line})
            for name,names in fields.items():
                occurrences=line.count(name)
                if not occurrences:continue
                counts[name]+=occurrences
                record={'family':name,'log':log,'line':line_number,'text':line,'occurrences':occurrences};records.append(record)
                match=patterns[name].fullmatch(line)
                if occurrences!=1 or match is None or log!=locations[name]:
                    record_errors.append({**record,'error':'record multiplicity, grammar or log location invalid'});continue
                parsed[name].append(dict(zip(names,map(int,match.groups()))))
    main=parsed['AHLS_PATH_UNIT_PASS'];reset=parsed['BANK1_RESET_INVALIDATION_PASS'];split=parsed['PAGE_SPLIT_ERROR_PASS']
    cardinality=all(counts[name]==1 and len(parsed[name])==1 for name in fields)
    values=cardinality and all(main[0][key]==value for key,value in expected.items()) and main[0]['checks']>0 and reset[0]=={'checks':1} and split[0]=={'native_AW':2,'native_W':4,'native_B':2,'upstream_B':1,'observed_split_errors':1}
    return {'pass':bool(values and not record_errors and not diagnostics),'rows':main,'reset_rows':reset,'split_rows':split,'family_counts':counts,'records':records,'record_errors':record_errors,'reset_marker_count':counts['BANK1_RESET_INVALIDATION_PASS'],'split_marker_count':counts['PAGE_SPLIT_ERROR_PASS'],'diagnostic_errors':diagnostics}


def postflight(m,result):
    errors=[]
    def check(name,fn):
        try:result[name]=bool(fn())
        except Exception as exc:result[name]=False;errors.append({'check':name,'error':repr(exc)})
    check('staged_inputs_preserved',lambda:bind(I,m['files']))
    check('run_inputs_preserved',lambda:bind(R,m['files']))
    check('originals_preserved',lambda:tools_bound(m['originals']))
    check('simulator_tools_preserved',lambda:tools_bound(m['simulator_tools']))
    check('runtime_tools_preserved',lambda:tools_bound(m['runtime_tools']))
    check('controls_preserved',lambda:sha(__file__)==m['runner_sha256'] and sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256'] and all(sha(p)==h for p,h in m['prerequisites'].items()))
    check('setup_result_preserved',lambda:sha(m['setup_result_file'])==m['setup_result_sha256'])
    logs={};result['logs']={}
    for label in ('configure','version','vlib','vdir','vlog','vsim','split_fault'):
        p=R/(label+'.log')
        if not p.is_file():errors.append({'log':p.name,'error':'required log missing'});continue
        try:
            size=p.stat().st_size;assert size<=m['log_limit_bytes'];b=p.read_bytes();assert len(b)==size
            logs[p.name]=b.decode(errors='replace');result['logs'][p.name]={'bytes':size,'sha256':hashlib.sha256(b).hexdigest(),'text':logs[p.name]}
        except Exception as exc:errors.append({'log':p.name,'error':repr(exc)})
    result['functional']=scoreboards_exact(logs,m['expected_score'])
    check('version_matches',lambda:'Questa Intel FPGA Edition-64 vsim 2024.3 Simulator 2024.09 Sep 10 2024' in logs.get('version.log',''))
    result['postflight_errors']=errors
    flags=('staged_inputs_preserved','run_inputs_preserved','originals_preserved','simulator_tools_preserved','runtime_tools_preserved','controls_preserved','setup_result_preserved','version_matches')
    return not errors and all(result.get(k) is True for k in flags) and result['functional']['pass'] and len(logs)==7


def run():
    assert len(sys.argv)==2;m=preflight(sys.argv[1]);R.mkdir(exist_ok=False)
    result={'batch':BUFFER,'scope':'migrated-integrated-unit-simulation-only','started':now(),'commands':[],'complete':False,'hardware_access':False,'hardware_ready':False,'manifest_sha256':sys.argv[1],'runner':identity(os.getpid()),'interface_uuid':m['interface_uuid'],'afu_uuid':m['afu_uuid'],'result_acceptance':'pending native diagnostics/behavioral result review','resources':{'cpus':m['cpus'],'address_space_limit_bytes':m['address_space_limit_bytes'],'deadlines_seconds':m['deadlines_seconds']}}
    env={k:os.environ[k] for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER')}
    env.update(HOME=str(R/'home'),USER='uwb_student00',LOGNAME='uwb_student00',LANG='C',PATH=str(TOOLS)+':/usr/bin:/bin',TMPDIR=str(R/'tmp'),MODELSIM=str(R/'modelsim.ini'),PYTHONDONTWRITEBYTECODE='1')
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
                    rec['native_rc'] = 0 if label in ('version', 'vlib', 'vdir', 'vlog', 'vsim', 'split_fault') and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct CMake vendor target: zero propagates child zero; nonzero does not disclose individual vendor exit.'
                                                  if label in ('version', 'vlib', 'vdir', 'vlog', 'vsim', 'split_fault') else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']
    try:
        persist()
        for n in ('home','tmp'):(R/n).mkdir()
        for name,item in m['files'].items():
            p=R/name;p.parent.mkdir(parents=True,exist_ok=True)
            with p.open('xb') as f:f.write((I/name).read_bytes())
        assert bind(R,m['files'])
        args=['/usr/bin/cmake','-S',str(P/'runtime'),'-B',str(R/'cmake-build'),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DSIM_RUN_ROOT='+str(R)]
        assert native('configure',args,m['deadlines_seconds']['configure'])==0
        for label in ('version','vlib','vdir','vlog','vsim','split_fault'):
            assert native(label,['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target',label,'--parallel','1'],m['deadlines_seconds'][label])==0
            log=(R/(label+'.log')).read_text(errors='replace')
            assert not ERROR.search(log),label+' native diagnostic error'
            if label=='version':assert 'Questa Intel FPGA Edition-64 vsim 2024.3 Simulator 2024.09 Sep 10 2024' in log
        result['complete']=True
    except BaseException as exc:result['error']=repr(exc)
    finally:
        try:ok=postflight(m,result)
        except BaseException as exc:ok=False;result['postflight_exception']=repr(exc)
        result['ended']=now();result['execution_clean']=result['complete'] and 'error' not in result and len(result['commands'])==7 and all(c.get('effective_rc')==0 for c in result['commands']) and ok
        result['unit_pass']=result['execution_clean']
        persist()
        with (R/'result.json').open('x') as f:json.dump(result,f,indent=2)
        raw=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest()
        with (R/'result.json.gz').open('xb') as f:f.write(raw)
        subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
        print(json.dumps({'execution_clean':result['execution_clean'],'unit_pass':result['unit_pass'],'result_sha256':h,'commands':[(c['label'],c.get('cmake_rc'),c.get('effective_rc')) for c in result['commands']]},indent=2),flush=True)
    return 0 if result['execution_clean'] else 1


if __name__=='__main__':sys.exit(run())
