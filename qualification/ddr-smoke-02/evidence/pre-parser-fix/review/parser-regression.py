#!/usr/bin/env python3
"""Python-only diagnostic regression. No HDL or subprocess execution.
Exit 1 means the reviewed runner still accepts a vendor ERROR fixture.
"""
import hashlib
import json
from pathlib import Path

p = Path(__file__).resolve().parent.parent
source = (p / 'run_smoke.py').read_text()
ns = {'__name__': 'review_only', '__file__': str(p / 'run_smoke.py')}
exec(compile(source, str(p / 'run_smoke.py'), 'exec'), ns)
base = '\n'.join([ns['PASS']] + [
    'DDR_SMOKE_CHANNEL_DONE channel=%d writes=2 reads=2' % c
    for c in range(2)
])
diagnostics = [
    'ERROR: Invalid burst type mode 2 specified!',
    '[100] [DWR=000]:  ERROR: tRCD violation (READ) on bank @ cycle 1',
    '[100] [DWR=000]:  Internal Error: Expected READ command not in queue!',
    '** Error: simulator error',
    '** Fatal: simulator fatal',
]
rows = [{'synthetic_diagnostic': d,
         'detected': bool(ns['ERROR'].search('# ' + d)),
         'accepted': ns['accepted'](0, base + '\n# ' + d)}
        for d in diagnostics]
result = {
    'synthetic_only': True,
    'hdl_executed': False,
    'ready_for_build': False,
    'runner_sha256': hashlib.sha256((p / 'run_smoke.py').read_bytes()).hexdigest(),
    'positive_fixture_accepted': ns['accepted'](0, base),
    'diagnostics': rows,
}
result['regression_pass'] = result['positive_fixture_accepted'] and all(
    row['detected'] and not row['accepted'] for row in rows)
print(json.dumps(result, indent=2))
raise SystemExit(0 if result['regression_pass'] else 1)
