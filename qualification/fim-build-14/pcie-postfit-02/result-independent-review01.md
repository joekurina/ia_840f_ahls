# Work14 pcie-postfit-02 — independent actual-result review 01

**Verdict: ACCEPT the completed native run as bounded diagnostic evidence only. No blocking integrity, execution-completeness or captured-preservation gaps were found. This is not timing acceptance, clock/exception repair acceptance, build readiness, hardware qualification, authorization issuance, or parent publication.**

The actual result supports the reported exact divider and selected FIFO connectivity findings. Its zero target-association results require the qualifications below; they are not an exhaustive propagated-clock-absence proof.

## Scope and evidence integrity — PASS

Reviewed `RESULT.md`, `result-manifest01.json`, the decoded `result01.json.gz`, all five `result-readback01/` files, the actual `prepared-readback01/query.tcl`, runner and diagnostic gate, `parent-consumption01.json`, `ACCEPTANCE.md`, SPEC/QUALITY reviews, and launch dispatch/pane receipts. Reused the accepted package reviews rather than reopening the framework, renewed authority, or selected OFS `ofs-2026.1-1` target.

Independent local parsing and hashing verified:

- Result batch is exactly `ia840f_w14_postfit02_result01`. Archive, manifest and readback have the same exact five-file set. Every decoded base64 payload equals its local readback bytes, and both byte counts and SHA256 match the archive metadata and manifest.
- Result archive SHA256 is `9ef433fa35707fb6811ce0be2b888041476e8974ac5c5094fbe6bee075e9a273`, matching the actual `W14_QUERY_RESULT 0 EXPORT_SHA256` receipt.
- All four parent-consumption hash pins match. All nine prepared exports match their manifest, parent receipt and decoded preparation archive, including exact file-set equality; adjacent authoring copies match where present. Preparation batch is `ia840f_w14_postfit02_preparation01`.
- Launch receipt review hashes match the actual acceptance, parent receipt, prepared manifest, SPEC and QUALITY files. The accepted candidate remains `bac66033e796c0ecb6f3390dd512751b3475b1bca440c1a7d591092e4e4821f4`; actual query SHA256 is `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d`. Query, runner, authority and diagnostic-gate bytes also match their candidate file bindings.

| Result readback | Bytes | Recomputed SHA256 |
|---|---:|---|
| `native-process.json` | 329 | `61d81d891cf6ce1ce841e38d1453bafb4dc5e70148c23d034c375f61ba78f077` |
| `native-result.json` | 194 | `ec7ae2c3ce9d5ca29c4e12e0d6fed1ea5ecf55be2863735dcf20ecdeca81cd17` |
| `preservation-after.json` | 195 | `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` |
| `query.claim` | 289 | `38f10689143e63dfbebdb4259d64d09c7310020c7277f3a1ad844fb7657329ea` |
| `query.log` | 181593 | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |

These authenticate the local evidence and its recorded provenance, not a fresh remote remeasurement or an independent local rehash of unexported original/database/tool files.

## Identity and native completion — PASS

- Dispatch records owned tmux `@37/%37`; issuance receipt records `%37` and the exact accepted candidate/review hashes.
- Claim records runner PID `16284`, PPID `16258`, start ticks `2541128`, executable `/usr/bin/python3.9`, argv `python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-02/run-query.py`, and cwd that attempt root. Executable/argv/cwd match the candidate's runner binding; issuance argv/cwd agree.
- Native PID is `16291`. `native-process.json` matches the candidate's exact launcher argv and scratch cwd:

```text
/opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-02/query.tcl
cwd: /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-02/scratch/syn/board/ia840f/syn_top
```

- Candidate identifies original database `work_ia840f_fim_14`, target `ia840f`, part `AGFB027R25A2E2V`, and `ready_for_build=false`. The accepted runtime gate separately checks `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, runtime argv/cwd and live runner ancestry. Those checks were not rerun by this reviewer; the native-process export itself records launcher context, not a new live executable/ancestry snapshot.
- Full log has **718 lines**, identifies **Quartus 26.1.1 Build 130 SC Pro Edition**, repeats PID `16291` at start/end, matches the runtime command, and reports successful loading of the final database and four final partition snapshots (`query.log:18–39`). The project callback text “Compiling PR Base revision...” is not evidence that this query performed a refit.
- Stored native status is **rc0**, from `2026-09-22T07:29:09.177473+00:00` to `2026-09-22T07:29:57.714346+00:00`; process/status start timestamps agree. Pane receipt independently records **outer rc0**.
- Final cardinalities appear at lines `705–709`, `QUERY_INVENTORY_END` at `710`, and **`W14_POSTFIT_QUERY_COMPLETE` at `711`**. The actual Tcl places its cardinality checks before that final completion marker. Lines `712–717` report successful Tcl evaluation and Timing Analyzer completion, **0 errors / 201 warnings**, peak virtual memory **7017 MB**, elapsed **00:00:48**.
- Entire-log scans found no Error/Fatal severity diagnostic, Critical Warning, `125091`, `23035`, gate-rejection marker, Tcl traceback, or query bound/cardinality failure. Warning records independently total **201**: `332049` ×133, `332174` ×53, `332054` ×14, and `332060` ×1. This is successful execution with unresolved constraint diagnostics, not a warning-free or timing-qualified result.

## Original preservation — PASS within captured-evidence boundary

`preservation-after.json` contains exactly these three roots, all boolean `true`:

```text
/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach
/home/uwb_student00/ahls/new_BSP/ofs-platform-afu-bbb
/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14
```

The verified runner writes raw native status first, then compares each complete original-tree file-hash/symlink inventory against its stored baseline (`run-query.py:10–21,47–58`). The launch receipt also records originals unchanged before launch. Thus the accepted runner's actual postflight reports maintained SOURCE, original PIM and original Work14 unchanged. This reviewer did not independently inventory those remote originals.

The known exceptional-postflight/export weakness remains: such an exception could obscure outer status or omit later receipts. It does **not** leave this run incomplete: raw status, full log, all three true preservation results, export digest and outer rc0 are present together. Source-bound guards are not OS sandboxing. The log also retains reads of original Work14 absolute SDC paths (for example lines `490–491`); do not describe the fitted-copy query as a hermetic, scratch-only read environment.

## Exact divider findings — VERIFIED

Define the following literal common prefix `P`:

```text
pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
```

`D` below denotes `P|u_pciess_clock_divider|clkdiv_inst`.

- Exact selector counts are `D|inclk = 1`, `D|clock_div2 = 1`, and `D|clock_div2x = 0`; returned pin names equal the first two selectors exactly (`query.log:496–500`). `clock_div2x` is not conflated with `clock_div2`.
- Exactly **one** divider cell is reported, type **`tennm_clk_divider`** (`504,705`). It has one clock input. `inclk` is input/clock; `clock_div2` is output/clock (`505–512`). The output's raw net handle is `_quartus_sta_net__53563`; neither that handle nor the register alias below substitutes for the exact pin name.
- The input has exactly one clock fanin, **`sys_pll|iopll_0|tennm_pll|outclk[2]`**, and exactly one target-associated clock: **`sys_pll|iopll_0_clk_100m`**, period **9.929 ns**, master **`sys_pll|iopll_0_n_cnt_clk`**, source **`sys_pll|iopll_0|tennm_pll~ncntr_reg`** (`506–509`). This is the actual observed input clock, not an inference from a nominal clock name.
- Output `D|clock_div2` reports **`CLOCK_TARGET_COUNT 0`** (`511`). The query does not report an output-clock period or independently establish its propagated divide ratio.
- Independently of that target-name lookup, **Warning 332060** explicitly identifies **`P|u_pciess_clock_divider|clkdiv_inst~div_reg`** as a clock without an associated clock assignment (`493`); following Info 13166 identifies a register clocked by it (`494`). This is substantive native negative evidence, not a gate or query error.

## Every selected FIFO cell — VERIFIED

Parsed **all 32 distinct cell records**, not only the four final group totals. Each complete six-line cell block was checked for exact cell/pin identity, `tennm_ff` type, one input/clock pin, one fanin, zero target-associated clocks and `CLOCK_INPUT_COUNT 1`. No extra or missing FIFO records were present.

Paths in this table are relative to `P`:

| Group | Exact FIFO path | Exact selected suffix prefix | Cells | Log span containing records |
|---|---|---|---:|---|
| 0 | `u_pciess_cplto_if|cplto_fifo_avmm_inst` | `auto_generated|rs_dgwp|dffpipe5|` | 8 | 609–656 |
| 1 | `u_pciess_cplto_if|cplto_fifo_lite_inst` | `auto_generated|ws_dgrp|dffpipe5|` | 8 | 657–704 |
| 2 | `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo` | `auto_generated|rs_dgwp|dffpipe5|` | 8 | 513–584 |
| 3 | `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo` | `auto_generated|ws_dgrp|dffpipe5|` | 8 | 537–608 |

Groups 2 and 3 are interleaved in the log. In **each** group the exact leaf set is `dffe6a[0]`, `dffe6a[1]`, `dffe6a[2]`, `dffe6a[3]`, `dffe7a[0]`, `dffe7a[1]`, `dffe7a[2]`, `dffe7a[3]`; each inspected pin is that cell's `|clk`.

Every cell's sole `get_fanins -clock -stop_at_clocks` result is exactly:

```text
P|u_pciess_clock_divider|clkdiv_inst~div_reg
```

Here `P` expands to the full literal prefix above. Every one of the 32 corresponding target-association lookups returns **0**. All final group totals agree with these independently parsed distinct-cell counts. Unlike attempt01, the corrected query reaches every selected receiver and final completion without the node-as-collection error.

## Interpretation limits and disposition

1. **Target association is not exhaustive clock propagation.** Actual `query.tcl:11–35` compares exact returned node names against `get_clock_info -targets` for each clock. Output lookup uses the output pin name; FIFO lookups use returned fanin names. Zero counts establish no matches by this method, not that no propagated clock could be found by another query. Warning 332060 is separate supporting unassigned-clock evidence.
2. **Input `-net` is not connectivity proof.** Empty `NET_ID {}` on input pins is not a disconnected-input finding. Connectivity conclusions above use the separate clock-fanin results, retaining the accepted input-pin API caveat.
3. **Top-level scope is not entity scope.** `TOP_AXI_LITE_PORT_COUNT 0; top_context_not_entity_scope` (`501`) does not prove a generated entity-scoped SDC predicate is false or settle which conditional branch should create a clock.
4. **Named receivers are not complete crossing/exception coverage.** These finite selections prove connectivity of the listed registers only. They do not enumerate every crossing, direction, endpoint, exception interaction or synchronizer-safety condition. Existing SDC warnings remain unresolved. Any future repair must separately review activated clock groups/multicycles; this run neither measures their effective coverage nor establishes that multicycles override asynchronous cuts.
5. **No repair or qualification occurred.** Actual Tcl loads existing SDC and adds no new clock/exception commands. Captured preservation supports unchanged maintained source; no new constraint, refit, timing pass, hardware run, guaranteed warning cure, or resolution of separate EMIF1 hold/other qualification gates follows from this evidence.

**Disposition:** the parent may consume this completed result as evidence for the bounded fitted-netlist diagnosis. Preserve the spent attempt and all original artifacts. Any changed experiment requires its own fresh scope/package; this report grants no execution authority and does not publish parent acceptance.

Only local evidence reads, in-memory decompression/JSON parsing, hashing, exact comparisons and full-log/per-cell checks were performed. No remote, vendor, hardware, git, source-edit, package execution or authorization action was taken. The sole intentionally written review artifact is this file.
