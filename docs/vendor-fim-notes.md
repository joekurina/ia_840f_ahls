# Vendor reference — BittWare IA-840F OFS FIM port notes

**Source document:** `IA-840F FIM Notes.docx` (621,993 bytes,
SHA256 `1a6560c2c8a46e97ad8430fc299f7804d7576b6f8c43108583dd586fa90cbbf7`).
The .docx stays **untracked** (vendor-authored external document, local-only
per repository policy); this page is the tracked reference summary. Local
copies: repository root and `~/Downloads/` (byte-identical). Received from
BittWare, 2026-09-30. Authorship is BittWare's; statements below are their
claims unless marked otherwise. This document describes **their port**, not
the delivered platform in this repository.

## Their port, as described ("OFS 2.2.0 BETA", IA-840F rev0/rev1 beta boards)

### Minimized floorplan

- Removed: HPS subsystem, Copy Engine, 8×25G HSSI, host exercisers (where
  possible). Minimized floorplan packed into the bottom-left of the die.
- HPS memory bank remains enabled top-right but unused (no fabric cost).
- Claimed utilization: **~14% of total AGF027 resources** for the locked-down
  floorplan. Independent corroboration: our CAPS03 fit is 13.96% ALMs
  (127,422/912,800) — same class.
- "Current FIM design has 2 DDR banks supported" per the floorplanning note;
  the accompanying task framing elsewhere in the document describes a
  single-bank USM-focused BSP goal with remaining banks not included. The
  document does not reconcile the two statements; which reflects current
  reality is a question for BittWare, not something to assume.

### BittWare BMC on PF3 — their stated architecture

Their stated biggest deviation from the Intel N6000 reference OFS file set:
Intel BMC/PMCI elements are **removed** and the BittWare BMC IP is included
as a subsystem on a **separate PF3 PCIe endpoint**, bound to the existing
BittWare SDK driver. Their stated rationale: no need to merge the BittWare
BMC into the OFS BMC stack at either FPGA or OPAE level; leverage existing
SDK development/testing; demonstrable as an SDK/CSP integration pattern.

Bridge implementation they describe:

- OFS PCIe SS is AXI-Stream; BittWare BMC IP is Avalon-MM. They created a
  **BWST2MM derivative** of the OFS ST2MM block (AXI-S → AXI-MM). Stock ST2MM
  was not reusable because its PMCI-facing features do not exist on the PF3
  path. A `bwbmc_wrapper` layer incorporates control ports that were
  statically driven/inverted in cardtest outside the BMC subsystem.
- Only the main `bmc_spi_sub.qsys` plus a System ID at 0x0 were brought
  across for SDK compatibility; the I2C shared master was **not** included.
- `bw_840_support.qsys` provides an AXI4-Lite → Avalon bridge, exposing an
  AXI4-Lite slave to the OFS upper layers (the original BMC IP was purely
  Avalon).
- Hardware status they report: SDK sensor reads work
  (`bw_card_monitor -I PCI`); **flash reprogramming through the PF3 path has
  not been tried** on their side.

### Build tailoring

`VERILOG_MACRO` settings in `ofs_top.qsf` tailor builds: `INCLUDE_DDR4`,
`INCLUDE_MEM_TG`, `INCLUDE_PMCI` (**commented out** — "not supported;
access via separate BittWare BMC subsystem IP"), `INCLUDE_PR`,
`INCLUDE_HSSI`, `INCLUDE_MSIX`, `INCLUDE_REMOTE_STP`, `INCLUDE_HPS`, etc.
They call the approach "not perfect by any means but it does help".

PR static region contents they list: DFH/CSR, user clock, PR control, freeze
logic, remote STP, reset IP; PF0/VF0 and PF0/VF2 mux to the PR region with
Traffic Gen and HE-MEM. PCIe: Gen4 ×16.

## Relation to this repository's delivered platform

- **PF topology differs by design.** Their port: BMC on **PF3** with the
  BittWare SDK driver. Our delivered platform: **PF1 BMC** (vendor board
  facts), PF0/VF0 AFU via OPAE/DFL with the accepted VFIO split. Both are
  legitimate integrations; ours is what CAPS03 v1.1.0 qualified. This
  document is authoritative for *their* choice only.
- **Flash rule unaffected.** Their untested flash path is a data point, but
  the standing rule already routes all flash writes exclusively through the
  BittWare SDK writer `bw_agilex_flash_programmer`.
- **Corroborates our resource class.** Their ~14% vs our independently fitted
  13.96% ALMs confirms our minimized shell matches the vendor's own.
- **Migration relevance (ofs-2026.1-1 / Quartus 26.1.1 campaign).** Their
  "PMCI removed" note aligns with the modern OFS PMCI IP regeneration seen
  in the upstream 2026.1-1 diff — on the IA-840F those blocks target no
  board feature. Their macro-tailoring approach is one proven vendor method
  for keeping unsupported subsystems out of a build. Their ST2MM derivative
  rationale documents the AXI-S/Avalon seam at the BMC path. None of this
  changes our PF1 architecture; it is vendor reference for the equivalent
  seam decisions.
- **DDR bank count is an open question**, not a specification: the document
  is internally inconsistent (2 banks in floorplanning vs single-bank BSP
  framing). Our platform's both-banks configuration is qualified by our own
  evidence
  ([DDR gate](../../docs/ddr-hardware-validation-gate.md)) and does not
  depend on this document.

## Status

Reference material only. It does not modify the delivered platform, the
migration pins, or any acceptance. The .docx is not a build input anywhere
in this repository. If BittWare issues an updated revision, add the new file
with its own hash and note the delta here rather than overwriting this
summary.
