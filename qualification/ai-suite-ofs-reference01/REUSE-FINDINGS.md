# FPGA AI Suite OFS example: useful AFU donor, not an established EMIF fix

## Answer

**Yes: this is a concrete source donor for the missing memory-capable AHLS AFU, not merely an AI tutorial.** The public `altera-fpga/agilex-ed-ai-suite` repository provides the PIM top, host/DDR DMA, per-bank interconnect, CSR plumbing, and interrupt transport. I inspected the immutable `rel-2026.1.1` pin `e0e07f7b1878a477dc4d1191918db8430193e148`; the source tree is public rather than dependent on obtaining the whole AI Suite installer.[10][12][13]

Research only: no build, vendor install, workstation command, hardware operation, or change to existing FIM/AFU inputs. Current Work18 timing failure is not cleared by these findings. Companion FIM/timing research is complete and parent-consumed (`parent-research-consumption01.json`); this report combines the parent's directly checked source findings with its verified version/known-issue conclusions.

## Version and board limits

The 2026.1 documentation explicitly bases this OFS example on **OFS2025.1-1**. The pinned I-Series README specifies **AI Suite2026.1.1, Quartus25.1, OFS2025.1-1 slim FIM, and OPAE2.13.0-2**. It is not a demonstrated Quartus26.1.1 FIM baseline merely because the AI release says2026.1.1.[1][11]

There is a documented matrix conflict: Handbook Table13 says Quartus24.3 for I-Series OFS, whereas the pinned README and OFS release say25.1. The AI README also names OPAE2.13.0-2 while the FIM release lists2.14.0-3. These are discrepancies to retain, not a reason to silently change our selected stack.[20][11][21]

AI release notes warn about sporadic embedded-memory corruption during partial configuration, potentially causing numerical errors or hangs. That is a separate PR qualification risk, not a remedy for static EMIF hold; no documented recovery operation was executed.[22]

Its I-Series target is an R-Tile/F-Tile development kit, not our P-Tile IA-840F. The guide's I-Series memory arrangement is four8GB banks, while N6001 has four4GB banks; our two16GiB instances must remain intact.[1][11] The sources' platform abstraction is useful; their SOF/GBS, board settings, memory geometry, and documented host-setup commands are not drop-in replacements for our board.

## What is concretely reusable

Paths below are under `agilex7/iseries_ofs_pcie/` at the pinned revision.

| Candidate | Source-level evidence | Use for this project |
|---|---|---|
| `ofs_plat_afu.sv` | PIM `ofs_plat_host_chan_as_axi_mem_with_mmio`, ordered/buffered read responses,64-bit MMIO, host channel0; clock crossing plus3 timing-register stages. Lines239–275. | Keep the native OFS/PIM boundary; use its host-memory and CSR integration as the donor for an AHLS payload, not an OpenVINO dependency.[12] |
| Same top, per-bank shims | One `ofs_plat_local_mem_as_axi_mem` per PIM bank, each with clock crossing and3 timing stages. Wrapper/host side runs on bank0's core clock; each physical bank retains its own clock behind the shim. Lines29–56,306–331. | Concrete way to preserve two independent DDR clock domains while sharing arbitration/control logic. Do not treat the stale nearby comment saying native pClk as overriding the actual bank0 clock connection.[12] |
| `dla_afu_hw.tcl` | Per-bank connections arbitrate DLA memory, DMA memory, and an address-span-extender/MMIO path to each DDR output. Lines821–846. | Replace the DLA-facing client with an adapter for actual AHLS-generated memory ports; retain supported DMA/bank interconnect rather than inventing a new protocol.[13] |
| `ip/dma/` | Address widths derive from PIM host and memory configuration; descriptors select the bank using address bits above the per-bank offset. | A parameterized host↔DDR DMA donor. It is not automatically ABI-compatible with our earlier tutorial audit.[14][15] |
| `dla_host_mem_if_mux.sv` | Multiplexes DMA writes and interrupts onto the PIM host AXI interface using `HC_AXI_UFLAG_INTERRUPT`; rising-edge pending state and burst tracking are explicit. | An actual interrupt-transport reference rather than guessing MSI-X transactions. Its exact semantics still require review with our chosen PIM version and AHLS completion contract.[16] |
| `setup_project.sh` | Uses the existing FIM `pr_build_template`, `afu_synth_setup`, and `ip-deploy`; checks the board directory. | PR/persona packaging reference, not a replacement full-FIM build. Adapt to our qualified IA-840F release instead of running the I-Series script unchanged.[18] |

The AI runtime documentation also centralizes board access in `runtime/coredla_device/inc/mmd_wrapper.h` and `runtime/coredla_device/mmd/`, covering device open, interrupts, CSR, and bulk DDR transfer. It explicitly says historical `aocl_mmd_*` names do not require an OpenCL BSP. Thus the layered design is relevant without replacing AHLS/OPAE with OpenVINO.[1] However, the inspected public repository tree has no runtime/MMD subtree: those implementation sources remain an acquisition item, not code inspected here. We cannot claim its software fixes the previously observed DMA address masking.

## Comparison with our existing AHLS code

[AHLS-DONOR-MAP.md](AHLS-DONOR-MAP.md) binds the current local sources and identifies the actual missing capability: automatic host↔DDR DMA and per-bank DMA/AHLS arbitration. Existing PIM/Avalon/64-bit CSR infrastructure is retained, not rewritten by this research. Both compositions claim host channel0, so they cannot simply be instantiated together; the donor DMA control byte0x40 also conflicts with the current scalar AHLS status offset. The current scalar checksum has no external DDR ports. A memory-capable AHLS payload and an explicitly separated CSR map remain necessary.

## IA-840F adaptations that cannot be skipped

1. **Memory geometry:** `parameters.tcl` specifies4banks,33-bit per-bank addresses and512-bit data. Two16GiB banks need34-bit byte offsets per bank and35bits for a contiguous combined address. This is calculated geometry, not proof that editing two parameters is sufficient.[17]
2. **Hardcoded stride:** `dla_afu_hw.tcl:828` spaces the MMIO/address-span-extender bank windows by `0x200000000` (8GiB), independent of the width parameter. A contiguous16GiB-per-bank adaptation needs a matching16GiB stride (`0x400000000`) and consistent software/window decode; otherwise changing only the width leaves an inconsistent memory map.[13]
3. **Bank encoding:** this donor selects bits immediately above `DDR_BANK_ADDR_WIDTH`; our two-bank geometry would select bit34. Do not mix that with the previously audited tutorial's high-bit bank encoding. Source/destination width, IOVA handling and host code must share one explicit ABI.[14][15]
4. **Transfer granularity:** the donor descriptor length is20bits. Large DDR sweeps need validated chunking and alignment; the all-bank simultaneous hardware gate is not satisfied by a selector visiting one bank per descriptor.[14][15]
5. **AHLS-specific boundary:** retain our64-bit CSR access contract and bind the actual generated AHLS memory/reset/clock interfaces. The guide's DLA MMD CSR functions are32-bit, so copying those accesses blindly would be wrong for our existing host contract.[1]
6. **No inherited qualification:** no source read proves end-to-end DMA, simultaneous bank traffic, reset/PR safety, or timing on our board. Maintain the existing numerical copyback and sustained two-channel hardware acceptance gate.

The root license permits modification subject to its terms, including Altera-product scope and preservation of notices, and explicitly lets file-specific terms override it. Preserve/review the per-file notices before transplanting code; public availability alone is not an unconditional relicensing grant.[19]

## Recommendation

Use the example's **PIM + DMA + per-bank arbitration/CDC structure as the source donor for our AHLS memory-capable AFU**, replacing the DLA-specific payload boundary rather than adopting the AI runtime/compiler stack. That is a useful new route for DDR/transfers and the AHLS integration gap.

**It does not yet justify Work19 as an EMIF hold repair.** The documented flow consumes a pre-existing FIM and builds its green persona; the observed Work18 miss is inside the FIM's vendor EMIF boundary. No correction to that boundary is established by the inspected AFU sources.[1][11][18] Keep the timing problem separate instead of claiming that AFU-side CDC/pipeline stages repair the internal Hyper-Register→UFI→PHY path.

Evidence: `captures/source-manifest03.json` binds25selected source files to Git blob identities and SHA256; the complete nontruncated Git tree and tag/release metadata are retained locally. `address-geometry-observations01.json` records the calculations. Raw captures are ignored; no donor source was integrated or executed.

## Sources

[1] https://altera-fpga.github.io/rel-26.1/ed-ai-suite/agilex7/ofs/ofs_pcie_getting_started — FPGA AI Suite26.1 OFS System Example Design
[10] https://github.com/altera-fpga/agilex-ed-ai-suite/tree/e0e07f7b1878a477dc4d1191918db8430193e148 — AI Suite example source pinned rel-2026.1.1
[11] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/README.md — AI26.1.1 agilex7/iseries_ofs_pcie/README.md
[12] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/ofs_plat_afu.sv — AI26.1.1 agilex7/iseries_ofs_pcie/ofs_plat_afu.sv
[13] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/dla_afu_hw.tcl — AI26.1.1 agilex7/iseries_ofs_pcie/dla_afu_hw.tcl
[14] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/ip/dma/dma_pkg.sv — AI26.1.1 agilex7/iseries_ofs_pcie/ip/dma/dma_pkg.sv
[15] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/ip/dma/dma_ddr_selector.sv — AI26.1.1 agilex7/iseries_ofs_pcie/ip/dma/dma_ddr_selector.sv
[16] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/dla_host_mem_if_mux.sv — AI26.1.1 agilex7/iseries_ofs_pcie/dla_host_mem_if_mux.sv
[17] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/parameters.tcl — AI26.1.1 agilex7/iseries_ofs_pcie/parameters.tcl
[18] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/agilex7/iseries_ofs_pcie/setup_project.sh — AI26.1.1 agilex7/iseries_ofs_pcie/setup_project.sh
[19] https://github.com/altera-fpga/agilex-ed-ai-suite/blob/e0e07f7b1878a477dc4d1191918db8430193e148/LICENSE.md — AI26.1.1 LICENSE.md
[20] https://docs.altera.com/r/docs/863373/2026.1.1/fpga-ai-suite-handbook/installing-quartus-prime-pro-edition-software — AI Suite Handbook Table13
[21] https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2025.1-1 — OFS2025.1-1 release
[22] https://docs.altera.com/r/docs/772497/2026.1.1/fpga-ai-suite-version-2026.1.1-release-notes/fpga-ai-suite-version-2026.1.1-release-notes — AI Suite2026.1.1 release notes
