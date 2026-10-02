# Work24 PR-export execution QUALITY re-review28

**Verdict: APPROVED.** I1 and M1 are closed for candidate24. No new blocking regression identified. This approves the corrected execution package, not native export results or hardware access.

Reviewer: GPT-6/openai-codex, substituting for unavailable GLM5.3. Local reads, hashing, AST inspection and in-memory comparisons only; no prepared-script/test execution, native tools, SSH, Git or hardware operations. Only this report is authored. Paths below are relative to `qualification/fim24-pr-platform01/`.

## Binding and preservation

- Verified **20/20** member sizes/SHA256 values in `quality-revision-freeze27.json`, SHA256 `704e0ae7b4a55e361fbc69209ffea37989b155f301cc4ca793bd051d582f4b55`. Rechecked **35/35** predecessor-freeze members unchanged, including candidate15 and its historical receipts/review.
- Recomputed `runner-delta26.patch`; it matches exactly. Outside `native()`, runner bytes are identical except the fixed candidate24 self-path. AST parsing succeeds. All four stage25 transport members match their sizes, hashes and local readbacks; collection script/result bindings and outer rc0 reconcile.
- Candidate and actual staged-readback runner both hash to `829ec7bb96644f3f2730bf43b571c6f40e7e011d1e42e38931f7b680b2275f14`. Draft25 hashes to `03f6514806687c9e5f4f2e68352db6c6518bc702cac4b87452d7b4d640fafe93`. Its only changes from draft15 are runner identity, revision provenance and four correction prerequisites, whose hashes verify.
- Reviewed `stage-runner25.py` and its captured success: complete design/original inventories are compared before and after, and every preexisting prepared15 entry is preserved. Bound inventories reconcile to **4,285** design entries, **6,160** original Work24 entries, **2,541** critical inputs and five static-artifact bindings. Actual entry-rejection25 records missing admission before operation/target creation. New files are confined to prepared15/candidate24 and revision25. This is verification of captured staging evidence, not a fresh remote inspection.

## I1 — closed

`candidate24/run-export24.py:185–250` shares the bounded observer across leader execution, descendant draining and final bytes. It retains the unreaped leader, original deadline, group cleanup and raw CMake status; overflow is explicit and produces effective125. Reads are limited to remaining budget plus one sentinel. The 32 MiB threshold remains a polling watchdog, not a filesystem quota; overshoot during polling/termination is possible.

The same 13-case harness and substituted child commands reconcile across old-fail24/new-pass25:

| Descendant case | Old effective / seconds | New effective / seconds |
|---|---:|---:|
| Gate writer | 124 / 2.570663 | 125 / 0.817314 |
| Overflow writer | 124 / 2.584436 | 125 / 0.839343 |
| Short-lived final gate | 0 / 0.762665 | 125 / 0.745297 |

Old evidence fails precisely these three supervision assertions. New evidence passes **13/13**; all three signals are detected without timeout, below the 1.8-second fixture bound, with raw leader rc0 and empty live-group results. Retained status/result/compressed-result records and available log hashes reconcile. Nonzero propagation, finite drainage, timeout cleanup, postflight failure and rejected-replay preservation remain covered.

## M1 — closed

`test-export-runner24.py:69–84,108–110` now waits for the configure child's own PID/start marker and confirms it is alive before injecting the identity error. Retained marker/proof, raw rc−15, outer failure and empty live-group evidence corroborate cleanup. The earlier instant-child receipt is not relabeled. Admission, CMake, tmux and artifacts remain synthetic; children are real inert Python, not vendor integration.

## Issuance boundary

Base/resource SPEC consumption remains applicable; source, gates, CMake, six contexts, full 36-CPU affinity, 64 GiB per-process limit and 120/60/600-second deadlines are unchanged.

After consuming this review, derive admission from the exact captured **revision25/export-inputs.draft25.json**, not draft15. Bind review/consumption bytes; set `parent_execution_accepted=true`, `resource_delta.final_spec_and_quality_pending=false`, and `runner_revision.quality_accepted=true`. Exclusively write/read back prepared15/export-inputs.admitted.json and pass its SHA to the corrected runner through owned tmux. Preserve inherited license handling without printing/recording values.

Actual IPC serialization, PR A&E/DRC, exported PIM/source closure, static-image/interface matching and independent result acceptance remain first-experiment/result-review obligations. No authority is issued by this report; no card/hardware access is approved.
