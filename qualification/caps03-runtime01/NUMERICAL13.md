# CAPS03 first real FPGA numerical test

## Result

The first CAPS03 hardware numerical case passed on the unchanged accepted image at the original 3.000 ns target. It ran once through the selected VFIO/OPAE route on `0000:4f:00.2` in boot `fb857f04-2297-4a93-9b32-26636641713b`, starting2026-09-26T19:11:12Z. Both source-bound static EMIF initialization flags were1 immediately before entry. The application is deliberately retained after its data checks; this is **not** native exit0 or lifecycle acceptance. [Native log](live13-native.log), [run receipt](live13-result.json), [verification](numerical13-verification.json).

- Exact source-bound identity-word comparisons passed for CAPS03 AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6`, followed by the versioned capability checks. The log records the accessed offsets rather than dumping raw identity values; the successful comparison is established by the bound frontend control flow. [Frontend](../../src/host/ahls_memory_caps03.c), [native log](live13-native.log).
- Four uploads completed: two64-byte inputs in bank0 and64/128-byte guarded output preparation in bank1. One HLS invocation then returned finish ticket1 and completion`0x10002`. Two64/128-byte copybacks completed from bank1, making six accounted-for DMA descriptors. Both host pages were checked after each descriptor. [Native log](live13-native.log), [frontend](../../src/host/ahls_memory_caps03.c).
- All nine signed32-bit outputs matched `[-3,0,-5,-5,5,7,9,-16,-7]`. The full192-byte returned span also matched its156 non-result bytes:28 tail/padding bytes plus two64-byte guards. These are in-process comparisons against the bound source reference, not a second independent host-memory dump. [Frontend, lines226–278](../../src/host/ahls_memory_caps03.c), [verification](numerical13-verification.json).
- The exact selected entry, core/backend and support-library paths appear in the retained owner's OS maps. Their input hashes were checked before loading. No extra device probe or raw BAR mapping was introduced. [Runtime binding](live13-runtime-binding.json), [postflight](postlive14-result.json).

## Entry review and correction

The complete result of independent review `deleg_62c01146` was consumed before launch. It supports normal idle first-use under initialized, running vendor-clock assumptions and the unchanged-image/exclusive-owner checks; it does not require a new hardware readiness register. Parent verified its one simulation omission: the real `pr_slot.sv:123–126,345–346` contains a host-clock register missing from RESET08's projected wiring. The pinned source SHA256 is `e6f69b311e7d592778f1e75a303c7517ef294dc47e28362a7ac3e87b96b861b1`. [Admission](entry-admission.json), [PR slot source](../../ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/port_gasket/pr_slot.sv).

RESET08 remains a genuine32-case/64-idle-FLR simulation, but not a cycle-exact projection of the complete integration chain. Including the omitted stage, source-derived nominal accounting is `32*9.929 - (19*2.127 + 12*3.000) = 241.315 ns` before FLR ACK, leaving229.315ns beyond four additional bank0 cycles. This supplements the simulation; it is not a new corrected simulation, analog timing guarantee, stopped-clock recovery or active-transaction reset qualification. The FPGA image and vendor sources were unchanged. [Simulation](reset08-result.json), [admission](entry-admission.json).

## Retained owner and actual status

The additive frontend stopped before its first `fpgaReleaseBuffer`; neither buffer release nor subsequent unmap/close/finalization occurred. Its SIGSTOP loop does not return into cleanup. The unchanged container supervisor observed its45-second deadline and retained the namespace without signaling the application. The outer receipt is therefore1 with `Expected allocated-owner retention`, native status is absent/null, and `numerical_data_pass=true` is separate from `success=false` and `lifecycle_pass=false`. Do not relabel this as three zero exits or as a numerical failure. [Retained source](../../src/host/ahls_memory_caps03_retained.c), [run receipt](live13-result.json), [outer receipt](live13-outer.json).

OS-only postflight independently verified:

- Host owner PID7231, start ticks3354890, stateT; namespace PID17; parent PID7226.
- VFIO container/group/device FDs remain open, including `/dev/vfio/76`; no other device owner, D-state task or scan error was reported.
- Container starter PID7176, start ticks3354844, remained alive in stateS.
- Same boot, stable native-log hash and the expected loaded runtime paths.
- The test-interval kernel journal contained only two VF enabling-device notices; no pending-transaction timeout, FLR warning or other error appeared in that captured interval.

No signals, cleanup, reset, rebind, reflash, reboot, retry or extra FPGA access were issued after the data pass. The owner and namespace must remain alive until a supported next operation is admitted. [Postflight](postlive14-result.json), [kernel interval](live13-kernel.log).

## Remaining scope

This establishes one finite numerical case on the final CAPS03 image, including its partial output/tail and two banks used in their assigned roles. It does not establish full DDR address coverage, independent/simultaneous bank qualification, repeated or sustained HLS operation, post-data teardown, cold/PR reset coverage or a successful application exit. The overall hls-samples goal is not complete. The next decision is the supported disposition of this exact successful retained owner, not a repeat of entry or deployment. [Current checkpoint](RESULT.md).
