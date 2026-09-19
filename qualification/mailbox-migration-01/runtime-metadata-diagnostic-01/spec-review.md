# Independent specification review

**Verdict: PASS — static implementation/specification review only.** No blocking deviation found from `../u03-runtime-diagnostic-proposal.md`. This permits the separately requested quality review, not diagnostic execution. `authorization`, `ready_for_build`, and `vendor_run` remain false. u03 remains consumed and INCONCLUSIVE; this review does not reopen it or establish its historical failure cause.

## Review basis and verification

Read the complete proposal and `collector.py`, `test_collector.py`, `README.md`, `test-results.txt`, `validation.txt`, and `SHA256SUMS`. Performed only local static reads, SHA-256 computation, and AST parsing. Did not import either reviewed module, run the collector or tests, access a remote host, invoke vendor/namespace tools, or change implementation/evidence files.

All five manifest entries independently matched:

| File | Verified SHA-256 |
| --- | --- |
| collector.py | `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897` |
| test_collector.py | `68c9869c32e96f22aa7ff6023c158f5c3e8682f342a1a70735e9c74625929f30` |
| README.md | `460690cab46a7e844f198423b4c5d517096fe838aec92f82e195f02ca261db48` |
| test-results.txt | `bcbd4dd62d723405d809ae85d8f43e0799eb99fe1df9c10b965bc06f6782b0ee` |
| validation.txt | `b51af6c198ccf5d5dd669bbfffebf88bebab0d078fba3327c0b122ec4fe179f3` |

Independent AST parsing accepted both files with Python 3.9 grammar and counted 30 test methods. The retained results report 30 passing tests; `validation.txt:2–8` reports exit 0 on Python 3.13.5 and explicitly disclaims Python 3.9 execution. These are preserved implementer execution results, not independently rerun tests. Grammar acceptance is not interpreter/runtime validation.

## Contract findings

- **Identity/context:** `collector.py:28–33,280–288` obtains OS hostname, real/effective UID/GID and groups, records USER/LOGNAME/TMUX, and refuses mismatches before filesystem selection. Fixed hostname, UID/EUID 1000, user strings and exact preserved TMUX value match proposal line 15. `README.md:37–44` correctly distinguishes environment assertions from account/session attestation; binding them to `uwb_student00` and `ia840f_migration_preflight` remains an execution prerequisite, not an established observation.
- **Roots and resolution:** `collector.py:10,94–170` limits candidates to the four specified paths, separates candidate qualification from explicit resolution, permits only necessary component metadata, rejects out-of-scope resolved roots, and deduplicates aliases/nested coverage. Optional ENOENT candidates are explicitly excluded; access errors terminate. Conservative stops for dangling aliases/unsupported candidate types are disclosed at `README.md:51–54`, not silently treated as successful coverage. Resolver errors name actual explicit primitives, so `resolve.lstat`/`resolve.readlink` do not invent hidden failing components of a compound resolver.
- **Mount guard/content exception:** `collector.py:35–36,172–217` opens only mountinfo for content, bounds reads, rejects empty/malformed input, escaped mount targets, and mounts at/below selected roots before traversal. Open/read/parse/close have distinct labels. The exact-input-limit refusal is conservative and disclosed (`README.md:56–60`); no extra byte is read beyond the budget.
- **Metadata-only traversal and change handling:** `collector.py:219–278` uses an unsorted stack of active directory iterators, lstat/readlink and scandir, without regular-file content reads, full inventory construction, or intentional descendant-symlink traversal. Unsupported types and detected signature changes terminate. Acquired iterators are registered before subsequent checks. Path-based rechecks are not atomic confinement; the explicitly acknowledged undetected-race limitation (`README.md:123–131`) is consistent with proposal line 21, not a basis to demand a new sandbox.
- **Counts and time:** `collector.py:12–14,44–47,60–72,225–239,255–278,289–293,317–325` supplies one 60-second budget, global 250000 discovery/visit ceilings, and checks during iterator consumption before admitting/visiting another entry. Selection/recheck calls are not misrepresented as traversal-entry counts. Cleanup is intentionally allowed after deadline. Interpreter startup, blocked calls and final output cannot be hard-bounded by these cooperative checks; the README discloses those limits rather than claiming a hard end-to-end wall-clock guarantee.
- **Error/close fidelity:** `collector.py:57–92,211–217,264–271,294–302` labels attempted operations, retains exact attempted paths and available exception filenames/errno, phase/root/counts/elapsed, and preserves primary failure separately from close errors. Iterator errors identify the directory, not an inferred child. First errors stop traversal; only owned handles are closed, with no retries or continuation into another root.
- **Report/output cap:** `collector.py:52–54,74–81,305–328` emits compact summary JSON, not per-entry success evidence. The 1048576-byte output ceiling is enforced before emission; oversized evidence is explicitly rejected with a small INCOMPLETE report rather than silently truncated. Final output-channel failures are not guaranteed to produce JSON; `README.md:80–81` correctly makes invalid/missing output or other exits inconclusive. Acceptance must consider controller status as well as JSON, particularly for a timeout during final flushing.
- **No prohibited actions:** The collector imports only standard-library errno/json/os/stat/sys/time and has no subprocess, namespace, vendor, credential-changing, socket, fixture, or receipt-write path. Its only explicit content-open is read-only mountinfo; output uses the existing stdout channel. The proposed `-B` invocation prevents requested bytecode writes. Interpreter/import startup is separately disclosed, not claimed to be part of the metadata-only walk (`README.md:132–134`).
- **Interpretation/preservation:** `README.md:117–138` separates hypothetical current observations from u03's historical cause, preserves the host-before-close and runtime-before-receipt caveats, and makes no production finding. Report flags are false in both normal and output-limit paths (`collector.py:52,310`). Nothing here authorizes reuse, cleanup, renaming, or modification of consumed evidence.

## Invocation and outer-timeout assessment

`README.md:83–98` proposes `/usr/bin/python3 -B -` with reviewed source bytes supplied on stdin, no remote staging or receipt, and no forged identity environment. This is a feasible standalone invocation, but the interpreter/version, source transport, captured output and actual execution context are deliberately unbound. They must be specified and reviewed before execution; this review does not claim those prerequisites exist.

`README.md:100–113` specifies an exact-child pidfd controller, launch-relative SIGTERM at 65 seconds and SIGKILL at 70 seconds, no negative-PID/group/session cleanup, and refusal if exact-child binding is unavailable. This is a feasible Linux process-specific timeout design **provided a controller on the diagnostic host actually owns that diagnostic child and can acquire/use its pidfd**. A local SSH-client PID or an unrelated transport timeout would not satisfy it. The plan is not an implemented or verified controller; its availability and integration are execution-approval prerequisites. Blocked unkillable syscalls can still delay reaping. Timeout or lost terminal evidence remains INCOMPLETE with no automatic retry.

These are outstanding execution bindings already recognized by the deliverable, not blocking specification defects in this local diagnostic implementation. Do not infer execution readiness from this PASS.

## Review artifact

Created only `spec-review.md`. No reviewed source, tests, manifest, retained validation output, or consumed u01/u02/u03 evidence was modified. No runtime diagnosis was performed.
