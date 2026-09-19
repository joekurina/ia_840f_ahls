# Preserved successor: first-u01

**Preparation only; not approved for execution. `ready_for_build: false`.**

This directory preserves a successor to the original mailbox harness. The original files, binding template and proposed binding remain authoritative historical artifacts and are not overwritten. This successor awaits independent specification review followed by quality review. The parent's bounded first-experiment design acceptance permits preparation, not live launch.

## Exact scope

The governing documents are `../first-experiment-binding-review.md` and `../first-experiment-binding-proposal.json`. The proposal envelope is not a harness binding. This directory's `binding-template.json` is exactly its `candidate_binding` as a JSON object, with every review/readiness boolean false and `reviewer: null`; no approval or authorization is granted. Preserve these bytes and create a separate approved binding only after independent disposition and explicit authorization.

Only the proposal's three one-occurrence byte substitutions were applied: `migration.py`'s fixed ROOT and the cwd assertions in `child.tcl` and `parent.tcl`. Their SHA-256 identities must equal the proposal. `source-baseline.json` is unchanged. No source-bound gate or other code was cleaned up or weakened. The regression test's only edit changes `LOCAL_N = m.HERE.parents[1]` to `LOCAL_N = m.HERE.parents[2]`, accounting for this extra directory level; `import migration` resolves the sibling successor when the test is run directly.

The fixed future scratch root is:

`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-first-7c407469a419-u01`

It is not this local successor directory. Do not create, reuse, delete or launch into that scratch during preparation. If the future path collides, stop for a reviewed newly named successor. The harness's exclusive mkdir owns the single-use claim, including failed attempts.

## Mandatory separate observer and prelaunch review

The observer/watchdog is **not implemented or verified by this harness preparation**. Before any future launch, separately implement, independently review and verify the proposal's `monitoring_recommendation`: follow-fork strace around the Python harness from process start, not late attachment or polling alone; resolve/hash the actual workstation interpreter and tracer; demonstrate fork/exec/write capture and descendant termination on an inert probe. If tracing is unavailable or restricted, stop for a reviewed equivalent; never run unobserved.

Use the separately exclusive observation root specified in the proposal, outside scratch, with umask 077; approvals and trace files stay outside all scratch snapshots. Enforce 1800 seconds, 2147483648 trace bytes, one-second watchdog checks, TERM then KILL after 10 seconds, tracking descendant PID/start-time identities including setsid children and final survivors. Observer loss, truncation hiding relevant identity, unexpected executable or external effect means stop, retain and review. These are external requirements, not claims about migration.py. This is not an OS sandbox or proof of exhaustive dynamic closure.

Revalidate host/user, named tmux `ia840f_migration_preflight`, fresh path/ancestors, deployed successor hashes, exact source/tool/catalog/evidence identities, protected workspace manifests including original/work03, license readability and SPI/IPX no-links compatibility. Retain and separately compare the proposal's native symlink-chain references; do not insert incompatible symlink paths into no-links maps or rewrite vendor argv. Local evidence is not remote deployment proof. Use exactly the candidate's six-key environment and argv; do not inherit collector overrides or injection variables. Do not copy license contents into reports.

A separate approval may attest review of bounded experimental scope with disclosed uncertainty, not previously successful loading/API behavior or exhaustive closure. Record that interpretation explicitly; no flags are promoted here. Vendor persistent writes are scratch-only; the observation directory is observer-only, not a vendor write exception. No external persistent cache or remote network endpoint is preapproved. No original/FIM sourcing, implicit project, bypass, broad IP upgrade, wrapper callback, synthesis or simulation is authorized.

## Saved-state stages and hard review barriers

1. After separately approved prelaunch checks, stage then selectively upgrade **only** `ip/bmc_spi_sub/sdm_mailbox.ip` using the exact bound qsys-generate vector. **STOP for independent review.** An immediate-parent Qsys rewrite or unrelated version change rejects the attempt even with rc0. At this barrier child proxies remain stale intentionally: require them unchanged and unambiguous, not already coherent with the upgraded leaf. Check actual resolution, full leaf XML/parameters/ports, logs, output inventories, QPF/QSF equality, observer/external-effect audit and original posthashes.
2. Only after independent approval bound to the **exact upgrade report SHA-256**, refresh child `sdm_mailbox` via the preserved named Tcl operations. **STOP for independent review.** Only the expected leaf/child targets may change; both child `componentDefinition` and `defaultBoundary` representations must now be coherent with the upgraded leaf. No broad reload.
3. Only after independent approval bound to the **exact child report SHA-256**, refresh parent `bmc_spi_sub_0`. **STOP for final independent acceptance.** External parent boundaries must remain unchanged. No automatic migration acceptance, stage chaining or build-readiness promotion follows.

At every barrier, independently inspect/static-parse the **full actual XML before constructing role dictionaries**. The known `wait_port()` duplicate-role overwrite weakness is intentionally unchanged. Count AVMM roles and reject duplicates in decoded leaf `lockedInterfaceDefinition`, both child boundary representations and relevant parent representations. Check IP-XACT logical/physical mappings and physical-name uniqueness; conduit role strings require schema-specific interpretation, not a blanket duplicate ban. A harness helper passing is never acceptance.

Require unique one-bit output `avmm_waitrequest`, correct mapping, nontermination and no constant replacement, retained readdatavalid and all old ports/mappings, full hidden/auto parameter set, FIFO depths 1024/1024/4 and feature flags, addresses, clock/reset/IRQ routes, source references, both SPI/SDM requesters and globally shared resets. Review every target timing/property change. Public 23.0.0/core 21.0.0 selections require actual resolution evidence; retain and investigate insufficient evidence rather than manufacturing approval.

Retain exclusive claims, raw before bytes, all inventories, XML, logs, traces, process/maps records, failures and partial outputs through independent disposition. No cleanup, rollback or retry is automatic. Changes to protected original/work03 invalidate acceptance even if later reverted.

This scope is **saved-state migration only**. Nonconstant end-to-end backpressure through generated core/wrapper/interconnect to `sdm_pipeline.m0_waitrequest`, retained readvalid and shared reset/FLR ownership require later standalone and nested RTL generation/validation under separate authorization. Serialized port presence is not RTL proof. No synthesis, fit, timing or hardware qualification is granted.

## Inert regression evidence

Run from this directory with local Python only:

```sh
PYTHONDONTWRITEBYTECODE=1 TMPDIR="$PWD" python3 -B test_migration.py
```

Tests read existing local source fixtures without modifying them; temporary fixture writes stay under this directory and are cleaned up by the existing tests. All vendor subprocess calls are mocked and synthetic XML is not vendor evidence. No Tcl/HDL/vendor interpreter, remote access or build is needed. See `regression-results.json` for the actual interpreter, command, exact test diff, counts, return code, input hashes and preservation checks; `regression-stdout.txt` and `regression-stderr.txt` retain raw output. `SHA256SUMS` covers the delivered files other than itself.
