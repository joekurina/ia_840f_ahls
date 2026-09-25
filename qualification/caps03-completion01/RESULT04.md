# CAPS03 completion — functional result

The additive candidate replaces the custom cross-clock snapshot mailbox with
application-domain finite output accounting and write-response retirement. The
existing generated HLS, DMA, full-width fabric and vendor PIM remain unchanged.
This is **simulation acceptance evidence, not fitted or hardware acceptance**.
Independent design review is pending; no successor synthesis, flash, reset,
power cycle or reboot was launched.

## Architecture and source counterparts

- Finite producer completion plus balanced response counters follows
  [`local_mem_engine_axi.sv`](../../ofs-platform-afu-bbb/plat_if_tests/local_mem_params/hw/rtl/axi/local_mem_engine_axi.sv), lines 600–606 and 625–692.
  This is the separately pinned PIM, not a claimed 2025.1 PIM release tag.
- DDR B-before-AR is implemented in tagged OFS
  [`mode_lpbk.sv`](../../ofs-agx7-pcie-attach/ofs-common/src/common/he_lb/mode_lpbk.sv), lines 289–298 and 370–418.
- Enabled-byte counting is the HLS partial-store adaptation. It prevents
  momentary AW=B before the final buffered output from qualifying completion.
  Raw completed-idle HLS status, sampled by the actual guard, is separately required.
- The additive bank shim observes `page_limited` after page splitting, before
  outer `ofs_plat_axi_mem_if_map_bursts` suppresses intermediate B responses.
  The inner map is passthrough for source burst width 5 / physical width 8;
  `user_ext` preserves B, and the existing complete PIM async shim supplies CDC.
  No payload synchronizer or new CDC protocol was added.
- Existing size/start programming arms the finite monitor. Read-only `0x20020`
  returns HLSCOMP1; `0x20028` reports supported bit16, errors15:8, done1, busy0.
  The candidate top keeps `COMPLETION_SUPPORTED=0`; only simulations enable it.
  These registers have **not** been accessed on the card.

## Actual changes

Additive files under `afu/ahls_memory/`: `control/ia840f_ahls_completion.sv`,
`control/ia840f_ahls_mmio_completion_guard.sv`,
`pim/ia840f_ahls_memory_bank_completion_shim.sv`, and
`pim/ofs_plat_afu_completion.sv`. The existing core_publication variant is reused
only for its bank1 DMA-attempt output. Original sources are preserved.

## Executed evidence

- [unit01.log](unit01.log): packaged Icarus native exits 0; **11 cases, 71 checks**.
  Covers delayed first/final traffic, partial writes, no-reset successors,
  response errors, excess bytes, uncredited B, contamination, busy start,
  same-edge fault priority, invalid extent and active reset cancellation.
- [sim02-result.json](sim02-result.json): Questa 2024.3 actual-HLS positive cohort,
  **6 cases / 133 integers / 1600 copied result-and-guard bytes / 24 DMA descriptors**.
  Actual AXI-Lite completion CSR controls copyback, not a testbench drain loop.
- [sim04-result.json](sim04-result.json), SHA256 `3b9d9cec65489a063ca896030376130e6cd4391bdd984a6b590ba89ca745cf9b`:
  all six native/effective stages 0, [outer exit 0](sim04-outer.json), no diagnostic
  errors, all original/input/tool preservation checks true, no remaining owned
  process groups. The same six positive cases pass, plus actual-HLS native B-error
  rejection and premature DMA GO rejection without any DDR read admission.
  Total 30 DMA descriptors includes six initialization descriptors for the two
  negative cases; those cases do not claim copied-back numerical acceptance.
- [split_fault.log](sim04-capture/split_fault.log): the real page mapper,
  metadata mapper and async PIM transport split one synthetic source burst into
  two native bursts. Native AW/W/B counts are **2/4/2**, upstream B count **1**,
  and the monitor sees **one errored intermediate B** despite its later suppression.
  This focused error test uses a synthetic AXI source, not HLS arithmetic.
- All **155** selected generated HLS entries are byte-identical to the
  accepted sim05 capsule. No HLS compilation or Platform Designer regeneration ran.
  The native commands and source/tool hashes are retained in each result JSON.

The sim04 numerical fixture reports 402461 checks, 1011 MMIO reads, 161 MMIO
writes, eight early-HLS-finish observations (six positive plus two fault cases),
and page-crossing input observations AW0=8/AW1=8/AR0=0/AR1=6. No AR0 page-crossing
coverage or native held-B event is claimed. Native warnings remain visible:
main simulation 261; focused page-error simulation 0.

## Preserved failures and limitations

- sim01: vlog exit2 from using guard wires before their declarations; assignments
  were moved below declarations. sim02 passed with that correction.
- sim03: native vsim exit0 but functional outer exit1. Its intended HLS B-error
  was detected, but the fixture incorrectly assumed the first HLS B was a
  suppressed page fragment. That required hit was absent. sim04 retains the HLS
  error test and adds the separate actual split-path error test above; it does
  not label the failed hit as covered.
- Negative fixtures drain synthetic endpoint bookkeeping before resetting their
  test systems. This is **not** an offered live recovery or software fence.
- Final 3.000 ns timing, reset/CDC and warning review, candidate-top native
  synthesis, physical DDR, PCIe/OPAE numerical execution, final boot/power-cycle,
  sustained use and lifecycle qualification remain unperformed for this candidate.

## Ownership and next action

No hardware owner or native build/simulation process remains from these runs.
Local-only independent design review `deleg_90848114` is outstanding; it has no
hardware access and may not edit sources. Next: consume that review, fix any
concrete blocker, then prepare the changed persona using the accepted Work21 shell.
