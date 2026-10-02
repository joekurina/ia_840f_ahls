# Migrated CAPS03 fabric execution QUALITY review13

**Verdict: APPROVED.** No blocking execution-package defect identified. Approval covers the staged import/generation package and the stated parent issuance procedure, not generated-fabric acceptance or hardware authority.

Reviewer: GPT-6 (`gpt-6-astra-900k`, `openai-codex`), substituted for unavailable GLM5.3. Local reads, in-memory hashing, AST inspection and data comparisons only. No repository scripts/tests, native tools, SSH, Git or hardware were executed. Only this report is authored. Paths are relative to this directory unless indicated otherwise.

## Critical

None identified.

## Important

None requiring changes before the bounded first native experiment.

### Frozen package and actual staging

- Independently verified **27/27** member lengths/SHA256 values in `quality-freeze12.json`; no mismatches. Freeze SHA256: `d27110295940b02f3c99f8723049f731a3d4eda07a5cfdfb4f2e58c96dd9eb4e`. Also rechecked **29/29** source-freeze members and the review06/consumption08 bindings.
- Reconciled stage11 collection script/result hashes, outer rc0, all **eight** embedded readbacks and their byte lengths/hashes. Staged runtime/CMake exactly match candidate08. The stage input transport also matches its script-pinned digest and all ten transmitted source/control/prerequisite payloads.
- The **228-entry** draft inventory exactly equals `prepared-inventory11.json`; against prepare03, only the composition descriptor changes. Its full byte delta is exactly `altera_axi_bridge 19.9.3` → `19.10.3`, identical to candidate05. The **224** copied report paths retain exactly the three preexisting LSU overlays; all **155** HLS expectations reconcile with original/corrected input hashes. No new parameter, Tcl topology or HLS changes are admitted.
- The draft's release-result digest matches the retained actual Work24 result and its **3,454-entry** inventory. UUID remains `fc603c44-5c8f-5e94-bcbe-a5780030947c`; acceptance39 and consumption38 hashes match the bound prerequisites. The historical raw export rejection is preserved and separately dispositioned, not silently converted into success.
- `entry-rejection11.json` records the actual staged Python entry rejecting missing admission with rc1 before operation/generated-IP creation. Preparation reports original-report/release preservation and no authority/native execution. These are verified captured staging observations, not a fresh remote inspection.

### Execution, ownership and failure handling

- `candidate08/run-fabric08.py:57–88,151–161` binds the exact admitted digest, fixed roots/self/CMake, prerequisites, tools/helpers, complete prepared file set, original report, release inventory/UUID, CPU affinity and available resources before exclusive operation creation. Host/user/owned-tmux and active-tool checks precede native work; spent operation replay cannot overwrite prior evidence. License variables are inherited without dumping their values; explicit stale tool/library/PIM environment variables are removed.
- Both CMake vendor command arrays exactly match `proposed-commands05.json`, including literal `,$`, package26.1 and the part. Targets have no dependency edges that repeat import. Help07's hash-verified no-project results support omitted qsys parallelism; CMake `--parallel 1` serializes targets, not internal qsys workers. The package retains 36 CPUs, QSF36, 64 GiB per-process and 60/60/180/600-second command deadlines.
- Independently proved `native()` byte-identical to accepted export candidate24 except the two zero-propagation label tuples; its dedented digest matches proof12. Immediate post-spawn protection, unreaped leader, original deadline, descendant-drain/final-byte observation, TERM/KILL cleanup, raw CMake status and effective failure remain intact. CMake nonzero is not mislabeled as an individual vendor exit code; postflight exceptions cannot create success.
- Before generation, import requires zero status, no detected Error/Fatal/rejection diagnostics, both markers, exactly eleven distinct expected interface names and every discovered child-IP error flag false. Postflight requires expected Qsys/QIPs, 155 matching emitted HLS hashes and all named preservation domains. Source-script drift is not exempted by the QPF/QSF metadata allowance.

### Retained verification

Read the actual harness and reconciled **16/16** fabric cases: clean, preflight/version/marker/interface/child-IP rejection, native nonzero, HLS/output/copy/release faults, generic diagnostic, drain rejection, overflow, proven-live post-spawn failure and postflight failure. All applicable cases retain empty live-group and byte-preserving replay evidence. **Five** CMake configure/help/rejection checks bind the reviewed CMake bytes without vendor-target execution.

The source/hash-matched predecessor harness and **13/13** retained export cases preserve TERM-resistant timeout, finite drainage and post-leader rejection/overflow/final-byte coverage. Admission/CMake/tmux and tiny artifact maps are mocked; children are real inert Python. None of these receipts proves native fabric integration, and no tests were rerun for this review.

## Minor

Nonblocking precision limits: the 32 MiB log limit is polled, not a filesystem quota; memory is per-process, not aggregate containment. QSF identity checking is required-line presence, not effective-assignment resolution. Full captured QPF/QSF changes therefore still require result review, including conflicting assignments. Generated port widths/footprints, complete QIP/HDL closure and matching-PIM simulation remain separate acceptance obligations, not preconditions to launching this experiment.

## Issuance boundary

Derive admission only from stage11 draft SHA256 `dec543a841303c9e5e728d620c5381f65f0aaebcf03014b929395f79c05ec270`. Preserve its inventories/resources/bindings, add this review and parent-consumption/prerequisite hashes, explicitly set `parent_execution_accepted=true`, retain `hardware_ready=false`, and exclusively write/read back `prepare08/fabric-inputs.admitted.json`. Pass that readback SHA to the fixed `prepare08/runtime/run-fabric08.py` once through owned tmux, using unoptimized isolated Python as in the staged rejection. Preserve failures and consumed claims. This review itself issues no authority; no HLS resynthesis, persona build or hardware access is approved.
