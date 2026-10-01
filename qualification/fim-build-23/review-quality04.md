# Work23 — QUALITY/execution review04

## Verdict

**APPROVED for one bounded offline seed3 compile, after parent consumption and the exact live revalidation below. No implementation change is required for that workflow.** This report issues no manifest or runtime authority, launches nothing, and grants no timing, FPGA or hardware acceptance.

Reviewer: **gpt-6-astra-900k / openai-codex**, substituting for unavailable GLM5.3. Review was local, read-only source/evidence inspection and in-memory hashing/AST/comparison; no candidate, test, workstation, vendor or device execution, Git mutation, or source edits. Only this report was written. The consumed SPEC PASS and `ITERATION-BASIS01.md` remain governing: second campaign compile, sole physical delta SEED2→3, unchanged 3.000ns requirements.

## Findings

1. **Frozen package and reuse verified.** All32 `quality-freeze04.json` members match size/SHA256; the prior26 bindings are unchanged. Direct predecessor comparisons confirm runner/gate differ only in E/W roots and CMake/Tcl are byte-identical. All135 unique contexts equal Work22 after WORK-root substitution; all12 runtime hashes and affinity0–35 are unchanged. The3,393 critical inputs,566 preflight-only inputs/roles and nine links remain classified separately. Every context executable has a runtime hash. No new source/design audit or vendor-internal qualification is inferred.

2. **Dispatch and rejection remain bounded.** The runner checks the exact admitted manifest hash, approval, own bytes, CMake, inputs, tools, prerequisites, resources and links before exclusively claiming the operation/lock. It permits only `compile`; CMake's independent target invokes `quartus_sh --flow compile ofs_top -c ofs_top`, not the explicit clear/regenerate-IP or header targets. Runtime authority keeps readiness false. The callback checks exact executable/argv/cwd/hash and live supervisor PID/start/ancestry, rejects stale identities and link escape, and emits the rejection marker without appending a rejection into consumed evidence. The supervisor also rejects Critical Warning125091; Tcl exceptions alone are not relied upon.

3. **Existing supervisor is adequate for this trial.** Spawn protection encloses bookkeeping, retains the unreaped leader through possible group signals, allows finite descendant drain, and escalates TERM/KILL within the owned group. Native budget is10,800s; configure has its separate120s allowance. Affinity and64GiB per-process address-space limit remain intact—not an aggregate memory cap. Raw CMake status is persisted before postflight; nonzero vendor status is not numerically recoverable from CMake alone. Final log scanning catches late gate rejection despite child zero. Failures remain unaccepted; operation evidence prevents replay.

4. **Admission is narrow, not a launcher.** `admit04.py` binds the supplied payload SHA, pinned draft/SPEC, actual four review-file bytes, parent QUALITY consumption and its own `__file__` hash. The intended delta is approval false→true, exactly four added review prerequisites, authority wording and corrected second-attempt wording; contexts/tools/settings stay unchanged. Host/UID/owned-tmux, resources/licenses, absence of consumed state, live input/link/tool/prerequisite hashes and predecessor inputs are checked before exclusive publication. Partial publication is a retained failed attempt, not permission to retry. No native/device subprocess is present.

5. **Evidence coverage is sufficient and limited.** Retained current-byte receipts reconcile eight actual-supervisor inert cases,16 synthetic-identity gate cases, three real local CMake checks, and two actual prepared missing-authority/manifest rejections. The19 admission cases exercise only AST-extracted `validate_delta`; they do not exercise full admission, remote publication or native integration. I did not rerun them. No new full-framework campaign is required.

## Parent-owned conditions before launch

- Consume this actual report and the exact SPEC report; construct real `quality-consumed05.json`, not placeholder approval. Publish the exact reviewed admission script at remote E23/admit04.py, bind its SHA and the complete future payload SHA, and use unoptimized Python with `PYTHONOPTIMIZE` unset. Assertions are not effective under `-O`.
- **Explicit preservation-binding condition:** immediately verify remote `E23/original-source-pim-inventory01.json` against the SHA below before admission. Lines69–70 iterate that file but do not independently pin its bytes or cardinality; it is absent from the draft's hashed maps. Parent exact live revalidation must supply this check, not merely trust the returned count. With that binding, its1,891 SOURCE/PIM checks use the reviewed inventory. The Work22 successor inventory is already prerequisite-hash-bound. This requires an ordinary-file hash check, not another experiment or changed manifest field.
- Require successful admission and read back the exact four published review files and stage manifest; verify the permitted delta and actual manifest SHA before separate runner invocation. Preserve exclusive failure state. Refresh host/UID/tmux, affinity/QSF count, memory/disk/licenses and no-competing-operation checks; never replay an old operation. Independently observe native executable/hash/argv/cwd/ancestry and retain completion/status evidence.

## Exact SHA256 bindings

Paths are relative to this directory; D=`prepared01-readback`. Remote E23=`/home/uwb_student00/ahls/new_BSP/qualification/fim-build-23`.

| Artifact | SHA256 |
|---|---|
| `quality-freeze04.json` | `bc565525a20dfc4d11a859e791919563906315f9f5bf9981bc9bcdccd32313cb` |
| `review-spec02.md` | `592f7c1be51193159c0dc76e507931bf39862ec84a91e79d2664395ba25f4668` |
| `D/compile-inputs.draft01.json` | `51aa191991f930eb9b245c205bef1a4dc867bd7d6045c08a26f6f6016b187165` |
| `admit04.py` | `c8f1220e2d8f10e3c3e0dcdb3c902f9c47949e1d7b4b85406f5017f31f4b7a4f` |
| `candidate02/run-compile30.py` | `a68681330f3aa0fdf21facac51b04e9dfd8d00a64273d6221ae4c158d7ff5bfc` |
| `D/original-source-pim-inventory01.json` | `ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9` |

Ordinary trusted-vendor-account execution is assumed; these guards are not an OS sandbox. Retain original inputs/artifacts. Native zero is not timing acceptance: reconcile complete fit/STA, all five corners of the exact transfer without exception, unchanged constraints/coverage and required markers. Identical recurrence stops blind seed iteration. PIM/equivalence, electrical, reset, PR/freeze, persona and hardware findings remain open for later acceptance, not new pre-fit blockers.
