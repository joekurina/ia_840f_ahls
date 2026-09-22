import os,json,socket,subprocess,sys,importlib.util,hashlib,datetime
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-16');P=E/'compile-candidate-01'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
procs=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-')) for x in procs.splitlines()[1:]), 'competing native process'
mem=int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024
assert mem>=80000000000
accepted={'mode': 'user-directed-native-iteration', 'parent_acceptance_explicit': True, 'fresh_independent_spec_quality_claimed': False, 'package_manifest_sha256': '72608ade29133d3c559bb2b43b6b29cf1db08848e916ac796e63521f17f6ffd2', 'candidate_top_sdc_sha256': '3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814', 'iteration_authority_sha256': '9c9fb32bd84ac5e53ecd5559596614b096a752191af98c94c4928ef80d80f476', 'iteration_basis_sha256': '2480c02885bf5efb5b77365219ead533dad5962cad95d1cc808641c267448a58', 'parent_checks': {'all_prepared_members_match': True, 'both_gates_and_runner_mechanically_retargeted': True, 'contexts': 135, 'inputs': 5424, 'functional_delta': 'fitter-only exact EMIF1 clock pair additive hold/removal10ps; no final STA change', 'remote_nonconsuming_preflight': 'PASS', 'original_Work15_and_PIM_preserved': True, 'loaded_SDC_last_writer_check': '38file capture; late files no matching set/remove uncertainty or derive-overwrite; native retention/applicability remains experimental'}, 'ready_for_build': False, 'timing_accepted': False, 'hardware_qualified': False}
ap=E/'native-iteration-acceptance.json'
with ap.open('x') as f:json.dump(accepted,f,indent=2)
assert json.loads(ap.read_text())==accepted
spec=importlib.util.spec_from_file_location('issuer16',P/'issue_authorization.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.issue_native_iteration(str(ap))
record=E/'compile-authorization.json'
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],authorization_sha256=hashlib.sha256(record.read_bytes()).hexdigest(),mem_available_bytes=mem,native_started_at_receipt=False,runner=str(P/'launch_native_compile.py'))
b=(json.dumps(receipt,indent=2)+'\n').encode()
with (E/'issuance-receipt01.json').open('xb') as f:f.write(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim16_launch_receipt01','-'],input=b,check=True)
print('WORK16_ISSUED',json.dumps(receipt),flush=True)
os.chdir(P);os.execv('/usr/bin/python3',['python3','-B',str(P/'launch_native_compile.py')])
