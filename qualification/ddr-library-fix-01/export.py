from pathlib import Path
import json,hashlib,base64,gzip
q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-fix-01');p=q.parent/'ddr-smoke-02'
files=[f for f in q.iterdir() if f.is_file() and f.suffix in ('.log','.py','.json')]+[f for f in (p/'run-03').iterdir() if f.is_file()]
d={str(f.relative_to(q.parent)):{'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'data':base64.b64encode(f.read_bytes()).decode()} for f in files}
s=base64.b64encode(gzip.compress(json.dumps(d).encode())).decode();(q/'export.b64').write_text(s)
print('EXPORT',len(s),hashlib.sha256(s.encode()).hexdigest(),'FILES',len(d))
print((p/'run-03/elaborate-run.log').read_text()[:23000])
