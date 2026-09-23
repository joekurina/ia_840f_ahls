# Independent review — page-safe AHLS / real-PIM analysis/elaboration

**Status: FINAL**

## 1. Specification-first verdict

**ACCEPT_PAGE_SAFE_REAL_PIM_NATIVE_ANALYSIS_ELABORATION_ONLY.** Accept the completed, changed Quartus 25.1 A&E result for the bound page-safe candidate. The exact source delta, actual native parameter instances, diagnostic delta and recorded preservation/return codes support this structural milestone. No demonstrated defect in this result requires an unchanged native rerun.

**Do not accept functional correctness, generic AXI compliance, lifecycle/reset/PR safety, mapped synthesis, full-FIM/persona fit or STA, build readiness, physical DDR/PCIe/OPAE operation, sustained operation or durable boot.** Functional review `deleg_6b06a023` remains separate and pending parent acceptance. The actual primary PCIe mapper was not executed in the path08 simulation. Work21 signoff coverage, PR dangling-node and BMC-constraint obligations remain open. Vendor DDR simulation remains **SKIPPED BY USER**. **Goal incomplete.**

This is result acceptance under the standing native-iteration authority, not a newly invented launch-approval gate. No launch or hardware action is authorized by this report.

Reviewed `SCOPE.md` before `RESULTS01.md`, exact bindings and implementation. Local-only methods: ordinary file reads, byte hashes, JSON/gzip/base64 decoding, source diffs, report parsing and inert AST/literal decoding of configuration `C`. Neither runner was imported or executed; no fixture/HDL simulation, SSH, vendor/native/hardware operation, implementation edit, git operation or task transition occurred. This report was written early as **IN_PROGRESS** and is the sole authored/modified project file. Its full-file final SHA256 is returned separately, not embedded self-referentially.

Notation: `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; `T=N/qualification/ahls-memory-pim02`; `P=N/qualification/ahls-memory-pim01`; `Z=N/qualification/ahls-memory-dma-core01`; `I=T/inputs-elab01`; `R=I/platform/ofs_plat_if/rtl`; `G=ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric`. Native panel line numbers below refer to `T/artifacts-elab01/output_files/ia840f_ahls_memory_pim_elab.syn.rpt`.

| Specification obligation | Independent disposition |
|---|---|
| Changed page-safe candidate, not an unchanged rerun | Met. The original top changes only its bank-shim type; one new wrapper and exactly two generated LSU overlays are consumed. |
| Reuse final functional path08 shim03 and reset corrections | Met for byte identity. The wrapper and both LSU overlay hashes match `qualification/ahls-memory-functional01/source-binding08.json`; functional acceptance is not imported with those hashes. |
| One primary mapper, both actual banks, real captured PIM | Met structurally. Only one `ofs_plat_afu` source is selected; native primary panel5084 has one `primary_axi`. Wrapper, underlying shim and splitter panels explicitly list bank0 and bank1. No projected platform package replaces the real PIM. |
| Preserve address/data/ID/USER and clock/reset topology | Met for source/native structure. Core boundary remains34-bit byte address,512-bit data,8-bit LEN,18-bit IDs,2-bit USER; only the internal page-limited interface uses LEN5. Primary host and all original top clock/reset/soft-reset/freeze wiring are byte-preserved outside the one type substitution. |
| No vendor PIM/installed-library or physical-constraint edits | Met within the captured source/run evidence. All existing PIM/FIM input payloads and262 original path/hash bindings are unchanged. QSF adds only the wrapper source and removes the redundant macro; no SDC/pin/frequency/physical-IP change. Remote installed-original/tool preservation is a captured before/after result, not a fresh review-time remote measurement. |
| Fresh, finite, parent-owned native execution | Recorded fresh root, @234/%234, resource preflight, two CPUs,16GiB per-process address-space limit and600s deadline. Native/effective/outer0/0/0; no timeout or remaining owned group. No remote operation was performed by this reviewer. |
| Fix predecessor F4 and recover F5 without rewriting history | Met. Final predicate requires all six preservation flags and empty postflight errors; ten inert recorded cases agree with the inspected expression. Four missing exports are recovered under T and match original hashes. P's old mirror and review are not relabeled complete. |
| Preserve stage/functional/hardware boundaries | Met only with the limitations above. Root is an AFU, not physical DDR controllers or a full FIM; success wording does not promote A&E to mapped synthesis. |

## 2. Evidence identity and independent verification

Frozen `review-package01.json`: **32 entries**, SHA256

`cbfa49143960f4ad2700c61387070deac9ed0e552c74372da2056aa0d21ba444`

Every entry matched its recorded byte count and SHA256. The manifest's existence was not treated as proof: the following underlying contents were independently reconciled.

- `result-elab01.json.gz`: **1,204,831 bytes**, SHA256 `46c5bd58c1ebbaec99cfdb9872aaa7fded565ba27c7f137a539d821aaadc5606`, matching `outer-elab01.json`.
- All **13 exports** match their decoded payload bytes, embedded byte counts/hashes and local artifacts. The stripped decoded result equals `manifest-elab01.json` exactly. These are the predecessor's nine log/report/project/PIM-metadata roles plus four generated metadata/header/SDC exports, not thirteen independent native reports.
- All **274 platform/core inputs** match both the decoded runner configuration payloads and the source-binding/native manifest. All **255 original generated inventory entries** rehash across `Z/artifacts-fabric01` plus the four new recovered members. All **255 candidate entries** rehash across that same base plus the two overlays. Thus **529 bound inputs** are locally reproducible as this explicitly composed evidence set, not as a newly complete predecessor directory.
- The original255 inventory and262 platform-original path/hash bindings equal the predecessor runner's inertly decoded bindings. The candidate inventory differs only at the two named LSUs. All other existing platform/core payloads are unchanged except the alternate top, plus the newly added wrapper.
- `Z/qip-dependencies01.json`, SHA256 `e2944289533f78450ce3979c31d962a8bb4b43bd7ec01b28db51682614dfc184`, has254 dependency rows. Every target resolves to the original bound inventory/hash; candidate mismatches are exactly the two intentional LSU overlays. Both system and child QIPs remain selected. The original header/SDC dependency roles are retained.
- All **226 warning rows** were reparsed from the full native log and match `warning-ledger01.json` row-for-row. All223 source-bearing rows resolve to the **41** exact local source files in `warning-source-binding01.json`; every source's bytes/hash verifies.
- All **eight** selected parameter-panel text blocks match the full native report at their recorded starting lines. Supplemental native CDC/WLAST/inner-mapper/sweep panels were read directly rather than inferred from representative instance names.
- `run-elab01.py`, SHA256 `14f05fd7e7d6edc692d66f533d3feea29652b10d903bc7c7f73ebf1387f577fa`, matches the dispatch receipt and is exactly `run-elaboration.py.in` with its literal `C` substituted. The full template-to-template diff equals `runner-delta01.patch`. Configuration, generated inventories, input payloads, tools and QSF/QPF match their independent binding records.

Key artifact identities:

| Artifact | SHA256 |
|---|---|
| `source-binding01.json` | `3723bdb43b017b05e7f8beba375c3a5dd8972433874f98103edbcbcb88d6dfec` |
| `project01.qsf` and captured native QSF | `40304b893b9091f794b6fa5c15c74af582c7af58eeba08e7464a44325c016dba` |
| `artifacts-elab01/elaboration.log` | `291c1c884f9adaea670952b420a1602d6f5691f85e56d6aea671d0552518bf29` |
| Native `.syn.rpt` | `20a6c0ed6d09e6fd4266ab8a7897d783256e2370c5463a2d35634d10152d0e4c` |
| Native `.syn.ae.rpt` | `4b796d6535acde3671e6b64ea57f257318b6bef721a62a72071f546de1be5f1b` |
| Native `.drc.partitioned.rpt` | `22a42fdae1771fd2ff10ef9092c35a1202fba891b8bb9ed978da47d13d3b9069` |

The predecessor FINAL review hashes to `bd6d1188d1e0d579e6b9012c1ce6219dddb1a7a25ce327ec3754f0d3be2216e0`; `P/RESULT-ACCEPTANCE.md` and `P/parent-review-verification02.json` explicitly consume it. Its F1–F6 structure and unchanged warning audit are reused below, not repeated or retrospectively edited.

### Actual native stage

```
/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_pim_elab -c ia840f_ahls_memory_pim_elab
```

Recorded work root: `/home/uwb_student00/ahls/new_BSP/work_ahls_memory_pim25_02/elab01`; tmux@234/%234. Quartus25.1.0 Build129 SC Pro; AGFB027R25A2E2V, top `ofs_plat_afu` (native760–770). Native start `2026-09-23T12:36:26.065933Z`, end `2026-09-23T12:37:28.691258Z`; PID110042/start_ticks13025783. Native/effective/outer **0/0/0**, errors empty, all six preservation flags true, `postflight_errors=[]`, no timeout, no descendants observed at leader exit and no owned live group afterward. Recorded preflight has124,892,770,304bytes available memory,1,298,495,979,520bytes free disk, CPUs[0,1], no competing native process.

Log20 independently records the A&E argv. Log5293–5294 records the synthesis-success banner,0errors/1warning and3128MB peak virtual memory. The detailed warning total is226; neither the banner nor memory usage establishes mapped synthesis, timing or performance. Native QSF bytes equal the prepared project, including previously established power-management settings; no new settings migration occurred here.

## 3. Exact source delta and structural quality

### Alternate top and wrapper

`afu/ahls_memory/pim/ofs_plat_afu_pagesafe.sv` equals `I/afu/ofs_plat_afu.sv`, SHA256 `008eb54d6ee983a771747c10ee34c9801836bb20bc32b375dc7f61cdf77220ce`. Its sole delta from the predecessor top is line37:

```
- ofs_plat_local_mem_as_axi_mem #(.ADD_CLOCK_CROSSING(1),
+ ia840f_ahls_memory_bank_shim #(.ADD_CLOCK_CROSSING(1),
```

The loop, both bank connections, `primary_axi`, all flat core associations, bank0 core clock, joined soft reset, freeze forwarding, masks and geometry-reject branch remain unchanged. The QSF selects just `rtl/afu/ofs_plat_afu.sv`, not both alternate and scalar implementations.

New `I/afu/ia840f_ahls_memory_bank_shim.sv` is byte-identical to maintained `afu/ahls_memory/pim/ia840f_ahls_memory_bank_shim03.sv` and the path08 bound input: SHA256 `7d6ae5d428a81105d83d09d8d8f15c38be63f5275554371c5f5a344521aafdc6`. It composes existing, unchanged PIM primitives:

1. Lines15–19 retain source address/data and full RID/WID/USER, using only an internal `BURST_CNT_WIDTH(5)`.
2. Lines21–27 put the existing local-memory shim after that interface, preserving requested CDC and timing stages.
3. Lines29–37 use a full `afu_if`, sourced from the shim's clock/reset/instance signals, and `ofs_plat_axi_mem_if_connect_sink_clk` across the outer `to_source_clk` boundary. `R/base_ifcs/axi/prims/ofs_plat_axi_mem_if_connect.sv:29–49` confirms clocks/reset flow sink-to-source with transaction fields preserved. This is the PIM's own interface pattern, not a modport-error suppression.
4. Lines42–46 instantiate the existing burst mapper with `PAGE_SIZE(4096)` and the local-memory NO_REPLY flag index. Native5316 explicitly records PAGE_SIZE4096, UFLAG_NO_REPLY0, NATURAL_ALIGNMENT0 and **both** bank instances.

Native5100 confirms34addr/512data/18RID/18WID/2USER on both sides, with8→5 LEN. At64bytes per line,4096bytes is64lines, and LEN5 permits32beats/2048bytes. Count-zero panel5933 records source8/sink5/address28/page64; count-one page gearbox panel6696 records source9/sink6/page64 and **all four** bank read/write instances. `ofs_plat_prim_burstcount1_mapping_gearbox.sv:228–242` requires PAGE_SIZE strictly greater than the sink maximum:64>32 satisfies it. LEN6 would not satisfy that strict inequality. A&E does not execute the translate-off assertions; the selected domain was checked from source and actual native parameters.

The old local shim's internal `map_bursts` still has PAGE_SIZE0 (native5477–5487), now with source LEN5 and physical LEN8. Its direct field connection widens the already split requests; it is not the new page splitter and does not undo page splitting. This distinction avoids falsely claiming that vendor PIM source was changed.

### Metadata, responses, WLAST and clocks

- `R/ifc_classes/local_mem/prims/ofs_plat_axi_mem_if_user_ext.sv:84–103,114–133,143–178` queues the full accepted ID/USER before physical ID/USER substitution and restores metadata on responses. Native5492–5505 confirms FIM_USER_WIDTH1, all three FORCE_* flags1 and512 entries for each bank. The physical9-bit IDs therefore do not establish lost18-bit arbitration IDs. Ordering is per read/write channel, not a cross-channel visibility fence.
- `ofs_plat_axi_mem_if_map_bursts.sv:186,219–220,281,317–323` sets/ORs NO_REPLY for generated subbursts, suppresses intermediate RLAST, and hides intermediate BVALID using restored USER. Read data beats are not discarded. This is the source-supported composition, not proof of all response conservation, metadata exhaustion or intermediate-error propagation. In particular, hiding an intermediate B response is not evidence that its BRESP was accumulated into a final software-visible error.
- Mapper61–80 explicitly instantiates `fixup_wlast`. That primitive's45–119 couples AW with first data availability, buffers AW/W and reconstructs WLAST from the accepted split LEN using a SOP tracker. Native5952–5988 lists both banks' AW/W registers and5-bit SOP trackers. No claim of arbitrary generic-AXI peer/backpressure compatibility follows from this ready/enable-style PIM implementation or from elaboration.
- Wrapper clock/reset copying adds no new clock source, reset IP or clock gate. `ofs_plat_local_mem_as_axi_mem.sv:55–70,103–118,229–252` retains crossed AFU reset plus each bank's own reset, the AFU-domain interface reset and per-bank CDC. Native5510–5544 confirms both bank async shims,3timing stages,256read/128write credits and the one-stage FIU-side pipe. Runtime reset ordering, stopped clocks, in-flight traffic and recovery remain F2; wiring/native parameters are not CDC/STA signoff.

### Two generated LSU overlays

Only the following original→candidate hashes differ within the255-entry generated inventory:

| File under `G/mmhost_ia840f_report_di_10/synth/` | Original SHA256 | Candidate SHA256 |
|---|---|---|
| `lsu_burst_coalesced_pipelined_read.sv` | `e87670399d7a99f2043198698b5363223dab54c2d754b6156f97d317d3709f85` | `080ef3e207155f5c65e2aa9b28509b4b1d52455086ef2d43bca7c6571054dd27` |
| `lsu_burst_coalesced_pipelined_write.sv` | `a1662618eab5784456b0bde941648383532109b68045d520af58f5ab14932cce` | `3af68a0ed68358861a559887c1856b1db9470ea7c97a631c09c2e088c9f2d7a5` |

The read hunk expands only the reset assignments to `kword_address_cpipe[2..5]`; localparam COALESCER_PIPE_DEPTH=5 (line281), while element1 belongs to the separate existing writer. The two write hunks expand reset assignments to `thread_count_inc_vpipe[1..3]`; VALID_GEN_THREAD_COUNT_PIPE_DEPTH=4 (line1030), with element4 handled separately at1322/1331/1333. Reset values, event controls, reset conditions, always_ff constructs and all non-reset logic are unchanged. This is the narrow constant-index ownership correction, not relaxation of always_ff or suppression of a real overlap. Full functional validation belongs to the separate review and is not duplicated here.

### QSF delta

The complete measured diff agrees with `source-binding01.json/qsf_diff`: add `rtl/afu/ia840f_ahls_memory_bank_shim.sv`; remove only command-line `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU=1`. The preserved `I/platform/platform_afu_top_config.vh:37` still defines it. No suppression, SDC, pin, frequency or physical-IP changes occur. Existing PIM primitive SDC assignments remain; retained Tcl setup metadata is not newly executed by this QSF.

## 4. Warnings: full count and bounded dispositions

Full-log accounting, not report-copy addition: **226 occurrences** versus banner1. Exact predecessor comparison yields **341−118+3=226**. Removed118 are duplicate-macro21425. Added3 are the active LEN5 splitter sites below. Four existing read-LSU warnings move405→406,503→504,887→888,1130→1131 because the reset hunk adds one line. Accounting for those explicit line moves leaves no other diagnostic delta.

| ID | Count | Disposition |
|---|---:|---|
|13469|90|Three newly active sites independently bounded below; predecessor's other87 width/arithmetic dispositions remain, including dynamic/protocol limits. No blanket waiver.|
|21610|86|Unchanged undriven-output set. Reuse source/consumer-specific inactive-channel and specialization analysis. Active status limitations remain: log5258 ties AHLS `device_exception_bus[0..63]` to ground; it is not a numerical/error checker.|
|16788|22|Unchanged undriven-net set; predecessor's specific inactive directions/metadata classification retained, not an assertion that arbitrary undriven traffic is harmless.|
|21442|19|Unchanged package-parameter/localparam semantics; no required package override added.|
|16752|2|Unchanged uninstantiated CCI-P invalid-credit error branches, not an observed combinational loop in the selected native AXIS path. Revisit if host class changes.|
|21705|2|Active FIFO `$fatal` ignored for synthesis (log5059–5060); A&E supplies no overflow/underflow exercise or software fault visibility.|
|13461|1|Inherited CCI-P ROB declaration diagnostic, not newly active CCI-P behavior.|
|17498|1|Inherited HLS declaration-localparam diagnostic.|
|20759|1|Missing device Reset Release; High/unwaived F2 obligation, not suppressed.|
|21620|1|DRC summary of that same Reset Release failure, not a second independent defect.|
|23762|1|Sweep summary; native30689–30696 still identifies unused write-only MMIO formatter, write-ROB RAM specialization and `freeze_cc`, not removal of the computational core or both bank shims.|

### Three new active width sites — source-justified within the selected domain

All three are Warning13469 and refer to unchanged PIM source newly specialized for the bank splitter; the host LEN3 occurrences remain separate at log5043–5045.

| Native log / source | Exact concern | Bounded disposition and remaining check |
|---|---|---|
|5112; `R/utils/prims/ofs_plat_prim_burstcount0_mapping_gearbox.sv:48` | 32-bit subtraction result assigned to5-bit LEN: `s_burstcount = s_b1 - 1` | Source46 defines6-bit count-one `s_b1`; the page gearbox caps valid output at32beats. Valid counts1..32 become LEN0..31, fitting5bits. Idle/reset count zero is not a legal request; mapper196–203/291–298 control request VALID. This explains the warning, not a runtime assertion of all state transitions. Functional acceptance must retain split/tail/backpressure/count checks. |
|5113; `R/base_ifcs/axi/prims/ofs_plat_axi_mem_if_map_bursts.sv:177` | Initial AR LEN copy8→5 | `OFS_PLAT_AXI_MEM_IF_COPY_AR` copies fields individually; in the same always_comb,179–180 replace the line-address portion and LEN with gearbox outputs. Full34-bit address and18-bit ID are not packed-shifted/truncated by this LEN warning. Native panels bind source8/sink5. Address-page/response behavior still needs functional evidence. |
|5114; same file273 | Initial AW LEN copy8→5 | The field-wise AW copy is followed by explicit mapped address/LEN overrides275–276;281 sets the intermediate-response marker. Outer fixup_wlast is present in both banks. This is not proof of AW/W stall conservation, final-response correctness or error propagation; those stay with the functional/fault contract. |

These are expected width idioms for this exact elaborated configuration, not warnings suppressed globally or a portability claim for different page/LEN/data geometry.

## 5. Runner quality and predecessor finding dispositions

### Runner acceptance and evidence handling

The exact template delta is limited to fresh work/transport identities, separated original/candidate inventories and two overlay application, broader competing-tool names, four generated exports, candidate provenance and the repaired acceptance predicate. It preserves finite supervision: `Popen` is inside try/finally, the leader is kept unreaped with WNOWAIT until group signaling finishes, helpers may drain within the deadline, native return status is persisted before fallible export work, and effective failure propagates to outer exit. This is static review plus this run's receipts, not newly executed supervisor fault injection.

Template132 now requires `native_stage_pass`, an empty `postflight_errors`, and `result.get(k) is True` for all six preservation flags, including `platform_originals_unchanged`. The ten recorded inert fixture cases are unique and accepted==expected for each: valid; each of six flags false; nonempty errors; native failure; missing platform flag. Static inspection agrees with all ten truth-table expectations. No payload-bearing runner or acceptance expression was executed by this reviewer. These cases establish the intended bookkeeping predicate, not process supervision, real resource exhaustion or HDL functionality.

**Residual runner-quality limitation (nonblocking for this captured result):** the postflight export loop118–127 still has unwrapped file-read/stat/hash assertions. A future acquisition failure there can prevent the final compressed archive/normal acceptance receipt, although native status has already been persisted and failure is not converted to success. The ten truth-table cases do not cover that path or supervisor exception races. Do not claim comprehensive collector fault-injection coverage. If this runner is changed for robustness, preserve raw native status and independently record export failures, then exercise the actual error paths with inert inputs in a separately permitted task. No current archive gap was observed: all13 exports verify.

Source-bound guards, normal-account execution, process affinity and per-process RLIMIT_AS are **not an OS sandbox** or a guaranteed aggregate-memory bound. The preflight is recorded evidence, not proof of perpetual exclusivity or current remote state. No additional run is needed merely to restate those limits.

### F1–F6 carried forward precisely

| Predecessor finding | Successor disposition |
|---|---|
| **F1 — High for functional acceptance: burst contract** | **Local PAGE_SIZE0 gap corrected structurally in this candidate**, by the separately active4096-byte wrapper before the unchanged inner shim. Exact path08 bytes and native consumption are established. Broad host generic-WRAP semantics, actual primary PCIe mapper execution, response/metadata/credit conservation, maximum-length transfers and fault handling remain open. This A&E review does not consume the pending functional review. |
| **F2 — High for lifecycle/hardware: freeze/drain/reset/PR** | **Open.** Freeze forwarding is unchanged and native sweep still removes `freeze_cc`. DRC `.drc.partitioned.rpt:49,62–71` remains RES-10204 High1,0waived, zero device Reset Release instances. No duplicate device-level IP was added. The real FIM must establish its provider/topology and reset propagation; global drain, in-flight recovery, PR isolation and buffer-release safety remain unproved. |
| **F3 — High for host control/error/lifetime** | **Open.** Full-width MMIO admission before downstream aliasing, posted-write error visibility, actual first-response codes/telemetry, fences, destination invalidation and pinned-buffer lifetime are not repaired by the page wrapper. Constant-zero exception/status fields and unrouted IRQ remain no proof of success or safe control. |
| **F4 — Medium: omitted platform preservation in acceptance** | **Closed for this successor predicate.** Platform preservation and empty postflight errors are now required; the actual result has every required flag true and errors empty. Ten recorded inert cases support the focused fix. Old consumed runner/receipt remains unchanged; broader collector robustness is separately bounded above. |
| **F5 — Medium: four missing local generated exports** | **Closed for the current composed evidence set**, not retroactively for P. Both CMPs, exact reset SDC and parameter-assert header are exported under `T/artifacts-elab01/generated` and match the original inventory hashes. No regeneration occurred. Capturing an SDC/header is not native STA evaluation or timing acceptance. |
| **F6 — Low: duplicate command-line macro** | **Closed for this changed QSF.** Only redundant macro removed; preserved platform definition remains. All118 corresponding warnings disappear naturally, without diagnostic suppression. |

Recovered F5 files, retaining original SHA256:

- `ahls_memory_dma_fabric/ahls_memory_dma_fabric.cmp`: `d56f695b57f4971325f6c3a3cad5cdd02ce115bf706a3dec7678174afdec2db1`.
- `G/ahls_memory_dma_fabric_fabric.cmp`: `d04b18474db9c14ef7aab9c5bc5029b28765edac9e6f9441efdff33af8bf1b87`.
- `G/altera_reset_controller_1924/synth/altera_reset_controller.sdc`: `e125bfda461376db31321949301164b907bb6d2719cd10456b8cd8cd8904282c`.
- `G/mmhost_ia840f_report_di_10/synth/acl_parameter_assert.svh`: `34b039fd2b2bbf5e51500685220bb1b6a2f4070719e0dd56ba4d98ee069a8416`.

The recovered SDC26–43 selects reset-synchronizer pins/registers and conditionally applies reset cuts or fallback min/max delays. Ordinary read/hash recovery proves its bytes; no report here establishes native collection resolution, effective exceptions or reset timing signoff.

## 6. Handoff and acceptance limits

The separate functional binding SHA256 `c4c5c68611880b5bad69097a271f560253d344837ef68da9a69a16831ae1f849` and path08 result SHA256 `d7599845d6c86d5c6e386472689694e1d22f7765fa2d4a3275fe3fb8259c9411` match this runner's provenance. The result records4cases,91sums,1088copied bytes and16DMA operations with a passing scoreboard. That remains **separate simulation evidence**, using byte-accurate synthetic memories/linear host behavior and no actual primary PCIe mapper or physical DDR model. This review checked candidate identity and the evidence boundary, not its full test audit; independent functional review is **pending parent acceptance**.

Parent may consume this FINAL report for **bounded native A&E result acceptance only**. No unchanged rerun is justified by the three source-explained width warnings, the corrected bookkeeping predicate, or recovery of already hash-bound files. Existing F1/F2/F3 and Work21 obligations still prevent broader signoff; further work must address those concrete unresolved contracts within the parent's authorized workflow, not silently expand this result into deployment permission. No FPGA/device/MMIO/driver/flash/reboot action occurred or is implied. **Goal remains incomplete.**
