# Specification and safety review — partial nonvendor scope

## Decision: BLOCKED pending two bounded fixes

Do not execute this revision on the workstation yet. The blockers below concern this partial fixture experiment itself, not missing implementation of the full proposal. Once fixed, rebind the manifest/invocation and review the affected paths; separate parent authorization and exact parent inputs remain necessary. This report grants no vendor, staging, installation, root, or host-configuration authority.

Reviewed scope: three fixed Python-only bubblewrap attempts (`controls`, `timeout`, `parent-loss`), under the existing named tmux session. Static review only: no runner/tests imported or executed, no subprocess/namespace/remote/vendor experiment performed. Only this report was written.

## B1 — Init pidfd is not proven to belong to this launch before it becomes signalable

**Blocking safety defect.** `preflight.py:247–261`, `65–70`, `310–320`.

The info pipe is launch-owned, but `child-pid` is a numeric PID, not an ownership-preserving process handle. The controller reads a candidate identity, checks only that its PID namespace differs from the controller's, then calls `verified_pidfd(pid)`. That helper compares its own two observations, not the earlier candidate identity or a launch ancestry identity. There is no check that the process belongs to the owned supervisor/bwrap lineage. Ordinary early exit plus PID reuse can therefore cause the numeric PID to resolve to a different process. The helper can consistently identify the replacement and still return success. A different PID namespace, or even NSpid ending in 1, does not establish launch ownership.

Worse, `initfd` is assigned at line 258 **before** NSpid validation at line 260. If that validation fails, the `finally` block can send SIGKILL through that very handle. Refusal must not signal an identity that failed validation. The preliminary namespace comparison is also not compared to the identity returned by `verified_pidfd`.

Required fix:

- Establish a launch-bound init identity/ancestry and retain a stable handle while it is validated. Use a bounded startup handshake/ownership chain, or equivalent mechanism that prevents trusting a stale PID merely because it appeared on the pipe.
- Validate the captured identity, expected namespace relationship, NSpid=1, and launch ownership together, with race checks around acquisition. Only then promote the handle into the set eligible for signaling.
- On failed validation, close an untrusted handle **without signaling it**; terminate only the already-owned direct supervisor and rely on the configured parent-death chain/finite fixture fallback. Report teardown uncertainty, not success.
- Add negative tests for a stale/reused info PID, a stable but unrelated namespace init, identity change between candidate and acquisition, and failed NSpid validation. Assert that no rejected handle is signaled, including from `finally`.

The direct supervisor differs: it is a fork-created child, unreaped when its pidfd is first acquired. The existing pidfd unit test covers an owned direct child, not the bwrap-init ownership gap.

## B2 — Receipt-cap/error handling can suppress final evidence and interrupt cleanup

**Blocking partial-spec failure.** `preflight.py:186–195`, `310–329`, `427–444`.

`Receipts.save` permits ordinary receipts to consume the entire remaining budget. There is no reserved space for terminal status. A near-cap accepted receipt can leave insufficient room for the next launch/pipes/final receipt; the attempted INCONCLUSIVE `final.json` then fails the same cap check. The outer handler prints `REFUSED_BEFORE_OR_DURING_CLAIM`, even though the run may already have claimed paths and launched probes. Existing artifacts remain, but the required bounded terminal report is not reliably retained.

Cleanup is also a serial, fallible sequence: a pidfd operation error other than ProcessLookupError can prevent handling the other owned process and closing streams; `receipts.save(...-pipes.json)` can raise before `waitpid(supervisor, 0)`. Thus receipt exhaustion or an evidence-write failure can skip remaining cleanup. The normal successful path has teardown checks, but the failure path has no independent bounded post-stop evidence collection.

Required fix:

- Reserve a small, explicit terminal-receipt allowance within the existing 64-MiB budget. Reject/truncate optional evidence before consuming it; retain a compact INCONCLUSIVE terminal record on cap exhaustion rather than serializing all accumulated events again.
- Make cleanup independent of receipt success and of each individual cleanup operation: attempt all owned-handle stops/closes/reaping even when an earlier step fails. Preserve primary and cleanup errors separately.
- Keep cleanup and available post-stop verification bounded. Record confirmed teardown versus unknown/missing init identity without treating a sent KILL as proof. Do not signal unvalidated processes to obtain evidence.
- If the filesystem itself prevents writing a terminal receipt, give a truthful post-claim fallback diagnostic identifying the retained root and missing final receipt; do not label this a preclaim refusal.
- Add injected cap/write/signal-error cases showing that cleanup still completes or reports bounded uncertainty and the terminal-cap reserve cannot be consumed by ordinary evidence.

This does **not** require a kernel quota, a complete aggregate inventory budget, or implementation of the original full proposal. It repairs this bundle's own stop-and-retain contract.

## Partial-scope checks that are satisfactory by inspection

- Fixed ROOT and both reserved paths match the proposal. `claim` uses exclusive mkdir; no deletion, retry suffix, reuse, real scratch creation, or real observation claim is present. Writes are directed to the new fixture, not original/work03/board inputs. No-link checks are present; protection against concurrent host pathname replacement is expressly not claimed.
- Hash/input approval/host/UID/tmux/tool/protected-path/reserved-path checks precede `claim`. The documented `-I -B -S` invocation prevents bytecode writes. The invalid template is rejected before claim by approval scope. These are static observations, not a new dynamic rejection test.
- Actual executable vectors are fixed tmux display query, bwrap help/launch, and pinned Python with a fixed payload. No arbitrary command argument, shell fallback, vendor executable, license-content read, installer, sudo, or unshare fallback is present. tmux is queried, not created or reconfigured. External trust in the initial interpreter remains required, as documented.
- The runtime view uses readonly OS runtime bindings, readonly fixture/payload, one persistent writable fixture tree, explicit device exceptions, private proc/user/mount/PID/network/IPC, and no vendor/license/home-content mount. The negative mutation controls target fixture paths, not original or system files. Network tests target only owned loopback/UNIX listeners; there is no DNS or external endpoint vector.
- The fixed lifecycle payload uses double-fork/setsid and independently rearms alarms in forked branches. The supervisor has PDEATHSIG plus a parent-race check and a 19-second alarm; bwrap receives `--die-with-parent`. Lifecycle acceptance before 17 seconds is intentionally earlier than the payload's 18-second expiry. These are useful harm bounds, not proof of installed bwrap semantics. They do not cure B1.
- Namespace attempts stop on the first failure and are limited to the three enumerated kinds. Per-attempt output accumulation is capped before appending, and pipes rather than observer descriptors reach the payload. Finite payload writes are small. Receipt writes are exclusive and artifacts are not deleted. B2 concerns terminal reserve and failure handling, not a claim that ordinary receipt writes lack a byte check.
- Status cannot become the full proposal PASS: the strongest status remains `FINITE_FIXTURE_CONTROLS_OBSERVED_PROPOSAL_INCOMPLETE`, exit 2, with authorization/readiness false.

## Explicit limitations accepted for this review, not blockers by themselves

The README correctly discloses missing finite candidate identity maps/native-chain checks, exact BMC/board and original/work03 before/after content inventories, vendor/license mounts and license compatibility, broader discovery, full aggregate caps and a preclaim outer watchdog. Runtime scans and pipe/receipt limits are supervisory, not comprehensive resource quotas. Preclaim subprocess capture and hashing are not covered by a universal aggregate cap. No hostile concurrent-writer defense, full syscall/exec audit, or injected outermost-controller-loss test is supplied.

Those omissions prevent original-proposal acceptance and vendor authorization. They do not require expanding this partial inert experiment into the full proposal. The parent must explicitly accept the stated narrower scope/resource assumptions. The unfilled tmux hash and protected pathnames are execution prerequisites, not values to guess. Installed facilities, `/proc` permissions, user namespaces, mount controls and parent-death behavior can still fail; a safe inconclusive result is acceptable after the blockers are fixed.

## Verification and evidence limits

Read README, both implementation files, tool/manifest/template/result files, local tests/transcript/refusal evidence, source provenance, and the full proposal. Read-only Python independently confirmed:

- All six `HASHES.json` member digests match.
- Manifest SHA-256 matches the documented invocation: `de607a50733c2de7ab036e03cc8087e4ea6eb5f3f2ee85ca6b1a61830602ae87`.
- All three source-provenance digests match their referenced files.
- `tools.json` equals the recorded availability tool map.
- `preflight.py`, `probe.py`, and `test_local.py` parse with Python 3.9 grammar. Their reviewed APIs are compatible with Python 3.9 in principle, including pidfd APIs subject to the kernel/runtime availability checks. No Python 3.9 execution was performed.

Existing local evidence reports 14 tests, zero failures/errors, under Python 3.13.5. I did not rerun them. They establish neither namespace behavior nor the two error-path properties above. The final quality review and workstation experiment remain separate activities.
