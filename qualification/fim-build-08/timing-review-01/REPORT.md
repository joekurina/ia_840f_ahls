# Work08 final timing / constraint review

## Verdict

**Timing FAIL, independently of constraint-completeness failures. No constraint relaxation or clock retuning is justified.** The largest setup failures are real, same-clock memory-subsystem adapter paths at 333.33 MHz, not the 470 MHz core and not a TRS crossing. There is also a separate EMIF1 core-to-periphery hold violation of -0.004 ns. The most actionable constraint investigation is the physically fitted but unconstrained PCIe clock divider.

## Evidence boundary

All citations `STA:L` refer to `../monitor-20260919T033051Z-01e73a/13-ofs_top.sta.rpt`; `FIT:L` to `09-ofs_top.fit.rpt`, `LOG:L` to `01-native.log` in that same directory. The complete directory is `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-08/monitor-20260919T033051Z-01e73a`. Independently rehashed and byte-counted every receipt entry: **20/20 match**. STA SHA256 `0de097308ba9226c97fc314cd55192620f89031e63e82ed6f97dffc9f48e80d0`, 46,757,072 bytes. This is the captured final STA snapshot, not an assertion that assembly or the parent flow has since finished. Monitor REPORT.md:3-13 records assembler still running at 20:34:14 PDT. No remote access, Quartus invocation, build modification, simulation, programming, commit or push was performed.

Read `../spec-review.md` and `../oscillator-exception-review.md` in full. Those reviewed preservation requirements remain unchanged: AGFB027R25A2E2V, two 16GiB x64 no-ECC DDR channels, BOT/BOT and whole-pair 0→0 / 1→1, core470/seven requested PLL outputs, PCIe Gen4x16/PF1/BAR contracts. This report does not requalify all inherited invariants.

## Exact failing paths and classification

The full node/clock names and path statistics are transcribed in Appendix A, without shortening identifiers.

| Failure | Required relationship | Worst corner | Slack / endpoint TNS / failing endpoints | Finding |
|---|---|---|---|---|
| EMIF1 user-clock domain, MSA1 write-request bank selection | setup 3.000 ns; clock 333.33 MHz | Slow vid2 100C Model | -0.366 / -117.103 ns / 820 | 11 logic levels, data delay 3.327 ns, skew -0.084 ns; no SDC exception |
| EMIF0 user-clock domain, MSA0 write-request bank selection | setup 3.000 ns; clock 333.33 MHz | Slow vid2 100C Model | -0.236 / -61.410 ns / 456 | 10 logic levels, data delay 3.315 ns, skew -0.035 ns; no SDC exception |
| EMIF1 AMM write-data bit 243 → tile2 lane1 phy_reg1 | hold 0.000 ns; related core/PHY clocks both 3.000 ns | Fast vid2 100C Model | -0.004 / -0.004 ns / 1 | 1 logic level, data delay 0.288 ns; no SDC exception |

Sources: STA:2749-2750,2780,156181-156210,157663-157692,172568-172597. Setup transfers explicitly classify the two setup domains Intra-Clock (Timed Safe), despite negative slack (STA:155945,155947): “Safe” describes clock relationship, not timing closure. EMIF0 data interconnect is 2.107 ns (64%); EMIF1 1.834 ns (55%). Both logic depth and routing matter; these numbers do not establish a particular placement or RTL change as a cure.

STA:2695-2712 explicitly fails setup, hold, DDR and unconstrained paths; recovery/removal/minimum pulse/max skew pass. DDR failure includes the actual EMIF1 hold path, not merely an aggregate warning (STA:155849,207730-207734). Do not round -0.004 to zero. Successful STA execution with zero tool errors is not acceptance.

## Actual clocks and fitted resources

STA:2603-2687 is the complete clock table (80 clock rows), including generated masters, sources and targets. Relevant observed frequencies are **reported**, not guessed from names:

- EMIF0/1 core user clocks: 3.000 ns / 333.33 MHz, generated divide-by-4 from their VCO clocks; sources `...pll_inst|pll_inst|vcoph[0]`, targets `...tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]` (STA:2630,2652). DDR references are 30.000 ns / 33.33 MHz; VCO rows show 0.750 ns / 1333.32 MHz, and PHY clocks 1.500 or 3.000 ns (STA:2631-2640,2653-2662). Preserve the report's displayed precision.
- `sys_pll|iopll_0_clk_sys`: 470.0 MHz; div2 235.0 and div4 117.5 MHz. **`sys_pll|iopll_0_clk_100m` is actually 100.71 MHz**, 9.929 ns. SYS_REFCLK is 100.0 MHz (STA:2680-2686). Four surviving sys-PLL output clocks in final STA do not prove that seven requested outputs were not configured; optimization and actual connections must be distinguished.
- AFU user PLL outputs 312.5 and 156.25 MHz (STA:2609-2610); qsfp reference 156.25 MHz (2679); BMC SCLK 5.0 MHz / 200 ns (2613); PCIe native rx_ch15 500.0 MHz (2678).
- Fmax summary gives 297.09/309.02 MHz for EMIF1/0 versus required 333.33 MHz, and 514.14 MHz for core470 (STA:2724-2727). These are analysis results, **not proposed replacement frequencies**, and the report warns that Fmax excludes different-clock paths (2735).
- FIT:31798-31803 places EMIF1 core clock at TILECTRL_X172_Y0_N298, fanout 35840; EMIF0 at TILECTRL_X281_Y0_N298, fanout 40983; sys PLL at IOPLL_X12_Y333_N303. FIT:5554-5563 reports 100.0 MHz PLL reference, 1410.0 MHz VCO, M=141/N=10. Clock names and node names must not be conflated with physical output indices.
- Fit summary: 86,223 ALMs, 232,567 registers, 664 RAM blocks, 8 PLLs; device AGFB027R25A2E2V (`17-ofs_top.fit.summary:6,10-20`). Low overall utilization does not demonstrate local routing headroom.

## Constraint defects versus warnings

### PCIe: concrete missing clock, not only optional empty filters

STA:207802 reports one unconstrained clock. STA:207815 identifies the exact fitted target:

`pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst~div_reg`

FIT:31831 independently shows that divider's `clock_div2x` at **CLKDIVBLOCK_X11_Y330_N106, fanout 355**. This is not evidence of an absent optional branch. STA:3612-3619 reports invalid-clock `set_net_delay` assignments in generated `ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc:631,639`; STA:207736 onward says no destination clock period satisfies those assignments. A causal connection to the unconstrained divider is a **strong hypothesis, not yet a proven connectivity trace**. No divider frequency is established here; do not infer one from `clock_div2x`.

Separately, ignored PCIe false paths at `intel_ptile_pcie.sdc:691-714` target empty p1/p2/p3 reset/adaptor collections (STA:206676-206705), plausibly unused branches but not independently proven optional. `pcie_ss.sdc:589-593` also has unmatched `u_pciess_cfg_if|u_pm_dstate_sync` paths and invalid object IDs (206707-206718): review actual hierarchy rather than widening patterns. Neither class explains the same-clock MSA setup failures.

### Unconstrained I/O

STA:207797-207806 gives two unconstrained inputs and two outputs for both setup/hold: reserved JTAG TDI/TMS, reserved TDO, and **bwbmc_bmc_irq** (207904-207915, repeated 207924-207935). BMC IRQ needs its actual receiver/interface timing contract; do not invent an output delay or false path. JTAG needs the applicable vendor constraint policy, not automatic suppression.

### BMC / clk50m / AFU region

- BMC SCLK non-dedicated pin / no automatic global promotion is LOG:8171-8172. Existing STA constrains it at 5 MHz, setup slack 86.950 ns and hold 0.518 ns (STA:2765,2795). BMC→100m is already false-pathed in Setup Transfers (155864). No pin relocation or frequency change follows from this warning; asynchronous-interface validation and the separate IRQ omission remain.
- `sys_pll|iopll_0_clk_50m` uncertainty filters were unmatched at **fitter-stage** `sys_pll.sdc:33-34` (LOG:8318-8321). This name is absent from final clock table and final STA warning text. Treat it as a stale/optimized-output applicability question; do not add a guessed 50 MHz clock. Verify used outputs before any guarded optional-constraint cleanup.
- LOG:8798-8799 says the exact assigned region node `afu_top|pg_afu.port_gasket|pr_slot|afu_main` does not exist. Yet final STA includes descendant AFU logic (e.g. STA:2946). Therefore it is not evidence that the entire AFU is missing; hierarchy flattening / assignment-target mismatch is a hypothesis. Check resolved partition/region membership before changing constraints, particularly for future PR export.

## S1 / TRS oscillator

The final STA clock table has no `ALTERA_INSERTED_INTOSC_FOR_TRS` or `divided_osc_clk`; neither exact token appears anywhere in the complete STA or complete fit report. The SDC list includes both generated EMIF SDCs, PCIe SDC, top.sdc, new bti_refclk.sdc and bwbmc.sdc (STA:2535,2580-2589). This is stronger absence evidence than RTL-only searching, but **not a complete fitted-resource inventory proof**. S1 remains narrowly open pending fitted-node confirmation; there is no evidence that restoring the removed exception would repair these failures.

Do not confuse TRS with present `altera_int_osc_clk`, 250 MHz, target `auto_fab_0|alt_sld_fab_0|alt_sld_fab_0|intosc|oscillator_dut~oscillator_clock` (STA:2611), physically OSCILLATOR_X11_Y0_N9 (FIT:31837). Setup Transfers includes that clock→sys 100m as Asynchronous (Timed Unsafe), positive slack 101.854 ns (STA:155859). This is another relationship review, not permission to cut it. The removed exact TRS-name exception cannot simply be applied to this different oscillator.

## Minimal next action — one bounded post-run interrogation, not a rebuild

First confirm the monitored native flow and assembler have exited and the database is stable. Do not invoke Quartus on the active build. In an authorized post-run context bind revision ofs_top, device, final netlist, SDC list and tool version; use the same final multi-corner analysis context as the captured report. Keep diagnostic output in a fresh project-local evidence directory.

1. **Prioritize the PCIe divider:** obtain only generated `pcie_ss.sdc` sections defining/deriving clocks and lines 580-645, plus the `u_pciess_clock_divider` RTL/primitive instance and its actual clock input/output wiring. These generated sources were not present at the local source path searched. Trace the unconstrained target to the invalid FIFO destination keepers from STA:3612-3619. Establish input/master clock, enabled division mode and resulting generated-clock relationship from the source/IP contract. Only then propose a narrowly scoped generated-clock/source-constraint repair. Do not assign a frequency based on a signal name. Re-run bounded STA after any separately reviewed repair; expect the independent MSA/EMIF failures to remain unless real implementation changes fix them.
2. **Setup datapath work already has sufficient identification:** inspect only the MSA write-request bank-spreading logic named in Appendix A and its generated parameters. A latency/handshake-preserving pipelining or shallower selection implementation is a candidate, not an approved patch; placement/routing optimization is also a hypothesis. No reason to rerun a full compile solely to rediscover these endpoints. Preserve clocks, geometry, mapping and constraints.
3. **Hold:** retain the exact EMIF1 bit243 endpoint/corner as a separate vendor-IP fitting/hold-repair target. Do not modify encrypted/vendor internals or relax hold.
4. **Close S1 in the same session:** enumerate exact and hierarchical TRS clock matches and fitted oscillator resources; retain full clock names/master/source/target, matching resource count, transfers and effective exception origins. If no resource and no associated clock exist, close S1 as inapplicable to this configuration. If a resource exists, apply the decision criteria in `../oscillator-exception-review.md:49-54`; do not restore a speculative cut.

### Supported report syntax, not an untested launch recipe

The captured native Command Info panels prove `report_timing -setup/-hold`, `-to_clock [get_clocks {...}]`, `-npaths 10`, and `-detail full_path` syntax (STA:156135-156143; hold command in the corresponding worst-case hold panel). In the already correctly initialized final netlist, a bounded repeat for the setup domain is:

```tcl
report_timing -setup -to_clock [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk}] -npaths 10 -detail full_path
report_timing -setup -to_clock [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk}] -npaths 10 -detail full_path
report_timing -hold -to_clock [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0}] -npaths 10 -detail full_path
get_clocks {ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk}
```

These are query fragments, not instructions to run during assembly. For clock-resource/exception inspection obtain installed command help for the finite relevant APIs before selecting options; no guessed create_timing_netlist/corner-switch/report-exceptions invocation is supplied. Existing full-path reports already settle the negative setup/hold paths; the missing information is PCIe divider connectivity/clock semantics and TRS fitted-resource applicability, not another broad timing scan.

## Appendix A — exact paths / clocks / statistics

### EMIF1 setup

Source STA:156177-156210.

```text
156177: ; Path Summary ;
156179: ; Property ; Value ;
156181: ; From Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_1|msa_1|msa_adapter|wrreq_bank_spreading|bank_fifos_dataout_out_valid[4] ;
156182: ; To Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_1|msa_1|msa_adapter|wrreq_bank_spreading|wrreq_select_bank_fifo_read[1]~SynDup_8DUPLICATE ;
156183: ; Launch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk ;
156184: ; Latch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk ;
156185: ; SDC Exception ; No SDC Exception on Path ;
156186: ; Data Arrival Time ; 7.605 ;
156187: ; Data Required Time ; 7.239 ;
156188: ; Slack ; -0.366 (VIOLATED) ;
156189: ; Worst-Case Operating Conditions ; Slow vid2 100C Model ;
156191: 
156193: ; Statistics ;
156195: ; Property ; Value ; Count ; Total Delay ; % of Total ; Min ; Max ;
156197: ; Setup Relationship ; 3.000 ; ; ; ; ; ;
156198: ; Clock Skew ; -0.084 ; ; ; ; ; ;
156199: ; Data Delay ; 3.327 ; ; ; ; ; ;
156200: ; Number of Logic Levels ; ; 11 ; ; ; ; ;
156201: ; Physical Delays ; ; ; ; ; ; ;
156202: ; Arrival Path ; ; ; ; ; ; ;
156203: ; Clock ; ; ; ; ; ; ;
156204: ; IC ; ; 2 ; 3.993 ; 53 ; 0.000 ; 3.993 ;
156205: ; Cell ; ; 14 ; 3.485 ; 47 ; 0.000 ; 1.131 ;
156206: ; PLL Compensation ; ; 2 ; -3.200 ; 0 ; -2.397 ; -0.803 ;
156207: ; Data ; ; ; ; ; ; ;
156208: ; IC ; ; 12 ; 1.834 ; 55 ; 0.066 ; 0.296 ;
156209: ; Cell ; ; 21 ; 1.247 ; 37 ; 0.000 ; 0.130 ;
156210: ; uTco ; ; 1 ; 0.246 ; 7 ; 0.246 ; 0.246 ;
```

### EMIF0 setup

Source STA:157659-157692.

```text
157659: ; Path Summary ;
157661: ; Property ; Value ;
157663: ; From Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_0|msa_0|msa_adapter|wrreq_bank_spreading|wrreq_select_bank_fifo_read[0]~SynDup ;
157664: ; To Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_0|msa_0|msa_adapter|wrreq_bank_spreading|wrreq_select_bank_fifo_read[0]~SynDup_8RTM_1 ;
157665: ; Launch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk ;
157666: ; Latch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk ;
157667: ; SDC Exception ; No SDC Exception on Path ;
157668: ; Data Arrival Time ; 7.554 ;
157669: ; Data Required Time ; 7.318 ;
157670: ; Slack ; -0.236 (VIOLATED) ;
157671: ; Worst-Case Operating Conditions ; Slow vid2 100C Model ;
157673: 
157675: ; Statistics ;
157677: ; Property ; Value ; Count ; Total Delay ; % of Total ; Min ; Max ;
157679: ; Setup Relationship ; 3.000 ; ; ; ; ; ;
157680: ; Clock Skew ; -0.035 ; ; ; ; ; ;
157681: ; Data Delay ; 3.315 ; ; ; ; ; ;
157682: ; Number of Logic Levels ; ; 10 ; ; ; ; ;
157683: ; Physical Delays ; ; ; ; ; ; ;
157684: ; Arrival Path ; ; ; ; ; ; ;
157685: ; Clock ; ; ; ; ; ; ;
157686: ; IC ; ; 2 ; 4.263 ; 55 ; 0.000 ; 4.263 ;
157687: ; Cell ; ; 14 ; 3.475 ; 45 ; 0.000 ; 1.131 ;
157688: ; PLL Compensation ; ; 2 ; -3.499 ; 0 ; -2.696 ; -0.803 ;
157689: ; Data ; ; ; ; ; ; ;
157690: ; IC ; ; 10 ; 2.107 ; 64 ; 0.066 ; 0.424 ;
157691: ; Cell ; ; 18 ; 0.974 ; 29 ; 0.000 ; 0.125 ;
157692: ; uTco ; ; 1 ; 0.234 ; 7 ; 0.234 ; 0.234 ;
```

### EMIF1 hold

Source STA:172564-172597.

```text
172564: ; Path Summary ;
172566: ; Property ; Value ;
172568: ; From Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243] ;
172569: ; To Node ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1 ;
172570: ; Launch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk ;
172571: ; Latch Clock ; local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0 ;
172572: ; SDC Exception ; No SDC Exception on Path ;
172573: ; Data Arrival Time ; 2.964 ;
172574: ; Data Required Time ; 2.968 ;
172575: ; Slack ; -0.004 (VIOLATED) ;
172576: ; Worst-Case Operating Conditions ; Fast vid2 100C Model ;
172578: 
172580: ; Statistics ;
172582: ; Property ; Value ; Count ; Total Delay ; % of Total ; Min ; Max ;
172584: ; Hold Relationship ; 0.000 ; ; ; ; ; ;
172585: ; Clock Skew ; -0.080 ; ; ; ; ; ;
172586: ; Data Delay ; 0.288 ; ; ; ; ; ;
172587: ; Number of Logic Levels ; ; 1 ; ; ; ; ;
172588: ; Physical Delays ; ; ; ; ; ; ;
172589: ; Arrival Path ; ; ; ; ; ; ;
172590: ; Clock ; ; ; ; ; ; ;
172591: ; IC ; ; 2 ; 3.236 ; 57 ; 0.000 ; 3.236 ;
172592: ; Cell ; ; 14 ; 2.440 ; 43 ; 0.000 ; 0.800 ;
172593: ; PLL Compensation ; ; 2 ; -3.000 ; 0 ; -2.292 ; -0.708 ;
172594: ; Data ; ; ; ; ; ; ;
172595: ; IC ; ; 1 ; 0.101 ; 35 ; 0.101 ; 0.101 ;
172596: ; Cell ; ; 4 ; 0.124 ; 43 ; 0.000 ; 0.053 ;
172597: ; uTco ; ; 1 ; 0.063 ; 22 ; 0.063 ; 0.063 ;
```

Only this new review file was authored. Build/source trees and acceptance flags were left unchanged. DDR simulation remains skipped by user.
