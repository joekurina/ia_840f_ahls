import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-19');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '48e29ab6a297187061746f8d4b07b2caf4a1cada98f35f423425306f4a593f5c', 'candidate_top_sdc_sha256': '3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814', 'candidate_qsf_sha256': 'e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f', 'iteration_authority_sha256': '011c320baa7e25618430d31b78fb83ff37b68fbf6d171e637dfc0958586a27f4', 'iteration_basis_sha256': '10386045714569e1902283a9551def3252ab6f425e295f0ce6f128437563308c', 'parent_checks': {'all_prepared_members_match': True, 'copied_inputs': 5424, 'native_contexts': 135, 'original_Work18_and_PIM_preserved': True, 'SDC_QSF_unchanged': True, 'toolchain_only_experiment': True, 'installed_25_1_paths_and_flow_evidence_bound': True}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim19_launch_receipt01','-'],input=b,check=True)
print('WORK19_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
