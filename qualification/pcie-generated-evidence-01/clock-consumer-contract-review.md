# IA840F clock consumers and correction decision

**ready=false; ready_for_build=false; execution_authorized=false. No source patch is justified yet.** The useful next step is a bounded constraint/source-manifest capture, not PLL retuning. In the selected IA840F source configuration the 630-MHz-named and 350-MHz-named NoC outputs have no enabled RTL sink. The CSR output does have enabled consumers; its nominal 100.7142857 MHz is not newly introduced by this port, but consumer-wide acceptance is not proved by that history.

## Scope and citation keys

- `C` = `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach`.
- `N` = `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.
- `V` = `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f` (read-only).
- `T` = `C/src/board/ia840f/top.sv`; `A` = `C/src/board/ia840f/afu_top.sv`; `Q` = `C/syn/board/ia840f/syn_top/ofs_top.qsf`.
- Citations are literal local source lines, except where expressly attributed to the prior generated review. This builds on `generated-hdl-review.md:64–99` and its JSON disposition; it does not repeat or requalify the six simulation HDL files.
- Only static text/XML/JSON inspection and Python arithmetic were performed. No Tcl, HDL, vendor execution, tests, remote operations or commits. Source selection is not a compiled/fitted design claim.

## Which top and which branches?

`Q:122` loads `ofs_top_sources.tcl`; that file's **line58 selects the board top T**, not `src/top/top.sv`. Line46 selects the IA840F AFU file-list; `syn/board/ia840f/setup/afu_design_files.tcl:14` selects A. `Q:96–108` enables USER_CLK, IA840F, DDR4, PR, PCIE_SS and REMOTE_STP, with DDR4_NUM_MEM_GROUPS=2; PMCI, HSSI, HPS and UART assignments are commented out. There is no IA840F INCLUDE_HBM assignment.

This is more than a name-based NoC inference:

1. `T:152,516,519,1256–1257` contains the declaration, producer connections, and the **only sink connections** of `clk_noc_fab_wr` and `clk_noc_fab` in that top. The sinks are inside **INCLUDE_LOCAL_MEM (`T:1230–1290`) AND INCLUDE_HBM (`T:1252–1263`)**.
2. `C/ipss/mem/mem_design_files.tcl:5–6` initializes both memory-selection variables to zero; **23–28** makes DDR4 imply LOCAL_MEM, not HBM. **36–40** requires an existing INCLUDE_HBM assignment. Only **67–84** adds the HBM/NoC Qsys and IP files. IA840F selects DDR4, so its LOCAL_MEM path does not enable the HBM sink.
3. `Q:111` includes `C/syn/shared_config/compile_flags.tcl`; its complete body (4–7) only supplies NULL exerciser flags. `T:14–15` includes `fpga_defines.vh` and generated `ofs_ip_cfg_db.vh`; local `C/src/includes/fpga_defines.vh:5–16` defines family/PTILE/ETILE, not HBM. A repository-wide search of source/config text for HBM macro definition/assignment found only `syn/board/mseries-dk/syn_top/ofs_top.qsf:74`, a different board.

**Conclusion:** outputs3 and6 are unused by the selected maintained IA840F RTL consumer graph. They remain configured/enabled in the generated PLL and hence still participate in its clock solution. This is not proof that a fitter removed those outputs; an actual compiled macro/header/source set is still needed to establish Work03 elaboration identity. Do not disable outputs merely because source sinks are absent: output numbering and the common seven-port interface must be preserved.

## Output-to-consumer contract

The common producer is unconditional `T:509–520`, with SYS_REFCLK at511. Frequencies below reuse the prior static generated divider result, not a measurement.

| Public output / nominal MHz | Source net and selected consumers | Contract boundary |
|---|---|---|
| 0 / 470 | `clk_sys`: PCIe streams `T:235–242`, reset controller528, PCIe wrapper FIM clock588, AFU740, local memory1237 | Main design clock; `T:503–506` explicitly describes470 for x16. Preserve it. |
| 1 / 100.7142857… | `clk_100m` -> `clk_csr` (`T:300`); resets529; PCIe CSR590; PMCI **dummy**672; FME703; AFU742; BPF941; local memory CSR1274 | Actual active CSR consumers, not just an unused nominal100 output. PCIe clock wiring detailed below. |
| 2 / 235 | `clk_sys_div2` -> AFU (`T:747`); A has a noprune two-register toggle at192–197; conditional port gasket passes it at667 | Exact half of core in generated solution. Do not drop it with NoC clocks. |
| 3 / 705 | `clk_noc_fab_wr`, only HBM-gated sink `T:1257` | No enabled maintained IA840F RTL sink; name630 and stale comment600 (`T:516`) are not measured or accepted contracts. |
| 4 / 50.3571429… | `clk_50m` -> reset controller (`T:530`) and AFU744; reset synchronizer `C/src/top/rst_ctrl.sv:236–248` | A:729–745 gates the UART consumer at736 with INCLUDE_UART, which Q does not enable. Connected reset logic is not proof it survives optimization. No quantitative tolerance found. |
| 5 / 117.5 | `clk_sys_div4` -> AFU (`T:748`) and conditional port gasket (`A:652–674`, pass668) | Exact quarter of core. Port gasket requires PG_AFU_NUM_PORTS>0; generated routing/header values are not independently elaborated here. |
| 6 / 352.5 | `clk_noc_fab`, only HBM-gated sink `T:1256` | Same disabled consumer branch as output3. |

PCIe forwarding is independent of whether the wrapper selects DM or AXIS: `C/ofs-common/src/fpga_family/agilex/pcie_ss/pcie_wrapper.sv:248–262` computes the selection from generated macros; **266–305** passes common `.csr_clk(csr_clk)` to either branch. `pcie_ss_dm_top.sv:232–234` connects p0_axi_lite_clk and its reset; `pcie_ss_axis_top.sv:716` also connects p0_axi_lite_clk to csr_clk. This source edge complements the already reviewed active P-Tile generated endpoint. It is not proof of Work03's synthesized hierarchy.

Other AFU consumers include the static-region branch `A:587–609`, and the port-gasket branch `A:652–674`. The latter forwards clk_csr as both clk_100 and clk_csr. `C/ofs-common/src/fpga_family/agilex/port_gasket/port_gasket.sv:257–273` enables user clock control with INCLUDE_USER_CLK; **448–463** enables PR control and connects both PR clocks to clk_csr. Thus treating CSR as “PCIe only” would miss consumers. Branch parameters must still be bound to the actual generated configuration before claiming a complete synthesis consumer count.

## Origin and shared-divider conflict

`C/syn/board/ia840f/config/ia840f.ofss:7` selects `tools/ofss_config/iopll/iopll_470MHz.ofss`, whose **5–9** selects sys_pll/iopll_0 and p_clk=470. The common helper `C/ofs-common/tools/ofss_config/iopll_ip.py:55–64` imports every common PLL parameter; **70–84** derives p_clk/2 and p_clk/4 and overrides outputs0,2,5 only. `ip_params/iopll_component_parameters.py:6–22` fixes reference100, seven clocks, requests100/630/50/350 on the other outputs, and their names. It does not inspect the selected board's HBM consumers before requesting them. Its check at `iopll_ip.py:33–42` is a p_clk lower-bound check, not output-tolerance approval.

All seven outputs are solved on one instantiated IOPLL with one M/N/VCO and separate integer C dividers (prior review PLLVO:147–286). Python Fraction arithmetic gives, at the proven1410 MHz VCO, required exact C for requested100/630/50/350 of **141/10, 47/21, 141/5, 141/35**. None is an integer. Changing just a C cannot make any of those exact while preserving that VCO. Outputs470/235/117.5 use integer C=3/6/12 and are already exact.

Preserving470 while changing M/N is not an independent “fix100” operation either: the minimum common integer-divider VCO for exact470 and100 is4700 MHz; for470 and630 it is29610 MHz, and for470 and350 it is16450 MHz. Exact470/100/630/50/350 together require a common multiple of296100 MHz. These are arithmetic lower bounds, **not proposed target frequencies**. Device/solver VCO limits were not established in this task, so do not generalize this into an unqualified proof about every alternate PLL architecture. The current solution's conflict is proved; a legal replacement is not. Merely omitting NoC sinks or their requests does not demonstrate exact100 with470 or preserve output-port compatibility.

## Historical and tolerance evidence: useful but limited

`V/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` already requests470 and100 at **1284–1293**, and records output1 clockRate **100714286 at230–233**; output4 is **50357143 at401–404**. Thus nominal CSR/50 rounding predates this seven-output migration. It is **not** a seven-output drop-in donor: its number_of_clocks is5 at864–867, output2 requests175 at1294–1297, and output3 requests155.555556 at1299–1302. Restoring this donor would change current output roles/ratios.

The maintained source explicitly expects possible CSR rounding: `T:505` says **~100 MHz**. `C/ofs-common/src/fpga_family/agilex/user_clock/qph_user_clk.sv:357–361` says actual clk_100m may be slightly off100 MHz and uses `sys_pll_pkg::clock_name_to_actual_mhz("clk_100m")`. `sys_pll_pkg.sv:29–52,80–83` separates requested and actual frequencies via generated macros. This is real accommodation in one consumer, **not numerical tolerance for PCIe, PR, BMC, all counters, or hardware**. No explicit consumer-wide ppm/percent acceptance bound was found in the bounded source/reference review. In particular, the PCIe captured schema at `N/reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_parameters.tcl:1721` declares the AXI-Lite request as **INTEGER {100:250}**, not a fractional real. Do not propose blindly writing100.7142857 into that parameter.

## Constraint evidence and exact missing files

Maintained constraints are available, but are not the missing generated constraints:

- `C/syn/board/ia840f/syn_top/ofs_top_sources.tcl:64` registers `syn/shared_config/top.sdc`. That SDC **27** creates SYS_REFCLK period10 ns; **44–60** uses named sys_pll clocks for groups and PCIe multicycles, without defining the PLL output periods.
- `C/ofs-common/src/fpga_family/agilex/ofs_common_agilex_design_files.tcl:44–45` registers PLL source/SDC. `sys_pll_design_files.tcl:7,12` registers the `.ip` and configuration database, not a generated QIP. The maintained `sys_pll.sdc:11–34` adds0.008 uncertainty only during quartus_fit, non-PR_IMPL base builds with INCLUDE_PR. This is fitting margin, **not frequency tolerance** and not a generated clock declaration.
- Captured installed source `N/reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_fileset.tcl:223,249,261–264` reads the parent AXI-Lite request, passes it as an SDC template dictionary key, reads literal `${QUARTUS_ROOTDIR}/../ip/altera/subsystems/intel_pcie_ss_axi/rtl/pcie_ss.sdc.terp`, and registers logical `pcie_ss.sdc` as SDC_ENTITY with NO_SDC_PROMOTION. The template is not in the local captured reference inventory. A logical fileset name is not an absolute rendered path.
- All live01–03 decoded bodies were searched for `.sdc`/`.qip` literals: none. Additional qualification receipt hits in ipgen-03 expected-source-inventory, ipgen-02 remote-post-setup-artifact-snapshot and goal-initial-preflight authorization-expected-sources resolve only to the maintained `src/fpga_family/agilex/sys_pll/sys_pll.sdc`. They do not establish Work03 generated paths.
- A **real legacy synthesis manifest** was found locally: `V/work-ofs-23.1-2-build/syn/ip_lib/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/sys_pll.qip`. Its14 marks SYNTHESIS_ONLY_QIP; **38,41,44** literally name the legacy synthesis child, entity SDC and top. In particular41 names `altera_iopll_1931/synth/sys_pll_altera_iopll_1931_4x4eiei.sdc`; that file119–137 creates clocks using variable periods/ratios. These are Quartus23.1 artifacts (QIP:2), **not** evidence of the26.1.1 Work03 synthesis source or SDC. No path was transplanted into Work03.

## Decision and practical next step

**Keep470 and current source/preset intact. Do not retune, rename, disable PLL ports, restore the five-port donor, relax constraints, or round the PCIe request to a newly invented frequency.** No minimal frequency patch is presently defensible. The high-value result is that the705-MHz NoC discrepancy is not an active IA840F RTL timing requirement under the selected flags; the active issue to resolve first is CSR source/constraint agreement.

1. Under separate authorization, obtain the **literal installed template** above, tied to the captured26.1.1 installation. It will establish whether the integer request affects a clock definition, delay bound or another constraint, and how it coexists with the incoming PLL clock. A parent request/producer mismatch alone does not prove a bad timing constraint.
2. Discover **names only**, capped to the two already observed generated-IP directory roots, for actual Work03 synthesis manifests and registered SDCs. Then capture only files named by those manifests. Do not infer a `.v` counterpart from `.vo` or transplant the legacy suffix. Exact directory roots, caps and unresolved file paths are in the companion JSON; this is a proposal, not execution authorization.
3. Bind those manifests plus the actual generated macro/header set to the selected board top and confirm the CSR generated clock has the divider-derived period9.929078014… ns, with no contradictory p0_axi_lite clock definition. Preserve simulation/synthesis identity as a separate check.
4. If constraints already follow the incoming actual clock, the next decision is a documented consumer acceptance/timing review for100.7142857… and50.3571429…, not a PLL patch. If the template hard-codes a conflicting100-MHz clock, correct the demonstrated source/template-binding contract using a vendor-supported representation only after its integer-schema/clock-object behavior is understood. Do not claim this conditional branch is already proved.

Preserve **AGFB027R25A2E2V, PTileGen4x16, PF0VF0 AFU, PF1 BMC, PF1 BAR0 Disabled, BAR2 width28, BAR4 width14,64-byte/two-segment workaround, existing pins/channels and board/vendor geometry**. No readiness promotion. Only this report and `clock-consumer-next-evidence.json` are owned outputs.
