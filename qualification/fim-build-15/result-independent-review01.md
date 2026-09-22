# Work15 — independent completed-native-result review

## Verdict

**ACCEPT the completed native compile/fit/STA/assembly evidence and the narrow PCIe generated-clock/constraint progress. Timing qualification FAILS; CDC/DRC and complete constraint coverage remain OPEN; hardware NOT RUN/NOT QUALIFIED; `ready_for_build=false`.** This is result acceptance within those boundaries, not image release, a timing waiver, a new authorization, or acceptance by exit code alone.

Work15 actually implements the modern divider declaration in a fresh fit. Its sole reported negative normal timing result is the **same EMIF1 −0.004 ns hold path as Work14**, with the same reported physical path and delays. The PCIe divider is no longer an unconstrained clock, and all eight formerly invalid FIFO net-delay assignments now have positive numerical results. Neither result clears the independent High CDC/DRC findings or remaining unconstrained ports.

Local, read-only inspection and in-memory parsing/hashing only: no SSH, vendor/project execution, tests, mocks, hardware, source/authorization/git changes, or new framework. Only this report was authored. The parallel warning review was not used as acceptance authority. Joe's explicit native-iteration amendment governs; **no fresh source SPEC/QUALITY approval is claimed or demanded** (`ITERATION-AUTHORITY.md:3–9`; `native-iteration-acceptance.json:2–20`).

### Citation convention

Paths are relative to this directory. **R** = `reports01/output_files`; **P** = `completion-readback01/project`; **L** = `completion-readback01/evidence/run`; **S** = `R/ofs_top.sta.rpt`; **D** = `R/ofs_top.tq.drc.signoff.rpt`; **W14** = `../fim-build-14/reports11/output_files/ofs_top.sta.rpt`. Text references are original 1-based lines, not excerpt line numbers. Compressed JSON is referenced by decoded member/key, not fictitious compressed-file line numbers.

## 1. Evidence identity, authority and preservation

- Independently verified **all 55 frozen files**, byte counts and SHA256, before and after analysis. Freeze SHA256: `19c437d633242ebb91629d3f5c3dff772ee964cefaca562a7c24a47eaa3ca2bf`. No frozen byte changed. Independently decoded and matched **19 preparation exports, 16 completion exports and 9 full-report exports** to their raw local readbacks and recorded hashes. The nine report captures include the full STA, not merely selected summary rows (`result-review-freeze01.json:4–224`; `reports-manifest01.json:5–68`; `completion-manifest01.json:4–132`).
- Recomputed archive SHA256: completion `ab80374ebd6145a8cf87c1f52e86d82072bd94535f74afff8d4cea71de87811a`; reports `5ef103998c4d8ebe0a30ff0309a759c408f9ad7445c8cbac0f1786824d6d4751` (**1,544,431 bytes**). Full STA: **49,225,123 bytes**, `e38b1fbfae9afe8efdb3602165c9ec475a7898301172eeff47825742956778d9`; full fitter: **19,808,778 bytes**, `a763725d71b02c4fb5687a5e5818e2714ed75ad2c21a0a5b6e6b99c742288aa3`; signoff DRC: `74b390e25c4e791543e1bb85e2fea5e99d9deeb4d9d918129583f770988141cd` (`reports-manifest01.json:3–4,27–32,48–53,62–67`). Completion's captured report identities agree with the later full-report archive.
- Prepared draft contains **5,424 recorded inputs and 135 contexts**, independently counted. Comparison of the backed-up and candidate top SDC finds exactly one replacement: old lines35–37 become new lines35–38; all other bytes, including exceptions, are unchanged. Candidate SHA256 is `b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc`. The two other recorded SOURCE changes are the mechanical gate retargets, not functional FPGA changes (`clock-delta.diff:3–16`; `prepared-readback01/preparation-result01.json:5–28`). Parent technical acceptance is explicitly distinguished from nonexistent new independent source approvals (`native-iteration-acceptance.json:3–16`).

**Separately verified postflight supplement, not silently added to the freeze:** `postflight01.json.gz` SHA256 `0d319ac350db5c95f22830a392b3a07229c8f0a4f6f520479b193c6c14372c4e`, **384,190 bytes**; `postflight-summary01.json` SHA256 `25d76055d741b6f75821c3ba95c875c74bd409ad536e1852e607e4bdbb207c8b`; collector SHA256 `cf50958895b7720f5a87a2c32b161b7d26534f5f0ddcce1ebba572be546b426b`. Decoded summary and inventories agree. Independently recomputed inventory deltas against `../pcie-clock-repair-01/fanout-diagnostic03/prepared-readback01/preservation.json.gz`, whose SHA256 matches the supplement's `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`, with exactly the accepted three-file SOURCE overlay applied:

- Original **Work14 7,346 entries** and **PIM 536 entries** unchanged.
- SOURCE has **one additional file**, `build_fim_work_ia840f_fim_15.log`, SHA256 `a321d623c615f35ae287566a7ecb73165e96d2f2cbbfa221a2dfc9b0df0d7e34`; no other post-overlay inventory delta. Consequently `source_full_matches_prelaunch_three_file_delta=false` is literally correct. **Do not call the full SOURCE tree byte-identical** or hide the native log addition. Recorded design-source entries remain unchanged after the accepted overlay.
- The collector reports exactly two changed recorded Work15 inputs: `build_env_db.txt` and `fme_id.mif`. Their before hashes match the prepared inventory and their after hashes match P. Captured QPF SHA256 equals its prepared input hash. The collector explicitly compares every recorded input, rather than comparing only those two files (`collect_postflight01.py:16–33`; `postflight-summary01.json:4–44`).

These are verified captured comparisons, not fresh remote inspection or an OS sandbox assertion. Completion's captured process list is empty at **18:49:02 UTC**, and the separately bound postflight has no active Quartus/qsys processes at **18:54:26 UTC** (`completion01.json.gz`, decoded `time/processes`; `postflight-summary01.json:15–20`).

## 2. Actual compile, fit and assembly completed

The exact invocation is `build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_15`, using the recorded Quartus26.1.1 environment. Native status is **rc0**; runner finished **2026-09-22T18:47:29.363718+00:00**, with `gate_rejection=false`, functional acceptance false and readiness false (`L/invocation.json:5–26`; `L/native-status.json:2–3`; `L/status.json:15–24`).

Full flow and fitter reports identify **Quartus Pro26.1.1 Build130, Agilex7 AGFB027R25A2E2V, revision ofs_top, top**, final timing models, successful fit/flow and **66,328 ALMs /175,246 registers** (`P/output_files/ofs_top.flow.rpt:20–41`; `R/ofs_top.fit.summary:1–20`). Effective fitter settings remain **seed2, High Performance Effort, Maximum Placement Effort, MAXIMUM router timing optimization, All Paths hold optimization**; QSF also retains `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON` (`R/ofs_top.fit.rpt:163–205`; `P/ofs_top.qsf:43,128–130`). Turning that already-enabled hold option on is not a new remedy.

Native diagnostic totals must retain their own scopes:

| Native stage | Errors / warnings | Evidence |
|---|---:|---|
| Synthesis | 0 /81 | `L/native.log:8290` |
| Fitter | 0 /208 | `L/native.log:9173` |
| Main Timing Analyzer | 0 /190 | `L/native.log:10450` |
| Post-module Timing Analyzer, PR-constraint emission | 0 /187 | `L/native.log:10464–10466,10931–10932` |
| Assembler | 0 /1 | `L/native.log:11082–11085` |
| Full compilation / outer Quartus shell | 0 /894 | `L/native.log:11208–11218` |

**Do not sum these as disjoint findings.** The two STA invocations each contain 127 top-level332049 ignored-assignment, 50×332174 unmatched-filter and 10×332054 clock-group warnings. The main analysis additionally contains Warning21620 and the two timing/DDR critical warnings. DRC violations and warning-message totals are different accounting units. Explicit “Timing requirements not met” and “DDR Timing requirements not met” survive the successful tool return (`L/native.log:9750,10424`). The small `ofs_top.sdc_constraints.rpt` only lists debug-fabric QIP sourcing; it is not a complete constraint-coverage report (`R/ofs_top.sdc_constraints.rpt:15–30`).

Assembly success is independently reported (`P/output_files/ofs_top.asm.rpt:44,169`). Warning20536 says the legacy `GENERATE_RBF_FILE` setting was ignored; it does not negate the separately captured green-region RBF's existence, nor prove it is an approved runtime-PR payload (`L/native.log:11082`).

## 3. Fresh-fit PCIe clock and constraint progress

Use exact abbreviations:

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
D = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst
M = sys_pll|iopll_0_clk_100m
C = H|avmm_clock0
T = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

The full STA has **110 SDC loading rows, all status OK**; PCIe generated SDC loads before top SDC, and normal later board/internal SDC files still load (`S:2564–2675`, especially `2613,2664–2675`). “OK” means loaded, not that every contained assignment took effect.

The actual final clock table contains **81 definitions: the original Work14 80 plus C**, with every original reported clock field unchanged. C is **Generated**, source **D|inclk**, target **D|clock_div2**, master **M**, divide/multiply **2/1**, noninverted, period **19.858 ns**, waveform **0.000/9.929 ns**. M remains **9.929 ns**, not an assumed nominal10 ns (`S:2683,2754,2759`; compare `W14:2629` onward). The divider target is explicitly **Constrained** in Work15's clock-status report (`S:214971`).

This is not only a clock-table observation: the normal fresh-fit setup path from PCIe `EP_CFG_IF...state.RESPONSE~LRTM_4` to **T** has launch/latch **C/C**, relationship19.858 ns and slack17.489 ns (`S:169254`). Intra-C transfer rows report **1,199 setup RR paths** and **1,138 hold RR paths**, with worst slacks **17.489 /0.056 ns** (`S:156006,156123`). These are native transfer counts, not unique-receiver counts. The old-fit trial's exhaustive known32-cell driving-clock census is **not rebranded as a new Work15 census**; the present fit independently establishes clock definition, T timing and recovered FIFO assignment evaluation, but does not repeat that per-cell API inventory (`../pcie-clock-repair-01/clock-trial02/RESULT-ACCEPTANCE.md:10–18`).

### Eight formerly invalid FIFO net-delay assignments recovered

Matched the exact **From selector, To selector, max type and SDC location**, not sorted position. Work14 and Work15 each contain **146 net-delay assignment summaries**, with identical assignment-key sets. Work14's eight `Invalid clock` rows (`W14:3620–3627`) become these numerical Work15 rows. All have **Required15.886 ns**, worst corner **Slow vid2 100C**, and correctly rounded Required−Actual=Slack:

| FIFO / selector class | Work15 S line | Actual ns | Slack ns |
|---|---:|---:|---:|
| `cplto_fifo_lite_inst`, ws_dgrp chain | 3717 | .307 | 15.579 |
| same, `*rdptr_g*` → ws_dgrp | 3711 | .517 | 15.369 |
| `cplto_fifo_avmm_inst`, rs_dgwp chain | 3715 | .343 | 15.543 |
| same, `delayed_wrptr_g*` → rs_dgwp | 3714 | .485 | 15.401 |
| `u_user_avmm_clk_to_axi_lite_clk_fifo`, ws_dgrp chain | 3716 | .318 | 15.568 |
| same, `*rdptr_g*` → ws_dgrp | 3712 | .516 | 15.370 |
| `u_axi_lite_clk_to_user_avmm_clk_fifo`, rs_dgwp chain | 3718 | .261 | 15.625 |
| same, `delayed_wrptr_g*` → rs_dgwp | 3713 | .509 | 15.377 |

The first two FIFOs are beneath `H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_cplto_if`; the latter two beneath the same prefix plus `EP_CFG_IF.u_pciess_cfg_if`. Chain selectors are `dffpipe*|dffe*` on both sides. Pointer/chain provenance is generated `pcie_ss.sdc:631/:639`, preserved in each full row. **Zero invalid-clock net-delay rows remain**; minimum across all146 numerical net-delay summaries is **1.026 ns** (`S:3577–3726`). This accepts those actual summary observations, not inherited trial per-corner detail counts or an uncollected Work15 exhaustive endpoint census.

Five fresh max-skew tables contain **102 numerical assignment summaries each**, versus94 each in original Work14. Their minimum slacks are **1.185,1.190,1.281,1.247,1.240 ns** in Slow vid2 100C / Slow vid2b 100C / Fast vid2a 0C / Fast vid2a 100C / Fast vid2 100C order (`S:3027–3574`). Positive summaries do **not** establish detailed latest/earliest coverage, per-assignment nonsaturation or complete CDC correctness.

### Exceptions are not newly waived or universally safe

All four M↔C multicycles are still **fully overridden** (`S:219553,219564,219575,219586`). C↔M setup/hold transfer cells literally say **`false path`** and have no numeric slack, although their classification says `Inter-Clock (Timed Safe)`; that classification is not a timed pass (`S:155991–155992,156108–156109`). C↔rx_ch15 is likewise `false path`, classified `Ignored (Not Timed)` (`S:155937–155938,156054–156055`). Preserve those cuts and their unresolved endpoint/precedence coverage; do not credit overridden multicycles or remove exceptions to manufacture coverage.

## 4. Timing FAIL: exact remaining path, not a PCIe-divider failure

Independently parsed the132 summary records and reconciled every timing family's minimum against the full STA tables and multicorner summary:

| Analysis | Worst slack ns | Endpoint TNS ns / failing endpoints | Source |
|---|---:|---:|---|
| Setup | +0.151 | 0 /0 | `S:2829` |
| Hold | **−0.004** | **−0.004 /1** | `S:2861` |
| Recovery | +0.274 | 0 /0 | `S:2893` |
| Removal | +0.137 | 0 /0 | `S:2918` |
| Minimum pulse width | 0.000 | 0 /0 | `S:2943` |

These agree with `S:215036`. Zero displayed margin is not added margin. Native design closure explicitly fails **hold, DDR, unconstrained paths**, and reports **High Severity Violations**, notwithstanding setup/net-delay/max-skew pass flags (`S:2770–2791`). The positive worst setup path is actually PCIe RX-side logic on `sys_pll|iopll_0_clk_sys`, not proof that cut crossings are safe (`S:156265–156280`).

The failing hold path is exactly:

```text
From: local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]
To:   local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1
Launch: local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk
Latch:  local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0
```

**Fast vid2 100C**, no SDC exception; arrival **2.964**, required **2.968**, hold relationship **0.000**, clock skew **−0.080**, data delay **0.288 ns**, **one logic level**. Data contribution: IC **0.101 ns /35%**, cell **0.124 /43%**, uTco **0.063 /22%**. The reported data route is Hyper-Register `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`, including `data_from_core[19]` (`S:126779–126858`). This is not a long routing-majority setup path.

Compared both duplicate native detail presentations against original Work14 (`S:126779–126899,173457–173577`; `W14:126747–126867,172148–172268`, independently hashed `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6`). After whitespace-only comparison, **the only changed detail cell is upstream clock-tree fanout16023→16175** (`W14:126817`; `S:126849`). Endpoints, corner, exception status, locations, path elements, incremental delays, totals and reported slack are unchanged. This proves persistence of the reported failing path, not byte-identical whole placement/routing or raw precision below report resolution. It remains unwaived despite its small magnitude.

## 5. Remaining DRC and coverage gaps

The standalone signoff report and the full STA's embedded rule table match exactly: **23 of88 rules fail**, **34 High violations across seven failed High rules**, **zero waived** (`D:123–149`; `S:215190–215216`). The seven names/counts match Work14:

| Failed High rule | Count |
|---|---:|
| CDC-50001 — 1-Bit Asynchronous Transfer Not Synchronized | 13 |
| CDC-50004 — MUX-type CDC Transfer with Insufficient Constraints | 7 |
| TMC-20027 — Collection Filter Matching Multiple Types | 5 |
| RES-50001 — Asynchronous Reset Is Not Synchronized | 4 |
| CDC-50007 — CDC Bus Constructed with Multi-bit Synchronizer Chains with Insufficient Constraints | 2 |
| CDC-50012 — Multiple Clock Domains Driving a Synchronizer Chain | 2 |
| CDC-50003 — CE-Type CDC Transfer with Insufficient Constraints | 1 |

They include protocol-checker/reset crossings, MSIX FIFO synchronization constraints and PCIe completion-metering crossings, not merely the repaired divider. TMC-20027's five bare-filter ambiguities still occur in generated PCIe SDC442–445/451 (keeper versus cell); repair of C does not repair those types (`S:215294–215399`, especially `215338–215342`). Unchanged counts do not establish unchanged endpoints or safety.

Medium findings include **1,518 unregistered PR boundary ports,1,484 constant PR outputs,1,074 PR inputs not driving registers**,117 ignored/overridden constraints,59 unmatched filters,6 reset-domain findings,1 improper clock target and1 reset polarity conflict (`D:134–141`). Partitioned/elaborated DRC's **0/10** failed rules is a different stage; synthesized DRC still fails **6/13**, and neither supersedes signoff (`R/ofs_top.drc.partitioned.rpt:45–59`; `R/ofs_top.drc.synthesized.rpt:48–64`).

The exact constraint-diagnostic progress is **120→117 ignored/overridden constraints** and **63→59 unmatched filters**. The four removed filter identities are the obsolete divider input, obsolete divider output, obsolete wildcard C name and `*avmm_clock0`; no new unmatched-filter identity was added. The117 remaining rows divide into **48 fully overridden exceptions,36 erroneous exceptions,27 erroneous assignments,6 invalid/no-path exceptions**. The59 unmatched-filter rows are **21 PMCI,20 PIM Avalon FIFO,12 top_sdc_util reset filters,4 top.sdc,2 generated PCIe SDC**. These are DRC rows, not the127/50 warning-message totals above (`S:219520–219712`; compare W14's corresponding TMC-20025/20026 tables). The remaining improper clock target is **SYS_REFCLK already assigned**, not D|clock_div2 (`S:219738–219742`).

**Actual fresh unconstrained-path categories, for both setup and hold:** illegal clocks0; unconstrained clocks0 (Work14 had1); input ports2 with78 pairs; output ports2 with10 pairs. Inputs are `altera_reserved_tdi` and `altera_reserved_tms`; outputs `altera_reserved_tdo` and **`bwbmc_bmc_irq`**. They lack the report-listed delay/exception/skew constraints (`S:214883–214892,214986–215021`; `W14:209848–209853`). The JTAG names do not justify waiving the BMC IRQ, and zero unconstrained clocks does not mean a fully constrained design.

The old-fit trial separately reported **370 `check_timing no_clock` issues**. The present captured full compile reports do not include that separate check_timing census; **do not relabel370 as a freshly measured Work15 count, nor claim it became zero from the UCP clock totals** (`../pcie-clock-repair-01/clock-trial02/result-independent-review01.md:124–126`). Full changed-crossing exception coverage, complete skew detail and those distinct unclocked-object questions remain unqualified. They do not justify another mock/source-review gate before using these actual native results.

## 6. Image identity and deployment boundary

The post-fit hook changes FME interface UUID from **`5c04f735-4245-5537-88d6-380f16bcc372`** to **`fd2baeed-3092-5735-90c9-52ef20542b75`**, followed by a successful MIF/HEX update (`L/native.log:9189–9232`). P's environment and MIF agree: MIF addresses02/03 contain `90c952ef20542b75` / `fd2baeed30925735` (`P/build_env_db.txt:11`; `P/fme_id.mif:12–13`). This explains the two recorded-input changes; the later out-of-date synthesis notice explicitly names the changed MIF and is not evidence of a newly failed native run (`L/native.log:11208–11214`).

**Any new persona/release must match this new base interface UUID and the Work15 base artifact. A Work14 persona is not proven compatible.** Completion captures these remote ordinary-file identities (decoded `completion01.json.gz:artifacts`, basename keys under its recorded output directory):

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ofs_top.sof` | 7,846,348 | `28e194dc7babbf16f7b8a7c4272db1685702b63541be0570bfa8afdf072fb4a2` |
| `ofs_top.green_region.rbf` | 7,258,112 | `866b53dff31a2499215c9c0be8c267fea6e1a2e76ba2237ee8b96d3be7408e41` |

These image bytes were not part of the raw local report exports; the archive binds their captured remote size/hash observations. MSF/PMSF entries are assembler intermediates, not substitute deployment qualification. No finish/release/persona compatibility, runtime PR, flash/JIC/QSPI, DDR calibration/data checking, AHLS numerical behavior or sustained hardware operation is accepted here. No hardware operation was performed by this review.

**Disposition:** retain the native-supported clock correction and accept the completed changed-fit evidence narrowly. The next timing correction must address the actually persistent EMIF1 core→PHY hold path, not pretend the PCIe declaration fixed it or enable an already-enabled option. Keep the34 High violations and specific constraint/coverage gaps open. `timing_accepted=false`, `hardware_qualified=false`, and `ready_for_build=false` remain appropriate. Parent consumption is separate; this report changes no acceptance/CURRENT/tasklist or authority record.
