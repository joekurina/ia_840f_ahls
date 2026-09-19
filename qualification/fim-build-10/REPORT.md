# Work10 seed-2 candidate — prepared, not authorized or launched

## Outcome
Fresh remote `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_10` and `qualification/fim-build-10` were created exclusively inside owned windows of `ia840f_mailbox_monitored_01` on verified Agilex7Workstation UID1000. No maintained SOURCE writes, issuer execution, native compile, DDR simulation, hardware action, driver/permission/install change, commit, or Query04 access occurred. All approval/readiness flags in the draft remain false. Ready for independent specification and quality review, not build readiness or timing acceptance.

## Exact candidate and baseline
`remote-evidence/candidate.patch` contains only three changed files relative to verified actual remote SOURCE:
- `syn/board/ia840f/syn_top/ofs_top.qsf`: SEED 1 → 2, and no other byte change.
- `ofs-common/tools/ofss_config/ia840f_compile_gate.py`: WORK/EVIDENCE 09 → 10.
- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`: actual Quartus dispatcher cwd 09 → 10.

Baseline QSF SHA256 `ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3`; candidate `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`. The remote SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT mode, SPEED and maximum router effort remain intact. The stale local maintained QSF was not used. Native Work09 option migration is not copied back into SOURCE.

Rationale and installed seed evidence: `../msa-timing-candidate-seed2/REPORT.md`, `seed-only.patch`, `verification.json`, and `remote-static.json`. Seed 2 probes placement sensitivity; no guarantee of improved setup or hold. The unchanged clock/geometry/interface constraints include 333 MHz DDR, core470/seven PLL requests, two 16 GiB x64 no-ECC BOT/BOT channels, AGFB027R25A2E2V and existing PCIe/BMC contracts. No pipeline, SDC cut, PLL or geometry changes.

## Fresh copy and binding evidence
The complete Work04 generation tree was checked against Work09's recorded Work04-before inventory, copied with symlinks, verified, then relocated using the proven staging method. Copied QDB/output directories and inherited experimental authorization are archived under remote `inherited-output/`; no Work09 compiled QDB/output was reused. There are 170 relocations and 5,564 bound staged WORK files/symlinks. Every final WORK symlink resolves inside WORK. Work04 was reread unchanged after staging and tests.

Maintained SOURCE's full inventory and PIM were verified against the prior issued record before staging; outer/inner tool hashes were reread. SOURCE remained unchanged after preparation. Work09 claim, authorization, finished status and native log hashes were checked before/after and retained; its images/WORK were never written or used as a copy source. `preparation-preflight.json` captures these checks and the installed instructions hash.

The candidate has 12 overlay files, retaining all inherited DDR and BTI repair bytes. Its 135 exact contexts equal Work09's contexts after only the Work-root substitution. All executable hashes, closed argv alternatives, actual ancestry/PID/start-time checks, readiness checks, options, source/tool/dependency checks, and rejection handling are preserved. Draft binds 106 dependencies and 10 runtime tools. These guards are not an OS sandbox.

## Regression results
- Remote compile-gate suite: 8 tests PASS, including positive claim, source/tool/part/readiness/review/work mutations, options/argv/cwd, symlink escape and ancestry.
- Remote actual SOURCE-overlay and copied-WORK dispatcher tests: 40 invocations, 12 positive and 28 negative. Actual production dispatcher/load_record/runtime checks use real paths and hashes, with explicitly inert future record/claim/process fixtures; no vendor child is executed.
- Three real missing-Work10-record rejection paths PASS: copied entry, build_top shell and build_fim_compile shell. All reject specifically at missing `qualification/fim-build-10/compile-authorization.json`, before native logs, claim or run directory.
- Local retargeted issuer suite: 2 tests PASS (positive/exclusive repeat plus negative timing-review coverage, gate review, handoff hashes, stale SOURCE and inherited review subcases). Only temporary inert fixtures are issued; this is not remote authorization issuance.
- Local runner suite: 3 tests PASS with real inert Python children. Native exit 7 propagates; exit zero with rejection marker returns failure; clean zero remains exit-only acceptance. Reruns preserve prior evidence bytes. No watchdog introduced.
- Local verifier: all 44 exported remote files match transfer manifest; patch reconstructed exactly; every overlay matches SOURCE/WORK draft inventories; full source comparison has exactly the three changes above; draft/issuer/runner hashes and 135 contexts checked. `verify_package.py` is reproducible without remote access.

## Focused review / later issuance boundary
Review `remote-evidence/issue_authorization.py`, `launch_native_compile.py`, `compile-authorization.draft.json`, both gate overlays, `candidate.patch`, and regression evidence. Issuer and runner are byte-exact Work09 retargets; neither has been executed against remote Work10.

The issuer still requires exact five-file `timing_review` coverage: top.sv, top_loc.tcl, ofs_top_sources.tcl, bti_refclk.sdc and the seed-2 QSF. Three DDR files retain the consumed Work05 source review. Remaining overlay files require gate review, and handoff coverage pins issuer, runner and draft. No consumed Work10 review record is manufactured here. Any future `timing_review.accepted=true` means acceptance for this bounded experiment only, not closure. A reviewed issuer is the only later path that may synchronize maintained SOURCE. Launch remains a separate action after review; this preparation request explicitly does not launch.

## Still-open acceptance
Work09 native exit was zero, but EMIF0 setup was -0.435 ns, EMIF1 setup -0.313 ns, and EMIF1 PHY hold -0.004 ns, with one unconstrained clock and two inputs/two outputs. Preserve its failed reports, images and claim. S1/TRS fitted-resource applicability, unconstrained PCIe divider, BMC IRQ/JTAG policy and other applicable ignored constraints/relationships remain open. Query04 remains explicitly blocked and was not retried, rerouted or changed. The existing Work08 timing report exists; do not repeat older claims that it was absent.

An eventual run must compare both DDR WNS/TNS/failing endpoints and routing/cell path composition, all hold checks, clocks, unconstrained paths and ignored-constraint diagnostics. A seed result or assembled image cannot establish functional acceptance; ready_for_build stays false until the full acceptance work is completed.

## Key SHA256
| Artifact | SHA256 |
|---|---|
| remote-evidence/candidate.patch | d3fc5a1a81abb2c9c711c7fa5ba715c90b361570598e09769dd563e84300b2de |
| remote-evidence/issue_authorization.py | c01c585bd2ac2193f46df49f2630cb9ae56c875e392a849c4b8ee77b70ba81f1 |
| remote-evidence/launch_native_compile.py | 31beb72d84a1a5bafc4226f7145a8a0414dc8883b44a36825fae089756581895 |
| remote-evidence/compile-authorization.draft.json | 3946f9994cae8c459a69ca1f09758ec1dafc2e3c434c30b7d815b0a1831ea947 |

Complete file inventory and hashes: `package-sha256.json`; remote-only transport inventory: `remote-evidence/export-sha256.json`. Local operational helpers and tests live only here. The initial unavailable bare `python` was corrected to `python3`; no remote preparation failure occurred.
