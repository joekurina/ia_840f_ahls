# Independent specification re-review — B1/B2

## Verdict: PASS for the bounded B1/B2 fixes

The original B1/B2 blockers are resolved for the **PARTIAL, nonvendor, fixed-three-probe experiment**. This is a specification-review verdict, not full-proposal acceptance, proof of installed isolation behavior, or execution approval. Quality review follows separately. `authorization`, `ready_for_build`, and `vendor_run` remain false; no approval/input value was changed.

Reviewed manifest SHA-256: `3b98d1769e4ed29944cf0c8db917a5d0280c9bed0622b12ed5e95083fd9fc9ac`.

## B1 — ownership before signaling: resolved

Relevant current code: `preflight.py:60–142`, `359–434`, `457–496`.

- The trust anchor is the controller's direct fork-created supervisor. Before its initial pidfd acquisition, it has not been reaped, so its numeric PID cannot identify a replacement. The supervisor creates exactly one subprocess and never launches a replacement child. That restriction is essential to the ownership argument; an arbitrary ancestry check without it would not suffice.
- The info-pipe PID is now only a candidate. `launch_init_pidfd` requires its parent to be a direct child of the owned supervisor, acquires parent and candidate pidfds, compares the earlier candidate identity against new observations, and rechecks the parent and supervisor identities. Comparisons cover PID, PPid, start time and PID namespace. Live-handle checks reject exit during validation. A supervisor reaped by an earlier loop iteration cannot be accepted later: its retained pidfd is no longer live.
- Candidate namespace identity must differ from the parent namespace, the parent must share the supervisor namespace, and NSpid must describe namespace PID 1 at one additional depth. These tests are combined with launch ancestry, not substituted for ownership. The design does not rely on the info pipe, namespace difference, NSpid=1, or start time alone.
- An unrelated process cannot satisfy the single-child ownership chain merely by replacing the numeric info PID. Parent replacement or reparenting fails the repeated identity/ancestry checks or live-handle checks. Once acquired and accepted, the pidfd remains bound to that process even if it exits immediately after the last check.
- Promotion is the successful function return, assigned to `initfd, init` only afterward. Validation/acquisition failure closes temporary handles without signaling them. The attempt's `finally` receives no rejected init handle; it stops only the already-owned supervisor and records unknown teardown. Ancillary-handle close failure occurs before promotion and also prevents the candidate from becoming signalable.
- Unsupported installed bwrap ancestry fails closed. This review does not claim that the particular workstation bwrap will expose the required chain or that the short controls probe always remains alive long enough to validate it. Safe inconclusive results are allowed.

The new negative tests traverse the actual attempt/finally path for stale/reused candidates, a stable unrelated init, candidate identity change, and invalid/missing NSpid. Their assertions exclude both rejected-init signaling and unintended numeric-PID fallback. The positive mocked chain and acquisition/close-failure tests supplement, rather than establish, the ownership argument above.

## B2 — terminal reserve and independent cleanup: resolved

Relevant current code: `preflight.py:51–57`, `258–356`, `363–381`, `480–496`, `594–619`.

- Ordinary receipts are limited to `MAX_OUTPUT - TERMINAL_RESERVE`; `final.json` alone can use the 16384-byte terminal reserve inside the existing 67108864-byte receipt allowance. Terminal filename/use is checked. Charging before open/write conservatively accounts for partial failed writes, and exclusive creation preserves existing evidence.
- Terminal output no longer duplicates accumulated payload events. It retains status, false flags, primary error, attempt count, root, and cleanup reports. Oversized cleanup details are reduced to bounded summaries and force INCONCLUSIVE. Actual primary errors are already shortened and the fixed attempt/listener counts bound the remaining structure. Ordinary evidence exhaustion therefore cannot consume the reserved terminal space.
- Cleanup runs before the fallible pipes receipt. Each validated-init/supervisor signal is separately guarded; one failure does not suppress the other. Missing supervisor pidfd permits only the direct unreaped child's numeric-PID stop. Reaping uses WNOHANG and shares a fresh two-second supervisory budget with init-exit and namespace checks. Descriptor closes are independently attempted afterward. Listener closes are likewise independent of terminal receipt writing.
- Primary attempt failure is re-raised while cleanup/write errors are separately retained. On an otherwise successful attempt, cleanup errors or unconfirmed teardown prevent a successful result from escaping. Receipt failure cannot bypass reaping or the remaining descriptor closes.
- CONFIRMED requires supervisor reaping, readable init pidfd indicating exit, and an empty namespace scan; a sent KILL does not qualify. Missing/unvalidated init remains UNKNOWN even if the supervisor is reaped. Expired deadlines or inaccessible/racing process evidence produce uncertainty rather than invented teardown proof.
- Filesystem failure writing the terminal receipt produces `INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE`, retained-root identification, and `missing_or_partial`. The claim flag is set immediately after successful exclusive root creation, so failure creating its children is not mislabeled a preclaim refusal.

The retained regressions cover terminal-budget exhaustion, oversized terminal detail, terminal filesystem failure, independent signal/reap/scan/close failures, bounded unreaped uncertainty, no-launch receipt failure, and postlaunch cap/pipes-write failure. They explicitly check remaining cleanup and primary-error preservation. These are injected local cases, not workstation teardown observations.

The two-second cleanup allowance is a supervisory deadline, not a kernel-enforced wall-time guarantee. `/proc` enumeration and blocking filesystem/kernel operations retain the documented limitations. Neither a hard quota nor an outer preclaim watchdog is newly required by this B1/B2 review.

## Independent verification performed

Read the original `spec-review.md`, current implementation/payload/tests/runner/README, preserved prior implementation and manifest, and the `verification-b1b2-01` result/transcript/binding records. Read-only Python computed diffs, hashes, syntax checks and counts; no reviewed module was imported or executed.

- Current manifest digest matches the value above; all eight bound member digests match.
- All five `tested_sha256` entries in `verification-b1b2-01/results.json` match current files.
- Existing transcripts and structured results agree on 14 original plus 19 regression tests: **33 tests, zero failures/errors**. AST enumeration independently agrees with the test counts. These tests were not rerun during this review.
- All five Python source/test/runner files parse with Python 3.9 grammar. This is not Python 3.9 runtime verification.
- Preserved prior manifest digest is `de607a50733c2de7ab036e03cc8087e4ea6eb5f3f2ee85ca6b1a61830602ae87`; all six prior bound members match it.
- Original `spec-review.md`, payload, tools, input template and source-provenance record are byte-identical to their preserved prior counterparts. The only existing-test code change is its retained fixture-directory name.

No remote connection, bwrap/namespace launch, process-signal test, vendor action, code edit, approval change or commit occurred. Only this review file was created. An initial read-only command used unavailable bare `python`; it was rerun successfully with `python3`.

## Remaining boundary

Full proposal/license/runtime omissions accepted by the original partial-scope review are not independent blockers here. Installed topology, mount/network denial behavior, parent-death propagation and actual runtime teardown remain unverified. The deliberately invalid parent template remains an execution gate. Separate quality review, exact reviewed parent inputs and explicit parent authorization are still required before any workstation experiment; this PASS supplies none of them.
