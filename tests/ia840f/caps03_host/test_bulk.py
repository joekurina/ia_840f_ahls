"""Full finite bulk corpus with inert OPAE symbols; no hardware backend."""
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
plan = []
for mode, bank, base, size in [(1, 0, 0x10000, 262144), (1, 0, 0x60000, 262144),
                               (1, 1, 0xffc0, 262272), (2, 1, 0xffc0, 262272)]:
    offset = 0
    while offset < size:
        tile = min(3968, size - offset)
        part = 0
        while part < tile:
            ddr, host = base + offset + part, 64 + part
            length = min(128, tile - part, 4096 - ddr % 4096, 4096 - host % 4096)
            plan.append((len(plan), mode, bank, length, ddr))
            part += length
        offset += tile
assert len(plan) == 8324
scenarios = [('pass', 0)] if a.red_only else [('pass', 0), ('late_payload_corrupt', 77), ('guard_corrupt', 77), ('start_error', 77)]
rows = []
for scenario, expected in scenarios:
    p = subprocess.run([str(a.binary.resolve()), '--run-qualified-caps03-hls', '0000:4f:00.2'],
                       env=dict(os.environ, MEMORY_CASE=scenario), stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=60)
    text = p.stdout.decode()
    (a.output / (scenario + '.log')).write_bytes(p.stdout)
    passed = p.returncode == expected
    if expected == 0:
        actual = re.findall(r'^FPGA Test DMA submit sequence=(\d+) mode=(\d+) bank=(\d+) bytes=(\d+) ddr=0x([0-9a-f]+)$', text, re.M)
        passed &= [(int(s), int(m), int(b), int(n), int(d, 16)) for s, m, b, n, d in actual] == [row for row in plan if row[0] % 128 == 0]
        inert = re.findall(r'^INERT_BULK_DMA sequence=(\d+) mode=(\d+) bank=(\d+) bytes=(\d+) ddr=0x([0-9a-f]+)$', text, re.M)
        passed &= [(int(s), int(m), int(b), int(n), int(d, 16)) for s, m, b, n, d in inert] == plan
        passed &= re.findall(r'^FPGA Test DMA retired and host pages verified sequence=(\d+)$', text, re.M) == [str(i) for i in range(0, len(plan), 128)]
        passed &= text.count('FPGA Test CAPS03 BULK PASSED: integers=65536 result_bytes=262144 guard_bytes=128 descriptors=8324 verified_payload_and_guards=1') == 1
        passed &= 'INERT_DMA buffers=2 releases=2 go=8324 held=0 kernel=1 producer=1 ticket=1 completed=1' in text
        passed &= 'FPGA Test HLS ticket=1 completion=0x10002' in text
    else:
        passed &= 'INERT_HOLD ' in text and 'releases=0' in text and 'held=1' in text
        passed &= not re.search(r'API \d+ fpga(?:ReleaseBuffer|Close|UnmapMMIO)', text)
        if scenario == 'late_payload_corrupt':
            passed &= 'FPGA Test BULK tile verified region=3 bytes=261888 descriptors=8320\n' in text
    rows.append({'scenario': scenario, 'native_rc': p.returncode, 'expected_rc': expected, 'passed': bool(passed)})
r = {'inert_only': True, 'hardware_linked': False, 'cases': rows, 'success': all(x['passed'] for x in rows)}
(a.output / 'result.json').write_text(json.dumps(r, indent=2) + '\n')
print(json.dumps(r, indent=2))
raise SystemExit(0 if r['success'] else 1)
