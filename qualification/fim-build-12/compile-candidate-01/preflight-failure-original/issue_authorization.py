"""Work12 postheader compile-only issuer; never modifies SOURCE/WORK or starts tools.
Fresh exact spec then quality review and parent consumption are mandatory.
"""
from pathlib import Path
import hashlib, json, os, socket, subprocess, sys
B=Path('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim-build-12'
P=E/'compile-candidate-01'; C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_12'
sys.dont_write_bytecode=True
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'))
import ia840f_compile_gate as gate
sha=gate.sha

def preflight():
    assert not sys.flags.optimize, 'assertions must be enabled'
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    for root in (P,C,W,E,gate.common.PIM): assert root.resolve(strict=True)==root
    manifest=json.loads((P/'review-package-sha256.json').read_text())
    for rel,h in manifest.items():
        assert not Path(rel).is_absolute() and '..' not in Path(rel).parts
        assert not (P/rel).is_symlink() and sha(P/rel)==h,rel
    draft=json.loads((P/'compile-authorization.draft.json').read_text())
    expected=dict(schema=1,approved=False,accepted_execution=False,source_review_consumed=False,
                  gate_review_consumed=False,ready_for_build=False,target='ia840f',part=gate.common.PART,
                  toolchain=gate.common.VERSION,source=str(C),work=str(W),pim=str(gate.common.PIM),
                  permissions=['native-full-compile'],native_argv=gate.TOP_ARGS,native_cwd=str(C))
    for k,v in expected.items(): assert type(draft.get(k)) is type(v) and draft[k]==v,k
    assert not draft.get('fixture_only',False)
    assert {t:gate.common.inventory(C/t) for t in gate.common.TREES}==draft['source_sha256']
    assert gate.common.inventory(gate.common.PIM)==draft['pim_sha256']
    assert gate.work_inventory()==draft['work_inventory']
    for path,h in draft['dependency_sha256'].items(): assert sha(path)==h,path
    for group in ('tools','quartus_tools'):
        assert set(draft[group])==set(gate.common.TOOLS)
        for item in draft[group].values():
            assert str(Path(item['path']).resolve(strict=True))==item['path']
            assert sha(item['path'])==item['sha256']
    contexts=[dict(executable=gate.common.RUNTIME_EXES[args[0]],sha256=sha(gate.common.RUNTIME_EXES[args[0]]),argv=args,cwd=str(gate.PROJECT)) for args in gate.allowed_commands()]
    assert len(contexts)==135 and draft['contexts']==contexts
    assert draft['source_sha256']==json.loads((E/'header-execution-02/source-integration-receipt.json').read_text())['source_after']
    assert draft['work_inventory']==json.loads((E/'header-run/postheader-work-inventory.json').read_text())
    for path in (gate.RECORD,gate.CLAIM,E/'run',P/'authorization-issuance.lock',P/'consumed-reviews.json'):
        assert not path.exists() and not path.is_symlink(),str(path)
    return draft,manifest

def issue(review_path):
    # All review/package/live checks precede the first exclusive side effect.
    draft,manifest=preflight()
    review_path=Path(review_path).resolve(strict=True)
    reviews=json.loads(review_path.read_text())
    assert reviews['parent_acceptance_explicit'] is True
    assert reviews['package_manifest_sha256']==sha(P/'review-package-sha256.json')
    for section in ('spec_review','quality_review'):
        r=reviews[section]
        assert r['accepted'] is True and r['files']==manifest
        assert sha(Path(r['report_path']))==r['report_sha256']
    assert reviews['quality_review']['spec_report_sha256']==reviews['spec_review']['report_sha256']
    assert reviews['spec_review']['report_path']!=reviews['quality_review']['report_path']
    (P/'authorization-issuance.lock').mkdir()
    with (P/'consumed-reviews.json').open('x') as f: json.dump(reviews,f,indent=2)
    assert json.loads((P/'consumed-reviews.json').read_text())==reviews
    draft.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
    for path in (P/'consumed-reviews.json',P/'review-package-sha256.json',P/'compile-authorization.draft.json',review_path,
                 Path(reviews['spec_review']['report_path']),Path(reviews['quality_review']['report_path'])):
        draft['dependency_sha256'][str(path)]=sha(path)
    with gate.RECORD.open('x') as f: json.dump(draft,f,indent=2)
    assert json.loads(gate.RECORD.read_text())==draft
    print('COMPILE AUTHORIZATION ISSUED; NOT STARTED',sha(gate.RECORD))

if __name__=='__main__': issue(sys.argv[1])
