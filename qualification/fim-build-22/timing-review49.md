# Work22 independent completed-fit / STA review49

## Disposition

**REJECT Work22 numerical timing and deployment. ACCEPT the captured Fitter completion as a completed implementation with findings, not as a timing pass. A fresh Work23, seed 3 only, is technically eligible as the next bounded offline trial under the user's Phase 4 authority; success is not predicted.**

The exact EMIF1 bit243 transfer again fails hold by **−0.004 ns**, TNS **−0.004 ns**, at **Fast vid2 100C**. All five detailed corner reports retain the same endpoints, clocks and **No SDC Exception on Path**. The native clock table is unchanged from Work21. The apparent net-delay discrepancy is resolved: **144 retained constraint identities + two generated debug-FIFO constraints = 146**, all passing; the minimum is **+1.022 ns**, not the old +1.024 ns.

`GOAL-PROMPT-MIGRATION.md:192–205` explicitly treats this repeat marginal result as a **placement/seed outcome, not a defect**, permits bounded refits, and forbids margin inflation, new exceptions and waivers. That project-specific direction governs this disposition; the repeated values do not justify substituting a tool downgrade or a new subsystem. The proposed successor is an experiment, not a demonstrated repair or hardware authorization.

## Scope and evidence binding

Only local immutable captures, source text and in-memory Python parsing/hashing were used. No SSH, workstation/device operation, vendor tool, source script/test, Git mutation or implementation edit was performed. Only this report was written. Reviewer: **gpt-6-astra-900k / openai-codex**; requested GLM5.3 was not selectable in this runtime, so no GLM review is claimed.

Paths below are relative to `qualification/fim-build-22` unless stated otherwise:

- **T / TS / F / D** = `timing47-readback/output_files/ofs_top.{sta.rpt,sta.summary,fit.rpt,tq.drc.signoff.rpt}` respectively. Citations are original native line numbers.
- **I** = `candidate01`; its QSF and SDC were independently matched to the exact WORK22 keys in `compile-inputs31.json`.
- **T21** = `../fim-build-21/final-capture01/ofs_top.sta.rpt`; **T18** = `../fim-build-18/reports01/output_files/ofs_top.sta.rpt`. Comparison STA/summary/Fitter/DRC files actually used from Work21 and STA from Work18 were rehashed against their original manifests, not accepted by filename alone.

The `timing47` acquisition is timestamped **2026-10-01T18:14:36.357049+00:00**. All **nine** local members match their captured sizes, SHA256 and decoded base64 bytes. The compressed result matches `timing47-collection.json:10–13` (collector outer rc0, success, bytes and SHA256). This is acquisition success, **not** full-flow native/effective/outer completion. These nine files contain no assembly report or terminal full-flow status; the parent collects those separately. No full-build exit is inferred here.

## 1. Completed implementation versus failed timing

- `ofs_top.fit.summary:1–20` identifies successful Fitter, **Quartus 26.1.1 Build130**, **AGFB027R25A2E2V**, final timing models, **66,395 / 912,800 ALMs (7%)**, 177,887 dedicated registers, 302 RAM blocks, 12 DSP blocks and eight PLLs. This is Work22 scalar-AFU FIM utilization, **not CAPS03 persona utilization**.
- `F:42777–42784` records final database committed and Fitter successful, **0 errors / 209 warnings**, processing ended **11:08:14**. The summary's timestamp is 11:08:11; neither timestamp establishes completion of later stages.
- `T:214739–214743` records Timing Analyzer execution successful, **0 errors / 191 warnings**, ended **11:11:45**. Nevertheless, **Critical332148** at `T:214039`, DDR critical warning at `T:214719`, and the closure panel at `T:2774–2791` explicitly report timing/hold/DDR failure. A zero-error tool execution is not signoff.
- As a warning-accounting limitation, parsing all severity-prefixed Fitter messages, including indentation, finds **207 ordinary + one critical** record versus the native footer's 209 warnings; that difference is not reconciled by these captures. STA's **189 ordinary + two critical** records do match its 191 footer. No clean-warning claim or invented total is made.

### Every TS Type block accounted for

Independent parsing recovered **788 records**, matching every `Type` line and the parent's `timing-summary-parsed48.json` row-for-row. **132 conventional records** contain Corner/TNS; **656 skew/net-delay records** contain only Type/Slack. No records were discarded for lacking Corner, and absent TNS was not converted to zero. The native T conventional, skew and net-delay tables independently agree with TS.

| Category | Records | Minimum slack (ns) | TS lines |
|---|---:|---:|---|
| Setup | 18 | +0.053 | 5–93 |
| Hold | 18 | **−0.004** | 95–183 |
| Recovery | 11 | +0.266 | 185–238 |
| Removal | 11 | +0.039 | 240–293 |
| Minimum pulse width | 74 | 0.000 | 295–663 |
| Max skew — Slow vid2 100C | 102 | +1.174 | 665–969 |
| Max skew — Slow vid2b 100C | 102 | +1.176 | 971–1275 |
| Max skew — Fast vid2a 0C | 102 | +1.289 | 1277–1581 |
| Max skew — Fast vid2a 100C | 102 | +1.252 | 1583–1887 |
| Max skew — Fast vid2 100C | 102 | +1.246 | 1889–2193 |
| Net delay | 146 | +1.022 | 2195–2631 |

There is exactly **one negative summary record** and **one failing hold endpoint** (`T:2861`); the other 131 conventional TNS cells are 0.000. The two negative detailed-path headings (`T:142594,173357`) are the corner path and its repeated multicorner worst path, not two independent failures. Zero displayed hold/MPW slack elsewhere is not positive margin.

Global recovery/removal minima above are **not bank0 margins**: bank0 `emif_0_core_usr_clk` has **+1.262 / +0.175 ns**, bank1 **+1.162 / +0.179 ns** (`TS:195–203,270–283`). Do not copy Work21's reset margins or load counts into this build.

## 2. Exact EMIF1 recurrence, all five corners

Use the literal prefix `P = local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|`:

- Launch: `P` + `emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`.
- Capture: `P` + `emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`.
- Launch clock: `P` + `emif_1_core_usr_clk`; latch clock: `P` + `emif_1_phy_clk_l_0`.

Each row below is a **Hold path #1**, with those identical endpoints/clocks, **No SDC Exception on Path** and **0.000 ns hold relationship**. Times are ns. The Work22 arrival/required/slack/skew/data-delay fields also match the independently read Work18 native details exactly at displayed precision.

| Corner | W22 slack (= W18) | W21 slack | W22 arrival / required | W22 skew / data delay | T summary/statistics lines |
|---|---:|---:|---|---|---|
| Slow vid2 100C | +0.132 | +0.242 | 3.814 / 3.682 | −0.215 / 0.400 | 20995–21019 |
| Slow vid2b 100C | +0.167 | +0.272 | 3.492 / 3.325 | −0.256 / 0.400 | 51403–51427 |
| Fast vid2a 0C | +0.047 | +0.118 | 2.466 / 2.419 | −0.127 / 0.253 | 81800–81824 |
| Fast vid2a 100C | +0.006 | +0.086 | 2.816 / 2.810 | −0.096 / 0.276 | 112201–112225 |
| Fast vid2 100C | **−0.004** | +0.082 | **2.964 / 2.968** | **−0.080 / 0.288** | 142601–142625 |

Historical matching summary starts: **T18** 5118,35554,65972,96383,126786; **T21** 5107,35557,66015,96453,126882. Work22's multicorner repeat is `T:173364–173388`. The custom EMIF report explicitly found ten hold paths, one violated (`T:142554–142581`); the later OFS hook likewise found one violated among its 20 reported paths (`T:214731–214736`). This closes the question of whether only a similarly named summary clock recurred.

All five Work22 physical details retain the launch as **Hyper-Register** at `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32`, through **UFI_X210_Y0_N355** to **IO12LANE_X184_Y0_N374**. See `T:21059–21067,51467–51475,81864–81872,112265–112273,142665–142673`. The exact bit243 retiming-OFF assignment is present in bound `I/ofs_top.qsf:136`; **it did not demonstrate forcing the launch out of a Hyper-Register**. This report makes no unsupported claim about effective assignment precedence or the causal reason for the repeated slack.

### Fit-only objective really applied; signoff really skipped it

- Bound `I/top.sdc:151–165` has the executable guard, exact singleton clock checks, additive **10ps under quartus_fit only**, and the STA skip-only branch. The SDC is byte-identical to Work21's selected four-line-divider version.
- `F:42405,42635,42644,42648,42724,42737,42740,42760,42770` records **HOLD_MARGIN_APPLIED app=quartus_fit additive=10ps from_count=1 to_count=1**.
- `T:213876` records **HOLD_MARGIN_SKIPPED app=quartus_sta signoff_unchanged**. No hold waiver or extra signoff margin explains this result.
- Actual seed **2** and intermediate snapshots **On** are in `F:177,185`; `F:42637,42741,42764,42771,42777` records planned/placed/routed/retimed/final database commitments. This acquisition does **not** contain their separate timing analyses or a current snapshot-file inventory. Stage-of-onset localization remains unobserved here; preserve those snapshots for the user's Phase 4 comparison rather than inferring that only finalization caused the miss.

## 3. Realized clocks and precise coverage delta

### PLL and PCIe divider

`F:6638–6706` establishes the actual board PLL at `IOPLL_X12_Y333_N303`: reference **100 MHz**, **M=141, N=10, VCO=1410 MHz**, seven output-counter settings:

| Public output index | Fitted MHz | Native F line |
|---:|---:|---:|
| 0 | 470.0 | 6658 |
| 1 | 100.714286 | 6666 |
| 2 | 235.0 | 6674 |
| 3 | 705.0 | 6682 |
| 4 | 50.357143 | 6690 |
| 5 | 117.5 | 6698 |
| 6 | 352.5 | 6706 |

These match the accepted seven-output generated preset; there is no realized-set change requiring the Phase 3 stop. Do not replace them with nominal100/630 MHz or a five-output donor. Configured outputs and analyzed clock objects are distinct: the native table lists active `clk_sys`, `clk_100m`, `clk_sys_div2`, `clk_sys_div4` at **2.127,9.929,4.255,8.510 ns** (`T:2759–2762`), not seven active sys-PLL output-clock domains.

All **81 clock-table rows** (`T:2685–2765`) are equal to Work21 in every reported field after excluding line numbers—no clock addition/removal or altered source/master/period. Both EMIF core/PHY-l clock pairs retain **3.000 ns** (`T:2708,2712,2730,2734`). Separate user-clock outputs remain **3.200/6.400 ns, 312.5/156.25 MHz** (`T:2687–2688`); the campaign's 3.000-ns target must not be represented as every clock's realized period or a runtime measurement.

The selected **four-line** divider is bound at `I/top.sdc:35–38`, not the unselected guarded candidate. `T:2754` confirms `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|avmm_clock0`, Generated, **19.858 ns / 50.36 MHz**, divide-by2, master `sys_pll|iopll_0_clk_100m`, source `...|u_pciess_clock_divider|clkdiv_inst|inclk`, target `...|clkdiv_inst|clock_div2`. Its existence and incoming-clock relationship are established, not merely requested in source.

`D:154–158,175–176` reports **zero** missing/multiple/invalid generated/invalid clock/PLL-setting/invalid set-net-delay/invalid-clock-reference rule violations. `T:214752–214753` likewise has zero illegal or unconstrained clocks. These bounded negatives do not clear ignored exceptions or unconstrained I/O.

### Net delay: 144 → 146 is explained, not waived

A set comparison of `(Name, Required, From, To, Type)` across complete native tables retains **all 144 Work21 identities**, removes none and adds exactly two. All are `max`; common SDC origins differ only by the explicit `25.1.0` → `26.1.1` compiler-cache path segment. Added rows originate in `qdb/_compiler/ofs_top/_flat/26.1.1/source/1/.temp/cpt_proxy/alt_sld_fab_0_st_dc_fifo_1953_phmrs5y.sdc`:

| Added constraint | T line / SDC line | Required / actual / slack (ns) |
|---|---|---|
| Write-pointer crossing | 3657 / 34 | 3.200 / 0.268 / **+2.932** |
| Read-pointer crossing | 3704 / 35 | 7.943 / 0.271 / **+7.672** |

Literal native selectors (From → To):

```text
[get_pins -compatibility_mode {*|in_wr_ptr_gray[*]*}]
  → [get_registers {*|altera_dcfifo_synchronizer_bundle:write_crosser|altera_std_synchronizer_nocut:sync[*].u|din_s1}]
[get_pins -compatibility_mode {*|out_rd_ptr_gray[*]*}]
  → [get_registers {*|altera_dcfifo_synchronizer_bundle:read_crosser|altera_std_synchronizer_nocut:sync[*].u|din_s1}]
```

Both worst corners are Slow vid2 100C. Native SDC reading is recorded at `T:214011`; this is generated debug-FIFO coverage, not an added user hold exception.

The overall new worst is **PCIe RX CDC** `PCIE_LINK_CONN[0].rx_sb.pipe_rx|rx_cdc|fifo|dcfifo|dcfifo_component|auto_generated|*rdptr_g*` → its `ws_dgrp|dffpipe*|dffe*` selector: **required1.600 − actual0.578 = slack1.022 ns**, Slow vid2 100C, `pcie_ss.sdc:631` (`T:3581`). The same identity had +1.104 ns in Work21 (`T21:3578`). Work21's **overall +1.024 ns** was a different, **TX CDC delayed_wrptr_g → rs_dgwp** identity (`T21:3572`), now +1.104 ns (`T:3590`). Therefore comparing only 1.024→1.022 would obscure a change in which constraint is worst. Both tables pass; neither a missing-row failure nor new CDC-wide qualification is implied.

The complete **778→788 summary-count delta** is also reconciled:

- **Max skew500→510:** all100 old rows per corner retained as a multiset, plus two debug-FIFO rows per corner. Actual endpoints are under `auto_fab_0|alt_sld_fab_0|alt_sld_fab_0|mboxfabric|stream_0_clock_crosser_0|dc_fifo_0`, `out_rd_ptr_gray→read_crosser` and `in_wr_ptr_gray→write_crosser`; SDC lines44/40. Added slack pairs by corner are **3.019/7.727, 3.018/7.729, 3.058/7.768, 3.041/7.757, 3.041/7.755 ns** (`T:3090,3119,3200,3229,3310,3338,3420,3450,3530,3560`).
- **Net delay144→146:** the two rows above.
- **MPW76→74:** the two no-longer-reported summary records are the user-PLL and sys-PLL **`iopll_0_m_cnt_clk`** checks (`Work21 TS:665–673`). Both clocks still exist unchanged in `T:2685,2763`. This is a reporting/check-coverage difference, not clock disappearance; these captures do not establish why the tool no longer emits those MPW checks, and do not justify fabricating replacement results.
- Setup/hold/recovery/removal counts are unchanged. None of these count changes clears the EMIF1 hold failure.

## 4. Findings retained without broadening the seed trial

**Timing coverage is not clean.** `T:214748–214757,214855–214886` retains two unconstrained inputs (`altera_reserved_tdi/tms`) and two outputs (`altera_reserved_tdo`, **bwbmc_bmc_irq**), with78 input and10 output path pairs for each setup/hold analysis. `GOAL-PROMPT-MIGRATION.md:207–212` explicitly retains this and overlapping signoff/reset findings as disclosed nonblocking posture for this campaign. Preserve that scope: neither invent waivers nor turn these unchanged findings into a new source-approval gate for the authorized seed iteration.

**Exception correctness remains separate from clock existence.** All four PCIe multicycles at `top.sdc:58–61` are fully overridden (`D:4487,4498,4509,4520`), while the selected SDC groups the divider/master asynchronous at line52. The memory selector still uses `mem_ss_inst`, not the realized `mem_ss_sv|mem_ss`, and covers no paths (`D:4524,4603`; `T:213813–213814`). The duplicate SYS_REFCLK create is rejected, but the actual native `sys_pll|iopll_0_refclk` already constrains SYS_REFCLK (`D:4469,4676`; `T:2765,214768`). There are117 ignored/overridden constraints and59 empty-filter violations; zero invalid-clock rules does not mean all exceptions are effective. The small `ofs_top.sdc_constraints.rpt:14–30` contains only debug-QIP source records, not a complete effective-constraint audit.

**DRC/reset:** `D:123–214` has **23/88 failed rules, 4,382 overlapping rule-level violations, zero waived**; not4,382 unique defects. High failures are CDC-50001=13, CDC-50004=7, TMC-20027=5, RES-50001=4, CDC-50007=2, CDC-50012=2, CDC-50003=1. Examples remain protocol-checker FIFO resets and MSI-X reset crossings (`D:288–291`), insufficiently constrained control-shadow/FLR FIFO buses (`D:304–305`) and completion-timeout transfer (`D:332`). `D:4863–4867` has five LNT-30010 rows totaling **1,831 asynchronous-reset / 118 synchronous-reset / 56 clock-enable loads**, not the Work21 figures quoted in the goal. Positive recovery/removal is real but is not CDC/reset-sequence qualification. Ten signoff rules were disabled (`T:214724`).

**PR boundary, including a new fitted observation:** the reconfigurable `green_region` and its physical region survive (`F:260,38668,38678`); warnings15705/15706 at `F:42640–42641` do not prove region loss. Critical**20727** remains (`F:41955`). The complete dangling-input panel has **1,077** rows (`F:271–1347`):537 per DDR bank, two remote-STP inputs, and **new versus Work21: `pr_freeze_to_afu`** (`F:1347`; also `D:4445`). DRC BBD-60001 is therefore1,075, while BBD-60000=1,518 and BBD-60002=1,484 (`D:134–136`). These overlapping classes must not be summed into distinct ports. This strengthens—not closes—the existing finding that the scalar AFU's freeze tie-low and PR initial state are **not active-PR-qualified**. Carry Critical**19854** and the54 grouped initialization rows from the already consumed `synthesis-review39.md:40` / `synthesis-review-consumed41.json`; do not call them cleared by fitting or by a populated region.

**Electrical:** the Work22 I/O warning panel still names the three BMC pins with missing explicit termination/slew and default slew2, and now also **SYS_REFCLK missing input termination** (`F:6997–7000`). Work22 emits ordinary **25315** (`F:42010`), not the old Critical15714 label. This is not electrical acceptance, nor evidence that defaults are necessarily unsafe.

**Carried integration scope:** reuse synthesis's accepted-with-findings disposition; the separate PIM16803 targeted review is not duplicated or closed here. Preserve its interface/debug/BMC/consumer limitations. Both DDR generated geometries remain accepted generation evidence, not calibration/data-check evidence; no encrypted-vendor-internal review is reopened. `IP-GENERATION-ACCEPTANCE35.md:28–36` carries the21 fresh Work21-identical headers and malformed, **unconsumed** ASP collateral; no repair or new consumer qualification follows from this STA review.

## 5. Successor conditions and remaining acceptance boundaries

1. **Eligible bounded experiment:** fresh Work23 / seed3, with only the seed change plus necessary fresh-root, authorization/gate and generated-metadata bindings. Preserve Quartus26.1.1, selected sources/IP/board geometry, four-line PCIe SDC, unchanged3.000-ns target, exact bit243 retiming-OFF, intermediate snapshots and existing fit-only10ps/STA-skip behavior. No margin increase, new exception/waiver, clock retune or unrelated integration correction is justified by this report.
2. **Parent execution prerequisites remain:** retire/collect the existing Work22 terminal owner/status, bind exact fresh inputs/resources and single-use authority, and verify the actual launched process. Fitter completion alone does not establish that the full flow has exited. Work22 reports36 detected CPUs but an internal maximum24 (`F:249–250`); do not describe the QSF's36 as36 effective workers. This review supplies technical disposition, not a new execution credential.
3. **Required successor result:** real completed fit/STA, every Type block and the exact transfer in all five corners with No SDC Exception, unchanged clock/constraint coverage and fit-only/STA markers. Preserve before/after and snapshot-stage evidence, stay within the user's1–3-full-compile budget, and report a repeat failure honestly. A seed-only success cannot be assumed; no open-ended seed sweep is authorized here.
4. **Work22 remains undeployable:** negative hold must pass before any flashed image. Assembly/full-flow status is outside this capture; electrical, PR initialization/freeze/boundary, persona compatibility, outstanding integration findings and all card-bound tests are not accepted by this review. Unchanged disclosed nonblocking findings remain findings, not newly invented gates for the offline trial.
5. **New FME identity is recorded, not approved:** `fme-ifc-id.txt:1`, `build_env_db.txt:9` and reconstructed MIF words03:02 (`fme_id.mif:12–13`) agree on **c67b3296-1a3d-58f1-867c-df13480baf4c**. That is a build-data identity, not programmed hardware or accepted persona compatibility. The migrated-shell persona and hardware gates remain those in `GOAL-PROMPT-MIGRATION.md:214–229`.

## Exact SHA256 index

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `timing47-result.json.gz` | 5,772,247 | `35740a9f8363d59ce872b95cf5d6e9a02835fbf411b45c27cbdfec31f75033a9` |
| F | 19,902,976 | `988c6d0a931f51ad01d8ff0fd289ea6d7a9d1b433fa713f685d56f7e106bc10f` |
| `ofs_top.fit.summary` | 722 | `70dc9a096297e4d1f9afe04533b97289bfac244496b2b0f53995e753012f0496` |
| T | 49,418,329 | `78e671945877a284f68f4e81b31155156ef4164a022858861f463659b4546ce7` |
| TS | 61,017 | `67cd8a8604713d35ac09e94f91e711dc8fa6f6dd65e8a6e7fe308a8af6bcc7b6` |
| D | 832,522 | `352b061fba7a795e311924754bc1a5867967f8d2b00c645e17cd92b184eac4ab` |
| `ofs_top.sdc_constraints.rpt` | 2,746 | `d6a22e7c54227c2f6338c2aa23d927678602165e200c7195a06f2bf411ac26f7` |
| `build_env_db.txt` | 314 | `75802f961496597e119477588f51a1329e8c30182047572266d638b16a1e379e` |
| `fme_id.mif` | 361 | `a71c5e7ebe68392f4809cccf14bb8717e33013daeb1dd4a3db242c0a40a1a650` |
| `fme-ifc-id.txt` | 37 | `337b4af52cff50d351a1d219f161c798a70ffbf98124a212ee50b53b0605d180` |

Binding references: `compile-inputs31.json` SHA256 **17cc563665ea726b2ed48115a3fc6572a8fd795e3a596dc2efe47294b98214ca**; `I/ofs_top.qsf` **199c0b83cf63e3486069a29757bc720853bf0d3faa38b05b365945dda5323dd7**; `I/top.sdc` **3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814**. Reused synthesis review hash **cfb2e3789c0ec370c67e0f606b9b5fabdf2776b22e3ae976d3645455c149c51b** matches its consumption receipt. Historical T18/T21 hashes are **ca2ed19589bc01e6bfac1028bd3a0cbdd50a6f0f801677cdce58ab7d42bc5020** / **6bddd20bb0294b654593a000b1aec2476bc009995b9767041aeed36c1550479a**. Reviewed goal SHA256 **9a44d12bd37fdb0505da9de5e3d3e518e97853328186021c9cee82b2585ba6ba**.
