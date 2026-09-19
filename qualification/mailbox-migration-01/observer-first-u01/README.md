# First-u01 observer: nonvendor preflight only

**Vendor launch is blocked, including after a successful preflight. This is not a production-ready first-upgrade wrapper or a sandbox.** The requested full scope audit cannot honestly be provided by this minimal implementation. `upgrade` exits 2 before any subprocess or evidence/scratch creation. There is no approval input, readiness flag, generic command CLI, stage/child/parent execution, retry, installation, or remote operation.

## Implemented

- `observer.py` binds the exact proposal SHA-256 `3a43e54127052568364e5bdbeb1e70b7a2d98a0454132f9777c4c24859bfaf83`. It reads the candidate scratch path without modifying the proposal/binding/harness.
- An exclusive, non-symlink-parent evidence directory disjoint from scratch, umask 077, retained on failure. It does not create scratch. An existing claim is never reused.
- Fixed harmless Python fork/setsid/exec/write/read probe, wrapped in the proposed `strace -ff -ttt -T -yy -v -s 65535 -e trace=all -e raw=read,pread64,readv,preadv,preadv2` options from probe start. No vendor command or license access. The probe uses only `LANG=C`, `PATH=/usr/bin:/bin`, isolated Python (`-I -B`). This probe environment is deliberately NOT the vendor environment.
- Actual interpreter, observer and strace resolved paths and SHA-256 identities. Successful probe output checks test option support, follow-fork, exec, file write, raw read formatting and exit records; unavailable strace/options/ptrace produce a failed retained receipt, not a substitute capture.
- A separate watchdog process acknowledges readiness before child creation; a pipe gate blocks exec until PID/starttime registration. Dedicated child session, PID/starttime descendant discovery, pidfd signaling, executable/cwd/maps snapshots, watchdog identity and final known-survivor scan.
- Defaults: 1800-second deadline, 2147483648 aggregate trace-byte threshold, 1-second sampling, TERM followed by KILL after 10 seconds. Stop on missing/replaced/shrunk/deleted trace, heartbeat loss, explicit audit-stop message or watchdog error. Tests shorten thresholds only through the private Python API.
- Before/after protected manifests (file hashes, metadata, directory entries and symlink text). Caller names all protected roots; nothing claims original/work03 coverage unless those exact roots were supplied and successfully hashed. No symlink-target traversal or raw protected-byte backups.
- `test_observer.py`: local inert watchdog and fault-injection tests; evidence remains in `test-evidence-*`. These fixtures are not vendor or strace evidence.

## Exact unresolved requirements / reasons for blocking vendor execution

1. There is **no complete syscall parser**. `scope_decision()` always requests a stop and is only an interface tested with synthetic audit events, not an unexpected-exec/external-write detector. The preflight regex checks are only format checks for its fixed probe. They cannot validate vendor argv/environment, launcher shell grammar, resource selections, project paths, network activity or dynamic libraries. The proposal's exact `candidate_binding.argv.upgrade`, `cwd`, and `env` remain authoritative, but this tool does not launch them.
2. A correct scope audit needs per-thread cwd and shared `CLONE_FS` state; dirfd resolution including `AT_EMPTY_PATH`; FD inheritance/dup/close/SCM_RIGHTS/pidfd_getfd; inode identity across rename/unlink/hardlinks; symlink resolution and races; shared writable mmap plus later mprotect; io_uring/AIO/splice/copy_file_range and socket effects. Raw read fields conceal FD annotations for those calls. `-yy` path decoration alone is not a proof. Unknown/truncated/unfinished/resumed/unresolved events must reject acceptance, never silently pass. A separately reviewed parser or equivalent observation system is required before replacing the unconditional gate.
3. `/proc` polling can miss short-lived/reparented descendants, including rapid double-fork/setsid escapees. Successfully killing an observed setsid child does not prove full accounting. The watchdog does not reconstruct the clone graph from trace. Its survivor scan is explicitly **known identities only**. It cannot attest no unaccounted survivors.
4. Sampling thresholds can overshoot (especially trace bytes); they are not kernel hard quotas. A frozen/killed watchdog, machine crash, full disk, inaccessible `/proc`, concurrent writer or observer-process failure can prevent final receipts. No robust mutual supervision or disk-reservation guarantee is claimed. Missing receipts mean failure.
5. Manifest equality cannot detect write-then-revert and is not an atomic filesystem snapshot. Symlink targets, raw-before backups, complete scratch inventories, target XML and stage/report/project equality remain missing vendor acceptance evidence, not waived prerequisites.
6. Raw reads avoid recording license read buffers; write/send/ioctl buffers and argv may still disclose sensitive data. Treat evidence as private. The probe contains no secrets. No external services/concurrent writers are controlled, and detected writes can occur before a stop.

These are engineering blockers, not reasons to run once and hope. A real upgrade is refused even if parent approval and all binding hashes exist. Do not import `start_supervised()` to bypass the gate: it is an inert-test/preflight primitive, not a scope enforcement mechanism.

## Local commands

Run from any directory; the test script imports its sibling without installation:

```sh
python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/observer-first-u01/test_observer.py
```

Tests leave claims/evidence intact. The deleted-trace test deliberately deletes only its own synthetic fixture trace to exercise loss detection; no production cleanup path exists. Unexpected-execution/external-write tests inject stop decisions and verify termination/retention; they do not establish detection completeness.

## Parent's later workstation preflight (NOT executed remotely here)

Deploy/read back the reviewed observer source plus unchanged proposal at matching relative paths. Supply an exclusive **preflight** evidence path, not the reserved actual observation-first path. Set `PY` to the workstation's independently resolved Python executable and `PREFLIGHT` to the single independently agreed absent path. Determine exact original, work03 and board-boundary protected roots from the reviewed project inventory; do not guess them or substitute scratch.

```sh
M=/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01
# Required operator inputs: PY, PREFLIGHT, ORIGINAL, WORK03, BOARD_BOUNDARY.
: "${PY:?resolved Python executable required}"
: "${PREFLIGHT:?exclusive disjoint preflight path required}"
: "${ORIGINAL:?exact original protected root required}"
: "${WORK03:?exact work03 protected root required}"
: "${BOARD_BOUNDARY:?exact protected board boundary required}"
"$PY" -I -B "$M/observer-first-u01/observer.py" preflight \
  --evidence "$PREFLIGHT" \
  --protected "$ORIGINAL" --protected "$WORK03" --protected "$BOARD_BOUNDARY"
```

Inspect retained `preflight.json`, `before.json`, `after.json`, watchdog receipts, process inventory, stdout/stderr and every syscall trace. Exit 0 means **only this harmless probe passed**, never permission to stage or upgrade. On failure retain the claim and stop for disposition; no retry on the same or a newly invented attempt path. On this local host `strace` is absent; no installation was attempted.

Before any future vendor execution, the parent still needs an independently reviewed complete observer replacement, exact source/tool/catalog/symlink-chain checks, named host/user/tmux checks, externally approved binding, read-only license verification, absent scratch and exclusive actual observation claim. The original monitoring recommendation reserves `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/observation-first-7c407469a419-u01` for that actual attempt. Nothing here claims or consumes it.
