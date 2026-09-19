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
changes=[]
for p in sorted(OLD.rglob('*')):
 if p.is_file() and not p.is_symlink() and str(OLD).encode() in p.read_bytes(): changes.append(dict(path=str(p.relative_to(OLD)),suffix=p.suffix,nul=b'\0' in p.read_bytes()))
print(json.dumps(dict(source=sum(map(len,binding['source'].values())),pim=len(binding['pim']),dependencies=len(binding['dependencies']),work04_entries=len(inv(OLD)),memory=inv(G),relocation_candidates=changes,existing=[str(p) for p in (E,W) if p.exists()]),indent=2))
