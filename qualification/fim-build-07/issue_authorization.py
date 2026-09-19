"""Consume independent parent reviews, sync exact overlay, issue once; never run Quartus.
Usage inside owned tmux: python3 issue_authorization.py consumed-reviews.json
Reviews JSON: {source_review:{accepted:true,files:{relative-path:sha256}},
 gate_review:{accepted:true,files:{relative-path:sha256}}}. Exact coverage below.
"""
import hashlib,json,os,socket,sys
from pathlib import Path
N=Path('/home/uwb_student00/ahls/new_BSP');C=N/'ofs-agx7-pcie-attach';E=N/'qualification/fim-build-07';W=N/'work_ia840f_fim_07'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def issue(review_path):
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 review_path=Path(review_path).resolve(strict=True);reviews=json.loads(review_path.read_text())
 overlays=json.loads((E/'overlay-sha256.json').read_text());before=json.loads((E/'source-before.json').read_text())
 source_files={r:v for r,v in overlays.items() if r in ('syn/board/ia840f/setup/emif_loc.tcl','syn/board/ia840f/source_manifest.json','ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv')}
 gate_files={r:v for r,v in overlays.items() if r not in source_files}
 # Source repair review was already consumed for Work05, not re-requested.
 inherited_path=N/'qualification/fim-build-05/consumed-reviews.json'
 inherited=json.loads(inherited_path.read_text())
 assert inherited['source_review']['accepted'] is True and inherited['source_review']['files']==source_files
 assert reviews['gate_review']['accepted'] is True and reviews['gate_review']['files']==gate_files
 expected_handoff={name:sha(E/name) for name in ('issue_authorization.py','launch_native_compile.py','compile-authorization.draft.json')}
 assert reviews['handoff_files']==expected_handoff, 'focused review must pin issuer/runner/draft'
 for r,h in overlays.items():
  assert sha(E/'source-overlay'/r)==h and sha(W/r)==h
  assert (sha(C/r) if (C/r).exists() else None)==before[r], 'maintained source changed: '+r
 assert not (E/'compile-authorization.json').exists() and not (E/'native-compile.claim.json').exists()
 sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_compile_gate as gate
 candidate=json.loads((E/'compile-authorization.draft.json').read_text())
 assert gate.work_inventory()==candidate['work_inventory']
 # All validation before sync. Exclusive lock prevents concurrent issue/reissue.
 (E/'authorization-issuance.lock').mkdir()
 for r,h in overlays.items():
  p=C/r;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((E/'source-overlay'/r).read_bytes());assert sha(p)==h
 for t in gate.common.TREES:gate.common.check_inventory(C/t,candidate['source_sha256'][t])
 candidate.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
 candidate['dependency_sha256'][str(review_path)]=sha(review_path)
 candidate['dependency_sha256'][str(inherited_path)]=sha(inherited_path)
 with (E/'compile-authorization.json').open('x') as f:json.dump(candidate,f,indent=2)
 assert json.loads((E/'compile-authorization.json').read_text())==candidate
 print('AUTHORIZATION ISSUED; NOT STARTED',sha(E/'compile-authorization.json'))
if __name__=='__main__':issue(sys.argv[1])
