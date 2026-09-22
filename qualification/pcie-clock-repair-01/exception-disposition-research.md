# IA840F PCIe clock repair — dependent-exception recommendation

## Decision and scope

**The completed Work14 fitted diagnostic now justifies a specific, guarded board-integration generated-clock definition. It does not establish timing closure or complete exception coverage.** Recommend a fresh, bounded **baseline-versus-candidate STA experiment on preserved copies of the existing Work14 fit**, not another unchanged full build, selector-discovery run, seed sweep, or vendor-IP alteration.

**Retain the existing vendor-consistent asynchronous policy for that experiment.** In particular, do not remove `top.sdc:51` merely because AVMM and CSR share a master. Generated vendor `pcie_ss.sdc:218` explicitly cuts the corresponding Lite↔AVMM pair despite creating their divide-by-two relationship at :191–192. The experiment must expose the paths newly covered by those cuts and the precedence of overlapping exceptions. The same-pair multicycles are **not** a safety backstop.

This is a recommendation only. No implementation, experiment authorization, source promotion, vendor/remote/hardware execution, git operation, or timing acceptance is supplied. The only authored artifact is this report. The independent review of the completed diagnostic must be consumed by the parent before any future experiment package is approved; the raw result's review-pending status is not silently promoted here. The old query stop in the earlier source-research report is historical and superseded by the renewed diagnostic approval; it is not a reason to discard the new completed evidence.

## 1. Evidence identities and citation convention

`N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`. Paths below are relative to N unless stated otherwise. Line references are **1-based original source/report lines**, including decoded JSON source payloads, not JSON container lines.

| Label | Exact file / payload | SHA256 recomputed locally |
|---|---|---|
| SDC | `ofs-agx7-pcie-attach/syn/shared_config/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |
| VSDC | `ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc`, decoded from LIVE06 below | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |
| LIVE06 | `qualification/pcie-generated-evidence-01/pcie-rendered-constraints-live06.json` | `10e8e2b262ada40ed64e232194e8cdc20ec3f20083b18d0ba12e0f3fd97b3e0f` |
| LIVE10 | `qualification/pcie-generated-evidence-01/pcie-synthesis-chain-live10.json` | `89fab314daae1a4ec64f87f8cd8f6fc1e0de23a007edb8691ac8574156fd4a33` |
| AUTH | `qualification/fim-build-14/status-readback05/compile-authorization.json` | `42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be` |
| SOURCE-REVIEW | `qualification/pcie-clock-binding-01/independent-research.md` | `27150f6a979e761d6207793397a33c72a05f3fa20de28f3f979745413f426547` |
| SOURCE-BINDING | `qualification/pcie-clock-binding-01/parent-source-verification01.json` | `b8d5d20a0daa2a5b7c60c98c02cb385d13a6db430cf378a76a9ab7cd458cf744` |
| STA | `qualification/fim-build-14/reports11/output_files/ofs_top.sta.rpt` | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| E2 | `qualification/fim-build-14/pcie-postfit-02/result-readback01/query.log` | `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` |
| E2-SCRIPT | `qualification/fim-build-14/pcie-postfit-02/query.tcl` | `c2acd70013ff567004a77199ebc22a977aeb48af03b83c740c8eda24129a333d` |
| E2-SUMMARY | `qualification/fim-build-14/pcie-postfit-02/result-summary01.json` | `2e7528f76c24f5a552c82156ef5574f6c9c3540968afea8e0b7651cce92fc0bb` |
| E2-RESULT | `qualification/fim-build-14/pcie-postfit-02/RESULT.md` | `be54cebdba102e8d3287f1c4b42aa84f040ee7db011e26fea98574d4472f361a` |
| HELP | `qualification/fim-build-08/pcie-postfit-query-01/api-help2.log` | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |

LIVE06 and LIVE10 store `files` lists keyed by each entry's `path`; their selected source root is `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/`. Historical Work08 captures instead use absolute-path keys and `text` payloads. This review reconstructed and hashed **all eight generated payloads and five maintained files enumerated in SOURCE-BINDING**, and compared each with its exact AUTH `work_inventory` hash: all matched. This is source identity verification, not requalification of the protected bodies. Their exact remaining paths/hashes are retained in SOURCE-BINDING:5–82; there is no need to search the vendor installation again.

E2 raw `native-result.json` has rc0 and SHA256 `ec7ae2c3ce9d5ca29c4e12e0d6fed1ea5ecf55be2863735dcf20ecdeca81cd17`. E2 has 718 lines, the final marker at :711, successful Tcl evaluation at :712, and `0 errors, 201 warnings` at :713. The preserved inventory receipt `preservation-after.json` hashes to `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` and records true for maintained SOURCE, PIM, and original Work14. That is the recorded runner comparison, not a new inspection of those remote trees.

## 2. What the completed diagnostic closes — and what it does not

Use these literal names; H/P/D/C/M/R are explanatory abbreviations, not created Tcl artifacts:

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
P = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
D = P|u_pciess_clock_divider|clkdiv_inst
C = H|avmm_clock0
M = sys_pll|iopll_0_clk_100m
R = H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|xcvr_hip_native|rx_ch15
```

- **Exact input/output pins now observed:** `D|inclk` and `D|clock_div2` each match one pin; `D|clock_div2x` matches zero (E2:496–500). Input/output directions and clock-pin flags agree (E2:505,510). There is one `tennm_clk_divider` cell (E2:504,705). Do not substitute the fitter net alias `clock_div2x` or register alias `clkdiv_inst~div_reg` into the output-pin selector.
- **Actual master path now observed:** the input's sole clock fanin is `sys_pll|iopll_0|tennm_pll|outclk[2]`; its clock is M, period 9.929 ns (E2:506–509). M's own master is `sys_pll|iopll_0_n_cnt_clk`; that is not the proposed divider's immediate master. Input-pin `-net` is empty (E2:505) and is not used as connectivity evidence.
- **The four selected receiver groups now bind to the divider:** programmatic parsing found eight unique cells per group, one clock input/fanin per cell, and the same `P|u_pciess_clock_divider|clkdiv_inst~div_reg` fanin for all 32 (E2:513–704; final counts :706–709).

| E2 group | FIFO under P | Selected destination under `auto_generated|` | Cells |
|---|---|---|---:|
| 0 | `u_pciess_cplto_if|cplto_fifo_avmm_inst` | `rs_dgwp|dffpipe*|dffe*` | 8 |
| 1 | `u_pciess_cplto_if|cplto_fifo_lite_inst` | `ws_dgrp|dffpipe*|dffe*` | 8 |
| 2 | `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo` | `rs_dgwp|dffpipe*|dffe*` | 8 |
| 3 | `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo` | `ws_dgrp|dffpipe*|dffe*` | 8 |

**Important API limit:** E2-SCRIPT:11–22 compares names against `get_clock_info -targets`; at :24–35 it applies that comparison to clock fanins. `CLOCK_TARGET_COUNT 0` at the output and each selected receiver is not an exhaustive propagated-clock query. Independent Warning 332060 at E2:493 expressly says the divider register has no associated assignment; :494 identifies an additional AVMM tile load. The 32 selected cells are not all AVMM loads, all FIFO circuitry, or all integrated crossings.

The source chain corroborates M's CSR meaning: maintained `top.sv:302,511–516,589–592`, `pcie_wrapper.sv:266–270,290–305`, and `pcie_ss_axis_top.sv:715–718` forward CSR to `p0_axi_lite_clk`; DM's alternative also uses CSR at :231–234. LIVE10 `synth/pcie_ss.v:180,183,1169,1177` and `pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv:4530–4533,4687–4694` select P-Tile endpoint and forward that clock into `u_pciess_p0.axi_lite_clk`. These primary excerpts were checked locally. Their five maintained and two generated payload identities are in SOURCE-BINDING and match AUTH. Protected inner wiring is no longer a reason to withhold this bounded hypothesis: the fitted input/fanins plus trusted vendor divide-by-two constraint supply the missing integration evidence without decryption or internal requalification.

## 3. Minimal board-integration definition

The repair belongs at **SDC:35–37**, replacing the failed existing command, not adding a second unconditional declaration. Recommended semantic contract:

| Field | Exact recommendation |
|---|---|
| Clock name | `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|avmm_clock0` |
| Source pin | `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|inclk` |
| Target pin | `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2` |
| Immediate `-master_clock` | Existing `sys_pll|iopll_0_clk_100m` clock object |
| Relationship | `create_generated_clock`, `-divide_by 2`, inherited master waveform; no base-clock creation, independent period, invented phase, PLL change, or nominal 50-MHz clock |
| Duplicate behavior | No blind `-add`, no implicit overwrite, no alias to evade exception selectors |

This is a field-level design, **not executable candidate code**. The fitted selectors are supported by E2 and the ratio by VSDC:191–192. Source location versus master-clock identity must remain distinct. From the rounded 9.929-ns observation, twice the period is approximately 19.858 ns; this is only a sanity check, not a new SDC period. Read the native resulting period/waveform rather than constraining to that rounded value.

Required fail-closed behavior for any later implementation:

1. Bind the one IA840F/P-Tile instance and the reviewed source/netlist/tool identities. Require exactly one input pin, one output pin, one expected divider, and one intended M. Resolve real names and directions, not only nonempty wildcard collections.
2. Verify that the source fanin is the observed physical PLL output and that M is its actual associated clock. Do not silently choose another master if multiple clocks appear.
3. Before creation, inventory both the requested name and all existing clock definitions/associations on the output. On this bound Work14 baseline, absence is the expected starting state. Missing required objects, multiple objects, duplicate clocks, or a conflicting existing name/target/master/ratio must reject the run. Do not delete or overwrite an unexpected clock to make the test pass.
4. If a later vendor flow already supplies **one exactly equivalent** clock, reconcile it as an explicit no-create case; do not create a duplicate. A clock with another name, extra target, different waveform/master, or ambiguous association is a changed baseline requiring review, not an automatic success. Validate postcreation cardinality and native propagated receiver clocks as well as the target definition.
5. Scope diagnostic temporaries in a namespace/procedure. Preserve the observed node-versus-collection distinction in E2-SCRIPT; do not feed one native node handle back to `foreach_in_collection` as if it were a collection. Acceptance must reject native errors, ignored critical commands, missing final marker, and the source-bound gate's failure diagnostics even if the outer vendor process exits zero.

### Keep generated SDC intact; preserve loading semantics

VSDC:161–164 tests Lite **port** existence; :187 computes a separate clock-existence flag, but :188 still gates creation on the port flag. :191–192 uses the standalone `p0_axi_lite_clk` clock name. E2:501 establishes only **top-context** port absence, not the entity-scoped historical predicate. The old source diagnosis remains valid without claiming a runtime branch trace that was never captured.

VSDC's nominal Lite period and `-add` are not a reason to manufacture `p0_axi_lite_clk` or duplicate M. Do not patch its :188 condition, rename vendor clocks, modify protected RTL, or copy its cuts into a new broad waiver. QIP:345 registers the entity SDC with `-no_sdc_promotion`; STA:208697,208749,208862 records PLL SDC → PCIe entity SDC → integration SDC order. HELP:274–308 documents default `read_sdc` import and project-file ordering. A later experiment must load the corrected **scratch copy of top.sdc in that normal order**, before evaluating its groups/multicycles, then update timing. Appending a clock after the completed E2 `read_sdc` would not prove that formerly ignored clock lookups in :49–60 were re-evaluated. Nor should it re-source the entire vendor SDC and accidentally duplicate constraints. Confirm that its period-derived FIFO assignments become numerical under the normal read/update flow; an ordering failure is evidence to stop and inspect, not permission to hard-code their bounds.

## 4. Explicit dependent-exception disposition

| Existing constraint | Experimental disposition | Meaning and remaining evidence |
|---|---|---|
| SDC:49, C↔R asynchronous | **Retain byte-for-byte** for the initial candidate. Confirm that the two wildcard groups resolve to exactly C and R. | Vendor equivalent at VSDC:299; activation cuts normal interclock setup/hold paths. Enumerate both directions and account for every affected endpoint/exception. |
| SDC:51, M↔C asynchronous | **Retain byte-for-byte** for the initial candidate. Confirm exactly M and C membership. | VSDC:218 deliberately expresses this policy for Lite↔AVMM. A common master does not invalidate a CDC-based IP contract. This cut is intentional experimental policy, not a proved absence of transfers. |
| SDC:50, M↔R asynchronous | Retain unchanged and report as baseline context. | Vendor analogue VSDC:290. Do not credit this pre-existing cut to the repair or conflate R with the CSR source. |
| SDC:57–58, C→M, setup 2/hold 1 `-end` | Preserve bytes **only to keep the first comparison clock-definition-only**; explicitly classify as superseded by :51 on the same pair, with no safety credit. | Native effective/ignored-exception reporting must show precedence/coverage. The broad `*avmm_clock0` collection must contain only C in this snapshot; otherwise the “same-pair only” premise fails. |
| SDC:59–60, M→C, setup 2/hold 1 `-start` | Same disposition as :57–58. | Do not call these active timed transfers while :51 cuts them. Removing :51 to activate them would be a separate policy experiment requiring the actual transfer/cycle contract. None is established here. |
| Other pre-existing groups/cuts, especially one-group SDC:43–44 | Preserve unchanged; include their membership/effect on C in the global comparison. | A newly defined clock can also enter the “other clocks” side of existing isolation policies or match other selectors. Newly cut scope cannot be inferred solely from :49/:51 or the four receiver groups. |
| VSDC:628–641 FIFO skew/net/max/min-delay constraints | Retain all byte-for-byte and verify their **effective numerical** checks. | Clock-group cuts do not supply a missing destination period. Do not assume all constraint classes share setup/hold exception precedence or disappear harmlessly under an async group. |

**Why retention is justified for an isolated test:** the generated vendor SDC documents the corresponding CDC intent, readable integration maps Lite to M, and fitted evidence now binds the actual divider. Keeping this policy is a narrower hypothesis than inventing synchronous multicycle behavior or redesigning trusted vendor CDC. An off-line STA experiment with no promotion can measure precisely what becomes untimed without asserting functional success. It is therefore reasonable to test this clock with the existing cuts retained, provided the reports below are mandatory and unexpected coverage is a failure, not a waiver.

**What retention does not establish:** that every newly cut path is inside the trusted vendor IP, that all integrated interfaces obey the vendor CDC contract, or that the global multicycles are functionally correct. Establish the trust boundary from native endpoint/instance inventories and existing readable integration; ordinary transfers within the supplied vendor IP may rely on its supplied constraints. An unexpected direct integration path outside that boundary must be reviewed on its own source/CDC contract. Do not demand cleartext protected implementations as the default next action.

**Eventual maintained-source policy:** retain the supported async policy if coverage confirms its scope. Retire the four redundant global multicycles rather than advertise them as useful protection, once the exact selector membership and native precedence evidence are reviewed. That cleanup is not included in the first clock-only comparison and is not implemented or approved here. If a future design really requires timed M↔C transfers, derive specific cycle/enable/handshake requirements first; simply deleting :51 to make the existing 2/1 numbers active is not justified.

## 5. Smallest useful isolated experiment — proposed, not authorized

Use a fresh package and separately owned output roots, never the consumed E2 attempt. Preserve maintained SOURCE, PIM, original Work14, and all captured results. Reuse the existing fitted database and unchanged generated PCIe content; do not synthesize, fit, assemble, simulate DDR, test dummy CSR, or touch hardware.

The finite comparison is:

- **A / baseline:** one fresh timing-netlist session on an unmodified preserved Work14 copy, with the additional finite reporting below. Retained Work14/E2 logs supply source/fitted provenance, but do not contain the missing endpoint-level exception comparison.
- **B / candidate:** another clean session on an equivalent copy, with **only the guarded integration generated-clock definition replacing SDC:35–37**; all exception statements and generated vendor files unchanged. Guards/reporting are separately bound diagnostic code, not changes to the implemented design. Normal SDC order and all other tool/netlist/settings/corner choices match A.
- Compare complete clock membership, transfer and exception inventories, then detailed numerical constraints/timing for the affected sets. Report “previously unclocked/unconstrained → now clocked but async-cut” separately from “previously timed → newly cut” and from “already cut.” None of those transitions is itself a setup/hold pass.

The initial native reporting should expose false paths **without removing the cuts**. If the installed API cannot expose complete affected coverage, stop with an explicit capability/output gap. Do not silently disable cuts, remove all exceptions, or add a third functional-policy variant. An exception-disabled forensic view, if ultimately necessary, would need its own exact bounded scope and must never be treated as a functional timing contract.

### Finite native evidence package

The following is a deliverable specification, not an issued command script. HELP is captured Quartus **26.1.1 Build 130** (:3), and already supports `project_open`, `create_timing_netlist`, `read_sdc`, `get_pins`, `get_pin_info`, `get_cell_info`, `get_cells`, `get_clock_info`, and `get_fanins`. In particular, HELP:692–720 exposes clock name/type/master/master-pin/targets/period/waveform/ratio queries, and :775–789 documents `get_fanins -clock -stop_at_clocks`. Their result semantics must not be broadened beyond their documentation.

The inspected retained help does **not** contain the full exception/transfer/net-delay report command options. A later approved package should acquire a single finite installed-help batch for the needed report/coverage operations before fixing their command grammar; no new help command was run here. `report_exceptions` is explicitly recommended by native STA:214554–214557. The report families below identify the required output; they do not assert unverified switches such as a guessed false-path or “all” flag. Confirm the installed equivalents for `report_clocks`, `report_clock_transfers`, `report_exceptions`, `report_sdc`, `report_net_delay`, `report_max_skew`, `report_timing`, and `report_ucp`, including how to expose cut/overridden paths, totals, truncation, endpoint clocks and SDC provenance. Capture only the additional endpoint/clock-information API help actually needed to finish these reports.

| Required output | Exact content / bounded scope |
|---|---|
| **1. Load/clock audit** | Actual SDC read order and source identities; complete clock inventory before/after; one C of generated type with correct target, source, master, divide relation, native waveform/period and no duplicate; no invented Lite/base clock. Exact memberships of SDC:49–60 and any existing group/selector newly covering C. Native receiver-clock association for each of the 32 previously selected cells and the other C loads, not only equality to definition targets. Retain positive clock/fanin evidence and absence of the specific 332060 diagnostic. |
| **2. Transfer inventory** | Setup/hold and applicable recovery/removal transfer matrices including cut/ignored status, with all transfers to/from C across **all actual clock domains**, not only M and R. Preserve M↔R baseline context. For C↔M and C↔R and every other changed pair: unique startpoint/endpoint identities, launch/latch clocks, counts, timed/cut/unconstrained status and the winning exception's source. Enumerate the finite affected endpoint pairs or equivalent complete native coverage, not every possible combinational route. Preserve raw reports and reconcile totals programmatically. A top-N sample without a proven total is incomplete. |
| **3. Exception precedence/coverage** | Native active, ignored, overridden and unmatched exception information plus SDC locations; show :49 and :51's coverage and that :57–60 do not provide ordinary setup/hold coverage. Distinguish already-cut paths from newly cut paths, account for other group policies, and detect any duplicate/conflicting exceptions. Classify each changed endpoint group as vendor-IP-internal, known integration CDC, or unresolved integration transfer. No zero-match exception may count as coverage. |
| **4. Numerical FIFO constraints** | Every one of the eight exact baseline-invalid assignments in §6, with matched launch/destination keeper sets, actual clocks/periods, native Required/Actual/Slack, corner and original VSDC line. Also report associated source-period max-skew constraints, destination-chain net delays and effective max/min-delay handling. Keep dedicated net-delay/skew checks even where normal setup/hold is cut; their continued existence and evaluation must be explicit. Include all changed C-related instances discovered by the audit, not only the originally selected four. |
| **5. Real timing and unconstrained delta** | For each enabled Work14 analysis corner, worst setup/hold and applicable recovery/removal/min-pulse-width results for C, its timed loads and other changed domains; unconstrained clock/register/path summaries and exact affected identities; dedicated net-delay/skew results and relevant Design Assistant constraint checks. Retain global summaries to expose regressions and the separate EMIF1 hold failure. Require all enabled corners, not one convenient corner or the abbreviated OFS failure-only summary. |
| **6. Run/preservation evidence** | Exact source/overlay/netlist/tool identities, commands, clean A/B output roots, native and outer status, full logs and completion markers, report counts/completeness, rejected/unsupported queries, and original-tree preservation comparison. Do not overwrite or relabel Work14/E2 reports. |

The bound OFS `ofs-common/scripts/common/syn/report_timing.tcl` (SHA256 `306ba0d8b931a884a228c5e06f212567f888371ecc3266aab5a10750ba7d5d26`, also matches AUTH) already enumerates operating conditions at :57–62 and setup/hold/recovery/removal/mpw at :64–80. It emits detailed paths only for negative-slack domains. Its summary alone cannot prove these newly numerical FIFO constraints or cut-path coverage; nor should that script be run in an original output tree, because :48–50 deletes its old timing-report directory. Reuse its verified reporting concepts, not an unreviewed invocation of a destructive output hook.

Predeclare finite report/output/time caps in the future package. Reaching a cap must mark the relevant evidence **incomplete** and prevent promotion; do not use the cap as a waiver or claim that 32 receivers bound the number of all crossing paths. This proposal does not require an unbounded installation search or a new generic diagnostic framework.

## 6. Eight exact invalid FIFO assignments and numerical bar

VSDC:628–635 applies pointer-transfer max skew `0.8 × source period`, max net delay `0.8 × destination period` outside `quartus_syn`, and max/min delay `100/-100`. VSDC:637–641 independently applies destination-chain max net delay using the same destination-period multiplier. Its rdptr selection/calls are :649–680 and wrptr selection/calls :690–721. At :727–733 it iterates the design's `dcfifo` entity instances: **do not assume this procedure is confined to the four queried FIFOs or even only the PCIe-internal hierarchy.** Preserve and compare its other existing coverage.

With the FIFO prefix from §2 plus `|auto_generated|`, these are the four pointer constraints and four receiver-chain constraints:

| Group | VSDC:631 source → destination | VSDC:639 source → destination | Baseline invalid summary lines | Baseline final warnings |
|---|---|---|---|---|
| 0 | `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*` | `rs_dgwp|dffpipe*|dffe*` → same chain | STA:3622–3623 | STA:209811–209812 |
| 1 | `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*` | `ws_dgrp|dffpipe*|dffe*` → same chain | STA:3620–3621 | STA:209813–209814 |
| 2 | `delayed_wrptr_g*` → `rs_dgwp|dffpipe*|dffe*` | `rs_dgwp|dffpipe*|dffe*` → same chain | STA:3626–3627 | STA:209815–209816 |
| 3 | `*rdptr_g*` → `ws_dgrp|dffpipe*|dffe*` | `ws_dgrp|dffpipe*|dffe*` → same chain | STA:3624–3625 | STA:209817–209818 |

These are **eight assignment records**, not eight endpoints or eight complete transfer paths. Their destination selection matches the four queried receiver chains, but native `get_keepers` expansion and actual path counts still need reporting. A constraint's receiver-chain collection can contain multiple pipeline stages: do not assume every possible Cartesian pair is a real path or that every selected cell is a first-stage synchronizer.

Candidate acceptance requires eight corresponding **present, active, numerical** net-delay records, with no `Invalid clock`, unresolved destination, dropped assignment, or false-path-only disappearance. Confirm `0.8 × actual native C period` rather than hard-coding a limit. Using only the rounded current input observation yields approximately 19.858 ns and 15.8864 ns respectively; these are local arithmetic sanity checks, **not measured candidate results**, not guaranteed native rounding, and not constraints to write. Source-side skew uses each actual **source** period, which must be queried rather than assumed to equal C. Record real Actual and Slack at each applicable corner, plus existing opposite-direction/other FIFO checks affected by the new clock.

STA's global Net Delay Summary is labeled Pass at :2732 even while :3620–3627 contains these invalid entries. Therefore warning disappearance, a global Pass label, native rc0, or eight missing rows cannot establish repair success.

## 7. Acceptance levels and exact remaining evidence

### A. Supported now

- Exact fitted input/output pin names and cardinality, upstream physical PLL output/M association, vendor divide-by-two intent, and bindings of the four selected receiver groups.
- Source-grounded reason to test one guarded integration clock while retaining vendor-consistent cuts.
- No need for another unchanged fitted selector query, nominal clock invention, upstream-release search, or protected-IP internal review. The accepted `qualification/ofs-2026-target-01/DISPOSITION.md` already reconciles the chosen OFS source target; it does not repair this SDC.

### B. Required for a successful isolated constraint-validation result

1. Parent consumes the pending independent E2 result review; future candidate/reporting package is separately reviewed and authorized. This report does neither.
2. A/B source and fitted-database identity/preservation checks pass; exactly the proposed clock-definition delta occurs and no unreviewed collateral settings/constraint changes occur.
3. One C binds to the exact divider with the expected master/waveform/ratio, receiver clocks propagate correctly, and the specific missing-clock failure is absent without duplicate or invented clocks.
4. All eight baseline-invalid assignments are numerically evaluated; all affected skew/net-delay constraints remain represented, with endpoint/corner counts reconciled. Native failed numerical checks remain failures.
5. Complete changed-transfer/exception coverage explains every newly cut/retimed/newly constrained endpoint group, including effects beyond the four FIFO chains and the superseded multicycles. No unexplained integration path is accepted merely because a clock-group cut hides it; no timing/CDC waiver or broad false path is added.
6. Real setup/hold/other applicable checks for the now-clocked domain and the global unconstrained/diagnostic delta are reported honestly across the enabled corners. No truncated report or query error is accepted as an empty set.

**Separate outcome labels:** successful parsing/binding is not a numerical timing pass; a numerical STA pass is not a functional CDC or hardware pass. If the repair produces valid but negative net-delay/skew or normal timed-path slack on the old fit, that is useful diagnostic evidence, not a failed clock-name hypothesis by itself. It prevents a timing-pass claim and must be reviewed explicitly before deciding whether a fresh build with the changed constraints is justified. Do not demand that an unconstrained old fit already meet every new bound as a circular prerequisite to considering a constrained fit; equally, do not run that fit automatically or waive the failures.

### C. Still open; not solved by this recommendation

- Candidate's actual native generated period/waveform, propagated clocks, numerical FIFO bounds/delays/slacks and load coverage.
- Effective async/other exception coverage, complete newly cut endpoint sets, multicycle dominance, and any integration transfers outside the supplied vendor-IP CDC boundary. These are finite native/integration questions, not demands for vendor plaintext.
- Exact installed report option grammar needed to expose cut paths/coverage; the inspected help proves only the listed lower-level APIs. Any API limitation must be stated before claiming complete coverage.
- Maintained-source promotion and redundant-multicycle cleanup, then any separately reviewed changed-constraint fit and full qualification. An isolated post-fit analysis does not generate a newly implemented image.
- The independent **EMIF1 −0.004-ns hold violation** remains: STA:2806,126734,126747–126761, Fast vid2 100C Model, core-user-clock write-data to PHY `phy_clk_l_0`. It is not repaired, explained away, or waived by a PCIe clock definition. No seed/settings sweep or unchanged full build is proposed.
- Hardware programming, host recovery prerequisites, PCIe/data-path functionality and the broader working-AHLS-FIM gates remain outside this local report.

**Bottom line:** proceed only to a separately reviewed proposal for the finite A/B constraint-validation experiment described here. The justified hypothesis is the exact vendor divide-by-two clock on the observed modern pin, with explicit M master and existing vendor-consistent async cuts retained. Acceptance comes from positive numerical constraint and complete exception-coverage evidence—not from suppressing warnings, enabling unsupported multicycles, or declaring every common-master crossing synchronous.
