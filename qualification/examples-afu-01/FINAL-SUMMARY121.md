# Final tutorial AFU campaign result

## Closure verdict

**The requested campaign is complete under the goal's recorded-failure policy—not an all-pass platform qualification.** All eight AFU variants were natively built, loaded through normal `fpgaconf`, and executed on the IA-840F. Six passed their scoped checks. Copy-engine and corrected DMA failed data verification; those failure dispositions were independently reviewed, committed and pushed. The README-only `PIM_advanced` entry was explicitly skipped. [Machine-checked aggregate](FINAL-AGGREGATE121.json), [goal acceptance policy](../../GOAL-PROMPT-EXAMPLES-AFU.md#evidence-and-acceptance-policy).

| Variant | Native build / final PR / host exit | Result | Published disposition |
|---|---|---|---|
| hello_world / avalon | 0 / 0 / 0 | PASS: full 64-byte greeting check | [Acceptance63](hello_world-avalon/ACCEPTANCE63.json), `019f51432c6af00cc4a322f15f00f292801d21a3` |
| hello_world / ccip | 0 / 0 / 0 | PASS: full greeting check | [Acceptance77](hello_world-ccip/ACCEPTANCE77.json), `3c62fa8341c7042fc0741f9685f85060b39d127f` |
| hello_world / axi | 0 / 0 / 0 | PASS: full greeting check | [Acceptance77](hello_world-axi/ACCEPTANCE77.json), `4aa239eb6c9790b154c46daef1d3fd59d26ef40f` |
| clocks / single | 0 / 0 / 0 | PASS: relative-frequency/divider checks after authorized ACL fix | [Acceptance93](clocks-single/ACCEPTANCE93.json), `d29b40874a6bf4a21d3aee997f70fec1bd48e8ce` |
| local_memory / avalon | 0 / 0 / 0, 0 | PASS: commanded-data checks on banks 0 and 1 | [Disposition86](local_memory-avalon/FINAL-DISPOSITION86.json), `f6dabd611090e291c5f54da4fc7bd5638170ff73` |
| local_memory / axi | 0 / 0 / 0, 0 | PASS: commanded-data checks on banks 0 and 1 | [Acceptance105](local_memory-axi/ACCEPTANCE105.json), `d51a6394fc82028c84c966dffbf7c3c6ebdd5d32` |
| copy_engine / single | 0 / 0 / 1 | FAILED: 2,048 checked bytes mismatched | [Failed disposition120](copy_engine-single/FINAL-DISPOSITION120.json), `c5f52a35cf1626780809eb538885db1bb6f74dca` |
| dma / single | 0 / 0 / 1 | FAILED: 128 checked words mismatched | [Failed disposition120](dma-single/FINAL-DISPOSITION120.json), `e995487003a6702be7f7fc45bffd41ef6742e0be` |

`PIM_advanced` has no sample AFU RTL. It is outside the eight-variant count, not a fabricated build or test. [Target inventory](targets28.json), [original README](../../examples-afu/tutorial/afu_types/01_pim_ifc/PIM_advanced/README.md).

## What the failures establish

Copy attempt115 used `--chunk-size=64 --completion-freq=1 --max-reqs=1`, noninterrupt mode, and checked 32 distinct buffer payloads. The host reported 32 lines read and written, but its exact data marker was `CHECK copy_payload buffers=32 bytes_per_buffer=64 errors=2048 FAIL`; native host exit1 remains decisive. The earlier 4 KiB-command completion deadline, AFU-not-found host retry, ineffective VF reset and PR Status timeout are preserved separately. [Copy capsule](copy_engine-single/CURRENT.md), [actual output115](copy_engine-single/hardware-result115-readback/hardware-attempt115/host0.stdout).

DMA attempt118 used the previously reviewed RTL/host corrections: one bank0 1,024-byte descriptor in each direction, separate pinned source/destination buffers, validated low-32-bit IOVAs and a full 128-word check. Source IOVA was `0x0`, destination IOVA `0x1000`. Its exact marker was `CHECK DMA roundtrip bank=0 bytes=1024 words=128 errors=128 FAIL`; host exited1. [DMA capsule](dma-single/CURRENT.md), [actual output118](dma-single/hardware-result118-readback/hardware-attempt118/host0.stdout).

Neither failure is root-caused. Completion counters, valid GBS containers, silent PR0 and empty host stderr do not prove successful data delivery. Independent FINAL `deleg_37f9cfb7` accepted both **failure reports only**. No MPS/address/protocol explanation or hardware pass is inferred.

## Recovery and material warnings

Joe explicitly authorized card power-cycle and workstation reboot recovery. One source-supported recovery was executed: card-only PF1 then PF0/VF PCI removal, donor Surprise Down-bit AER preparation, USB BMC Off/On with separate readbacks, and one normal workstation reboot. No reflash or FPGA rebuild occurred. Reboot preparation110 failed at a module-path lookup before issuing reboot; corrected112 resolved the installed weak-updates paths through `modinfo` and performed only the remaining reboot. [Power receipts](recovery-power110-collection.json), [postboot receipts](recovery-postboot113-collection.json), [VF setup receipts](recovery-VF114-collection.json).

New boot `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`, native reboot0, module hash/build-ID continuity, cached probe-time FIM interface compatibility and AER-mask restoration were verified. VF0 was recreated, deliberately bound to VFIO, and per-PF driver autoprobe restored before the final tests.

**Kernel warnings remain unwaived:** at boot-relative `195.897734` and `310.912886`, VFIO reported pending-transaction timeouts and performed FLR anyway. Final ordinary OS ownership observation found no holders, mappings, relevant processes, D-state entries or acquisition errors. This does **not** establish global DMA drain, healthy/safe hardware, reset qualification, future health or no-hang guarantees. [Final kernel and ownership collection](final-card119-collection.json), [raw kernel log](final-card119-readback/recovery109/kernel-after-tests119.log).

## Evidence basis and limits

- Native CMake/Quartus 26.1.1 Build130 used part `AGFB027R25A2E2V` and matching migrated release `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01`. Actual platform selection was `ofs_agilex.ini`; the legacy name was not fabricated. [Release acceptance](../fim24-pr-platform01/EXPORT-ACCEPTANCE39.md).
- The aggregate verifies each native terminal receipt, input preservation, GBS identity, runtime result, independent disposition and published milestone. All eight milestones are ancestors of the closing basis; their exact committed path sets and included blob hashes were rechecked. Original tutorial manifest verifies all 85 files unchanged. [Aggregate121](FINAL-AGGREGATE121.json), [original source inventory](tutorial-source-manifest03.json).
- The original Avalon false/null host receipt remains false/null; a separate host-only run supplied native0. The initial clock PR5 permission failure and copy/DMA historical failures/holds remain unedited. Frozen pending/hold flags are historical, superseded by formal dispositions rather than rewritten.
- Hello-world verifies an MMIO-triggered DMA greeting, not a literal register write/read roundtrip. Clocks verifies counter ratios and the packaged user-clock target, not independently measured absolute 470 MHz. Local-memory covers nine nonzero-mask and two zero-mask cases per bank, not full capacity, isolation or sustained traffic. No unrun all-bank DMA, performance, DRC/CDC/reset or future-health qualification is claimed.
- Programming images, databases, licensed binaries, oversized logs and embedded transport payloads remain local/remote-only and SHA-referenced. This is an evidence release, not an end-to-end clean-checkout build package. [Publication policy](README.md#evidencepublication-policy).

## End state

No native build, card operation or independent review remains active. Further data-path diagnosis, corrective RTL/host work, performance testing or stronger drain/reset qualification would be a new follow-on task, not silently appended to this closed campaign. Joe's user-authored goal-file changes remain untouched and unstaged; closure publication does not absorb unrelated worktree edits.
