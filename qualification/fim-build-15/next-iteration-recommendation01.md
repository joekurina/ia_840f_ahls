# Work15 EMIF1 hold: next-iteration recommendation

**Outcome: the failed physical segment did not change. No exact corrective source assignment is justified yet.**
The useful missing fact is narrowly defined below: the **effective Fitter-stage hold objective for this exact core→PHY transfer**, including the vendor's stage-specific overconstraint and its legal source control.
Do not spend another full fit on unchanged effort/seed settings or an assumed additive uncertainty. This is a report-selection result, not a new approval/review framework.

## Evidence and scope

- `T15` = [actual Work15 STA](reports01/output_files/ofs_top.sta.rpt); `F15` = [actual Work15 FIT](reports01/output_files/ofs_top.fit.rpt).
- `T14` = [actual Work14 STA](../fim-build-14/reports11/output_files/ofs_top.sta.rpt).
- `S` = [captured generated EMIF1 source directory](../msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/).
- Under `S`, `IP` means `mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra`; `IP.sdc`, `IP_pin_map.tcl`, and `IP_ip_parameters.tcl` below use that exact basename.
- Native evidence is already bound by [reports-manifest01.json](reports-manifest01.json:27–67) and [result-review-freeze01.json](result-review-freeze01.json); neither was changed.
- `S` is the retained generation result, not a newly collected Work15 source/atom readback. Its matching hierarchy explains the report, but does not independently prove Work15's effective atom assignments.
- Work15 is still a timing failure: hold slack/TNS **−0.004/−0.004 ns**, Fast vid2 100C; assembly/compile success does not supersede it. [STA summary:95–98](reports01/output_files/ofs_top.sta.summary)

## Exact failed path, established from Work15

The reported panel is **Core To Periphery (hold), snapshot final**, not an external DDR pin path or the earlier MSA setup path. [T15:126744–126758]
With common prefix `P = local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1`:

- Launch: `P|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`.
- Capture: `P|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`.
- Clocks: `P|emif_1_core_usr_clk` → `P|emif_1_phy_clk_l_0`; relationship **0.000 ns**; **No SDC Exception on Path**. [T15:126786–126804]
- Launch resource: `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32`, a **Hyper-Register**.
- Data crosses `UFI_X210_Y0_N355`, specifically `fm_ufis|tile_gen[2].lane_gen[1].pin_gen[3].phase_gen[3].data_lane_c2p_ufi_i|c2p_350_ufi.ufi_inst`.
- Capture resource: `IO12LANE_X184_Y0_N374`, entering `lane_inst|data_from_core[19]`. [T15:126850–126858]

A programmatic comparison of all semicolon-delimited fields in T14:126747–126865 against T15:126779–126897 found **only the launch clock-tree fanout changed, 16023→16175**.
Every reported delay, resource location, element name, exception, clock, arrival and required-time field in that path remained equal at printed precision. [T14:126817; T15:126849]
This establishes repeated physical-path reporting, not identical complete routing databases or proof that the segment can never move.
The next listed path, bit368 to the same named PHY endpoint, has +0.006 ns; positive neighboring bits do not erase bit243's failure. [T15:126766–126775]

## Data versus clock/logic decomposition

| Quantity | Work15 value (ns) | Native citation |
|---|---:|---|
| Launch clock arrival at Hyper-Register | 2.676 | T15:126831,126850 |
| Launch clock's final aggregated IC arc | 3.236 | T15:126850 |
| Hyper-Register clock-to-Q | 0.063 | T15:126853 |
| Data interconnect, Hyper-Register→UFI | 0.101 | T15:126854 |
| UFI cell arcs | 0.022 + 0.053 | T15:126855–126856 |
| I/O lane data cell arc | 0.049 | T15:126857 |
| Total data delay / logic levels | 0.288 / 1 | T15:126804–126805 |
| Raw capture clock arrival | 3.000 | T15:126889–126891 |
| Capture corrections: pessimism / advanced effects | −0.354 / −0.050 | T15:126892–126893 |
| Corrected capture clock / reported skew | 2.596 / −0.080 | T15:126867,126803 |
| Hold uncertainty / endpoint uTh | 0.030 / 0.342 | T15:126894–126895 |

Decimal arithmetic: arrival = 2.676 + 0.063 + 0.101 + 0.022 + 0.053 + 0.049 = **2.964 ns**.
Required = 3.000 − 0.354 − 0.050 + 0.030 + 0.342 = **2.968 ns**; slack = **−0.004 ns**.
The reported negative skew is capture-minus-launch and **helps** this hold check by 0.080 ns; do not diagnose it as 80 ps of adverse hold skew.
Holding all clock/check terms fixed, data delay would need **0.292 ns**, versus 0.288 ns, just to reach displayed zero slack. This is sensitivity arithmetic, not a supported delay-chain setting.
There is no fabric LUT chain to lengthen in the reported data leg. Its 0.101 ns IC entry does not reveal freely selectable routing alternatives; the 3.236 ns clock IC entry likewise aggregates a route. [T15:126813–126815,126850–126858]
Signoff reports zero TMC-20312 global-data-route and zero TMC-20313 locally-routed-clock violations; those limited checks do not prove optimizer freedom or timing acceptance. [signoff:202–203](reports01/output_files/ofs_top.tq.drc.signoff.rpt)

## Source names and actual optimizer targetability

`S/altera_emif_arch_fm_hmc_amm_data_if.sv:132–162` declares `amm_writedata_0_r`, clocks it with `emif_usr_clk`, and maps its data to lanes.
`S/altera_emif_arch_fm_ufis.sv:723–738` creates the matching pin/phase `data_lane_c2p_ufi_i`, supplying `LANE_HIPI_DELAY` to its wrapper.
Crucially, `S/altera_emif_arch_fm_ufi_wrapper.sv:58–68` names the observed `c2p_350_ufi` branch and embeds **FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON; HYPER_REGISTER_DELAY_CHAIN 350** on its `tennm_ufi` instance.
Thus the evidence points to a **vendor-directed Hyper-Register→UFI→hard PHY boundary**, not an arbitrary user RTL short path. The source attribute targets the UFI instance, not the post-fit `amm_writedata_0_r` launch name or `lane_inst~phy_reg1` timing-model name.
Do not infer a legal new delay-chain value, a guaranteed 350 ps fitted delay, or permission to relocate/disable the forced Hyper-Register from that literal. Do not edit generated PHY RTL.

F15:163–205 confirms High Performance Effort, MAXIMUM router optimization, Maximum placement effort, register retiming On, All Paths hold optimization, multicorner On and seed2.
Aggressive hold closure is already On in [actual QSF:128–130](completion-readback01/project/ofs_top.qsf) and [actual flow:399](completion-readback01/project/output_files/ofs_top.flow.rpt). Re-enabling these changes nothing.
F15:39676 says this clock transfer “Meets timing requirements: No further analysis performed” in **Retiming Limit Summary**; it is not final hold signoff and gives no per-arc hold-fix rejection reason.
F15:39155–39234 lists estimated hold-delay additions elsewhere, not a repair for bit243. Its generic suggestion to turn hold optimization off is not adopted.

## New, consequential distinction: Fitter objective is not final STA uncertainty

The captured IP explicitly has **Fitter-only core/periphery overconstraints**: `S/IP.sdc:946–965` loads them for fit and substitutes zeros for STA.
`S/IP_pin_map.tcl:822–830` obtains C2P hold overconstraint from **C2P_HOLD_OC_NS**; the captured value is **0.000** at `S/IP_ip_parameters.tcl:143`.
`S/IP.sdc:983–1008` distinguishes multi-tile explicit uncertainty from same-tile derived-plus-additive uncertainty. Its comment expressly says **do not use −add** for the explicit-override case.
Therefore “append +10 ps with −add” is not established to mean “increase the existing effective hold objective by 10 ps”; it can replace the vendor's assignment basis. Final STA's 0.030 ns alone does not settle the Fitter value or branch.
A **strictly increased, fit-only hold objective** could legitimately test optimizer responsiveness without changing functional timing requirements. That is different from false-pathing this transfer, relaxing hold, altering uTh, or deleting vendor exceptions.
The actual path has no exception; the vendor's conditional −0.200 ns lane-UFI min-delay is for a different registered-UFI mode, not a waiver to transplant. [T15:126790; S/IP.sdc:753–758; S/IP_ip_parameters.tcl:108]

## One finite next datum, not another blind full fit

**Obtain the effective Fitter-stage hold-uncertainty/overconstraint record for exactly `P|emif_1_core_usr_clk` → `P|emif_1_phy_clk_l_0`, from Work15's retained native design and consumed generated SDC.**
The record must identify: resolved same-/multi-tile branch, effective hold uncertainty, C2P_HOLD_OC_NS, and whether that parameter has a supported editable IP-source control (name and legal domain). The generated variable's existence is not proof of a public IP parameter.
This is one clock-transfer contract, not another full constraint review. A final-STA-only `report_sdc` or a mock Tcl calculation cannot establish a Fitter-only objective; T15:214149 itself points to native `report_sdc` for effective uncertainties.
No such Fitter-stage record appears in the supplied final path, FIT settings/retiming tables, or finalize report; hence this report does **not** emit an executable guessed assignment.
If it establishes a supported strictly greater fit-only objective, the next full fit can be one controlled objective change with seed2 and the physical/IP configuration preserved. It must not overwrite a stronger existing objective.
The measurable test is an increased **Fitter** hold requirement, followed by changed launch-clock arrival and/or Hyper→UFI data delay, with unchanged signoff exceptions and signoff uncertainty.
Falsification: if the stronger objective is demonstrably consumed but the same locations/arcs remain 2.964/2.968 ns under original signoff constraints, that objective did not fix this forced boundary; do not escalate into a margin/seed sweep.
An unchanged objective means the attempted experiment was ineffective, not that the path is intrinsically unfixable. An improved requirement-only/slack presentation without physical improvement is not closure.

## Preserved integration scope

Work15's sole functional delta from Work14 is the four-line PCIe generated-clock correction, not an EMIF modification. [clock-delta.diff:7–13](clock-delta.diff); [iteration authority:7–9](ITERATION-AUTHORITY.md)
Retain the existing board/device/speed grade, clocks, two 16 GiB x64 DDR channels, memory geometry/interfaces, PR and PF1 BMC. The existing MSA integration and disabled-UART identity correction are not new hold remedies.
Reuse the completed [earlier source review](../emif1-hold-source-review-01/REPORT.md:13–27), which found no exact remedy. A narrow new documentation fetch for clock uncertainty returned navigation/loading content, not usable command-body evidence; no support claim rests on it.
Only this recommendation was written. No source changes, tests, vendor/native/remote execution, hardware access, waivers, git operations or task closure were performed.
