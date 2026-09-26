"""Exercise the actual CAPS03 frontend against inert OPAE symbols, not hardware."""
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path

assert __debug__
exe = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2]).resolve()
out.mkdir(parents=True, exist_ok=False)
elf = subprocess.run(['readelf', '-d', str(exe)], capture_output=True, text=True, check=True).stdout
assert not re.search(r'NEEDED.*(?:opae|xfpga|vfio)', elf, re.I)
base = [str(exe), '--run-qualified-caps03-hls', '0000:4f:00.2']
results = []


def run(name, changes, expected, argv=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('MEMORY_')}
    env.update(changes)
    command = argv if argv is not None else base
    p = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=10)
    text = p.stdout.decode(errors='replace')
    (out / (name + '.log')).write_bytes(p.stdout)
    ok = p.returncode == expected and not any(s in text for s in ['runtime error:', 'AddressSanitizer'])
    if expected == 0:
        ok &= 'CAPS03 frontend PASSED' in text
        ok &= 'releases=2 go=6 held=0 kernel=1 producer=1 ticket=1 completed=1' in text
    elif expected == 77:
        ok &= 'INERT_HOLD' in text and 'releases=0' in text and 'held=1 kernel=1' in text
        ok &= 'frontend PASSED' not in text
    elif expected == 2:
        ok &= 'API ' not in text
    results.append({'case': name, 'argv': command, 'changes': changes,
                    'rc': p.returncode, 'expected': expected, 'pass': bool(ok),
                    'bytes': len(p.stdout), 'sha256': hashlib.sha256(p.stdout).hexdigest(),
                    'log': name + '.log'})
    if not ok:
        print(name, p.returncode, expected, text)
    return bool(ok), text


ok, positive = run('pass', {}, 0)
cases = []
if ok:
    start_match = re.search(r'INERT_KERNEL_SUBMIT api_next=(\d+)', positive)
    release_match = re.search(r'API (\d+) fpgaReleaseBuffer', positive)
    assert start_match is not None and release_match is not None
    start = int(start_match[1])
    first_release = int(release_match[1])
    # Only the newly introduced post-start lifetime boundary, not a new SDK matrix.
    for call in range(start, first_release):
        cases.append((f'post-start-api-error-{call}', {'MEMORY_FAIL_AT': str(call)}, 77, None))
    for scenario in ['start_error', 'status_error', 'status_timeout', 'bad_ticket',
                     'completion_error', 'completion_unsupported', 'completion_reset',
                     'completion_timeout', 'missing_visibility', 'payload_corrupt',
                     'tail_corrupt', 'guard_corrupt', 'source_corrupt']:
        cases.append((scenario, {'MEMORY_CASE': scenario}, 77, None))
    cases.extend([
        ('missing-option', {}, 2, [str(exe)]),
        ('bad-bdf', {}, 2, base[:-1] + ['nonsense']),
        ('old-option', {}, 2, [str(exe), '--isolate-qualified-memory-banks', base[-1]]),
    ])
    for case in cases:
        ok, _ = run(*case)
        if not ok:
            break
receipt = {'inert': True, 'hardware_access': False, 'live_lifecycle_qualified': False,
           'elf_sha256': hashlib.sha256(exe.read_bytes()).hexdigest(),
           'elf_dynamic': elf, 'planned': 1 + len(cases), 'executed': len(results),
           'passed': sum(r['pass'] for r in results), 'cases': results}
(out / 'result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({k: receipt[k] for k in ['planned', 'executed', 'passed', 'inert', 'hardware_access']}))
raise SystemExit(0 if ok and len(results) == receipt['planned'] else 1)
