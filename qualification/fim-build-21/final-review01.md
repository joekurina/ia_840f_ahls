# Work21 independent final-evidence review

**Status: FINAL. Bounded verdict: ACCEPT completed Fitter, assembly and reported constrained numerical STA WITH FINDINGS; CLOSE the prior EMIF1 −0.004 ns hold failure for this exact Work21 build. DO NOT accept complete timing/CDC coverage, electrical signoff, future DDR-persona/PR readiness or working hardware.**

The historical transfer is still analyzed as **Hold**, with the same logical launch/capture and clocks, no path exception, and **+0.082 ns worst hold slack** across the five reported corners. This is not a partial-summary substitution or a fit-only-margin signoff pass. Critical19854/20727/15714 and the failed coverage/DRC results below remain unwaived.

## 1. Evidence scope and completion

Root **E** = `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-21`; repository root **N** = E's grandparent. Citations are native file line numbers unless a JSON field is named:

- **T** = `E/final-capture01/ofs_top.sta.rpt`; **TS** = `ofs_top.sta.summary` in that directory.
- **F** = `E/final-capture01/ofs_top.fit.rpt`; **D** = `ofs_top.tq.drc.signoff.rpt`; **A** = `ofs_top.asm.rpt`; **FL** = `ofs_top.flow.rpt`, all in the same directory.
- **S** = `E/synthesis-capture01/ofs_top.syn.rpt`.
- **I** = `E/prepared-readback01/compile-candidate-01`; **M** = `N/ofs-agx7-pcie-attach`.
- **T18** = `N/qualification/fim-build-18/reports01/output_files/ofs_top.sta.rpt`.

Independently recomputed the sizes/SHA256 of **all 19 final captured members**, matched their manifest, and verified the **6,701,978-byte archive**. Reverified all five synthesis-report hashes and T18 against its original `reports-manifest01.json`. Numerical results below were parsed from original TS/T, **not** `summary-parsed01.json`. Ten specifically used source files were independently matched to I's precompile `work_inventory`; their exact locations/hashes are indexed below. The synthesis review's broader source-provenance accounting is reused, not relabeled as a new full-source audit.

Native runner: `final-capture01/runner/run/native-status.json:2–3` records rc0; `runner/run/status.json:20–24` records finish `2026-09-23T06:24:09.725882+00:00`, no gate rejection and native exit accepted. Its `PENDING REPORT REVIEW` is the preserved pre-review state, not a failed run or a field changed by this report. `status06.json`, `$.diagnostics` and `$.log_tail`, captures native21793: **Full Compilation successful, 0 errors / 1183 warnings**. This is the native total, not a count synthesized from repeated report messages.

Fitter is successful for **AGFB027R25A2E2V**, Quartus **25.1.0 Build129**, final timing models (`ofs_top.fit.summary:1–20`; F:41766; FL:22–41). Final usage includes **67,145 ALMs**, **178,677 dedicated registers**, **302 RAM blocks**, **12 DSP blocks**, **8 PLLs**. Fit completion is accepted, not inferred from synthesis estimates. A:148–168 records PR-base assembly from the final root/green-region databases and successful assembly, 0 errors/1 warning; A:191–193 lists the generated SOF/static MSF/green PMSF.

## 2. The exact EMIF1 failure is numerically resolved

Define literal prefixes solely to shorten the endpoint description:

- `P = local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|`
- Launch = `P` + `emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`
- Capture = `P` + `emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`
- Launch clock = `P` + `emif_1_core_usr_clk`; latch clock = `P` + `emif_1_phy_clk_l_0`.

The following are five **Hold path #1** reports for those exact endpoints, not setup rows or five different endpoints. Each explicitly reports **No SDC Exception on Path**. Thirty literal launch-name occurrences in T reduce to five corner paths plus the repeated multicorner worst path; they are not thirty independent timing tests.

| Native corner | Work18 hold ns | Work21 hold ns | T path-summary lines | T18 path-summary lines |
|---|---:|---:|---|---|
| Slow vid2 100C Model | +0.132 | **+0.242** | 5107–5115 | 5118–5126 |
| Slow vid2b 100C Model | +0.167 | **+0.272** | 35557–35565 | 35554–35562 |
| Fast vid2a 0C Model | +0.047 | **+0.118** | 66015–66023 | 65972–65980 |
| Fast vid2a 100C Model | +0.006 | **+0.086** | 96453–96461 | 96383–96391 |
| Fast vid2 100C Model | **−0.004** | **+0.082** | 126875–126900 | 126779–126804 |

T:183480–183495 repeats the Fast vid2 100C worst hold path in the multicorner section; TS:140–143 independently reports +0.082 for the EMIF1 PHY clock. The observed worst-corner improvement is **0.086 ns**. Required time remains **2.968 ns**, arrival changes **2.964→3.050 ns**, data delay remains **0.288 ns**, and reported clock skew changes **−0.080→−0.166 ns** (T/T18 last-row ranges above). This does not indicate inserted data-delay logic.

**Unchanged signoff is evidenced, not assumed:** I/top.sdc is byte-identical to Work18's precompile-bound top.sdc. Lines151–165 add10ps only under `quartus_fit`, guard both clock collections as singletons, and only print a marker under `quartus_sta`. F:41399 and subsequent fitting stages record `HOLD_MARGIN_APPLIED ... additive=10ps from_count=1 to_count=1`; T:214064 records `IA840F_EMIF1_HOLD_MARGIN_SKIPPED app=quartus_sta signoff_unchanged`. The final QSF differs from I/ofs_top.qsf only in `LAST_QUARTUS_VERSION` at line39; the exact-register retiming-OFF assignment remains at line136. No new false path/hold waiver is responsible for this result.

**Do not attribute the pass to forcing the launch out of a Hyper-Register.** Both generations place the launch at `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` as **Hyper-Register**, through `UFI_X210_Y0_N355`, to `IO12LANE_X184_Y0_N374` (T:126946–126954; T18:126850–126858). All five Work21 details retain that launch type. Presence of the retiming assignment does not prove effective precedence. Work18 used26.1.1 Build130; Work21 uses25.1 Build129. The completed successor establishes a valid numerical remedy under25.1, not an isolated causal proof about retiming or identical cross-version timing models.

## 3. Numerical STA versus timing/CDC coverage

Independently parsed **778 TS records**, all numeric and nonnegative: 134 conventional timing records, 500 maximum-skew records and144 net-delay records. All134 reported TNS cells are0.000; the other644 blocks do not contain TNS and were not assigned invented zeros. These are summary/constraint records, **not778 exhaustively enumerated paths**.

| Category | Records | Minimum reported slack ns | Native TS citation |
|---|---:|---:|---|
| Setup | 18 | **0.216** | 5–8 |
| Hold | 18 | **0.000** | 95–103 |
| Recovery | 11 | **0.242** | 185–188 |
| Removal | 11 | **0.140** | 240–243 |
| Minimum pulse width | 76 | **0.000** | 295–298 |
| Maximum skew | 500 | **1.137** | 675–679; five100-record corner groups |
| Net delay | 144 | **1.024** | 2175–2176 |

T:214905 explicitly says **Timing requirements were met**; T:214910 says Timing Analyzer successful, 0 errors/189 warnings. Zero reported hold/MPW slack is a pass at displayed precision, not positive engineering reserve everywhere.

**Coverage remains FAIL:** T:2790 marks Unconstrained Paths Fail. T:214919–214928 has0 illegal/0 unconstrained clocks but **2 unconstrained inputs and2 outputs**, with **78 input-path pairs and10 output-path pairs**, separately for setup and hold. T:215022–215057 names:

- Inputs `altera_reserved_tdi`, `altera_reserved_tms`.
- Outputs `bwbmc_bmc_irq`, `altera_reserved_tdo`.

The native reason is no applicable I/O delay, min/max delay, false-path exception or maximum-skew assignment. JTAG origin may explain three ports, but is not a waiver; **the fourth is a BMC output**, not inactive HSSI. D's zero missing-I/O-delay rule counts (D:166–169) do not supersede this explicit unconstrained-path report.

### P1 — clock/reset/exception coverage is not accepted

D:123–214 contains **23 failed of88 rules, 4,393 rule-level violation occurrences, zero waived**; overlapping rules/objects are not4,393 distinct functional defects. Counts were parsed with thousands separators. The high-severity failed rules are TMC-20027=19, CDC-50001=13, CDC-50004=7, RES-50001=4, CDC-50007=2, CDC-50012=2 and CDC-50003=1 (D:127–133). These require bounded source/topology disposition, not a blanket vendor-origin dismissal:

- **Actual active-domain examples:** protocol-checker frozen/error/timeout transfers, FLR receipt and MSI-X FIFO pointers (D:258–270); protocol-checker multibit status transfers with unconstrained skew/data delay (D:283–289); two protocol-checker FIFO reset groups and two MSI-X reset groups crossing `clk_100m`/`clk_sys` (D:302–305); MSI-X control-shadow/FLR FIFO buses with unconstrained skew/data delay (D:318–319). These are potential CDC/reset risks, not proof of observed corruption. D:332–346 additionally identifies mixed-clock synchronizer inputs and the10-bit completion-timeout transfer.
- **Clock existence is established, exception correctness is not.** `avmm_clock0` is present as Generated, period19.858ns, sourced from `iopll_0_clk_100m` (T:2753; I/top.sdc:35–38). All four associated multicycles at top.sdc:58–61 are **fully overridden** (D:4471,4500,4511,4522); top.sdc:52 explicitly groups those clocks asynchronous. Resolve the intended relationship and effective exceptions from source/evidence before claiming those crossings are timed. Do not patch the clocks as part of this review.
- **Confirmed ineffective memory-clock selector:** top.sdc:53 uses `mem_ss_inst`, whereas the actual EMIF clocks use `mem_ss_sv|mem_ss`; T:214001–214003 and D:4537 report no match/no covered paths. Reset/calibration selectors at top.sdc:126,135–136 also have rejected constraints (D:4559,4562–4563,4573,4576,4578). Determine whether each is obsolete/optimized or an active intended crossing; the hold pass does not settle that question.
- **Narrowly explained diagnostic, not missing refclk:** top.sdc:27's duplicate SYS_REFCLK creation is ignored (T:213990; D:4689), but native `sys_pll|iopll_0_refclk` already constrains SYS_REFCLK at10.000ns (T:2764,214939). D:154–157 reports zero missing/multiple/invalid generated/invalid clock assignments. These bounded negatives do not close CDC or exception coverage.
- D:137–138 reports117 ignored/overridden constraints and59 empty filters. PMCI-specific missing targets are consistent with disabled INCLUDE_PMCI (final QSF:100; bound pmci_top.sdc; D:4473–4488), **not an explanation for every entry**. TMC-20027 includes PCIe and both memory MSA/reset collections (D:227–245); the generated PIM FIFO empty-filter cases include active host-channel paths as well as idled local memory (D:4601–4613). No blanket waiver is justified.

## 4. PR retained, but later DDR persona not qualified

**Region-loss concern narrowed:** F:248–256 retains `green_region` at `afu_top|pg_afu.port_gasket|pr_slot|afu_main` as Reconfigurable. F:38494–38513 reports the actual placement regions `(301,0)–(390,20); (101,21)–(390,100); (0,101)–(390,333)`, route region `(0,0)–(390,333)`, **7,270.0 ALMs used in final placement** and11,973 dedicated registers. These agree with bound `pr_assignments.tcl:24–33`. Thus15705/15706 at F:41634–41635 does **not** establish that the PR region vanished. Exact diagnostic-stage semantics remain unexplained, but a repeat fit solely to check region presence is unnecessary.

**P1 — boundary retention remains open despite a populated region.** F:260–1340's complete dangling-boundary panel has **1,076 inputs**, not the50 example20728 messages:

| Boundary group | Exact per-bank members | Count |
|---|---|---:|
| `ext_mem_if[1]` | `bid[0..8]`, `bresp[0..1]`, `buser[0]`, `rid[0..8]`, `rdata[0..511]`, `rresp[0..1]`, `rlast`, `ruser[0]` | 537 |
| `ext_mem_if[0]` | Same member/range set | 537 |
| `remote_stp_jtag_if` | `vir_tdi`, `reset` | 2 |

All belong to green_region. D's1,074 BBD-60001 inputs (D:3381 onward) exactly match the DDR subset; the two remote-STP inputs are additional Fitter rows, not a counting error. D:134–136 also reports BBD-60000=1,518 not-directly-registered ports and BBD-60002=1,484 constant output ports. Do not add these overlapping classes or call them cleared by area retention. **Critical20727 remains unwaived** (F:40973).

Bound `ofs_plat_afu.sv:147–154` deliberately idles read/write/address/data on both local memory banks; bound `ahls_ofs_board_services.sv:53–68` still instantiates each bank's clock-crossing/three-stage mapping. This explains why the present scalar AFU has constant requests/unused returns, but **does not prove the exported static boundary can support a later DDR-using persona**. Smallest remaining check: exact required future memory/debug port preservation and PR-interface compatibility against the retained partition/export evidence, not a generic `noprune` patch, PR disablement or an unchanged build.

**P1 — PR initialization remains open.** Critical19854 at S:132304 refers to54 grouped rows in S:122640–122693, all Low and `Derived from Assignment=No`; ranged rows are not single-bit counts. They include reset pipes, both memory mappings, arbiter state and RAM-address registers. Bound `fim_dup_tree.sv:27–35` and `afu_main.sv:99–105` explain reset initialization, not a sufficient reset/first-use sequence for all54 rows. Disposition the concrete arbiter/RAM/reset cases under the intended PR reset protocol. Assembly success is not that proof.

## 5. Electrical and image boundaries

**P1 — Critical15714 identifies three real BMC pins**, not just unused QSFP/CPRI. F:6985–6992 gives **Missing termination setting and slew rate** for each:

| Pin | Location / fitted direction | Native fitted pin citation |
|---|---|---|
| `bwbmc_bmc_irq` | L56 / output | F:6486 |
| `bwbmc_bmc_mst_en_n` | N57 / output | F:6518 |
| `bwbmc_fpga_max_miso` | U53 / bidir | F:6580 |

All are in Bank3A, fitted1.2-V; bound `top_loc.tcl:82–93` assigns those locations/standards. F:2583–2584,2651 also shows fitted slew value2 and series40-ohm-without-calibration behavior. Effective/default choices therefore exist, but the report still lacks explicit termination/slew assignment acceptance. Native completion neither proves electrical adequacy nor establishes those defaults are unsafe. The remaining check is the exact board BMC interface/load requirements against these settings, including IRQ timing; no hardware discovery is authorized.

**Assembly accepted, deployment not accepted.** A:165's20536 says legacy GENERATE_RBF_FILE was ignored; do not use that setting as proof of a qualified programming payload. The collector's image inventory (manifest:4–24) records a SOF of7,901,287 bytes, SHA256 `bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4`, and a base-compile green RBF of6,922,240 bytes, SHA256 `0b22d42f4262a35a9494135461a052d5fb85e122d21be473fe36baed822bb740`. **These are hash-only capture identities; the image bytes were not locally independently rehashed in this review.** The base green RBF is **not a qualified persona GBS**. No accepted persona packaging, runtime PR, programming, DDR data-check or electrical measurement is supplied by this compile.

## 6. Disposition and remaining scope

1. **Close only the historical EMIF1 numerical hold blocker for Work21** and accept its fit/assembly/constrained numerical timing milestone. No unchanged rerun or additional hold-margin escalation is justified by this evidence.
2. **Keep complete timing/CDC acceptance open:** explicit unconstrained I/O plus the named active clock/reset/exception findings require source/effective-constraint disposition. This is not a finding that every DRC row is a real defect.
3. **Keep PR/DDR-persona acceptance open:** retain19854/20727, the exact dangling boundary inventory and object-specific reinitialization requirements. The positive region-retention evidence narrows, but does not remove, those risks.
4. **Keep electrical acceptance open:** retain15714 on the three BMC pins and the BMC IRQ coverage gap. Resolve board requirements from evidence rather than choosing arbitrary assignments.
5. Reuse `synthesis-review02.md` for remaining bounded width/driver issues. In particular `top.sv:602` connects a40-bit export to an implicit1-bit unconsumed top net (the intended prefixed40-bit declaration is at179); **do not infer an active internal MSI-X truncation failure**. Native376 synthesis warnings versus430 top-level textual occurrences remains unreconciled; this review does not recategorize all1183 or fabricate warning-clean status. The prior source map's18 current-only identities remain a provenance limitation, not proven mismatches.

**DDR simulation: SKIPPED BY USER. Hardware/functional acceptance: not established.** This report adds no source/build/programming authorization, changes no readiness flag, supplies no waiver and creates no new source-approval loop. The parent alone operates the workstation. Only this report was authored; no SSH, native/vendor tool, simulator, hardware access, source edit, git action or task transition was performed.

## 7. SHA256 and source index

All hashes below were recomputed locally, except the explicitly labeled image inventory above. The manifest binds the complete19-member native set, including stage reports, QPF, MIF and runner receipts; this selected index avoids duplicating its entire inventory.

| Evidence relative to E unless noted | SHA256 |
|---|---|
| `final-capture01/manifest.json` | `01f63ade17df65235b5986bbf5992278bc146afebc54c2a36cc81f5bed6fb659` |
| `final-capture01/result01.json.gz` | `33a796362be5d2ec098d66993dc3cc519f6bdffe76f844a3329a17cbf74fbb4c` |
| T | `6bddd20bb0294b654593a000b1aec2476bc009995b9767041aeed36c1550479a` |
| TS | `03556e185fa8910e3734ca02dfe0c59b212ddd6823d3cd46089359e9bee8d7ed` |
| F | `e2dc82d95bf5e0fe0ae7b210850a4a5565ba694dff5a1158928b8086cac5aded` |
| D | `da3c4ec1ae72853833d0ad015c7c96010282d6f80eba5dbe4c44519d4a4fde3d` |
| A | `f2fa908764a71b898cb6c922f0866af3e41c5037dc242bb935b1c4b35036789e` |
| FL | `75486dadc0a78884d7dae08dc12b30089c9db1caf43a6936ab5c9f6a7f832dd9` |
| `final-capture01/project/ofs_top.qsf` | `801d9ae71588011828e6c217effb0c2292fadec8a08c39ebc5bd972549ca0256` |
| `I/compile-authorization.draft.json` (input inventory, not new authority) | `a27d5a15ecaea909eea081e7c0ab52956db6cd91e0a6202f2fb712c4b1dad09e` |
| `I/ofs_top.qsf` | `e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f` |
| S | `0b41ed02e5b63ec4bff9eef506dd71100eaa3893ce794c4ff532082fef1c00dc` |
| T18 (historical native comparison) | `ca2ed19589bc01e6bfac1028bd3a0cbdd50a6f0f801677cdce58ab7d42bc5020` |
| `status06.json` | `0b76b7f228e242a68f61efbbb1af94f390d138e28fb2ad2929293b0a6315a5f1` |
| `synthesis-review02.md` (reused derivative review) | `d38445bbe58c59d0e49b3f01987c1c81905acecb92271fce4921c615858c389a` |

These10 source files match the corresponding Work21 precompile inventory hashes. Prefix **O** below is `N/qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/afu_with_pim/afu/hw`; retaining the file there does not relabel that entire historical tree as Work21.

| Exact local source location | SHA256 |
|---|---|
| `I/top.sdc` → native `syn/shared_config/top.sdc` | `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814` |
| `M/syn/shared_config/top_sdc_util.tcl` | `8006c9c497629945e4c5136af38d5b3bee5202d9a43332509c11209697e2ea43` |
| `M/syn/shared_config/pmci_top.sdc` | `d3b8135e34541e86353f9b8a3522681e9e1c3dee70c1d73454af572a6e78e0c4` |
| `M/syn/board/ia840f/setup/pr_assignments.tcl` | `ee691738de4804222453ee1bacf82535ed7c57df6b05819008b6a97df8e6cd61` |
| `M/syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `M/src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `O/ofs_plat_afu.sv` | `3638a59ec7d811c16d9d1e738ca57b606ee3cb9b8cc5bdb15b75ce965c8f12fb` |
| `N/afu/ahls/rtl/ahls_ofs_board_services.sv` | `823aa941b8f7dc2addba78d0f9748cf3d22b2429e2e2835d6567099f235294a9` |
| `M/ofs-common/src/common/lib/sync/fim_dup_tree.sv` | `c9481b8534e4e200e0ff43aa1a44375ee5a3e58598a40364610b6860deb518ae` |
| `M/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv` | `ea02940bc34e6fa33e142e429bbb0df8db893239880c8e15ba6039751bfe8e1c` |

**Final acceptance boundary: offline fit/assembly and reported numerical STA pass; exact EMIF1 hold failure resolved; complete coverage, PR-persona, electrical and hardware acceptance remain open.**
