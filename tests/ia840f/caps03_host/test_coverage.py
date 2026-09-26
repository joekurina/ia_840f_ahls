"""Finite CAPS03 coverage frontend check; inert ELF only, never an OPAE binary."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess

LENGTHS = [1, 8, 9, 16, 17, 31, 32, 33, 63, 64, 65, 127, 128, 129, 255, 256, 257]
p = argparse.ArgumentParser()
p.add_argument('executable', type=Path)
p.add_argument('output', type=Path)
p.add_argument('--red-only', action='store_true')
a = p.parse_args()
a.output.mkdir(parents=True, exist_ok=False)
dynamic = subprocess.run(['readelf', '-dW', str(a.executable)], capture_output=True, text=True, check=True).stdout
assert not re.search(r'\(NEEDED\).*\[(?:libopae|libxfpga)', dynamic)
scenarios = [('pass', 0)]
if not a.red_only:
    scenarios += [('start_error', 77), ('completion_error', 77), ('payload_corrupt', 77), ('guard_corrupt', 77)]
results = []
for scenario, expected_rc in scenarios:
    env = dict(os.environ, MEMORY_CASE=scenario, MEMORY_FAULT_KERNEL='2')
    r = subprocess.run([str(a.executable), '--run-qualified-caps03-hls', '0000:4f:00.2'],
                       capture_output=True, text=True, env=env, timeout=20)
    text = r.stdout + r.stderr
    (a.output / (scenario + '.log')).write_text(text)
    rows = re.findall(r'FPGA Test HLS CASE PASS: case=(\d+) n=(\d+) layout=(\d+) result_bytes=(\d+) guard_bytes=(\d+) descriptors=(\d+)', text)
    ok = r.returncode == expected_rc
    if scenario == 'pass':
        expected = [(i, n, layout) for layout in range(2) for i, n in enumerate(LENGTHS, start=layout * len(LENGTHS))]
        ok &= [(int(x[0]), int(x[1]), int(x[2])) for x in rows] == expected
        ok &= all(int(x[3]) == 4 * int(x[1]) and int(x[4]) == ((4 * int(x[1]) + 63) // 64) * 64 + 128 - 4 * int(x[1]) for x in rows)
        ok &= 'FPGA Test CAPS03 COVERAGE PASSED: cases=34' in text
        ok &= 'remaining=0 allowed_remaining=0' in text
    else:
        ok &= len(rows) == 1 and 'INERT_HOLD' in text and 'releases=0' in text
        ok &= 'FPGA Test CAPS03 COVERAGE PASSED' not in text
    results.append({'scenario': scenario, 'native_rc': r.returncode, 'expected_rc': expected_rc,
                    'case_passes': len(rows), 'passed': bool(ok)})
summary = {'inert_only': True, 'hardware_linked': False, 'cases': results,
           'success': all(x['passed'] for x in results)}
(a.output / 'result.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
raise SystemExit(0 if summary['success'] else 1)
