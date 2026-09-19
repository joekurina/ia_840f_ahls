"""Issue header-only authorization after exact independent spec/quality reviews.
Does not run any vendor command. Requires an owned-tmux parent invocation.
"""
from pathlib import Path
import sys,os,json,hashlib,socket,subprocess
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach'
sys.dont_write_bytecode=True
sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'))
import ia840f_header_gate as gate
sha=gate.sha
def issue(review_path):
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 reviews=json.loads(Path(review_path).read_text());manifest=json.loads((E/'review-package-sha256.json').read_text())
 for section in ['spec_review','quality_review']:
  assert reviews[section]['accepted'] is True and reviews[section]['files']==manifest
 for rel,h in manifest.items():assert sha(E/rel)==h,rel
 draft=json.loads((E/'header-authorization.draft.json').read_text())
 before=json.loads((E/'preflight.json').read_text());overlays=json.loads((E/'overlay-sha256.json').read_text())
 assert {t:gate.common.inventory(C/t) for t in gate.common.TREES}==before['source']
 assert gate.common.inventory(gate.common.PIM)==before['pim']==draft['pim_sha256']
 for p,h in draft['dependency_sha256'].items():assert sha(p)==h,p
 for group in ['tools','quartus_tools']:
  for item in draft[group].values():assert sha(item['path'])==item['sha256']
 assert gate.work_inventory()==draft['work_inventory']
 assert draft['contexts']==[dict(executable=gate.common.RUNTIME_EXES['quartus_sh'],sha256=sha(gate.common.RUNTIME_EXES['quartus_sh']),argv=gate.HEADER_ARGS,cwd=str(gate.PROJECT))]
 assert draft['approved'] is False and draft['ready_for_build'] is False
 for rel,h in overlays.items():assert sha(W/rel)==h and sha(E/'source-overlay'/rel)==h
 assert not gate.RECORD.exists() and not (E/'header-run').exists()
 changes={rel:h for rel,h in overlays.items() if not (C/rel).exists() or sha(C/rel)!=h}
 expected=json.loads((E/'header-source-changes.json').read_text());assert changes==expected
 predicted=json.loads(json.dumps(before['source']))
 for rel,h in changes.items():
  tree,rest=rel.split('/',1);predicted[tree][rest]=h
 assert predicted==draft['source_sha256']
 # All validations precede the single-use lock and reversible exact SOURCE sync.
 (E/'header-issuance.lock').mkdir()
 backup=E/'header-source-before';backup.mkdir()
 for rel,h in changes.items():
  p=C/rel
  if p.exists():
   d=backup/rel;d.parent.mkdir(parents=True,exist_ok=True);d.write_bytes(p.read_bytes())
  p.write_bytes((E/'source-overlay'/rel).read_bytes());assert sha(p)==h
 assert {t:gate.common.inventory(C/t) for t in gate.common.TREES}==predicted
 draft.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
 draft['dependency_sha256'][str(Path(review_path).resolve())]=sha(Path(review_path))
 with gate.RECORD.open('x') as f:json.dump(draft,f,indent=2)
 assert json.loads(gate.RECORD.read_text())==draft
 print('HEADER AUTHORIZATION ISSUED; NO VENDOR START',sha(gate.RECORD))
if __name__=='__main__':issue(sys.argv[1])
