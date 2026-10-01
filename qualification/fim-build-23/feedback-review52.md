# CPA feedback diagnostics — independent result review52

**ACCEPT the three completed observations, with the initial acquisition gap retained. The matched raw feedback measurements do not explain the −84ps CPA COMP change. They neither establish a timing-model bug nor rule out an implementation-dependent CPA response. Timing remains failed; no corrective implementation is established.**

Reviewer: **gpt-6-astra-900k / openai-codex**, substituting for unavailable GLM5.3; no GLM review claimed. Local retained files and in-memory Python only; no SSH, native tools, tests/source-script execution, web research, hardware, or Git/source changes. Only this report is written. Scope follows `result-review32.md` and `clock-compensation-remedy-review32.md`, not a new FIM review or approval framework.

## Evidence acceptance

Independently verified **64/64 frozen sizes and SHA256 hashes**. `feedback-result-freeze51.json` SHA256 is `84709fa356c23d640ed436f84341b59c592c40e6d2207474e3922c34c29a8beb`. All three `result.json.gz` captures match collection40/43/49; every decoded member matches its receipt and local readback: **13/13, 17/17, 17/17**. Report manifests, audit/log records and supervision/status records reconcile.

For attempts **37 / 41 / 46**, effective/supervised-CMake/outer status is **0/0/0**; termination is confirmed, with no residual live owned processes, abort, supervision or postflight errors. The field `native_rc` actually records CMake’s exit, not a separately captured vendor exit. Direct CMake targets invoke `quartus_sta`; all logs independently report successful Tcl evaluation and Timing Analyzer completion, **0 errors/192 warnings**. A nonzero CMake status would not identify the exact vendor code. These successful observations are not warning-free signoff.

Original Work23/PIM or Work21/PIM file-hash/link inventories are recorded preserved. The bound runner compares complete inventory maps, not selected timing files; this review verifies those retained receipts, not a new workstation scan. Both Work23 candidates bind the same QDB/QSF; all three bind identical `top.sdc`, and native logs retain the signoff-margin skip marker. Each loads its own **final** snapshot under its original tool: **26.1.1 Build130** or **25.1.0 Build129**. No fit or image generation occurred.

Supplemental provenance finding: feedback41’s preliminary `inputs.json.gz` retains older wording in `AUTHORITY.md` only. Its actual query/runner match; the prepared candidate and hash-verified issue42 receipt bind the corrected matched-polarity scope. This is not executed-query drift; preserve both artifacts.

## What was measured

Paths below are relative to each attempt’s `result-readback/reports/`. All returned raw paths and anchors explicitly identify **Fast vid2 100C Model**, not an inferred corner from filenames.

- **37:** unrestricted core maximum **3.853ns** and minimum **3.455ns** reproduce respectively 41’s rising maximum and falling minimum, including ordered route fields. Board `ddr4_mem_ref_clk[1].clk`→PHY queries return **zero paths**, not zero delay. Installed help documents the keeper boundary; the successor removes the inappropriate fixed board-port start.
- **41 versus 46:** query logic is identical apart from attempt identifiers and the expected anchor. Each returns all **eight requested extrema**, not exhaustive feedback-route coverage. Core queries fix both rising/rising or falling/falling endpoints; PHY queries fix destination polarity only. I verified actual start/end names, ordered transition continuity, endpoint polarities, modes, snapshot/corner, counts and totals in all **16** reports.

| Raw path / edge | W21 minimum | W23 minimum | Δps | W21 maximum | W23 maximum | Δps |
|---|---:|---:|---:|---:|---:|---:|
| Core rise | 3.479 | 3.478 | −1 | 3.857 | 3.853 | −4 |
| Core fall | 3.458 | 3.455 | −3 | 3.834 | 3.829 | −5 |
| PHY rise | 1.166 | 1.166 | 0 | 1.356 | 1.356 | 0 |
| PHY fall | 1.166 | 1.166 | 0 | 1.355 | 1.355 | 0 |

Delays are ns; deltas are W23−W21. These independently reproduce `feedback-comparison50.json`.

Core is exactly EMIF1 `tile_gen[1].tile_ctrl_inst|pa_core_clk_out[0]`→`pa_core_clk_in[0]`. Every PHY report actually starts at `…|pll_inst|pll_inst|lvds_clk[0]` and ends at that tile’s `pa_fbclk_in[1]`, with RR or FF arcs as requested. **Neither measures board-reference-to-phase-detector delay.** PHY0/2 lookup failures establish unavailability in this queried view, not physical absence.

`report_path` reports propagation extrema, labeled “Data Delay,” not CPA compensation or timing slack (`cpa-help35`, lines67–110). Core starts at zero and includes a downstream output CELL arc; PHY starts at zero and includes six CELL arcs. Neither raw path contains COMP or a capture setup/hold micro-term. Routing-detail IC rows are placeholders, not extra delays to add.

## Identity and topology limits

Core routes genuinely differ: **58→57 ordered rows**, including `DCM_mux_X198_Y2_N0_I27`→`…I29` and different clock-tree branches. Core CELL fanout changes **15973→15967**, with another spine-tap fanout **24→20**. Small total differences are not physical-tree equality. Comparison50’s empty `changed_fields` for structurally unequal core paths must not mean “no field changes.”

All four PHY comparisons have **seven identical ordered rows**, including **fanout**, locations, RF, increments and totals. Both designs retain the physical output suffix `__core_clk_out[1]` downstream of the verified logical `pa_core_clk_out[0]`; this does not turn the query into output1. Separately, exactly six anchor reference-clock rows pair `refclk_Duplicate`→`refclk_Duplicate_3` at the same site with otherwise equal fields. No general alias normalization or whole-tree equivalence is claimed.

## Interpretation and smallest remaining discriminator

The anchors reproduce **+0.082ns versus −0.004ns** on the same bit243 Hyper-Register→UFI→PHY transfer. Decimal reconciliation gives CPA COMP **−2.208→−2.292ns** and launch-clock IC **3.238→3.236ns**: **−84ps−2ps=−86ps** slack change. Data delay **0.288ns** and required time **2.968ns** remain equal. This explains the *signoff difference*, not the production of COMP.

The measured core changes are only **1–5ps**, and PHY propagation is unchanged at printed precision. There is no established mapping from these extrema to COMP. Selecting minima, maxima, mixed edges or averages until an equation fits would invent that mapping. Both implementation and tool version changed; a nonlinear/discrete implementation response or different nominal/model treatment remains possible, not demonstrated.

Hash-matched generated RTL confirms zero phase offsets, disabled core phase controls and output0 feedback selection `fb1_p_clk`; **`CPA_FB_MUX_1_SEL` controls output1**. This establishes connectivity/requested controls, not every effective internal CPA parameter or the production STA equation (remedy-review32 references; tile RTL1618–1636,1715–1723).

**Next action: obtain the supported production calculation/decomposition for this one output from implementation-source evidence or the CPA model owner, using the frozen paired reports.** It must identify the calculation’s start/reference planes and detector endpoints, edge/divider relationship, nominal versus early/late delay treatment, and effective internal settings, then reproduce **both** COMP values without fitted constants. That is the smallest causal discriminator—not another route inventory.

No verified command currently supplies it: help35 finds `report_delay_calculation` absent; help36 finds no imported CPA/compensation command. `report_clock_network` includes fanin **and fanout**; `-initial_depth` only collapses GUI rows, so it was correctly not run as a bounded substitute. If supported source/decomposition is unavailable, the genuine remaining dependency is a **vendor CPA model/implementation explanation or applicable 26.1.1 patch**, not proof that no remedy exists. No contact, upload or tool change is implied.

Keep **OFS2026.1, Quartus26.1.1 Build130, AGFB027R25A2E2V and 3.000ns** unchanged. No blind seeds, waivers, inflated margins, vendor-RTL phase override, reopened closed workaround branches, or hardware follows from these observations.
