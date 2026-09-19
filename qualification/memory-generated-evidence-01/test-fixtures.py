"""Synthetic local filesystem tests ONLY, no production main or workstation access."""
import ast
import copy
import hashlib
import json
import os
from pathlib import Path
import tempfile

HERE = Path(__file__).absolute().parent
source = (HERE / 'collect-memory.py').read_text()
ast.parse(source, feature_version=(3, 9))
ns = {'__name__': 'fixture_only_not_main'}
exec(compile(source, '<reviewed collector fixture code>', 'exec'), ns)
scope = json.loads((HERE / 'scope.json').read_text())
assert hashlib.sha256((HERE / 'scope.json').read_bytes()).hexdigest() == ns['SCOPE_SHA256']
assert not any(isinstance(n, (ast.Import, ast.ImportFrom)) and 'subprocess' in ast.unparse(n) for n in ast.walk(ast.parse(source)))
results = ['PASS Python 3.9 grammar and scope hash binding', 'PASS no subprocess import']
with tempfile.TemporaryDirectory(prefix='synthetic-', dir=str(HERE)) as temp:
    root = Path(temp)
    mem = root / 'memory'
    synth = mem / 'synth'
    synth.mkdir(parents=True)
    top = synth / 'mem_ss.v'
    payload = b'module mem_ss(input [13:0] i0_app_ss_mm_awuser);\r\nendmodule\r\n'
    top.write_bytes(payload)
    (mem / 'saved.ip').write_text('<parameter name="MEM_INTFS_TYPE" value="DDR4,DDR4"/>')
    (synth / 'bulk_inner.v').write_text('INTENTIONALLY OMITTED')
    s = copy.deepcopy(scope)
    s['discovery_roots'] = [str(mem)]
    s['exact_files'] = [{'path': str(top), 'purpose': 'fixture'}]
    r = ns['collect'](s)
    assert r['status'] == 'bounded_scope_captured_not_qualified'
    assert r['captured_file_count'] == 2
    assert r['files'][0]['content'].encode() == payload
    assert r['files'][0]['sha256'] == hashlib.sha256(payload).hexdigest()
    assert not r['ready_for_build'] and not r['complete_generated_tree']
    results.append('PASS full raw text/CRLF/hash retained; inner HDL excluded; no qualification')
    missing = copy.deepcopy(s)
    missing['exact_files'].append({'path': str(mem / 'absent.vh')})
    assert ns['collect'](missing)['status'] == 'partial'
    results.append('PASS missing header explicitly partial')
    outside = root / 'outside'
    outside.mkdir()
    (outside / 'secret.ip').write_text('NOT CAPTURED')
    (mem / 'escape').symlink_to(outside, target_is_directory=True)
    (mem / 'linked.ip').symlink_to(outside / 'secret.ip')
    r = ns['collect'](s)
    assert r['status'] == 'partial'
    assert len([x for x in r['issues'] if x['status'] == 'symlink_rejected_no_traversal']) == 2
    try:
        ns['read_regular'](str(mem / 'escape' / 'secret.ip'), 1024)
        raise AssertionError('symlink ancestor accepted')
    except OSError:
        pass
    results.append('PASS file/directory/ancestor symlinks rejected without target capture')
    (mem / 'escape').unlink()
    (mem / 'linked.ip').unlink()
    for key, value in [('entries', 0), ('directories', 0), ('selected_files', 1), ('file_bytes', 1), ('total_bytes', 1), ('depth', 0)]:
        limited = copy.deepcopy(s)
        limited['limits'][key] = value
        assert ns['collect'](limited)['status'] == 'partial', key
        results.append('PASS explicit partial on ' + key + ' cap')
    mismatch = copy.deepcopy(s)
    mismatch['exact_files'][0]['expected_sha256'] = '0' * 64
    assert any(x['status'] == 'reviewed_binding_mismatch' for x in ns['collect'](mismatch)['issues'])
    results.append('PASS expected source hash mismatch remains partial')
    fifo = mem / 'fifo.ip'
    os.mkfifo(str(fifo))
    try:
        ns['read_regular'](str(fifo), 1024)
        raise AssertionError('FIFO accepted')
    except ValueError:
        pass
    results.append('PASS nonregular FIFO rejected without blocking')
    exclusive = root / 'receipt-fixture.json'
    fd = os.open(str(exclusive), os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    os.close(fd)
    try:
        os.open(str(exclusive), os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
        raise AssertionError('existing receipt overwritten')
    except FileExistsError:
        pass
    results.append('PASS exclusive receipt creation primitive refuses existing target')
for result in results:
    print(result)
print('RESULT: %s fixture/static checks passed; production main NOT invoked; no remote or vendor execution.' % len(results))
