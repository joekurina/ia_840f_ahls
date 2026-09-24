# Work21 per-boot VF setup — completed

## Result

On the already-verified Work21 boot `598f7b27-1798-4a88-8a79-9e4a2659c64d`, created exactly one PF0 VF and bound it to VFIO. Both native utilities and outer runners returned0; actual sysfs and device-node state were checked after each write. No flash, rebuild, reboot, AFU application MMIO, DMA, or kernel launch accompanied this operation. See [create03-result.json](create03-result.json) and [bind04-result.json](bind04-result.json).

| Binding | Verified value |
|---|---|
| VF | `0000:4f:00.2`, `8086:bccf`, subsystem `8086:1771` |
| Reverse parent | `0000:4f:00.0` |
| VF driver/override | `vfio-pci` / `vfio-pci` |
| IOMMU group |76; only `0000:4f:00.2` belongs to it |
| Device node | `/dev/vfio/76`, character device, UID/GID1000:1000, mode0660 |
| PF0 | `dfl-pci`, sriov_numvfs1, total1 |
| Management PF1 | `0000:4f:00.1`, `vfio-pci`, group5; metadata and device-node ownership/mode unchanged |
| Autoprobe after setup | Original per-PF value1 restored; verified VF stayed bound to VFIO |

## Avoiding an unreviewed AFU read during creation

The historical sequence let `dfl-pci` automatically bind the new VF. That driver's `find_dfls_by_default` reads the standalone AFU BAR, so ordinary-looking VF creation could perform AFU reads before the selected runtime inspection. The existing [backend review](../caps01-resume02/BACKEND-REVIEW.md) identifies that path.

Used the documented per-PF `sriov_drivers_autoprobe` ABI: set0 **before** creating the VF, read back0, execute `sudo -n /usr/bin/pci_device 0000:4f:00.0 vf 1` once, then require the actual VF to be unbound. This changes only the selected PF's future-VF probing, not global PCI driver behavior. The Linux5.14 ABI explicitly states that0 prevents immediate binding and changes do not affect already-enabled VFs ([version-pinned ABI](https://raw.githubusercontent.com/torvalds/linux/v5.14/Documentation/ABI/testing/sysfs-bus-pci); [PCI SR-IOV guide](https://docs.kernel.org/PCI/pci-iov-howto.html)).

Set the verified VF's `driver_override=vfio-pci` before `opae.io init` could load its auxiliary `dfl-pci-sva` module. The same ABI documents that an override restricts matching and does not itself load or bind a driver. Ran only `sudo -n /usr/bin/opae.io init -d 0000:4f:00.2 uwb_student00:uwb_student00`; verified actual binding, isolation, permissions and unchanged management state. Restored per-PF autoprobe1 afterward and verified binding remained unchanged. Saved `/var/lib/opae/opae.io.json` history was unchanged because this VF was initially unbound. See [bind04-result.json](bind04-result.json).

## Kernel/tool binding

[preflight02-result.json](preflight02-result.json) matches loaded GNU build IDs to actual on-disk DFL/VFIO modules, records their hashes, captures the actual DFL SR-IOV callbacks' disassembly, and matches current `dfl-pci.c`/`dfl.c` bytes to the reviewed source. The DFL callback invokes `dfl_fpga_cdev_config_ports_vf` then `pci_enable_sriov`; its conditional FME port-access control is separate from the disabled VF driver probe. VF creation remains hardware configuration, not a file-only action or a universal no-hang guarantee.

The first preflight tried readelf on a compressed VFIO `.ko.xz` and returned1; it performed no hardware operation. The successor decompresses only into owned scratch, then checks ELF notes; original modules are untouched. Both receipts are preserved. `pci_device`, `opae.io` and selected installed source hashes were rechecked by their live runners. Exclusive-operation checks found no selected competing tools or device holders before creation.

## Next boundary

This is verified VF/driver/permission setup, **not** live CAPS01 UUID or capability acceptance. The standalone AFU UUID remains `673c03a1-cef3-4c82-bf10-b12c247d9718`, and its seven reviewed reads depend on bank0 clock/reset plus the host/PR path. Do not start the existing Target01 binary merely because binding succeeded. Its `/work` loader/configuration closure and actual VFIO open/close/reset behavior also remain separate from compile-only acceptance.

A local-only source review `deleg_f054bf3d` is identifying a minimal existing static readiness accessor; parent alone controls hardware. No independent review outcome is claimed yet. Reuse compiled artifacts; no resynthesis, fresh flash, old ASP initialization or UART work.

## Receipt identities

- `preflight02-result.json` SHA256 `dc70edb506fa89e3e395961de28ca6acd9728b42a7c469466d8c9f81e0eb08d8`.
- `create03-result.json` SHA256 `3eeb1e6db3570b52344997e15611929d57019b06f98326f039f72d3446ea990e`.
- `bind04-result.json` SHA256 `ff73bab84f1048c0601ae7a964ac9a21353e9393e5f42b39e813a1500a458600`.

Overall OPAE/DFL/AFU functional goal remains incomplete. Both DDR channels, bidirectional transfers, numerical AHLS and sustained testing remain unrun. No git commit/push in this step.
