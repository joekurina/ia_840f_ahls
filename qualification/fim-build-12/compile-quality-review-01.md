# Work12 compile-candidate-01 — independent final quality review

## Verdict: APPROVED

No concrete must-fix defect found in the exact once-only compile package. This is quality approval after specification PASS, not authorization issuance, parent consumption, native execution, or qualification of a compiled result. Parent must read and explicitly accept both reports before consuming reviews; the issuer must then perform its fresh live preflight. No incremental user approval barrier is introduced.

Specification report reviewed first: `compile-spec-review-01.md`, SHA256 **`aa822df551a0a302e679e7bbe546d92a774d92fb26d667571d4a48cdf519ecf7`**. This quality verdict explicitly binds that exact specification report.

## Exact package and complete coverage

The verdict covers **every one of the 62 payload mappings**, without exclusions, in `compile-candidate-01/review-package-sha256.json`. That complete mapping—not a selected subset—is the quality-review `files` mapping for later parent consumption. Independently recomputed every payload hash, compared the complete on-disk file set against the mapping, and repeated that check after tests: **63 files including manifest, zero missing/extra payloads or hash mismatches**. Preserved failed artifacts are covered as historical evidence only, never as executable successors.

| Binding | SHA256 |
|---|---|
| Exact package manifest | `15687a2e812b78101246a66a57edc8e5991ef596a361d4de46e898afc8cc4836` |
| Review archive | `8c231cafcb7746378fd3f9f22edc167bf98f4b5352a30c072a683a5c37c0d6ab` |
| Compile draft | `2dac6b722902eb5c141107f8f93b550f72b298f49d1b31f960acbb6c9493d5ea` |
| Issuer | `c831dd5d99b7e795d3032e3a27ea33a8e847d7ee6d297c5fad4faaa1d2ca9752` |
| Runner | `80bb3835eb77f15e0375c118c423ed57c1a2d2320620ecd150a0213d2e96664a` |
| Accepted header-result review 02 | `708f9e564b5ce1852ad35f2636c3a9a871025de4ae0f8c958c6e69fe3659bf95` |
| Actual postheader inventory | `da828e3203f2019951fa370f103d6c22d6e3c20906949c16e1fd46ac79d1d4c3` |

Read the complete preparation report and README, issuer, runner and diff, compile/experimental/header gates, native shell and Tcl guards, relevant test implementations, accepted header-result report and captured final preflight/readback. Fully parsed all JSON payloads. Review coverage includes draft inventories, provenance/receipt records, accepted MSA correction artifacts and historical reports, SOURCE/WORK input copies, captured test outputs, and preserved failed-preflight payloads. Prior accepted memory/interface/ASP engineering evidence is retained as provenance rather than requalified here.

## Quality findings

1. **Preflight and consumption ordering are sound for the declared trust model.** `issue_authorization.py` performs host/UID/owned-session, exact package, complete SOURCE/PIM/WORK, dependencies, tools and context checks before any exclusive write. It requires absent compile authorization, native claim, run directory, issuance lock and consumed-review record. Review checks require explicit parent acceptance, exact manifest hash, full identical payload coverage, hashed report files, quality linkage to the spec hash and distinct report path strings. Only then does it exclusively create the issuance lock, consumed reviews and new compile record. Partial failure retains evidence and fails closed; no SOURCE integration or WORK recreation is performed. Issuer does not launch tools. These are trusted source-bound controls, not an OS sandbox or proof of reviewer independence; parent genuinely reading and accepting the two distinct reports remains part of the contract.

2. **The draft binds actual accepted postheader state.** Full dictionary comparisons independently verified SOURCE equals both issued-header SOURCE and integration receipt `source_after`, PIM equals issued-header PIM, and WORK equals actual postheader inventory. Independently counted SOURCE **1361**, PIM **530**, WORK **5277**, dependencies **471**. All **448** inherited dependency mappings are retained unchanged. Every provenance-binding entry is present with its exact hash in the draft. Gate and SOURCE/WORK review copies match their corresponding inventory hashes. No preheader fixture is being promoted and no consumed header claim is being replayed.

3. **Executable reconstruction is narrow and complete.** Compared all **135** context dictionaries to the Work11 issued record after only literal WORK11→WORK12 retarget: exact equality. Independently evaluated only the pure `allowed_commands()` function and matched its entire ordered argv output to the draft. The issuer correction hashes each exact installed `/opt/altera/26.1.1/quartus/linux64/<argv0>` executable rather than using the incomplete two-tool common runtime map. The original failing issuer/draft/manifest/log remain preserved. Runtime executable/hash/argv/cwd checks and live claimed-native ancestry remain unchanged; a bare inherited stage flag cannot authorize a callback.

4. **Native entry and dispatch remain fail-closed.** The maintained and copied shell guards precede logs, board sourcing, bootstrap and native compilation. WORK12 experimental entry routes compile contexts to the compile validator, with only the exact historical header argv routed separately. The native claim is exclusive and binds authorization hash, bash process identity/start ticks, command and SOURCE cwd. Runtime callbacks require the claimed live ancestor plus an exact context. Tcl gate rejection markers and `Critical Warning (125091)` remain independently rejected even if Quartus returns zero. Callback checks do not incorrectly demand the initial WORK inventory after native post-module exporter updates.

5. **Runner change preserves failure information without broadening execution.** Exact command remains `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12`, cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`. Explicit Quartus 26.1.1 PATH including sopc_builder, Quartus/PIM roots and all three license variables remain; seed, variant, analysis-only and hook overrides are cleared. There is no watchdog. Initial record/environment/WORK validation precedes exclusive run-directory creation. Raw native return code is persisted before fallible log collection; nonzero and signal status survive collection failure, whereas native zero plus collection failure returns nonzero. Exclusive invocation/log/checkpoint and rejected-rerun behavior preserve prior evidence. Mechanical native-exit acceptance is expressly separate from fit/STA/assembly report acceptance.

6. **Preservation boundaries are consistent.** SOURCE QSF remains `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`; WORK QSF remains `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`. Full diff is the accepted native maximum-placement migration and version metadata, not a new operator setting change. Seed2, hold ON, maximum placement, clocks/SDC, geometry, PF/BAR/pins and calibration routing remain within the accepted unchanged scope. FIFO0/copies1, accepted wrapper coverage, sparse header and malformed-but-unconsumed ASP collateral remain preserved. The default standard-exerciser AFU is not AHLS functionality.

## Fresh independent local execution

Ran only disposable copied Python fixtures with bytecode disabled; temporary-directory contexts removed them afterward. No production remote paths, tools, claims or records were exercised or created.

| Fresh local command/probe | Actual result |
|---|---|
| `python -B -m unittest test_compile_policy.CompileTests -v` | Exit 0; **7 tests PASS** |
| `python -B test_runner_inert.py` | Exit 0; **5 cases PASS** |
| `python -B test_issuer_inert.py` | Exit 0; **8 cases PASS** |
| Additional real inert SIGTERM child plus forced log-read failure | Raw **-15**, outer **143**, checkpoint and rejected-rerun bytes preserved |
| Additional real inert rc0 child printing `Critical Warning (125091)` | Raw **0**, outer **1**, checkpoint and rejected-rerun bytes preserved |

Gate fixtures cover source/tool/part/readiness/review/permission/WORK/argv/cwd/options mutation, native ancestry and symlink escape. Runner cases cover rc0, rc7, rc7 with failed collection, rc0 with failed collection, and signal propagation. Issuer fixtures mock preflight's return only and isolate writes: missing reviews, wrong full coverage, manifest, parent acceptance, report hash and spec linkage reject without mutation; successful fixture issuance rejects replay without changing retained bytes. Fixture issuance is not real authorization.

Separately inspected and programmatically counted **captured remote** results: 274 successful and 32 rejecting actual-entry dispatch invocations, plus two metadata rows; six maintained/copied missing-record entry/shell rejections. Captured final readback records real corrected preflight success, missing-review rc1 and unchanged package/live inputs with authorization/claim/run absent. These are historical captures, **not fresh remote verification by this reviewer**. The preflight log's 448 count is inherited-dependency baseline evidence; the final draft/preservation and checked full dependency dictionary contain 471. Fresh live revalidation remains required at issuance by the existing issuer.

## Issues and final boundary

- **Critical/important must-fix issues: none.**
- Minor documentation debt only: compile-gate opening docstring still says Work08 although executable constants and dispatch are Work12. It does not change behavior or block this exact package. Do not edit the frozen candidate to tidy it during consumption.
- All readiness, functional, timing, constraint-completeness and calibration-association qualification flags remain **false**. Later actual fit/STA/assembly review and Work11 STA comparison are still required; approval of an experiment is not approval of its outcome.

Only this quality report was created in the project. Candidate package, SOURCE, WORK, gate code, historical failed artifacts and real authorization state were not modified. No vendor or remote execution, authorization issuance/consumption, native compile launch, header rerun, Query04/equivalent, DDR simulation, hardware operation, install, permissions change or commit occurred.

**APPROVED for parent consumption of this exact manifest and exact preceding specification report, followed by the already-defined fresh live preflight and once-only compile path.**
