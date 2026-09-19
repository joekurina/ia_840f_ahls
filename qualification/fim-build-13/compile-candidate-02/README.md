# fim-build-13 compile-candidate-02

Supersedes compile-candidate-01 (spec-review FAIL sha 65cb06d364e5..., quality-review REJECTED sha 65babefd3228...).
candidate-01 and its reviews are preserved unchanged as history.

## Fixed vs candidate-01
1. issue_authorization.py: restores the dropped `C=`/`W=` definitions (issuer previously crashed: NameError at import).
2. issue_authorization.py lineage check: was `draft.source_sha256 == W12 record` (unsatisfiable forever, since SOURCE legitimately differs in the two retargeted gate files). Now delta-exact: measured delta == exactly the two reviewed gate files, old/new bound to source-inputs/delta-report.json. Duplicate work-inventory assert dropped.
3. source-inputs/gate-swap.json: before-block now records the true pre-swap hashes derived from the W12 issued record (candidate-01 recorded post-swap hashes in before).

## Identical to candidate-01 (already spec-verified)
gate-copy/ (both gates), launch_native_compile.py, compile-authorization.draft.json (byte-identical; no candidate-01 self-references), source-inputs/delta-report.json.

## Review envelope (fresh reviews required; candidate-01 reviews do NOT bind this manifest)
issue_authorization.py issue(review_path) requires reviews JSON with parent_acceptance_explicit=true,
package_manifest_sha256=sha256(review-package-sha256.json), spec_review/quality_review accepted=true,
files==manifest, report hashes. On pass: lock, consumed-reviews.json, RECORD at
qualification/fim-build-13/compile-authorization.json (approved=true, once-only), claim at
native-compile.claim.json by the launch gate.

## Launch (after issuance)
launch_native_compile.py (W12-reviewed runner, paths retargeted) — single native compile of
work_ia840f_fim_13 from SOURCE cwd under Quartus 26.1.1.
