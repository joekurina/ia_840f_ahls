# Work15 native-warning triage

**Recommendation: let the existing compile finish.** No captured warning proves a fatal integration failure requiring cancellation. Do not equate that recommendation with PR, timing, DDR, or hardware acceptance.
**Highest priorities:** PR boundary preservation and ignored region targets; active reset/CDC constraint coverage; missing I/O electrical assignments; MSI-X ECC error observability.

## Snapshot and source scope
- Warning snapshot: **2026-09-22T18:38:41.665550Z**, `manifest02.json`; every captured file was unchanged during its individual read.
- **Synthesis completed successfully:** `ofs_top.syn.summary:1-6`; native.log:8290 reports **0 errors, 81 warnings**.
- **Fitter completed successfully:** `ofs_top.fit.summary:1-9`; F:42538-42543 reports **0 errors, 208 warnings**, ending vendor time 11:37:05. The log prefix alone ends mid-message at L:9139 and lacks fitter completion.
- `status.json:2` still says running. Parent update at 18:40:22.341796Z says STA is active; this is not a completed timing result. No new capture was awaited or remote operation performed.
- `S:n` / `F:n` mean original lines in `ofs_top.syn.rpt` / `ofs_top.fit.rpt`, recoverable from the diagnostic JSON rows; `L:n` means native.log line. They are **not JSON-file line numbers**.
- Full native log prefix: 2,625,646 bytes; synthesis extraction: 1,220 selected rows from 54,681,439 bytes; fitter extraction: 360 selected rows from 19,808,778 bytes. Extractions are diagnostic matches plus five following lines, **not full report panels**.
- Verified archive and all four ordinary captured-file SHA256s against manifest02. Original report hashes are manifest/extractor assertions; full original report bytes are not local in this package.
- Source identities are bound to prepared `compile-authorization.draft.json` work_inventory/source_sha256 and source-after.json; these are input evidence, **not newly issued approval**. Detailed hashes, exact mappings, counts and native references are in findings.json.
- The maintained QSF does **not** hash-match Work15 input. Q below does match the prepared Work15 QSF; A and H are older saved files whose bytes also match the corresponding prepared Work15 inputs. No older fit/timing result is promoted by these source matches.

## Severity and disposition
| Ref | Severity | Classification | Finding / smallest next native corrective check |
|---|---|---|---|
| R1 | High for PR | Potential risk; persona tie-offs expected | Check the complete green_region unused-input list and preserved boundary connectivity before a DDR-capable persona. Preserve only genuinely unused required boundary inputs, in their proper domains. |
| R2 | High for PR | Potential risk / insufficient panel detail | Read Work15 Ignored Assignments and partition/region panels; identify which exact assignment failed before changing the PR target or regions. Check PR initial-state/reset handling. |
| R3 | High for CDC | Confirmed stale selectors; coverage risk unresolved | Query actual surviving reset/calibration/FIFO endpoints and their applied exceptions. Do not fix by broad false paths or clock groups. |
| R4 | Medium | Mixed expected and unresolved clock constraints | Verify surviving SYS_REFCLK/50 MHz clocks and generated PCIe clock; validate ignored generated P-Tile power-management exceptions only for surviving endpoints. |
| R5 | Medium, safety observability | Confirmed diagnostic omission | MSI-X FIFO ECC is enabled but its exported error has no consumer. Trace generated ECC status/correction before deciding on a minimal error-latch/CSR connection. |
| R6 | High before hardware | Missing electrical detail; other warnings source-justified | Retrieve I/O Assignment Warnings pin rows; compare only flagged pins against IA840F electrical requirements. BMC route/clock warnings are not evidence that BMC is disabled. |
| R7 | Low current impact | Confirmed source declaration defect | Fix unused 40-bit control-shadow output's implicit scalar binding, or explicitly leave the unused output open; do not change the internal PCIe shadow bus. |
| R8 | Medium | Mixed expected / targeted-check needed | Inspect active PF/VF completion and PIM TX sideband widths first; distinguish inactive requests and unused protocol fields from a real data/address truncation. |
| R9 | Low / informational risk | Expected examples; residual evidence limits | No broad cleanup. Check removed hierarchy/initial-state panels only where they overlap required PR or active CSR logic. |

### R1 — CSR-only persona explains tied DDR payloads, not a reusable PR boundary
- Critical **20727**, F:41727 / L:8361: green_region unused inputs. L:8362-8371 names `ext_mem_if[1].bid[0..8]` and `bresp[0]`; L:8372 is an ellipsis. This is **ten shown inputs, not a complete ten-input list**. The fitter extraction retains only the first five children.
- **13410**: 48 DDR field-vector warnings, S:131410-131457 / L:8217-8264, split across both channels, including 34-bit addresses and 512-bit write payloads. These are internal PR interface fields, not 48 package pins or 48 individual bits.
- A:132-155 explicitly ties **both local-memory and host-memory request paths idle**; A:160-183 instantiates the binding and A:206-220 instantiates the AHLS CSR kernel. SHA256 `3638a59ec7d811c16d9d1e738ca57b606ee3cb9b8cc5bdb15b75ce965c8f12fb` matches prepared Work15 `.../afu/hw/ofs_plat_afu.sv`.
- The wrapper name “afu_main_std_exerciser” alone is not justification: T/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv:334-336 **forwards** ext_mem_if; its preservation section :377-432 preserves clocks/HSSI, not all unused DDR response inputs. P/ifc_classes/local_mem/native_axi/prims/gasket_fim_emif_axi_mm/map_fim_emif_axi_mm_to_local_mem.sv:54-62 forwards BID/BRESP.
- Thus request-idle constants are expected **for this CSR-only persona**; they neither demonstrate two working 16 GiB x64 DDR channels nor justify discarding the interfaces needed by a future PR persona. PIM FIFO pointer warnings on banks[0/1] may follow the same pruning (R3). Do not “repair” this by merging banks or enabling fake DDR traffic.

### R2 — PR location warning must not be waved away
- **15705/15706**, F:42409-42410 / L:9043-9044: `afu_top|pg_afu.port_gasket|pr_slot|afu_main` has a location/region assignment but “does not exist in design.” **171167**, F:42538, confirms invalid fitter assignments; the requested panel is not captured.
- T/syn/board/ia840f/setup/pr_assignments.tcl:24-33 assigns green_region, reserve/core-only/PR flags and explicit PLACE_REGION/ROUTE_REGION to that exact path. Earlier 20727 proves the partition boundary was recognized then; these messages do **not** prove the whole PR partition vanished or that every region assignment was lost.
- Critical **19854**, S:131402 / L:8209: explicitly initialized green_region state. A:207-211 uses binding reset but ties kernel freeze low; the wrapper has initialized/preserved reset state (:99-100, :345-355). Full initialized-state inventory and PR reset/protection results are missing. No PR reload safety claim follows from successful fitting.

### R3 — distinguish stale reset selectors and pruned FIFOs from unconstrained live crossings
- **332174/332049**, F:42117-42176: **12 selector failures and 24 ignored min/max commands** in top_sdc_util.tcl. They cover PCIe 50 MHz/power-good/warm/input/PTP resets, PF/VF FLR, and memory reset/calibration/ack names (complete list in findings.json).
- T/syn/shared_config/top.sdc:109-136 retains these patterns. T/src/top/rst_ctrl.sv:103-124 now uses `rst_warm_in_resync` / `rst_cold_in_resync` with **NO_CUT=0**, not the named `synchronizer_nocut` path; :265-275 still instantiates active power-good. These are not all disabled features.
- T/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv:108-146 has real reset/calibration synchronizers with **NO_CUT=0**. Their actual parent is `local_mem_wrapper|mem_ss_top` (L:8651,8690-8697), not top-level `mem_ss_top`; top.sdc:53 also names the obsolete `mem_ss_inst` clock hierarchy (F:42114-42116).
- T/ofs-common/src/common/lib/sync/fim_resync.sv:51-62 selects a synchronizer with embedded false-path SDC for NO_CUT=0. Consequently “ignored supplemental selector” is proven; **“all reset paths unconstrained” is not**. Check the effective exceptions and recovery/removal paths before a source change.
- P/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc:34-39 emits **20 unmatched pointer queries** over ten FIFO instances (F:42067-42086): six DDR AR/AW/W FIFOs and four host request/ROB FIFOs. Those requests are idle in A:139-154. Global net-delay constraints at :23-30 are separate; absent optional per-instance pointers do not prove those constraints failed.
- In contrast, F:42089-42100 has **seven diagnostics** in fim_dcfifo.sdc on `afu_top|afu_intf_inst|protocol_checker_csr|fim_dcfifo_inst`; this is not the idle AHLS DDR path. Check its surviving rdptr/synchronizer endpoints against T/syn/shared_config/fim_dcfifo.sdc:42-50.
- **18059/22471**, S:130959-130960 / L:7766-7767: max-fanout ignored on a reset duplication node driving FME `fme_sclr[0]` ACLR. Quartus explains duplication is illegal for that sink; inspect actual reset fanout/recovery timing, not a stronger fanout directive.

### R4 — clock warnings do not invalidate or accept the Work15 clock correction
- F:42103 (**332049**) says SYS_REFCLK already has a clock, so top.sdc:27 was not applied. It does **not** say SYS_REFCLK has no clock; query the existing clock's period/source rather than blindly adding `-add`.
- F:41932-41935: legacy `sys_pll|iopll_0_clk_50m` unmatched for added uncertainty. top.sv still connects clk_50m; surviving-clock evidence is needed to distinguish unused-output pruning from a renamed clock.
- F:42040-42043: two **332054** user-clock overwrites accompany the FIM “Applying high frequency constraint” message (L:8667-8677); expected fitter preparation, not measured achieved frequency.
- F:42105-42113: obsolete generic/R-Tile groups; H:8-24 proves P-Tile, one Gen4 x16 physical link. F:41952-41981: 18 ignored secondary P-Tile link1/2/3 exceptions are consistent with that one-link configuration. F:41983-42006: **16 pcie_ss.sdc warnings** on primary `u_pm_dstate_sync|req_wr_clk` / `data_in_d1[*]` still need surviving-endpoint checks.
- No captured warning names Work15 top.sdc:35-38's exact PCIe generated-clock addition (SHA256 `b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc`). Absence of a warning is **not** whole-clock/CDC acceptance. Host Gen3 x16 operation remains an expectation, not measured here.

### R5 — ECC is enabled; this is not a disabled-ECC warning
- **18410** occurs eight times in synthesis (S:130969-130976) and again on the **same eight** `afu_top|st2mm|axis_tx_msix_bridge|msix_fifo|...|ram_block2a[0..7]` RAMs in fitting (F:41744-41751). Do not count sixteen independent defective RAMs.
- T/ofs-common/src/common/lib/bridges/axis_tx_msix_bridge.sv:149-155 connects eccstatus and sets `enable_ecc="TRUE"`; :64 forwards only status[0] to axis_tx_error. T/ofs-common/src/common/st2mm/st2mm.sv:211-225 leaves **axis_tx_error() open**.
- Confirmed error-observability omission at the active FIM MSI-X bridge; generated clearbox TDF is not local, so correction behavior or exact status encoding is not established. Smallest next check: generated FIFO ECC fanout/correction configuration, then decide whether a sticky error indication is needed. No DDR ECC claim is made.

### R6 — board interface warnings and deliberately absent PMCI
- **25315**, F:41782 / L:8416: some pins lack drive-strength/termination/slew assignments. The actual I/O Warning panel is absent; **do not declare defaults electrically safe** or infer which DDR/BMC/clock pins are affected. No captured evidence establishes a dangerous drive conflict either.
- **18553**, F:41783-41784: SYS_REFCLK's one local destination is `sys_pll|iopll_0|tennm_pll.REFCLK`, explicitly not a valid global destination. **21752**, F:41785-41786: BMC SCLK is on a non-dedicated pin. T/syn/board/ia840f/setup/top_loc.tcl:79-93 deliberately locates SYS_REFCLK and BMC SCLK (W52, 1.2V); bwbmc.sdc:3-14 supplies the 200 ns clock and I/O delays. Routing-warning disposition is expected; final timing/electrical adequacy remains open.
- **13410**, S:130942 / L:7749: BMC master-enable is GND. T/ipss/ia840f/bwbmc/bwbmc_wrapper.sv:48-71 explicitly requires low to advertise the implemented BMC SPI subsystem. T/src/board/ia840f/fim_afu_instances.sv:217-252 routes **PF1 physical function**, not a VF, to real bwbmc_wrapper. This is not a substituted PMCI tie-off.
- **81 SDC diagnostics** originate in pmci_top.sdc, including m10_gpio_m10_seu_error (F:42299-42302 / L:8933-8936). Q:95-107 disables PMCI/HSSI/HPS/UART; T/src/board/ia840f/top.sv:100-125 conditionally removes those PMCI pins and :665-696 uses a dummy CSR. T/syn/board/ia840f/syn_top/ofs_top_sources.tcl:66 still unconditionally loads PMCI SDC. These unmatched PMCI ports are expected disabled-feature residue, **not proof IA840F BMC telemetry/thermal/SEU protections are equivalent or validated**.

### R7/R8/R9 — width, undriven, pruning and syntax warnings
- **24541**, S:129554: top.sv:602 connects a scalar implicit `ss_app_st_ctrlshadow_tdata` to 40-bit output; declarations :178-179 instead name `p0_ss_app_st_ctrlshadow_*`. pcie_wrapper.sv:48-50 defines the wide **output**. Search of top.sv finds no other consumer of the unprefixed net: confirmed declaration typo/truncation of unused exported status, not proof the internal MSI-X shadow path is truncated.
- **13469** has 184 emitted rows: 107 in MSI-X table code, 20 fair-arbiter rows, plus PIM/protocol/CSR/kernel widths. **13438** six unreachable PF2-7 cases at msix_table.sv:3313-3318 are expected for H:131-158's PF0/PF1 plus one VF; over-width PBA shift :3157 is consistent with the small static table, but do not clear all 107 truncations by that explanation.
- **13469** in B/ahls_mmio_aperture.sv:36 (64→17) is guarded by :31-44's in-aperture request decode; A:74-75 chooses a 256-byte window. This is source-justified rebasing, not evidence of 16 GiB DDR address truncation.
- **22568**, S:129609, indexes scalar VF_ACTIVE at mmio_rsp_bridge.sv:298 in the completion identity path. **16803**, S:129665-129670, addresses PIM TX user.dm_mode/sop/eop fields; P/ifc_classes/host_chan/native_axis_pcie_tlp/prims/gasket_pcie_ss/ofs_plat_host_chan_GROUP_align_tx_tlps.sv:193-227. Both warrant checking elaborated active values/connections, not calling all parser warnings harmless. The FIM boundary is one segment (T/src/includes/ofs_pcie_ss_plat_cfg_pkg.sv:32-33); the HIP's two-segment setting H:34 is a different interface, not proof of a fatal segment mismatch.
- **13471** 27 rows assign interface input clock/reset members; **16788** 16 rows and **21610** 156 rows include unused B-channel TLAST, CPRI clocks, AXI user/QoS, but also FLR/CSR/TLP/kernel fields. Only specific source-proven tie-offs are cleared. E.g. PF1 TX-B valid=0 (fim_afu_instances.sv:241-242); P/local-memory gasket :44,52,74 deliberately omits QoS/WUSER. Active VF completion/FLR and PIM TLP fields remain targeted checks.
- **16752** two “potential always loop” warnings are CCI-P parameter-error branches containing `always $display` plus PARAMETER_ERROR instantiation (P/ifc_classes/host_chan/afu_ifcs/ccip/ofs_plat_shim_ccip_async.sv:224-235,347-358), not evidence of a fitted feedback loop. **21705** means $fatal is ignored for synthesis, not that assertions passed. **13461** declaration semantics alone are not a functional failure.
- **23762**, **14284/25637** sweep/removal reports and **19854** initial values cannot be fully classified without their named panels. **276020**, S:130720, explicitly adds pass-through logic to preserve timestamp RAM read-during-write semantics. **24420**, S:129763, marks the PCIe request-splitter pragma at :298: inspect the retained pragma only if an associated timing/resource behavior is wrong.
- No explicit latch, tri-state, multi-driver, unknown-assignment-name or signedness-specific diagnostic was found among the parsed warning/error rows. This is a bounded search result, **not** proof of their absence from all implementation/DRC results.

## Message counts and coverage (not sums of copies)
- Parsed **495 synthesis diagnostic rows** = 436 unindented + 59 nested; exact warning-text multiset matches the synthesis portion of native.log. Report warning-summary extraction exposes **80 group rows**, whose Count columns sum to **483 leaf occurrences**, plus **12 parent/container rows** = 495. The native summary says **81 warnings**; its one-slot difference from 80 visible groups cannot be resolved from this extraction and is retained as a counting-semantics limit, not silently changed.
- Fitter report has **208 diagnostic rows** = 207 unindented + one nested, matching its own terminal warning count. Prefix log has 207 fitter rows, missing only final **171167**. This is a complete diagnostic scan of the captured successful fitter report, not a complete copy of its panels.
- Across stages: **33 IDs / 34 stage-ID groups**. Do not add report copies to log copies, group samples to children, or repeated ECC messages across stages as new RAM instances. Repeated BMC 21752 remains two native emissions. All stage-ID occurrences and summary groups are enumerated in findings.json.
| ID | S emitted rows | F emitted rows | Meaning / disposition reference |
|---|---:|---:|---|
| 13024 | 2 | 0 | Constant-output parent; see R1/R6 |
| 13410 | 49 | 0 | 48 DDR fields + BMC-present pin; R1/R6 |
| 13438 | 6 | 0 | Unreachable MSI-X PF cases; R8 |
| 13461 | 3 | 0 | Parameter/localparam declarations; R9 |
| 13469 | 184 | 0 | Width truncation, mixed datapaths; R8 |
| 13471 | 27 | 0 | Interface clock/reset input assignments; R8 |
| 14284 | 9 | 0 | RAM-removal parent; R1/R9 |
| 15705 | 0 | 1 | Ignored placement/region parent; R2 |
| 15706 | 0 | 1 | PR hierarchy location target absent; R2 |
| 16752 | 2 | 0 | Unclocked parameter-error display loops; R9 |
| 16753 | 4 | 0 | Over-width shifts; MSI-X/MCTP/generated CSR; R8 |
| 16788 | 16 | 0 | Undriven nets, mixed active/disabled; R8 |
| 16803 | 6 | 0 | PIM TX user indexing; R8 |
| 18059 | 1 | 0 | Fanout-assignment parent; R3 |
| 18410 | 8 | 8 | ECC status unused, same eight RAMs; R5 |
| 18553 | 0 | 1 | SYS_REFCLK local PLL route; R6 |
| 19854 | 1 | 0 | Critical: PR initial values; R2 |
| 20727 | 0 | 1 | Critical: dangling PR inputs; R1 |
| 21610 | 156 | 0 | Undriven output fields, mixed active/disabled; R8 |
| 21705 | 2 | 0 | Synthesis ignores $fatal; R9 |
| 21752 | 0 | 2 | BMC SCLK non-dedicated clock pin; R6 |
| 22471 | 1 | 0 | FME asynchronous-clear fanout limit ignored; R3 |
| 22568 | 1 | 0 | Scalar VF_ACTIVE indexed for completion ID; R8 |
| 23762 | 1 | 0 | Swept hierarchies; R1/R9 |
| 24420 | 1 | 0 | Mixed valid/invalid PCIe splitter pragma; R9 |
| 24541 | 5 | 0 | Port-width mismatch including control-shadow typo; R7/R8 |
| 25315 | 0 | 1 | Incomplete pin electrical assignments; R6 |
| 25637 | 9 | 0 | RAM-removal children; R1/R9 |
| 171167 | 0 | 1 | Invalid fitter assignments; R2/R6 |
| 276020 | 1 | 0 | Read-during-write bypass added; R9 |
| 332049 | 0 | 129 | Ignored SDC commands; R3/R4/R6 |
| 332054 | 0 | 12 | Clock overrides/groups; R3/R4/R6 |
| 332174 | 0 | 51 | Unmatched SDC selectors; R3/R4/R6 |

## Exact source aliases and remaining action
- T = `ofs-agx7-pcie-attach`; P = `ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl`; B = `afu/ahls/rtl`; paths are relative to repository N.
- Q = `qualification/fim-build-14/completion12/project/ofs_top.qsf` (hash-equal Work15 prepared QSF).
- A = `qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ofs_plat_afu.sv` (hash-equal Work15 prepared persona).
- H = `qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh` (hash-equal Work15 prepared generated PCIe header).
- PIM GROUP template citations retain original line numbers; in-memory removal of literal `_@group@`/`_@GROUP@` reproduced the generated-file hashes in Work15 inventory. This was evidence reconstruction only, not a source edit or a test run.
- **Next iteration:** finish current compile; use its actual timing/DRC plus the missing Work15 partition, ignored-assignment and pin panels to choose one smallest justified correction. No seed sweep, speculative blanket exception, mock or new approval framework.
- Work14 hold −0.004 ns and 7 High / 34 violations / 0 waived remain historical unresolved findings. Clock-trial02's accepted narrow old-fit evidence is not Work15 timing or hardware acceptance. No image programming, device access, timing acceptance or working-DDR claim is authorized by this review.
