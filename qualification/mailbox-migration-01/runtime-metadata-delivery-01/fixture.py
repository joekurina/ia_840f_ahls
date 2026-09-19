"""Dedicated LOCAL synthetic tmux fixture, never a deployment controller."""
import hashlib
import json
import os
from pathlib import Path
import selectors
import shutil
import subprocess
import threading
import time
import delivery

ROOT=Path(__file__).absolute().parent
TOKEN='b'*32

def capture_worker(stdout, path, stop, errors, raw, clean):
    """Report every worker failure; clean is set only after successful cleanup."""
    import traceback
    sel = None
    clean.clear()
    try:
        sel = selectors.DefaultSelector()
        sel.register(stdout, selectors.EVENT_READ)
        with path.open('xb') as f:
            try:
                deadline = time.monotonic() + 90
                while not stop.is_set():
                    if time.monotonic() > deadline:
                        raise delivery.Incomplete('capture deadline')
                    for key, _ in sel.select(.05):
                        b = os.read(key.fd, 65536)
                        if not b: raise delivery.Incomplete('control disconnect')
                        # Keep bytes already read even if persistence fails.
                        raw.extend(b)
                        if f.write(b) != len(b): raise OSError('short capture write')
                        f.flush()
                        if len(raw) > delivery.RAW_CAP:
                            raise delivery.Incomplete('raw cap exceeded: incomplete prefix')
            except BaseException:
                # Preserve the body exception even if file close also fails.
                errors.append(traceback.format_exc())
    except BaseException:
        errors.append(traceback.format_exc())
    finally:
        if sel is not None:
            try: sel.close()
            except BaseException: errors.append(traceback.format_exc())
    if not errors: clean.set()


def require_clean_capture(thread, errors, clean):
    """A dead thread alone is not evidence of completed acquisition."""
    if thread.is_alive() or errors or not clean.is_set():
        raise delivery.Incomplete('capture failure/incomplete: ' + repr(errors))


def main():
    if not shutil.which('tmux'): raise SystemExit('BLOCKED: tmux unavailable; do not install')
    import sys
    if len(sys.argv)!=3 or sys.argv[2] not in ('emitter','reader') or not __import__('re').fullmatch('fixture-[0-9]{2}',sys.argv[1]):
        raise SystemExit('usage: fixture.py fixture-NN emitter|reader (new directory only)')
    mode=sys.argv[2]
    run=ROOT/sys.argv[1]; run.mkdir() # no overwrite or automatic retry
    directory=os.open(run,os.O_RDONLY|os.O_DIRECTORY)
    socket=f'/proc/{os.getpid()}/fd/{directory}/socket'
    base=['/usr/bin/tmux','-S',socket]
    log=[]; ctl=None; stop=threading.Event(); errors=[]; raw=bytearray(); thread=None
    clean=threading.Event()
    def invoke(args,**kw):
        p=subprocess.run(base+args,capture_output=True,timeout=10,**kw)
        log.append(dict(argv=base+args,status=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace')))
        if p.returncode: raise RuntimeError(log[-1])
        return p.stdout
    def capture():
        capture_worker(ctl.stdout, run/'control.raw', stop, errors, raw, clean)
    try:
        invoke(['-f','/dev/null','new-session','-d','-s','synthetic','/bin/bash --noprofile --norc'])
        pane=invoke(['display-message','-p','-t','synthetic','#{pane_id}']).decode().strip()
        parent=int(invoke(['display-message','-p','-t',pane,'#{pane_pid}']))
        before=invoke(['display-message','-p','-t',pane,'#{pane_tty}']).decode().strip()
        import termios
        tty=os.open(before,os.O_RDWR|os.O_NOCTTY)
        old=termios.tcgetattr(tty)
        ctl=subprocess.Popen(base+['-C','attach-session','-t','synthetic'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=(run/'control-client.stderr').open('xb'))
        log.append(dict(argv=base+['-C','attach-session','-t','synthetic']))
        thread=threading.Thread(target=capture);thread.start()
        start=time.monotonic()
        while b'%end ' not in raw:
            if time.monotonic()-start>5 or errors: raise delivery.Incomplete('attach incomplete: '+repr(errors))
            time.sleep(.01)
        # Fixed harmless emitter; a long physical source line challenges canonical input.
        # The source interpreter needs real pipe EOF before it executes this program.
        body=('import os,json,sys\n'
              'os.write(1,(json.dumps({"ppid":os.getppid(),"stdin_eof":os.read(0,1)==b""})+"\\n").encode())\n'
              'for i in range(12287):\n'
              ' os.write(1,bytes(range(256)))\n'
              ' os.write(2,bytes(reversed(range(256))))\n'
              'sys.exit(23)\n').encode()
        payload=body+b'#'+b'x'*(41045-len(body)-2)+b'\n'
        assert len(payload)==41045
        if mode=='reader': payload=(bytes(range(256))*161)[:41045]
        cmd=delivery.command(payload,TOKEN).encode()
        if mode=='reader':
            reader='import os,sys,hashlib,json; b=sys.stdin.buffer.read(); os.write(1,json.dumps(dict(length=len(b),sha256=hashlib.sha256(b).hexdigest(),ppid=os.getppid(),eof=os.read(0,1)==b"" )).encode()); os.write(2,bytes(range(256))); sys.exit(7)'
            cmd=cmd.replace(b' | /usr/bin/python3 -I -B -S - >&7',(' | '+delivery.py(reader)+' >&7').encode())
        (run/'synthetic.py.txt').write_bytes(payload)
        (run/'command.txt').write_bytes(cmd)
        invoke(['load-buffer','-b','synthetic','-'],input=cmd)
        invoke(['paste-buffer','-d','-r','-b','synthetic','-t',pane])
        result=None;start=time.monotonic()
        # Decode only after a candidate R marker arrives; complete LF is required.
        while time.monotonic()-start<75 and not errors:
            snapshot=bytes(raw)
            if ('D1 '+TOKEN+' R 0 0').encode() in snapshot:
                try: result=delivery.decode(snapshot,pane,TOKEN);break
                except delivery.Incomplete: pass
            time.sleep(.05)
        if result is None: raise delivery.Incomplete('incomplete capture: '+repr(errors))
        stop.set();thread.join(2)
        require_clean_capture(thread, errors, clean)
        # Final retained bytes, not an earlier snapshot.
        result=delivery.decode(bytes(raw),pane,TOKEN)
        restored=termios.tcgetattr(tty)==old;os.close(tty)
        if mode=='emitter':
            identity,content=result['stdout'].split(b'\n',1)
            assert json.loads(identity)=={'ppid':parent,'stdin_eof':True}
            assert content==bytes(range(256))*12287
            assert result['stderr']==bytes(reversed(range(256)))*12287
            assert result['status']==23 and restored
            assert len(raw)>3*1024*1024
        else:
            identity=result['stdout']
            assert json.loads(identity)==dict(length=len(payload),sha256=hashlib.sha256(payload).hexdigest(),ppid=parent,eof=True)
            assert result['stderr']==bytes(range(256)) and result['status']==7 and restored
        for name in ('stdout','stderr'): (run/(name+'.bin')).write_bytes(result[name])
        summary=dict(outcome='PASS_SYNTHETIC_ONLY',status=result['status'],parent_pid=parent,
            identity=json.loads(identity),termios_restored=restored,raw_length=len(raw),
            payload_length=len(payload),payload_sha256=hashlib.sha256(payload).hexdigest(),
            stdout_length=len(result['stdout']),stderr_length=len(result['stderr']),
            authorization=False,ready_for_build=False,vendor_run=False)
        (run/'result.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
    finally:
        stop.set()
        if thread: thread.join(2)
        # Only this fixture's owned client and server; never any default socket.
        if ctl:
            ctl.terminate()
            try: tail=ctl.communicate(timeout=5)[0]
            except subprocess.TimeoutExpired:
                ctl.kill();tail=ctl.communicate(timeout=5)[0]
            # Preserve unread shutdown bytes too; never feed a deliberately
            # terminated client's exit back as the Python command status.
            (run/'control-shutdown-tail.raw').write_bytes(tail)
            (run/'control-full.raw').write_bytes(bytes(raw)+tail)
        try:
            invoke(['kill-server'])
            # tmux can leave its socket inode when the /proc fd alias disappears.
            # Query ONLY this owned socket; never auto-create a server or retry work.
            check=subprocess.run(base+['list-sessions'],capture_output=True,timeout=5)
            log.append(dict(argv=base+['list-sessions'],status=check.returncode,stdout=check.stdout.decode(errors='replace'),stderr=check.stderr.decode(errors='replace')))
            if check.returncode==0: raise RuntimeError('owned server still active')
            import stat
            if (run/'socket').exists():
                if not stat.S_ISSOCK((run/'socket').lstat().st_mode): raise RuntimeError('unexpected socket type')
                (run/'socket').unlink()
        finally:
            (run/'commands.json').write_text(json.dumps(log,indent=2)+'\n')
            os.close(directory)

if __name__=='__main__':main()
