"""Read-only sibling validation; generates ONLY inert local proposal text."""
import ast
import hashlib
import json
import re
import subprocess
from pathlib import Path
import delivery

root=Path(__file__).absolute().parent
bindings={}
for relative in ('runtime-metadata-launch-01/transport.py',
                 'runtime-metadata-launch-01/launcher.py',
                 'runtime-metadata-diagnostic-01/collector.py',
                 'runtime-metadata-receiver-01/receiver.py'):
    b=(root.parent/relative).read_bytes()
    bindings[relative]=dict(length=len(b),sha256=hashlib.sha256(b).hexdigest())
payload=(root.parent/'runtime-metadata-launch-01/transport.py').read_bytes()
text=delivery.proposed_command(payload,'d'*32)
proposal=root/'proposed-command.txt'
if proposal.exists():
    assert proposal.read_bytes()==text.encode()
else:
    with proposal.open('xb') as f: f.write(text.encode())
chunks=re.findall(r"(?m)^'((?:\\[0-7]{3})+)'",text)
reconstructed=bytes(int(x,8) for chunk in chunks for x in chunk.split('\\')[1:])
assert reconstructed==payload
assert max(map(len,text.splitlines()))<1024
for name in ('delivery.py','test_delivery.py','fixture.py','validate.py'):
    ast.parse((root/name).read_text(),feature_version=(3,9))
replay={}
for name in ('fixture-06','fixture-07','fixture-08'):
    raw=(root/name/'control.raw').read_bytes()
    r=delivery.decode(raw,'%0','b'*32)
    for stream in ('stdout','stderr'): assert r[stream]==(root/name/(stream+'.bin')).read_bytes()
    result=json.loads((root/name/'result.json').read_text())
    assert r['status']==result['status']
    assert (root/name/'control-full.raw').read_bytes()==raw+(root/name/'control-shutdown-tail.raw').read_bytes()
    assert not (root/name/'socket').exists()
    replay[name]=dict(status=r['status'],raw_bytes=len(raw),stdout_sha256=hashlib.sha256(r['stdout']).hexdigest(),stderr_sha256=hashlib.sha256(r['stderr']).hexdigest(),private_socket_absent=True)
info=dict(bindings=bindings,python=subprocess.check_output(['/usr/bin/python3','--version']).decode().strip(),
          tmux=subprocess.check_output(['/usr/bin/tmux','-V']).decode().strip(),
          bash=subprocess.check_output(['/bin/bash','--version']).decode().splitlines()[0],
          grammar='Python 3.9 AST only; not runtime certification',
          proposal=dict(length=len(text.encode()),sha256=hashlib.sha256(text.encode()).hexdigest(),
                        max_physical_line=max(map(len,text.splitlines())),reconstructed_bytes=len(reconstructed),
                        reconstruction_matches=True,executed=False),
          replay=replay,authorization=False,ready_for_build=False,vendor_run=False)
(root/'validation.json').write_text(json.dumps(info,indent=2)+'\n')
print(json.dumps(info,indent=2))
