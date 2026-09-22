from pathlib import Path
import os,socket,json,subprocess,signal,datetime
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01')
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
claim=json.loads((E/'query.claim').read_text());assert claim=={'argv': ['python3', '-B', '/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01/run-query.py'], 'cwd': '/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/plan-diagnostic01', 'exe': '/usr/bin/python3.9', 'pid': 36061, 'ppid': 36034, 'start_ticks': '6963733'}
assert json.loads((E/'native-process.json').read_text())['pid']==36100
receipt={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'reason':'gate rejected mutable message database; stop this diagnostic, no result acceptance','pid':36100,'expected_start_ticks':'6964709','method':'pidfd SIGTERM to exact owned Fitter; existing supervisor owns descendant drainage'}
with (E/'parent-stop-request01.json').open('x') as f:
 try:
  fd=os.pidfd_open(36100)
  try:
   p=Path('/proc')/str(36100);st=(p/'stat').read_text().rsplit(')',1)[1].split()
   assert st[19]=='6964709' and int(st[1])==claim['pid']
   assert str((p/'exe').resolve())=='/opt/altera/26.1.1/quartus/linux64/quartus_fit'
   assert str((p/'cwd').resolve())==str(E/'scratch/syn/board/ia840f/syn_top')
   signal.pidfd_send_signal(fd,signal.SIGTERM,None,0);receipt['signal_sent']=True
  finally:os.close(fd)
 except ProcessLookupError:receipt['already_exited']=True
 json.dump(receipt,f,indent=2)
blob=json.dumps(receipt,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b','ia840f_emif_plan01_stop01','-'],input=blob,check=True)
print('EMIF_PLAN_STOP01',json.dumps(receipt),flush=True)
