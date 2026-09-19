# Runtime metadata diagnostic — local preparation only

Status: implemented and fake-backend tested locally; **not approved for production
execution**. `authorization`, `ready_for_build`, and `vendor_run` are always false.
No remote command was run. Existing u01/u02/u03 sources and evidence are untouched.
This is not a successor preflight, sandbox, namespace test, or fixture claim.

## Files and local verification

- `collector.py`: standalone Python 3.9-compatible standard-library source.
- `test_collector.py`: entirely in-memory backend, synthetic metadata and iterators;
  no Native backend construction, local `/usr` traversal, or remote root access.
- `test-results.txt`: retained verbose unittest output (30 test methods, including
  parameterized subtests); all passed on Python 3.13.5, exit 0.
- `validation.txt`: local interpreter and Python 3.9 grammar-check results.
- `SHA256SUMS`: hashes of the four files above plus this README, excluding itself.

Local test command, from this directory:

```sh
python3 -B -m unittest -v test_collector
```

Tests cover identity refusal; selection and resolution permission failures;
metadata/readlink/scandir open, iteration and close failures; mountinfo
open/read/close failures; primary versus close error preservation; alias dedup;
out-of-scope resolution; symlink cycles and no deliberate descendant-target
visits; mounts and escaped targets; parse and input bounds; entry and output
bounds; deadline and acquisition ownership; directory/root races; special types;
nested iterator closure; and main's output/exit status using only the fake backend.
The 250000 boundary is exercised by injecting counters and smaller fixture caps,
not by constructing 250000 actual filesystem entries. Python 3.9 grammar is
checked locally, but no Python 3.9 interpreter execution is claimed.

## Fixed contract

Required identity: hostname `Agilex7Workstation`, real/effective UID 1000,
`USER=uwb_student00`, `LOGNAME=uwb_student00`, and preserved
`TMUX=/tmp/tmux-1000/default,7828,4`. Real/effective GID and supplementary groups
are recorded without changes. UID/EUID and hostname come from OS APIs; user-name
fields and TMUX are environment assertions, **not independent account/session
attestation**. No NSS lookup, tmux invocation, process inspection or socket is
used. The later execution decision must independently bind UID 1000 to
`uwb_student00` and that TMUX identity to `ia840f_migration_preflight`.

Only `/usr`, `/bin`, `/lib`, `/lib64` are candidates. Explicit component
`lstat`/`readlink` operations resolve aliases. Resolution may inspect needed
components outside the roots, but never enumerate an out-of-scope target.
Resolved roots must be `/usr`, below `/usr`, or an exact candidate observed as a
non-symlink directory. Exact aliases and nested coverage are deduplicated.
Optional absent candidates and optional regular-file non-directories are
explicitly excluded. Missing required `/usr`, dangling candidate symlinks,
unsupported types and all other errors stop; dangling optional symlinks are
conservatively terminal rather than silently excluded like `isdir`.

The sole content read is `/proc/self/mountinfo`, in bounded binary chunks.
Escaped targets anywhere, malformed input, and mounts at/below selected roots
stop before traversal. Exactly 1048576 input bytes also stops: no extra sentinel
byte is read to establish EOF. Thus an input exactly at the limit is intentionally
not accepted. Empty mountinfo is rejected.

Traversal uses unsorted depth-first active iterators, `lstat`, `readlink`, and
`scandir`, without a metadata inventory or a whole-directory enqueue. Descendant
symlink targets are never intentionally followed. It rechecks active ancestor
signatures before operations and entries after access; detected changes stop.
Counts are unique admitted traversal visits/discoveries, not selection metadata
calls or defensive rechecks. Both count limits are 250000 globally. Deadline is
one monotonic 60-second budget started at collector construction before identity,
covering selection, mount read, traversal and report preparation; it is not reset
per root. Cleanup closes only owned read handles even after a deadline. A blocked
kernel operation, final output write, or cleanup can exceed this budget.

Compact ASCII JSON goes only to captured stdout. Errors retain attempted path,
operation/phase, exception class, errno, filename/filename2, current root,
counts and elapsed time. Resolution labels are explicit because the resolver
itself calls the named primitives; no hidden `Path.resolve` syscall is guessed.
Close failures are separate from the primary failure. An oversized JSON report
is rejected in favor of a small `INCOMPLETE/output_limit` report explicitly saying
its evidence was not emitted; no partial path/error evidence is silently
truncated. Exit 0 means a completed report, not build authorization. Other exits,
output-channel failure, invalid/missing JSON or lost report are inconclusive.

## Exact proposed invocation — NOT EXECUTED

After independent specification review, quality review and an exact scope /
execution authorization, the proposed **diagnostic argv** is:

```text
/usr/bin/python3 -B -
```

Feed the hash-reviewed bytes of `collector.py` on stdin through the already
approved captured command channel, then close stdin. Do not stage a remote file,
redirect remote output to a receipt, set/forge identity environment variables,
run preflight/probe, or add flags/roots. The absolute interpreter path/version,
stdin transport, existing TMUX context and captured-output mechanism still need
binding in that future execution decision. This document supplies no SSH command
and authorizes no launch or staging operation.

### Proposed outer timeout plan — not implemented or exercised

The future approved execution controller must own the **single diagnostic child**
and retain its exact unreaped PID with a pidfd acquired for that child before any
timeout signal. Measure from diagnostic launch: at 65 seconds, send SIGTERM only
to that pidfd; at 70 seconds, if still alive, send SIGKILL only to the same pidfd.
Never signal a negative PID, process group, TMUX pane/server, SSH session, parent,
fixture or unrelated process. No `pkill`, `killall`, general cleanup, process
search, namespace operation or retry. If the controller cannot provide this
exact-child binding, refuse launch; do not fall back to a group timeout or a
reused numeric PID. Reap only that owned child and release the controller-owned
handle. Any timeout, blocked unkillable syscall or missing final report is
**INCOMPLETE** and does not authorize another run. This is a reviewable plan,
not a supplied supervisor/framework or permission to implement one.

## Interpretation and remaining limitations

- No current production failure has been observed by this work. Fake failures
  validate reporting only. A future observed error describes only that current
  reproduction, **not proof of u03's historical cause** or its permission mechanism.
- A successful traversal cannot eliminate historical permission/race/mount
  changes, host-before close failure, or runtime-before receipt creation failure.
  Receipt writes/closes are deliberately not reproduced.
- Path-based metadata is not an atomic snapshot or race-proof confinement.
  Rechecks detect some changes; a concurrent substitution between checks and
  `scandir`/`lstat`, including an ancestor symlink or mount change, can evade them.
  No descriptor-relative no-follow sandbox or mount namespace is claimed. The
  future scope review must explicitly accept this residual limitation or refuse
  execution; no scope expansion is authorized here.
- Environment identity is not session attestation. Mountinfo is a single guard
  observation, not continuous mount monitoring. Deep trees may exhaust read
  descriptors before the count/time ceilings; that error is terminal, not retried.
- Read-only means no requested writes or permission changes, not absence of
  atime/cache/audit effects. Python interpreter/import startup is outside the
  metadata walk and requires the separately reviewed interpreter environment.
- Existing source and evidence were read only. No vendor tools, namespaces,
  subprocesses, sockets, permission changes, fixture claims, commits or pushes
  were performed by the implementation or tests. Only this new local directory
  contains deliverables. Production execution remains pending all reviews.
