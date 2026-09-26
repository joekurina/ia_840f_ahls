"""Focused reduced contiguous full-capacity frontend checks; inert OPAE symbols only."""
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
scenarios = [('pass', 0)] if a.red_only else [('pass', 0), ('banks_alias', 77), ('payload_corrupt', 77), ('guard_corrupt', 77), ('stale_count', 77)]
rows = []
for scenario, expected in scenarios:
    env = dict(os.environ, MEMORY_CASE=scenario, MEMORY_AT_GO='3')
    p = subprocess.run([str(a.binary.resolve()), '--run-qualified-caps03-hls', '0000:4f:00.2'], env=env,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=20)
    text = p.stdout.decode()
    (a.output / (scenario + '.log')).write_bytes(p.stdout)
    passed = p.returncode == expected
    if expected == 0:
        phases = re.findall(r'FPGA Test DDR phase verified mode=(\d) bank=(\d) bytes=(\d+) descriptors=(\d+) source_page=4096 destination_page=4096', text)
        passed &= phases == [('1', '0', '8192', '64'), ('1', '1', '8192', '128'), ('2', '0', '8192', '192'), ('2', '1', '8192', '256')]
        passed &= text.count('FPGA Test CAPS03 FULL DDR PASSED: banks=2 locations_per_bank=64 bytes_per_bank=8192 descriptors=256 verified_payload_and_guards=1') == 1
        passed &= 'INERT_DMA buffers=2 releases=2 go=256 held=0' in text
    else:
        passed &= 'INERT_HOLD ' in text and 'releases=0' in text and 'held=1' in text
        passed &= not re.search(r'API \d+ fpga(?:ReleaseBuffer|Close|UnmapMMIO)', text)
    rows.append({'scenario': scenario, 'native_rc': p.returncode, 'expected_rc': expected, 'passed': bool(passed)})
r = {'inert_only': True, 'hardware_linked': False, 'locations_per_bank': 64, 'cases': rows, 'success': all(x['passed'] for x in rows)}
(a.output / 'result.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r, indent=2))
raise SystemExit(0 if r['success'] else 1)
