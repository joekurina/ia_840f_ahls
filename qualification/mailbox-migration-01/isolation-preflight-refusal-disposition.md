# Disposition: unused setuid mount caused the preflight refusal

**STOP retained. A narrow role-scoping correction is justified for a separately reviewed successor; no implementation or retry is authorized by this disposition.** `authorization: false`, `ready_for_build: false`, `vendor_run: false`.

All source references below are relative to this directory. This review used local source and retained capture only; it did not connect remotely, execute tests or reviewed code, launch bwrap/namespaces/vendor tools, or change the bundle.

## Actual refusal and its limits

The parent reports the one approved invocation ended with exit 2, `REFUSED_BEFORE_CLAIM`, and `RuntimeError('privileged/nonregular tool')`. The retained local `isolation-preflight-u01-remote-stop-capture.txt:14–21` records:

- `/usr/bin/mount`: regular file, mode `0o104755`, setuid true, setgid false, capability query errno 61 (ENODATA).
- bwrap, unshare, setpriv, strace, Python (resolved `/usr/bin/python3.9`), and tmux: regular `0o100755`, neither setuid nor setgid, capability query ENODATA.
- The fixed preflight fixture does not exist.

`isolation-preflight-u01/preflight.py:197–218` applies one privilege rejection to every inventory entry. Line 207 rejects mount's setuid mode before reaching its capability query or hash comparison. Therefore the stop capture is mode evidence, not evidence that this invocation finished validating every tool hash. No claim that all tool identities passed follows from it.

The call at line 524 precedes the tmux query (525), bwrap help (538), exclusive fixture claim (544), and namespace attempts (583–584). Combined with the reported refusal, this establishes that this invocation did not reach those subprocesses or a namespace/vendor launch. The Python controller itself did run inside the existing named tmux; “no tools ran” would be inaccurate.

The parent identifies retained remote `isolation-preflight-u01/{invocation.json,result.json,execution.log,stop-evidence.json}`. These exact remote receipts were not fetched or independently inspected here. Preserve them and the local capture unchanged. The capture and source support the reported cause without another remote experiment.

## Source establishes an inventory/execution mismatch

For this **partial implementation**, the closed tool roles are:

| Role | Names | Source evidence |
|---|---|---|
| Executed/trusted execution dependencies | `python3`, `bwrap`, `tmux` | Controller interpreter check at 217; tmux query at 525–528; bwrap help at 538–542; fixed bwrap/Python argv at 232–255 and launch at 391–392 |
| Inventory-only; not authorized for execution | `unshare`, `mount`, `setpriv`, `strace` | `tools.json`; explicit discovery omissions at 552; README 21–26 and 105–106 |

`probe.py` exposes only fixed controls/lifecycle modes (161–168), performs its work through Python APIs, and forks without exec for lifecycle descendants (136–158). There is no mount subprocess, raw-unshare fallback, or setpriv/strace execution in this source. Bwrap's mount setup is not a source invocation of `/usr/bin/mount`; installed bwrap behavior remains unqualified, not assumed exhaustively audited.

The broader `isolation-preflight-proposal.json:120–130` did propose mount/version and other discovery commands. Those were explicitly omitted from the accepted partial implementation. This classification must not be transferred to that fuller proposal or to a future launch grammar that actually invokes mount.

README 21–24 already distinguishes inventory pins from executed tools, but its “no extra executable privileges” wording and the blanket implementation are overbroad together. The refusal correctly enforced the shipped code; it is not evidence that unprivileged bwrap is unavailable. Prior spec/quality approval binds the exact historical manifest and does not approve changing this check.

## Exact minimal correction proposed, not applied

In a separately reviewed successor, split **identity collection for every pinned entry** from **privilege eligibility for the closed executed set**:

1. Bind the role sets explicitly in reviewed source: executed `{python3, bwrap, tmux}`; inventory-only `{unshare, mount, setpriv, strace}`. Require the merged expected map to contain exactly their union, with no overlap, missing name, or unknown entry. Do not default unknown names to inventory-only or accept an unchecked caller-provided role override. Any new command requires execution-role review.
2. Keep the `/usr/bin/` location rule, expected realpath comparison, regular-file requirement, cumulative hash-byte cap, SHA-256 equality and current-interpreter check **for every entry**, including mount. Do not delete mount from `tools.json`, skip its hash, or bypass the identity function.
3. Query `security.capability` for every entry as now; retain the ENODATA-only absent-xattr handling and refuse unsupported/unreadable detection. Preserve actual mode and capability hex in returned receipts, alongside existing pinned fields; record the explicit role as well. A setuid inventory entry must remain visibly setuid in evidence, not normalized to 0755. Existing metadata recording is observation, not an expected-mode equality pin; do not claim otherwise.
4. Apply rejection of `S_ISUID | S_ISGID` and nonempty file capabilities to **each executed entry**. Keep rejection of nonregular files universal. Inventory-only privilege bits/capability bytes are recorded rather than treated as permission to execute. In particular, mount remains regular, hashed and metadata-recorded with its actual `0o104755` mode. No host chmod, package installation, capability removal, or safeguard deletion is proposed.
5. Amend successor documentation to state this distinction explicitly. Preserve fixed payload/argv, preclaim ordering, namespace/FD/capability checks, lifecycle ownership, receipt reserves, bounds, failure cleanup and false readiness/vendor flags. The already-running controller still needs independent interpreter trust before invocation (README 159–161); self-checks are not retroactive authentication.

Before approval, review the successor diff and inert regression evidence demonstrating that privileged executed entries still refuse, inventory-only mount remains hashed/recorded, hash/type/realpath/capability-detection failures still refuse, and role-map omissions/additions cannot bypass classification. This is a finite review requirement, not a request to run those tests in this task.

## Read-only runtime exposure is not an execution prohibition

Mount remains **visible and executable** in the intended runtime view: `preflight.py:236` read-only binds all of `/usr`. A read-only bind does not imply `noexec` or `nosuid`, and inventory-only classification is not a kernel exec allowlist. The runtime inventory (167–194) rejects special endpoints/nested mounts and records modes, but does not reject all setuid regular files or inventory every file capability xattr. Do not reinterpret it as a privilege-free runtime tree.

The relevant separate controls are explicit: bwrap argv requests `--cap-drop ALL`, private user/PID/network/IPC namespaces and a constructed read-only view (232–252). `probe.py:58–84` requires `NoNewPrivs=1` and zero `CapInh`, `CapPrm`, `CapEff`, `CapBnd`, and `CapAmb`, retains mount/status evidence, and checks descriptor restrictions. Both controls and lifecycle call this baseline before their substantive fixture actions. The argv does not itself show an explicit no-new-privs setter; installed bwrap must establish it and the payload must observe it. These checks were never reached in the refused invocation.

Under Linux no-new-privileges semantics, inherited `NoNewPrivs=1` prevents exec from acquiring setuid/setgid or file-capability privilege; it does not make mount unexecutable or revoke privileges already held. The independently checked zero capability sets therefore remain essential. Neither read-only exposure nor user-namespace separation alone substitutes for those checks. No `nosuid` evidence is available from this attempt, and this disposition does not assume that mount flag.

These controls support a prospective fixed, trusted Python fixture experiment, not hostile-code containment or an exhaustive executed-helper prohibition. There is no seccomp/exec allowlist claim, no mount-execution test, and no proof here against all namespace/kernel behavior. If the requirement is that privileged-marked files cannot even be visible/executed, the current `/usr` view does not satisfy it; that would need a separate policy/design decision, not this small correction. Do not broaden this disposition into a sandbox redesign or vendor approval.

## Decision boundary

The existing one-shot authorization (`isolation-partial-execution-decision-u01.md:3–5`) was consumed by the refused invocation; fixture absence does not renew it. Keep the attempted bundle, historical hashes, inputs, reviews, decision and receipts unchanged. No automatic reuse of the attempted deployment or fixture pathname, suffix selection, cleanup, rebinding, or retry follows.

A successor requires explicit new parent scope/decision, separately reviewed changes and new source/manifest/input bindings where changed, with exact successor deployment and exclusive fixture paths approved before staging or execution. Old tool identity pins remain unchanged unless separately evidenced and reviewed. Until then, retain the stop. Even a future successful partial fixture run would leave installed vendor/license behavior, full-proposal acceptance and build readiness unestablished.
