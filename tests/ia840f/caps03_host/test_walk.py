"""Exact 30-address walk and correlated-pair faults with inert OPAE symbols."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess

ap = argparse.ArgumentParser()
ap.add_argument('binary', type=Path)
ap.add_argument('output', type=Path)
ap.add_argument('--red-only', action='store_true')
a = ap.parse_args()
a.output.mkdir(parents=True, exist_ok=False)
elf = subprocess.run(['readelf', '-dW', str(a.binary)], capture_output=True, text=True, check=True).stdout
assert not re.search(r'NEEDED.*(?:opae|xfpga)', elf, re.I)
addresses = [0] + [1 << bit for bit in range(6, 34)] + [(1 << 34) - 64]
scenarios = [('pass', 0)] if a.red_only else [('pass', 0), ('alias7_10', 77), ('alias8_11', 77), ('alias9_12', 77)]
rows = []
for scenario, expected in scenarios:
    env = dict(os.environ, MEMORY_CASE=scenario)
    p = subprocess.run([str(a.binary.resolve()), '--run-qualified-caps03-hls', '0000:4f:00.2'], env=env,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
    text = p.stdout.decode()
    (a.output / (scenario + '.log')).write_bytes(p.stdout)
    passed = p.returncode == expected
    if expected == 0:
        submits = re.findall(r'FPGA Test DMA segment submit descriptor=(\d+) sequence=(\d+) bank=(\d+) mode=(\d+) bytes=(\d+) ddr_offset=0x([0-9a-f]+)', text)
        expected_submits = [(i, i, (i // 30) % 2, 1 + i // 60, 64, addresses[i % 30]) for i in range(120)]
        passed &= [(int(d), int(s), int(b), int(m), int(n), int(o, 16)) for d, s, b, m, n, o in submits] == expected_submits
        passed &= re.findall(r'FPGA Test segment pages verified descriptor=(\d+)', text) == [str(i) for i in range(120)]
        passed &= text.count('FPGA Test DMA address walk PASSED: banks=2 locations=30 descriptors=120 verified_payload_and_guards=1') == 1
        passed &= 'INERT_DMA buffers=2 releases=2 go=120 held=0' in text
    else:
        passed &= 'INERT_HOLD ' in text and 'releases=0' in text and 'held=1' in text
        passed &= not re.search(r'API \d+ fpga(?:ReleaseBuffer|Close|UnmapMMIO)', text)
    rows.append({'scenario': scenario, 'native_rc': p.returncode, 'expected_rc': expected, 'passed': bool(passed)})
r = {'inert_only': True, 'hardware_linked': False, 'addresses_per_bank': len(addresses), 'cases': rows, 'success': all(x['passed'] for x in rows)}
(a.output / 'result.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r, indent=2))
raise SystemExit(0 if r['success'] else 1)
