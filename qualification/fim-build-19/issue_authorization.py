"""Work19 unchanged-design Quartus 25.1 comparison; direct native-iteration authority.
Legacy issue() is preserved but unused. The additive entry below consumes
explicit user policy and parent bindings, not fabricated independent reviews.
"""
from pathlib import Path
import hashlib, json, os, socket, subprocess, sys
B=Path('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim-build-19'
P=E/'compile-candidate-01'; C=B/'ofs-agx7-pcie-attach'; W=B/'work_ia840f_fim_19'
sys.dont_write_bytecode=True
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'))
import ia840f_compile_gate as gate
sha=gate.sha

def preflight():
    assert not sys.flags.optimize, 'assertions must be enabled'
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
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
    assert gate.work_inventory()==draft['work_inventory'], 'W19 work inventory drift'
    for path,h in draft['dependency_sha256'].items(): assert sha(path)==h,path
    for group in ('tools','quartus_tools'):
        assert set(draft[group])==set(gate.common.TOOLS)
        for item in draft[group].values():
            assert str(Path(item['path']).resolve(strict=True))==item['path']
            assert sha(item['path'])==item['sha256']
    contexts=[dict(executable='/opt/altera/25.1/quartus/linux64/'+args[0],sha256=sha('/opt/altera/25.1/quartus/linux64/'+args[0]),argv=args,cwd=str(gate.PROJECT)) for args in gate.allowed_commands()]
    assert len(contexts)==135 and draft['contexts']==contexts
    # Work19: SOURCE changes only the two retargeted tool/operation gates.
    # All Work18 QSF/SDC and generated RTL are preserved at preparation.
    _r12=json.loads((B/'qualification/fim-build-18/compile-authorization.json').read_text())
    _dr=json.loads((P/'source-inputs/delta-report.json').read_text())['source_delta']
    assert set(_dr)=={'ofs-common/tools/ofss_config/ia840f_experimental_gate.py',
                      'ofs-common/tools/ofss_config/ia840f_compile_gate.py'}, 'delta-report scope unexpected'
    for t in gate.common.TREES:
        _new=draft['source_sha256'][t]; _old=_r12['source_sha256'][t]
        _measured={k for k in _new if _old.get(k)!=_new[k]}
        _reviewed={k[len(t)+1:] for k in _dr if k.startswith(t+'/')}
        assert _measured==_reviewed, f'{t}: source delta != reviewed set'
        for k in _dr:
            if k.startswith(t+'/'):
                rk=k[len(t)+1:]
                assert _old.get(rk)==_dr[k]['old'] and _new[rk]==_dr[k]['new'], k
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

def issue_native_iteration(authority_path):
    draft,manifest=preflight()
    authority_path=Path(authority_path).resolve(strict=True)
    accepted=json.loads(authority_path.read_text())
    assert accepted['mode']=='user-directed-native-iteration'
    assert accepted['parent_acceptance_explicit'] is True
    assert accepted['fresh_independent_spec_quality_claimed'] is False
    assert accepted['package_manifest_sha256']==sha(P/'review-package-sha256.json')
    assert accepted['candidate_top_sdc_sha256']==sha(C/'syn/shared_config/top.sdc')
    assert accepted['candidate_qsf_sha256']==sha(W/'syn/board/ia840f/syn_top/ofs_top.qsf')
    assert accepted['iteration_authority_sha256']==sha(P/'ITERATION-AUTHORITY.md')
    assert accepted['iteration_basis_sha256']==sha(P/'iteration-basis.md')
    (P/'authorization-issuance.lock').mkdir()
    with (P/'consumed-reviews.json').open('x') as f: json.dump(accepted,f,indent=2)
    draft.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True,
                 review_mode='user-directed-native-iteration: parent exact-delta checks; no new independent source reviews')
    for path in (P/'consumed-reviews.json',P/'review-package-sha256.json',P/'compile-authorization.draft.json',authority_path):
        draft['dependency_sha256'][str(path)]=sha(path)
    with gate.RECORD.open('x') as f: json.dump(draft,f,indent=2)
    assert json.loads(gate.RECORD.read_text())==draft
    print('WORK19_AUTHORIZATION_ISSUED',sha(gate.RECORD),flush=True)

if __name__=='__main__': issue_native_iteration(sys.argv[1])
