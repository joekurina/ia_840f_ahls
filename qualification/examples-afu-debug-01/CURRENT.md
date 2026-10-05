# Copy/DMA debugging — functional repairs accepted

**Both original data-test shapes now pass and are independently accepted.** The remaining VFIO cleanup warning is preserved, not solved or waived. No native build, card operation or review remains active.

- [Final readable summary](FINAL-SUMMARY43.md)
- [Copy final acceptance](copy_engine-cap27/FINAL-ACCEPTANCE43.json)
- [DMA final acceptance](dma-cap27/FINAL-ACCEPTANCE43.json)

| Variant | Actual tested scope | Result |
|---|---|---|
| Copy-engine cap27 | 32 × 4 KiB, maxreq8, completion1; bitwise-NOT oracle | Build/effective0/0, PR0, host0; 2,048 read/write lines; zero data errors |
| DMA cap27 | Bank0, one1KiBH2D + one1KiBD2H, original host, no chunk workaround | Build/effective0/0, PR0, host0; all128 words correct |

Independent FINAL `deleg_394c8322` task0/task1 is consumed. Both frozen manifests41 rehash correctly: 19 entries each, all size/hash matches. Original-source preservation and native44/44 copy and47/47 DMA input preservation remain verified. The accepted scopes exclude timing/performance, capacity/isolation, error-injection and future health.

## What changed

Copy's earlier identity checker was my error: the tutorial explicitly inverts payload bits. A separate host now verifies the proper transform. Its original32×64-byte control passed before changing RTL. Old wrong-oracle and timeout receipts remain untouched.

The shared additive AFU-side adapter caps host-facing fragments at256 bytes, preserves the original wide engines, and uses private USER4 rather than the PIM's internal bit0 NO_REPLY. It preserves addresses/data/masks/IDs/USER widths, clocks/reset and existing PIM sorting/buffering, while reconstructing fragment WLAST and original response cardinality. Alternate tops and copied source lists select it; originals and retained FIM/export are unchanged. [Source acceptance29](CAP-SOURCE-ACCEPTANCE29.json), [source candidate27](packet-cap27/review-manifest27.json).

Retained sources permit512-byte PU writes, while captured PF0DeviceControl0x2930 hasMPS256/MRRS512. Source/size controls and the successful repair support the packet-sizing diagnosis; actualwireTLP sizes/rejection were not captured. PCIeGen3 itself is not a256-byte payload ceiling. DMA's earlier host256-byte chunk workaround is not used in the final capped-image test.

## Retained tested images

Under `/home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01/`:
- `copy_engine-cap27/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs`: SHA256 `9ed7a4b6c900505ef555fa6c1dfbda282737d70ba46fc8f34dacd80eb0d583dc`.
- `dma-cap27/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs`: SHA256 `69c83b336a6b4bae3e0a8fe19b9c197d50fabd125c24893eebaad3768954abe2`.

Both native/effective compiles exited0; GBS/nativeRBF pairing and source/UUID sanity were validated before serial hardware. No synthesis is needed to reuse unchanged tested images. Build-waiter notices `proc_d160d3454216`/`proc_14797322de69` refer to completed, consumed jobs; do not relaunch them.

## Important remaining warning and limits

Both passing tests still logged `timed out waiting for pending transaction; performing function level reset anyway` during VFIO cleanup, at7639.887118(copy) and7779.246637(DMA). Ordinary postflight holders/maps/errors/relevant-process lists are empty on boot `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`; that is not global DMA-drain or safe-reset/future-health proof. [Copy kernel delta39](copy_engine-cap27/kernel-delta39.log), [DMA kernel delta41](dma-cap27/kernel-delta41.log).

Copy's pattern repeats within256 bytes and its unchanged AxBURST iszero, not explicitINCR; generic fragment-permutation/FIXED semantics are not qualified. DMA scope is aligned full-width16-beat WRAP and low32IOVA bank0. Read-RRESP visibility is incomplete and intermediateBRESP errors are not aggregated. No broader error/drain/reset qualification is claimed.

## Next action

**None for these functional data repairs.** Diagnose the remaining VFIO lifecycle warning or stronger coverage only as a separately directed follow-on. The accepted copy and DMA repair milestones are published separately, with their original frozen receipts preserved. Task prompt documents have been removed from the current repository tree and backed up privately outside it; historical snapshot references remain unedited. See the operator guide for the release supplement's final publication links. No reflash, power-cycle/reboot, link/MPS/driver changes or speculative MMIO/BAR probing was performed for this repair.
