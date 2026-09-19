from pathlib import Path
import os,socket,json,hashlib,subprocess
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';P=B/'qualification/fim-build-09'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert not (B/'work_ia840f_fim_10').exists() and not (B/'qualification/fim-build-10').exists()
print('INSTRUCTIONS',Path('/home/uwb_student00/quartus_26/instructions.md').read_text())
expected=json.loads((P/'overlay-sha256.json').read_text())
actual={r:sha(C/r) for r in expected};assert actual==expected,(actual,expected)
assert actual['syn/board/ia840f/syn_top/ofs_top.qsf']=='ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3'
print('SOURCE',json.dumps(actual,indent=2))
print('HELPERS',json.dumps({n:sha(P/n) for n in ['stage_remote.py','prepare_handoff_remote.py','issue_authorization.py','launch_native_compile.py','test_real_dispatch.py']},indent=2))
print('PREFLIGHT PASS')
