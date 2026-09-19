# Minimal isolation alternative — design review, not authorization

**Recommend an existing unprivileged bubblewrap sandbox around the vendor subprocess only, conditional on one bounded nonvendor preflight.** Do not finish a general syscall reconstruction engine for this experiment. No capability or installed-tool availability is established by this review. No remote, vendor, harness, namespace, or test command was run. `authorization: false`; `ready_for_build: false`.

## Evidence and policy change

Local evidence (paths relative to this directory):

- `first-experiment-binding-review.md:43–64,66–80,82–96`: exact command/environment, finite loader allowance, external-write prohibition, proposed tracing policy, and independent stage barriers.
- `first-experiment-binding-proposal.json`: authoritative `candidate_binding`, `reference_native_identities_not_harness_paths`, and `monitoring_recommendation`. The companion JSON carries the exact vendor fields copied from that candidate and hashes of reviewed local inputs.
- `observer-first-u01/README.md:16–25`: no complete scope parser; polling cannot account for all descendants; sampling limits are not quotas. Its unconditional vendor refusal is correct **for that implementation and claimed tracing contract**. Do not remove or bypass it.
- `migration.py:341–361`: staging exclusively creates scratch and writes copies and snapshot; `364–410`: upgrade validates snapshots, writes claim/before bytes/log, then invokes `subprocess.run`; `413–435`: comparison and reports follow vendor exit. `successor-first-u01/README.md:9–27` preserves this logic with the fresh-root substitutions, not a sandbox integration.
- `source-baseline.json`: named BMC source and board-boundary identities, readiness false.

A mount/PID/network boundary addresses prevention rather than attempting to infer every possible write from strace. It does **not** prove catalog selection, executed-helper allowlisting, semantic selectivity, or absence of attempted forbidden actions. The parent must explicitly approve a replacement for the original complete real-time syscall-audit requirement: trusted installed vendor code, kernel-enforced external filesystem/network isolation, bounded diagnostic observation, then independent output acceptance. Without that explicit policy amendment, the old observer contract remains unsatisfied. No boolean is silently reinterpreted here.

## Chosen boundary

### Filesystem and descriptors

Build a private mount namespace using already installed bubblewrap, without sudo, installation, persistent mounts or host changes. All exposed host filesystem data is read-only **except the exact fresh scratch root**, mounted at its unchanged absolute path. Prefer a constructed filesystem view: expose the installed `/opt/altera/26.1.1` tree and required OS executable/library roots read-only at their original paths, preserving actual `/bin`, `/lib*` symlink layout; expose only required regular `/etc` configuration files. An initially empty root is safer than blindly exposing `--ro-bind / /`.

A whole-root read-only bind is only an alternative after proving recursive read-only treatment of all descendant mounts and covering every unsafe subtree/alias. A read-only bind does not disable an existing pathname UNIX socket, FIFO, device, or already-open writable descriptor. Merely masking `/run` is insufficient if sockets remain in home, `/var`, shared mounts, or vendor roots. Do not claim that `--ro-bind / / --bind SCRATCH SCRATCH` alone meets the policy. For this minimal proposal choose the constructed view, not an expanding whole-host masking exercise.

- Mount scratch at `candidate_binding.root`; nothing at its parent is writable or broadly exposed. Original/FIM/work03 need not be visible to the vendor. A synthetic `/home/uwb_student00` contains only the exact scratch mount and the read-only license file at its exact pathname. Observer files, approvals, staging implementation, SSH/tmux sockets and other home data are absent, not merely chmod-protected from a same-UID process.
- Preserve the license as a read-only regular-file bind; never dump license bytes. Preserve necessary machine-id/hostname files read-only where appropriate. Do not infer licensing success from readability.
- Fresh PID-namespace `/proc`, never host `/proc`: prevent paths through host `/proc/PID/root` and `/proc/PID/fd`. Protect kernel-control entries; keep `/sys` absent by default, exposing only specifically justified read-only identity data if needed. No host `/sys` device-control tree, cgroup filesystem, device nodes, or host IPC objects.
- Minimal private `/dev`: null, zero, random and urandom as needed; no host device-tree bind, terminal, disk, GPU/FPGA/USB nodes or `/dev/log`. Private `/dev/shm` only if needed; bounded ephemeral IPC storage is an explicit nonpersistent exception, not permission to write host shared memory.
- `/tmp` and `/var/tmp` resolve to storage backed by scratch `tmp`, without changing the six-key environment. Host `/run` and host `/var` remain absent; expose individual required regular runtime data files rather than those directories. Mount topology/symlinks must be chosen before staging snapshot finalization if they require any scratch directories. No later helper inserts files into scratch to repair equality checks.
- Verify exposed trees contain no host sockets/FIFOs or extra mounted filesystems through which effects escape. Check finite exposed-root metadata, not catalog Tcl closure. Cap exhaustion is inconclusive and stops this candidate. Do not follow symlink escapes into newly exposed host roots; fail/report missing dependencies rather than broadening mounts automatically.
- Staging uses byte copies, never hardlinks to originals. Check scratch has no external hardlinks or nested host mounts before vendor start. Symlinks cannot grant access outside the exposed view, but still must comply with existing harness no-links rules.
- The parent closes all inherited FDs except stdin from `/dev/null` and stdout/stderr **pipes**. Host-owned collectors write pipe bytes to retained logs; do not give the vendor open evidence-file descriptors or a terminal. Any sandbox setup/info descriptors must be consumed and closed before vendor exec. No host namespace FD or agent socket crosses the boundary.

Read-only exposure is not confidentiality isolation for exposed files, a snapshot of concurrently changed host data, or resource/host-kernel isolation. This design trusts the installed vendor/runtime and the operator; it is not a hostile-code VM.

### Network, machine identity, local IPC

Require a separate network namespace with no external interface, veth, route, DNS service or host networking. Namespace-local loopback IPC may be available; it cannot reach the host loopback. Unshare SysV IPC as well. Abstract AF_UNIX sockets are network-namespace scoped; pathname AF_UNIX sockets are controlled by mount visibility, **not** read-only permissions. Scratch-local pathname sockets and anonymous pipes are allowed; never expose system/user D-Bus, SSH agent, tmux or external license-daemon sockets.

Do not unshare UTS merely for appearance: retaining hostname can help identity compatibility without granting network access. A new network namespace normally hides the physical NIC and MAC from ioctl/netlink discovery. Keeping `/etc/machine-id` or read-only sysfs text does **not** guarantee FLEXlm host-ID behavior. The nonvendor probe compares host and sandbox hostname/UID/machine-id availability and NIC/MAC visibility without running `lmutil`, Java, Quartus, or a license checkout. Record mismatch as a compatibility uncertainty, not sandbox failure or vendor-license success. No moving host NICs, fabricated/spoofed MACs, license edits or shared host network fallback. A later explicitly authorized isolated upgrade may return a license error; retain it and stop. If licensing requires host NIC discovery or external service access, the parent must decide whether to redesign or accept a narrower containment claim; that is a risk-scope decision, not a reason for recursive IP-catalog discovery.

### Lifecycle, observation and acceptance

Use private PID namespace with a stable namespace-init identity, no capabilities in the vendor, `no_new_privs`, and a new session. Drop privileges after setup. The host supervisor must hold/validate the init identity (prefer pidfd), TERM with 10-second grace, then KILL namespace init. Kernel PID-namespace teardown covers double-fork/setsid descendants; killing only a process group or the outer launcher is not enough. Verify the actual installed bubblewrap parent-death/init behavior with inert probes, including supervisor loss. Do not assume `--die-with-parent` alone proves the entire chain.

Keep the future experiment's 1800-second wall limit, one-second watchdog interval and 2147483648-byte observation threshold. These are stop thresholds, not hard aggregate scratch/disk/memory/process quotas; disclose residual resource-exhaustion risk. Supervisor death, timeout, missing final receipt, collector error, output overflow or uncertain teardown rejects the attempt. Preserve all claims and partial artifacts; no automated cleanup/retry.

Use retained exact launch argv/env/cwd, namespace/mount/FD receipts, stdout/stderr, process identities and available bounded exec/file trace as diagnostics. Do not implement a path/FD/mmap syscall reconstruction engine. If strace is used, bind its version/options and avoid secret read buffers; it is supporting evidence, not the write boundary. Polling is not complete exec provenance. Unexpected observed helpers/generation still stop; **instant exhaustive unexpected-exec detection is not claimed**. If the parent requires that original property, this minimal alternative does not meet it.

Before and after each stage, independently compare original BMC exact inventory, both board boundaries, the explicitly identified protected original/work03 manifests, known tool/catalog/evidence identities and recorded library symlink chains. Before/after equality cannot disprove write-then-revert by concurrent outside processes. Vendor-visible mounts enforce vendor write restriction; hashes remain drift/acceptance checks. Preserve raw before bytes, complete scratch directories/files, project equality and full actual XML. Keep upgrade → review → child → review → parent barriers, duplicate-role checks and later RTL-proof requirements unchanged. Readiness stays false even if isolation and migration succeed.

## Integration: separate staging, vendor, reporting

1. **Trusted host staging:** after future separate authorization, the successor harness owns exclusive scratch mkdir, source-copy validation and staged snapshot. External supervisor owns an independently exclusive observation claim. Do not precreate the real scratch for a namespace probe; use the separate preflight path in the JSON.
2. **Trusted host launch preparation:** retain all `run()` binding/snapshot checks and exclusive stage claim/raw-byte evidence. Establish supervisor readiness and record the exact sandbox contract outside scratch. Add no unintended scratch files after snapshot checks.
3. **Vendor-only sandbox:** a future reviewed successor integration replaces only the subprocess execution boundary with a sandbox launcher. Inside it, execute the identical candidate vendor argv, cwd and six-key env without shell expansion, path rewriting or extra flags. The outer launcher is separately bound; it is not inserted into the vendor argv identity. Namespace setup must complete before any vendor executable starts. Pipes return stdout/stderr for the existing retained log.
4. **Trusted host reporting:** only after confirmed namespace teardown, perform existing comparison/report logic and independent review. The report inside scratch is an output, not an independently protected observation receipt; outside collector evidence remains inaccessible to vendor.

Simply wrapping `stage` in a scratch-only RW sandbox fails because scratch must not already exist. Giving the whole qualification parent RW exposes evidence. Running the unchanged `upgrade` host-side launches an unsandboxed vendor; running the entire harness inside exposes its report/control context and complicates snapshot rules. Therefore a small, explicitly reviewed future integration is necessary; this document does not implement it, authorize it, alter hashes or bypass the current observer gate. Preserve existing successor hashes as historical bindings; any future code changes require new harness hashes and review, while vendor fields remain byte-identical.

## One finite next step and decision tree

`isolation-preflight-proposal.json` specifies one nonvendor remote batch, **not executed or authorized here**: resolve existing tools, check namespace policy read-only, use an exclusive disjoint fixture, inspect exact mount/identity behavior, exercise inert write/socket/FD/descendant/parent-loss controls, retain receipts. No installations, sudo, sysctl/firewall changes, NIC changes, daemon changes, package/catalog downloads, vendor invocations or actual migration staging. Host connection/identity and exact protected work03 path must come from the parent's existing verified workstation inventory; never guess them.

If bubblewrap is absent but unprivileged namespace creation is available, record installed `unshare`/`mount`/`setpriv` capabilities once. A raw unshare recipe needs separately reviewed mount/root, privilege-drop and PID-init lifecycle composition; **it is not an automatic equivalent fallback**. Do not install bubblewrap, write a container runtime, or retry progressively weaker isolation in this batch.

- **Engineering blockers:** installed sandbox unavailable/restricted, unsupported required semantics, exposed socket/FD or writable mount, missing helper identity, invalid teardown, snapshot-integration defect. Fix only within separately authorized local scope or select a separately reviewed existing facility; no vendor run meanwhile.
- **Risk-scope decisions:** whether trusted-code containment plus nonexhaustive diagnostics may replace full syscall/exec provenance; whether to accept resource/concurrent-writer limitations; whether license incompatibility justifies different network/identity exposure. Isolation unavailable is not permission for an unsandboxed run. Parent can retain the stop, choose a suitable existing isolated host/VM subject to licensing, or obtain explicit approval for a reduced monitored-only contract. Do not represent the latter as equivalent isolation.
- **Experimental outcomes, not circular prerequisites:** vendor loader behavior, actual license checkout, selected component/API behavior and selective saved-state deltas. No repeated catalog hunt and no demand for successful vendor execution before permission to try the isolated experiment.

## Reference semantics

Consulted upstream documentation, not evidence of the remote installed version:

- [Bubblewrap README](https://raw.githubusercontent.com/containers/bubblewrap/main/README.md): configurable rather than ready-made sandbox, mount policy, `no_new_privs`, PID reaper, network namespace and D-Bus/terminal hazards.
- [network_namespaces(7)](https://man7.org/linux/man-pages/man7/network_namespaces.7.html): NIC and abstract UNIX-socket isolation.
- [pid_namespaces(7)](https://man7.org/linux/man-pages/man7/pid_namespaces.7.html): fresh procfs and namespace-init death killing namespace processes.

Only the two isolation review/proposal deliverables are written by this task. No readiness promotion or execution authorization is issued.
