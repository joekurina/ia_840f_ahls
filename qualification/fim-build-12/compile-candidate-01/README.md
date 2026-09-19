# Work12 actual-postheader full-compile candidate 01

**UNAPPROVED. No authorization issued or consumed; no compile launched.**

Remote package: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-candidate-01`.
Current SOURCE, PIM and existing WORK12 remain in place. No source integration or WORK recreation is required or permitted by this issuer. Header issuance/run claims are consumed historical evidence and must never be replayed. `compile-context-fixture.json` is not used or copied into this package.

## Bindings and preserved engineering scope

The draft is derived from actual issued header SOURCE/PIM/tools/dependencies plus the **actual postheader WORK inventory**, SHA256 `da828e3203f2019951fa370f103d6c22d6e3c20906949c16e1fd46ac79d1d4c3`. Fresh complete live comparisons passed before package creation: SOURCE 1361 files, PIM 530, WORK 5277 entries, 448 inherited dependencies and all 135 native contexts. The draft adds exact actual-result and accepted MSA provenance pins and this issuer/runner/result-review hashes. Historical Work11 dependencies are provenance only, not reused approvals or Work05 source-review classification.

Accepted header-result review SHA256 `708f9e564b5ce1852ad35f2636c3a9a871025de4ae0f8c958c6e69fe3659bf95`, evidence SHA256 `44e3399128d6bb9e49fdaa6b76e5e9c568a28b8cc9f37dcaa2bb256b92ed4857`. These support compile preparation, not compile authorization. `accepted-history/` contains actual header authorization/result/invocation/claim/inventory/output hashes and exact three-gate SOURCE integration receipt. `accepted-msa/` contains accepted corrected-source receipt, source-after inventory, spec/quality reports and generation-candidate-03 binding/consumed review. `corrected-source/` contains the three integrated correction artifacts. They are already accepted engineering provenance, not a request for broad re-review.

SOURCE QSF is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`; native-migrated WORK QSF is `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`. Do not impose byte equality or roll back migration. Seed 2, hold ON, maximum placement effort, geometry, clocks/SDC, PF/BAR, pins and calibration routing are unchanged. Saved memory has FIFO0/copies1 on both MSA instances. All actual generated headers are bound, including four wrappers byte-identical to Work11 with reviewed 128-port coverage. Malformed unconsumed ASP collateral remains unchanged; sparse FIM header is supported by interface-info/package consumers. No ASP qualification is claimed.

The selected AFU is the existing default standard exerciser, **not AHLS functionality**. All readiness, timing, constraint-completeness, calibration-association and functional flags remain false. Later actual full STA must be compared to Work11; native exit zero alone is not timing acceptance.

## Exact native flow and limited implementation changes

From SOURCE `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`:

```sh
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12
```

The candidate runner sets the proven explicit Quartus 26.1.1 PATH, sopc_builder launcher path and all three license variables, clears seed/variant/hook overrides, preserves the exclusive original `fim-build-12/run` and native claim, and has **no wall-clock watchdog**. It reuses the Work12-retargeted proven runner with only raw native-status persistence before fallible log reading and native nonzero/signal propagation on collection failure; `runner.diff` is exact. The existing IP-generation post-module exporter may refresh configuration during full compile. Initial WORK equality is a pre-start gate, not an assertion that compile outputs never change. Native status and gate-marker rejection remain independent checks.

No SOURCE gate changes: `gate-copy/` is a byte-identical review/test copy. All 135 executable/argv/cwd/hash contexts and native ancestry grammar remain unchanged. The issuer follows the established exact-review, full-preflight, exclusive-lock, exclusive-record pattern, but removes obsolete Work11 source/timing classifications and SOURCE writes. It verifies the fresh complete package and current actual inventories before its first exclusive side effect. It does not launch the runner. These gates are not an OS sandbox.

## Independent review contract

1. Independent **specification review**, then independent **quality review**. Each report must inspect the exact `review-package-sha256.json` payload mapping, draft, issuer, runner diff, actual result/source integration bindings and test evidence. Check all 135 contexts unchanged; actual postheader binding; current/source QSF distinction; no stale fixture or historical approval reuse; pre-side-effect rejection and exclusive stage evidence; expected native hook changes; ready flags false.
2. Parent reads both reports and explicitly accepts them. Do not treat preparation or tests as either independent approval. Stage reports/envelope outside immutable package without overwriting old evidence.
3. Envelope schema:

```json
{
  "parent_acceptance_explicit": true,
  "package_manifest_sha256": "<exact manifest hash>",
  "spec_review": {"accepted": true, "files": {"<each payload path>": "<sha256>"}, "report_path": "<absolute remote spec report>", "report_sha256": "<hash>"},
  "quality_review": {"accepted": true, "files": {"<same exact mapping>": "<sha256>"}, "report_path": "<absolute remote quality report>", "report_sha256": "<hash>", "spec_report_sha256": "<accepted spec hash>"}
}
```

No accepted envelope is included. Issuance, only after parent review consumption, inside a fresh window of owned `ia840f_mailbox_monitored_01` on Agilex7Workstation UID1000:

```sh
python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-candidate-01/issue_authorization.py /absolute/fresh/parent-envelope.json
```

Then separately, after verifying issued record/readback and unchanged pre-start live inventories, the once-only launch command (NOT EXECUTED BY PREPARATION) is:

```sh
# cwd SOURCE; fresh owned tmux window
python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-candidate-01/launch_native_compile.py
```

A rejected/failed attempt is retained, not overwritten or retried. Issuer does not change SOURCE, WORK or consumed header claims. All remote operations, including readback, stay in fresh owned tmux windows. No Query04/equivalent, DDR simulation, hardware operation, install, permission change or commit.

## Inert validation

`test_compile_policy.CompileTests` is the established isolated gate fixture suite, with mock identities/tools never executed. `test_actual_dispatch.py` invokes actual production entry dispatch and validator for all 135 contexts from both isolated byte-identical gate copy and existing WORK; record/claim/process identities are explicitly mocked, with real current inventory/tool hashes and actual cwd. It also rejects argv/executable/cwd/ancestry/source/readiness mutations. `test_missing_record.py` exercises both actual maintained/copied shell guards and entry before logs/claims/bootstrap. `test_runner_inert.py` uses actual inert Python children, including nonzero and signal exits, collection failure and rejected rerun preservation. `test_issuer_inert.py` uses isolated output roots and mocked preflight result to check exact review coverage, parent/report/order requirements and exclusive replay rejection. Real issuer `preflight()` is separately executed without issue. No test executes a vendor fixture or grants real authorization.
