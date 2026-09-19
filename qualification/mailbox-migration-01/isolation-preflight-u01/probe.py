#!/usr/bin/python3
"""Fixed inert payload. Never accepts a command or an executable pathname."""
import errno
import fcntl
import json
import mmap
import os
import signal
import socket
import struct
import sys
import time


def read(path):
    with open(path) as f:
        return f.read()


def identity():
    macs = {}
    for _, name in socket.if_nameindex():
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
            raw = fcntl.ioctl(s.fileno(), 0x8927, struct.pack('256s', name.encode()))
            macs[name] = raw[18:24].hex()
    return dict(hostname=socket.gethostname(), uid=os.geteuid(), interfaces=macs,
                machine_id=read('/etc/machine-id').strip() if os.path.isfile('/etc/machine-id') else None)


def denied(name, operation):
    try:
        operation()
    except OSError as exc:
        if exc.errno not in (errno.EROFS, errno.EACCES, errno.EPERM, errno.ENOENT):
            raise RuntimeError('%s unexpected errno %s' % (name, exc.errno))
        return dict(name=name, errno=exc.errno, denied=True)
    raise RuntimeError(name + ' unexpectedly succeeded')


def write_file(path):
    with open(path, 'wb') as f:
        f.write(b'fixture-write\n')


def shared_mapping(path, flags=os.O_RDWR):
    fd = os.open(path, flags)
    try:
        with mmap.mmap(fd, 1, flags=mmap.MAP_SHARED, prot=mmap.PROT_WRITE) as m:
            m[0:1] = b'X'
    finally:
        os.close(fd)


def emit(value):
    print(json.dumps(value, sort_keys=True), flush=True)


def baseline():
    # os.listdir's temporary directory descriptor is already closed here.
    fds = {}
    for fd in os.listdir('/proc/self/fd'):
        try:
            fds[fd] = os.readlink('/proc/self/fd/' + fd)
        except FileNotFoundError:
            pass
    assert set(fds) == {'0', '1', '2'}, fds
    assert fds['0'] == '/dev/null' and all(fds[n].startswith('pipe:[') for n in ('1', '2')), fds
    status = dict(line.split(':', 1) for line in read('/proc/self/status').splitlines() if ':' in line)
    assert status['NoNewPrivs'].strip() == '1'
    for name in ('CapInh', 'CapPrm', 'CapEff', 'CapBnd', 'CapAmb'):
        assert int(status[name].strip(), 16) == 0, name
    namespaces = {n: os.readlink('/proc/self/ns/' + n) for n in ('user', 'mnt', 'pid', 'net', 'ipc', 'uts')}
    assert set(os.listdir('/dev')) == {'null', 'zero', 'random', 'urandom'}
    mounts = []
    for line in read('/proc/self/mountinfo').splitlines():
        a, b = line.split(' - ', 1)
        fields, tail = a.split(), b.split()
        target = fields[4]
        writable_exception = target == '/rw' or target == '/proc' or target.startswith('/proc/') or target == '/dev' or target.startswith('/dev/')
        assert 'ro' in fields[5].split(',') or writable_exception, line
        mounts.append(dict(target=target, options=fields[5], fs=tail[0]))
    return dict(fds=fds, namespaces=namespaces, status={n: status[n].strip() for n in ('NoNewPrivs','CapInh','CapPrm','CapEff','CapBnd','CapAmb')},
                mountinfo=read('/proc/self/mountinfo'), mounts=mounts, identity=identity(),
                routes=read('/proc/net/route'), ipv6_routes=read('/proc/net/ipv6_route'))


def controls(config):
    time.sleep(0.25)  # retain init long enough for host pidfd capture
    evidence = baseline()
    assert set(evidence['identity']['interfaces']) <= {'lo'}
    # No IPv4 route entries; no non-loopback IPv6 route entries.
    assert len(evidence['routes'].strip().splitlines()) == 1
    assert all(line.split()[-1] == 'lo' for line in evidence['ipv6_routes'].splitlines())
    write_file('/rw/success')
    results = [denied('create', lambda: write_file('/ro/new')),
               denied('truncate', lambda: write_file('/ro/canary')),
               denied('rename', lambda: os.rename('/ro/canary', '/ro/renamed')),
               denied('shared-writable-mmap-open-or-map', lambda: shared_mapping('/ro/canary')),
               denied('shared-writable-mmap-readonly-fd', lambda: shared_mapping('/ro/canary', os.O_RDONLY)),
               denied('readonly-root-scaffold', lambda: write_file('/escape'))]
    os.symlink('/ro/canary', '/rw/escape-link')
    results.append(denied('symlink', lambda: write_file('/rw/escape-link')))
    results.append(denied('relative-dotdot', lambda: write_file('/rw/../ro/canary')))
    for path in config['absent']:
        assert not os.path.lexists(path), path
    network = []
    os.chdir(config['synthetic_cwd'])
    for label, family, endpoint in [
            ('host-loopback', socket.AF_INET, ('127.0.0.1', config['port'])),
            ('host-abstract', socket.AF_UNIX, '\0' + config['abstract']),
            ('host-pathname', socket.AF_UNIX, config['pathname'])]:
        with socket.socket(family, socket.SOCK_STREAM) as s:
            s.settimeout(0.5)
            try:
                s.connect(endpoint)
            except OSError as exc:
                # A timeout alone is not positive proof of isolation.
                assert exc.errno in (errno.ECONNREFUSED, errno.ENOENT, errno.ENETUNREACH, errno.EHOSTUNREACH), repr(exc)
                network.append(dict(name=label, errno=exc.errno, connected=False))
            else:
                raise RuntimeError('host listener reached: ' + label)
    # Private pathname IPC is allowed; retained socket lives only in the fixture.
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as listener:
        listener.bind('/rw/local.sock')
        listener.listen(1)
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.connect('/rw/local.sock')
            accepted, _ = listener.accept()
            with accepted:
                client.sendall(b'fixture')
                assert accepted.recv(7) == b'fixture'
    evidence.update(negative_controls=results, network=network, rw_success=True, local_ipc_success=True)
    emit(dict(kind='controls', evidence=evidence))


def lifecycle():
    evidence = baseline()
    # Every branch has a finite independent real-time alarm, even on supervisor
    # failure. This is a fail-safe, NOT accepted evidence of namespace teardown.
    signal.signal(signal.SIGALRM, signal.SIG_DFL)
    signal.alarm(18)
    child = os.fork()
    if child == 0:
        signal.alarm(18)  # alarms are not inherited across fork
        os.setsid()
        grandchild = os.fork()
        if grandchild:
            os._exit(0)
        signal.alarm(18)
        stat = read('/proc/self/stat')
        emit(dict(kind='descendant', pid=os.getpid(), starttime=stat[stat.rfind(')') + 2:].split()[19],
                  pid_namespace=os.readlink('/proc/self/ns/pid'), sid=os.getsid(0)))
        while True:
            signal.pause()
    os.waitpid(child, 0)
    emit(dict(kind='lifecycle-ready', evidence=evidence))
    while True:
        signal.pause()


if __name__ == '__main__':
    mode = sys.argv[1]
    if mode == 'controls' and len(sys.argv) == 3:
        controls(json.loads(sys.argv[2]))
    elif mode == 'lifecycle' and len(sys.argv) == 2:
        lifecycle()
    else:
        raise SystemExit('fixed modes only')
