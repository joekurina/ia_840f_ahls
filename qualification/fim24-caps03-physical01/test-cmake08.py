"""CMake-only checks of exact candidate; never invoke a native design target."""
import base64,datetime,gzip,hashlib,json,os,resource,signal,socket,subprocess,time,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01');D=ROOT/'base01';R=ROOT/'cmake_checks08';J=R;operation=R;PROJECT=D/'build/syn/board/ia840f/syn_top';Q=Path('/opt/altera/26.1.1/quartus');BUFFER='ia840f_fim24_caps03_physical_cmake08_result';SOURCE='cmake_minimum_required(VERSION 3.16)\nproject(ia840f_migrated_persona_first_fit LANGUAGES NONE)\nset(PERSONA_PROJECT "" CACHE PATH "Prepared matching mapped-persona project")\nset(QUARTUS_ROOT "/opt/altera/26.1.1/quartus" CACHE PATH "Selected Quartus installation")\nif(NOT QUARTUS_ROOT STREQUAL "/opt/altera/26.1.1/quartus")\n  message(FATAL_ERROR "This qualification uses Quartus Pro 26.1.1")\nendif()\nif(NOT PERSONA_PROJECT STREQUAL "/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_physical01/base01/build/syn/board/ia840f/syn_top")\n  message(FATAL_ERROR "The exact fresh mapped project is required")\nendif()\nif(NOT EXISTS "${PERSONA_PROJECT}/ofs_pr_afu.qsf" OR NOT EXISTS "${PERSONA_PROJECT}/ofs_top.qdb" OR NOT IS_DIRECTORY "${PERSONA_PROJECT}/qdb")\n  message(FATAL_ERROR "A prepared PR project, static QDB and mapped database are required")\nendif()\nadd_custom_target(version\n  COMMAND "${QUARTUS_ROOT}/bin/quartus_fit" --version\n  WORKING_DIRECTORY "${PERSONA_PROJECT}"\n  VERBATIM USES_TERMINAL)\nadd_custom_target(fit\n  COMMAND "${QUARTUS_ROOT}/bin/quartus_fit"\n    --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu\n  WORKING_DIRECTORY "${PERSONA_PROJECT}"\n  VERBATIM USES_TERMINAL)\n';SOURCE_SHA='742c858135fd8fb15bed82a2590f1306a203ca8f62f380f4d5f6e583e10e6588'
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
                rec['native_rc'] = None
                rec['native_status_basis'] = 'CMake-only configure/help/dry-run/refusal check; no vendor tool invocation.'
                rec['effective_rc'] = 124 if timedout else (125 if rejected or log_bound_exceeded or residual_after else cmake_rc)
                persist()
    return rec['effective_rc']
def inventory(root):
 result={}
 for d,dirs,files in os.walk(root,followlinks=False):
  for n in dirs+files:
   p=Path(d)/n;rel=str(p.relative_to(root))
   if p.is_symlink():
    v={'kind':'symlink','target':os.readlink(p),'resolved':str(p.resolve(strict=True))}
    if p.is_file():v['sha256_of_target']=sha(p)
   elif p.is_file():v={'kind':'file','bytes':p.stat().st_size,'sha256':sha(p)}
   else:continue
   result[rel]=v
 return result
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
assert not R.exists() and not (ROOT/'fit01').exists()
assert hashlib.sha256(SOURCE.encode()).hexdigest()==SOURCE_SHA
meta=ROOT/'prepare03/prepared-copy03.json';assert sha(meta)=='8606a19ffab26f23caa5b8ee23bb51ecfab0aa3bdcc3e96898c30b5b5af818c5';prepared=json.loads(meta.read_text())
assert inventory(D)==prepared['copied_inventory']
for n,x in prepared['tools'].items():assert sha(n)==x['sha256']
R.mkdir();(R/'home').mkdir();(R/'tmp').mkdir();S=R/'source';S.mkdir();(S/'CMakeLists.txt').write_text(SOURCE)
m={'cpus':sorted(os.sched_getaffinity(0)),'address_space_limit_bytes':64*1024**3,'log_limit_bytes':2_000_000};assert m['cpus']==list(range(36))
env={'HOME':str(R/'home'),'USER':'uwb_student00','LOGNAME':'uwb_student00','LANG':'C','PATH':'/usr/bin:/bin','TMPDIR':str(R/'tmp')}
result={'batch':BUFFER,'started':now(),'commands':[],'success':False,'scope':'exact CMake configure/help/make-dry-run/refusal only; no vendor command executed','hardware_access':False,'native_design_executed':False,'cmake_sha256':SOURCE_SHA,'files':{}}
def persist():(R/'status.json').write_text(json.dumps(result,indent=2)+'\n')
def limits():
 os.sched_setaffinity(0,set(m['cpus']));resource.setrlimit(resource.RLIMIT_AS,(m['address_space_limit_bytes'],m['address_space_limit_bytes']));resource.setrlimit(resource.RLIMIT_CORE,(0,0))
try:
 def configure(path,project,qroot):return ['/usr/bin/cmake','-S',str(S),'-B',str(path),'-G','Unix Makefiles','-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DPERSONA_PROJECT='+str(project),'-DQUARTUS_ROOT='+str(qroot)]
 assert native('configure',configure(R/'build',PROJECT,Q),30)==0
 assert native('targets',['/usr/bin/cmake','--build',str(R/'build'),'--target','help'],30)==0
 assert native('fit_dry',['/usr/bin/cmake','--build',str(R/'build'),'--target','fit','--','--dry-run'],30)==0
 assert native('default_dry',['/usr/bin/cmake','--build',str(R/'build'),'--','--dry-run'],30)==0
 assert native('wrong_tool',configure(R/'wrong-tool',PROJECT,'/INERT/wrong'),30)!=0
 assert native('wrong_project',configure(R/'wrong-project','/INERT/wrong',Q),30)!=0
 helptext=(R/'targets.log').read_text();assert '... fit' in helptext and '... version' in helptext and all('... '+t not in helptext for t in ('synthesis','timing','assemble','program'))
 fittext=(R/'fit_dry.log').read_text();needle=str(Q/'bin/quartus_fit')+' --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu';assert needle in fittext and str(PROJECT) in fittext
 assert str(Q/'bin/quartus_fit') not in (R/'default_dry.log').read_text()
 assert 'This qualification uses Quartus Pro 26.1.1' in (R/'wrong_tool.log').read_text() and 'The exact fresh mapped project is required' in (R/'wrong_project.log').read_text()
 assert inventory(D)==prepared['copied_inventory'] and not (ROOT/'fit01').exists() and not list(PROJECT.glob('output_files/ofs_pr_afu.fit*'))
 result.update(success=True,case_count=6,prepared_copy_preserved=True,fit_operation_absent=True,printed_fit_argv=needle)
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 result['ended']=now()
 for n in ('configure.log','targets.log','fit_dry.log','default_dry.log','wrong_tool.log','wrong_project.log','source/CMakeLists.txt'):
  p=R/n
  if p.is_file():
   b=p.read_bytes();assert len(b)<2_000_000;result['files'][n]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 persist();raw=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(raw).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=raw,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True);print('CMAKE_CHECK08',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
