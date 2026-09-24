# FPGA Test — first real host/DDR roundtrips

## Observed result

Both separate invocations completed **native/container/outer0/0/0** through the actual strict OPAE/VFIO backend. Neither was an inert executable. The compiled frontend checked identity/capabilities, registered real buffers, programmed the two descriptors, required fresh local retirement, actively compared the returned64-byte payload, checked all4096bytes of each host page including guards, released resources and finalized normally.

| Logical bank selection | Time UTC | Transfer | Descriptor counters | Status polls | Result |
|---|---|---|---|---|---|
| 0 | 2026-09-24 21:45:10–21:45:13 | 64B host→DDR, then64B DDR→host | 1,2 | 2 per descriptor | Data and page checks passed |
| 1 | 2026-09-24 21:47:14–21:47:17 | 64B host→DDR, then64B DDR→host | 1,2 | 2 per descriptor | Data and page checks passed |

These times include supervision/preflight work, **not benchmark timings**. The two status polls do not by themselves establish an observed busy transition. Completion freshness and idle/error predicates are supplied by the hash-bound actual frontend/core.

Bank-local DDR byte offset was0x10000, aggregate address0x10000 for bank0 and0x400010000 for bank1. This is a DDR address, **not a write to the kernel's MMIO aperture**. Returned host IOVA bases were0 and0x1000; payloads used+64 within two4096-byte mappings. IOVA0 is valid in this observed backend, not a null CPU pointer. Patterns depend on address/bank, and destination poison differs in every byte.

Actual loader calling-init records select `/dma/build/libahls_memory_dma_entry_vfio_strict.so` and the accepted `/work/sdk-build/lib/` OPAE core/VFIO/support closure. No xfpga/UIO/ASE library was initialized in those logs. Exact new artifact hashes and static source/ELF provenance are retained in RESULT04.md and dma-build03-result.json. No FPGA rebuild or programming occurred.

## Postflight and limitations

Both runs retained boot598f7b27-1798-4a88-8a79-9e4a2659c64d, PF0 dfl-pci, managementPF1 vfio-pci, and AFU VFvfio-pci. Postflight scans reported empty holder/relevant/D-state lists; selected original and new runtime files remained hash-identical. No owner is retained and no application is still running. Standard implicit VFIO function-reset lifecycle applies; no explicit reset/retry/rebind/reflash/reboot was performed.

This is **two tiny logical-bank path tests**, not physical bank-isolation proof. Writing then reading each selected bank separately can pass even if the banks alias; cross-bank retention and simultaneous access remain untested. No GB-scale/address-range/boundary/sustained DDR test or numerical AHLS/kernel launch has occurred. Existing controller/pin/timing/calibration-association qualification items are not closed by64-byte samples. Vendor DDR simulation remains skipped by user.

The source/frontend review is ACCEPT WITH BOUNDED LIMITS (FRONTEND-REVIEW04.md). Independent review of these actual runtime results is pending. No universal no-hang, cache-coherence, whole-system drain, or reset certification is claimed.

## Evidence

- [Bank0 receipt](bank0-07-result.json): SHA2561d87c64a465f6f54b09d156aabca9efdd1edcefbac6895e0735641ebac8d6839; [native log](bank0-07-native.log), [outer receipt](bank0-07-outer-result.json).
- [Bank1 receipt](bank1-08-result.json): SHA256ce54fedf593dd942ce8185177f19586227a661d41bd09b5d70a2a940089074e4; [native log](bank1-08-native.log), [outer receipt](bank1-08-outer-result.json).
- [Machine-readable result summary](roundtrip-summary09.json); [bank0 plan](BANK0-07-PLAN.md), [bank1 plan](BANK1-08-PLAN.md).
- Device-free container-lifetime fixture: supervisor05-result.json SHA256ec48870ff8943c29d4f2151d321f323477c887912e66f00d46f2b6cdd53d7fbe. Clean exit, deliberate production-helper hold, deadline and post-spawn save error all behaved as required; held owners survived outer-observer exit. Fixture cleanup was restricted to known device-free namespaces and is absent from the live supervisor/runner.

**Overall goal is not complete.** The next useful boundaries are cross-bank isolation/larger bounded transfers and a source-bound numerical AHLS frontend; do not reuse the old scalar CSR protocol.
