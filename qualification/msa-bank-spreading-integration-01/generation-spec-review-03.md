# Independent specification re-review — candidate03

## Verdict: specification PASS

S1 is resolved for the owned stage process group. No remaining specification must-fix was found in this focused re-review. This is **not quality approval**, authorization consumption, native acceptance, or an execution/readiness assertion. Independent quality/execution review remains next, before remote staging/readback and once-only native execution.

Reviewed package-manifest SHA256:
`8da56f00d8e49f95fe1d3fbd90812440cd7c5af39f8bd4d267b3c360e9b9543c`

Reviewed runner SHA256:
`4ab5a5e10a78afc2029e7aaf868b99553de173a581407a38f88718904b397e12`

## S1 behavior and independent evidence

Read the previous MUST-FIX review, correction report/patch/inventories/verification/transfer record, complete successor runner, both test files, package manifest and review documentation. The predecessor's accepted memory-generation scope is retained rather than reopening broad tool discovery.

- `run_generation.py:98–128,156–164` keeps the actual `start_new_session=True` child unreaped after TimeoutExpired. Its PID therefore reserves the owned PGID through both signals. There is no intervening wait/poll and no arbitrary PGID lookup/signaling. TERM is followed by a full ten-second grace and KILL to the same group independently of launcher exit. ProcessLookupError is tolerated at either signal without replacing rc124.
- The bounded post-KILL check treats Z/X as dead, not live writers; it does not reap the leader before the last group signal. Remaining live members produce `timeout_group_terminated=false`, retain rc124 and failed evidence, and avoid an unbounded child wait. This is not a containment claim for descendants that deliberately leave the group, nor a guarantee that SIGKILL can remove an uninterruptible task.
- Reproduced all **14 tests**, exit **0**, in a fresh local package copy at `/tmp/msa-spec-review03-34cvshu3/candidate`, using `/usr/bin/python3 -B -m unittest -v test_candidate test_timeout`, with PYTHONOPTIMIZE unset and PYTHONDONTWRITEBYTECODE=1. The existing twelve tests are byte-identical. The actual fork regression returned rc124 after 11.074 seconds; descendant PID335498, PGID/SID335497, was Z at return, with no live descendant and unchanged evidence on rejected rerun. The second new test exercises absent-group signal races and no premature wait/poll.
- Independently authored and executed `/tmp/msa-spec-review03-34cvshu3/probe.py`, not merely the submitted tests. Its actual inert Python stage forks a TERM-resistant descendant that repeatedly appends to a file. The actual runner returned rc124 after 11.060 seconds. A wrapper around real killpg observed leader PGID336565 in S at TERM and still unreaped in Z at KILL, with at least ten seconds between signals. The writer was Z at runner return; all retained bytes remained stable across a further observation interval and a rejected rerun. Cleanup evidence was true. The local fixture adopted/reaped its own orphan afterward.
- The independent probe also supplied a **synthetic** persistent D-state /proc observation and mocked clock/process/signals through the actual runner. It verified rc124, `timeout_group_terminated=false`, failed final result, both signals targeting only the supplied owned-child identity, and no additional child wait/poll. This tests the bounded failure branch; it is not a real kernel D-state experiment.

Retained fresh local evidence:
- `/tmp/msa-spec-review03-34cvshu3/tests.log`, SHA256 `c93a258d16dbfa38254d8d4cdb0ee9b9a74a1ed7bd624aaf6374ffd9a37cd841`.
- `/tmp/msa-spec-review03-34cvshu3/probe.log`, SHA256 `ddd3c4a2a8145ca702f7dabae94d74e79779b7979e63d6d0f750130fac8b8b00`.
- The same temporary root retains inert fixture claims, invocation/log/result records and the independent probe source. None is a vendor result or real generation claim.

## Minimal delta and preservation

Independently rehashed all **35 manifest entries** and all **36 package files** including the manifest; the manifest covers the complete package. Rehashed after testing: candidate03 is unchanged and contains neither run nor consumed-review.json.

Computed the complete predecessor/successor hash delta and matched changed-inventory.json exactly: **seven paths only** — run_generation.py, new test_timeout.py, execution-binding.json, save_reload.tcl, REVIEW.md, SUCCESSOR.md, package-manifest.json. Tcl and execution-binding text are exactly the predecessor with the package path retargeted. The runner's only behavioral delta is S1 cleanup and its outcome field. Existing test_candidate.py, compare_memory.py, all captured baselines/help/tool bindings and the review template remain byte-identical. All 36 transfer-needed records match the actual local package inventory.

Rehashed every entry in preservation-before.json: **113 preexisting qualification files preserved**, including candidate02 and historical evidence. The three currently integrated local SOURCE files match the unchanged integration receipt. Unchanged execution bindings still contain 1,360 SOURCE files, 530 PIM entries and 419 dependencies. This confirms preserved bindings and current local integrated-file bytes, **not a new live remote inventory**. No hardware-contract/source/gate change was introduced. The previously accepted two scoped FIFO 8→0 changes, copies1 constraint, full saved/generated checker, exact device and native memory-only sequence remain unchanged.

## Boundaries and next barrier

Candidate03 remains local-only; no remote call, transfer, live remote check, authorization consumption or vendor execution occurred. Captured inventory/absence evidence is historical, not current remote preflight. After independent quality acceptance, staging must read back the exact package and live preflight must still check SOURCE/PIM/tool dependencies and absent WORK/RUN; failed attempts must never be reused. Strict saved drift remains a legitimate preserved rejection, not grounds to relax the checker.

All readiness stays false. Work11's completed-but-failed-timing evidence remains the baseline. Generation, native compatibility, generated-interface acceptance, calibration association, functionality and timing are still unproven. No compile, Query04, DDR simulation, hardware action, installation, permission change, commit, SOURCE/gate edit or general framework was introduced. Only this report was created in the qualification tree, outside the reviewed package; test/probe artifacts were written solely under fresh local temporary paths.
