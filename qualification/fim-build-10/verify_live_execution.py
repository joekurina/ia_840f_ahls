from pathlib import Path
import os,json,hashlib,sys,subprocess,datetime
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-10');sys.path.insert(0,'/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config');import ia840f_compile_gate as g
claim=json.loads(g.CLAIM.read_text());assert g.start_time(claim['pid'])==claim['start_time'];assert g.sha(g.RECORD)==claim['record_sha256']
chains=[]
for p in Path('/proc').glob('[0-9]*'):
 try:
  if os.readlink(p/'exe')!='/opt/altera/26.1.1/quartus/linux64/quartus_syn':continue
  pid=int(p.name);chain=[]
  while pid>1:
   exe,argv,cwd=g.common.process(pid);chain.append(dict(pid=pid,start_ticks=g.start_time(pid),exe=exe,argv=argv,cwd=cwd));pid=g.parent(pid)
  assert any(x['pid']==claim['pid'] for x in chain);chains.append(chain)
 except OSError:pass
assert chains
b=(E/'run/native.log').read_bytes();r={'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'live_claim_verified':True,'synthesis_ancestry':chains,'rejection_counts':{m.decode():b.count(m) for m in g.common.REJECTION_MARKERS},'status':json.loads((E/'run/status.json').read_text())}
p=E/'final-marker-check.json'
with p.open('x') as f:json.dump(r,f,indent=2)
subprocess.run(['tmux','load-buffer','-b','work10-final-live-check',str(p)],check=True)
print('FINALCHECK',g.sha(p),flush=True)
