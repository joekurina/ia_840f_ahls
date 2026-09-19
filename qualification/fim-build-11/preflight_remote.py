from pathlib import Path
import os,socket,json,hashlib,subprocess
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';P=B/'qualification/fim-build-10'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not (B/'work_ia840f_fim_11').exists() and not (B/'qualification/fim-build-11').exists()
print('INSTRUCTIONS',Path('/home/uwb_student00/quartus_26/instructions.md').read_text())
expected=json.loads((P/'overlay-sha256.json').read_text())
actual={r:sha(C/r) for r in expected};assert actual==expected,(actual,expected)
assert actual['syn/board/ia840f/syn_top/ofs_top.qsf']=='35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293'
print('SOURCE',json.dumps(actual,indent=2))
print('HELPERS',json.dumps({n:sha(P/n) for n in ['stage_remote.py','prepare_handoff_remote.py','issue_authorization.py','launch_native_compile.py','test_real_dispatch.py']},indent=2))
print('PREFLIGHT PASS')
