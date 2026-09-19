# Rendered PCIe synthesis constraints: live06 static review

**ready=false; ready_for_build=false; execution_authorized=false.** Rendered source confirms a conditional 100-MHz PCIe AXI-Lite clock definition, not a proved conflicting TimeQuest clock object. No source/constraint correction is justified by this evidence alone. Core470 and the seven-port PLL interface remain unchanged.

## Scope and integrity

Only local captured JSON/text inspection and Python byte/hash/arithmetic work; no workstation/network acquisition, Tcl/HDL/vendor execution, tests, source edits or commits. No protected bodies were read or decrypted. Only the two owned review artifacts are created.

`pcie-rendered-constraints-live06.json`: 275510 bytes; SHA256 `10e8e2b262ada40ed64e232194e8cdc20ec3f20083b18d0ba12e0f3fd97b3e0f`. Independently verified container and all four UTF-8 payload lengths/hashes. Capture `errors=[]`. The four unique payload paths are all literal live05 observations. Live05 reports `RuntimeError('512-entry discovery cap')`, 513 entries examined and `complete_within_scope=false`: neither directory-root completeness nor system-PLL absence is established. The fifth observed match, `.qgsynthc`, was not captured or inspected.

All citations below are **1-based decoded payload lines**, not JSON lines. Let R be `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss`.

- **Q** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/pcie_ss.qip`; 63169 bytes, 360 lines; SHA256 `97d4cd6d42bd823437e9e221d0c6987e670ba45124e49c3e72cae69730b332df`.
- **I** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/altera_iopll_2110/synth/pcie_ss_altera_iopll_2110_5imavpa.sdc`; 7038 bytes, 183 lines; SHA256 `6d2b95bfe3f3954da1dd60641bf0dac1f215a70c3112943c29752881c89da507`.
- **H** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/synth/intel_ptile_pcie.sdc`; 138663 bytes, 2149 lines; SHA256 `aa82e3d18d152d231ea0f256dd2e7cb2a62bbb6499ebcb8633dde27b5e7645a0`.
- **A** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc`; 59669 bytes, 736 lines; SHA256 `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265`.

## Literal synthesis registration and hierarchy boundary

Q:2 identifies26.1.1; Q:16 targets AGFB027R25A2E2V; Q:20 records STANDALONE generation mode and Q:21 SYNTHESIS_ONLY_QIP. These are generated-manifest facts, not proof that the FIM loaded this QIP or that an embedded endpoint is a board-level port. Q:6 also records PRE_COMPILED_MODULE ON; no compiled database was inspected.

All three literal SDC_ENTITY_FILE registrations in this QIP are captured:

| Q line | Entity / library | R-relative rendered SDC | Flags |
|---|---|---|---|
|84|pcie_ss_altera_iopll_2110_5imavpa / altera_iopll_2110|altera_iopll_2110/synth/pcie_ss_altera_iopll_2110_5imavpa.sdc|no_sdc_promotion; no_auto_inst_discovery; read_during_post_syn_and_post_fit_timing_analysis|
|160|pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a / intel_pcie_ptile_ast_1100|intel_pcie_ptile_ast_1100/synth/intel_ptile_pcie.sdc|no_sdc_promotion|
|345|pcie_ss_intel_pcie_ss_axi_500_gycdipy / intel_pcie_ss_axi_500|intel_pcie_ss_axi_500/synth/pcie_ss.sdc|no_sdc_promotion|

Paths use `[file join $::quartus(qip_path) "..."]`. This closes the literal PCIe QIP-to-three-SDC registration question, **not their evaluated load order, instance scope, or transitive dependency closure**. A:14–18 takes `pcie_ss_inst` from `get_current_instance`; H:125–129 similarly takes `inst`. Neither supplies the actual board hierarchy string. No promotion flag is evidence against treating these as unconditional top-level constraints, but does not determine `get_ports` results in an unevaluated design.

## Rendered AXI-Lite condition and period versus live04

A:82–90 now supplies actual rendered values: Agilex7, Gen4 1x16, Native Endpoint, debug0, P-TILE, Power User, core16 ST500 and Lite100. A:92–94 retains runtime period expressions; Python evaluation of the literal arithmetic gives ST/MM2.000 ns and Lite10.000 ns. **The file does not literally store an evaluated TimeQuest clock object or even substitute a literal10.000 into create_clock.** Template live04:89–90 had source dictionary placeholders; the helpers and clock branches retain their structure with template dollar/backslash escaping removed.

- A:23–41 checks `[get_ports -nowarn $port_name]` collection size; A:63–80 gathers defined clocks' targets using `get_clock_info -targets` and `query_collection -report -all` into a Tcl list.
- A:133 takes the target-list snapshot before the conditional refclock/ST/Lite creations. It is not refreshed immediately before Lite.
- A:161 queries `p*_axi_lite_clk`; A:162 does `lsearch -exact $pcie_clock_target_list p*_axi_lite_clk`; A:163 requires port existence AND lookup=-1. A:164 then calls `create_clock -name p0_axi_lite_clk -period $CORE_16_LITE_CLK_PERIOD [get_ports p0_axi_lite_clk]`.
- The `*` in that exact lookup is not a glob match. This is not proven comprehensive duplicate detection for a concrete `p0_axi_lite_clk` target, especially with hierarchy-qualified or multi-target collection strings. Conversely it is not proof the branch executes: the port collection and scope remain unknown.
- Gen4 1x16 makes the p1/p2/p3 conditional branches A:165–170 inactive by the rendered topology. A:187 computes clock existence, but the AVMM block A:188 gates on **port existence**, not that clock-existence variable. Rendered P-Tile/Native Endpoint selects A:191–192's divide-by2 `avmm_clock0`, master/source `p0_axi_lite_clk`, targeting `${pcie_ss_inst}|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2`. A:218 groups it asynchronously from p0_axi_lite_clk. These commands still require actual objects and scope; no20-ns AVMM object is claimed.
- A:147–151 similarly conditionally defines p0_axi_st_clk from rendered500. This is not evidence to retune the470-MHz core: the same existence/target/scope uncertainty applies.

The prior producer result remains nominal100.714285714 MHz /9.929078014184396 ns on system PLL output1, under a100-MHz reference assumption (`generated-hdl-review.md:66–91`). The selected maintained consumer path is clk_100m -> clk_csr -> PCIe csr_clk -> p0_axi_lite_clk (`clock-consumer-contract-review.md:28–42`). **A rendered conditional10.000-ns definition disagrees numerically with that nominal producer; a contradictory effective timing clock on the same consumer has not been established.** If embedded `get_ports` finds no matching port, this creation branch does not run. If the port exists and exact lookup returns-1, the command is attempted; actual target resolution and coexistence with the incoming clock must still be established. Do not declare timing failure, success, or a safe duplicate guard from the source alone.

## Other two SDCs do not close the system-PLL question

I is the PCIe-local `pcie_ss_altera_iopll_2110_5imavpa`, **not** `sys_pll_altera_iopll_2110_3lkpvti`. I:31–34 sources two exact companion Tcl files. I:75–109 obtains atom-derived clock dictionaries; I:116–124 conditionally creates reference clocks; I:130–166 uses dictionary multiply/divide/source/name fields with post-synthesis versus other timing branches. No captured helper contents or evaluated dictionaries establish even this PLL's clock objects. Its registration does not stand in for the missing system-PLL manifest/SDC.

H:116–129 renders Agilex7, Gen4x16/512-bit and captures current instance. H:151–158 resolves internal channel15 nodes. H:607–660 conditionally creates10-ns refclk/reconfig/completion-timeout clocks by port/target checks. No p0_axi_lite clock definition was found in H; those differently named clocks cannot be substituted for CSR binding evidence.

## Finite exact missing source paths and contracts

The next four synthesis RTL paths are derived from literal QIP records, not guessed from simulation suffixes. Their **contents are not captured here**, and matching entity suffixes do not prove simulation/synthesis identity:

- Q:348: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/synth/pcie_ss.v`.
- Q:162: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv`.
- Q:161: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_intel_pcie_ptile_ast_500_pxriq3y.v`.
- Q:88: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/intel_pcie_ptile_ast_1100/synth/pcie_ss_intel_pcie_ptile_ast_1100_ndgxg4a.sv`.

They are the finite top -> AXI -> P-Tile bridge -> HIP chain to compare against the earlier simulation payloads, especially p0_axi_lite port wiring and effective branch/parameter selection. Read only unprotected source if separately authorized; stop at protected content, never decrypt. Four files are not a complete synthesis closure.

The PCIe-local PLL SDC also literally names these missing companion sources (only needed to close its own clock dictionary behavior, not as substitutes for sys_pll):
- I:33, Q:83: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/altera_iopll_2110/synth/pcie_ss_altera_iopll_2110_5imavpa_parameters.tcl`.
- I:34, Q:85: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ipss/pcie/qip/pcie_ss/altera_iopll_2110/synth/pcie_ss_altera_iopll_2110_5imavpa_pin_map.tcl`.

Remaining system-PLL manifest/registered SDC/RTL paths are **unknown**, not negative findings: complete a separately authorized names-only bounded discovery under the already observed `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll` root without spending its budget on recursive PCIe traversal; then use literal returned registrations. No `synth` counterpart or suffix is invented for sys_pll.

The exact unresolved binding contract is: the actual selected board/generated header/source set and loaded QIP/SDC order; the AXI SDC current instance; `get_ports p*_axi_lite_clk` and `get_ports p0_axi_lite_clk` collections; the defined-clock target-list snapshot and exact lookup result at A:162; incoming system-PLL output1 clock name/source/period/targets; whether A:164 creates/replaces/coexists with a clock on the same sink; and the resolved A:192 divider target/master clock. Static synthesis wiring can narrow this, but **evaluated TimeQuest objects are absent** and cannot be replaced by rendered text. No timing run is authorized here.

Separately missing is documented consumer acceptance for nominal100.714285714 MHz (and prior50.357142857 MHz consumers), including the supported interpretation of PCIe's parent INTEGER {100:250} request. The value100 is now visibly used in a clock-period formula; that still supplies no tolerance grant. Do not insert an unsupported fractional request, silently retune, disable/rename PLL outputs, relax SDC, or alter the core470/seven-port interface.

Broad generation remains failed due to mailbox; generated headers have not run. Preserve AGFB027R25A2E2V, PTileGen4x16, PF0VF0 AFU/PF1 BMC, PF1 BAR0 Disabled, BAR2 width28/BAR4 width14,64-byte/two-segment workaround, existing pins/channels and geometry. No readiness promotion.
