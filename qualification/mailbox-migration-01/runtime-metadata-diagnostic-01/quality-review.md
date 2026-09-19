# Independent static quality review

**Verdict: APPROVED — code quality within the finite metadata-diagnostic scope only.** No blocking correctness defect found by static inspection. This is not execution approval, hostile-code isolation assurance, or a runtime result. `authorization`, `ready_for_build`, and `vendor_run` remain false; consumed u03 remains unchanged and INCONCLUSIVE.

## Basis and verification

Read `collector.py`, `test_collector.py`, `README.md`, `SHA256SUMS`, `validation.txt`, `test-results.txt`, `spec-review.md`, and `../u03-runtime-diagnostic-proposal.md` completely. Independently ran only `sha256sum --check SHA256SUMS` in this directory: exit 0, all five entries OK (collector, tests, README, retained test output, retained validation). The manifest does not cover either review document.

No collector/test execution, imports, AST execution/check, remote access, source edits, or commit was performed. `test-results.txt:1–35` retains 30 passing fake-backend test methods; `validation.txt:2–8` records Python 3.13.5 execution and Python 3.9 grammar checking only. Those results were read, not rerun. Python 3.9 execution remains unverified.

## Findings

### Correctness, operations, and cleanup

- Identity refusal precedes selection; OS-derived UID/EUID and hostname are distinguished from environment assertions (`collector.py:28–33,280–290`; `README.md:37–44`). Both ordinary and oversized-output reports explicitly retain all three false flags (`collector.py:52–54,305–314`). No subprocess, vendor, namespace, credential-change, receipt-write, or regular-file content-read path appears in the reviewed collector.
- Operation labels precede attempted calls; errors retain the attempted path independently of exception filenames, plus phase, root, errno, counts, and elapsed time (`collector.py:57–81`). Iterator failures are labeled with their directory, not a guessed child (`collector.py:263–265`). Actual resolution primitives have explicit labels (`collector.py:108–125`).
- Acquisitions deliberately bypass the generic post-call deadline check so ownership can first enter a `try/finally` or the active stack (`collector.py:64–72,174–175,247–250`). Later checks cannot strand a successfully returned handle. Normal exhaustion pops and closes the iterator; exceptional unwinding closes remaining owned iterators in reverse order (`collector.py:264–271,294–300`). Cleanup is not retried and is allowed after deadline.
- Primary failures are retained before cleanup; close failures are separately appended and become terminal only when no primary terminal exists (`collector.py:83–92,211–216,294–300`). Tests address isolated operation failures, simultaneous primary/close failures, late acquisition, and nested unwind (`test_collector.py:118–146,210–218,245–268`). No blocking error/close fidelity defect was found.

### Scope, roots, symlinks, and mounts

- Fixed candidates, explicit component resolution, narrow optional exclusions, scope rejection, and exact/nested path deduplication are implemented without directory enumeration during selection (`collector.py:10,94–170`). Resolution may inspect necessary out-of-root components, as explicitly allowed by proposal line 19; it does not enumerate an out-of-scope resolved target.
- Traversal uses active unsorted iterators, validates child names, applies metadata/type checks, and reads descendant symlink text without intentionally visiting the target (`collector.py:219–278`). Rechecks catch persistent observed changes at roots, entries, and active ancestors. Path checks are not atomic and mountinfo is a single observation; the documented substitution/mount-race limitation is real (`README.md:123–131`), but is not an undisclosed sandbox guarantee or a blocking reason to redesign this bounded diagnostic.
- Mountinfo is the sole explicit content-open and is read-only. Reads are bounded before issuance; exact-cap input is conservatively refused without a sentinel read. Empty input, structural parse errors, escaped targets, and mounts at/below selected roots stop before walking (`collector.py:35–36,172–217`). Tests cover exact/over/just-under bounds, empty/malformed data, and mount refusal (`test_collector.py:170–192,295–305`). This is a guard for kernel-produced mountinfo, not a general untrusted mountinfo parser.

### Counts, time, and output

- Global admission/visit counters are checked before increment or the next visit, with no whole-directory enqueue (`collector.py:225–239,255–278`). Selection and defensive rechecks are not entry visits; these ceilings do not bound every syscall. Active-ancestor rechecks cost work proportional to depth, and deep traversal may exhaust descriptors. The single deadline and terminal error handling limit continuation rather than guaranteeing a large tree completes; descriptor exhaustion is already disclosed (`README.md:130–131`).
- One monotonic deadline is established before identity and reused across roots and phases (`collector.py:44–47,60–72,280–293`). Report encoding receives a further completion/deadline check (`collector.py:317–325`). Blocking operations, cleanup, interpreter startup, and final stdout operations are not hard-bounded by these checks, as disclosed (`README.md:68–71,132–134`). This distinction must remain in execution acceptance.
- Full ASCII JSON is size-checked before output. Oversize evidence is replaced with an explicit small INCOMPLETE report, not silently truncated (`collector.py:305–314`). The fallback's retained fields are bounded counters and elapsed time from this collector, rather than arbitrary path/error lists. Output write/flush failures cannot reliably report through the same broken channel; they must remain inconclusive (`collector.py:326–328`; `README.md:73–81`).

## Test coverage assessment and optional improvements

The retained fake tests are suitable unit coverage for control flow, labels, refusal conditions, small-fixture boundaries, acquisition ownership, and cleanup. They do not establish native filesystem behavior, real session identity, production timing, or Python 3.9 runtime compatibility. The README accurately discloses the injected-counter/smaller-cap approach (`README.md:24–33`). No additional production execution is requested by this review.

Two nonblocking, minimal test improvements would strengthen future maintenance:

1. **Successful nested traversal and nested-root dedup:** current alias tests exercise exact aliases and separate roots (`test_collector.py:148–155,313–320`); the nested iterator test covers an error unwind (`test_collector.py:262–268`). Add an in-memory successful multi-level tree and an alias such as `/bin -> /usr/bin`, asserting one traversal, counts, and normal child-before-parent closure. This directly protects `collector.py:164–168,264–278` without native filesystem access.
2. **Additional recheck/deadline branches:** current race tests mutate an active directory and the selected root (`test_collector.py:236–243,322–329`), but do not directly assert `resolution_race`, `candidate_race`, or `entry_race` (`collector.py:114–116,158–160,250–252`). Add narrowly scheduled fake mutations for those branches and a fake clock transition during report encoding to exercise `collector.py:321–325`. Assert the terminal reason and that no further traversal occurs. These are coverage improvements, not evidence that the branches are incorrect.

No source fix is required for this approval.

## Execution blockers and interpretation

Exact interpreter/version/environment, preserved session/account binding, stdin transport, and captured-output binding remain unresolved (`README.md:83–98`). The proposed remote exact-child pidfd timeout controller is neither implemented nor exercised (`README.md:100–113`; `spec-review.md:35–39`). A local transport/SSH-client timeout is not that controller. These remain launch blockers, not automatic code-quality defects. Approval here supplies no permission to implement a controller, stage files, or execute the diagnostic.

A later current error or completed traversal cannot prove or exclude u03's historical cause, host-before receipt-close failure, or runtime-before receipt creation failure (`README.md:117–122`; proposal lines 38–40). No production diagnosis was made. Created only `quality-review.md`; reviewed sources, manifest, retained evidence, and consumed u03 were not modified.
