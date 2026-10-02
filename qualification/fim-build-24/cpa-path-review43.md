# Work24 — exact-transfer / CPA path review43

**Verdict: the supported physical intervention closes the exact bit243 defect on Quartus26.1.1 Build130, seed3, AGFB027R25A2E2V under unchanged timing requirements.** This is path-level physical/STA acceptance, not deployment or migration completion.

Reviewer: **GPT6 / openai-codex**, substituting for unavailable GLM5.3. Local read-only files and in-memory Python only; only this report written. No implementation, native query, repository scripts/tests, SSH, Git or hardware.

## Evidence and unchanged contract

Rehashed **41/41** [physical-result-freeze41.json](physical-result-freeze41.json) members: all sizes/SHA256s match. Independently decoded and matched Work23/24 timing captures and completion/input bindings; Work21 STA/Fitter match `final-capture01/manifest.json`. Reproduced `exact-transfer36.json`'s complete properties/eight-column paths and comparison40's five-corner claims, rather than trusting their verdicts. [S21]/[S23]/[S24] and [F21]/[F23]/[F24] denote raw STA/Fitter reports; preparation members also match review-freeze01/capture bindings.

The bound predecessor/prepared inventories reconcile **170 changed entries = 169 root relocations ∪ two overlays**, with the gate file overlapping; **no RTL or SDC member changed**. [Candidate QSF](candidate01/ofs_top.qsf) adds only the spine/full-region records (lines141–143); top.sdc is byte-identical. All **3,387 WORK critical-input hashes** match completed inventory; postflight reports no errors ([native status]:91,137,3549). Its only two inventory-content changes are recorded FME metadata outputs. This supports purity of the bound inputs, not an unrecorded whole-tree claim. The inherited fit-only10ps objective remains skipped in final STA (S24:214046; [candidate SDC]:151–165), not a new margin/latency waiver. Both relevant generated clocks retain **3.000ns**, rise0/fall1.500 (S21:2729,2733; S23/S24:2730,2734).

## Implemented allocation, not just intent

F24:31392–31408 identifies the exact EMIF1 `core_clks_from_cpa_pri_nonabphy[0]`, source **TILECTRL_X172_Y0_N298**, terminating spine **2**, **SX0 SY0 SX6 SY7**, and **root_partition** ownership. F23:31195–31211 used spine1; F21:31118–31134 used spine2. Target wirelength remains10.5 sectors; layer jumps increase1→2 versus W23. F23/F24:177 confirms seed3; F21:173 used seed2, so historical equality is not a controlled version-only comparison.

Across **44 exact-name blocks**, **32 spines change including the target (31 collateral)**. PCIe's two spine2 occupants move to17/12; DDR0 reference coverage contracts two sectors→one; both reset-anchor FF sites move (F23:31451–31466,31547–31562,31759–31792,31844–31859; F24:31648–31663,31744–31759,31956–31989,32041–32056). This is not single-net-only routing.

## Exact transfer and quantitative reconciliation

The exact common prefix is `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|`. From suffix: `hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`; to suffix: `io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`.

Each build has five corner records plus one identical aggregate repeat. All report **No SDC Exception on Path**, the same core-user→PHY-low clock pair and zero hold relationship. Raw starts below cover through **start+116**, including every timing row. All times are ns unless marked ps; W24 values equal W21 at printed precision.

| Corner | Hold slack W23→W24=W21 | ΔCPA, ps | Launch IC W23→W24=W21 | Data delay | Required | Raw starts S21/S23/S24 |
|---|---:|---:|---:|---:|---:|---|
| Slow vid2 100C | .132→.242 | +96 | 4.108→4.122 | .400 | 3.682 | 5100/21020/21017 |
| Slow vid2b 100C | .167→.272 | +83 | 3.813→3.835 | .400 | 3.325 | 35550/51470/51450 |
| Fast vid2a 0C | .047→.118 | +56 | 2.519→2.534 | .253 | 2.419 | 66008/81900/81879 |
| Fast vid2a 100C | .006→.086 | +72 | 2.943→2.951 | .276 | 2.810 | 96446/112336/112299 |
| Fast vid2 100C | −.004→.082 | +84 | 3.236→3.238 | .288 | 2.968 | 126875/142770/142714 |

Python Decimal reconciliation gives **Δslack = ΔCPA + Δlaunch-IC = [110,105,71,80,86]ps**. No data increment changes. Launch/UFI/capture remain **BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32 / UFI_X210_Y0_N355 / IO12LANE_X184_Y0_N374**. In corner order, uTco is [.093,.091,.054,.060,.063], uTh [.453,.459,.303,.336,.342]; uncertainty is .030 throughout. Required clock paths, PLL compensation, pessimism removal and advanced-clock effects are unchanged. At the failing corner arrival **2.964→3.050**, required **2.968**, so **+84ps COMP +2ps IC** explains the entire86ps recovery—not inserted data delay (S23:142839–142886; S24:142783–142830).

**Complete arc-field differences:** W23→24 changes only CPA/launch-IC increments, their propagated Totals, and CPA output-CELL fanout **15967→15948**; required rows have no differences. CPA/output-CELL Totals increase by ΔCPA; launch and subsequent data Totals increase by Δslack. W21→24 differs only in that fanout **15973→15948** and six refclk Element aliases per corner: `pll_inst~refclk_Duplicate`→`pll_inst~refclk_Duplicate_3`, paired only at **REFCLKINPUT_X172_Y0_N301**, pins `ref_clk_in`, `ref0_to_btm`, `clk_out`, in both roles. All other ordered fields match; no wildcard normalization (S21:5157–5170,5193–5195; S24:21074–21087,21110–21112). Fitter fanout is a different report quantity: **16068/16045/15962** for W21/23/24, not the STA output-CELL fanout.

## Both CPA compensation roles

Indexed every exact `tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]` COMP appearance: **1100/1099/1102** in W21/23/24, including repeats. Grouping uses each path's **Worst-Case Operating Conditions**, never a stale Delay Model heading. Every group has one value at TILECTRL_X172_Y0_N298, RR. **H = hold-arrival = setup-required; S = setup-arrival = hold-required.** Recovery/removal were retained separately, not misclassified.

| Corner, same order | H W23→W24=W21 | S W23→W24=W21 | W24 raw lines HA/SA/SR/HR |
|---|---:|---:|---|
| Slow vid2 100C | −2.810→−2.714 | −2.397→−2.450 | 21086/19833/22383/23673 |
| Slow vid2b 100C | −2.603→−2.520 | −2.224→−2.282 | 51519/50266/52816/54106 |
| Fast vid2a 0C | −1.735→−1.679 | −1.474→−1.514 | 81948/80695/83245/84535 |
| Fast vid2a 100C | −2.061→−1.989 | −1.766→−1.802 | 112368/111115/113665/114955 |
| Fast vid2 100C | −2.292→−2.208 | −1.966→−1.997 | 142783/141530/144080/145370 |

Old S-arrival anchors: S21:3916,34366,64824,95262,125691; S23:19836,50286,80716,111152,141586. Reverse-role confirmation at the last corner: S21:128241,129531; S23:144136,145426. The role separation contracts **[413,379,261,295,326]→[264,238,165,187,211]ps**. Opposite-sign H/S changes rule out one rigid phase constant; both roles, not just the failing hold term, return to W21's printed values.

## Mechanism and limits

Retained feedback reports independently reproduce W21→W23 core rise/fall min/max changes **−1/−4/−3/−5ps**, with PHY rows unchanged ([R21]/[R23], `core_feedback-*.rpt`:49–50; `phy1_upstream-*.rpt`:48–49). Those raw extrema are not the production CPA equation: core output→return and PLL-lvds→PHY-feedback have different reference planes. **Work24 feedback-route timing is not captured here**; equal COMP does not prove equal feedback routes, calibration state or detector settings.

The same-version supported allocation change plus unchanged requirements and positive exact-path STA establishes a successful physical correction. It does **not** uniquely attribute recovery to one wire, prove a version-only CPA-model bug, reconstruct the CPA algorithm, or measure silicon margin. No additional native feedback sweep is needed to accept this supported path fix. Whole-summary **788/788 nonnegative**, including four rounded zeros, is not positive physical margin everywhere; broader signoff/electrical/PIM/hardware gates remain separate.

[S21]: ../fim-build-21/final-capture01/ofs_top.sta.rpt
[S23]: ../fim-build-23/timing22-readback/output_files/ofs_top.sta.rpt
[S24]: timing32-readback/output_files/ofs_top.sta.rpt
[F21]: ../fim-build-21/final-capture01/ofs_top.fit.rpt
[F23]: ../fim-build-23/timing22-readback/output_files/ofs_top.fit.rpt
[F24]: timing32-readback/output_files/ofs_top.fit.rpt
[native status]: completion34-readback/qualification/fim-build-24/operations/compile/status.json
[candidate SDC]: candidate01/top.sdc
[R21]: ../fim-build-23/cpa-work21-46/result-readback/reports/
[R23]: ../fim-build-23/cpa-feedback41/result-readback/reports/
