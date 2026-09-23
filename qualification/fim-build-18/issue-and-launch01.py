import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-18');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '477ab2f713f2d9a7dad019a1b427dc32656fc6a48fc4bea20c7e22997e5a297e', 'candidate_top_sdc_sha256': '3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814', 'candidate_qsf_sha256': 'e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f', 'iteration_authority_sha256': '319534f5dab350b72988ca2fd0bee2fd901d3d803a5795f28a0925dc12e41383', 'iteration_basis_sha256': 'c0b6cb4521682fb3e15c038bef5f4e83b340c4de9d5f3192680910a4beecde3a', 'parent_checks': {'all_prepared_members_match': True, 'prepared_exports': 20, 'normalized_contexts': 135, 'copied_inputs': 5424, 'sole_configuration_delta': 'ALLOW_REGISTER_RETIMING OFF on exact EMIF1 amm_writedata_0_r[0][243] in WORK QSF', 'source_qsf_and_all_sdc_unchanged': True, 'source_gate_delta_only': True, 'native_nonconsuming_preflight': 'PASS', 'original_Work17_and_PIM_preserved': True, 'native_eligibility_result': 'synthesized exact singleton register; Agilex7 Fitter instance support; legal On/Off', 'user_direction': 'START QUARTUS AGAIN ASAP; no further prelaunch review', 'trial_not_validated_timing_fix': True}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim18_launch_receipt01','-'],input=b,check=True)
print('WORK18_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
