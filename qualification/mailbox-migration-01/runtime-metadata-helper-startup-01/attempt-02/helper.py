"""Embedded cooperative helper, not a payload launcher. No filesystem writes."""
import base64
import fcntl
import os
import select
import stat
import sys
import time


def run(role, token, fault, cleanup_fault):
    target = 3 if role == 'relay' else 9
    # Coprocess exec receives only these descriptors; prove actual pipe access,
    # not just existence of a child or success of shell redirection syntax.
    if fault == 'fail': return 72
    if fault == 'fd': os.close(target)
    for fd, mode in ((0, os.O_RDONLY), (1, os.O_WRONLY), (target, os.O_WRONLY)):
        try: meta = os.fstat(fd)
        except OSError as exc: raise RuntimeError('required fd '+str(fd)+': '+str(exc)) from exc
        if fd != target or role != 'relay':
            if not stat.S_ISFIFO(meta.st_mode): raise RuntimeError('required pipe')
        access = fcntl.fcntl(fd, fcntl.F_GETFL) & os.O_ACCMODE
        if access != mode and not (fd == target and role == 'relay' and access == os.O_RDWR):
            raise RuntimeError('required access mode')
    if role == 'relay' and not os.isatty(target): raise RuntimeError('required tty')
    if fault == 'timeout':
        # Cooperative missing-ready injection: EOF from owner cancels promptly.
        if select.select([0], [], [], 3)[0]: os.read(0, 1)
        return 73
    if os.write(1, ('READY '+role+'\n').encode()) != len('READY '+role+'\n'):
        raise RuntimeError('readiness short write')
    os.close(1)
    # Avoid changing target open-file-description flags (PTY shared with bash).
    # Small pipe writes are atomic; relay writes are bounded but a blocked tty
    # syscall remains a stated hard limit, not an invented recovery guarantee.
    deadline = time.monotonic() + 15
    n = 0
    while True:
        left = deadline - time.monotonic()
        if left <= 0 or not select.select([0], [], [], left)[0]: return 76
        b = os.read(0, 4096 if role == 'relay' else 288)
        if role == 'relay':
            if not b: break
            while b:
                count = os.write(target, b)
                if count <= 0: raise RuntimeError('short relay')
                b = b[count:]
        else:
            frame = ('D1 '+token+' '+role+' '+str(n)+' ').encode()+base64.b64encode(b)+b'\n'
            if len(frame)>512 or os.write(target, frame)!=len(frame):
                raise RuntimeError('short encoder')
            n += 1
            if not b: break
    return 74 if cleanup_fault == 'fail' else 0

if __name__ == '__main__':
    try: result = run(*sys.argv[1:])
    except Exception as exc:
        print('helper error: '+repr(exc), file=sys.stderr)
        result = 71
    sys.exit(result)
