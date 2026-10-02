# CPA clock topology: Work21 versus Work23

**Finding:** the core-feedback clock tree changes substantially, but its local return tap and the critical launch site do not. The PHY feedback route is unchanged. The most concrete implementation lead is the changed terminating spine; the most localized alternative is the launch-only clock branch. Neither is a demonstrated repair.

Read-only local review by **gpt-6-astra-900k / openai-codex**, substituting for unavailable GLM5.3. No native execution, source/test execution, SSH, implementation or hardware access.

## Evidence key and comparison

Paths below are relative to `qualification/`:

- **R21/R23:** `fim-build-23/{cpa-work21-46,cpa-feedback41}/result-readback/reports/`; **C** means `core_feedback-rise-minimum.rpt`, **A** means `anchor-hold.rpt` within those directories.
- **F21:** `fim-build-21/final-capture01/ofs_top.fit.rpt`; **F23:** `fim-build-23/timing22-readback/output_files/ofs_top.fit.rpt`.
- **N:** `router-native-capability-01/remote-evidence/agilex7-fit-names.txt`.

Parsed all **16** explicit-polarity reports, comparing ordered location, element, type, RF, fanout, increment and total, not just extrema. All are final-snapshot **Fast vid2 100C** observations. Core endpoints are EMIF1 `io_tiles_wrap_inst|io_tiles_inst|tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]` → `pa_core_clk_in[0]`, both `TILECTRL_X172_Y0_N298`. The downstream physical suffix `__core_clk_out[1]` does not change the logical output index. [R21/C:7–22,65–66; R23/C:7–22,65–66]

| Raw propagation, ns | Work21 min/max | Work23 min/max |
|---|---:|---:|
| Core rising | 3.479 / 3.857 | 3.478 / 3.853 |
| Core falling | 3.458 / 3.834 | 3.455 / 3.829 |
| PHY rising | 1.166 / 1.356 | 1.166 / 1.356 |
| PHY falling | 1.166 / 1.355 | 1.166 / 1.355 |

Native witnesses: each R21/R23 `core_feedback-{rise,fall}-{minimum,maximum}.rpt:32–55` and `phy1_upstream-{rise,fall}-{minimum,maximum}.rpt:30–53`. These are selected propagation extrema, not CPA detector-reference-plane measurements or its production compensation equation.

## Three physically distinct branches

### 1. Core global network and feedback return

All four core reports per fit retain the same location/type/fanout sequence. Work21 has **58 rows**, Work23 **57**. Ordered routing shows:

- DCM ingress changes `DCM_mux_X198_Y2_N0_I27` → `I29`; rising-minimum increment **0.087 → 0.091ns**.
- Work21 climbs the **X226** clock column to **Y166**, returns to Y84, crosses **X171→X117**, descends to Y43 and returns through **X171**. Work23 instead climbs **X171** to Y166, returns to Y84, crosses **X226→X280**, descends to Y43 and returns through **X226**.
- Both reach the X198/Y23 spine and X198/Y3 sector mux, but spine-tap indices **I66/I2 → I33/I1**, with tap fanout **24→20**. The output CELL fanout is **15973→15967**. Rising routes retain seven RF/FR inversion pairs; falling routes reverse their polarity order, preserving FF endpoints.
- Both finish through `SCLKMUX_RE_X198_Y3_N188_I38`, `ROWCLK_TAPOFF_X196_Y3_N0_I5`, `GLOBAL_LOCAL_SEL_X196_Y3_N0_I3`, `RPII/RPI_X196_Y3_N0_I51`, then the same periphery return resources. **The feedback tap has not relocated.**

[R21/C:66–122; R23/C:66–121; corresponding falling reports, same line ranges.]

The native **Place-stage** global-clock panel corroborates terminating spine **2→1**, source-to-tree length **4.0 sector wires** unchanged, layer jumps **2→1**, and tree length **6.5** unchanged. Both cover **56 sectors**, `(11,3)`–`(386,330)`, owned by `root_partition`. Its fanout **16068→16045** is a different stage/view from final STA’s CELL fanout; do not equate them. [F21:31118–31133; F23:31195–31211; stage labels F23:37–41]

### 2. Launch-only branch versus feedback tap

Within each fit, feedback rising-minimum and anchor launch clock share identical incremental fields from the output CELL through `SCLKMUX_RE_X198_Y3_N188_I2` (Work21) or `I1` (Work23). They then diverge: feedback samples **X196/Y3**, whereas the launch clock goes through **X192/Y3** and `DELAY_CHAIN_X192_Y3_N0_I0` (**0.285→0.286ns**) into the Hyper-Register. Even shared `I38` has different branch increments, **0.010ns feedback versus 0.021ns launch**. [R21/C:66–122, A:104–164; R23/C:66–121, A:104–163]

Summing the printed post-common-prefix increments gives feedback **0.163ns** in both, versus launch **0.410→0.409ns**: differential **0.247→0.246ns**. This is a route-local comparison, **not a CPA formula**. A shared-trunk change need not deliver useful relative skew; a launch-only physical change targets a different quantity.

The data transfer remains Hyper-Register `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`, with identical **0.288ns** delay. Required **2.968ns** is unchanged. The slack **+0.082→−0.004ns** separates into CPA COMP **−2.208→−2.292ns** and launch routing **3.238→3.236ns**. Routing-detail IC placeholders are not additional delays. [R21/A:44–75,103–176; R23/A:44–75,103–175]

### 3. PHY feedback is not the capture branch

All four PHY comparisons have **seven identical ordered rows**, including fanout and RF. They begin at EMIF1 `pll_inst|pll_inst|lvds_clk[0]` at `IOPLL_X172_Y0_N303`, pass through `IO48PHYCLK_X172_Y0_N302`’s `phy_rxclk_to_btm`, `phy_rxclk_match_btm`, `phy_clk_out_2[1]`, `fbclk_pa[1]`, and end at CPA `pa_fbclk_in[1]`. This local matching path is distinct from capture distribution through **IO48PHYCLK_X185_Y0_N302** to the X184 lane. Neither measures the board-reference-to-detector path. [R21/R23 `phy1_upstream-rise-minimum.rpt:62–68`; other PHY reports:61–68; R23/A:202–212]

## Ranked intervention hypotheses and discriminators

1. **Directed spine selection, preserving coverage.** Target the native EMIF1 global source suffix `core_clks_from_cpa_pri_nonabphy[0]`, not guessed DCM resource assignments. `CLOCK_SPINE` and `CLOCK_REGION` appear in the native Agilex7 fitter-name list [N:171–172]. The changed spine is a concrete candidate for implementation-dependent CPA behavior, **not proof of causation**. First establish documented object/value semantics with lane03; report index “2” is not automatically a legal assignment value. Intended effect: change distribution/feedback implementation and possibly CPA response, not frequency; its sign is unknown. A future approved single-control experiment should verify actual spine/route change, both feedback extrema and launch branch, COMP and unchanged multicorner signoff requirements. No full CPA reconstruction is a prerequisite.

2. **Launch-local placement/clock-distribution change.** Target the exact X192/Y3 Hyper-Register branch, not the fixed I/O lane or whole EMIF. Seek a documented control applicable to this generated EMIF register; `LOCATION` is listed [N:4], but that alone does not establish legal alternative sites. Intended effect is additional early launch arrival relative to feedback/capture, without changing cycles or clocks. First discriminator: supported placement/control applicability and resulting branch movement. Existing retiming-OFF did not remove this Hyper-Register; effective precedence against vendor force remains unproved. Removing its clock delay would worsen hold, all else equal; the pin-oriented Delay Chain Summary does not expose this internal clock-chain setting. [R23/A:152–175; F23:38825–38828; `fim-build-23/result-review32.md:35–39`]

3. **Consumer placement or clock-region refinement—conditional, lower priority.** F23 explicitly expands this clock across downstream PR regions and mentions Clock Region override [42499–42500]. Do not infer that presently clustered consumers permit truncating reserved PR clock coverage. Establish legal PR clock delivery before any region proposal; otherwise retain the full region and investigate only within-boundary placement. No geometry change is authorized.

4. **PHY/periphery relocation—deprioritize.** Unchanged PHY feedback and capture paths provide no observed routing discriminator. Preserve both DDR banks, pins and PLL contract rather than perturbing them speculatively.

## Geometry and stopping boundary

Actual PR placement rectangles remain **X301/Y0–X390/Y20; X101/Y21–X390/Y100; X0/Y101–X390/Y333**; routing spans **X0/Y0–X390/Y333**. The X192/Y3 launch lies outside those PR placement rectangles; global clock routing through their footprint is not evidence of illegal static placement. Static **90320 ALM** versus PR **822480 ALM** capacities do not prove congestion. Both fits report no short-wire hotspots above 100%; this is not complete local congestion clearance. [F21:38498,38562–38563,39371; F23:38718,38782–38783,39328–39335]

Work22/23 seed2/3 already retain the same five slacks and reported critical locations/delays after one explicit refclk alias pairing, **but fanout changes 16025→15967**; do not claim whole-tree equality or repeat blind seeds. [`fim-build-23/result-review32.md:23–39`]

No further broad clock report is warranted: `report_clock_network` expands fanin/fanout and `initial_depth` only collapses GUI rows [`fim-build-23/cpa-help36/readback/help.log:145–166`]. Use existing evidence and lane03’s control documentation first. Preserve **3.000ns EMIF clocks, DDR/PR boundaries, tool/device contract and no waivers**. Physical differences and software version are confounded; neither a compiler-only cause nor vendor-only remedy is established.
