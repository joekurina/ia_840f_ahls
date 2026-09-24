# VFIO reset boundary — metadata checked; AFU open not executed

## Decision

The next AFU inspection is **blocked under the current no-host-hang / independent-recovery requirement**, not by missing generic continuation permission or a need to reflash. No independent host restart method is currently available according to Joe's latest answer. A VFIO device open must not be represented as a passive read: the exact loaded driver attempts a function reset, and release can attempt another. The selected function-level reset mechanism is now known, but live bank0/AFU clock/reset/freeze readiness across that reset remains unqualified. Preserve the current working host and do not run the application to discover whether it recovers.

This does not claim that FLR necessarily hangs the host, nor that the current FPGA image is defective. It means the first unqualified AFU open/read/close still cannot be certified against the stated availability boundary. Do not disable kernel resets, change power-management parameters, rebind PF0, bypass OPAE with raw BARs, or launch a reset experiment as a shortcut.

## Actual new observation

[reset-meta08-result.json](reset-meta08-result.json), SHA256 `cac6510e5f236640f662c7f0d622ed4252c9bf6719389f3647ceefca98de2095`, completed native/outer0 at `2026-09-24T20:11:26.550464+00:00`:

- Boot unchanged: `598f7b27-1798-4a88-8a79-9e4a2659c64d`.
- VF `0000:4f:00.2/reset_method` returned literal `flr\n`.
- Cached VF power state: `D0`.
- Existing `/sys/module/vfio_pci/parameters/disable_idle_d3`: `N`; unchanged.
- PF0 `0000:4f:00.0` remains dfl-pci; managementPF1 `0000:4f:00.1` and VF remain vfio-pci; groups4/5/76 respectively.
- Bus4f contains those three functions, and VF physfn points to PF0.
- No reset command, VF device open, MMIO, PCI configuration write, driver change or parameter change occurred.

The upstream comparison `drivers/pci/pci.c` at Linuxv6.12 defines `reset_method_show` as formatting cached `pdev->reset_methods[]`; its store function is distinct and was never invoked. This public source explains the ABI but is **not** asserted to be exact Rocky kernel source. [Upstream source](https://github.com/torvalds/linux/blob/v6.12/drivers/pci/pci.c).

## Exact loaded-module evidence

Completed local-only review `deleg_7f2987b9` is consumed, not pending. Parent independently inspected the captured module disassembly and verified the decisive calls. ELF SHA/build-ID bindings come from `../caps01-work21-vf01/preflight02-result.json` and `source01-result.json`; binary-containing receipts/ELFs remain local-only.

| Exact module symbol/address | Observed behavior |
|---|---|
| vfio_pci `vfio_pci_open_device`, call0x8b | Calls `vfio_pci_core_enable` before finish-enable. |
| vfio_pci_core `vfio_pci_core_enable`, call0x1cfb | Calls `pci_try_reset_function` after PCI enable; app MMIO has not begun. |
| core `vfio_pci_core_close_device`, call0x2d0a | Calls `vfio_pci_core_disable`. |
| core disable0x2c3a–0x2c77 | Conditional reset-capable branch tries device lock and calls `__pci_reset_function_locked` at0x2c5f. |
| core disable0x2b31–0x2bab | Conditional device-set fallback checks open count, reset-needed state and resettable scope before `pci_reset_bus`. It is not an unconditional bus reset. |
| `vfio_pci_dev_set_resettable`0x11d0 and `vfio_pci_is_device_in_set`0x110 | Walks candidate slot/bus and rejects a device not present in the VFIO device set. Preserve PF0's non-VFIO binding; it must not be changed to force this fallback to work. |

Addresses are module-relative disassembly offsets, **not** live kernel addresses or MMIO offsets. VFIO core ELF SHA256 `9e2a52601af5e8ba8264505ce4ba962e9f97066d1fd6ec88eaa22ad89136145a`; vfio_pci ELF SHA256 `7e4180a29d2e668a04e533e44f202c8eef27786558367486578cd3bcc729b39e`.

The existing OPAE inspection performs enumeration open/GUID reads/close and then application open/seven reads/close. Its userspace reset stub does not bypass either kernel path. The frontend's printed “No ... reset ... performed” refers only to its explicit application calls; it must not be reported as a process-wide no-reset claim. [Backend review](../caps01-resume02/BACKEND-REVIEW.md), [source-to-host review §5](../ahls-memory-host01/HOST-ACCESS-DELTA01.md).

## Bound FIM reset implementation and limits

The following bytes match Work21's original input inventory in `../fim21-pr-platform01/result-stage01.json.gz`:

- `ofs-common/src/common/flr/flr_rst_mgr.sv`: `72dae03e3f1b488e25cebf6a504101a018a78ffc63a07265230d1c711b17c1de`.
- `ofs-common/src/fpga_family/agilex/port_gasket/port_gasket.sv`: `7d38322cecdb120047a24603180d95ca69448522469d1ac79abaf8450eaed3ec`.
- `ofs-common/src/common/port_gasket/port_reset_fsm.sv`: `fa7210a352b360a7a6fb1feba39e4e01c3f06dcf2b9183958a8bd9cffe6fdedc`.

FLR manager lines95–152 discriminate PF from VF and decode the requested PF/VF; lines159–188 synchronize corresponding reset wires; lines229–247 respond after the timer's reset/recovery phases. Port gasket lines146–188 select the source-mapped AFU port reset and combine it with other reset sources. This is not a BMC power cycle or evidence that another PF is intentionally reset by the VF reset wire.

However, timer-based FLR response is not an observation of the AFU's bank0-domain reset/clock after the event. The separately read EMIF init-done flags both1 are useful prior initialization observations, not a complete live reset/freeze check. Port-reset traffic inputs are tied high in the captured port gasket lines333–334; do not call those wires proof of drained real traffic. These limitations remain distinct from any actually observed hardware fault—none was induced here.

## Resume condition

Before the first separately bounded VFIO inspection, establish an independent way to recover the workstation if the unqualified device access strands it, and explicitly bind the operation's implicit FLR/open/close effects and post-reset readiness procedure. Joe has already granted broad project execution approval; repeating a blanket approval question does not resolve the missing recovery capability. Once available, reuse the accepted image, VF setup and static runtime closure; do not redo them merely to reconstruct context.

Current goal remains incomplete: AFU UUID/capabilities, DDR data, bidirectional transfers, numerical AHLS and sustained operation are unrun.
