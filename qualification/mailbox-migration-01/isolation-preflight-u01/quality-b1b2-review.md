# Independent final quality review — B1/B2

## Verdict: APPROVED for the exact partial bundle

No blocking quality defect found within the reviewed scope: three fixed, nonvendor Python isolation probes (`controls`, `timeout`, `parent-loss`). This is **not execution authorization**, installed-sandbox qualification, or approval of the full proposal or any vendor launch.

Reviewed `HASHES.json` SHA-256:
`3b98d1769e4ed29944cf0c8db917a5d0280c9bed0622b12ed5e95083fd9fc9ac`.

`authorization`, `ready_for_build`, and `vendor_run` remain false. The input template remains `NOT_APPROVED`. The parent's execution decision and exact separately reviewed input-file binding remain prerequisites.

## Findings

### Ownership and signal safety

Reviewed `preflight.py:60–146,359–496`, including both normal lifecycle signals and exception cleanup.

- The direct, initially unreaped fork-created supervisor is the ownership anchor. Its code creates only one child and never launches a replacement. This restriction makes the checked ancestry materially stronger than merely finding an arbitrary process whose namespace differs.
- The info-pipe PID remains a candidate until repeated identity/PPid reads, parent/supervisor relationships, namespace relationship, NSpid depth/PID 1, and live pidfds all pass. The caller receives the init handle only after successful validation and ancillary-handle closure.
- Failed acquisition or validation closes candidate handles without signaling them. Cleanup has no rejected init handle to signal. A supervisor reaped in an earlier loop cannot validate a later candidate because its pidfd is no longer live.
- Signals target only the owned supervisor or promoted init pidfds. The sole numeric-PID fallback is the direct unreaped supervisor when no supervisor pidfd was obtained; there is no name/group/unrelated-PID fallback.
- An unsupported bwrap process topology, early controls exit, inaccessible `/proc`, or identity race can safely make the experiment inconclusive. This approval does not predict that the installed bwrap topology will pass.

### Failure cleanup and evidence

Reviewed `preflight.py:258–356,363–381,480–496,544–619`.

- Partial pipe allocation, command construction, launch-receipt failure and fork failure close already allocated descriptors without launching a replacement attempt.
- After launch, independent stop attempts precede reaping and receipt writing. Signal, wait, namespace-query and close errors are retained separately; a failed pipes receipt does not bypass cleanup. An existing primary attempt error is re-raised rather than replaced by the pipes-write error.
- Supervisor reaping uses `WNOHANG`, not an unconditional blocking wait. Reaping, init-exit polling and namespace inspection share a two-second supervisory deadline. Unreaped/unknown init state remains UNKNOWN; CONFIRMED requires the three affirmative observations. Cleanup errors prevent an otherwise successful attempt from returning success.
- Ordinary receipts cannot consume the 16384-byte terminal reserve within the existing 64-MiB allowance. Writes are exclusive and conservatively charged before opening/writing. The terminal record excludes accumulated event payloads and compacts excessive cleanup detail while forcing INCONCLUSIVE.
- Listener closes are independent of final receipt writing. Terminal filesystem failure identifies the retained root and missing/partial final record truthfully. Successful root creation is tracked before child-directory creation, preventing an ordinary subsequent setup error from being mislabeled preclaim refusal.
- These are supervisory best efforts, not guarantees against uninterruptible kernel calls, outer-controller SIGKILL, allocation failure at arbitrary instructions, or failure of both persistent storage and diagnostic output. The documented limits remain applicable; no new hard-quota/watchdog requirement is imposed by this review.

### Scope and Python compatibility

Read the fixed payload, command construction, preclaim gates, tests, runner, README, both specification reviews, manifest, retained verification, tool/template data, and `../isolation-parent-input-evidence-live01.json`.

The parent evidence supplies `/usr/bin/tmux` with SHA-256 `e5b9534d3dc79b2e32ad958d458f4933fead6c768a80ccf0c3203ddfa0382dc7`, session/pane identity `ia840f_migration_preflight\t$4\t%4\t25387`, and the existing original, work03 and two board-boundary paths. I did not replace these with guessed paths or convert this evidence into approval. Their use here remains absence checking, not content-preservation qualification.

The launch grammar remains fixed; no arbitrary command, vendor executable, external network destination, license read, remote action or namespace fallback was added. Probe mutations target fixture paths. The strongest possible result remains partial observation with exit code 2, never full acceptance.

All five Python files parse with Python 3.9 grammar. Static API review found no introduced requirement for a newer Python runtime: Linux `os.pidfd_open` and `signal.pidfd_send_signal` are appropriate to Python 3.9, with availability checked before claim and operational failures handled fail-closed. Actual execution on the pinned Python 3.9 interpreter remains unverified; the retained tests ran on Python 3.13.5.

## Independent verification

A read-only `python3 -I -B -S -c ...` verification completed with exit 0. It did not import or execute any reviewed module.

- Manifest digest matches the reviewed value; all eight member digests match.
- All five retained `tested_sha256` values match current files.
- AST-enumerated test names match the retained successful transcript names exactly: 14 original tests and 19 regression tests, 33 total, zero recorded failures/errors.
- Python 3.9 grammar parsing passed for implementation, payload, both test files and runner.
- The original specification review is byte-identical to its preserved prior copy. The implementation diff against the preserved prior was independently inspected.

Tests were not rerun. Retained tests are local/inert evidence, including one owned ordinary Python-child pidfd test and mocked topology/failure regressions; they establish no real bwrap mount, network or teardown result.

## Remaining boundary and changes

Missing full-proposal runtime/license inventories, aggregate bounds and other explicitly accepted partial-scope omissions are not blockers for this review. Installed topology, denial controls, parent-death behavior and real teardown still require the separately authorized experiment. No approval flag or input was changed.

Only this new `quality-b1b2-review.md` was created. No remote connection, bwrap/namespace/vendor execution, process-signal experiment, source edit, test rerun, deployment or commit was performed.
