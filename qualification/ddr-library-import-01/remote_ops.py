import subprocess,shlex,base64,time,pathlib
ROOT=pathlib.Path(__file__).parent
HOST='uwb_student00@100.101.227.97'
SESSION='ia840f_mailbox_monitored_01'
def remote(code,name='inspect',wait=2):
    (ROOT/(name+'.py')).write_text(code)
    payload=base64.b64encode(code.encode()).decode()
    cmd='python3 -c '+shlex.quote('import base64;exec(base64.b64decode('+repr(payload)+'))')+'; exec bash'
    win=subprocess.check_output(['ssh',HOST,'tmux new-window -d -P -F '+shlex.quote('#{pane_id}')+' -t '+SESSION+' -n libimport-'+name+' '+shlex.quote(cmd)],text=True).strip()
    time.sleep(wait)
    text=subprocess.check_output(['ssh',HOST,'tmux capture-pane -p -J -S - -t '+shlex.quote(win)],text=True)
    (ROOT/(name+'.txt')).write_text(text)
    print('PANE',win);print(text)
    return win
if __name__=='__main__':
    import sys
    remote(pathlib.Path(sys.argv[1]).read_text(),sys.argv[2],float(sys.argv[3]) if len(sys.argv)>3 else 2)
