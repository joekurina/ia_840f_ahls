#!/usr/bin/env python3
import hashlib, sys
from pathlib import Path
man = Path(sys.argv[1]); root = Path(sys.argv[2])
ok=miss=bad=0; badf=[]
for ln in man.read_text().splitlines():
    ln=ln.strip()
    if not ln: continue
    h, p = ln.split(None,1); p = p.strip()
    rel = p.split(root.name+'/',1)[1] if root.name+'/' in p else p
    f = root/rel
    if not f.is_file(): miss+=1; badf.append(('MISSING',rel)); continue
    g = hashlib.sha256(f.read_bytes()).hexdigest()
    if g==h: ok+=1
    else: bad+=1; badf.append(('HASH',rel))
print(f'VERIFY ok={ok} missing={miss} bad={bad} total={ok+miss+bad}')
for t,r in badf[:20]: print('VERIFY-FAIL',t,r)
sys.exit(0 if (miss==0 and bad==0) else 1)
