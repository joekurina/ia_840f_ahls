"""Run narrow Python operations only inside the owned remote tmux session."""
import base64, gzip, shlex, subprocess, sys, time
from pathlib import Path
HOST='uwb_student00@100.101.227.97'
SESSION='ia840f_mailbox_monitored_01'
def run(code, label, timeout=120):
    prefix="import os,socket\nassert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000\n"
    payload=base64.b64encode(gzip.compress((prefix+code).encode())).decode()
    remote='/tmp/ia840f-fim05-'+label+'.log'
    done=remote+'.done'
    command="python3 -c "+shlex.quote("import base64,gzip; exec(gzip.decompress(base64.b64decode("+repr(payload)+")))")
    if len(command) > 16000:
        buffer = 'fim05-code-' + label
        subprocess.run(['ssh','-o','BatchMode=yes',HOST,'tmux load-buffer -b '+shlex.quote(buffer)+' -'], input=(prefix+code).encode(), check=True)
        command = 'python3 -c ' + shlex.quote('import subprocess; exec(subprocess.check_output('+repr(['tmux','save-buffer','-b',buffer,'-'])+'))')
    shell=command+' >'+shlex.quote(remote)+' 2>&1; rc=$?; tmux load-buffer -b '+shlex.quote('fim05-'+label)+' '+shlex.quote(remote)+'; tmux wait-for -S '+shlex.quote('fim05-'+label)+'; exit $rc'
    subprocess.run(['ssh','-o','BatchMode=yes',HOST,'tmux new-window -d -t '+SESSION+' -n '+shlex.quote('fim05-'+label)+' '+shlex.quote('bash --noprofile --norc -c '+shlex.quote(shell))],check=True)
    subprocess.run(['ssh','-o','BatchMode=yes',HOST,'tmux wait-for '+shlex.quote('fim05-'+label)],check=True,timeout=timeout)
    result=subprocess.run(['ssh','-o','BatchMode=yes',HOST,'tmux save-buffer -b '+shlex.quote('fim05-'+label)+' -'],check=True,capture_output=True)
    Path(__file__).with_name(label+'-remote.log').write_bytes(result.stdout)
    print(result.stdout.decode())
if __name__=='__main__':
    run(Path(sys.argv[1]).read_text(),sys.argv[2])
