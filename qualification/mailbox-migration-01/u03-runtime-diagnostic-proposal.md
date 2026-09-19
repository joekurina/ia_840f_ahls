# u03 runtime metadata diagnostic proposal

**Proposal only — no implementation, execution, or execution authorization.** Preparation used local static reads only. No remote observation or new hash verification is claimed. u03 remains consumed and INCONCLUSIVE; `authorization`, `ready_for_build`, and `vendor_run` remain false.

## Evidence and question

Read: `u03-checkpoint-disposition.md`, `u03-permission-diagnosis.md`, `u03-checkpoint-metadata.json`, `u03-checkpoint-content.json`, and `isolation-preflight-u03/preflight.py`, including runtime inventory and its callers.

The preserved checkpoint evidence reports stable, valid, hash-verified `inputs.json` and `host-before.json`; `runtime-before.json` was absent with ENOENT. This narrows the historical interval to host-before receipt close (valid JSON does not establish successful close), runtime-root selection/inventory, or runtime-before receipt creation. No saved traversal progress or traceback identifies a failed path or operation. Do not invent one or characterize this as demonstrated user-namespace denial.

The smallest useful next question is: **does a bounded same-user metadata traversal of the source-defined runtime roots encounter a currently observable error, and at which operation/path?** Further reads of the existing checkpoints cannot recover lost traversal progress. Receipt write/close reproduction is deliberately excluded because it would mutate evidence or create a new test artifact.

## Proposed scope, requiring separate approval

One standalone, non-importing diagnostic on `Agilex7Workstation`, as `uwb_student00`, real/effective UID 1000, in the existing `ia840f_migration_preflight` context. Require the preserved TMUX identity `/tmp/tmux-1000/default,7828,4`; record current real/effective GID and supplementary groups for interpretation, without changing credentials. Stop on host/user/context mismatch. No privilege escalation or new namespace.

Only these runtime candidates are in scope: `/usr`, `/bin`, `/lib`, `/lib64`. Source line 572 always includes `/usr` and includes the other three when `os.path.isdir` succeeds. Resolve/deduplicate selected roots as at lines 184–187. Report candidate qualification and resolution separately: use explicitly error-reporting metadata operations rather than letting `isdir` silently turn an access error into a false result. An absent optional candidate can be recorded as excluded; a permission error is terminal, not an exclusion.

Permit metadata checks of only the path components needed to resolve those four candidates. Do not recursively follow an alias to an unreviewed location: a resolved root outside `/usr` or the exact non-symlink candidate roots is a scope stop requiring separate review, not permission to expand the search. Descendant symlinks get `lstat` and `readlink` only; never traverse their targets. No `/` scan, arbitrary guessed descendant, vendor installation scan, home-directory scan, ACL/xattr sweep, content reads, or process/namespace enumeration.

The sole filesystem-content exception is a bounded read of `/proc/self/mountinfo`, needed for the original mount guard (lines 179–188). Label open/read/close and parse errors separately. Reject escaped mount targets and any mount at or below a selected resolved root, as the source does; do not bypass this guard or cross such a mount. A change/race detected during traversal is terminal and inconclusive, not a reason to retry. This remains a live observation, not an atomic snapshot or proof against undetected concurrent changes.

## Minimal bounded traversal and reporting contract

No runnable code is supplied. A separately reviewed implementation would:

1. Establish one monotonic deadline **60 seconds from diagnostic start**, covering selection, mountinfo read, and traversal. This is no looser than the runtime inventory caller's 60-second allowance (line 573); do not reset it per root. No retries or automatic continuation batches.
2. Walk only the selected, deduplicated roots once using a stack and the source operation sequence: `lstat`; require regular file, directory, or symlink; `readlink` for symlinks; directory enumeration for directories (lines 191–202). Distinguish `scandir` open, iteration, and close errors. Do not read regular-file contents or construct/save a full metadata inventory. Do not sort entire directories or recursively follow symlinks. Directory enumeration order can differ from the historical run.
3. Enforce the source's **250000-entry** ceiling globally across roots, checking before the next metadata visit. Also cap total discovered/enqueued paths at 250000 and check deadline/count while consuming each directory iterator, not only after enumerating a whole directory. These stricter admission checks prevent the source's unbounded single-directory stack extension; they are diagnostic bounds, not a claim to reproduce the original walk exactly.
4. Bound mountinfo input and emitted output separately at **1048576 bytes each**, tighter diagnostic limits rather than claimed source limits. Reject oversized input/output instead of silently truncating evidence. Emit only identity, selection/guard results, counts, elapsed time, last completed operation/path, the terminal result, and any close error; reserve space for the terminal report. No per-entry success dump.
5. Label each potentially failing operation before calling it. On the first non-exempt filesystem error emit: phase, exact attempted path, operation, exception type, errno, `filename`, `filename2` when available, selected root, visited/discovered counts, and elapsed time. Keep the attempted path even if exception filenames are absent. For a compound root-resolution error, identify it as `resolve` rather than inventing a lower-level syscall or failing component. During directory iteration, report the directory path, not an inferred child. Preserve a primary failure separately from descriptor/iterator close errors.
6. Stop immediately on that error, guard rejection, unsupported file type, detected race, deadline, count/input/output bound, or completion. Close only diagnostic-owned read handles. Do not skip unreadable entries, weaken guards, retry, or continue into another root after failure. Output goes only to the already captured stdout/stderr channel; no remote receipt or staging file is created.

Time checks bound admitted work but cannot guarantee return from a blocked kernel filesystem operation. Any later execution approval must specify an outer timeout restricted to the diagnostic process; a timeout or lost terminal report is **INCOMPLETE**, never success, and does not authorize another run. No fixture/process-group cleanup or namespace machinery is part of this proposal. Read-only means no requested writes or permission changes; normal access-time/cache/audit effects of reads cannot be promised absent.

## Interpretation and preservation

- **Observed error:** identifies a current failure of the named operation under recorded credentials/context. Even EACCES does not prove that path or syscall caused u03's historical PermissionError, nor identify the permission mechanism.
- **Completed without error:** establishes only that these current metadata operations completed within the stated scope/bounds. It does not eliminate historical races, changed permissions/mounts, the host-before close caveat, or runtime-before receipt creation failure.
- **Bound/guard/context/race stop:** partial or refused diagnostic, not an unreadable path finding and not evidence of a namespace rejection. Report the actual stop reason and coverage.

Preserve every consumed u01/u02/u03 source, claim, manifest, receipt, and evidence file unchanged. Do not import/run preflight or probe, invoke bwrap/unshare/vendor tools, claim/reuse/rename/clean a fixture, create listeners, test receipt writes, chmod/chown, change ACLs, or modify source. No successor harness or sandbox redesign follows. All readiness/authorization flags remain false regardless of diagnostic outcome. Separate explicit review and authorization are required before implementation or execution; this document grants neither.
