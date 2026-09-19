# Work10 independent quality review

**Verdict: APPROVED — bounded seed-2 experiment and Work10 handoff only.**

Critical findings: none. Important findings: none. Minor findings: inherited issuer docstring describes an obsolete review schema; executable checks correctly require timing_review, gate_review, inherited source_review and handoff_files. Historical Work08 gate heading and Work05 shell-test log label are also stale comments/fixture labels. These do not affect the successor's executable bindings and do not warrant scope-expanding edits.

This is the fresh technical quality review after the accepted specification PASS. It neither issues authorization nor launches or consumes reviews. Approval is not timing closure, hardware qualification, functional acceptance, or build readiness. No additional user approval is requested by this review; the existing technical issuance/launch sequence remains separate.

## Independent checks and findings

- Read actual issuer, runner, production compile gate, dispatcher branch, early compile-shell guard, full candidate patch and test implementations. Independently recomputed every one of the 68 file hashes listed in spec-review.md, including predecessor/rationale pins, and all 60 package manifest entries. Rechecked all 60 after test execution: unchanged. This is a local review of exported remote evidence, not a fresh remote-host attestation.
- Independently proved issuer and runner are byte-exact Work09-to-Work10 mechanical retargets. All 135 runtime contexts equal Work09 after only the WORK-root substitution. Draft contains 106 dependency pins and 5,564 WORK entries. Checked each of the 12 overlay digests against actual overlay bytes, draft SOURCE inventory and draft WORK inventory; exactly the two gate files and QSF differ from the actual remote baseline. No framework redesign or grammar expansion.
- QSF is precisely SEED 1 to SEED 2, with no other byte change. Actual remote maximum-placement baseline is preserved, not replaced by stale local QSF or native Work09 migration. Thus the unchanged AGFB027R25A2E2V, core470/seven PLL requests, DDR333, two 16-GiB x64 no-ECC BOT/BOT channels, PF/BAR and pin/clock/RTL contracts remain unchanged; this review does not independently requalify inherited hardware contracts.
- Issuer checks exact timing/gate review dictionaries, inherited Work05 source review and issuer/runner/draft handoff hashes. Before synchronization it verifies every overlay, corresponding WORK file and current SOURCE overlay baseline, plus full WORK inventory. Issuance lock uses exclusive mkdir; authorization uses exclusive x and readback. Full SOURCE inventory is checked after synchronization. That ordering is correctly described: pre-sync SOURCE checking covers overlay targets, not the entire SOURCE inventory. A non-overlay SOURCE mismatch fails after sync without authorization, and the lock remains as failure evidence; this is not atomic rollback. No blocker for this trusted, bounded inherited workflow.
- Runner cleans forbidden options and explicitly selects Quartus 26.1.1 bin and sopc_builder/bin paths and license variables. Production gate checks actual resolved outer/inner paths, executable hashes, SOURCE/PIM/dependencies, readiness false and exact native binding. Runner checks full initial WORK inventory and absent claim before exclusively reserving run directory, invocation and log. Repeated invocation cannot overwrite existing evidence. Status is updated only inside the newly reserved directory.
- Native gate uses exclusive claim creation, exact executable/argv/cwd checks and inventory before native start. Callback validation combines record hash, live ancestor PID/start ticks, exact ancestor command and finite executable/hash/argv/cwd context. The dispatcher selects Work10 PROJECT rather than Work09; unsupported argv are rejected, not normalized. Work10 authorization/claim paths are distinct; no consumed Work09 authorization is selected for reuse. These are source-bound guards, not an OS sandbox against their operator.
- Runner returns native nonzero status, and converts rejection-marked zero to failure. A clean zero remains native-exit acceptance only, with fit/assembly/timing pending and functional_acceptance false. All five draft approval/consumption/readiness flags are false. The reviewed document does not change them.

## Tests actually executed versus inspected

All fresh outputs and temporary fixture writes were restricted to a newly exclusively created `quality-tests/` directory. Bytecode writes were disabled. Existing bound logs were not overwritten. No vendor executable or remote command was run.

| Fresh execution | Result | Evidence |
|---|---|---|
| test_issuer.py -v | 2 tests PASS, including negative subcases | quality-tests/test_issuer.py.log |
| test_runner.py -v | 3 tests PASS | quality-tests/test_runner.py.log |
| unittest -v test_ia840f_compile_gate.CompileTests | 7 tests PASS | quality-tests/compile-policy.log |

The issuer suite executes actual issuer logic only under temporary paths, mocked host identity and inventory gate. Its `AUTHORIZATION ISSUED` output is inert fixture issuance, not real Work10 authorization. The runner suite uses actual Python print/exit children: exit 7 propagates; clean zero remains exit-only; rejection-marked zero returns 1; repeat attempts preserve evidence bytes. Policy fixtures exercise claim exclusivity, source/tool/part/review/readiness mutations, WORK inventory, options/argv/cwd, symlink escape, exact runtime hash and stale ancestry rejection.

Inspected but not rerun: remote real-dispatch implementation and bound 40-invocation evidence, three explicit missing-Work10-record shell/entry rejections, and inherited remote complete eight-test suite. The local policy execution intentionally excludes RealShellRejection: exported overlay lacks the full build_top tree, so running that shell fixture locally could yield a misleading missing-file failure. Issuer fixtures use reduced overlays and mocked full-inventory validation; production five-file review coverage and full-inventory sequencing were checked directly in code, not inferred from fixture counts. No Quartus/Tcl integration claim follows from these tests.

## Exact hash-bound coverage

Paths are relative to this evidence directory. The manifest pin incorporates the complete verified package; explicit pins below identify the reviewed handoff and gate/QSF scope. Changed bytes require renewed applicable review.

| Artifact | SHA256 |
|---|---|
| spec-review.md | 649e685681bfe71ec60adf28c80cdea6e34ef412e1e7ffb534c7a56d2dfd31a8 |
| package-sha256.json | fb666ce47c0bf2527dd3c164a185026ce0336702a2bc64ea6ceccf68f7c5ae39 |
| remote-evidence/issue_authorization.py | c01c585bd2ac2193f46df49f2630cb9ae56c875e392a849c4b8ee77b70ba81f1 |
| remote-evidence/launch_native_compile.py | 31beb72d84a1a5bafc4226f7145a8a0414dc8883b44a36825fae089756581895 |
| remote-evidence/compile-authorization.draft.json | 3946f9994cae8c459a69ca1f09758ec1dafc2e3c434c30b7d815b0a1831ea947 |
| remote-evidence/candidate.patch | d3fc5a1a81abb2c9c711c7fa5ba715c90b361570598e09769dd563e84300b2de |
| remote-evidence/overlay-sha256.json | 8fa1f10ae399c621132200ed1dd6608b64c9c54891694831298b2bf93299d2ba |
| remote-evidence/source-before/syn/board/ia840f/syn_top/ofs_top.qsf | ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3 |
| remote-evidence/source-overlay/syn/board/ia840f/syn_top/ofs_top.qsf | 35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293 |
| remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_compile_gate.py | 1f147c46af7fe3e34e65eabeb6519fef0d6ff80ef7adc0a882e707caaeef3135 |
| remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_experimental_gate.py | ded3e1213e9bbfce5335070c65553ff5d40a5e30eb46f8845ccc0c23f66aa365 |
| remote-evidence/source-overlay/ofs-common/tools/ofss_config/test_ia840f_compile_gate.py | d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2 |
| remote-evidence/source-overlay/ofs-common/scripts/common/syn/build_fim_compile.sh | 0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07 |
| quality-tests/verification.json | 6b7cca1dc202aad8559889f5393e9b144ad6c289addd6a58c5c144e94a65868a |
| quality-tests/test_issuer.py.log | f0bf34ca603ddda8359f15a039af4396dbeb396da3943c429a13fdcedebe2ae9 |
| quality-tests/test_runner.py.log | 2f42f5e3bc54c84595fee999f0f1916d48ba8525c518b6322d51bb5f2a9c753e |
| quality-tests/compile-policy.log | ca14e9d9f0d84016eb83e5481f96f2225058f1f5f792d96c2711dccfd1267f64 |

Issuer review partition is explicitly accepted for this experiment: timing_review must cover precisely top.sv, top_loc.tcl, ofs_top_sources.tcl, bti_refclk.sdc and seed-2 ofs_top.qsf; inherited Work05 source_review covers emif_loc.tcl, source_manifest.json and mem_ss_top.sv; gate_review covers the four gate/shell/test paths pinned above. Exact values for all 12 are in the pinned overlay manifest and independently verified against SOURCE/WORK draft bindings. Handoff must cover exactly the issuer, runner and draft hashes above. This document does not manufacture consumed-reviews JSON.

## Acceptance boundaries retained

Work09 setup/hold failures, S1/TRS applicability, unconstrained PCIe divider, BMC IRQ/JTAG and applicable ignored constraints remain open. Seed 2 is an unchanged-constraint placement experiment, not a timing fix or acceptance of those constraints. Preserve comparisons of both DDR WNS/TNS/endpoints and routing/cell composition, hold, clocks, unconstrained paths and ignored constraints. `ready_for_build` remains false. Query04 was not accessed; DDR simulation, hardware, maintained-source edits, commits and real authorization/claim creation were not performed. Only this report and new local quality-test evidence were created.
