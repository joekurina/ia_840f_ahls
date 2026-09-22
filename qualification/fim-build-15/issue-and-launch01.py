import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-15');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '3f8ce25ae9a62d75e9ab80f41db0c43152ea42135c58a82b17e7dc324b6fe317', 'candidate_top_sdc_sha256': 'b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc', 'iteration_authority_sha256': '5be9826990314928d7f78635fa997492aac3dda9ec3dea32d265d88d9421552c', 'native_result_acceptance_sha256': 'c63b48b504462f95b5d2ec0d236d3cc413fc2246ce91c4bb0d77124e5dedd50d', 'parent_checks': {'all_prepared_members_match': True, 'both_gates_mechanically_retargeted': True, 'contexts': 135, 'inputs': 5424, 'functional_delta': 'only native-supported generated-clock declaration; all exceptions unchanged', 'remote_nonconsuming_preflight': 'PASS', 'original_Work14_and_PIM_preserved': True}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer15',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim15_launch_receipt01','-'],input=b,check=True)
print('WORK15_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
