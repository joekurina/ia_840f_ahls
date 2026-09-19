"""Bounded LOCAL captured-stream controller. No backend, launch or CLI.

Only acquire() performs I/O. See README for the cooperative channel contract,
CAPTURE_END boundary, fixed source bindings and final in-memory error receipt.
"""
import hashlib
import json
import math
from pathlib import Path
import re
import time
import types

BINDINGS = {
    'runtime-metadata-delivery-01/delivery.py': (8202, '1eb2552668d4589b2ea6533fdfedbd55725b005e780d20ba0d68e4e12272ad71'),
    'runtime-metadata-delivery-01/fixture.py': (9175, '79e9543968d5ae0dca89373c94049de28be0a55e309a077c320063eaac4d0367'),
    'runtime-metadata-receiver-01/receiver.py': (12097, 'bc5d4cc16ecb38568868e70692ce261a0c890eb345fa6c39dea51ce64662a389'),
    'runtime-metadata-launch-01/transport.py': (41045, '29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60'),
    'runtime-metadata-launch-01/launcher.py': (30087, '2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2'),
    'runtime-metadata-diagnostic-01/collector.py': (13851, '6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897'),
}
RAW_CAP = 32 * 1024 * 1024
CHUNK = 65536
METADATA_CAP = 65536
DISK_CAP = RAW_CAP + 1 + 2 * (3 * 1024 * 1024) + 2 * 1024 * 1024 + METADATA_CAP
# A separate identity sentinel: byte EOF is ALWAYS disconnect, even after R.
CAPTURE_END = object()


def verified_apis():
    """Verify every immutable source before executing only decoder/receiver definitions."""
    base = Path(__file__).resolve().parent.parent
    sources = {}
    for name, (length, sha) in BINDINGS.items():
        with (base / name).open('rb') as f:
            data = f.read(length + 1)
        if len(data) != length or hashlib.sha256(data).hexdigest() != sha:
            raise ValueError('source binding: ' + name)
        sources[name] = data
    modules = []
    for name in ('runtime-metadata-delivery-01/delivery.py',
                 'runtime-metadata-receiver-01/receiver.py'):
        module = types.ModuleType('_controller_bound_' + Path(name).stem)
        exec(compile(sources[name], str(base / name), 'exec'), module.__dict__)
        modules.append(module)
    return tuple(modules)


def exclusive_sink(path):
    return path.open('xb')


def acquire(channel, output, pane, token, *, seconds=90.0, raw_cap=RAW_CAP,
            clock=time.monotonic, sink_open=exclusive_sink):
    """Acquire a supplied fake/local binary channel; return the final receipt.

    setup(deadline), read(maximum, deadline), close(deadline) are cooperative,
    bounded local operations. read returns bytes or CAPTURE_END, never None.
    CAPTURE_END means all acquisition bytes AND external error events delivered;
    it is not EOF, a parser observation, or authorization. close only releases
    local capture resources; it must not signal or stop any process.

    Refused parameters, source drift and an existing output raise before taking
    channel ownership. After a new output is created, errors (including cleanup)
    are returned, with bounded in-memory raw bytes even when persistence fails.
    """
    if not isinstance(pane, str) or not re.fullmatch(r'%[0-9]{1,10}', pane):
        raise ValueError('pane')
    if not isinstance(token, str) or not re.fullmatch('[a-f0-9]{32}', token):
        raise ValueError('token')
    if type(raw_cap) is not int or not 1 <= raw_cap <= RAW_CAP:
        raise ValueError('raw_cap')
    if type(seconds) not in (int, float) or not math.isfinite(seconds) or not 0 < seconds <= 90:
        raise ValueError('seconds')
    delivery, receiver = verified_apis()
    output = Path(output)
    # Fresh private local directory is a precondition, not an overwrite fallback.
    output.mkdir(exist_ok=False, mode=0o700)
    errors = []
    raw = bytearray()
    sink = None
    boundary = False
    deadline = None
    timed_out = False

    def error(stage, exc):
        # Fixed stage names and bounded exception summaries prevent error growth.
        # The full unmodified data remains in raw, not interpolated into errors.
        try:
            detail = str(exc)[:256]
        except BaseException:
            detail = '<unprintable>'
        errors.append(stage + ':' + type(exc).__name__ + ':' + detail)

    def check_deadline():
        nonlocal timed_out
        now = clock()
        if not math.isfinite(now):
            raise ValueError('nonfinite clock')
        if now >= deadline and not timed_out:
            timed_out = True
            raise TimeoutError('monotonic deadline')

    def attempt(stage, fn):
        try:
            value = fn()
        except BaseException as exc:
            error(stage, exc)
            return False, None
        return True, value

    def flush_close(handle, label):
        attempt(label + '.flush', handle.flush)
        attempt(label + '.close', handle.close)

    def write(handle, data):
        n = handle.write(data)
        if type(n) is not int or n != len(data):
            raise OSError('short write; not retried')

    def save(name, data):
        ok, handle = attempt(name + '.open', lambda: sink_open(output / name))
        if ok:
            attempt(name + '.write', lambda: write(handle, data))
            flush_close(handle, name)

    try:
        start = clock()
        if not math.isfinite(start):
            raise ValueError('nonfinite clock')
        deadline = start + seconds
        check_deadline()
        channel.setup(deadline)
        check_deadline()
        ok, sink = attempt('control.raw.open', lambda: sink_open(output / 'control.raw'))
        if ok:
            while not errors:
                check_deadline()
                # At most one byte beyond cap, retained but NEVER accepted.
                maximum = min(CHUNK, raw_cap - len(raw) + 1)
                block = channel.read(maximum, deadline)
                if block is CAPTURE_END:
                    boundary = True
                    check_deadline()
                    break
                if type(block) is not bytes:
                    raise TypeError('binary channel contract')
                if len(block) > maximum:
                    raise ValueError('channel exceeded requested bound')
                if not block:
                    raise EOFError('unexpected disconnect')
                raw.extend(block)  # before persistence; no lost partial buffer
                attempt('control.raw.write', lambda: write(sink, block))
                attempt('control.raw.flush', sink.flush)
                check_deadline()
                if len(raw) > raw_cap:
                    raise ValueError('raw cap exceeded')
    except BaseException as exc:
        error('acquisition.setup/read/deadline', exc)
    finally:
        if sink is not None:
            flush_close(sink, 'control.raw')
        attempt('channel.close', lambda: channel.close(deadline))
        if deadline is not None:
            attempt('capture.deadline', check_deadline)
    if not boundary:
        errors.append('capture:missing explicit local end boundary')
    captured = bytes(raw)
    del raw
    decoded = None
    if len(captured) <= raw_cap:
        ok, decoded = attempt('delivery.decode', lambda: delivery.decode(captured, pane, token))
        if not ok:
            decoded = None
    else:
        errors.append('delivery.decode:raw cap rejected')
    # Do not infer a missing Python exit status or fabricate an envelope.
    envelope = decoded['stdout'] if decoded is not None else b''
    stderr = decoded['stderr'] if decoded is not None else None
    status = decoded['status'] if decoded is not None else None
    def evaluate():
        ok, value = attempt('receiver.evaluate', lambda: receiver.evaluate(envelope, status, errors))
        if ok:
            return value
        return dict(classification='INCOMPLETE', command_exit_status=status,
                    issues=['transport_error:' + x for x in errors],
                    authorization=False, ready_for_build=False, vendor_run=False), {}

    _, streams = evaluate()
    ok, _ = attempt('receiver.mkdir', lambda: (output / 'receiver').mkdir(mode=0o700, exist_ok=False))
    if ok:
        if decoded is not None:
            save('receiver/raw-envelope.bin', envelope)
            save('receiver/command-stderr.bin', stderr)
        for name, data in streams.items():
            save('receiver/collector-' + name + '.bin', data)
    if deadline is not None:
        attempt('evidence.deadline', check_deadline)
    # This on-disk record deliberately NEVER claims completion. Its own flush
    # and close can fail; only the returned post-cleanup receipt is authoritative.
    record = dict(classification='INCOMPLETE', final_receipt_required=True,
                  raw_length=len(captured), raw_sha256=hashlib.sha256(captured).hexdigest(),
                  command_exit_status=status, explicit_boundary=boundary,
                  errors=list(errors), authorization=False, ready_for_build=False,
                  vendor_run=False, source_bindings=BINDINGS)
    metadata = (json.dumps(record, indent=2) + '\n').encode('ascii')
    if len(metadata) > METADATA_CAP:
        errors.append('acquisition.json:metadata cap exceeded; not persisted')
    else:
        save('acquisition.json', metadata)
    if deadline is not None:
        attempt('final.deadline', check_deadline)
    assessment, streams = evaluate()
    return dict(assessment=assessment, errors=errors, raw=captured,
                envelope=envelope if decoded is not None else None,
                command_stderr=stderr, collector_streams=streams,
                explicit_boundary=boundary, authorization=False,
                ready_for_build=False, vendor_run=False)
