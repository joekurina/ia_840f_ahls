# FPGA Test — one-shot CAPS01 OPAE identity/capability inspection

## Scope and authority

Joe's current instruction explicitly grants continuation and confirms physical workstation access; see [AUTHORITY.md](AUTHORITY.md). The physical-recovery prerequisite is supplied. This does not guarantee a no-hang operation. The operation uses the source-bound standard OPAE/VFIO path, not guessed hardware addresses. No known failed access is being retried.

Preflight [afu-preflight01-result.json](afu-preflight01-result.json) succeeded on boot `598f7b27-1798-4a88-8a79-9e4a2659c64d`: cached Work21 FME ID, expected exact PF/VF/driver/module identities, singleton group76, assigned 1MiB VF BAR0, FLR-only reset method, D0, expected device permissions, matching runtime bytes, no holders or D-state tasks. No source or FPGA rebuild is needed.

## Single native application

Execute an executable hash-equal copy of the existing mode0600 Target01 launcher; leave the accepted original unchanged. Use the existing AHLS SIF and exact core/plugin/support closure, `/work` read-only, an empty read-only `/empty` working directory, sysfs read-only, and expose only VFIO control plus group76—not PF0/group4, management PF1/group5 or DFL character devices. The source configuration permits only `libopae-v.so` and the exact VF tuple. PF0 remains dfl-pci, so the source's conditional PF-companion VFIO open is not selected. Record dynamic-loader diagnostics separately from test results.

Native application arguments: `--config /work/source/config/ia840f_caps01_vfio.cfg --module /work/build/libahls_memory_entry_vfio_strict.so --inspect-qualified-memory-afu 0000:4f:00.2`.

Enumeration reads the selected VF's GUID before filtering, closes it, and application open repeats the kernel lifecycle. Application reads only aligned R64 offsets `0`, `8`, `16`, `0x98`, `0xa0`, `0xa8`, `0xb0`; identity must match `673c03a1-cef3-4c82-bf10-b12c247d9718`. Capabilities are validated by the unchanged frontend decoder; do not claim unprinted raw values were independently captured. See [host contract](../ahls-memory-host01/HOST-ACCESS-DELTA01.md) and [backend review](../caps01-resume02/BACKEND-REVIEW.md).

## Reset, clock and side-effect disposition

This is not process-wide read-only: reviewed VFIO acquisition/release can issue FLR, the backend may enable PCI COMMAND memory/bus-master bits and maps reported regions RW. No DMA buffers/descriptors or application writes are issued. Preserve standard driver reset handling and all PF bindings; do not disable FLR or force bus-reset fallback. See [exact loaded-kernel review](../caps01-runtime-readiness01/VFIO-RESET09.md).

The bound port gasket selects the PF0/VF0 reset vector and synchronizes it into the AFU port; the function-reset request is not a board power cycle. FLR manager response is timer-based, not a downstream readiness measurement. The static memory wrapper receives system-memory reset (`top.sv:1233-1243`); memory user clocks/reset are supplied separately (`mem_ss_top.sv:262-296`). CAPS01 joins bank0 and AFU reset for its CSR/host crossing. Both static init-done observations were1 on this unchanged boot, no PR/clock change has followed, and no application has launched traffic. These source/prior-state checks support the bounded first inspection, but do not certify all clock/reset/CDC behavior. Successful reads would establish this access path empirically, not general reset, DDR or DMA safety.

## Stop behavior and evidence

One application invocation, no retry. Persist argv, stage markers, native PID/start ticks, log, native return, image/library hashes and loaded-library diagnostics. Stop immediately on unexpected identity/response/error/timeout. A 45s outer observation deadline does not cancel MMIO; timeout records UNKNOWN and sends no signal, launches no alternate probe or recovery. No post-failure hardware reads, resets, rescan, rebind, flash or reboot. Record only ordinary process/log/boot evidence afterward. Normal application cleanup retains its reviewed kernel-reset effects; no additional recovery is appended.

Acceptance requires native application0 and the actual seven read markers plus decoded expected summary, normal container completion, unchanged boot/bindings and no remaining relevant holders. No DDR data, DMA, numerical AHLS or sustained-operation acceptance follows. The frontend's historical “no reset” banner means no explicit application reset API, not absence of implicit kernel FLR.
