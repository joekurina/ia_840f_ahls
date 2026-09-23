# AI Suite donor versus existing AHLS integration

This is a source comparison, not an implemented adapter or a new build gate. Existing bytes are bound in `existing-integration-bindings01.json`; external source references use the pinned AI commit and citations in [REUSE-FINDINGS.md](REUSE-FINDINGS.md). No original source is replaced.

## Preserve what already exists

- `afu/ahls/rtl/ahls_ofs_board_services.sv:21–62` already provides PIM host/MMIO and per-bank Avalon services, with explicit clock crossings. It uses `uClk_usrDiv2` and PIM line-addressed memory. Its host timing-stage setting is1 and each memory-bank setting3. The donor uses AXI byte addresses and bank0's core clock with3 host stages. These are distinct compositions, not wires that may be spliced without conversion.
- `afu/ahls/integration-contract.json:20–38,122–164` already specifies64-bit CSR, DFH/UUID aperture separation, memory alignment/units, physical IOVA, and generated-port binding. It explicitly does not implement an automatic host↔DDR transfer engine. These source requirements remain useful; its old phase/permission flags are not current execution authority or a global statement about later host-test work.
- `qualification/ahls-compile-01/src/qual_vec_op.cpp:31–49` is the scalar-argument checksum kernel. Its local `results[8]` does not expose DDR memory ports. Attaching DMA does not turn this kernel into the memory-capable numerical AFU required for the hardware gate.

## Missing capability → actual donor component

| Missing capability | Pinned donor component | Required boundary work, not yet implemented |
|---|---|---|
| Host↔DDR transfers | `ip/dma/dma_top.sv`, read/write engines, CSR manager and descriptor FIFO | Keep64-bit host IOVA/DDR offset handling end-to-end; match exact descriptor/status ABI and enforce alignment, bounded completion and quiescence. Do not copy the old tutorial's address masks. |
| DMA and AHLS sharing each DDR bank | `dla_afu_hw.tcl:821–846` | Replace the DLA client boundary with actual generated AHLS memory ports using a supported AXI/Avalon conversion/interconnect. Keep separate PIM bank shims; never merge physical banks. |
| Bank clock crossings | `ofs_plat_afu.sv:306–331` | Preserve each bank's clock on the FIM side. If adopting the donor composition, use its common bank0-side domain consistently instead of mixing the older `uClk_usrDiv2` composition. |
| Host DMA plus interrupts | `dla_host_mem_if_mux.sv` | Review the exact PIM interrupt flag/response contract; generated AHLS IRQ is not automatically an OPAE interrupt. Polling and IRQ completion ownership must not compete. |
| PR/persona source registration | `setup_project.sh`, `filelist.txt`, `ofs_build_env` | Use our matching IA840F release/template and current PIM/PR-freeze requirements, not the foreign board's prebuiltGBS. |

## Integration traps established by source

1. **Do not instantiate two owners of host channel0.** Both our board-service module and the donor's primary mapper claim `plat_ifc.host_chan.ports[0]`. An alternate AXI/DMA-backed composition must sit alongside the existing library, not connect both primary mappers simultaneously.
2. **Do not overlay the CSR maps.** The donor DMA's `DMA_DESCRIPTOR_CONTROL` is64-bit-register index8, i.e.byte0x40. The existing scalar AHLS host contract uses0x40 as status (`src/host/ahls_qualification_core.h:6`). The AFU identity region, DMA aperture and AHLS aperture need explicit separation; no new numeric aperture is selected by this research.
3. **Two16GiB banks require more than changing bank count.** Per-bank byte offset width34, bank select above it, matching hardcoded address-span-extender stride, enabled-bank macros, generated interconnect and host decode all need one coherent configuration. Retain actual PIM data width rather than equating the physical x64 bus to the fabric width.
4. **The donor DMA has one selected bank per descriptor.** Independent AHLS clients/bank exercisers must provide the required simultaneous-bank load. Serial DMA copies alone cannot qualify simultaneous operation.
5. **The memory-capable AHLS component must be real.** Reuse the existing compiler/interface workflow to generate actual buffer endpoints; do not invent normalized port names or repurpose the scalar checksum as a DDR test. Existing library files and scalar baseline remain intact.

## Concrete disposition

The recommended reusable unit is an **alternate DMA-backed memory-AFU composition**, not a wholesale replacement FIM, AI runtime installation or migration to OpenCL/oneAPI. The donor supplies meaningful missing transport/interconnect source; our generated AHLS payload, CSR map and host lifecycle remain project-specific. This comparison establishes the source-level work boundary but does not claim implementation, elaboration, timing, DDR operation, or hardware safety.

The separate Work18 static EMIF hold failure is still−0.004ns. None of these AFU-side wiring changes is claimed to fix that vendor-internal path.
