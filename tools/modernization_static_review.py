#!/usr/bin/env python3
"""Source/hash/XML/Git inspection only. No vendor/project execution."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

# Run only the separately reviewed, read-only source inventory.
p = subprocess.run([sys.executable, '-B', str(ROOT/'tools/source_inventory.py')], capture_output=True, text=True)
inventory = json.loads(p.stdout)
if p.returncode:
    errors.extend(inventory['errors'])

archive = ROOT/'experiments/asp-baseline-separation'
preservation = json.loads((archive/'preservation-manifest.json').read_text())
for entry in preservation['records']:
    file = archive/entry['snapshot']
    if not file.is_file() or digest(file) != entry['sha256'] or file.stat().st_size != entry['size']:
        errors.append('Archive mismatch: '+entry['snapshot'])

research = ROOT/'reference/modernization-upstream'
evidence = json.loads((research/'evidence-manifest.json').read_text())
for entry in evidence['files']:
    file = research/entry['path']
    if not file.is_file() or digest(file) != entry['sha256'] or file.stat().st_size != entry['bytes']:
        errors.append('Research evidence mismatch: '+entry['path'])

asp = ROOT/'oneapi-asp'
restored = ['common/hardware/common/build/asp_design_files.tcl', 'common/source/host/CMakeLists.txt', 'common/source/host/mmd.cpp', 'common/source/host/mmd_device.cpp', 'common/source/host/mmd_device.h']
pin = inventory['revisions']['oneapi-asp']
for rel in restored:
    original = subprocess.check_output(['git','-C',str(asp),'show',pin+':'+rel])
    if (asp/rel).read_bytes() != original:
        errors.append('Upstream restoration mismatch: '+rel)
for base in [asp/'common/source/host', asp/'common/hardware/common/build']:
    for file in base.rglob('*'):
        if file.is_file() and any(token in file.read_bytes() for token in [b'asp_hostchannel', b'mmd_hostchannel', b'DmaHostChannels', b'interfaces/dma_hostchannel']):
            errors.append('Active experiment dependency: '+str(file.relative_to(ROOT)))

receipt = json.loads((archive/'static-check-evidence.json').read_text())
for rel in receipt['gates']:
    expected = next(e for e in preservation['records'] if e['source'] == str(asp/rel))
    if digest(asp/rel) != expected['sha256']:
        errors.append('Gate changed: '+rel)

repos = ['ofs-agx7-pcie-attach','ofs-platform-afu-bbb','oneapi-asp','examples-afu']
donors = {}
for name in repos:
    result = subprocess.run(['git','-C',str(ROOT/name),'diff','--check'],capture_output=True,text=True)
    if result.returncode:
        errors.append('Whitespace: '+name+': '+result.stdout+result.stderr)
    donors[name] = subprocess.check_output(['git','-C',str(ROOT.parent/name),'status','--porcelain'],text=True)
    if donors[name]:
        errors.append('Donor checkout dirty: '+name)
report = {'scope':'Static source parsing, hashing and read-only Git only; not compilation or tests', 'passed':not errors, 'inventory':inventory, 'archive_files_verified':len(preservation['records']), 'research_files_verified':len(evidence['files']), 'restored_upstream_files_verified':restored, 'asp_gate_files_verified':len(receipt['gates']), 'prior_asp_check_count':len(receipt['checks']), 'prior_asp_receipt_passed':receipt['passed'], 'donor_status':donors, 'errors':errors}
print(json.dumps(report,indent=2))
raise SystemExit(0 if not errors else 1)
