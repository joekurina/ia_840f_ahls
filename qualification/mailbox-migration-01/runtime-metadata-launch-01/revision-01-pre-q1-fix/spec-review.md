# Independent static specification review

**Verdict: PASS — static specification review of the locally prepared launcher only.** No blocking implementation deviation found within this fixed-source, trusted-host contract. This is not execution authorization or end-to-end deployment acceptance. The receiver/delivery integration and independent live account/session/interpreter attestation remain explicit execution blockers, not completed facilities. `authorization`, `ready_for_build`, and `vendor_run` remain false. Consumed u03 remains untouched and INCONCLUSIVE.

## Basis and independent verification

Read this directory's `README.md`, `launcher.py`, `transport.py`, `test_launcher.py`, `validate_local.py`, `test-results.txt`, `validation.txt`, and `SHA256SUMS`; also read `../u03-runtime-diagnostic-proposal.md` and the sibling diagnostic README/specification/quality review contracts. Performed only local file reads, independent standard-library AST/literal parsing, base64 decoding as data, and SHA-256 calculations. No reviewed module, test, validator, collector, or transport was imported or executed. No remote access, tmux query, vendor operation, namespace operation, or commit occurred.

Independent verification exited 0:

- All seven entries in this directory's manifest matched; all five sibling diagnostic manifest entries matched. Reviews are not covered by those manifests.
- All four launcher-directory Python sources passed `ast.parse(..., feature_version=(3, 9))`. The embedded collector also passed that grammar check. This is syntax validation, not Python 3.9 runtime validation.
- Strictly decoded transport payload equals the on-disk launcher byte for byte, with matching declared length/hash.
- Strictly decoded collector payload equals the unchanged sibling collector byte for byte, with matching fixed length/hash.
- AST enumeration found 21 test methods, exactly matching the 21 named entries in retained test results. `test-results.txt:26–30` reports passing tests and exit 0; these results were read, not independently rerun.

| Bound artifact | Bytes | Independently verified SHA-256 |
| --- | ---: | --- |
| Sibling collector / embedded collector | 13851 | `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897` |
| Launcher / transport payload | 29948 | `c02a0b0565cf6c77af2effdcef2961b7ff567dff898b462a9be56af3999c79f1` |
| Transport envelope | 40861 | `e4f3f37b4d2fb57244655ad050e1161e92681b674b649fddc1a00aa2dd85fa1e` |

## Contract findings

### Fixed source, standalone startup, and identity

- `launcher.py:11–22,29–33,86–90` fixes the absolute interpreter, realpath/hash, collector hash/length, output caps, deadlines, and child argv. Source mutation is rejected before fork. `transport.py:7–16,19–28` validates the exact launcher bytes before compiling them in memory and supplies their binding to the result. There is no user command, configurable root, source path, arbitrary argument, staging file, or retry interface.
- `launcher.py:36–61,289–293` refuses unexpected argv, hostname, UID/EUID, USER/LOGNAME, TMUX, pane, direct shell parent, Python version/flags, realpaths, or executable hashes before child creation. The fixed values match `Agilex7Workstation`, UID/EUID 1000, `/tmp/tmux-1000/default,7828,4`, pane `%4`, shell PID 25387, `/usr/bin/python3` resolving to `/usr/bin/python3.9`, and interpreter hash `7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2`.
- Actual session name and account mapping are deliberately external, not secretly asserted by environment strings. `README.md:68–97` requires independent live binding and explicitly pins `/usr/bin/tmux` hash `e5b9534d3dc79b2e32ad958d458f4933fead6c768a80ccf0c3203ddfa0382dc7`, socket/pane-targeted query, and exact response `ia840f_migration_preflight|$4|%4|25387|7828|/tmp/tmux-1000/default`. The launcher does **not** implement or enforce receipt of this external attestation. Consequently it is not a self-contained account/session authorization gate; the future controller must refuse missing/stale/mismatching attestation before delivery. That separation is explicit and remains a launch blocker.
- The standalone stdin route is coherent: envelope execution retains stdin-program argv; the fixed child receives only the collector through a separate pipe and EOF (`launcher.py:135–139,186–192`). There is no unconditional refusal, placeholder exception, missing implementation stub, or hidden requirement to execute a vendor/preflight tool in this route. The historical identity requirements may legitimately refuse a changed live context; do not silently rebind them.
- The additional `-I -S` flags relative to the sibling's earlier proposed `-B` invocation are documented (`README.md:35–45`), preserve the collector bytes, and constrain startup. Live Python 3.9 imports/runtime and inherited loader/stdlib trust remain unverified. Executable path replacement after hashing is explicitly acknowledged (`launcher.py:53–54`; `README.md:73–75,189–193`), not disguised as a sandbox guarantee.

### Exact ownership, gated startup, and timeout

- `launcher.py:64–73,90` checks callable pidfd APIs and actual self-pidfd/signal-0 kernel-policy support before fork. Missing support refuses without a numeric-PID fallback.
- `launcher.py:118–150` creates exactly one direct child. That child cannot exec or traverse until a one-byte gate is released after the parent acquires its unreaped child's pidfd, probes signal 0, and sets the I/O endpoints nonblocking. Acquisition failure closes the gate in cleanup; EOF or the five-second gate wait exits the still-inert child. No traversal-capable child is released without the owned handle.
- `launcher.py:76–83,122–123,155–168` measures from immediately before fork and sends TERM at elapsed 65 and KILL at elapsed 70 if exit has not been observed. Delayed scheduling past both thresholds produces TERM then KILL. Polling and signal delivery are not real-time guarantees. Control/I/O errors may cause an earlier exact-child KILL; they cannot become success.
- All nonzero signal delivery uses `signal.pidfd_send_signal` on the owned child handle (`launcher.py:111–115,164,202–208`). There is no kill-by-name, process group, parent/server/pane signal, or numeric-PID signal fallback. `waitpid(pid, 0)` is restricted to the direct child and occurs while it remains unreaped (`launcher.py:201–215`); it is reaping, not a fallback identity mechanism.
- Cleanup closes owned pipe/pidfd handles and reaps only that child (`launcher.py:197–242`). Acquisition refusal leaves the inert gate exit as the fallback, not an unauthorized signal target. Parent death after release is not covered and is explicitly disclosed (`README.md:109–110`). Blocked kernel calls, signal-policy failure, or scheduling can delay synchronous reaping indefinitely (`README.md:123–128`). No hard wall-clock or D-state recovery claim is made.

### Bounded I/O, evidence, and completion

- `launcher.py:147–192` multiplexes nonblocking input and both output pipes rather than filling one pipe while waiting on another. Input is fixed hash/length-bound source, EOF is delivered, and incomplete delivery becomes an error. Each stream retains at most 1048576 bytes; the extra overflow-detection byte is not silently admitted. Overflow preserves a bounded prefix with an explicit failure.
- `launcher.py:195–196,216–250` preserves errors and bounded partial stdout/stderr, including buffered bytes drained after reaping. Each captured stream carries strict reconstructable base64, decoded length, and SHA-256; source binding, timeout, reap, and wait status accompany it. Reports default to INCOMPLETE. Completion requires no errors, no timeout, successful reap/status, and a completed collector JSON with all three false flags (`launcher.py:243–260`).
- `launcher.py:264–286,297–299` emits the normal launcher result through nonblocking writes with a five-second cooperative output deadline. Missing/truncated/broken outer output cannot reliably label itself; `README.md:140–164` correctly requires receiver rejection and separate preservation of partial/error evidence. This is not a guarantee that evidence survives a broken channel.
- `README.md:151–169` specifies complete command status, one complete envelope, launcher/collector bindings, strict decoded-stream length/hash/cap checks, all false flags, and completed inner JSON as receiver acceptance conditions. It explicitly requires capacity for base64 expansion. This receiver is **not implemented or exercised here**; these conditions must be enforced by the separately reviewed integration, not assumed from a completed-looking fragment.

### Scope and evidence preservation

- The production sources contain no arbitrary-command dispatch, permissions/credential changes, namespace operations, vendor tools, remote staging/receipt writes, preflight/probe import, evidence edits, or automatic retry. Only the fixed interpreter is exec'd. Interpreter content reads are the two exact attestation files, separately disclosed from the unchanged collector's finite metadata contract (`launcher.py:55–59`; `README.md:65–66`).
- Authorization/build/vendor flags are false in launcher success/error reporting and envelope decode failure (`launcher.py:243,255–256,295–296`; `transport.py:23–25`). Completion remains a diagnostic observation, not a readiness grant or proof/exclusion of u03's historical cause, host-before-close failure, or runtime-before receipt creation failure (`README.md:166–169`).

## Test evidence and remaining execution prerequisites

The retained tests statically cover fixed-source rejection, absent/kernel-refused pidfd support, exact deadline decisions, gate acquisition/probe failures, owned-handle signal/reap behavior, inert isolated startup, input/output saturation, partial/error/malformed output, per-stream caps, and bounded broken/full outer channels (`test_launcher.py:29–254`). Identity testing uses mocked host/process/environment/interpreter data, and inert tests substitute source bindings only inside the test process. They do not run the collector. None establishes live attestation, target Python 3.9 behavior, receiver correctness, or production timing.

No mandatory source correction is identified by this static review. Before any execution, independently complete quality review, fresh exact identity/account/session/executable attestation, accepted startup/path-race limitations, approved binary-exact stdin delivery from the required existing shell, and captured-output/receiver integration; then obtain separate exact execution authorization (`README.md:189–193`). Do not use these outstanding prerequisites as permission to run tmux, stage files, recreate/rebind a session, or improvise a different timeout.

Created only this `spec-review.md`. No launcher implementation, manifest, retained results, sibling diagnostic source/evidence, or consumed u01/u02/u03 artifact was modified by this review.
