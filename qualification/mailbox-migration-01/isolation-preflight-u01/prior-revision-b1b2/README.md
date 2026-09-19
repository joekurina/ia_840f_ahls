# Finite nonvendor isolation controls — prepared, not remotely run

**Status: local fixture tests pass; full proposal implementation is incomplete.**
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

- Fixed exclusive root, exactly as proposed:
  `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u01`.
  No alternate suffix, deletion, retry, or reuse. No-link ancestor checks, mode
  0700/umask 077, retained `rw`, `protected`, and host-only `observer` children.
- Observed SHA-256/realpath pins for bwrap, Python 3.9, unshare, mount, setpriv,
  and strace are copied exactly into `tools.json`; only Python/bwrap and a
  separately pinned tmux are executed. Required setuid/file-capability detection
  must work and report no extra executable privileges. Missing pidfd support,
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
  a parent-race check. `--info-fd` gives init PID, validated by namespace identity,
  NSpid=1 and starttime before acquiring/using its pidfd. Inaccessible or missing
  identities do not become a process-group kill or a pass.
- Each inert lifecycle branch independently expires after 18 seconds; this is
  only emergency harm reduction. Acceptance requires confirmed init exit and an
  empty namespace scan before 17 seconds from launch, so natural fixture expiry
  cannot masquerade as tested teardown. Maximum three attempts, 20 seconds each.
  No repeated sandbox launch on failure. All signalling is to this launch's
  pidfds, never process names or unrelated PIDs.
- Stdout/stderr are pipes collected by the host, never writable observer FDs.
  Exclusive JSON receipts include launch argv/env/cwd, raw pipes, init identity,
  results, host state, runtime metadata and final status. Host state/canaries and
  reserved path absence are compared; all fixture artifacts remain retained.

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

## Exact future invocation — NOT RUN

Assuming the parent separately deploys this reviewed bundle at the following
path and creates the reviewed input file, invoke from the existing named tmux
session, not via an invented remote connection. `PREFLIGHT_INPUTS_SHA256` must be
the parent's reviewed input-file hash, not an unchecked on-host auto-rebinding.

```sh
: "${PREFLIGHT_INPUTS_SHA256:?set reviewed parent-inputs.json SHA-256}"
/usr/bin/python3 -I -B -S /home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/isolation-preflight-u01/preflight.py \
  --bundle-sha256 de607a50733c2de7ab036e03cc8087e4ea6eb5f3f2ee85ca6b1a61830602ae87 \
  --inputs /home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/isolation-preflight-u01/parent-inputs.json \
  --inputs-sha256 "$PREFLIGHT_INPUTS_SHA256" \
  --acknowledge-partial-nonvendor-only
```

The interpreter must first be independently trusted against `tools.json`; a
Python program cannot retroactively authenticate its interpreter before that
interpreter starts. The runner checks its own executable thereafter. Reviewed
bundle members are hash-checked before host checks or claim creation. Unfilled
inputs refuse before claiming. Remote successful partial observation still
returns 2, never full acceptance. Preserve output and every claimed file.

## Actual local verification

`local-tests-final.txt` / `local-results.json`: **14 tests passed**, zero failures
or errors on local Python 3.13.5; Python 3.9 grammar checked with `ast.parse`.
Tests cover exclusive claim collision, symlink refusal, negative-control errno
classification, local writable mmap helper, finite metadata/FIFO/cap/deadline
handling, fixed argv, exact proposal paths and observed tool map, tool-identity
mismatch, signalling only an owned inert child via pidfd, retained receipt cap,
syntax and absence of vendor-launch strings. They do **not** establish actual
namespace, readonly mount, network, or lifecycle-chain behavior on either host.
`local-fixtures-01` and `local-fixtures-02` retain both local test batches; no
cleanup. First test transcript also retained. No local bubblewrap run occurred.

`HASHES.json` pins code/test/tool/template/provenance members. `source-provenance.json`
pins the three reviewed source documents without rewriting any of them.
