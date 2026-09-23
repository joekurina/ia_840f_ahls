# General-purpose IA-840F feature matrix

## Current Work21 FIM milestone — Quartus 25.1

**Not hardware-qualified.** This section supersedes earlier FIM timing checkpoints below, without changing their historical results or reclassifying skipped tests. The active FIM toolchain is Quartus Prime Pro 25.1.0 Build 129 SC Pro, not the historical 26.1.1 target. [Work21 acceptance](../qualification/fim-build-21/RESULT-ACCEPTANCE.md).

| Function | Accepted evidence | Remaining boundary |
|---|---|---|
| Work21 fit / assembly | Completed native compile, rc 0; 0 errors / 1,183 warnings | No deployment or hardware-function acceptance |
| Exact EMIF1 hold transfer | All five corners pass; worst +0.082 ns versus Work18 −0.004 ns; signoff SDC unchanged | No retiming-causation claim; do not repeat the unchanged hold experiment |
| Reported constrained numerical STA | 778 nonnegative summary records, independently reviewed | Unconstrained Paths FAIL; 23/88 failed signoff rules; complete CDC/reset/exception coverage open |
| PR region / future memory persona | Final populated region and placement confirmed | 1,076 dangling inputs and explicit initial values remain unwaived; later DDR-persona compatibility not established |
| BMC electrical assignments | Three affected pins identified in the native fitter panel | Termination/slew adequacy and IRQ timing unresolved; no arbitrary settings or live probing |
| DDR / transfers / AHLS function / durable boot | No new live result from this build | Hardware gates remain open; DDR simulation SKIPPED BY USER |

Details and immutable evidence bindings: [final review](../qualification/fim-build-21/final-review01.md), [parent verification](../qualification/fim-build-21/parent-final-verification01.json). Older rows below are retained as prior-build evidence, not current Work21 failures.

## Prior execution checkpoint — source-resume-01

**Not hardware-qualified.** W13 FIM and the sanctioned persona have compiled
artifacts; neither is accepted as timing-clean. This section supersedes the
older Work04/source-only snapshots below without reclassifying skipped tests.
See [continuation evidence](../qualification/source-resume-01/REPORT.md).

[Independent spec PASS, quality APPROVED and parent acceptance](../qualification/offline-milestone-review-01/ACCEPTANCE.md)
close the bounded offline gates only. Pre-review reports remain byte-preserved;
current statuses below supersede their pending-review wording.

| Function | Current evidence | Remaining boundary |
|---|---|---|
| W13 FIM / persona | Existing artifacts preserved, source identity checked | W13 -0.004 ns hold; persona -0.336 ns setup, -0.004 ns hold, -0.029 ns pulse width; timing not accepted |
| Work14 UART-absent FIM | Native compile exit 0, successful assembly; result evidence independently reviewed and parent-consumed | Timing FAIL / NOT accepted: −0.004 ns EMIF1 hold, unconstrained PCIe divider and unresolved constraint/CDC findings. W13 persona interface does not match; no hardware deployment. [Disposition](../qualification/fim-build-14/RESULT-ACCEPTANCE.md) |
| Work15 clock-corrected FIM | Native compile/fit/assembly rc0; independently accepted result evidence; FME fd2baeed-3092-5735-90c9-52ef20542b75 | Timing FAIL: EMIF1 hold−0.004ns; 7 High rules/34violations/0waived. PR/CDC/electrical/ECC follow-ups open; matching persona and hardware qualification not established. [Acceptance](../qualification/fim-build-15/RESULT-ACCEPTANCE.md) |
| Work16 Fitter-only hold experiment | Full compile/fit/STA/assembly rc0; actual failed-timing result independently reviewed and parent-consumed; FME ef3f29b8-f48b-5056-9f96-4d4a3351eeae | Timing FAIL: EMIF1 hold −0.004 ns; complete STA summary unchanged from Work15. DRC 23/88 failed, 7 High/34 violations/0 waived. Setter issuance is not retention/edge-applicability proof; no matching persona or hardware qualification. [Acceptance](../qualification/fim-build-16/RESULT-ACCEPTANCE.md) |
| Work17 snapshot-enabled diagnostic FIM | Native compile/fit/STA/assembly rc0; independently accepted failed-timing result; retained planned/placed/routed/retimed/final snapshots; FME33f9e51f-aa64-5620-b9c0-714a0ddf485c | Timing FAIL: hold−0.004ns and full STA summary unchanged from Work16. DRC23/88failed,7High/34violations/0waived. Retention evidence is not snapshot-query or hardware acceptance. Original Work16 recorded5441bindings match, but full predecessor QDB preservation is not established. [Acceptance](../qualification/fim-build-17/RESULT-ACCEPTANCE.md) |
| Work17 routed/final exact-path diagnostic | Separate copied-project STA rc0 and confirmed termination; independently accepted native evidence; all original Work17/SOURCE/PIM preservation receipts true | Same−0.004ns Fastvid2100C detailed path already exists routed; final body identical. Header corner scopes differ. Not global retiming/uncertainty/timing or hardware acceptance. [Acceptance](../qualification/fim-build-17/snapshot-compare01/RESULT-ACCEPTANCE.md) |
| OFS2026.1 target | Explicitly selected examples prerelease and recommended companion pins reconciled; all already locked | No matching public2026 FIM tuple found in inspected refs; retain accurate2025.1 donor provenance. Combined IA840F/AHLS qualification remains open. [Disposition](../qualification/ofs-2026-target-01/DISPOSITION.md) |
| PCIe divider constraints | Minimal production correction passed the fresh Work15 native fit: original80 clock definitions unchanged plus C; zero unconstrained clocks; all8 formerly invalid FIFO net-delay summaries numerical (minimum15.369ns) | Narrow clock progress independently reviewed/parent-consumed, not complete exception/CDC coverage. EMIF1 hold−0.004ns, unconstrained JTAG/BMC IRQ ports and34 High violations remain. [Work15 acceptance](../qualification/fim-build-15/RESULT-ACCEPTANCE.md) |
| DFL UART | UART-absent scope resolved; vendor ID-zero correction independently accepted, exact one-token static checks pass | Placeholder and generated chain links retained; UART/HPS remain absent. No dummy-CSR simulation. New native build/timing/live behavior not qualified. [Acceptance](../qualification/dfl-uart-fix-02/ACCEPTANCE.md) |
| DFL permissions | Successor02 staged policy independently accepted; captured PF0 BDF and all PCI IDs; 21 inert fixtures pass | Candidate01 rejected; unrelated fallback preserved. Native required-node detection UNVERIFIED; native validation/activation NOT RUN. No VFIO grant. [Acceptance](../qualification/dfl-udev-fix-02/ACCEPTANCE.md) |
| AHLS PF/VF/BAR routing | PF0 VF0 BAR0 → PIM channel 0 → AHLS; OPAE VFIO standalone-AFU path source-established | Current image/VF binding/BDF/BAR allocation/clock/reset state not live-verified. PF0+0x80000 is protocol checker, not AFU. [Map](../qualification/ahls-host-offline-01/HOST-ACCESS-MAP.md) |
| Host test | Additive exact-checksum, aligned, clear-on-read-aware test independently accepted offline; fresh CTest 2/2; native OPAE compile/link pass | No native FPGA-access executable run. Q1/Q2 test-hardening follow-ups retained; hardware gates remain. [Acceptance](../qualification/ahls-host-offline-01/ACCEPTANCE.md) |
| OPAE library evidence | Core identity plus selected plugin/support code sections reconciled; ELF supplement independently reviewed | Full dependency/runtime footprint NOT closed; xfpga accesses devices before token filtering. [Supplement](../qualification/opae-backend-binding-01/ACCEPTANCE.md) |
| Both DDR channels | Existing vendor-derived implementation; simulation SKIPPED BY USER | Full [DDR hardware gate](ddr-hardware-validation-gate.md) NOT RUN/qualified |
| Host transfers / memory data path | Current AHLS qualification top ties memory masters idle | Reference transfer/memory integration and data-verification tests remain; CSR success cannot qualify DMA |
| Runtime PR | Historical failure remains unresolved | No PR retry, reset, or cause exclusion authorized by this continuation |
| Sustained operation / durable boot | Historical programming records preserved | Final exact-image flash/power-cycle and full matrix NOT qualified |
| Remote safety | No hardware operations during continuation | Specific finite-operation authorization and independently verified host recovery required |

## Historical Work04 AHLS / OFS / OPAE source snapshot

**Generated candidate; not build-ready.** Work04 IP/RTL and headers executed successfully (not FIM synthesis). [FIM integration 05](../qualification/fim-integration-05/report.md) corrects the proven DDR pin-target/CS_N/QoS source defects with bounded static checks. DDR simulation is **SKIPPED BY USER**, not passed and not a compile prerequisite. Compile/fit/timing and hardware qualification remain unperformed. The explicit AHLS target correction governs the active implementation; the earlier standard/USM ASP work below remains reference-only. Requested Quartus Pro **26.1.1** is unchanged. Pinned donors are not a vendor-qualified combined release. See [scope](ahls-scope.md), [source lock](../sources.lock.json) and [integration status](vendor-integration-status.md).

| Function | Prepared source / reuse | Applicability | Remaining boundary |
|---|---|---|---|
| Device and pins | Vendor AGFB027R25A2E2V board-local constraints retained | Shared FIM | Generated-interface, electrical and timing qualification |
| DDR4 | Vendor discrete DDR4 and RDIMM topology; board-local modern `mem_ss` and two model source presets | Shared FIM; PIM local memory | Work04 emits one two-element physical group: discrete[0], RDIMM[1], each configured 16 GiB x64/no ECC. Integration05 corrects 118 stale RDIMM target names and scalar CS_N while preserving all 241 coordinates; guarded AWQOS/ARQOS zero defaults added. Static target checks pass; Quartus elaboration/fit remains pending. CSR/PMON disabled in emitted wrapper; status/DFH fallback applies. Calibration association and PIM USER semantics remain unqualified; no remap. DDR simulation SKIPPED BY USER |
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

AHLS documentation names Quartus Pro 26.1 for Agilex 7; that does not qualify the exact 26.1.1 + pinned OFS + BittWare IP combination. Historical oneAPI version constraints below are not active AHLS acceptance criteria. No compiled FIM, DDR-simulation, timing or hardware validation is claimed.

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

Current execution evidence supersedes the original source-only status: Work04 setup/IP generation/header emission completed. Integration05 source repairs pass bounded static checks. No FIM synthesis/fit/timing or hardware acceptance is established. DDR simulation is SKIPPED BY USER; historical failed simulator experiments are preserved, not reclassified as passes. No commits or pushes.
