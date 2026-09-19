"""Owned local PTY/bash fixture. Never tmux, network, or production payloads."""
import errno
import hashlib
import json
import os
from pathlib import Path
import pty
import select
import subprocess
import termios
import time
import startup

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT.parent/'runtime-metadata-delivery-01'/'delivery.py'
# Load only the inert sibling generator/decoder, never its fixture or transport.
ns = {'__name__': 'immutable_decoder'}
exec(compile(SOURCE.read_bytes(),str(SOURCE),'exec'), ns)
Incomplete = ns['Incomplete']


def decode(data, token):
    escaped = b''.join(bytes([b]) if 32 <= b < 127 and b != 92 else ('\\%03o'%b).encode() for b in data)
    return ns['decode'](b'%output %0 '+escaped+b'\n', '%0', token)


def run(name, payload, token, faults):
    # Only this fixed harmless program family is allowed by the fixture.
    if not payload.startswith(b'import os,sys,json\n') or b'os.write' not in payload:
        raise ValueError('synthetic emitter only')
    out = Path(os.environ['HS_EVIDENCE'])/name
    out.mkdir()
    command = startup.command(payload,token,faults)
    script = ("trap ':' USR1\nbuiltin printf 'BEFORE_TRAP\\n'; trap -p USR1\n"+command+
              "builtin printf 'AFTER_TRAP\\n'; trap -p USR1\nbuiltin printf 'FIXTURE_END\\n'\n")
    (out/'command.txt').write_text(command)
    (out/'fixture-shell.txt').write_text(script)
    (out/'synthetic.py.txt').write_bytes(payload)
    master, slave = pty.openpty()
    before = termios.tcgetattr(slave)
    p = None
    raw = bytearray()
    try:
        argv = ['/bin/bash','--noprofile','--norc']
        with (out/'fixture-shell.txt').open('rb') as script_in:
            p = subprocess.Popen(argv,stdin=script_in,stdout=slave,stderr=slave,close_fds=True)
        deadline = time.monotonic()+22
        while True:
            if time.monotonic()>deadline: raise RuntimeError('synthetic fixture timeout')
            if select.select([master],[],[],.05)[0]:
                raw.extend(os.read(master,65536))
            elif p.poll() is not None: break
        status = p.wait(timeout=2)
        after = termios.tcgetattr(slave)
        normalized = bytes(raw).replace(b'\r\n',b'\n')
        traps_before = normalized.split(b'BEFORE_TRAP\n',1)[1].split(b'\n',1)[0]
        traps_after = normalized.split(b'AFTER_TRAP\n',1)[1].split(b'\n',1)[0]
        result = dict(pid=p.pid,exit=status,restored=after==before,argv=argv,
                      raw_sha256=hashlib.sha256(raw).hexdigest(),raw_length=len(raw),
                      payload_sha256=hashlib.sha256(payload).hexdigest(),
                      faults=faults,authorization=False,ready_for_build=False,vendor_run=False,remote_execution=False)
        (out/'result.json').write_text(json.dumps(result,indent=2)+'\n')
        return dict(result,raw=bytes(raw),traps_before=traps_before,traps_after=traps_after)
    finally:
        # Exact Popen-owned bash only, no process group; a stuck helper is not
        # claimed cleaned by this fallback. Normal tests must never use it.
        forced = p is not None and p.poll() is None
        if forced:
            p.kill()
            p.wait(timeout=2)
        (out/'raw.bin').write_bytes(raw)
        termios.tcsetattr(slave,termios.TCSANOW,before)
        os.close(master)
        os.close(slave)
        (out/'fixture-cleanup.json').write_text(json.dumps(dict(forced_bash_kill=forced,pty_closed=True,local_fixture_termios_reset=True))+'\n')
