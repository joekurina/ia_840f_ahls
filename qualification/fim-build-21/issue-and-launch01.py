import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-21');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '1e483811bca664e2c9c05b9de7d484a54db97c378096a45ed9fcfea735e97c06', 'candidate_top_sdc_sha256': '3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814', 'candidate_qsf_sha256': 'e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f', 'iteration_authority_sha256': 'df0a7bb1e3313ae5c87bbe60a02195f48edeb3a38625aa3f7dfb7d3be9a64ebe', 'iteration_basis_sha256': '3004e45800601974b9fa1e796ed22579bea7783287009880feeef4dd354533fe', 'parent_checks': {'all_prepared_members_match': True, 'copied_inputs': 5415, 'native_contexts': 135, 'original_Work18_Work20_and_PIM_preserved': True, 'SDC_QSF_unchanged': True, 'source_delta': '2 mechanically retargeted execution guards; existing Python fixes retained', 'work_debug_replacement': {'before_files': 22, 'after_files': 13, 'generation_sha256': 'c3e4b9ac9dbed00008264bd96077f1a205b6dd197308819905d87093ee0d5ae4'}, 'native_tools_executed_during_preparation': False}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim21_launch_receipt01','-'],input=b,check=True)
print('WORK21_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
