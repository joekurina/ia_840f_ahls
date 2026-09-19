"""Fresh Work07 staging only. OVERLAYS injected by local verified transport."""
from pathlib import Path
import base64, hashlib, json, os, shutil, sys
N=Path('/home/uwb_student00/ahls/new_BSP');C=N/'ofs-agx7-pcie-attach';OLD=N/'work_ia840f_ipgen_04';W=N/'work_ia840f_fim_07';E=N/'qualification/fim-build-07'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def inv(root):
 return {str(p.relative_to(root)):({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)}) for p in sorted(root.rglob('*')) if p.is_symlink() or p.is_file()}
assert not W.exists() and not W.is_symlink() and not E.exists()
E.mkdir(parents=True)
before=inv(OLD);(E/'work04-before.json').write_text(json.dumps(before,indent=2))
source_before={rel:(sha(C/rel) if (C/rel).exists() else None) for rel in OVERLAYS}
(E/'source-before.json').write_text(json.dumps(source_before,indent=2))
shutil.copytree(OLD,W,symlinks=True)
assert inv(W)==before
arch=E/'inherited-output';arch.mkdir()
for rel in ['syn/board/ia840f/syn_top/qdb','syn/board/ia840f/syn_top/output_files','syn/board/ia840f/setup/experimental-authorization.json']:
 p=W/rel
 if p.exists():
  dest=arch/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.move(str(p),dest)
relocations=[]
for p in sorted(W.rglob('*')):
 if p.is_symlink():
  link=os.readlink(p);new=link.replace(str(OLD),str(W))
  if str(C) in new:
   target=Path(new.replace(str(C),str(W)))
   assert target.is_file() and sha(target)==sha(p)
   new=str(target)
  if new!=link:
   p.unlink();p.symlink_to(new);relocations.append(dict(path=str(p.relative_to(W)),before=link,after=new))
 elif p.is_file():
  data=p.read_bytes()
  if str(OLD).encode() in data:
   assert b'\0' not in data, 'opaque old path: '+str(p)
   stat=p.stat();new=data.replace(str(OLD).encode(),str(W).encode());p.write_bytes(new);os.utime(p,ns=(stat.st_atime_ns,stat.st_mtime_ns))
   relocations.append(dict(path=str(p.relative_to(W)),before_sha256=hashlib.sha256(data).hexdigest(),after_sha256=sha(p)))
for rel,item in OVERLAYS.items():
 data=base64.b64decode(item['data']);assert hashlib.sha256(data).hexdigest()==item['sha256']
 for root in (W,E/'source-overlay'):
  p=root/rel;assert not p.is_symlink();p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(data)
  assert sha(p)==item['sha256']
for p in W.rglob('*'):
 if p.is_symlink():assert p.resolve(strict=True).is_relative_to(W),str(p)
 elif p.is_file():assert str(OLD).encode() not in p.read_bytes(),str(p)
assert inv(OLD)==before,'Work04 changed'
assert {r:(sha(C/r) if (C/r).exists() else None) for r in OVERLAYS}==source_before,'maintained source changed'
(E/'relocations.json').write_text(json.dumps(relocations,indent=2))
(E/'overlay-sha256.json').write_text(json.dumps({r:v['sha256'] for r,v in OVERLAYS.items()},indent=2))
(E/'staged-work-inventory.json').write_text(json.dumps(inv(W),indent=2))
receipt=dict(work=str(W),work04_unchanged=True,maintained_source_unchanged=True,overlay_count=len(OVERLAYS),relocation_count=len(relocations),generated_cache='retained synthesis HDL/XML; no inherited QDB/output database reused',ready_for_build=False,accepted_execution=False,source_review_consumed=False,gate_review_consumed=False,quartus_started=False,ddr_simulation='SKIPPED BY USER',work04_inventory_sha256=sha(E/'work04-before.json'),staged_inventory_sha256=sha(E/'staged-work-inventory.json'))
(E/'staging-receipt.json').write_text(json.dumps(receipt,indent=2));print(json.dumps(receipt,indent=2))
