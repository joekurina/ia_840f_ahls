# Work12 compile-candidate-01 — independent specification review

## Verdict: PASS

Specification compliance passes for the exact frozen candidate described below: preparation for one native full compile from the accepted actual postheader WORK12. No must-fix specification gap found. This is the specification review only, not quality review, parent acceptance, authorization issuance/consumption, native execution, or result qualification. Quality review must follow this report and bind its hash; parent must read and accept both before the fresh issuer may be used.

## Exact reviewed identity

All **62 payload mappings** in `compile-candidate-01/review-package-sha256.json` are covered by this verdict, without exclusions (including preserved failed-preflight artifacts as history only). Python independently hashed every payload, checked the actual 63-file package count, and found zero mismatches. Final recheck after the inert tests also passed. The manifest is the exact payload mapping for any later review envelope, not a selected subset.

| Artifact | SHA256 |
|---|---|
| Candidate manifest | `15687a2e812b78101246a66a57edc8e5991ef596a361d4de46e898afc8cc4836` |
| Review archive | `8c231cafcb7746378fd3f9f22edc167bf98f4b5352a30c072a683a5c37c0d6ab` |
| Compile draft | `2dac6b722902eb5c141107f8f93b550f72b298f49d1b31f960acbb6c9493d5ea` |
| Issuer | `c831dd5d99b7e795d3032e3a27ea33a8e847d7ee6d297c5fad4faaa1d2ca9752` |
| Runner | `80bb3835eb77f15e0375c118c423ed57c1a2d2320620ecd150a0213d2e96664a` |
| Accepted header-result review 02 | `708f9e564b5ce1852ad35f2636c3a9a871025de4ae0f8c958c6e69fe3659bf95` |
| Actual postheader inventory | `da828e3203f2019951fa370f103d6c22d6e3c20906949c16e1fd46ac79d1d4c3` |
| Captured final remote readback | `e235bbbac585470573c7170cb48593496b3ec8f7b895620ba38b02883fe5fd6b` |

Read the preparation report and complete README, accepted header result, issuer, runner and diff, compile gate, relevant experimental dispatch/monitor and shell/Tcl guards, test implementations and captured results. Parsed the full draft/inventories/context tables and provenance bindings rather than treating summary counts as proof. Accepted MSA/interface/ASP findings remain prior engineering evidence; this review does not repeat their engineering qualification.

## Specification findings

1. **Actual accepted state, not a preheader fixture.** Python full-dictionary comparisons show draft SOURCE equals both actual issued-header SOURCE and integration-receipt `source_after`; PIM equals the issued-header PIM; WORK equals the actual postheader inventory. Counts independently computed: SOURCE **1361**, PIM **530**, WORK **5277**, dependencies **471**. All **448** inherited header dependency paths and hashes remain exactly present. Actual-result and accepted-correction provenance is additional binding, not reuse of consumed approval.
2. **Exact finite native scope.** All **135** context dictionaries equal the Work11 issued authorization after only literal `work_ia840f_fim_11` to `work_ia840f_fim_12` replacement. Independently evaluated the pure `allowed_commands()` function and matched its entire ordered argv list to the draft. The corrected issuer reconstructs each exact `/opt/altera/26.1.1/quartus/linux64/<argv0>` executable and hashes it, avoiding the incomplete common runtime map without widening grammar. Runtime acceptance still requires exact executable/hash/argv/cwd plus live ancestry of the exclusive native bash claim. Gate-copy files match both complete SOURCE and WORK inventory hashes. WORK12 dispatch selects the compile gate except for the separately exact historical header argv.
3. **No source reintegration or work recreation.** Issuer reads inventories, dependencies, native contexts, package and review records before its first exclusive lock. Only the new lock, consumed review evidence and fresh compile record can be created. It contains no SOURCE/WORK integration writes and does not launch the runner. Existing header authorization/claims are provenance, not replay targets. Initial failed issuer/draft/manifest and failure log remain separate immutable package payloads.
4. **Fresh reviews and once-only scope.** Issuer demands exact manifest hash, exact full payload coverage by both accepted reviews, hashed report files, quality linkage to the spec hash, distinct report paths, and explicit parent acceptance before creating the lock. Source/live-state checks and absence of compile record/claim/run/issuance evidence precede this. Exclusive lock, consumption file and authorization record prevent reuse. Runner independently validates record/environment/initial WORK before exclusive run-directory creation; native entry claims exclusively before build logs and requires the exact command. These are trusted source-bound controls, not an OS sandbox or a cryptographic proof of reviewer independence.
5. **Native command/environment unchanged.** The runner executes, from `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`, exactly `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12`. Explicit 26.1.1 bin and sopc_builder PATH, Quartus root, PIM root, and all three license variables are set. Seed, variant, analysis-only and hook overrides are cleared. No watchdog is introduced. The compile stage does not select setup or finish/release.
6. **Preservation and expected native changes are distinguished.** SOURCE QSF hash is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`; WORK QSF hash is `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`. Full QSF diff contains only accepted native maximum-placement migration and version metadata. Seed2, hold ON and maximum placement remain. No new geometry, clocks/SDC, PF/BAR/pins or calibration-routing delta is introduced. Initial WORK byte equality is checked before native launch, not required after the native IP-generation post-module exporter refreshes outputs.
7. **Failure evidence and acceptance remain separate.** The narrow runner diff persists raw child status before fallible log reading and retains native nonzero/signal status when collection fails. Native zero plus collection failure returns nonzero. The monitor and runner reject stable gate markers, including Critical Warning (125091), even if native exit is zero. Fit/STA/assembly acceptance remains pending report review; the runner's mechanical native-exit field is not a general diagnostic/timing/functional acceptance verdict. A failed or rejected run retains exclusive evidence and is not retried.
8. **Engineering exclusions preserved.** Accepted FIFO0/copies1, 128-port wrapper coverage, sparse-header consumer evidence and malformed-but-unconsumed ASP collateral are retained, not repaired or reinterpreted. Existing default standard-exerciser AFU is not AHLS functionality. All draft readiness, functional, timing, constraint-completeness and calibration-association flags are false. These unresolved qualifications do not block this unchanged-constraints experiment, but require later actual result review and Work11 STA comparison.

## Independently exercised local inert tests

Copied only Python test/issuer/runner/gate files into a disposable `work12-spec-inert-*` temporary directory; executed with Python `-B`, no vendor executable and no real authorization. Production remote paths and identities were not represented as locally exercised remote state.

| Command in temporary copy | Actual local result |
|---|---|
| `python -B -m unittest test_compile_policy.CompileTests -v` | Exit 0; **7 tests PASS** |
| `python -B test_runner_inert.py` | Exit 0; **5 cases PASS** |
| `python -B test_issuer_inert.py` | Exit 0; **8 cases PASS** |

Gate tests independently mutate source/tool/part/readiness/review/permission/WORK/argv/cwd/options and reject symlink escape; positive native claim replay preserves prior bytes. Runner cases use real inert Python children: rc0, rc7, rc7 plus log-read failure, rc0 plus log-read failure (outer rc1), and SIGTERM (raw -15, outer 143). All preserve raw status and rejected-rerun evidence. Issuer fixtures mock only preflight's returned state and isolate all writes; missing spec/quality, wrong coverage/manifest/parent/report/order reject without mutation, and successful fixture issuance rejects replay without changing retained files. None is real compile authorization.

Captured remote evidence, separately reviewed rather than rerun locally: policy **7**, actual copied/WORK dispatch **274 successes + 32 rejections** (plus two metadata rows), six actual maintained/copied missing-record entry/shell rejections, runner **5**, corrected issuer **8**. Python parsed and counted the complete captured dispatch and shell arrays. Captured final missing-review invocation returns rc1 after real preflight, with package/live-state checks passing and authorization/claim/run absent. Real preflight originally failed on missing `quartus_syn` map coverage; the corrected exact-path reconstruction and preserved failure are consistent with the final successful capture. This reviewer made no fresh remote live-state claim; issuance must rerun the real preflight as designed.

## Boundary and deliverable

Only this report was created in the project; candidate package, SOURCE, WORK, gate code, historical evidence and authorization state were not modified. Disposable inert fixture files were removed by their temporary-directory contexts. No remote/vendor execution, compile launch, header rerun, Query04/equivalent, DDR simulation, hardware operation, install, permissions change or commit occurred.

**Next permitted review step: independent quality review of this same exact manifest, followed by explicit parent consumption.** This PASS does not itself authorize or consume the once-only native compile.
