# Connected AHLS memory fabric candidate

This additive fabric uses the AI Suite's [pinned OFS example](https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/dla_afu_hw.tcl) bridge/arbitration composition around the actual corrected HLS2026.1.0 DDRIP. Original scalar-AFU and board-service sources are unchanged.

## Source layout

- `ia840f_ahls_memory_fabric_hw.tcl`: component composition callback, retaining donor interconnect settings. It instantiates the generated `mmhost_ia840f_report_di` from the supplied report-project catalog.
- `make-system02.tcl`: standalone native system script that instantiates/exports that component. `make-system01.tcl` preserves the failed initial system-scope API attempt; do not execute it as the current recipe.
- `provenance01.json`: exact original donor parameter tables, geometry evaluation, initial script identity and aperture choices. It describes the fabric01 boundary; successor callback/top-script identities are recorded in qualification dispatch/input receipts.
- `AI-SUITE-LICENSE.md`: donor notice and terms, retained.

## Interfaces

An external clock/reset domain services the fabric and kernel. The intended enclosing PIM composition uses the DDR bank0 core domain with independent bank CDC and one host-channel0 mapper, following the donor. This component does not implement the device Reset Release service or change board clocks.

The AXI MMIO input is20-bit byte-addressed/64-bit data. Byte0–0xffff routes to the exported DMA CSR endpoint; byte0x10000–0x100ff routes to the kernel CSR, with native AXI-to-Avalon byte/word conversion. These are AFU-relative source allocations, not live PF/VF/BAR addresses. Two34-bit/512-bit AXI DMA inputs arbitrate separately with the34-bit/256-bit AHLS hosts into two34-bit/512-bit AXI bank outputs. Host0 carries x/y; host1 carries z. Native adapters must retain upper address bits, strobes, burst semantics and accepted-beat accounting; generation alone does not prove those functions. No flat MMIO DDR window/stride is introduced.

The kernel exception bus has no meaningful reporting and is constant zero. Its IRQ and freeze are exported for the enclosing AFU contract. Completion and downstream visibility are not equivalent and remain integration obligations.

## Execution and limits

Use only the explicit Quartus25.1 environment and fresh source-bound work described in [qualification](../../../qualification/ahls-memory-fabric01/SCOPE.md). Keep the standard catalog via literal `,$` after the supplied report-project and component paths. Do not launch a default full FIM build from this directory. This is connected fabric, **not yet the complete DMA/PIM AFU**, a programming image or a numerical/hardware result. DDR simulation remains SKIPPED BY USER.
