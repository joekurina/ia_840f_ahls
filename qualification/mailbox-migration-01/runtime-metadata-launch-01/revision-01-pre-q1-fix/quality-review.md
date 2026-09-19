# Independent static quality review

**Verdict: REQUEST_CHANGES — one localized cleanup-error handling defect.**

This is a static quality verdict, not execution authorization. The specification PASS was read independently; live attestation and receiver integration are outstanding execution prerequisites, not defects added by this review. `authorization`, `ready_for_build`, and `vendor_run` remain false. Consumed u03 remains preserved and INCONCLUSIVE.

## Required correction

### Q1 — Gate-close failure can bypass all remaining child cleanup (medium)

**Location:** `launcher.py:197–215`, specifically the unguarded `close(gate_w)` at **199–200**, with `close()` defined at **106–109**.

When setup fails while the gate writer is still owned (for example, child pidfd acquisition or its signal-0 probe fails at 144–146), the `finally` block closes that writer before proceeding to signal/reap/drain/close the remaining resources. Unlike the later descriptor-close loop at 238–242, this first close is not exception-contained. If it raises an `OSError`, execution leaves the entire `finally` block: the direct child is not reaped at 212, remaining descriptors are not closed, and the structured result at 243–260 is not produced. `main()` catches the escaping exception at 294–296 but replaces the result with a generic INCOMPLETE report; it cannot finish the skipped ownership cleanup or preserve the original failure details.

The unreleased child still has the gate timeout/EOF refusal, so this finding does **not** assert that acquisition failure allows collector traversal or signals an unrelated process. It concerns the promised owned-child cleanup on an ordinary reported close-error path, not recovery from process death or an unkillable kernel call.

**Minimal fix:** contain and append the gate-close error inside `finally`, then continue through exact-pidfd error cleanup, direct-child reaping, bounded draining, and the remaining closes. Preserve the existing no-numeric-signal rule. Do not blindly retry a failed Linux `close()` on the same numeric descriptor; `close()` already removes it from the ownership set before invoking the syscall. Add a narrowly scoped inert/mock regression for setup refusal followed by a gate-close error, asserting that reaping and the other closes are still attempted and that both the initiating error and close error survive in an INCOMPLETE result. The current acquisition/probe tests (`test_launcher.py:134–158`) and successful cleanup test (`188–211`) do not inject this failure.

Any implementation change requires refreshing the embedded launcher in `transport.py` and the affected hash/evidence bindings before re-review. No such change was made here.

## Other reviewed properties

- **Bindings:** independently verified every entry in the launch manifest (seven) and unchanged sibling diagnostic manifest (five). Strict base64 decoding confirmed byte-for-byte equality of the transport payload with `launcher.py`, and of the embedded collector with the sibling `collector.py`. Launcher: 29948 bytes, SHA-256 `c02a0b0565cf6c77af2effdcef2961b7ff567dff898b462a9be56af3999c79f1`. Collector: 13851 bytes, SHA-256 `6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897`.
- **Exact child:** callable API checks and self-pidfd signal-0 probe precede fork (`launcher.py:64–73,90`). The child gates before exec; the parent obtains/probes the pidfd and configures nonblocking I/O before release (`118–150`). Nonzero signals use only that handle (`111–115,164,202–208`); numeric `waitpid` is direct-child reaping, not signaling. No numeric/group/name signal fallback was found.
- **Timing:** launch-relative monotonic timing includes fork/startup; the decision function preserves TERM at 65 and KILL at 70, including TERM then KILL if scheduling crosses both thresholds (`76–83,122–123,155–168`). Scheduling and synchronous reap limitations are explicitly disclosed, not hard wall-clock guarantees (`README.md:112–128`).
- **I/O and evidence:** multiplexed nonblocking source/stdout/stderr, partial writes, EOF, per-stream caps plus overflow detection, error-path draining after reap, and byte-preserving base64/length/hash reporting are implemented (`launcher.py:147–196,216–250`). Apart from Q1, inspected cleanup errors are retained rather than permitting completion. Completion additionally requires successful reap/status, no errors/timeout, and completed collector JSON with false authorization flags (`251–260`).
- **Identity/startup:** fixed isolated/no-site/no-bytecode interpreter argv, exact host/UID/environment/parent checks, and realpath/executable-hash checks are present (`launcher.py:11–22,36–61,135–139`). Independent live account/tmux attestation and inherited startup/path-race trust are explicitly external prerequisites (`README.md:68–97,189–193`); no unrelated sandbox redesign is requested.
- **Transport/receiver:** transport checks launcher bytes before in-memory compilation (`transport.py:12–28`). Normal outer output has a cooperative nonblocking deadline (`launcher.py:264–286`). Complete command status, complete envelope, strict stream decoding/bindings/caps, false flags, and completed inner JSON are receiver obligations (`README.md:140–169`). Missing/broken/truncated delivery cannot be accepted; the unimplemented receiver is not represented as production-tested.

## Verification scope

Read `spec-review.md`, `README.md`, `launcher.py`, `transport.py`, `test_launcher.py`, `validate_local.py`, both retained result files, and `SHA256SUMS`. Independent standard-library file reads, AST/literal parsing, strict base64 decoding as data, and SHA-256 verification succeeded. All four local Python sources and the embedded collector parse under the Python 3.9 grammar. AST enumeration found 21 test methods, matching exactly the 21 named retained test entries. The retained results report success; they were **not rerun** and establish neither target-host execution nor receiver integration.

No reviewed module was imported or executed. No tests, validator, collector, transport, remote action, tmux query, vendor command, or commit was run. Created only this `quality-review.md`; no source, manifest, retained evidence, sibling diagnostic artifact, or consumed u01/u02/u03 artifact was modified.
