# Clock-trial02 — independent actual-result review

## Verdict

**ACCEPT narrowly: the completed native pilot validates the proposed generated-clock binding, its propagation to the predeclared 32 receivers plus tile T, and numerical evaluation of all eight formerly invalid FIFO net-delay assignments in all five acquired operating conditions.** No blocker was found for those claims.

**The result justifies preparing the minimal production clock-definition correction and a separately reviewed changed-constraint fit.** It does not accept production-source promotion, authorize that fit, establish comprehensive changed-transfer/exception coverage, or qualify timing, CDC/DRC, hardware or a bitstream. The max-skew output is summary-only, and the exception/path reports are intentionally limited. Those boundaries must survive parent consumption. **This attempt is SPENT; this review authorizes no rerun and closes no task.**

This review used local byte/hash, JSON/gzip/base64, non-evaluating Tcl-list and source/report inspection only. No project code, test, vendor/help command, remote connection, hardware operation, authorization or git command was executed. Only this report is authored. The native-iteration amendment in `prepared-readback01/PRIORITY-AMENDMENT.md:5–13` governs: the unfinished comprehensive experiment04 framework and a new original-baseline run are not prerequisites to accepting this narrower observation.

References below are relative to this directory: **P** = `prepared-readback01`, **F** = `result-readback01`; **audit** = `F/reports/audit.tcllist`; **log** = `F/query.log`. Report/source line references are 1-based. **VSDC** is the generated `intel_pcie_ss_axi_500/synth/pcie_ss.sdc` decoded locally from `../../pcie-generated-evidence-01/pcie-rendered-constraints-live06.json`; its decoded SHA256 is `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265`, equal to the candidate's exact generated-SDC binding.

## 1. Identity, transport and terminal-state evidence

Independently verified the **152 entries** in `result-review-freeze01.json` at entry and again after analysis: every byte count and SHA256 matched. The freeze digest remained `0674f73b1a11fda75b63d30ee91f907259a65229a35b2855ce80f714724396ce`. `CURRENT.md` and `.gitignore` are outside this freeze; neither was used to upgrade acceptance.

Decoded both archives, strictly base64-decoded each export, and compared its bytes/size/hash with its manifest and local readback: **21 preparation exports and 86 result exports**, all matching. Reconciled the exact report file set and every report-manifest entry: **79 files, 49,058,648 bytes**. Largest report: **2,320,342 bytes**. These are below the retained file-count/size/total caps; no cap increase was needed.

Principal independently recomputed bindings:

| Artifact | SHA256 |
|---|---|
| `preparation01.json.gz` | `0894077b821624673b4e5f797db4606722a9270cd934a1ab5bc2afdde287ab52` |
| `prepared-manifest01.json` | `97f9c0664a266ef77d2025c710bd12078728e079dc75feec23b0e3a595ed6e22` |
| `P/candidate.json` | `c2fbb6e73f56aa4a8a212edade169e0b547286573662fc996c1196516f12fbc4` |
| `result01.json.gz` — 1,763,076 bytes | `1619230e6582918bc8eb51e3f05c0514348f4b34c7f0afb6535bd1e5cb4d533f` |
| `result-manifest01.json` | `f0dd91835a63a5f9b09bacd7a07aa1935d1effb1cf6943848534f9983d8ed2a7` |
| `F/query.log` — 419,192 bytes | `eabbdeed33424f8810a68fed6ffb7d9eba7e00aaee8fcf5cbe844f32d3bc04b1` |
| `F/reports/audit.tcllist` — 846,739 bytes | `45e701c10111b05f6de3972fbda5eaee022e7de503cca1a1ae648017c352d85a` |

Actual prepared query/helper/inventory/receiver/scope/runner/gate/dispatcher/top-SDC bytes match their candidate bindings; corresponding authoring copies match the prepared exports. `ACCEPTANCE.md` is historical **package** acceptance, not a result verdict. The later issuance record in `native-status01.json` binds that acceptance, both reviews, parent consumption, prepared manifest and the exact candidate; all five review-file hashes match. Its authorization digest also matches reconstruction using the issuer's exact JSON serialization (`issue-launch01.py:63–67`), rather than an assumed serialization.

`F/native-process.json` records PID23848, the exact candidate `quartus_sta -t .../clock-trial02/query.tcl` launcher argv and copied-fit cwd. `F/query.claim` records runner PID23841 with the expected Python executable/argv/cwd. Native execution was **2026-09-22T17:13:12.813331+00:00 → 17:14:42.458290+00:00**, **89.644959 seconds**. `F/native-result.json`, `F/execution-status.json`, `completion-pane01.txt` and log:1349–1357 agree on **native/effective/outer 0/0/0**, one completion marker, no abort/supervision errors, `termination_confirmed=true`, and `final_live_pids=[]`.

The separate saved status capture at **17:15:33.567184 UTC** has `live_group=[]`; its common exported-file hashes/data match F. `F/preservation-after.json` records true for maintained SOURCE, PIM and original Work14, with no postflight errors. These are verified **captured runner/status comparisons**, not a fresh inspection of the remote trees or a sandbox claim. `P/run-query.py:252–310` preserves the whole-lifetime supervisor, exclusive claim, original-inventory comparison and failure propagation. No hardware/fit/source promotion occurred in this pilot.

## 2. Clock identity and source delta — accepted

The copied top SDC is exactly the prescribed replacement of original lines35–37. Inverse replacement reconstructs SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`; the candidate top SDC hashes to `ea484352945e166842f1d84496d727730478434c11da84edb934ed5bf6c09590`. Every other byte, including groups and multicycles, is preserved. `P/clock-repair.tcl` contains the complete accepted `../experiment04/guard02/clock-repair.tcl` as a byte-identical prefix (guard SHA256 `4967de098cd857a936ccaeb16b22092259872292488ca44d5bce46b594af8bdc`). The additive final verifier does not weaken ratio, precision, identity or propagation requirements.

Use these exact abbreviations:

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
D = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst
M = sys_pll|iopll_0_clk_100m
C = H|avmm_clock0
T = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

The insertion precheck observes no named C or explicit divider-output definition, while the output's existing **driving association** is M (log:348). That is not contradictory: driving clocks and definition targets are different properties. The insertion snapshot has 77 clocks; later full-SDC clocks must not be rejected as an insertion-time delta.

Native final C is **generated**, with source `D|inclk`, sole target `D|clock_div2`, immediate master M, **divide/multiply 2/1**, period **19.858 ns**, waveform **{0.000 9.929}**, inversion0, empty explicit edges/edge-shifts. M is **9.929 ns**, waveform **{0.000 4.964}**, targeted at `sys_pll|iopll_0|tennm_pll|outclk[2]`. These are returned values, not a hard-coded nominal 20-ns clock. The strict final property/propagation guard passed and emitted `CLOCK_REPAIR_VERIFIED_FINAL_V3` (log:723–726; `P/clock-repair.tcl:211–241`).

Independently decoded audit:3,7 and their nested Tcl lists without evaluating captured scripts. Both inventories contain exactly **the original 80 definitions plus C**, with every original inventoried field unchanged after list-semantic comparison; waveform trailing whitespace is not a clock change. Independently reconstructed those 80 original definitions from the retained diagnostic03 native `CLOCK` records, decoding its `generated_properties` record tag, and matched P's pinned baseline. This is not circular comparison against a candidate-derived baseline.

All **140 COUNT/SET pairs** reconcile raw/enumerated/unique cardinality and remain within their recorded caps. All32 predeclared cells occur exactly once in each mapping class, in four groups of eight: `tennm_ff`, exact expected input clock pin, reverse fanin `D|clock_div2`, one cell-derived timing register, and **sole driving clock C**. T also has sole C (audit:27–430; `P/receiver-mapping.tcl:5–80`). The two unfiltered root sets and union retain the same **459 names** as the baseline. This does **not** prove all459 are clock loads or constitute exhaustive timing/CDC coverage; aggregate clock association must not be distributed into invented per-member evidence.

## 3. Five actual corners and numerical FIFO evidence — accepted within scope

Audit:432–472 records five actual objects, each selected before timing update/reports, with all five `CORNER_COMPLETE` records:

- c0: `2_slow_vid2_100c` — Slow vid2 100C Model.
- c1: `2_slow_vid2b_100c` — Slow vid2b 100C Model.
- c2: `MIN_fast_vid2a_0c` — Fast vid2a 0C Model.
- c3: `MIN_fast_vid2a_100c` — Fast vid2a 100C Model.
- c4: `MIN_fast_vid2_100c` — Fast vid2 100C Model.

The 25 domain-summary records carry the corresponding model names. `P/query.tcl:34–58` selects **one** acquired object at a time, matching retained installed `../api-help01/commands/set_operating_conditions.txt:50–59`, which distinguishes this loop from selecting the entire collection for aggregation. Net-delay and skew reports have equal byte sizes across corners but **five different hashes and different numerical values** in each family. They are neither identical copies nor evidence of automatic all-corner aggregation.

Independently hashed original Work14 `../../fim-build-14/reports11/output_files/ofs_top.sta.rpt` to `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` and matched all eight literal anchor lines3620–3627. Matched candidate assignments by **exact From selector, To selector, max type and complete SDC location**, not report order or FIFO-name substring alone.

VSDC:628–641 establishes pointer max skew = **0.8 × source period**, pointer net delay = **0.8 × destination period**, separate synchronizer-chain net delay with the same destination multiplier, and pointer max/min-delay exceptions **100/−100**. Its dcfifo iteration at :727–733 is not confined to these four FIFOs. Candidate net-delay Required is **15.886 ns for every one of the 40 target assignment/corner observations**, consistent at native display precision with C's destination period; bounds were not replaced by literals.

The compact table gives native **Actual / Slack** vectors in **c0,c1,c2,c3,c4 order**, in ns. “Chain” is the same `dffpipe*|dffe*` chain on both sides. The candidate line is identical across the five `c*-net-delay.rpt` files; four detail rows immediately follow it.

| Baseline → candidate line | FIFO and selector class | Actual vector | Slack vector |
|---|---|---|---|
| 3620 → 1067 | `cplto_fifo_lite_inst`, ws_dgrp chain | .306, .305, .215, .225, .226 | 15.580, 15.581, 15.671, 15.661, 15.660 |
| 3621 → 1042 | `cplto_fifo_lite_inst`, `*rdptr_g*` → ws_dgrp | .657, .656, .480, .509, .510 | 15.229, 15.230, 15.406, 15.377, 15.376 |
| 3622 → 1062 | `cplto_fifo_avmm_inst`, rs_dgwp chain | .339, .339, .238, .247, .249 | 15.547, 15.547, 15.648, 15.639, 15.637 |
| 3623 → 1057 | `cplto_fifo_avmm_inst`, `delayed_wrptr_g*` → rs_dgwp | .352, .351, .245, .254, .255 | 15.534, 15.535, 15.641, 15.632, 15.631 |
| 3624 → 1077 | `u_user_avmm_clk_to_axi_lite_clk_fifo`, ws_dgrp chain | .291, .288, .196, .205, .207 | 15.595, 15.598, 15.690, 15.681, 15.679 |
| 3625 → 1052 | same FIFO, `*rdptr_g*` → ws_dgrp | .406, .405, .277, .293, .294 | 15.480, 15.481, 15.609, 15.593, 15.592 |
| 3626 → 1072 | `u_axi_lite_clk_to_user_avmm_clk_fifo`, rs_dgwp chain | .297, .297, .208, .216, .218 | 15.589, 15.589, 15.678, 15.670, 15.668 |
| 3627 → 1047 | same FIFO, `delayed_wrptr_g*` → rs_dgwp | .414, .413, .293, .307, .307 | 15.472, 15.473, 15.593, 15.579, 15.579 |

The full identifiers are preserved in `baseline-fifo-row-anchors01.json` and each native row. The first two FIFOs are under `u_pciess_cplto_if`; the latter two under `EP_CFG_IF.u_pciess_cfg_if`, both beneath `H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif`. Chain assignments cite VSDC:639; pointer assignments cite :631.

Each corner contains **146 assignment rows and 978 detail rows**, zero `Invalid clock`, and at most **48 details per assignment**, versus requested `-nworst 20001`. Each target assignment has exactly **four unique reported endpoint pairs**; all160 target detail observations have destinations in the known32 mapping. All assignment/detail values were numerically checked: no negative/absent/non-numeric Required/Actual/Slack, displayed Slack agrees with Required−Actual to 0.001 ns, and each summary slack is the minimum of its actual details. Minimum target slack is **15.229 ns**. Minimum across all reported net-delay assignments is **1.023, 1.024, 1.182, 1.143, 1.142 ns** by corner. No observed net-delay assignment reaches the cap; this is not a claim about all possible timing paths or Cartesian selector pairs. Retained `report_net_delay` help:26–37 defines these as each assignment's matching-edge results.

All40 entries of `fifo-numerical-observations01.json` were independently reproduced, including line, selectors, source, values, detail count and cap flag. The parent's preliminary extraction is corroborated, not used as acceptance authority.

### Max-skew limitation is real, but not an invalid-clock failure

Each `c*-max-skew.rpt` is **100,764 bytes /108 lines**, containing **102 numerical assignment summaries and no per-path detail rows**. All displayed skew summaries are nonnegative and arithmetically consistent; global minimum slack is **1.158, 1.163, 1.294, 1.251, 1.249 ns**. Each corner includes eight pointer-direction summaries for the four selected FIFOs at VSDC:629. Their Required values distinguish **7.943 ns** from **15.886 ns**, consistent with source-period rather than destination-period semantics; minimum among those FIFO skew summaries is **7.481 ns**.

**Do not claim latest/earliest path coverage or verified per-assignment non-saturation for skew.** `-npaths 20001` was requested, but `-detail summary` did not retain that detail or its counts; launch/latch-clock cells are blank. All five `SKEW_RETURN` values are empty (audit:439,447,455,463,471), despite the retained help's described two-element return. An empty return is not zero paths. These are usable positive **summary** observations, not a demonstrated complete latest/earliest acquisition. Endpoint-specific source-clock identities and full skew coverage remain unavailable here.

## 4. Exceptions, remaining diagnostics and timing boundaries

The full SDC report retains the C-related groups and all four multicycles (`F/reports/sdc.rpt:852–855,1211–1214`). The clock-only replacement shifts subsequent source locations by one line; candidate references must not be mistaken for original line numbers.

Across all five corners, each exception report contains **448 rows**, below the 20001 exception-count cap. This says nothing exhaustive about paths: `-npaths 1 -detail summary` retains status/slack summaries, not endpoint coverage (`P/query.tcl:49`; retained `report_exceptions` help:116–170).

- Candidate `top.sdc:50`, M↔C async, is **Complete** in the exception summaries. The four multicycles at :56–59 are **Fully overridden** in the appropriate setup/hold analyses at every corner and receive **no safety credit**.
- Candidate :48, C↔rx_ch15 async, is **Fully overridden** for setup/hold and **Partially overridden** for recovery/removal. Thus it would be false to call every C-related group newly effective or its winning exception uniquely identified.
- Setup/hold transfer reports retain both C↔rx_ch15 directions as RR=`false path`, classification `Ignored (Not Timed)`. C↔M rows also contain RR=`false path` and no numerical slack, even though their classification column says `Inter-Clock (Timed Safe)`. Preserve both fields; that classification is **not a timed-pass result**. See `c0-{setup,hold}-transfers.rpt:39–40,93–94` and corresponding other corners.
- The four selected pointer max/min-delay exceptions at VSDC:633/634 are **Fully overridden** in setup/hold at every corner (`c0-*-exceptions-sample1.rpt:371–372,386–387`). Their −100-ns minimum-delay value is intentional source policy, not a negative net-delay slack. Dedicated numerical net-delay/skew results remain separately present.
- Negative numbers in false-path/clock-group exception summaries are real diagnostic observations, not normal timed-path failures or a waiver. Retained `report_exceptions` help:183–200 describes the cut-path view. The reports do not enumerate every affected endpoint or establish every integration CDC contract. `Invalid`/`Paths will not be analyzed` statuses must retain their analysis-specific meanings, not become numeric zero or invented missing-clock failures.

The C domain's native worst slacks, c0→c4, are:

- setup: **17.639, 17.591, 18.209, 18.101, 18.110 ns**;
- hold: **0.051, 0.050, 0.022, 0.020, 0.020 ns**;
- recovery: **18.680, 18.684, 19.004, 18.940, 18.933 ns**;
- removal: **0.238, 0.242, 0.165, 0.172, 0.170 ns**;
- MPW: **9.428, 9.422, 9.558, 9.543, 9.546 ns**.

Each has endpoint TNS0 and zero negative endpoints in the reported domain summary. These are meaningful domain summaries (`audit:434–470`; retained `get_clock_domain_info` help:28–49), **not all detailed MPW checks, complete crossing coverage, or full timing sign-off**. The four normal timing report families are explicitly limited to20 paths each.

The separate **EMIF1 −0.004-ns hold violation remains actually present**, not merely inherited caution: audit:467 and `c4-hold-sample20.rpt:26,57–62` show core-user-clock write data to PHY `emif_1_phy_clk_l_0`, Fast vid2 100C Model, `VIOLATED`.

Native completion has **0 errors /187 warnings**: 127×332049 ignored assignments, 50×332174 unmatched register filters and 10×332054 clock-group problems. No332060 missing-clock warning, `Invalid clock`, clock-repair rejection or125091 gate diagnostic occurs. This removes the specific missing-clock symptom without declaring the warning set harmless. Ignored-SDC entries still include the top-level SYS_REFCLK redefinition and unmatched PMCI clocks/ports (`sdc-ignored.rpt:6–18`); no blanket suppression is justified.

`check-timing.rpt:6–12` reports **370 no_clock issues**, zero for the six other requested check categories. All32 exact receiver names and exact T are absent from those370, but other PCIe tile and EMIF objects remain. This is **check_timing, not DRC**. Each UCP report records zero illegal/unconstrained clocks but **two unconstrained input ports /78 pairs** and **two output ports /10 pairs** for both setup and hold: `altera_reserved_tdi`, `altera_reserved_tms`, `altera_reserved_tdo`, `bwbmc_bmc_irq` (`c0-unconstrained.rpt:9–14,113–123`, same summaries at all corners). Those UCP clock totals do not erase no_clock-register findings. Log:1347–1348 explicitly says setup and hold are not fully constrained. Original High CDC/DRC findings remain unwaived and unqualified by this query.

## 5. Precise gaps and smallest justified next step

**Proceed to preparation, not acceptance by extrapolation.** The old fit now provides positive native evidence for the exact modern hierarchy, M master, divide-by-two semantics, known receiver propagation, all eight recovered net-delay checks and finite five-corner results. Another unchanged fit, another selector-discovery run, a baseline rerun or completion of experiment04's reporting framework is not needed to establish those facts.

The smallest supported preparation is a **clock-definition-only production candidate**, replacing the obsolete top-SDC command with the validated name/source/target/master/divide relationship; preserve generated vendor files and exception bytes, avoid blind `-add`, invented periods, exception cleanup or unrelated fitter changes. Do not copy the trial's absolute scratch-helper path or treat its fixed original80/post-fit guards as a universally valid production-flow baseline. Check the actual proposed production loading boundary and exact diff in its ordinary source/build review, then prepare one fresh changed-constraint fit under the existing gates. This report does not promote those bytes or consume any new authorization.

Carry these gaps explicitly into the next actual-result review, using **focused additions to ordinary native reporting**, not a new framework:

1. **Skew detail/count gap:** if making a complete skew-coverage claim, retain latest/earliest path details and actual per-assignment counts with a finite cap; use documented non-summary detail and inspect the actual result, rather than trust the empty return. Existing summaries remain accepted only as summaries.
2. **Cut-path/precedence gap:** endpoint identities and winning exceptions for changed C-related crossings are not exhaustively retained. A focused bounded `report_exceptions`/false-path detail capture for the relevant C↔M/C↔rx_ch15 transfers and other observed changed scope can establish vendor/internal versus integration boundaries without deleting cuts. Until then, no exhaustive CDC or newly-cut-path acceptance; no requirement to rebuild a full A/B acquisition system before preparing the correction.
3. **Changed-design/full qualification gap:** the new fit must supply its own valid clock/constraint/timing results. Preserve the unresolved EMIF hold failure, unconstrained ports/registers and High-rule findings; do not relabel this old-fit STA pilot as fixing them or as hardware qualification.

**Disposition:** narrow native clock/constraint evidence accepted; minimal correction/changed-fit preparation justified; comprehensive exception/skew coverage, production promotion, full timing/CDC/DRC and hardware acceptance remain open. Parent consumption is a separate decision.
