import datetime,hashlib,json,os,socket,subprocess,sys,time
from pathlib import Path
RUN=Path(__file__).resolve().parent
OBSERVER=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/activation-pre43/runtime/ownership27.py')
OBSERVER_SHA='c120062efd638824d05f4495faf7e63634576744e3cc13f26aa0d3a2d12faf8c'
def sha(p):
    h = hashlib.sha256()
    with Path(p).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

def proc(pid):
    p = Path('/proc') / str(pid)
    s = (p / 'stat').read_text().rsplit(')', 1)[1].split()
    return {'pid': pid, 'ppid': int(s[1]), 'state': s[0], 'start_ticks': s[19],
            'exe': os.readlink(p / 'exe'), 'cwd': os.readlink(p / 'cwd'),
            'argv': (p / 'cmdline').read_bytes().decode().rstrip('\0').split('\0')}

def ownership():
    assert sha(OBSERVER) == OBSERVER_SHA
    z = subprocess.run(['sudo', '-n', '/usr/bin/python3', '-I', '-B', str(OBSERVER)],
                       capture_output=True, timeout=60)
    assert z.returncode == 0, z.stderr.decode(errors='replace')
    return json.loads(z.stdout)

def execute_once(name, argv, deadline_seconds, directory, env):
    result = {'argv': argv, 'utc_start': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'native_rc': None, 'execution_state': 'NOT_STARTED', 'retained_owner': False}
    child = None
    try:
        with (directory / (name + '.stdout')).open('xb', buffering=0) as out, \
             (directory / (name + '.stderr')).open('xb', buffering=0) as err:
            child = subprocess.Popen(argv, cwd=RUN, env=env, stdout=out, stderr=err,
                                     start_new_session=True)
            # Never signal this hardware process, including on bookkeeping failure.
            result['owner'] = proc(child.pid)
            (directory / (name + '-launch.json')).write_text(json.dumps(result, indent=2))
            deadline = time.monotonic() + deadline_seconds
            while time.monotonic() < deadline:
                rc = child.poll()
                if rc is not None:
                    result.update(native_rc=rc, execution_state='EXITED', retained_owner=False)
                    with (directory / (name + '-native-exit.json')).open('x') as receipt:
                        json.dump({'native_rc': rc, 'owner': result['owner']}, receipt, indent=2)
                    break
                current = proc(child.pid)
                if current['state'] == 'D':
                    # A sample is not a hang verdict. Observe this same owner
                    # within its original deadline; never start a replacement.
                    result['d_state_samples'] = result.get('d_state_samples', 0) + 1
                    result.setdefault('first_d_state_sample', current)
                    result['last_d_state_sample'] = current
                if current['state'] in ('T', 't'):
                    result.update(execution_state='RETAINED_' + current['state'],
                                  retained_owner=True, current_owner=current)
                    break
                time.sleep(0.1)
            else:
                result.update(execution_state='TIMEOUT_EXECUTION_UNKNOWN', retained_owner=True,
                              current_owner=proc(child.pid))
    except BaseException as exc:
        result['error'] = repr(exc)
        if child is not None and child.returncode is None:
            result.update(execution_state='BOOKKEEPING_FAILURE_EXECUTION_UNKNOWN', retained_owner=True,
                          pid=child.pid)
    result['utc_end'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
    for stream in ('stdout', 'stderr'):
        p = directory / (name + '.' + stream)
        if p.exists():
            result[stream] = {'bytes': p.stat().st_size, 'sha256': sha(p)}
    with (directory / (name + '-result.json')).open('x') as stream:
        json.dump(result, stream, indent=2)
    return result
def main():
 assert os.environ.get('TMUX') and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
 a_path=RUN/'host-only-approval10.json';assert len(sys.argv)==2 and sha(a_path)==sys.argv[1]
 a=json.loads(a_path.read_text());assert a['approved'] and sha(__file__)==a['runner_sha256']
 for p,h in a['files'].items():assert sha(p)==h,p
 prior=json.loads(Path(a['last_PR_result']).read_text());assert prior['load']['native_rc']==0 and prior['load_diagnostics_clean'] and prior['hosts'][0]['execution_state']=='EXITED' and prior['hosts'][0]['native_rc']==1
 before=ownership();assert before['boot_id']==a['expected_boot'] and not any(before[k] for k in ['holders','maps','errors','relevant_processes'])
 trial=RUN/'host-only-attempt10';trial.mkdir(exist_ok=False);(trial/'preflight.json').write_text(json.dumps(before,indent=2))
 env=dict(os.environ);env['LIBOPAE_CFGFILE']='/etc/opae/opae.cfg'
 host=execute_once('host',a['host_command'],60,trial,env)
 result={'scope':a['scope'],'success':False,'host':host,'no_PR_reload':True}
 after=ownership();result['postflight']=after
 out=(trial/'host.stdout').read_text();err=(trial/'host.stderr').read_bytes()
 result['success']=host['execution_state']=='EXITED' and host['native_rc']==0 and not err and a['required_marker'] in out and after['boot_id']==before['boot_id'] and not any(after[k] for k in ['holders','maps','errors','relevant_processes'])
 with (trial/'result.json').open('x') as f:json.dump(result,f,indent=2)
 print(json.dumps(result,indent=2),flush=True)
 return 0 if result['success'] else 1
if __name__=='__main__':sys.exit(main())
