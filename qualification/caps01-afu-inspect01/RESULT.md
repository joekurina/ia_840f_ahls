# FPGA Test — first live CAPS01 identity/capability result

## Observed result

**Native application 0 / container 0 / outer 0.** One OPAE invocation completed on boot `598f7b27-1798-4a88-8a79-9e4a2659c64d`, at 2026-09-24T20:54:01–20:54:03 UTC. No retry, reflash, reboot, manual reset or driver rebind occurred. Independent result review is pending; raw success is not a declaration that the overall hardware goal is complete.

The existing hash-bound frontend enumerated the exact VF and required the intended AFU UUID, then checked all three identity words and decoded all four raw-capability words. Actual native output:

```text
FPGA Test identity read 0x0
FPGA Test identity read 0x8
FPGA Test identity read 0x10
FPGA Test capability read 0x98
FPGA Test capability read 0xa0
FPGA Test capability read 0xa8
FPGA Test capability read 0xb0
FPGA Test identity/capability PASSED: banks=2 beat_bytes=64 host_address_bits=57 max_descriptor_beats=130816
No DDR data, DMA, kernel execution, reset, PR or durable-boot test performed.
```

The test establishes live AFU identity `673c03a1-cef3-4c82-bf10-b12c247d9718` and the narrow identity/capability path through real OPAE/VFIO. It reports banks2, beat_bytes64, host_address_bits57 and max_descriptor_beats130816. The frontend did not print each raw capability word; do not promote its decoder success into an independently captured exact-value dump.

## Host and runtime observations

- Preflight verified unchanged Work21 cached FME identity, exact VF/PF bindings, singleton VF IOMMU group76, 1MiB BAR0, FLR-only/D0 metadata, runtime/module hashes and an empty process/device-holder scan. See [preflight](afu-preflight01-result.json).
- The one-shot application used an executable hash-equal copy of the existing mode0600 launcher, leaving original Target01 bytes and mode unchanged. The existing AHLS SIF, entry/core/plugin/support libraries and config were reused; no host or FPGA rebuild occurred.
- Runtime prechecks verified read-only work/exec/sysfs mounts, empty read-only CWD and only `/dev/vfio/vfio` plus `/dev/vfio/76` visible. Actual dynamic-loader diagnostics are captured in the main result; these are execution evidence, separate from the earlier static loader result.
- Native application PID16 is **inside the container PID namespace**; outer container PID6718/start_ticks468244 is the host-side launcher record, not the same process identifier.
- Postflight ordinary process scan found no FPGA device holders, relevant programmer processes or D-state tasks. PF0 remains dfl-pci; PF1 and VF remain vfio-pci. Boot unchanged and original selected runtime files hash-identical.

## Reset and acceptance boundaries

The native banner saying no reset means **no explicit application reset API**. Exact kernel review establishes reset-capable VFIO acquisition/release; the operation was planned with those implicit FLR paths and PCI COMMAND setup included. No reset trace was installed, so source-established reset behavior is not a measured reset count. This bounded successful lifecycle is not a universal no-hang or reset/CDC qualification.

Both DDR channels have **not** been tested for data integrity, either individually or simultaneously. No DMA/bidirectional transfer, numerical AHLS, boundary/repetition or sustained test occurred. Existing flash-boot acceptance is retained separately. Physical recovery availability is Joe's current explicit report, not a property established by this application.

## Evidence

- [Plan](PLAN01.md), [current authority](AUTHORITY.md).
- [Native/runner result](afu-inspect02-result.json), SHA256 `953b5a67c61f6cd0ce24ed8ae64db0f35d9642fcc19a8e906cf6a7f9c54f10b4`.
- [Native log](afu-inspect02-native.log), SHA256 `664c7cb860be3911d95861ef58bd28493935e4d40b9f344f863263bd7b8268bd`.
- [Independent outer-return receipt](afu-inspect02-outer-result.json).
- [Runtime binding](inspect02-binding.json), [inner runner](inspect02-inner.py).

Next functional boundary is a separately source-bound, finite transfer test with correct DMA buffer lifetime and failure handling. Do not reuse the scalar frontend or infer transfer safety from this read-only application test.
