# Work23 prepared successor — SPEC review02

## Verdict

**PASS — the prepared package complies with the seed-only successor specification. No blocking SPEC gap found.** This is not QUALITY/execution approval, native admission, timing acceptance or hardware authority.

The governing scope is `ITERATION-BASIS01.md` and `../../GOAL-PROMPT-MIGRATION.md:192–205`: Work23 is the second bounded full compile within the 1–3-attempt budget, at unchanged 3.000 ns. Work22 remains timing-rejected; seed3 is an eligible experiment, not a promised correction.

Reviewer: **gpt-6-astra-900k / openai-codex**; preferred GLM5.3 was unavailable. Review used local captures, source text and in-memory Python comparisons/hashing only. No workstation/SSH, vendor tools, source-script/test execution, Git mutation or implementation edits. Only this report was written.

Paths below are relative to `qualification/fim-build-23`; **D** means `prepared01-readback` and **P** means `../fim-build-22`.

## Verified compliance

1. **Frozen evidence and predecessor.** All 26 `review-freeze01.json` members match their sizes/SHA256. The preparation collection matches its compressed capture and all seven decoded readbacks. Work22’s completion capture matches all eleven decoded members, terminal status and reusable inventory: native/CMake/effective zero, no remaining owned groups, and no active vendor processes recorded. Its consumed `timing-review49.md` retains the exact five-corner hold results +0.132/+0.167/+0.047/+0.006/−0.004 ns, with No SDC Exception on Path. Native completion does not reverse timing rejection.

2. **Exact physical delta.** Comparing `candidate01/ofs_top.qsf` with the actual completed Work22 QSF proves exactly `SEED 2` → `SEED 3`. No stale pre-migration QSF was substituted. Device, macros, native high-performance/maximum-placement settings, router/hold effort, bit243 retiming-OFF, snapshots and processor assignment are unchanged. All 45 inventoried SDC entries are unchanged, including the selected four-line PCIe divider and fit-only10ps/STA-skip behavior; `pr_assignments.tcl` is unchanged. No timing relaxation, geometry/floorplan edit, exception, waiver, clock retune or new feature appears.

3. **Complete input accounting.** `D/work-input-inventory01.json` has exactly the predecessor completion inventory’s 3,963 keys, excluding DB/QDB/output trees. Programmatic comparison finds 3,793 unchanged entries and exactly 170 changed entries: 169 relocations (167 text, two symlink) plus two overlays, with the gate overlapping both sets. Every before/intermediate/after hash or link target reconciles with `relocations01.json` and `overlay-delta01.json`; sizes/modes are retained. The audited preparation performs literal old-WORK-root substitution, followed only by QSF and gate overlays. HDL/HLS/header inputs are retained; no separate HLS or explicit clear/regenerate-IP target is invoked. Completed Work22 `build_env_db.txt`, `fme_id.mif` and QPF bytes are retained, not replaced by stale pre-fit metadata.

4. **Preservation is scoped accurately.** The captured preparation rechecks original Work22 input bindings, four image/intermediate hashes and static-QDB hash before/after copying. Those image/QDB records match completion51. The 1,891 original SOURCE/PIM hashes equal the retained Work21 maps (1,361 SOURCE, 530 PIM); preparation revalidates them against consumed authorization `793eece9892980e7c7bb0daa383a47838c21c1fd679768c033eb6db6038060a8`. These are captured named-domain checks, not a fresh remote inspection, current-local-mirror equivalence, or unrecorded whole-tree preservation claim.

5. **Execution rebinding is mechanical.** Gate and compile runner equal their predecessor bytes after only E/W-root substitutions; CMake/Tcl callback bytes are identical. Root constants agree, and Tcl resolves the adjacent gate. All 135 unique executable/argv/cwd contexts equal Work22 after WORK-root replacement only. All twelve runtime hashes, affinity0–35, 3,393 critical-input keys, 566 preflight-only keys/roles and nine links retain their classifications. The draft binds 3,962 WORK entries; QPF remains the already-declared metadata exclusion, retained in preparation inventory for comparison. Eleven prior prerequisite hashes remain provenance, with eight explicit additions—not reusable operation tokens. Independent reconstruction of every manifest field matches the draft exactly.

6. **Guard evidence is correctly limited.** Retained receipts reconcile eight actual-runner inert cases, sixteen gate fixtures and three local CMake checks; none establishes native integration. Actual copied Tcl rejected missing authority and the new runner rejected missing `stage-inputs/compile.json`, both rc1. The bound preparation asserts no operation, stage-input directory or lock was created and WORK remained unchanged. `parent_execution_accepted=false`, `authority_issued=false`, `native_tools_executed=false` remain intact.

Informational only: inherited `validation_scope` still says “First full native…”; the explicit Work23 basis/predecessor correctly identify the second campaign attempt. This does not reset the budget.

## Native admission still outstanding

- Parent must consume this exact SPEC review and complete/consume the separate execution/gate review. This review supplies no execution approval.
- Revalidate exact prepared inputs/links, runner/CMake/tools, prerequisites and predecessor preservation; bind a fresh parent-accepted `stage-inputs/compile.json` and its exact launch hash. The false draft is not authorization; do not replay consumed IP/header/Work22 operations.
- At admission, verify Agilex7Workstation/UID1000, owned `ia840f_mailbox_monitored_01` tmux, unchanged full affinity/QSF count, memory >80,000,000,000 bytes, disk >20,000,000,000 bytes, license environment and no competing vendor process. Preserve 64GiB per-process limit and finite deadlines.
- Require absent `operations/compile` and exclusive `native-operation.lock`; the compile-only runner must issue fresh live-supervisor-bound authority with readiness false. Independently observe the actual native executable/hash, argv, cwd and ancestry after dispatch. SPEC PASS launches nothing.

Actual acceptance still requires completed fit/STA, every summary record, exact transfer nonnegative at all five corners without exception, unchanged clock/constraint coverage and fit/STA markers. Compare sites and compensation/data/clock terms; identical recurrence stops blind seed iteration. Electrical, PR/freeze/reset, PIM, persona and hardware findings remain open—not new blockers for this offline trial.

## SHA256 binding

| Artifact | SHA256 |
|---|---|
| `review-freeze01.json` | `ee657f0ae78609b3126e393d0d5ced003b12a80001f4f58fc9229a9edf351a23` |
| `D/compile-inputs.draft01.json` | `51aa191991f930eb9b245c205bef1a4dc867bd7d6045c08a26f6f6016b187165` |
| `D/work-input-inventory01.json` | `09ce64a5bf21f50bd57790cdbb7e4f4fb7ccda77201de9c6bab0aff82b1722e5` |
| `P/compile-inputs31.json` | `17cc563665ea726b2ed48115a3fc6572a8fd795e3a596dc2efe47294b98214ca` |
