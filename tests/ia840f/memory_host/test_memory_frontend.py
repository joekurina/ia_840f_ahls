#!/usr/bin/env python3
"""Exercise the actual C frontend with local inert API symbols, never OPAE."""
import json, os, re, subprocess, sys
from pathlib import Path
assert __debug__
exe, result_path = sys.argv[1:]
args = [exe, '--inspect-qualified-memory-afu', '0000:ab:1f.7']
records = []
def run(case='pass', fail=0, word=-1, bit=0, argv=None):
    env = {k:v for k,v in os.environ.items() if not k.startswith('MEMORY_')}
    env.update(MEMORY_CASE=case, MEMORY_FAIL_AT=str(fail),
               MEMORY_MUTATE_WORD=str(word), MEMORY_MUTATE_BIT=str(bit))
    p = subprocess.run(args if argv is None else argv, capture_output=True,
                       text=True, timeout=5, env=env)
    records.append(dict(case=case, fail_at=fail, word=word, bit=bit,
                        argv=args if argv is None else argv, rc=p.returncode,
                        stdout=p.stdout, stderr=p.stderr))
    return p
try:
    p = run()
    assert p.returncode == 0, ('new memory inspection option must succeed', p.returncode, p.stdout, p.stderr)
    count = len(re.findall(r'^API ', p.stdout, re.M))
    assert 'filters=10 reads=7 opens=1 maps=1 failed=0 remaining=0 allowed_remaining=0' in p.stdout
    assert 'FPGA Test identity/capability PASSED' in p.stdout
    for case in ('zero', 'multiple', 'enum_partial_error'):
        p = run(case=case)
        assert p.returncode == 1 and 'reads=0 opens=0 maps=0' in p.stdout, (case, p)
    for i in range(1, count + 1):
        p = run(fail=i)
        assert p.returncode == 1 and 'failed=1' in p.stdout, (i, p)
    for word in range(7):
        for bit in range(64):
            p = run(word=word, bit=bit)
            assert p.returncode == 1, (word, bit, p)
            expected_reads = word + 1 if word < 3 else 7
            assert f'reads={expected_reads} ' in p.stdout, (word, bit, p.stdout)
    bad = [[], ['--help'], ['--run-qualified-csr-test','0000:ab:1f.7'],
           ['--inspect-qualified-memory-afu','0000:ab:1f.7','extra']]
    bad += [['--inspect-qualified-memory-afu', bdf] for bdf in
            ['0:ab:1f.7','0000:ab:20.7','0000:ab:1f.8','0000:ab:1f.7x',
             '0000:ab:1f.7 ','0000:ag:1f.7','0000:ab:1f.-','0000:ab:1f.']]
    for tail in bad:
        p = run(argv=[exe, *tail])
        assert p.returncode == 2 and 'API ' not in p.stdout and 'INERT_MEMORY_SUMMARY' not in p.stdout, (tail,p)
    print(f'MEMORY_FRONTEND_INERT_PASS processes={len(records)} api_faults={count} mutated_words=7 bit_faults=448 invalid_arguments={len(bad)}')
finally:
    Path(result_path).write_text(json.dumps(dict(offline_only=True, records=records), indent=2)+'\n')
