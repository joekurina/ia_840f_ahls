# Exact-child metadata launcher — LOCAL PREPARATION ONLY

Implemented for independent specification then quality review. **No workstation
execution or production authorization.** All authorization/readiness/vendor flags
remain false. The standing local-preparation instruction, not either diagnostic
review, authorized these new files. No source/evidence in the diagnostic directory
or consumed u01/u02/u03 was changed. This is not a successor preflight or fixture
claim, and supplies no vendor, namespace, build, permission-change or retry path.

## Q1 cleanup revision — local only, awaiting independent re-review

The gate-writer close now contains `OSError` and appends a separate
`gate_close` error without replacing the initiating setup error. Remaining
exact-pidfd cleanup, direct-child reap, bounded drain and owned closes continue;
the failed numeric descriptor is not retried. No other launcher behavior changed.

`revision-01-pre-q1-fix/` preserves all ten original files byte-for-byte, including
both reviews, the original manifest and original test/validation results; its
`ARCHIVE-SHA256SUMS` binds those copies. Original `test-results.txt`,
`validation.txt`, `spec-review.md` and `quality-review.md` remain untouched and
refer to the pre-fix revision, not approval of these changed bytes.

Current results are `q1-test-results.txt` (22 inert local tests) and
`q1-validation.txt` (static bindings). `q1-regression-before-fix.txt` records the
new mocked regression failing against the original launcher in both acquisition
and probe refusal cases; `q1-regression-after-fix.txt` records its passing result.
It verifies both errors survive, gate release is refused, reap/drain/remaining
closes occur, the failed close is not retried, and signals use only the owned
pidfd. `q1-exact-changes.diff` retains the full source/documentation diff,
including the exact regenerated transport payload. `SHA256SUMS` binds current
sources and both generations of retained evidence.

Independent specification and quality re-review of this revision is required
before any separately authorized launch. Authorization, readiness and vendor
flags remain false. No remote/native collector/root walk or vendor action ran.

## Files

- `launcher.py`: Python 3.9 standard-library controller with immutable embedded
  collector bytes, exact identity checks, one fork/exec child and pidfd timeout.
- `transport.py`: fixed stdin envelope; checks launcher SHA-256 and byte length
  before compiling it in memory. It embeds exactly `launcher.py`, without staging.
- `test_launcher.py`: local inert child / mocked identity and failure tests only.
- `validate_local.py`: repeatable read-only AST/hash verification; never imports
  or executes the launcher/collector.
- `test-results.txt`, `validation.txt`: exact local commands/results and limitations.
- `SHA256SUMS`: file hashes, excluding the manifest itself.

Source binding: collector length **13851 bytes**, SHA-256
`6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897`.
Launcher and envelope lengths/hashes are recorded in `validation.txt` and manifest.
The collector is decoded/hashed, never imported or executed in local tests.

## Proposed exact launch — NOT EXECUTED

Only after independent reviews AND a separate exact execution authorization:

```text
/usr/bin/python3 -I -B -S -
```

The existing, independently approved captured-command channel must deliver exactly
`transport.py` bytes on stdin and EOF, in pane `%4`, as a **direct child of its
existing shell PID 25387**. No shell `exec` replacing that shell, wrapper process,
new tmux pane/session, SSH-client timeout substitution, remote redirect, receipt,
file staging, environment forgery or arbitrary arguments. The child uses the same
fixed argv, with exactly the reviewed collector bytes on stdin and EOF. `-I -B -S`
ignores Python environment/path customization, suppresses bytecode, and skips site
initialization. Collector imports only errno/json/os/stat/sys/time; no site module
is required. Inert isolated child tests exercise those flags on the LOCAL installed
interpreter; Python 3.9 grammar passes, but Python 3.9 runtime/import compatibility
on the workstation is not claimed.

The delivery channel is **not implemented here**. Shell text injection into a pane
is not a substitute for binary-exact stdin delivery and complete stdout/exit-status
capture. The sender must independently verify the envelope's manifest hash/length
before delivery. The envelope checks launcher hash/length before any child work;
the launcher checks collector hash/length before fork, and again in its internal
child-launch routine. Envelope corruption before its checking code cannot be
self-authenticated: trusted captured transport and independently pinned bytes are
execution prerequisites. These hashes are bindings, not signatures or a sandbox.

### Exact live identity prerequisites — do not silently rebind

The launcher checks hostname `Agilex7Workstation`, UID/EUID 1000, preserved
USER/LOGNAME `uwb_student00`, TMUX `/tmp/tmux-1000/default,7828,4`, TMUX_PANE `%4`,
and direct parent PID 25387. It checks Python 3.9, isolated/no-site/no-bytecode flags,
and realpaths for `/usr/bin/python3`, `sys.executable`, and `/proc/self/exe` equal
`/usr/bin/python3.9`. It hashes both that exact executable and `/proc/self/exe`
against historical expected SHA-256
`7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2`.
No filesystem enumeration is performed by the launcher. Hashing those exact files
and resolving their paths are read-only interpreter attestation, not a root walk.

Environment strings and a numeric parent PID alone are NOT independent session
or account attestation. Before execution, the authorized controller must independently
bind UID 1000 to the actual `uwb_student00` account and verify the existing shell,
server, pane and session identity live; old records are not proof. Any mismatch
REFUSES rather than substituting a current pane/PID/socket or resetting evidence.
Do not recreate a missing session. Keep the existing inherited environment; the
execution reviewer must consider dynamic-loader variables and interpreter/stdlib
startup trust, which a Python-level check cannot undo after process startup.

If a separately authorized read-only tmux attestation is used, it must first
verify `/usr/bin/tmux` real executable bytes against historical SHA-256
`e5b9534d3dc79b2e32ad958d458f4933fead6c768a80ccf0c3203ddfa0382dc7`.
The sole proposed tmux query, explicitly socket- and pane-targeted, is:

```text
/usr/bin/tmux -S /tmp/tmux-1000/default display-message -p -t %4 '#{session_name}|#{session_id}|#{pane_id}|#{pane_pid}|#{pid}|#{socket_path}'
```

Require exactly this one line (plus its terminating newline) and exit 0:

```text
ia840f_migration_preflight|$4|%4|25387|7828|/tmp/tmux-1000/default
```

This query is specified, not invoked by the launcher or these tests. No tmux
socket, command, process search or extra subprocess occurs inside the launcher.
The external attestation must be retained by the captured channel and immediately
associated with the launch; stale data, unsupported format, altered executable or
unexpected output refuses. Live session/account attestation and approved channel
integration remain blockers; these instructions do not authorize running tmux.

## Child ownership and timeout

Before fork, actual pidfd API/kernel/policy support is probed with a pidfd for
self and signal 0 (not a terminating signal); it is closed before child creation.
Then exactly one child is forked. The child closes parent pipe ends and blocks on
a one-byte gate with a five-second local wait. It cannot exec the interpreter or
start collector work until the parent has opened its exact unreaped child pidfd,
validated pidfd signal 0, and made the I/O endpoints nonblocking. Acquisition or
setup failure closes the gate; EOF or gate timeout exits the inert child with 125.
There is no traversal-capable orphan on an acquisition failure and no numeric-PID
signal fallback. Parent death before release also closes the gate. After release,
parent death is not covered by this controller (no stronger survival claim).

The launch clock is taken immediately before fork, including handshake and
interpreter startup. At elapsed 65 seconds send SIGTERM to the owned child pidfd;
at 70 seconds send SIGKILL to that same pidfd if it has not been observed exited.
The loop polls at at most 50 ms intervals; these are scheduling thresholds, not
real-time guarantees. If descheduled past both thresholds, TERM then KILL are
issued. Output overflow/channel/control errors can cause an earlier exact-pidfd
SIGKILL and terminal INCOMPLETE. No groups, names, unrelated PIDs, parent, pane,
server or transport are signaled. Only `waitpid(owned_direct_child, 0)` reaps.
No preflight/probe import, subprocess retry, alternate target, cleanup scan, socket,
namespace operation, credential change or remote file write is implemented.

The synchronous owned-child reap can be delayed indefinitely by an unkillable
kernel syscall, a kernel/policy signal failure, or scheduling failure. The gate's
select/read and Python startup also rely on functioning kernel operations. No
hard wall-clock bound or D-state recovery is claimed. Lost parent/output capture
or interrupted cleanup is INCOMPLETE, not permission to rerun. The collector's own
60-second cooperative budget and original root-race limitations remain unchanged.

## Input/output and acceptance

The source pipe is written nonblocking while both child output pipes are drained
nonblocking; no sequential write/read pipe deadlock. Each captured stream is at
most 1048576 bytes. An extra detection byte may be read but is not retained; an
overflow preserves the bounded prefix, explicitly reports an error, and fails.
Errors/timeout retain partial stdout/stderr; after reaping, still-buffered data is
drained nonblocking to the same caps before owned handles are closed. No streamed
partial report is treated as completed evidence.

One compact ASCII JSON envelope is sent to existing stdout. Each stream has
base64-encoded exact bytes plus independent decoded-byte length and SHA-256.
The collector hash/length, launcher hash/length from the verified envelope,
raw wait status, elapsed time, timeout flag, reap flag and errors are included.
Base64 expands output; the capture channel must allow at least 3 MiB for the outer
JSON (two 1 MiB decoded stream caps), not just the collector's 1 MiB. No remote
receipt is created. Outer emission uses nonblocking writes and a five-second
cooperative channel deadline. Broken/missing/truncated outer output cannot always
carry an INCOMPLETE label through that same broken channel; exit is nonzero and
the receiver MUST classify it as INCOMPLETE. Do not assume a terminal flag survived.

Receiver acceptance must verify all of:

1. Complete captured command exit status 0 and exactly one complete JSON envelope;
   missing exit status, transport error, truncation or extra bytes is INCOMPLETE.
2. Expected launcher SHA-256/length from this reviewed transport and collector
   SHA-256/13851-byte binding; no null/missing launcher binding.
3. Both base64 streams decoded strictly; their byte lengths and SHA-256 match the
   declared values and neither exceeds 1048576 bytes. Retain even incomplete data.
4. Envelope terminal `completed`, `reaped=true`, `wait_status=0`,
   `timed_out=false`, `errors=[]`, and all three authorization flags false.
5. Decoded collector stdout is complete JSON with terminal.result `completed`
   and all three authorization flags false. Nonzero collector exit, malformed or
   missing JSON, an error report, or a timeout remains INCOMPLETE regardless of
   a completed-looking fragment. Preserve stderr as separate evidence.

The receiver/captured channel is an explicitly outstanding integration prerequisite,
not a tested production facility. Success is a current diagnostic observation,
never build readiness or proof/exclusion of u03's historical cause, receipt-write
failure or host-before-close failure. No fixture or consumed evidence is reused.

## Local verification and remaining blockers

From this new directory, local tests use:

```sh
python3 -B -m unittest -v test_launcher
python3 -B validate_local.py
```

Tests patch the source binding only inside the test process to fixed harmless code:
printing, pipe writes, sleeping and ignoring TERM. They NEVER call the collector,
its Native backend, a root walk, remote tools or `main()` on real identity. Mocked
identity/hash tests are not live attestation. Real LOCAL pidfd tests exercise gate
failure, exact handle signals, reaping, EOF, saturation, partial output, bounded
capture and isolated child startup. Timing is accelerated in tests; exact 65/70
threshold decisions are tested separately. No workstation/native collector run,
permission changes, vendor tools, commits or pushes were performed.

Outstanding: independent spec/quality review; fresh live interpreter/account/tmux
identity bindings; accepted startup/path race limitations; approved binary-exact
stdin and captured-output transport/receiver integration; and explicit execution
authorization. Historical hashes and local test results satisfy none of those by
themselves. Refuse rather than rebind or improvise a replacement timeout mechanism.
