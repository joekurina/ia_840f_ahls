# General-purpose IA-840F feature matrix

## Active AHLS / OFS / OPAE source project

**Source-only; not build-ready.** The explicit AHLS target correction governs the active implementation; the earlier standard/USM ASP work below remains reference-only. Requested Quartus Pro **26.1.1** is unchanged. Pinned donors are not a vendor-qualified combined release. See [scope](ahls-scope.md), [source lock](../sources.lock.json) and [integration status](vendor-integration-status.md).

| Function | Prepared source / reuse | Applicability | Remaining boundary |
|---|---|---|---|
| Device and pins | Vendor AGFB027R25A2E2V board-local constraints retained | Shared FIM | Generated-interface, electrical and timing qualification |
| DDR4 | Vendor discrete DDR4 and RDIMM topology; board-local modern `mem_ss` and two model source presets | Shared FIM; PIM local memory | [Source mapping review complete](memory-port-source-map.md); physical grouping remains unresolved, so group-specific pin names are proposals. Derived model settings and generated interfaces remain open. [CSR review](memory-csr-source-review.md) establishes the existing outer router; enabled subsystem/MSA register and clock/reset semantics remain unproven. Internal controller-MMR routes are outside the outer aperture, not demonstrated direct host access |
| PCIe | P-Tile Gen4 x16; vendor identities, PF0VF0 AFU, PF1 BMC; installed-source-backed PF1 BAR2 type/width 28 added, BAR0 disabled and BAR4 width 14 retained | Shared FIM | Child-IP acceptance, generated capability/interface and toolchain qualification; unconditional gate retained |
| BMC | Actual vendor SPI/mailbox/arbitration implementation; modern OFS CDC/TX skid; explicit CSR clock/reset and unused IRQ-cause tie-off | Shared management | [Completed source review](bmc-flr-source-review.md) found no vendor/OFS-proven PF1 drain/cancellation fix; RTL unchanged. Shared-reset safety, legacy IP, unsupported SPI windows and MSI-X transport remain open |
| PIM / PR | Pinned OFS PIM and board source integration | AHLS AFU infrastructure | Fresh matching generated PIM/PR artifacts; no legacy QDB reuse |
| AHLS CSR / memory binding library | Five source modules reuse PIM services and supply DFH/CSR routing, tagged MMIO/Avalon and byte/line adaptation | Unbound reusable library, not an activated AFU | Actual generated component, register map, top-level activation and necessary adapters. Current library needs 64-bit CSR, native aligned memory and a local bank; these are not workload requirements |
| Host↔DDR transfers | Existing OFS DMA and reference-only ASP DMA remain reuse evidence | Not yet integrated into active AHLS AFU | Complete transfer/control/completion and safe quiescence integration; ordinary PIM memory ports alone are insufficient |
| Host memory | PIM host-memory services available in board-side library | AHLS explicit memory binding, not oneAPI USM runtime | Actual generated-IP binding, registration/IOVA lifetime and ordering/completion |
| Host software | OPAE/DFL is the selected access foundation | Active AHLS architecture | AFU-specific discovery, control, transfers and completion software remain unbound |
| Host streaming / pipes | No applicable end-to-end transport advertised; prior custom experiments preserved separately | Not enabled | Reference implementation and real endpoint/host integration required; no invented stream ABI |
| HSSI / two-link PCIe | Reference implementations inspected, not enabled for IA840F | Not adopted | Physical board/FIM mapping required; no devkit topology substitution |

Evidence: [preset derivation](vendor-derived-presets.md), [resolved subsystem BAR2 trace](pcie-bar2-source-trace.md), [BMC integration](vendor-derived-bmc.md), [AHLS source binding](vendor-derived-ahls-binding.md), and [FIM manifest](../ofs-agx7-pcie-attach/syn/board/ia840f/source_manifest.json). The memory and BMC source reviews are complete; their unresolved interface requirements remain open and are not qualification claims.

AHLS documentation names Quartus Pro 26.1 for Agilex 7; that does not qualify the exact 26.1.1 + pinned OFS + BittWare IP combination. Historical oneAPI version constraints below are not active AHLS acceptance criteria. No compiled, simulated, timing or hardware validation is claimed.

## Historical standard / USM ASP reference inventory

The following preserves the earlier ASP review, including its then-open gaps and toolchain discussion. It is **not current active-target status**; in particular the BAR2 source-schema gap has since been resolved as described above.

**Source-only candidate; not build-ready.** Standard: `ia840f:ofs_ia840f`. USM: `ia840f:ofs_ia840f_usm`. Exact repository/submodule commits are in [sources.lock.json](../sources.lock.json); current heads are not a qualified combined release.

| Function | Vendor baseline retained | Upstream modernization / adaptation | Variants | Unresolved gap |
|---|---|---|---|---|
| Device/pins | AGFB027R25A2E2V, BittWare assignments | Board-local QSF/Tcl/top overlay on modern OFS | Both | Electrical, generated-interface and timing review |
| DDR4 | Discrete + RDIMM, each 16 GiB, x64/no ECC | Modern ASP two-bank parameters and kernel-wrapper names | Both | Mixed-format FIM preset and generated group/port contract |
| PCIe | Gen4 x16, PF0 VF0 AFU, PF1 BMC, original IDs/apertures | Modern PCIe/PR infrastructure; BMC selected by PF identity | Both | PF1 disabled BAR0/BAR2 not supplied by inspected generic OFSS controls |
| BMC | Vendor SPI/mailbox/shared memory/arbitration | Modern OFS CDC/TX skid in board ST2MM; original FIFO depth | Both | Old IP migration, PF1 FLR/CDC policy; polling only |
| Host↔DDR DMA | Vendor bulk-transfer capability | Existing common ASP DMA/MMD retained; no bespoke engine | Both | FIM/PR integration and runtime qualification |
| Host/shared memory | Vendor USM address ranges/flags | Upstream VTP/host-memory path, `kernel_host0` naming | USM only | Runtime, environment, toolchain and ordering qualification |
| Local write ACK | Enabled vendor feature | Modern XML/RTL declarations retained | Both | Not proof of cross-interface memory visibility |
| MMD identity | Original standard/USM UUIDs, BOARD_TYPE=1 | Explicit IA840F selector; reject unknown selection instead of D5005 fallback | Both | Shared UUID collisions, temperature and discovery behavior |
| PIM/PR | Board shell/AFU separation | Pinned modern PIM/ASP integration sources | Both | Fresh matching PR template/interface identity; no old QDB reuse |
| oneAPI host pipes | No complete applicable board implementation established | None advertised; custom experiment archived/disconnected | Neither advertised | Inspected compiler metadata/RTL/MMD does not establish PCIe hostpipes; CSR runtime path separately unqualified |
| UDP/HSSI pipes | No qualified board mapping established | Actual N6001 implementation inspected, not blindly imported | Neither enabled | Physical mapping; these are not CPU host pipes |
| Two-link PCIe | Vendor single-link topology | I-Series two-link reference inspected, not adopted | Neither | Different physical board topology |

## Implementation provenance

- **FIM:** `OFS/ofs-agx7-pcie-attach@599ac052eafbc9cede22561c099233ae4a54cb7d`, common `34a8540697fdf3d66fbcaa263fa037bae17cc32f`. [Board manifest](../ofs-agx7-pcie-attach/syn/board/ia840f/source_manifest.json) binds source/origin hashes. The BMC correction uses common `src/common/st2mm/st2mm.sv`, `src/common/lib/axis/ofs_fim_axis_cdc.sv` and `ofs_fim_axis_pipeline.sv`, not a new transport. [FIM review](fim-modernization-review.md) records adaptations and reset limitations.
- **ASP:** `OFS/oneapi-asp@1af2ca74c452cb6ebbf54beb86e758e53489e826`, N6001 standard/USM layout plus common `kernel_wrapper.v`, `board_hw.tcl`, `ddr_channel_hw.tcl`, DMA RTL and `mmd_dma.cpp`. IA840F adaptations retain two-bank geometry, device/UUIDs, vendor flags, single link and disabled HSSI. Exact source paths/hashes and variant comparisons are in [ASP review](asp-modernization-review.md) and its linked evidence. F-Series/I-Series were comparison references, not substitutes for board hardware.
- **PIM:** `OFS/ofs-platform-afu-bbb@3c21189e728009d4c492fa2be54c0ab1008b06dc`, retained unmodified donor; generated board interface closure deferred.
- **Examples:** `OFS/examples-afu@4a1350e3c9e223d8bac3cb47f756a1d919ef8de1`, reference only, not replacement DMA. Its `ofs-2026.1-1` tag is a prerelease.

## Toolchain and release boundary

The selected FIM **2025.1-1 explicitly says oneAPI is not validated**. The documented historical combination is FIM/PIM **2024.2-1**, ASP **2024.2-2**, Quartus **24.1** with listed patches. Neither that set nor the newer donors automatically qualifies IA840F. Exact alternative hashes and official citations are in [upstream review](upstream-baseline-review.md).

Requested **Quartus 26.1.1 remains unchanged**. It is outside FPGA-capable oneAPI 2025.0's documented range **22.3–24.2**, while the newest FIM names **25.1**. Integrated FPGA compiler support was removed in oneAPI 2025.1; newer generic oneAPI is not an assumed fix. This establishes a support gap, not proven impossibility.

Only source preparation/review and static consistency are established. No configure/setup, generation, compilation, simulation, executable tests, workstation operations, installation, programming, commits or pushes. No functional, performance, utilization or timing-closure claim.
