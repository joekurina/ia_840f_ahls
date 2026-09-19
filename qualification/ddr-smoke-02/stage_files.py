#!/usr/bin/env python3
import pathlib,sys,base64,zlib,json,hashlib
P=pathlib.Path(__file__).resolve().parent
sys.path.insert(0,str(P.parent/'ddr-smoke-01/inspection'))
from probe import probe
root='/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02'
probe('pathlib.Path('+repr(root)+').mkdir(exist_ok=False)\nprint("PREP_ROOT_CREATED")',P/'stage-00.txt')
i=1
for name in ['tb_mem_ss_smoke.sv','run_smoke.py','manifest.json','review-pending.json']:
 data=(P/name).read_bytes();enc=base64.b64encode(zlib.compress(data)).decode();remote=root+'/'+name+'.z64'
 for pos in range(0,len(enc),6500):
  code='p=pathlib.Path('+repr(remote)+')\nwith p.open('+repr('x' if pos==0 else 'a')+') as f:f.write('+repr(enc[pos:pos+6500])+')\nprint("CHUNK_STAGED")'
  probe(code,P/('stage-%02d.txt'%i));i+=1
 code='import base64,zlib\np=pathlib.Path('+repr(remote)+')\nf=pathlib.Path('+repr(root+'/'+name)+')\nwith f.open("xb") as o:o.write(zlib.decompress(base64.b64decode(p.read_text())))\nh=hashlib.sha256(f.read_bytes()).hexdigest()\nassert h=='+repr(hashlib.sha256(data).hexdigest())+'\nprint("STAGED "+json.dumps({"path":str(f),"sha256":h}))'
 probe(code,P/('stage-%02d.txt'%i));i+=1
probe('import subprocess\np=pathlib.Path('+repr(root+'/run_smoke.py')+')\np.chmod(0o755)\nx=subprocess.run(["python3",str(p)],capture_output=True,text=True)\nprint(json.dumps({"rc":x.returncode,"stdout":x.stdout,"stderr":x.stderr}))',P/'stage-inert.txt')
