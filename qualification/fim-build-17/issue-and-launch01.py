import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-17');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '18df914b857a3bf02095708883840408ca6d4f85df74972a20e0de14f3a59c58', 'candidate_top_sdc_sha256': '3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814', 'candidate_qsf_sha256': '502f55c2eca4441d221851af3dce4431a63f10426a7477b73ec94724e62d3daa', 'iteration_authority_sha256': '2ea7db261b921abf7834c9aa9215bd29b6c1582040e763e003a61639bb98f966', 'iteration_basis_sha256': '372f01ca6198e227e76f6f5b802f4a56262865765e8c305e14ef9e2938006253', 'parent_checks': {'all_prepared_members_match': True, 'prepared_exports': 20, 'normalized_contexts': 135, 'copied_inputs': 5424, 'sole_configuration_delta': 'ENABLE_INTERMEDIATE_SNAPSHOTS ON in copied WORK QSF', 'source_qsf_and_all_sdc_unchanged': True, 'source_gate_delta_only': True, 'native_nonconsuming_preflight': 'PASS', 'original_Work16_and_PIM_preserved': True, 'next_recommendation_report_sha256': '15ab6ea050a36fc1b7ce0880ccfb5ace9319cd681ca6d64852c8a6c5cfae5cd1', 'diagnostic_only_not_timing_fix': True}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim17_launch_receipt01','-'],input=b,check=True)
print('WORK17_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
