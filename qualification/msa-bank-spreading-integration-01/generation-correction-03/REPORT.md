# Candidate03 S1 correction — local evidence, pending independent re-review

## Outcome

Fresh `../generation-candidate-03` corrects only the timeout process-group defect identified in `../generation-spec-review-02.md` (SHA256 `640ec6bace2de43f6af5d1c4fac52dec1ccb5eb1ae24539036a66132b460fd40`). Candidate02 and all 113 previously existing qualification files are byte-preserved. The historical review is MUST-FIX evidence, not an approval.

Candidate03 package-manifest SHA256: `8da56f00d8e49f95fe1d3fbd90812440cd7c5af39f8bd4d267b3c360e9b9543c` (35 entries; 36 package files including manifest).
Runner SHA256: `4ab5a5e10a78afc2029e7aaf868b99553de173a581407a38f88718904b397e12`.

## Narrow production correction

The runner retains the unreaped `start_new_session=True` child as the owned PGID/session identity. It sends TERM, gives the group a full ten-second grace regardless of launcher exit, then sends KILL to the same group. It tolerates ProcessLookupError for both signals. It checks live members of that group for up to ten further seconds before reaping; Z/X states are not live writers. No unrelated process is signaled. A still-live uninterruptible member is recorded as `timeout_group_terminated=false`, not silently declared dead; rc124 and failed evidence remain intact without an unbounded wait. This is not containment for descendants that deliberately leave the process group.

No generic monitor, native command, checker or hardware-contract redesign. The Tcl change is solely its callback package path. Execution-binding changes solely the package path in the script argument. Complete SOURCE (1,360 files), PIM (530 entries), and dependencies (419) are exactly preserved. All readiness stays false.

## Actual inert results

- **RED:** `/usr/bin/python3 -B test_timeout.py`, cwd `/tmp/msa-red03-c6bxv4xl/candidate`, exit **1**, one regression failed. Actual predecessor runner returned rc124 after 1.006 seconds; descendant PID329161 in PGID/SID329159 remained **S/live**. Exclusive rerun already preserved all bytes. The fixture then killed/reaped only its owned descendant. Saved original RED test is `red-test_timeout.py`; `red-inputs.json` binds the complete temporary copy.
- **GREEN:** `/usr/bin/python3 -B -m unittest -v test_candidate test_timeout`, cwd `/tmp/msa-green03-21g8monl/candidate` (also recorded in `green-command.json`). Exit **0**, **14 tests passed**: all twelve byte-identical existing tests plus two S1 tests. Real timeout returned rc124 after 11.063 seconds; descendant PID331754 in PGID/SID331753 was **Z/dead**, not live, immediately on runner return. The fixture adopted and reaped it afterward. Exclusive rerun preserved all retained bytes. Separate absent-group regression verifies both signal races preserve rc124/failed result and no intermediate wait/poll reaps the leader before KILL.
- Both commands unset PYTHONOPTIMIZE and set PYTHONDONTWRITEBYTECODE=1. Only inert Python is launched; absent-group Popen is mocked, never executed. Complete commands, environment overrides, exits and stdout/stderr are retained in `red-command.json`, `green-command.json`, `red.log`, `green.log`.
- Existing tests continue to reject missing reviews before work, claim, log, vendor launch or subprocess inspection. No review/claim is supplied in candidate03.

`msa-inert-timeout-nwx4smxd/` retains RED fixture claim/invocation/log/stage result/final result and on-return observation. `msa-inert-timeout-xrtvwqt1/` retains GREEN equivalents. These are clearly local inert fixtures, never vendor results or real generation claims.

## Exact changed inventory and preservation

`changed-inventory.json` gives before/after SHA256 for all seven successor deltas: run_generation.py; new test_timeout.py; package-only retargets in execution-binding.json and save_reload.tcl; REVIEW.md; SUCCESSOR.md; package-manifest.json. `correction.patch` contains the complete text delta. The original test_candidate.py, compare_memory.py, baseline and tool/dependency captures are unchanged. `verification.json` records manifest completeness, full predecessor preservation, binding/Tcl equivalence, and current local hashes of the three already-integrated SOURCE files matching the unchanged local integration receipt. No SOURCE file was edited.

Original WORK `work_ia840f_msa_generation_01` remains bound. Captured predecessor `generation-package02-result.json` documents WORK/run/review absent and vendor_launched=false. This task made no remote contact and does not claim a fresh live remote absence check; actual preflight must reject any existing WORK/RUN. No old consumed claims may be reused.

## Review and transfer handoff

1. Independent focused specification review of S1 and its evidence.
2. Only after specification acceptance, independent quality review.
3. After the appropriate review barrier or separate follow-up, transfer the complete **36-file candidate03 directory**, without run records or consumed-review.json, from:
   `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/msa-bank-spreading-integration-01/generation-candidate-03/`
   to fresh remote:
   `/home/uwb_student00/ahls/new_BSP/qualification/msa-bank-spreading-integration-01/generation-candidate-03/`
   on `uwb_student00@100.101.227.97`, using the owned `ia840f_mailbox_monitored_01` tmux workflow. Exact per-file source/destination hashes are in `transfer-needed.json`. Verify complete manifest and absence of remote review/run/WORK; preserve candidate02 and all integration receipts. Candidate03 has **not** been remotely staged or live-validated. No SOURCE reintegration is needed.

No approval was self-issued. No authorization consumption, native generation, compile, Query04, DDR simulation, hardware action, installation, permission change, commit or push occurred. Timing, functionality, generated-interface acceptance and native acceptance remain unproven. The original integration receipts and failed-timing evidence are untouched.
