"""Single-use CMake-native migrated CAPS03 fabric generation."""
import base64,datetime,gzip,hashlib,json,os,resource,re,shutil,signal,socket,subprocess,sys,time,xml.etree.ElementTree as ET
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');ROOT=B/'work_fim24_caps03_fabric01';G=ROOT/'generate01';D=G/'mmhost_ia840f.report.prj';P=ROOT/'prepare08';R=ROOT/'native01';Q=Path('/opt/altera/26.1.1/quartus');S=B/'work_ahls_memory_01/build/mmhost_ia840f.report.prj';REL=B/'work_fim24_pr_platform01/release01'
MANIFEST=P/'fabric-inputs.admitted.json';BUFFER='ia840f_fim24_caps03_fabric_native15_result'
MARKERS=(b'IA840F_GATE_REJECTED',b'Critical Warning (125091)')
ERROR_PATTERN=re.compile(r'\b(?:Error|Fatal)(?:\s+\([^)]*\))?\s*:',re.I)
INTERFACES={'clock_reset','clock_reset_reset','mmio_control','dma_csr','dma_ddr_in0','dma_ddr_in1','bank_out0','bank_out1','kernel_irqs','freeze','device_exception_bus'}


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


def verify_files(root,entries):
    return all((root/n).is_file() and (root/n).stat().st_size==item['bytes'] and sha(root/n)==item['sha256'] for n,item in entries.items())


def verify_release(m,release):
    for name,item in release.items():
        path=REL/name
        if item['kind']=='file':
            if not path.is_file() or path.stat().st_size!=item['bytes'] or sha(path)!=item['sha256']:return False
        elif item['kind']=='symlink':
            if not path.is_symlink() or os.readlink(path)!=item['target']:return False
        else:return False
    return (REL/'hw/lib/fme-ifc-id.txt').read_text().strip()==m['interface_uuid']


def preflight(expected):
    assert __debug__ and re.fullmatch(r'[0-9a-f]{64}',expected)
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert sha(MANIFEST)==expected;m=json.loads(MANIFEST.read_text())
    assert m['scope']=='fabric-import-generate-only' and m['parent_execution_accepted'] is True and m['hardware_ready'] is False
    assert m['part']=='AGFB027R25A2E2V' and m['toolchain']=='Quartus Prime Pro 26.1.1 Build 130'
    for key,path in [('generation_root',G),('report_copy',D),('prepared_root',P),('operation_root',R),('report_source',S),('release_root',REL)]:assert m[key]==str(path),key
    assert Path(__file__).resolve()==P/'runtime/run-fabric08.py' and sha(__file__)==m['runner_sha256']
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256']
    assert m['prerequisites'] and all(sha(path)==h for path,h in m['prerequisites'].items())
    assert len(m['prepared_inputs'])==228 and len(m['original_report_inventory'])==224 and len(m['current_hls'])==155
    assert verify_files(S,m['original_report_inventory']) and verify_files(G,m['prepared_inputs'])
    assert {str(p.relative_to(G)) for p in G.rglob('*') if p.is_file()}==set(m['prepared_inputs'])
    assert all(sha(path)==item['sha256'] for path,item in m['tools'].items())
    assert all(sha(path)==item['sha256'] for path,item in m['vendor_sources'].items())
    raw=Path(m['release_result_file']).read_bytes();assert hashlib.sha256(raw).hexdigest()==m['release_result_sha256'];release=json.loads(raw)['release_inventory']
    assert len(release)==3454 and verify_release(m,release)
    assert sorted(os.sched_getaffinity(0))==m['cpus'] and len(m['cpus'])==36 and m['address_space_limit_bytes']==64*1024**3
    assert int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024>80_000_000_000
    assert shutil.disk_usage(ROOT).free>5_000_000_000
    assert all(os.environ.get(k) for k in ('LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER'))
    active=[]
    for entry in Path('/proc').iterdir():
        if not entry.name.isdigit():continue
        try:
            exe=os.readlink(entry/'exe');cmd=(entry/'cmdline').read_bytes()
            if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vlog','vsim')) or (Path(exe).name=='java' and b'/opt/altera/' in cmd):active.append({'pid':int(entry.name),'exe':exe})
        except (FileNotFoundError,ProcessLookupError,PermissionError):pass
    assert not active,active
    assert not R.exists() and not R.is_symlink() and not (G/'ahls_memory_dma_fabric.qsys').exists() and not (G/'ip').exists()
    return m,release


def child_ip_errors():
    paths=sorted((G/'ip').rglob('*.ip'));assert 0<len(paths)<=128,'missing/unbounded child IP metadata'
    rows=[]
    for p in paths:
        assert p.stat().st_size<16*1024**2
        tree=ET.fromstring(p.read_bytes());flags=[x.text for x in tree.iter() if x.tag.rsplit('}',1)[-1]=='altera_has_errors']
        assert flags and all(v=='false' for v in flags),(str(p),flags)
        rows.append({'path':str(p.relative_to(G)),'sha256':sha(p),'altera_has_errors':flags})
    return rows


def scan_logs(limit):
    bad=[]
    for p in R.glob('*.log'):
        if p.stat().st_size>limit:bad.append({'file':p.name,'error':'log threshold exceeded; full text not read'});continue
        for i,line in enumerate(p.read_text(errors='replace').splitlines(),1):
            if ERROR_PATTERN.search(line) or any(marker.decode() in line for marker in MARKERS):bad.append({'file':p.name,'line':i,'text':line})
    return bad


def postflight(m,release,result):
    errors=[]
    def check(name,fn):
        try:result[name]=bool(fn())
        except Exception as exc:result[name]=False;errors.append({'check':name,'error':repr(exc)})
    copied={n:item for n,item in m['prepared_inputs'].items() if n.startswith('mmhost_ia840f.report.prj/')}
    scripts={n:item for n,item in m['prepared_inputs'].items() if n.endswith('.tcl')}
    check('original_report_preserved',lambda:verify_files(S,m['original_report_inventory']))
    check('copied_corrected_report_preserved',lambda:verify_files(G,copied))
    check('composition_and_system_scripts_preserved',lambda:verify_files(G,scripts))
    check('tools_vendor_sources_preserved',lambda:all(sha(p)==x['sha256'] for p,x in list(m['tools'].items())+list(m['vendor_sources'].items())))
    check('accepted_release_preserved',lambda:verify_release(m,release))
    check('control_files_preserved',lambda:sha(__file__)==m['runner_sha256'] and sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256'] and all(sha(p)==h for p,h in m['prerequisites'].items()))
    result['native_project_metadata_delta']={}
    for name in ('ahls_memory_dma_fabric.qpf','ahls_memory_dma_fabric.qsf'):
        p=G/name
        if not p.is_file():errors.append({'check':'project_metadata_missing','path':str(p)});continue
        digest=sha(p)
        if digest!=m['prepared_inputs'][name]['sha256']:result['native_project_metadata_delta'][name]={'before_sha256':m['prepared_inputs'][name]['sha256'],'after_sha256':digest,'after_text':p.read_text()}
    def project_identity():
        qsf=(G/'ahls_memory_dma_fabric.qsf').read_text()
        return all(line in qsf for line in ('set_global_assignment -name FAMILY "Agilex 7"','set_global_assignment -name DEVICE AGFB027R25A2E2V','set_global_assignment -name TOP_LEVEL_ENTITY ahls_memory_dma_fabric','set_global_assignment -name NUM_PARALLEL_PROCESSORS 36'))
    check('project_identity_preserved',project_identity)
    hbase=G/'ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth'
    check('corrected_hls_generated_unchanged',lambda:all((hbase/n).is_file() and sha(hbase/n)==item['current_sha256'] for n,item in m['current_hls'].items()))
    outputs=('ahls_memory_dma_fabric.qsys','ahls_memory_dma_fabric/ahls_memory_dma_fabric.qip','ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/ahls_memory_dma_fabric_fabric.qip')
    result['expected_outputs']={n:(G/n).is_file() and (G/n).stat().st_size>0 for n in outputs}
    try:result['generated_child_metadata']=child_ip_errors()
    except Exception as exc:errors.append({'check':'generated_child_metadata','error':repr(exc)})
    result['generated_inventory']={};total=0
    for p in G.rglob('*'):
        if not p.is_file() or p.is_relative_to(D):continue
        total+=p.stat().st_size;assert total<8*1024**3 and len(result['generated_inventory'])<20000
        result['generated_inventory'][str(p.relative_to(G))]={'bytes':p.stat().st_size,'sha256':sha(p)}
    result['diagnostics']=scan_logs(m['log_limit_bytes']);result['postflight_errors']=errors
    result['log_hashes']={p.name:{'bytes':p.stat().st_size,'sha256':sha(p)} for p in R.glob('*.log')}
    required=('original_report_preserved','copied_corrected_report_preserved','composition_and_system_scripts_preserved','tools_vendor_sources_preserved','accepted_release_preserved','control_files_preserved','project_identity_preserved','corrected_hls_generated_unchanged')
    return not errors and not result['diagnostics'] and all(result.get(k) is True for k in required) and all(result['expected_outputs'].values())


def run():
    assert len(sys.argv)==2;m,release=preflight(sys.argv[1])
    R.mkdir(exist_ok=False)
    for name in ('home','tmp'):(R/name).mkdir()
    env={k:v for k,v in os.environ.items() if not k.startswith(('IA840F_','OFS_')) and k not in ('LD_LIBRARY_PATH','PYTHONPATH','PYTHONOPTIMIZE','QUARTUS_ROOTDIR','QUARTUS_ROOTDIR_OVERRIDE','OPAE_PLATFORM_GEN','BBS_LIB_PATH','BUILD_VAR_SETUP_COMPLETE','BUILD_ROOT_REL_PRINTED','PR_COMPILE','AFU_WITH_PIM')}
    env.update(HOME=str(R/'home'),TMPDIR=str(R/'tmp'),QUARTUS_ROOTDIR_OVERRIDE=str(Q),PATH=str(Q/'sopc_builder/bin')+':'+str(Q/'bin')+':/usr/local/bin:/usr/bin:/bin',LANG='C',PYTHONDONTWRITEBYTECODE='1')
    result={'batch':BUFFER,'started':now(),'scope':'fabric-import-generate-only','hardware_access':False,'hardware_ready':False,'manifest_sha256':sys.argv[1],'runner':identity(os.getpid()),'commands':[],'complete':False,'generated_acceptance':'pending actual footprint/closure/simulation review','resources':{'cpus':m['cpus'],'address_space_limit_bytes':m['address_space_limit_bytes'],'deadlines_seconds':m['deadlines_seconds']}}
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
                    rec['native_rc'] = 0 if label in ('version', 'import', 'generate') and cmake_rc == 0 else None
                    rec['native_status_basis'] = ('Direct CMake vendor target: zero propagates child zero; nonzero does not disclose individual vendor exit.'
                                                  if label in ('version', 'import', 'generate') else 'CMake configure only; no vendor tool invoked.')
                    rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                    persist()
        return rec['effective_rc']
    persist()
    try:
        cfg=['/usr/bin/cmake','-S',str(P/'runtime'),'-B',str(R/'cmake-build'),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DQUARTUS_ROOT='+str(Q),'-DFABRIC_ROOT='+str(G)]
        assert native('configure',cfg,m['deadlines_seconds']['configure'])==0,'configure failed'
        assert native('version',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','version','--parallel','1'],m['deadlines_seconds']['version'])==0,'version failed'
        assert '26.1.1 Build 130' in (R/'version.log').read_text() and 'SC Pro Edition' in (R/'version.log').read_text()
        assert native('import',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','fabric_import','--parallel','1'],m['deadlines_seconds']['import'])==0,'import failed'
        log=(R/'import.log').read_text(errors='replace');assert not scan_logs(m['log_limit_bytes']) and all(x in log for x in ('PD_VALIDATE_OK','PD_IMPORT_COMPLETE'))
        rows=re.findall(r'FABRIC_INTERFACES=([^\r\n]+)',log);assert len(rows)==1 and set(rows[0].split())==INTERFACES and len(rows[0].split())==len(INTERFACES)
        result['import_interface_names']=rows[0].split();result['import_child_metadata']=child_ip_errors();persist()
        assert native('generate',['/usr/bin/cmake','--build',str(R/'cmake-build'),'--target','fabric_generate','--parallel','1'],m['deadlines_seconds']['generate'])==0,'generate failed'
        result['complete']=True
    except BaseException as exc:result['error']=repr(exc)
    finally:
        try:ok=postflight(m,release,result)
        except BaseException as exc:ok=False;result['postflight_exception']=repr(exc)
        result['ended']=now();result['execution_clean']=result['complete'] and 'error' not in result and len(result['commands'])==4 and all(c.get('effective_rc')==0 for c in result['commands']) and ok
        persist()
        with (R/'result.json').open('x') as f:json.dump(result,f,indent=2)
        blob=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
        with (R/'result.json.gz').open('xb') as f:f.write(blob)
        subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
        print(json.dumps({'success':result['execution_clean'],'native_result_acceptance':'pending','result_sha256':h,'commands':[(c['label'],c.get('cmake_rc'),c.get('effective_rc')) for c in result['commands']]},indent=2),flush=True)
    return 0 if result['execution_clean'] else 1


if __name__=='__main__':sys.exit(run())
