# Work23 independent completed-result review32

**ACCEPT the completed native implementation/assembly as evidence with findings. REJECT numerical timing and deployment. Seed3 did not repair the exact Work22 seed2 hold failure; stop blind seed iterations.**

Reviewer: **gpt-6-astra-900k / openai-codex**, substituted for unavailable GLM5.3; no GLM review is claimed. Only local captures, read-only source inspection and in-memory Python parsing/hashing were used. No SSH, vendor/device tools, source-script/test execution, implementation or Git changes. Only this report is written.

## Evidence and completion

Paths are relative to `qualification/fim-build-23`. **F/T/TS/D** denote `timing22-readback/output_files/ofs_top.{fit.rpt,sta.rpt,sta.summary,tq.drc.signoff.rpt}`; **S** is `synthesis15-readback/ofs_top.syn.rpt`. **C** is `completion24-readback/qualification/fim-build-23/operations/compile`; **W** is `completion24-readback/work_ia840f_fim_23/syn/board/ia840f/syn_top`. References use original line numbers; W22 equivalents are identified by `../fim-build-22/timing-review49.md`.

Independently verified **36/36** frozen sizes/hashes, including **4 synthesis, 9 timing and 11 completion members**. All three compressed archives match their collection receipts; every decoded member equals its readback. Freeze SHA256: `cb6a007da174fdb3aa743bc3d7cfbdbaaf030d45f0a38a4548a818f3797972aa`. Reverified W22 timing/synthesis captures and consumed timing-review49. `completion-metadata31.json` exactly projects the completion archive and terminal status.

The supplemental `preservation34.json`/receipt/archive/producer hashes also agree: at **20:27:31Z**, the named **1,891 SOURCE/PIM bindings, 3,963 original Work22 inputs including modes/links, four images and static QDB** passed. This supplements—not modifies—the freeze; it is not whole-tree preservation.

`C/status.json` records completed native/CMake/effective **0/0/0**, no timeout, rejection, residual owned group or postflight error. `compile07-completion-event.json` records **outer0**. All **15** captured gate events accept; completion captured no active vendor process. Full compilation and assembly succeed (`C/native.log:11223–11234`; `W/output_files/ofs_top.asm.rpt:170–174`). Tool success is not timing signoff (`T:2774–2791,214261,214941`).

## Experiment and persistent failure

Actual seed **3** is `F:177`; completed QSF equals the reviewed candidate. The sole physical-setting delta remains seed2→3: unchanged **3.000ns target, floorplan, effort, bit243 retiming-OFF, snapshots and fit-only10ps/STA-skip** (`EXECUTION-ACCEPTANCE11.md:7–17`; `W/ofs_top.qsf:128–136`). Native applied/skip markers confirm the distinction (`F:42236,42466–42601`; `T:214098`). Snapshot commitments exist (`F:42468,42572,42595,42602,42608`); this review does not establish stage-of-onset timing.

The literal EMIF1 launch suffix `hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]` and capture suffix `io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1` retain their full hierarchy, core-user/PHY-l0 clocks, **No SDC Exception on Path**, and zero hold relationship in every corner:

| Corner | W23 = W22 slack, ns | T path start |
|---|---:|---:|
| Slow vid2 100C | +0.132 | 21020 |
| Slow vid2b 100C | +0.167 | 51470 |
| Fast vid2a 0C | +0.047 | 81900 |
| Fast vid2a 100C | +0.006 | 112336 |
| Fast vid2 100C | **−0.004** | 142770 |

At the failing corner, arrival/required are **2.964/2.968ns**, data delay **0.288ns**, skew **−0.080ns** (`T:142777–142811`). Summary TNS is **−0.004ns**, with one failing endpoint (`TS:95–98`; `T:2861`). The multicorner repeat at `T:173555` is not another independent failure.

### Exact comparison boundary

Reproduced all **49 ordered physical rows per corner**, comparing element identity, location, arc type, increment and total. Only the six literal `pll_inst~refclk_Duplicate|`→`pll_inst~refclk_Duplicate_3|` rows at **REFCLKINPUT_X172_Y0_N301** are paired (`seed-disposition30.json:5–47`). The initial raw-identity **false** in `timing-analysis28.json` is correct; `exact-path-row-delta29.json` remains intact.

**Do not widen that equality to every cell:** clock-distribution fanout changes **16025→15967** in every corner (`T:142840`; W22 T:142664). Reports are not byte-identical; unreported routes and Boolean/sequential equivalence are unproven. The launch remains **Hyper-Register X192/Y3**, through **UFI_X210_Y0_N355** to **IO12LANE_X184_Y0_N374**; fast COMP **−2.292ns** and clock IC **3.236ns** are unchanged (`T:142839–142849`). Retiming-OFF did not demonstrate removing the Hyper-Register.

The older W21 +0.082ns contrast remains **0.084ns COMP + 0.002ns IC**, not isolated tool-defect proof (`reference-clock-compensation18.json`). No mechanism research or further run is undertaken here.

## Complete timing/clock coverage

Parsed **all 788 Type records**, matched their canonical fields to analysis28 and their values to native tables: **132 conventional + 656 skew/net-delay**, with exactly one negative record. No absent TNS was fabricated.

| Category | Records | Minimum slack, ns |
|---|---:|---:|
| Setup / Hold | 18 / 18 | +0.069 / **−0.004** |
| Recovery / Removal | 11 / 11 | +0.278 / +0.143 |
| Minimum pulse width | 74 | 0.000 |
| Max skew, five corners | 102 each | +1.177 / +1.183 / +1.287 / +1.264 / +1.259 |
| Net delay | 146 | +1.044 |

Sources: `TS:5–2631`; `T:2825–3726`. All skew/net-delay constraint identities remain; numerical margins change. Net-delay's new worst is control-shadow FIFO, not W22's RX FIFO (`T:3581`). Zero displayed margin is not positive margin.

All **81 clock rows** equal W22 (`T:2685–2765`). Board PLL remains **1410MHz VCO**, seven outputs **470/100.714286/235/705/50.357143/117.5/352.5MHz** (`F:6638–6706`); PCIe divider remains **19.858ns** (`T:2754`). These are not seven active sys-PLL domains or runtime measurements.

## Findings retained, including actual deltas

- **Constraints:** unchanged **117 ignored/overridden and 59 empty-filter rows**; four fully overridden PCIe multicycles and unmatched `mem_ss_inst` remain (`D:4488,4499,4510,4521,4525,4604`). Missing/invalid-clock and PLL-setting rules remain zero (`D:154–158`). Reserved TDI/TMS/TDO and `bwbmc_bmc_irq` remain unconstrained, **78/10** input/output pairs per setup/hold (`T:214974–214979,215077–215108`). This is not clean coverage.
- **DRC is not identical:** **23/88 failed, 4,380 overlapping violations, zero waived**, versus 4,382. Complete per-rule comparison finds CDC-50001 **13→14**, FLP-40006 **14→15**, TMC-20604 **7→3** (`D:123–214`). The added high-severity row is AHLS MMIO command-FIFO `in_wr_ptr_gray[0]`→`write_crosser|sync[0].u|din_s1`, reason **User-specified** (`D:237`); another timeout row changes its fitted duplicate name (`D:235`). Neither is silently waived.
- **Reset:** LNT-30010 totals are now **1,836 asynchronous / 122 synchronous / 56 enable loads** (`D:4842–4846`). Additional reset-sequence cycles change user-PLL outclk1 **4→6**, PCIe rx_ch15 **4→3**, internal oscillator **2→0** (`F:39620,39623,39690`; W22 F:39570,39573,39640). These are not total reset widths; positive recovery/removal does not qualify the sequence.
- **Pins/PR:** complete input/output/bidirectional/package-pin tables equal W22. Four electrical-warning pins remain (`F:6997–7000`). `green_region` and its floorplan survive; all **1,077** dangling rows, including `pr_freeze_to_afu`, are unchanged (`F:260,269–1347,38718`). Critical20727/19854 remain (`F:41786`; `S:131412`). Carry consumed PR initialization/freeze and PIM16803 findings, not a new review campaign.

## Warning accounting and bounded disposition

Synthesis's **494 ordinary + one critical** records match W22 after only literal WORK-root and clearbox-PID **293579→302961** pairing. Its 81-warning footer covers later mapping records; 413 earlier ordinary records remain (`S:123851–131493`; comparisons16/17). Fitter has **207 ordinary + one critical** versus footer209: **one unresolved count gap**, as before. STA **189+2=191** reconciles. Assembly's one warning is legacy GENERATE_RBF_FILE **20536** (`W/output_files/ofs_top.asm.rpt:167`). Full-flow896 numerically equals **495+209+191+1**, without resolving that fitter gap or double-counting hook/report copies.

Recorded, **not programmed**, SOF: **7,843,324 bytes**, SHA256 `6d149d05ec82587f4f61e0e78ba470d3058da0f1263b2d339ecaea7d61c374c9`. FME **c39acdc5-cde0-5256-ae78-1ae9a71266e6** agrees across text, build metadata and MIF; these are captured artifact identities, not hardware readbacks.

**No further blind seed compile, waiver, margin inflation, programming or hardware acceptance follows.** The persistent hold failure blocks deployment. Existing user-approved nonblocking findings are not retroactively new offline-fit gates; changed DRC/reset observations remain explicit unresolved findings. Persona compatibility, electrical behavior, PR initialization/freeze and migrated card/DDR tests remain unaccepted. Preserve the Phase4 placement/seed disposition without causal overclaim (`../../GOAL-PROMPT-MIGRATION.md:192–229`).
