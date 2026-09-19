# Work04 generation/header acceptance review

## Disposition

**IP generation and OFS header emission succeeded; functional BSP acceptance remains blocked by concrete integration issues below.** This is a local review of captured output and maintained source, not a new vendor run, compile, timing analysis, simulation, or hardware qualification. Continuing in-scope BSP work does not need another user approval. No source, pointer, pin, PLL, calibration remap, gate, or readiness change was made.

`G:<line>` means decoded `generate-full.log`; `H:<line>` means decoded `headers-full.log`. Artifact basenames below refer to the full keys in `headers-final-evidence.json`. Maintained source root is `new/ofs-agx7-pcie-attach`; PIM root is `new/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if`.

## Integrity and actual stage results

Recomputed SHA-256 over UTF-8 bytes of **all 17 content payloads** (6 generation, 11 headers): all match their recorded hashes. This authenticates the local capture against its self-hashes, not every remote file or every file named in the enumerated inventory. The latter contains 83 IP-file path/hash records, not 83 locally available payloads.

- Generation result: rc0; full log reports `0 errors, 1002 warnings`.
- Project-IP result: rc0; its full log has no warning/error diagnostic lines.
- Header result: rc0; outer shell reports `0 errors, 0 warnings`, **but its complete captured child output contains four PLL warnings**. Do not call the header operation warning-free.
- No `Error:`/`Error (number):` diagnostics in these three complete logs; no Critical Warning in generation/header logs. These are diagnostic counts, not inferred behavioral correctness.
- `--synthesis=verilog` here requests generated synthesis RTL; it does not mean the BSP was synthesized/fitted. The header log's `Compiling PR Base revision...` is project-loading messaging, not evidence of a compile result.

Container hashes:
- `generation-final-evidence.json`: `bfbfee1671e575018077ea91d333f6dce97960b4c6ae643e9b7abb4b3c8c2746`
- `headers-final-evidence.json`: `7cc209fe3f7c917cad2f2599124db60de3435e10c69d7aa3d534bb116d663899`

## What the new generated boundary actually establishes

### PCIe

`ofs_ip_cfg_pcie_ss.vh` explicitly selects P-Tile, Gen4, one x16 link, PU/native endpoint, side-band headers, **64-byte data and two segments**. PF0 and PF1 are active; PF0 has one VF (VF0); PF1 has no VF. PF0 and its VF BAR0 address widths are 20, PF1 BAR0 width is 12. `NUM_PFS=2`, total VFs=1, PF vector `1,1`, VF-count vector `1,0`. This matches the requested PF0/VF0 AFU + PF1 BMC topology; the header alone does not establish endpoint routing to the AFU/BMC. The log also reports PF1 vendor/device 0x12ba/0x70. Retain routing/interrupt validation rather than treating IDs as proof of functionality.

G:2407–2415,2842–2850 and H:181,185 explicitly identify **AGFB027R25A2E2V**, Agilex 7, speedgrade 2. The two obsolete Stratix-10 input-device warnings discussed below do not override that invocation identity, but still need leaf-output disposition.

### Memory

Actual emitted `mem_ss_param_pkg.sv` says `NUM_PORTS=2`. `mem_ss_sv.sv` declares **one two-element physical DDR4 interface array**, one two-element AXI array, two reference clocks/OCT inputs, per-channel user clocks/resets and status. It connects i0 to array[0], i1 to array[1], mem0 to physical[0], mem1 to physical[1]; there is no `mem_g1_ddr4` interface or group-1 macro. This is now observed output, not the earlier wrapper prediction.

Both channels have 512-bit data, 64-bit WSTRB, 34-bit byte addresses, nine-bit IDs, eight-bit LEN, four-bit AWQOS/ARQOS, **14-bit AWUSER/ARUSER**, one-bit BUSER, and **no WUSER/RUSER**. DDR4 members are x64 DQ, eight DQS pairs/DBI, 17 address, two BA/two BG, with scalar CS_N/CK/CK_N/CKE/ODT/PAR/ALERT_N. `mem_ss_ip_params.vh` disables CSR and PMON; no CSR wrapper port or CSR-presence macro exists. The DFH/status fallback is the relevant source branch, not restoration of a legacy memory CSR aperture.

Header composition log supplies additional current Work04 configuration evidence beyond port shape:
- EMIF0 is loaded at H:843 and set to DISCRETE at H:1086; EMIF1 is loaded at H:2274 and set to RDIMM at H:2516.
- DDR4 row17/column10/BA2/BG2, DQ64 and ranks-per-DIMM1 are explicitly set for each; DDR4 ECC is false at H:2073/3506. Both clocks are configured 1333.333 MHz (H:977/2407), not measured.
- Capacity arithmetic from these configured dimensions: `2^(17+10+2+2)*(64/8) = 17,179,869,184 bytes = 16 GiB` per bank. The 34-bit byte address space agrees. This is configured capacity, not RDIMM SPD validation or exercised hardware capacity.
- H:3798/3830 and 3805–3811/3837–3843 establish two distinct MSA-to-EMIF channels with their corresponding clocks/reset/status and 512-bit/34-bit final geometry. Earlier initialization values of row15/data256 in the same log are superseded; do not mistake intermediate composition defaults for final widths.
- H:3857–3875 uses `emif_cal_bot` with two interfaces, hence BOT/BOT. It **still connects calbus_0→EMIF0 and calbus_1→EMIF1**, matching the earlier discrepancy, not the donor's reversed calbus associations. BOT/BOT is not equivalent to donor calibration-order acceptance. The emitted wrapper does not establish physical P1 pin placement; retain the existing discrete/P1-channel0 and RDIMM-channel1 board contract without swapping channels.

## Exporter behavior: missing `emif.tcl` is not a demonstrated failure

The earlier interim capture records `syn/board/ia840f/setup/emif.tcl` missing. The final header receipt does not include that path, so it cannot prove its final presence or absence. More importantly, **the actual inspected exporter does not promise to produce it**:

- `gen_ofs_ip_cfg_db.tcl:45–51` opens the project and calls `::ofs_ip_cfg_db::generate`.
- `ofs_ip_cfg_db.tcl:28–95` emits the aggregate header, wrapper include Tcl, wrappers, and registered configuration headers. Its memory command is observed at H:4291: `mem_ss_get_cfg.tcl; emit_ip_cfg ofs_ip_cfg_db/ofs_ip_cfg_local_mem.vh LOCAL_MEM`.
- `mem_ss_get_cfg.tcl:54–56,155,251–260,274–324` emits the `.vh` and `_asp.qprs`; **it does not emit setup/emif.tcl**. Its only ordinary local-memory header content in this configuration is ENTITY plus guards/comments. Counts/selected widths go into the ASP preset; interface widths/groups come from wrapper generation, not this `.vh`.
- H:4292 names `ofs_ip_cfg_local_mem_asp.qprs`; H:4293–4294 explicitly creates group0 then reuses it for channel1. H:4296–4302 enters EMIF0 for ASP bandwidth extraction. This is positive evidence that channel parsing/grouping executed, not evidence of a comma-list parsing failure. Actual raw API strings were not captured; no delimiter correction is justified.
- `syn/board/ia840f/syn_top/ofs_top_sources.tcl:90` sources **`../setup/emif_loc.tcl`**, not `emif.tcl`.

Exporter local hashes match the AST-extracted Work04 deployer's expected source entries: `mem_ss_get_cfg.tcl` = `918fb1d93dc73828de06d5d331fe65debdf586b8c9973fa00a7290837c2eabb1`; `ofs_ip_cfg_db.tcl` = `fb6a74d6359d549c9481d3c064a996903ad2ee861c58a83649da10fb59e1fb1a`. This is source-binding corroboration, not a separate readback of remote source bytes. Capture the real `_asp.qprs` if accepting ASP metadata; do not fabricate `emif.tcl` or add it as an arbitrary compile prerequisite. Its bandwidth calculation uses EMIF0 frequency times combined DQ width, which is consistent only while both configured memory frequencies agree.

## Whole-log warning classification

Computed from all 6,016 G lines, matching `Warning:` or `Warning (number):` and removing the logging prefix, **not** from tails or summaries. Totals below are disjoint and sum to 1,002. “Bodies” are exact distinct diagnostic strings, **not independent root causes**. Exact-body dedupe gives 490; normalizing the embedded nested timestamps gives 474. Multiplicity is 444 bodies twice, 34 three times, 12 once; synthesis/simulation and repeated parent/leaf validation account for repeated emissions. Do not report 1,002 independent defects, nor automatically waive all duplicates.

| Diagnostic class | Emissions | Exact bodies | Meaning / disposition |
|---|---:|---:|---|
| missing interface metadata | 288 | 128 | Saved footprint/catalog metadata drift (optional reset, translator, AXI features, Avalon waitrequest/BE); inspect active boundaries, not 288 hardware faults. |
| value mismatch | 540 | 270 | 528 APF/BPF outstanding/acceptance/issuing 16-vs-1 emissions; 12 JOP DFH metadata emissions. Functional protocol/feature-description review needed, not cosmetic blanket waiver. |
| missing module metadata | 6 | 3 | JOP embedded-software CMacro omissions; debug/DFH metadata issue. |
| project sysinfo mismatch | 76 | 38 | 38 named remote-debug/APF/BPF/EMIF-CSR instances repeated twice. Reconcile saved sysinfo to target, not indiscriminate IP upgrade. |
| parameterization summary | 2 | 1 | JOP summary of underlying warnings, not a new cause. |
| unconnected conduit | 6 | 3 | Three BMC input conduits, twice each. Inspect actual input ties/exports and active interrupt paths before PF1 BMC acceptance. |
| empty sim model | 4 | 2 | ed_sim_mem and ed_sim_mem_group1 twice each. Generated model usability unproven; not a physical-bank deletion instruction. |
| nested project omitted | 24 | 17 | Nested memory generation lacks --quartus-project/--rev; children explicitly receive part and search path. Inspect generated target/dependencies; outer context is not absent. |
| version substitution | 40 | 20 | 20 leaf variants, simulation/synthesis. Catalog version migration is visible; successful generation does not validate changed behavior. |
| PLL advanced reconfiguration | 2 | 1 | One recommendation, repeated; no evidence of an actual illegal reconfiguration. Preserve PLL settings. |
| PLL frequency mismatch | 8 | 4 | Outputs 1,3,4,6 twice. Real clock-contract/timing follow-up; also four occurrences in H. Do not alter PLL to silence. |
| JTAG TCK-ENA | 2 | 1 | Supported-debug-IP limitation; conditional debug qualification, not memory generation failure. |
| invalid legacy device | 4 | 2 | tx_sc_fifo and rom_1port_0 still name 1SX280HN2F43E2VG. Inspect effective generated leaf target before synthesis acceptance. |

Specific BMC conduits are `bmc_to_pcie_irq_gen.Ext_irq_interface`, `pci_to_bmc_irq_gen.Ext_irq_interface`, and `system_arbiter.hps_gp_if`. A disconnected unused HPS conduit may be intentional, but the log alone does not establish safe tie-offs. Do not equate these with the previously repaired mailbox interface problem or assume mailbox generation resolves them.

## Precise next acceptance work, in priority order

1. **Correct the now-proven physical port naming mismatch, preserving every coordinate.** Maintained `emif_loc.tcl` hash `44fdb76902f22b83df265da656f531fca9d5abe61a74c696190b5465c0da579d` still has 118 `ddr4_mem_group_1[0]` targets and HB29 at `ddr4_mem[0].cs_n[0]`. Actual headers select only `ddr4_mem[1:0]` and scalar CS_N; board `top.sv:48–52` conditionally removes group1. The earlier proposed **name-only** correction is now output-supported: those 118 prefixes become `ddr4_mem[1]`, HB29 becomes `ddr4_mem[0].cs_n`. This is not a bank/pin/calibration remap. Preserve all package coordinates, RDIMM refclk/OCT and simulation model count. Next result required: exact maintained-source diff, coordinate-preservation comparison, updated source binding, then real elaborated port/assignment checks with no unmatched DDR targets. No edit made here.

2. **Apply and exercise the narrow QoS default fix; its previous missing-header prerequisite is closed.** Actual `IFC_MEM_SS_I_AXI_MM_IF_WIDTH_AWQOS` and `...ARQOS` macros both equal 4; actual wrapper fields are input-driven toward the subsystem. Current `mem_ss_top.sv` hash remains `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c`, and its lines 298–341 omit both assignments. Add `assign ss_axi_mm[c].awqos = '0;` after AWPROT and the matching AR assignment after ARPROT, guarded by the corresponding emitted macros. Do not merely forward upstream undriven QoS. Required new result: source diff/hash and bound rebuild plus elaboration/lint showing one defined driver per QoS field on each channel; stimulus should show zero QoS on accepted requests. That establishes a defined default, not arbitration-performance acceptance.

3. **Close PIM width/USER semantics using the real active Work04 route, not a blanket widening patch.** Actual emitted no-WUSER/no-RUSER now selects fallback width1 in `includes/ofs_fim_mem_if_pkg.sv:51–55,74–77`; AW/AR select14, B selects1; NUM_MEM_CHANNELS and group0 count select2. Earlier captured generated PIM uses `AXI_MEM_WUSER_WIDTH` plus a one-bit PIM flag, hence source-derived expectation2, **not an observed compiled PIM ABI**. Carry forward `pim-user-source-review.md`'s important refinement: native-AXI adapter has FORCE_USER_TO_ZERO and metadata/ID FIFOs, restoring response USER; width mismatch alone does not prove lost NO_REPLY. Capture both Work04 `afu_with_pim/pim_template/hw/lib/build/platform/ofs_plat_if` and `afu_with_pim/afu/build/platform/ofs_plat_if` active configuration/QSF, generated local-memory cfg/FIU/gasket, and the corrected paths:
   - `rtl/ifc_classes/local_mem/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv`
   - `rtl/ifc_classes/local_mem/afu_ifcs/ofs_plat_local_mem_axi_mem.vh`
   - `rtl/ifc_classes/local_mem/ofs_plat_local_mem_wrapper.vh` and `rtl/ofs_plat_if.vh`
   - `rtl/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv`
   - `rtl/ifc_classes/local_mem/prims/ofs_plat_axi_mem_if_user_ext.sv`
   - QSF-selected AXI interface/macros and burst mapper.
   Capture actual preprocessed/elaborated width values and instantiated AFU route. Read each generated MSA QIP's exact `mem_ss_msa_top.sv`/`drc_pkg.sv` source edges, or report protected/missing sources. Establish this version's 14-bit request USER and BUSER semantics, especially whether zero is an ordinary request. Then test split bursts, response ordering/backpressure and metadata restoration. No pointer change, WUSER→AWUSER substitution or invented command encoding is justified now.

4. **Resolve calibration semantics without changing routing.** H:3873/3875 repeats direct calbus0→discrete0/calbus1→RDIMM1; the earlier donor evidence requires reversed associations. Read the installed composition/control definition and current generated nested HDL/SOPC metadata to decide whether index semantics are equivalent or a supported source control is needed. BOT/BOT and rc0 do not resolve it. No remap/PLL alteration is proposed or performed by this review.

5. **Take focused warning dispositions into the next real elaboration/compile.** Capture effective generated FIFO/ROM device settings for the two invalid-device messages; active APF/BPF bridge capacity settings versus RTL protocol implementation; the three BMC conduit terminations; and requested/actual sys_pll outputs1/3/4/6 plus clock constraints. For memory simulation capture usable generated models and per-bank geometry: the four no-port diagnostics are not passed simulation. The missing ASP preset is a finite capture gap, not a reason for general monitoring infrastructure. Retain intentional debug/version notices with exact leaf identities after inspection rather than chasing a zero-warning count.

After these narrow integration steps, actual compile/elaboration must demonstrate correct part, complete include/QIP binding, both bank instances, PF routing and no undriven/width-truncated critical boundary signals. Fitter/timing and hardware remain later acceptance gates: pin/clock fit, constrained timing, both-bank calibration and independent capacity/data tests, PCIe Gen4x16 enumeration and PF0/VF0 AFU plus PF1 BMC transactions/interrupts. None is established by the receipts reviewed here.

## Scope

Created only this report. No SSH, vendor execution, source edits, commits, pointer/PLL/remap changes, generated substitutes, or readiness promotion. An unavailable bare `python` was replaced by `python3`; inspection and arithmetic then completed locally. The old missing wrapper/header condition is closed; unresolved integration issues above are not hidden behind another approval request.
