# CAPS03 SDK flash and activation — completed

## Accepted result and scope

The requested **BittWare SDK flash → USB BMC Off/On → normal workstation reboot** sequence is complete. The original program23 returned native/effective/outer0 after complete erase/write/readback and successful byte comparison. Separate BMC OFF/ON readbacks passed. A new Linux boot and the expected Work21 static FME compatibility UUID were verified. No repeat flash or standalone flash verify was run. [Program receipt](sdk-program23-result.json), [native log](sdk-program23.log), [BMC receipt](bmc-cycle45-result.json), [postboot receipt](postboot47-result.json).

This establishes programming, the observed BMC power-state sequence, host reboot, and static-FIM identity. It does **not** independently identify the CAPS03 AFU or establish numerical HLS, DDR, reset-entry, sustained-operation or teardown acceptance. The same Work21 FME UUID is shared by persona variants. No application VF was created and no kernel/DMA test was launched. Overall accelerator goal remains incomplete. [Postboot state](postboot47-result.json), [physical/reset-entry obligations](../caps03-persona01/PHYSICAL-ACCEPTANCE01.md), [lifecycle boundary](../caps01-dma-gib01/ERRATUM11.md).

## Original SDK operation

Native start `2026-09-26T06:47:18.132763+00:00`; completion `2026-09-26T09:43:50.732734+00:00`. Duration10592.599971seconds. Native PID7462/start_ticks949300 and tmux@7/%7 are historical, not active. Observer `proc_f6d2723897fa` completed0/output0 and was consumed. Original native exit and complete readback/comparison were independently reconciled from the hash-verified receipt and exact raw log bytes before activation. [Runner](sdk-program23.py), [dispatch](sdk-program23-dispatch.json), [receipt](sdk-program23-result.json), [log](sdk-program23.log).

Actual command:

`/home/uwb_student00/.local/bin/bw_agilex_flash_programmer -i PCI -c 0 program --force -a 0x00000000 /home/uwb_student00/ahls/new_BSP/work_caps03_flash01/sdk-convert21/caps03-sdk.rpd`

The installed source's `--force` permits the selected VFIO transport; it does not bypass verification. `handle_program` erases, writes, reads the entire input length back and compares every byte. All three named phases reached100.0% and the native log contains `Flash programmed successfully.` Boot before/after programming remained `4945ac3f-5bfd-43d3-a4bf-748af43e70b6`; writing alone did not activate the image. [Bound implementation](../caps01-bwflash01/source01-result.json), [final native receipt](sdk-program23-result.json).

## Preserved image and layout

- Accepted CAPS03 full-device SOF remains10065141bytes, SHA256 `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276`. No resynthesis, fit, assembly or HLS regeneration occurred. [Assembly acceptance](../caps03-persona01/ASSEMBLY-ACCEPTANCE01.md), [current bindings](sdk-preflight20-result.json).
- Quartus25.1 native CMake conversion returned zero errors/warnings. The resulting JIC and MAP are byte-identical to convert03. The SDK-compatible RPD is10653696bytes, SHA256 `0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf`; `bitswap=OFF` matches the writer's per-byte reversal. Writer-transformed bytes hash `766eb2697ac16ba4296f47e259b4be306b7d5bd787a1a22af5b8d9c66514fd9d`. [Conversion](sdk-convert21-result.json), [format rationale](../caps01-bwflash01/QSPI-CORRECTION03.md).
- Complete non-RSU layout remains BOOT_INFO `0x00000000..0x001FFFFF`, P1 `0x00200000..0x00A28FFF`, MT25QU02G/ASx4. This is not an RSU user update at `0x04000000`. The exact installed erase formula covers163 sectors/10682368bytes through `0x00A2FFFF`, including28672bytes of sector padding. [Map and image](sdk-convert21-result.json), [source-bound footprint](sdk-program23.py).
- The previously programmed/activated CAPS01 JIC was hash-verified as retained recovery material. No fresh pre-write device snapshot was made; the retained package is not represented as one. [Launch checks](sdk-program23.py), [previous activation](../caps01-jtag-w13-01/RESULT.md).
- SDK card0 was freshly bound to management PF `0000:4f:00.1`,12ba:0070, singleton IOMMU group5. The service was started, not enabled. Pre-write CONFIG_STATUS returned done/init1, zero errors/state, ASx4 Normal and firmware word `0x190100`; that observation did not identify CAPS03. [Target receipt](sdk-target22-result.json).

## Activation and reboot

1. Fresh USB listing identified only IA-840F serial8110055 at USB:0/location1-3.4; power was ON. SDK daemon stop returned0, but its own exit1/failed state is preserved. MainPID0, empty cgroup, absent original PID and empty ownership scan established that it had stopped. This was not relabeled a clean daemon exit. [Pre-activation](activation-pre43-result.json).
2. Applied only the vendor-derived Surprise Down clear/mask bit0x20 on root `0000:4e:00.0`; verified the temporary mask. Removed only PF1 and PF0 with source-bound `pci_device ... remove`. Whole PCI-name inventories confirm exactly those two endpoints disappeared, no other device was removed, and the root remained. No rescan. [Quiescence](quiesce44-result.json).
3. One BMC Off completed09:48:36UTC and separate readback confirmed OFF; after the recorded12-second dwell, one On completed09:48:54UTC and separate readback confirmed ON. Both setters and both readbacks returned0, followed by30-second settle. The initial not-powered warning during Off-state inspection/On setup is explained by the captured `_get_bmc` source; the subsequent ON readback is explicit. No electrical rail waveform is claimed. [BMC receipt](bmc-cycle45-result.json).
4. One `sudo -n /usr/bin/systemctl reboot` was requested at `2026-09-26T09:50:47.769099+00:00` and returned0. Requested/command-result records were fsynced before shutdown and collected after return. [Reboot runner](reboot46.py), [embedded durable receipts](postboot47-result.json).
5. Postboot47 completed `2026-09-26T09:54:40.468170+00:00`: new boot `fb857f04-2297-4a93-9b32-26636641713b`, kernel `5.14.0-687.48.1.el9_8.x86_64`. PF0dfl-pci and PF1vfio-pci are present. sriov_numvfs0/VF absent is expected before per-boot setup. SDK daemon is inactive and ownership scans are empty. [Postboot receipt](postboot47-result.json).
6. Source-verified cached FME accessor returned `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`, matching Work21. Loaded-module build IDs and on-disk hashes match the reviewed cached-accessor evidence. This is probe-time identity read from kernel memory, not new FPGA MMIO or AFU identity. Original AER masks `00100000`/`00002000` and status00000000 were restored after reboot without an extra restoration write. [Postboot receipt](postboot47-result.json).

Initial OS-only preflight19 caught a transient PID1 D-state with no device ownership; both subsequent preflight20 snapshots were clear. Postboot47's local heterogeneous-dictionary type annotation was corrected before remote dispatch; no postboot hardware operation was duplicated. Historical JTAG failures and all progress snapshots remain unchanged. [Initial snapshot](sdk-preflight19-result.json), [accepted preflight](sdk-preflight20-result.json), [JTAG history](RECOVERY18.md), [postboot runner](postboot47.py).

## Durable evidence

Remote root: `/home/uwb_student00/ahls/new_BSP/work_caps03_flash01/`. The reboot ended the original tmux server; its completion buffers are historical. The owned session was recreated after SSH returned. Use the durable result files, not a new wait on the already consumed original completion channel. [Dispatches](sdk-program23-dispatch.json), [postboot](postboot47-result.json).

| Artifact | SHA256 |
|---|---|
| sdk-program23-result.json | `c1c325773aba79acc758d25e537f003156a47e5d4451c53f5ff4e2202ec3deea` |
| sdk-program23.log | `22a4221729a311f8328b8a69823e540c7f9db9f845186a688cc29d4243f2ab1d` |
| activation-pre43-result.json | `73542bb70a5602baec1b0b492f8dd59a8ae01887aac5fb39b1760c58af408de7` |
| quiesce44-result.json | `b0e67fa472ac5a2687cc810e72d81bf0fbde18deaa56e38f21e3ac7bfe73c97c` |
| bmc-cycle45-result.json | `a92136e40e349d5ac50f966b730dc5cb05288094ac6a9a45691b77a0ffe6aa10` |
| postboot47-result.json | `336a62e9e5849941f7657cf29ded2ba3f595a19b2f55f003dc103e47c0765e20` |

Next unfinished work is current-boot VF/OPAE setup and CAPS03 AFU/reset-entry qualification before the admitted numerical copyback case, followed by remaining DDR/sustained/lifecycle tests. Do not reflash unchanged images or infer those gates passed from the FME UUID. No commit/push was performed in this deployment action.
