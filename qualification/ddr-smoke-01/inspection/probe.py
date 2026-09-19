#!/usr/bin/env python3
"""Read-only remote Python probes, exclusively in named tmux session."""
import base64, json, pathlib, shlex, subprocess, sys, time
HOST='uwb_student00@100.101.227.97'
SESSION='ia840f_mailbox_monitored_01'
ROOT='/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04'
def ssh(args):
    return subprocess.check_output(['ssh',HOST,shlex.join(['tmux']+args)], text=True)
def probe(code, outfile):
    prelude='import pathlib,json,hashlib,re,os\nr=pathlib.Path('+repr(ROOT)+')\n'
    body=base64.b64encode((prelude+code).encode()).decode()
    cmd='python3 -c '+shlex.quote('import base64;exec(base64.b64decode('+repr(body)+'))')+'; printf "\\nPROBE_FINISHED\\n"; read -r _'
    pane=ssh(['new-window','-d','-P','-F','#{pane_id}','-t',SESSION,'-n','ddr_readonly', 'bash -c '+shlex.quote(cmd)]).strip()
    try:
        for _ in range(120):
            data=ssh(['capture-pane','-p','-J','-S','-2000','-t',pane])
            if 'PROBE_FINISHED' in data: break
            time.sleep(1)
        else: raise RuntimeError('probe timeout')
        pathlib.Path(outfile).write_text(data)
        print(data)
    finally:
        ssh(['kill-pane','-t',pane])
if __name__=='__main__':
    probe(pathlib.Path(sys.argv[1]).read_text(),sys.argv[2])
