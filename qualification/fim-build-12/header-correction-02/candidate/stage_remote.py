from pathlib import Path
import os,sys,socket,json,hashlib
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';OLD=B/'work_ia840f_ipgen_04';E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';G=B/'work_ia840f_msa_generation_01';M=B/'qualification/msa-bank-spreading-integration-01'
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inv(root):
 return {str(p.relative_to(root)):({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)}) for p in sorted(root.rglob('*')) if p.is_symlink() or p.is_file()}
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'));import ia840f_experimental_gate as common
binding=json.loads((M/'generation-candidate-03/execution-binding.json').read_text())
assert {t:common.inventory(C/t) for t in common.TREES}==binding['source']
assert common.inventory(common.PIM)==binding['pim']
for p,h in binding['dependencies'].items():assert sha(p)==h,p
assert inv(OLD)==json.loads((B/'qualification/fim-build-11/work04-before.json').read_text())
receipt=json.loads((M/'integration-receipt.json').read_text())
for row in receipt['changed_files']:assert sha(C/row['path'])==row['after']
assert sha(C/'syn/board/ia840f/syn_top/ofs_top.qsf')=='ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c'

import shutil,difflib
assert not E.exists() and not W.exists()
assert inv(G)==EXPECTED_MEMORY
E.mkdir();(E/'preflight.json').write_text(json.dumps(dict(source=binding['source'],pim=binding['pim'],dependencies=binding['dependencies'],memory=inv(G)),indent=2))
original=inv(OLD);(E/'work04-before.json').write_text(json.dumps(original,indent=2))
history={str(p):sha(p) for p in [B/'qualification/fim-build-11/compile-authorization.json',B/'qualification/fim-build-11/native-compile.claim.json',B/'qualification/fim-build-11/run/status.json',B/'qualification/fim-build-11/run/native.log']}
shutil.copytree(OLD,W,symlinks=True);assert inv(W)==original
archive=E/'inherited-output';archive.mkdir()
memrel='ipss/mem/qip/mem_ss';proj='syn/board/ia840f/syn_top'
for rel in [memrel,proj+'/qdb',proj+'/output_files',proj+'/ofs_ip_cfg_db','syn/board/ia840f/setup/experimental-authorization.json']:
 p=W/rel
 if p.exists() or p.is_symlink():
  dst=archive/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.move(str(p),str(dst))
dest=W/memrel;dest.mkdir(parents=True)
shutil.copy2(G/'mem_ss.ip',dest/'mem_ss.ip');shutil.copytree(G/'mem_ss',dest/'mem_ss',symlinks=True)
assert inv(dest)=={k:v for k,v in EXPECTED_MEMORY.items() if k!='first-save.ip'}
shutil.copy2(G/'first-save.ip',E/'first-save.provenance.ip')
relocations=[]
for p in sorted(W.rglob('*')):
 if p.is_symlink():
  old=os.readlink(p);new=old.replace(str(OLD),str(W))
  if str(C) in new:
   target=Path(new.replace(str(C),str(W)));assert target.is_file() and sha(target)==sha(p)
   new=str(target)
  if new!=old:
   p.unlink();p.symlink_to(new);relocations.append(dict(path=str(p.relative_to(W)),kind='symlink',before=old,after=new))
 elif p.is_file():
  data=p.read_bytes();new=data
  for src,target in [(str(OLD),str(W)),(str(G),str(dest))]:new=new.replace(src.encode(),target.encode())
  if new!=data:
   assert p.suffix in ('.xml','.rpt') or p.name=='README',str(p)
   assert b'\0' not in data
   st=p.stat();p.write_bytes(new);os.utime(p,ns=(st.st_atime_ns,st.st_mtime_ns))
   relocations.append(dict(path=str(p.relative_to(W)),kind='metadata',before_sha256=hashlib.sha256(data).hexdigest(),after_sha256=sha(p)))
# Live authoritative source overlays, including the three integrated preset files.
prior=json.loads((B/'qualification/fim-build-11/overlay-sha256.json').read_text())
for row in receipt['changed_files']:prior[row['path']]=row['after']
overlays={};patches=[]
for rel,h in prior.items():
 assert sha(C/rel)==h
 data=(C/rel).read_bytes();new=data
 if rel.endswith(('ia840f_compile_gate.py','ia840f_experimental_gate.py')):new=data.replace(b'fim-build-11',b'fim-build-12').replace(b'work_ia840f_fim_11',b'work_ia840f_fim_12').replace(b'Work11',b'Work12')
 for root in [W,E/'source-overlay']:
  p=root/rel;assert not p.is_symlink();p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(new)
 overlays[rel]=sha(W/rel)
 if data!=new:patches.extend(difflib.unified_diff(data.decode().splitlines(True),new.decode().splitlines(True),fromfile='a/'+rel,tofile='b/'+rel))
(E/'candidate.patch').write_text(''.join(patches))
(E/'overlay-sha256.json').write_text(json.dumps(overlays,indent=2))
(E/'source-before.json').write_text(json.dumps(prior,indent=2))
(E/'relocations.json').write_text(json.dumps(relocations,indent=2))
for p in W.rglob('*'):
 if p.is_symlink():assert p.resolve(strict=True).is_relative_to(W),str(p)
 elif p.is_file():
  assert str(OLD).encode() not in p.read_bytes(),str(p)
  assert str(G).encode() not in p.read_bytes(),str(p)
assert inv(OLD)==original
assert inv(G)==EXPECTED_MEMORY
assert {t:common.inventory(C/t) for t in common.TREES}==binding['source']
assert common.inventory(common.PIM)==binding['pim']
assert {p:sha(p) for p in history}==history
for p,h in binding['dependencies'].items():assert sha(p)==h,p
(E/'work12-preheader-inventory.json').write_text(json.dumps(inv(W),indent=2))
(E/'staging-receipt.json').write_text(json.dumps(dict(work=str(W),source_unchanged=True,work04_unchanged=True,accepted_memory_unchanged=True,work11_preserved=history,relocations=len(relocations),overlays=overlays,ready_for_build=False,header_launched=False,compile_launched=False),indent=2))
print(json.dumps(dict(staged=True,work_entries=len(inv(W)),relocations=len(relocations),header_launched=False,compile_launched=False)))
