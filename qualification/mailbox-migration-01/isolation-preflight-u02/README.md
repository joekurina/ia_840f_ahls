# Successor u02: finite nonvendor isolation controls — local preparation only

**Status: NOT_APPROVED; separate spec then quality review required.**
`authorization: false`, `ready_for_build: false`, `vendor_run: false`.
No inherited approval or execution receipt is a u02 approval. The u01 one-shot
authorization was consumed; fixture absence does not renew it.
No remote command, bubblewrap namespace, vendor program, Java, license checkout,
real migration scratch, or real observation claim was executed/created here.
`authorization: false`, `ready_for_build: false`. Historical harness, observer,
proposal and approval files are untouched.

This bundle implements three fixed Python-only probe attempts, not a container
runtime or syscall parser. Even if every implemented control passes, its strongest
status is `FINITE_FIXTURE_CONTROLS_OBSERVED_PROPOSAL_INCOMPLETE` and exit code **2**.
It cannot emit the proposal's full-preflight PASS or authorize vendor execution.
Parent review must explicitly accept this *partial nonvendor scope* before use.

## Implemented design (not workstation observations)

- Fixed exclusive successor root, explicitly scoped by the parent:
  `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u02`.
  No alternate suffix, deletion, retry, or reuse. No-link ancestor checks, mode
  0700/umask 077, retained `rw`, `protected`, and host-only `observer` children.
- Observed SHA-256/realpath pins for bwrap, Python 3.9, unshare, mount, setpriv,
  and strace are copied exactly into `tools.json`; only Python/bwrap and a
  separately pinned tmux are executed. The exact closed executed set is
  `{python3, bwrap, tmux}`; inventory-only is `{unshare, mount, setpriv, strace}`.
  Missing/unknown names or role overlap refuse; caller role fields cannot override
  source-bound roles. Every entry retains location, realpath, regular-file,
  cumulative hash-byte cap, hash and capability-detection checks. Only ENODATA
  means absent capability xattr; unsupported/unreadable detection refuses.
  Receipts retain actual mode, capability hex and explicit role; mode is observed,
  not an expected-mode equality pin. SUID/SGID and nonempty capability bytes
  refuse for executed tools only. Privileged inventory entries remain hashed
  and recorded, never permission to execute. No chmod or capability removal. Missing pidfd support,
  userns denial, unsupported bwrap options or inaccessible evidence stops; no
  unshare fallback. Userns limit 511531 is not treated as proof of usability.
- Host `Agilex7Workstation`, UID 1000, user `uwb_student00`, observed TMUX value
  `/tmp/tmux-1000/default,7828,4`, and named tmux session/pane output
  `ia840f_migration_preflight\t$4\t%4\t25387` are checked. No sessions are made
  or modified. Drift requires separate review, not automatic rebinding.
- Constructed runtime-only view: readonly `/usr` and actual `/bin`, `/lib`,
  `/lib64` directory/symlink layout, optional regular no-link `/etc/machine-id`,
  bound readonly payload and deliberately readonly canary. Runtime metadata scan
  rejects special endpoints/devices and nested mounts; no recursive catalog walk.
  Four explicit `/dev` device bindings (null/zero/random/urandom), fresh procfs,
  private user/mount/PID/network/IPC, retained UTS, new session, dropped caps,
  checked `NoNewPrivs=1`, and readonly root scaffolding. No host root bind.
- `/rw` is the only persistent writable host-backed tree; `/tmp` points to its
  `tmp`. Private proc/dev semantics are explicit exceptions. Real home contents,
  `/opt`, `/run`, `/var`, `/sys`, observer and supplied protected paths are absent.
  An **empty synthetic** tree at the fixed preflight pathname permits a short
  relative pathname-socket test without exposing its host contents. Linux's
  UNIX socket pathname limit makes the actual 124-byte absolute socket path
  unusable; binding/connecting `protected/host.sock` relative to that pathname
  tests the same endpoint without shortening/relocating the host fixture.
- Normal probe: fixture write succeeds; create/truncate/rename/readonly open for
  mmap/actual shared-writable mmap on a readonly FD/root/symlink/dot-dot controls
  must deny. The mmap receipts distinguish denial at open versus mmap itself.
  FD enumeration allows null stdin and stdout/stderr pipes only; setup info FD
  must have disappeared. Mount/status/namespace/UID/hostname/machine-id/MAC/route
  evidence is private in retained receipts, not printed into the broad summary.
- Owned ephemeral loopback, abstract UNIX, and hidden pathname listeners must
  not be connectable; any pending host connection is failure. Scratch-local
  pathname IPC must succeed. No external address/DNS/service is contacted.
- Second probe: double-fork/setsid grandchild and its parent remain alive; at a
  fixed two-second test threshold the controller signals **namespace init by
  pidfd**, TERM then (if necessary) KILL after ten seconds. Third probe kills only
  the dedicated test supervisor by pidfd, testing bwrap's parent-death chain.
  Same launch topology for all three; supervisor also sets Linux PDEATHSIG with
  a parent-race check. `--info-fd` supplies only an untrusted candidate PID.
  Before promotion, live pidfds bracket identity/PPid reads establishing exactly
  `init -> bwrap -> fork-owned supervisor`; the supervisor creates only one child
  and never forks again. The candidate must be namespace PID 1 one level below
  bwrap, with a different PID namespace while bwrap/supervisor share theirs.
  Candidate, ancestor and supervisor identities are checked again with the
  handles still live. Any unsupported topology, stale/reused PID, identity drift,
  missing NSpid or inaccessible evidence refuses. Rejected handles are closed,
  never signaled (including cleanup); only validated init or the owned supervisor
  can be stopped. Missing init identity is teardown UNKNOWN.
- Each inert lifecycle branch independently expires after 18 seconds; this is
  only emergency harm reduction. Acceptance requires confirmed init exit and an
  empty namespace scan before 17 seconds from launch, so natural fixture expiry
  cannot masquerade as tested teardown. Maximum three attempts, 20 seconds each.
  No repeated sandbox launch on failure. Signals use validated launch pidfds;
  if supervisor pidfd acquisition fails, only the direct, still-unreaped fork
  child may receive a numeric-PID KILL. No process names or unrelated PIDs.
- Stdout/stderr are pipes collected by the host, never writable observer FDs.
  Exclusive JSON receipts include launch argv/env/cwd, raw pipes, init identity,
  results, host state, runtime metadata and final status. Host state/canaries and
  reserved path absence are compared; all fixture artifacts remain retained.
- Within the existing 64-MiB receipt allowance, 16384 bytes are reserved solely
  for compact `final.json`; ordinary receipts cannot consume this reserve.
  Failed writes are conservatively charged before opening the file. Terminal
  evidence does not duplicate accumulated payload events, and oversized cleanup
  details are compacted with INCONCLUSIVE status. A filesystem failure reports
  `INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE`, the retained root and a missing or
  partial final receipt, rather than claiming a preclaim refusal.
- Cleanup independently attempts each owned stop, bounded WNOHANG reaping,
  exit/namespace verification and every descriptor/listener close. Primary
  errors and cleanup errors are separate. Post-stop checks share a two-second
  supervisory budget per attempt, in addition to its twenty-second main loop.
  CONFIRMED requires supervisor reaping, init exit and an empty namespace scan;
  a sent signal alone is insufficient. Blocking kernel/filesystem calls still
  have the non-hard-bound caveat below.

## Important remaining gaps / reasons this is not full proposal acceptance

1. **No candidate source/catalog/evidence identity-map revalidation, native-chain
   verification, exact BMC/board inventories, or original/work03 before/after
   content inventories.** Supplied protected paths are checked for canonical
   no-link existence and sandbox absence, not content preservation.
2. **No vendor installation or license mount.** The license is not even opened
   for metadata in this partial bundle. Runtime-only controls cannot validate
   endpoint exposure, loader dependencies or licensing in the future vendor view.
3. Unshare/mount/setpriv version/help and LSM/userns-policy discovery remain
   unimplemented; their installed executable identities alone are checked.
4. Caps are conservative supervisory checks, not kernel quotas: 300-second
   post-claim batch deadline, two at-most-60-second runtime inventory passes,
   250000 metadata entries **per runtime scan**, 8-GiB executable hash-byte cap,
   64-MiB receipts, 1-MiB per-attempt pipe cap. Inventory/survivor counts are not
   a shared aggregate 250000-entry counter; tool hashing/preclaim discovery lacks
   an independent outer 120-second watchdog. The proposal's complete aggregate
   cap contract is therefore NOT met. Runtime receipt serialization and kernel
   uninterruptible operations also are not hard wall-time bounds.
5. Installed bubblewrap/Python 3.9 behavior, namespace init info semantics,
   `/proc` accessibility, all real denial controls and parent-death propagation
   remain **untested**. Local tests exercise helpers, not sandbox success. The
   deliberate supervisor-loss experiment is implemented, but abrupt loss of the
   outermost controller is not separately injected. No exact-exec provenance,
   syscall trace parser, hard resource quota or protection from concurrent host
   writers is claimed. Missing teardown evidence is inconclusive even if an
   emergency pidfd KILL was sent.

These are explicit incomplete controls, not hidden policy relaxation. Full
proposal PASS, vendor integration and vendor execution require separate work and
review. No existing observer refusal is removed.

## Required parent inputs

`parent-inputs.template.json` is intentionally invalid (`NOT_APPROVED`, nulls).
Do not guess missing values. The parent must supply a separately reviewed
`parent-inputs.json` containing:

- `approval_scope`: `partial-nonvendor-fixture-controls-only` only after review;
- observed `/usr/bin/tmux` realpath and SHA-256, absent from availability-live01;
- exact existing `original`, `work03`, `board_boundary_1`, `board_boundary_2`
  pathnames from existing inventory; these are *absence checks only* here.

All paths must be no-link absolute paths under the existing `new_BSP`; no guessed
work03 location is supplied. Input bytes are pinned separately on the command
line. No SSH alias/address or deployment has been invented/performed.

## Future deployment boundary — NOT AUTHORIZED

The future deployment pathname is exactly
`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/isolation-preflight-u02`.
The only future fixture pathname is the u02 root above. No staging, remote
connection, namespace launch or retry is authorized now. A future parent decision
must bind the newly reviewed `HASHES.json` digest and fresh input bytes explicitly;
there is no filled `parent-inputs.json` here. Do not reuse the old decision, inputs,
manifest hash or receipts. The template remains NOT_APPROVED, null identity/path
inputs, authorization/readiness/vendor flags false. No automatic rebinding.

The interpreter must first be independently trusted against `tools.json`; a
Python program cannot retroactively authenticate its interpreter before that
interpreter starts. The runner checks its own executable thereafter. Reviewed
bundle members are hash-checked before host checks or claim creation. Unfilled
inputs refuse before claiming. Remote successful partial observation still
returns 2, never full acceptance. Preserve output and every claimed file.

## Read-only exposure is not an execution prohibition

Read-only binding `/usr` does **not** imply `noexec` or `nosuid`. Setuid mount
remains visible and executable in that intended view. Inventory-only is not a
kernel exec allowlist. Runtime metadata scanning rejects special endpoints and
nested mounts, not every privileged regular file or capability xattr. Do not
claim a privilege-free runtime tree or an installed-bwrap helper audit.

The unchanged fixed argv requests `--cap-drop ALL` and private namespaces.
Both controls and lifecycle call the unchanged payload baseline first: it must
observe `NoNewPrivs=1` and zero `CapInh`, `CapPrm`, `CapEff`, `CapBnd`, `CapAmb`.
The argv does not explicitly set no-new-privileges; installed bwrap must establish
it and the payload must verify it. These installed controls have not been reached
or qualified by the refused u01 invocation or this local work. No-new-privileges
prevents acquiring privilege on exec, not execution or already-held privilege;
zero capabilities remain essential. No `nosuid` assumption or mount-execution
test is made. Fixed trusted fixture controls are not hostile-code containment,
full sandbox qualification, vendor/license qualification or build readiness.

## Local verification and preservation

Run `python3 -I -B -S` with the absolute path to `run_local_u02.py` only for inert
local tests. The runner exclusively claims `verification-u02-02`; it refuses to
overwrite. That directory holds exact per-test output, tested source SHA-256,
Python version, Python 3.9 grammar results and an unapproved-template CLI refusal.
All existing tests remain (two expectations adapted for the successor root and
full tool union); new tests cover roles, metadata retention, executed privileges,
universal identity failures and the unchanged payload baseline. The existing
owned-child pidfd test starts only an ordinary local Python sleeper. No namespace,
bwrap, tmux, inventory tool or vendor execution occurs. OS identities/capabilities
in the new tests are synthetic mocks, not workstation observations.

`successor-provenance.json` binds original copied source hashes and the disposition.
`source-provenance.json` and `tools.json` are byte-identical to u01. Historical
reviews, approval inputs and execution receipts were not copied as successor
artifacts. `preservation-before.json` and `preservation-check.json` audit the
surrounding qualification tree (including immutable u01) excluding u02.
`root-only.diff` records the fixture-root-only change independently of
`scope.diff`, the full copied-member diff. Only the root constant changes in the
launch design: reserved vendor scratch/observation paths, abstract listener name,
fixed argv, preclaim ordering, B1 ownership, B2 cleanup, bounds and payload remain
unchanged. A source diff is not approval. Old B1/B2 review evidence stays in u01.

`HASHES.json` pins current source/tests/templates/provenance/docs, not itself or
new test results. `EVIDENCE-HASHES.json` separately binds retained local outputs
and fixtures (special files recorded by type, not opened). No full-proposal
acceptance, vendor authorization or readiness follows from passing local tests.
