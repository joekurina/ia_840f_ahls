# Work21 synthesis review02

**Status: FINAL. Verdict: ACCEPT WITH FINDINGS, for the completed native synthesis evidence only.**

The captured native result is valid evidence of successful synthesis for **AGFB027R25A2E2V**, Quartus Prime **25.1.0 Build 129**, revision `ofs_top`, top entity `top`: **0 errors / 376 warnings**. The previous elaboration failure is not present in this completed successor. This is **not** a warning-clean or DRC-clean design verdict. Explicit PR initialization, boundary preservation, selected reset/clock issues and incomplete warning accounting remain open. A definite source connection-width mistake is identified below, but no active functional failure is established by that mistake alone.

Accepting this synthesis-stage result does not accept Fitter, final STA, CDC, PR deployment, DDR operation or hardware. It does not change any readiness/qualification flag, authorize another launch, require an unchanged rerun, or create a new launch-approval barrier. Work21 was already fitting; the latest snapshot reviewed here is `status04.json`, UTC `2026-09-23T05:43:47.590506+00:00`, with planned database commitment and periphery-placement completion, not a completed fit. The parent alone operates the host. **DDR simulation: SKIPPED BY USER.**

## 1. Evidence and limits

Only preserved local files were read. No SSH, vendor tool, simulator, hardware access, source edit, git write or gate transition was performed. An `IN_PROGRESS` draft of this file was written early and updated before finalization. The interrupted review01 had no terminal verdict; its private transcript was not treated as review evidence or a conclusion.

Citations below use:

- **S** = `synthesis-capture01/ofs_top.syn.rpt`; **AE** = `synthesis-capture01/ofs_top.syn.ae.rpt`.
- **DS** = `synthesis-capture01/ofs_top.drc.synthesized.rpt`; **DP** = `synthesis-capture01/ofs_top.drc.partitioned.rpt`.
- **I** = `prepared-readback01/compile-candidate-01/`; its `compile-authorization.draft.json` supplies the recorded precompile `work_inventory`, not new authorization.
- Source paths in the findings are the literal native File reference suffixes. Their retained local locations and SHA256 bindings are documented in section 6 and `warning-source-capture01/manifest.json`. Board/common sources resolve under repository `ofs-agx7-pcie-attach/`; captured generated sources resolve under `warning-source-capture01/files/<absolute native path with leading slash removed>`.

Recomputed and matched all **5 report sizes/hashes**, both archive hashes, all **46 captured source sizes/hashes**, and all **31 previously matched local source hashes**. The combined warning File-reference map has **77 available files**. Direct comparison with I's Work21 inventory confirms **59 precompile matches**: 31 local plus 28 captured. The other **18 are current-byte hash-verified only**: 15 synthesis-generated `tmp-clearbox` files and 3 historical AHLS paths under `work_ahls_afu_fim_01`. There were no mismatches against a recorded input where one exists. Missing earlier bindings are evidence scope, **not automatically source defects**. Additional specifically cited local files were compared separately to exact Work21 input hashes.

S:1335–1345 and `ofs_top.syn.summary:1–9` agree on target/version/success. The summary gives 67,819 estimated ALMs, 169048 dedicated registers and 12 estimated post-merging DSP blocks; these remain synthesis estimates, not final fitted usage. Work21's retained QSF/SDC/EMIF configuration and narrowly replaced 25.1 debug leaf are the reviewed iteration context, not a claim of full IP regeneration or deployment.

## 2. Native 376-warning reconciliation

**The authoritative native total is 376**, explicitly printed at **S:132568**. The following are distinct report representations, not competing replacements for it:

| Representation | Measured result | Counting rule |
|---|---:|---|
| Synthesis Messages, S:124254–132574 | 430 top-level records | Unindented `Warning (ID):` / `Critical Warning (ID):`; 429 Warning and one Critical19854 |
| Indented child warnings in the same message section | 354 | 49 ID13410, 9 ID14285, 295 ID14320, 1 ID22471 |
| All warning-severity message occurrences | 784 | 430 parents/top-level plus354 children; not784 independent warnings |
| Per-file/General Warnings summary rows, S:122932–124250 | 80 rows | Severity-bearing rows only; retain composite IDs such as `14284:14285:14320` |
| Sum of the summary rows' native Count cells | 763 | 418 across75 single-ID rows;345 across5 composite-ID rows |
| Recovered diagnostic-shaped S rows | 864 | Exactly80 summary rows plus784 message rows; do not add their counts |
| AE Messages, AE:91162–98424 | 408 | Every `(severity, ID, full text)` occurrence is also present in S, with matching multiplicity; do not add AE to S |

Composite summaries are `18059:22471`=1, `13024:13410`=48+1 and `14284:14285:14320`=215+80. Their leaf-count sum345 is not a count of new parent messages. The remaining12 parent messages (nine14284, two13024, one18059) and nine intermediate14285 children explain the difference between763 summary leaf/single-message occurrences and784 hierarchical message occurrences. Per-source nested samples and report/log copies were not added again.

### ID occurrence inventory from Synthesis Messages only

These are occurrence counts at the displayed hierarchy level, **not an allocation of the native376**.

| ID | Top-level | Nested children |
|---|---:|---:|
| 13024 | 2 | 0 |
| 13410 | 0 | 49 |
| 13438 | 6 | 0 |
| 13461 | 3 | 0 |
| 13469 | 184 | 0 |
| 13471 | 27 | 0 |
| 14284 | 9 | 0 |
| 14285 | 0 | 9 |
| 14320 | 0 | 295 |
| 16752 | 2 | 0 |
| 16753 | 4 | 0 |
| 16788 | 16 | 0 |
| 18059 | 1 | 0 |
| 18410 | 8 | 0 |
| 19854 | 1 | 0 |
| 21610 | 156 | 0 |
| 21705 | 2 | 0 |
| 22471 | 0 | 1 |
| 22568 | 1 | 0 |
| 23762 | 1 | 0 |
| 24420 | 1 | 0 |
| 24541 | 5 | 0 |
| 276020 | 1 | 0 |
| **Total** | **430** | **354** |

**Unresolved accounting:** 430 top-level textual records exceed the native376 by54. Exact-text deduplication yields418 top-level strings, still not376, and is not a valid fix: identical14284/13024 parent text introduces different child sets, while three A&E source messages also repeat verbatim. Neither text identity nor source origin proves distinct/suppressed native-message semantics. No retained count-semantics/message-database breakdown was found that establishes which54 records the native total excludes. This report preserves that discrepancy rather than declaring 430,418,763,784,864 or1272 to be the warning total. The number54 also happens to occur as a PR table row count below; no causal connection is inferred.

## 3. Priority findings: PR, DRC, clocks and reset

### P1 — Critical19854: PR initialization — potential risk, not waived

**Evidence:** S:132304; explicit PR power-up panel S:122636–122693. It contains **54 grouped register-name rows**, all `Low`, `Derived from Assignment=No`; rows containing ranges are not single-bit register counts. They include `dup_rst`, per-port/user-clock reset chains, both local-memory reset mappings, PIM arbiter state and RAM address registers. This is not just a generic warning without an affected-object list.

**Source:** `fim_dup_tree.sv:27–35` initializes `dup_tree` and `dup_leaf` then shifts the input; `afu_main.sv:99–105,350–365` initializes and distributes reset; `map_fim_emif_axi_mm_to_local_mem.sv:24–31` initializes `mb_rst_n` and clocks the incoming reset. These explain important entries, but do not prove the complete set has a sufficient reset/reinitialization sequence after PR. RAM-address and arbiter-state entries cannot be dismissed merely because other entries are reset pipes.

**Disposition:** retain Critical19854 as **potential PR/reinitialization risk**. The smallest remaining source/result check is an object-specific reset/first-use disposition for the explicit table, especially the arbiter and RAM address entries, with the final retained PR boundary. This is not an instruction to add arbitrary resets, disable PR or run hardware. The separate root-partition **Registers with Power-Up Settings Ignored** panel (S:112878 onward, including EMIF/reset-controller state) is a different finding; neither panel proves vendor memory reset behavior. Existing vendor reset/hardware qualification is not reopened as an exhaustive internal-IP audit by this review.

### P1 — PR inputs, constant memory outputs and region retention

**Evidence:** S:4614–4621 retains `green_region` at `afu_top|pg_afu.port_gasket|pr_slot|afu_main` as **Reconfigurable**. S:132494–132543 contains the48 nested constant-output messages for its two memory interfaces. Snapshot03 `log_tail` records fitter-start Critical20727 and example20728 children for dangling `ext_mem_if[1].bid[0..8]` and `bresp[0]`, followed by `Info (20186): ....`; this is not the complete unused-port inventory. Snapshot04 `log_tail` records15705/15706 saying the assigned `afu_main` node does not exist. These latter diagnostics are **Fitter-start/in-progress observations**, not additional synthesis warnings or final Fitter panels.

**Source justification:** the hash-matching retained `ofs_plat_afu.sv:139–154` explicitly idles host/local-memory request interfaces; both local banks have read/write/address/data controls tied off in this scalar AHLS qualification AFU. The bound `ahls_ofs_board_services.sv:53–68` still maps the banks. Thus constant memory requests are **source-justified expected for this AFU**, not evidence that the EMIF subsystem disappeared or that DDR works. Unused return inputs are consistent with that workload, but **boundary preservation for later personas remains a separate potential risk**.

**Unresolved:** final **Fitter Partition Summary**, **Logic Lock Region Constraints/Usage**, and complete unused PR-port detail are needed to distinguish harmless hierarchy transformation from lost/ineffective region constraints and to resolve20727. Do not conclude region loss from15706 alone; synthesis proves only the earlier partition. No generic `noprune` patch is authorized or recommended without the actual affected boundary inventory.

### P1/P2 — Native DRC results and source disposition

DS:48–64 reports **6 of13 rules failed,19 violations,0 waived**. DP:45–58 reports **1 of10 rules failed,1 violation,0 waived**. These are rule/object counts, not counts to add to376.

| Rule / native severity / count | Evidence and interpretation | Classification and remaining check |
|---|---|---|
| RES-30132 / Medium /6 | DS:77–82: `afu_main|pclkDiv4_q1/q2`, `pclkDiv2_q1/q2`, `afu_top|clk_div2_q1/q2`. `afu_top.sv:188–197` and `afu_main.sv:377–389,422–429` explicitly use noprune feedback consumers to retain clocks. | **Source-justified expected** for these six consumers. They are not functional generated-clock dividers; no reset patch is justified by this rule alone. Does not clear other reset paths. |
| LNT-30023 / Medium /1 | DS:95: MSI-X `intc_st_cpl_tx_tvalid` drives67 non-inverted and85 inverted synchronous-clear uses. Bound `ofs_fim_pcie_ss_msix.sv:312–331` selects completion versus interrupt headers with this signal; it is a data/header select, not a board reset. | **Source-justified expected topology** from synthesis of header selection. No evidence of an external reset polarity error. This explains the named rule, not all MSI-X behavior. |
| LNT-30010 / Low /5 | DS:108–112: four PCIe-reset-tree branches reach protocol checker/ST2MM controls; MSI-X `u_rst_stclk_sync1|dreg[1]` also reaches1691 asynchronous reset signals and2 clock enables. | **Potential reset-distribution risk / incomplete evidence.** Mixed uses are not automatically a defect, but reset deassertion/recovery and actual timing must cover the specific groups, particularly MSI-X asynchronous users. |
| TMC-20501 / Low /4 | DS:125–128: requested6→implemented0 for PR reset and two bank soft resets;3→0 for `pg_flr_port_map`. Native reason: all fanout in same hierarchy. | **Source/native-justified optimization outcome**, not proof of missed functional reset. Physical fanout/timing remains for fit/STA. |
| TMC-20500 / Low /2 | DS:141–142: depth7/implemented6 at PR port reset, non-register-fed root; depth10/implemented6 at `rst_clk100m_resync`, hierarchy-depth limit. | **Potential timing/fanout risk**, bounded native reason known. Do not assume an ineffectual setting was consumed as requested. |
| FLP-10500 / Low /1 | DS:155: only `qsfp_ref_clk`. `top.sv:44–45` deliberately retains the Bank9A reference with HSSI disabled; I/ofs_top.qsf:102 disables INCLUDE_HSSI. | **Source-justified expected nonfunctional input use** at this stage. Pin/clock-only preservation and electrical assignment remain distinct from logic fanout. Do not remove this reference port. |
| LNT-30020 / Low /1 (elaborated) | DP:71: BMC SPI reset controller `reset_out_pre_reg`. Native parameters S:46364–46394 select deassert synchronization, depth2, assertion minimum3. A byte-identical Work21-bound `altera_reset_controller.v:269–281` uses `reset_out_pre` in async assertion and the clocked data assignment. | **Source-justified expected vendor reset-controller construction**, not proof of erroneous reset wiring. No vendor-source change warranted. Final reset timing remains separate. |

The tested **combinational-loop** rule LNT-30011 and **post-synthesis inferred-latch** rule TMC-20052 report zero (DS:58,62); reset-release instance-count and reachability checks also report zero in their respective tables. This is a bounded native negative result, not universal functional/CDC proof. ID16752's two potential always loops are source `$display` parameter-error branches (`ofs_plat_shim_ccip_async.sv:225–235,347–357`), not a demonstrated synthesized combinational loop. Their source intent plus successful elaboration and the zero loop rule support **source-justified expected diagnostics**, not a simulation result.

### P1/P2 — Clock/reset assignment diagnostics and timing boundary

- **13471 (27 occurrences):** pcie_wrapper reset assignments2; afu_top reset assignments17; pr_slot clock/reset assignments8. `pcie_ss_axis_if.sv:16–19` declares the corresponding interface inputs as **wires**. `afu_top.sv:121–164,281–289`, `pcie_wrapper.sv:163–164`, and `pr_slot.sv:164–174` deliberately provide interface clocks/resets through hierarchical assignments. These are **source-justified wiring-style warnings**, not by themselves multiple-driver or missing-clock proof. The review does not certify all effective clock propagation from syntax alone.
- **16788 clock fields:** S:130411–130413 identify unconnected `.clk` on three protocol-checker interfaces declared with `()` at `afu_intf.sv:73–77`. The module's sequential logic and instantiated consumers use explicit `clk` (e.g.238,435,471,514,550,579), and interface assertions are translate-off (`pcie_ss_axis_if.sv:58 onward`). This supports a metadata/assertion-field explanation; **complete downstream clock-use coverage is insufficient** to claim a global harmlessness waiver. These three strings are not evidence that the entire protocol checker is unclocked.
- **18059→22471:** S:131857–131858 names `rst_clk100m_resync...dup_leaf[0]~SynDup_14` feeding `fme_csr|rom_state[1]` ACLR; duplication is disallowed for that use. Source `fim_dup_tree.sv:24–35` requests MAX_FANOUT and hierarchy duplication. **Confirmed ignored optimization request; potential physical reset-fanout/timing risk**, not an ignored functional reset or SDC clock definition.
- **Fitter-start PMCI warnings:** snapshot04's retained tail has332174/332049 for missing `qspi_data[*]`, `flash_qspi_clk` and M10 GPIO targets. `pmci_top.sdc:85–98` contains those exact constraints; I/ofs_top.qsf:100 leaves INCLUDE_PMCI disabled. **Source-justified inactive-feature constraints for these named targets only.** The tail is truncated; it cannot establish that all ignored SDC warnings are harmless.
- I/top.sdc:35–38 preserves the explicit PCIe `avmm_clock0` generated-clock definition. Snapshot04 lists that clock at19.858ns and the EMIF/user clocks. I/top.sdc:151–165 confines the10ps EMIF1 hold margin to `quartus_fit`; snapshot04 contains its applied marker. **Clock presence and marker emission are not final propagation/exception coverage or a hold pass.** Existing PCIe clock, ignored-constraint, EMIF hold and all-corner STA qualifications stay open. Require actual completed signoff, including the STA skip marker for unchanged signoff, rather than claiming synthesis closes them.

## 4. Width, undriven nets and lower-priority groups

### P2 — Confirmed source issue, with bounded impact

**24541 at S:130369 / top.sv:602:** a40-bit `pcie_wrapper.ss_app_st_ctrlshadow_tdata` output is attached to the1-bit implicit top-level net `ss_app_st_ctrlshadow_tdata`. `top.sv:178–179` instead declares the unused `p0_ss_app_st_ctrlshadow_tdata[39:0]`; the actual unprefixed name occurs only at the connection. `pcie_wrapper.sv:49–50` proves output direction. This is a **confirmed source declaration/connection-width defect**, not an intentional correctly declared40-bit connection. The observed export has no other top-level consumer, so this review does **not** infer that it truncates the internal MSI-X control-shadow path or causes a live failure. The smallest correction decision is to confirm the export is intentionally unused or bind the correctly sized intended net in a future reviewed source change. Do not change the running input.

**22568 at S:130424 / mmio_rsp_bridge.sv:298:** scalar `VF_ACTIVE` is bit-indexed in completion-ID construction, while line277 uses the scalar directly. This is a **confirmed native type/index diagnostic; functional impact unresolved**, not grounds to invent a new PF/VF layout. Resolve the warned instance's elaborated scalar value and actual completion-ID bit before proposing an edit.

### P2 — Source-justified narrowing/specialization at specific sites

- **AHLS aperture13469, S:130512,64→17:** `ahls_mmio_aperture.sv:25–44` computes base-relative word address while gating read/write with `in_csr`, reset, no outstanding request and burstcount1. Bound `ofs_plat_afu.sv:74–75` selects base64 bytes,size256 bytes: accepted word addresses8–39, offsets0–31, comfortably representable in17 bits. Wrapped subtraction outside the aperture is not issued as a CSR request. **Source-justified expected narrowing** at this site; no full MMIO functional test was run.
- **MSI-X13438 (six dead case items),16753 at3157, and the largest13469 subgroup (107):** native S:18189–18207 sets table size7, static allocation,2PF+1VF. Source `ofs_fim_pcie_ss_msix_table.sv:152–165` yields21 entries,5-bit table address,1-bit PF selector and one64-bit PBA word. Thus the six PF2–7 case items at3313–3318 are unreachable, and shifting that5-bit table index by6 at3157 correctly selects PBA word0. These exact diagnostics are **source-justified expected specialization**. The107 truncations include other counters/fields; the demonstrated cases do **not** waive all107 or all184 ID13469 occurrences.
- **FME24541, S:130371–130373:** source `fme_top.sv:171–210` uses a21-bit pfa_master and20-bit AXI address connections; native S:12607 binds `ST2MM_MSIX_ADDR` to `0x40010`, which fits both. The request is a fixed interrupt write and read is tied0. **Expected for this fixed-address path**, not proof that arbitrary21-bit addresses may be discarded elsewhere.
- **AHLS21610 zero-width outputs, S:130726–130727:** native S:76060 and76089 sets WIDTH=0 for the two branch/merge FIFOs. Captured historical `acl_mid_speed_fifo.sv:127–133,384–500` gates RAM/data generation on WIDTH>0. This supports **expected control-token/no-payload specialization**, but those historical source bytes are not precompile-bound. `cra_ring_node.sv` declares `avm_enable` and `avm_burstcount` (46,48) without driving them, matching S:130728–130729. **Their consumer irrelevance remains insufficiently established**; do not claim harmlessness solely because they are generated AHLS files.

### P2/P3 — Undriven, tied-off, optimized and pragma groups

- **21610 (156):** most occurrences are AXI sidebands/unused outputs, not156 missing datapath clocks. Entity occurrence counts include `axi_lite2mmio`55, `ofs_fim_axi_csr_slave`18, PCIe debug log12, `ss_tie_off`27, `ptile_tie_off`6 and the two-bank local-memory mapper6. At `map_fim_emif_axi_mm_to_local_mem.sv:44,52,74`, QoS/WUSER assignments are deliberately commented; S:130707–130712 ties those exact outputs to ground. **Source-justified omitted sidebands at these sites**, not a blanket electrical/protocol proof for every default-grounded output. The remaining active-looking response/metadata uses retain **insufficient evidence** until their consumer/valid gating is traced.
- **16788 (16):** includes interface metadata, `vf_flr_cnt`, PIM `.last`/read data, CSR storage and inactive CPRI wires. S:13221–13230 gives the PF0-only `flr_rst_mgr` NUM_VF=0; source `flr_rst_mgr.sv:67–68,127–150` uses the parameterized VF array and zero-iteration loops, explaining the phantom VF counter at S:130421. This does not waive the distinct active VF instance. The complete16 are not all clock faults and are not all proven harmless.
- **13024→13410:** two parent groups and49 child records:48 PR memory-output rows plus the board `bwbmc_bmc_mst_en_n` grounded output. The PR-memory group has the explicit idle-AFU source justification above. **BMC output electrical/operating intent is not established by a constant-output message alone**; it is not a new synthesis-launch blocker.
- **14284→14285→14320:** nine parents, nine intermediates,295 synthesized-away RAM-node records (215 attributed to afu_main,80 to top in per-source summaries). Optimization is native fact, not proof of corruption. Source-idled memory paths justify some pruning; **no claim that all295 removed nodes are irrelevant** is made. Generated temporary-source hash coverage does not supply earlier input bindings.
- **18410 (8)** unconnected RAM `eccstatus` ports and **276020 (1)** inferred synchronous RAM with added read-during-write pass-through at `mmio_handler.sv:56` are implementation/monitoring observations. **Potential monitoring/resource/timing implications, no confirmed data fault**; inspect retained configuration/usage before assigning stronger meaning.
- **21705 (2)** ignores synthesis `$fatal` tasks at `ofs_plat_prim_fifo_lutram.sv:255,261`. Source244–271 retains hardware `error` state and flow control. **Expected simulation-task exclusion**, not a failure assertion firing or proof that the FIFO was exercised.
- **13461 (3)** parameter/localparam declaration behavior, **24420 (1)** mixed valid/invalid pragma at `ofs_fim_pcie_dm_req_splitter.sv:298`, and **23762 (1)** hierarchy sweep are **lower-priority/incomplete evidence** unless effective parameter overrides, memory inference or required hierarchy preservation depends on them. Do not waive them on vendor provenance alone. The source-supported material PR/hierarchy question is already isolated above.

## 5. Precisely unresolved, without expanding execution scope

1. **Native warning accounting:** explain the54-record difference between430 displayed top-level occurrences and376 native warnings using existing native message accounting/suppression metadata if retained. No equality was forced; no rerun is needed merely to restate the native summary.
2. **PR initialization and boundary:** disposition the54 grouped explicit-power-up rows by reset/first use; review final partition/Logic Lock usage and complete20728 details for unused memory returns. Synthesis retention does not close the in-progress15706 observation.
3. **Reset/clock coverage:** resolve the five LNT-30010 groups and specific ignored duplication branch with actual reset/timing evidence; distinguish the three interface-clock metadata nets from effective downstream clocks. Final all-corner STA/clock coverage and the existing EMIF hold issue are not supplied by these reports.
4. **Electrical/I/O:** Critical15714 has no completed **I/O Assignment Warnings** panel in this capture. The exact deficient pins/assignments cannot be named from that prose. Do not assume it is only unused QSFP/CPRI pins, and do not treat offline compile acceptance as electrical acceptance.
5. **Selected width/driver issues:** decide the unused control-shadow export's intended declaration/connection; bind VF_ACTIVE's effective completion bit; trace AHLS CRA enable/burstcount and any active PIM metadata consumers not justified above. Remaining MSI-X/general narrowing cases have not all been behaviorally proved safe. These are bounded source/result checks, not a mandate for generic simulation or a speculative source patch.
6. **Evidence provenance:** the15 generated temporary files and3 historical AHLS files remain without earlier bindings. Only seek a retained matching source/archive binding if a consequential conclusion depends on one; absence is not an observed source mismatch. The existing DDR/hardware qualification remains separate and simulation stays skipped.

No new confirmed functional defect requiring interruption of the current offline Fitter was established. This is not a promise of eventual fit, timing, PR or hardware success.

## 6. Hash-bound evidence index

### Full reports (all reverified)

| File in synthesis-capture01 | Bytes | SHA256 |
|---|---:|---|
| `ofs_top.drc.partitioned.rpt` | 9453 | `77f8f0f8ecf7439da3ab911d7b2c95420f07a83692f5ee138c694f6ac9cd41ce` |
| `ofs_top.drc.synthesized.rpt` | 23108 | `4191397a6db580e41dc23de50b3fa535c2dcae63dfdc037c45104dabf233e442` |
| `ofs_top.syn.ae.rpt` | 29715838 | `bc40b80c62f9933c5ca5b75aff918d0dd9f619c3cf706d959dcd67510fbf6969` |
| `ofs_top.syn.rpt` | 56378370 | `0b41ed02e5b63ec4bff9eef506dd71100eaa3893ce794c4ff532082fef1c00dc` |
| `ofs_top.syn.summary` | 363 | `d5a4860d74b857df648df80aa45f57a77daf14995557a8f94b1e821c4595c87c` |

- Report archive `synthesis-capture01/result01.json.gz`: `b9229e2ecc3b6b97bd0da505e293865ba00eccf064bae2ef00a85a10c68815ab`.
- Source archive `warning-source-capture01/result01.json.gz`: `322def587707db2e40680d78f13c14f1ba2c16e28beecd3aea989a2b61d14430`.
- The46 source file hashes and true/null `matches_recorded_input` labels are in `warning-source-capture01/manifest.json`. The31 local warning-source matches were independently checked against I's Work21 inventory, not accepted only from the recovery ledger. Private recovery files remain derivative aids, not a substitute for these report/source bytes.

### Additional exact local source matches used in this review

The following files were matched to the corresponding **Work21 `work_inventory` SHA256**, despite some being retained at older/local authoring paths. This does not relabel the entire older tree as Work21.

| Work21 source suffix / local retained file | SHA256 |
|---|---|
| `ofs-common/src/common/includes/pcie_ss_axis_if.sv` → repository `ofs-agx7-pcie-attach/ofs-common/src/common/includes/pcie_ss_axis_if.sv` | `ac303879b3d3f066c4e60ce37b58202fb70b7807febd2e426afb1619f29d5139` |
| `ofs-common/src/fpga_family/agilex/pcie_ss/shims/ofs_fim_pcie_ss_msix.sv` → repository `ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/pcie_ss/shims/ofs_fim_pcie_ss_msix.sv` | `6d70bec25b7fe597fc9a8951b348e8fa770c244072d671d0cc5535fa56550b5a` |
| `syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ahls_binding/rtl/ahls_board_binding.sv` → repository `afu/ahls/rtl/ahls_board_binding.sv` | `dfdc163d67cb26a0f6757a699eedd5655584df09b9f29fbe0e31a083c1384d93` |
| `syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ahls_binding/rtl/ahls_ofs_board_services.sv` → repository `afu/ahls/rtl/ahls_ofs_board_services.sv` | `823aa941b8f7dc2addba78d0f9748cf3d22b2429e2e2835d6567099f235294a9` |
| `syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ofs_plat_afu.sv` → repository `qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/syn/board/ia840f/syn_top/afu_with_pim/afu/hw/ofs_plat_afu.sv` | `3638a59ec7d811c16d9d1e738ca57b606ee3cb9b8cc5bdb15b75ce965c8f12fb` |
| `ipss/ia840f/bwbmc/bmc_spi_sub/altera_reset_controller_1924/synth/altera_reset_controller.v` → repository `qualification/msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/mem_ss_mem_ss_501_qm5zaka/altera_reset_controller_1924/synth/altera_reset_controller.v` | `0097e1b4a176ed1a4dba376109598c064ab7dc4bb5bf2f29f3e76f11b2618f5c` |
| `syn/shared_config/pmci_top.sdc` → repository `ofs-agx7-pcie-attach/syn/shared_config/pmci_top.sdc` | `d3b8135e34541e86353f9b8a3522681e9e1c3dee70c1d73454af572a6e78e0c4` |

### Principal warning-source bindings cited above

These are selected entries from the77-file checked map; generated captured entries remain indexed individually in their manifest. `M/` means repository `ofs-agx7-pcie-attach/`.

| Native-relative/local source | SHA256 |
|---|---|
| `M/src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `M/src/board/ia840f/afu_top.sv` | `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c` |
| `M/ofs-common/src/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv` | `ea02940bc34e6fa33e142e429bbb0df8db893239880c8e15ba6039751bfe8e1c` |
| `M/ofs-common/src/common/lib/sync/fim_dup_tree.sv` | `c9481b8534e4e200e0ff43aa1a44375ee5a3e58598a40364610b6860deb518ae` |
| `M/ofs-common/src/fpga_family/agilex/pcie_ss/pcie_wrapper.sv` | `4dd941c11890bbb38f2851ce9bc59dd79a8c457f1c738f904eaf38d47a4be0e0` |
| `M/ofs-common/src/fpga_family/agilex/port_gasket/pr_slot.sv` | `e6f69b311e7d592778f1e75a303c7517ef294dc47e28362a7ac3e87b96b861b1` |
| `M/ofs-common/src/common/flr/flr_rst_mgr.sv` | `72dae03e3f1b488e25cebf6a504101a018a78ffc63a07265230d1c711b17c1de` |
| `M/ofs-common/src/common/fme/fme_top.sv` | `ec6ac6867b9727b135f888224af4dc06da191aa1a8cbeae48b04533e3a1d4d36` |
| `M/ofs-common/src/fpga_family/agilex/pcie_ss/shims/ofs_fim_pcie_ss_msix_table.sv` | `527c400abb0f932b75b5ae7975a7c1cdcf84aa6cfe459c23dfb173f84588dae3` |
| `M/ofs-common/src/common/protocol_checker/afu_intf.sv` | `41f15a83bd2454f2322ea327f3d952d77203ccec82ba48d26ee9c1757a8fde75` |
| `M/ofs-common/src/common/st2mm/mmio_rsp_bridge.sv` | `2ffc00db41fcbcd00b8578a12dc62e4b5842592f2a8cd82a2e41c6ff1e6415b8` |

**Final scope:** synthesis evidence accepted with the findings above; no source change, no waiver, no gate transition, no deployment.
