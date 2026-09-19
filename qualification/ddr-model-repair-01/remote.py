import base64,pathlib,shlex,subprocess,sys,time,zlib,uuid
HOST='uwb_student00@100.101.227.97'; SESSION='ia840f_mailbox_monitored_01'
def ssh(a): return subprocess.check_output(['ssh',HOST,shlex.join(['tmux']+a)],text=True)
def run(code,out):
 payload=base64.b64encode(zlib.compress(code.encode())).decode();buf='ddr_repair_'+uuid.uuid4().hex
 wrapper="import base64,io,contextlib,traceback,zlib,subprocess; s=io.StringIO()\nwith contextlib.redirect_stdout(s),contextlib.redirect_stderr(s):\n try: exec(zlib.decompress(base64.b64decode("+repr(payload)+")),{})\n except: traceback.print_exc()\nsubprocess.run(['tmux','load-buffer','-b',"+repr(buf)+",'-'],input=base64.b64encode(zlib.compress(s.getvalue().encode())),check=True)\nprint('RESULT_END')"
 cmd='python3 -u -c '+shlex.quote(wrapper)+'; read -r _'
 pane=ssh(['new-window','-d','-P','-F','#{pane_id}','-t',SESSION,'-n','ddr_model_repair','bash -c '+shlex.quote(cmd)]).strip()
 print('pane',pane,flush=True);done=False
 try:
  for _ in range(1200):
   data=ssh(['capture-pane','-p','-J','-S','-100','-t',pane])
   if 'RESULT_END' in data:
    done=True;data=zlib.decompress(base64.b64decode(ssh(['show-buffer','-b',buf]))).decode();pathlib.Path(out).write_text(data);print(data);return
   time.sleep(2)
  raise RuntimeError('timeout; pane preserved '+pane)
 finally:
  if done: ssh(['delete-buffer','-b',buf]);ssh(['kill-pane','-t',pane])
if __name__=='__main__':run(pathlib.Path(sys.argv[1]).read_text(),sys.argv[2])
