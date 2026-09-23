# Independent review — DMA + AHLS connected component

**Status: FINAL**  
**Specification: PASS for the stated component-generation / connected analysis-and-elaboration scope.**  
**Quality: PASS_WITH_NONBLOCKING_FINDINGS for that milestone, not functional acceptance.**  
**Bounded verdict: ACCEPT_NATIVE_GENERATION_AND_CONNECTED_ANALYSIS_ELABORATION_WITH_FINDINGS.**

No blocker was found to accepting the exact completed native generation and component A&E evidence. All generated boundary ports are connected, the requested geometry/BRESP changes are exact, and no newly undriven active memory/control path or wrong-field connection was established. There are confirmed software-visible diagnostic defects and substantial retained integration obligations below. Native success is neither a warning waiver nor acceptance of a functioning/deployable accelerator. No unchanged native rerun or extra launch-approval gate is requested.

This FINAL replaces the early IN_PROGRESS report. Review activity was local file reading, hashing, inert AST/literal/JSON/XML parsing, source comparison and arithmetic. Neither runner was imported or executed. No SSH, vendor/simulator/native execution, hardware access, source edits, git operations, publication or task transitions occurred. Only this report was created/modified.

## 1. Specification compliance — reviewed first

Paths are relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless stated otherwise. **Z** = `qualification/ahls-memory-dma-core01`; **R** = `Z/inputs-core01`; **F** = `Z/artifacts-fabric01`; **G** = `F/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric`; **E** = `Z/artifacts-elab01`; **AE/SYN/DRC/FLOW** = `E/output_files/ia840f_ahls_memory_core_elab.` followed by `syn.ae.rpt/syn.rpt/drc.partitioned.rpt/flow.rpt`.

| Requirement | Independent result |
|---|---|
| Additive fabric; old accepted component untouched | **Pass.** Full source diff changes only module NAME, the shared DMA-input S0/M0 ID parameters16→9, MMIO M0BRESP0→1, and DMA-CSR S0/M0BRESP0→1. The original maintained component still hashes to its fabric03 recorded input: `9adb503379d3b6853a954581043467dbb5fc5ae8c1ee090eb7f1204a68959448`. No other Tcl geometry, latency, clock/reset, interconnect requirement or HLS edit appears. |
| Correct native tool, device and stage | **Pass.** Logs and saved XML bind Quartus25.1 Build129, Agilex7, `AGFB027R25A2E2V`; qsys import/validate/save and synthesis-HDL generation completed. Actual elaboration argv contains `--analysis_and_elaboration`; FLOW explicitly identifies **Synthesis (Analysis & Elaboration)**. The generic synthesis-success banner is not mapped synthesis. |
| Complete generated interface | **Pass.** Independently parsed native top HDL and SOPCINFO agree on **245 unique ports /11 interfaces**, including the final port without a trailing comma. Relative to accepted fabric03 there are exactly eight DMA ID-port changes16→9, one added two-bit `dma_csr_bresp`, and no other name/direction/width change or removed port. |
| Real connected DMA and kernel, not surrogate modules | **Pass structurally.** Actual DMA top, CSR,166-bit descriptor FIFO/scfifo, selector, directional mux, both PIM register slices, reader, writer and514-bit data FIFO/scfifo are in AE. The actual DDRIP kernel/CRA/LSUs remain at `fabric|fabric|fabric|k0`. R/ia840f_ahls_memory_core.sv:240–489 instantiates generated fabric and DMA, not primary-host or per-bank PIM mappers. |
| Explicit complete core wiring | **Pass.** Recomputed **171 flat external ports** and **245 unique named fabric connections** exactly match connection-ledger01.json. Every endpoint was independently checked against the identity or channel/field/bank-index mapping, rather than merely trusting ledger coverage. No generated-boundary ID/USER slice, empty connection or wrong-bank mapping was found. |
| Geometry and responses | **Pass at this boundary.** External host address57/data512/LEN8/ID9/USER4; DMA bank input address34/data512/LEN8/ID9/USER2; bank output ID18/USER2; DMA CSR address16/data64/ID18/USER1. The new BRESP connects to the actual `dma_csr.b.resp`, not OKAY. Generated bridges retain enabled BRESP forwarding. CSR single-beat WLAST goes to the explicit unused wire because AXI-Lite has no WLAST. |
| Preserve kernel and accepted corrections | **Pass.** All **155 HLS synthesis-member inventory entries** match accepted fabric03. Of these,154 current captured bodies compare directly; the remaining `acl_parameter_assert.svh` has matching current native inventory and prior captured bytes. All **551 kernel-instance parameter maps** are identical after changing only the enclosing hierarchy prefix. Corrected LSU SHA256 remains `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd`. |
| Honest scope | **Pass.** SCOPE/RESULTS/core README explicitly exclude full generated PIM import, functional/numerical execution, mapped synthesis, fit/STA, physical DDR, deployment and hardware acceptance. DDR vendor simulation remains **SKIPPED BY USER**. Dummy component UUID must not be deployed or used for discovery. |

The native bridge parameter panels independently confirm the exact intended effective changes: AE:3010 onward MMIO changes only USE_M0_BRESP; AE:3113 onward DMA CSR changes only USE_M0_BRESP/USE_S0_BRESP; AE:3216 onward both DMA input instances change only S0_ID_WIDTH/M0_ID_WIDTH; AE:3320 onward both bank-output instances are unchanged. These comparisons use complete per-instance parameter maps, including **All Instances**, not just selected geometry fields.

## 2. Evidence integrity and native completion

Independently verified all **22/22 frozen package entries**, byte lengths and hashes, against:

`Z/review-package01.json` SHA256 **`aa5123970898776bdc2a5e89bbbcc782a9fb7cc505151d5be1e16c0a112566df`**.

The following checks passed:

- Both payload-bearing runners parse as Python AST. Only their literal `C` assignment was decoded with `ast.literal_eval`; replacing that assignment with `C=@CONFIG@` reproduces the corresponding frozen template exactly. Dispatch hashes match both full runner files. Generation's four authored inputs and elaboration's25 base64-encoded core inputs match their local snapshots and recorded hashes.
- Both compressed archives match their outer receipts. Every encoded member decodes to its recorded size/hash and to the exact local captured bytes: **261/261 fabric members and7/7 elaboration members**. Manifest metadata equals archive metadata after excluding encoded bodies and the added capture-manifest field.
- Both generated QIPs were independently parsed across **all `_FILE` assignment types**:254 edges,253 distinct targets plus two QIPs =255 generated inputs; with25 core inputs, **280 bound inputs**. Literal assignment lines/types/targets match qip-dependencies01.json. Every generated input's size/hash agrees with the generation inventory and elaboration configuration/result inventory.
- Current archive capture is not the entire286-entry generation inventory. Four QIP targets have no current captured body: two `.cmp` files, `altera_reset_controller.sdc`, and `acl_parameter_assert.svh`. All four are native hash-bound inputs; the SDC/SVH additionally match prior locally captured bodies. The two changed-name `.cmp` declarations are metadata, not substituted HDL. This distinction does not invalidate A&E closure, but the261 count must not be described as all generated outputs or all255 input bodies captured locally in this attempt.
- Elaboration's configured QSF, project01.qsf and captured completed QSF are identical, including both QIPs, ordered source packages/interfaces, selected top/device, two processors and explicit known power-format settings.
- Actual DMA implementation files match the immediately preceding CSR-admission baseline; the integrated CSR instead exactly matches its final `inputs-candidate02/csr_mgr.sv`, SHA256 `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073`. Component include/projection/UUID inputs are explicitly different, not relabeled full-platform imports.

| Attempt | Captured native result and scope |
|---|---|
| fabric01, tmux @217 | Native/effective rc0 for import and generation; outer0. Fresh root `work_ahls_memory_dma_core01/fabric01`. Import11:11:34.999686–11:11:44.695330Z; generation11:11:44.711863–11:11:58.711542Z. Short-lived helper PIDs were observed at launcher exit and drained; no timeout or surviving owned group recorded. |
| elab01, tmux @218 | Native/effective/outer0, runner accepted. Fresh root `work_ahls_memory_dma_core_elab25_01/elab01`. Native11:18:33.481246–11:19:18.384190Z. No timeout or surviving owned group recorded. Exact argv: `/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_core_elab -c ia840f_ahls_memory_core_elab`. |

Generation's224 original/copied input checks, corrected-LSU check, component/script/tool preservation and elaboration's original/copied/core/tool/QSF preservation are all true in captured postflight. This is independently inspected **recorded preservation**, not a new live remote re-hash or an OS-sandbox claim. The local extraction interruption is resolved by the verified existing archive and full261-member readback; it is not a failed native generation or reason to rerun it.

| Artifact | SHA256 |
|---|---|
| result-fabric01.json.gz | `e04cb136ecf372394280898d48e56650d6b17bb5eb642b71d55141f67269f090` |
| result-elab01.json.gz | `c80f704f7d4935249deef9af8836e7fa2a3cc29aec9bb248e0ec471ef3d0cd66` |
| Full AE,2915728 bytes | `28fc18ac272bd274d4e33138a91bcab72ac3ac949233da002086161116208bc1` |
| Full SYN,3333072 bytes | `b4fe1fbcc3d09c38e38a4ccdf89c28250267f09823c9f7fa909cdc34935c3c05` |
| DRC | `8b4f4c0550907fe33515103f5aa2c87fefa380e561fab10eb09064c6dc65310f` |

Full native reports, not truncated2MB excerpts, were used for parameter-map and diagnostic checks. No Error/Fatal diagnostic was found in native import/generation/elaboration logs or full SYN.

## 3. Source/wiring quality and diagnostic disposition

### 3.1 Geometry is a source-bound projection, not completed PIM integration

All seven geometry-binding01.json source hashes match. The local USER derivation is correct: captured `mem_ss_if_info.vh` declares ARUSER/AWUSER14 but **no WUSER**; FIM package WUSER fallback is1; local-memory NO_REPLY flag width is1; local_mem_cfg_pkg therefore gives **USER2**, not14. Source interface defaults subtract one from the package's9-bit burst-count width to produce AXI LEN8. The prior USER14 unit fixture was synthetic and is not this integration geometry.

For complete provenance, the two-bank leaf is the already captured `mem_ss_param_pkg.sv:6` (NUM_PORTS2), not an explicit bank count in mem_ss_if_info. The host chain passes through ofs_pcie_ss_cfg_pkg → ofs_pcie_ss_plat_cfg_pkg → captured ofs_fim_cfg_pkg:32–36; captured `ofs_ip_cfg_pcie_ss.vh:33` defines DWIDTH_BYTE64. Together with the host line-address width51, this supports the selected512-bit data/57-bit byte-address projection. These supplementary leaves are outside the seven-entry geometry ledger; a successor full-PIM binding should include them explicitly, not silently promote the small ledger into full-platform closure.

Native AE:2762–3005 confirms actual CSR, descriptor FIFO, selector, both register slices and engine/dataFIFO parameters. No primary host mapper or per-bank user_ext/burst/CDC shim is instantiated. The captured `ofs_plat_local_mem_as_axi_mem.sv:125–187,200–229` shows the supported burst/user/extra-ID preservation and optional CDC path; it is evidence for later integration, not circuitry in this native pass. **Never slice bank output ID18 to physical ID9.**

### 3.2 Counts reconciled without waivers

Native elaboration.log contains **142 occurrences =141 Warning +1 Critical Warning**. Every occurrence exactly matches warning-ledger01.json; all140 source-bearing occurrences resolve to hash-matching local source. SYN's populated message Count cells independently sum to142 (lines12651–12974). The generic banner still says **0 errors /1 warning**. That summary is a different, unexplained vendor presentation, not the complete occurrence count. Repeated log/report presentations are not added together.

| ID | Total | Source/consumer disposition |
|---|---:|---|
| 13469 | 49 |28 inherited HLS arithmetic widths;21 DMA/mux/CSR widths, classified below. No blanket truncation waiver. |
| 16788 | 17 |13 inherited HLS undriven diagnostics;4 new DMA interface `instance_number` debug nets, not bus/control fields. |
| 21610 | 73 |13 inherited HLS outputs;60 DMA outputs:17 unused writer-status fields,15 unused reader-status fields,11 inactive writer AR payload fields,16 inactive reader AW/W payload fields,1 selected-interface debug number. |
| 17498 | 1 |Inherited generate-local parameter interpretation. |
| Critical20759 | 1 |Missing device-level Reset Release IP. Open full-device obligation. |
| 21620 | 1 |Reports that same High DRC failure, not another independent violation. |

The57 inherited occurrences match the prior accepted connected-fabric diagnostics exactly after normalizing only source/report paths and the enclosing hierarchy prefix. Reuse is additionally supported by155 source-inventory equalities and551 kernel-instance parameter-map equalities; it is not a waiver based on familiar IDs or vendor origin. The observable64-bit HLS exception bus remains undriven/tied to zero and cannot establish error detection, completion or numerical correctness.

### 3.3 High-priority active-path checks

**Partial status is not an active unwired bus.** R/dma_top.sv:72–98 initializes aggregate status and selects the actually driven fields from each engine: own performance/state, read descriptor count, sticky read/write error, stopped-on-error, busy, and independently driven FIFO status. The32 undriven partial-status fields listed above are not those selected active producers. The writer's unused read channel has ARVALID0 (dma_write_engine.sv:249–255); reader AWVALID/WVALID are reset0 and never raised (dma_read_engine.sv:148–159). Their undriven payloads are not offered as transactions under the required reset sequence. The four16788 nets and selector21610 debug net carry `instance_number`; interface consumers use these for logging/check diagnostics, not memory addresses, IDs, enables or reset. Explicit defaults would improve lint/simulation hygiene but do not establish an active-traffic defect here.

**Packed mux warning is not proof of high-IOVA clipping.** R/dma_axi_mm_mux.sv:45 performs a redundant packed AR assignment; lines73–85 subsequently overwrite every AR field through the native macros (R/ofs_plat_axi_mem_if.vh:188–199). Thus the97→74 warning at mux:133/141 concerns a superseded packed assignment. Final field-wise DDR address narrowing keeps the bank-local34-bit offset; dma_ddr_selector.sv:29–41 separately selects the bank from descriptor bit34. Both DMA directions retain host57 through the actual register slices. The selector masks inactive response payloads/readiness and holds inactive RREADY/BREADY low (selector:60–116). These observations agree with the accepted routing evidence, but do not simulate the newly generated fabric.

**USER4→2 is real narrowing, with a restricted present domain.** Ordinary reader AR is reset to zero and updates only address/length/burst/size; writer AW is similarly initialized, WUSER is zero, and mux:145–146 forces ATOP0. This supports the present zero-special-flag request subset. Response USER is not used for the engines' completion/error accounting. It does **not** establish arbitrary host USER, atomic, interrupt or fence preservation. Do not remove the warning by globally widening local USER to14 or by slicing generated bank IDs.

**Request-counter widths are guarded, not generally safe for arbitrary descriptors.** Reader:94–97,174–176 and writer:81–89,200 use9-bit request/reply counts. CSR:88–89,117–128 limits descriptors to511×256 =**130816 beats /8372224 bytes**, checks nonzero length, endpoints and same-bank range before GO. Within that admission contract the13→9 request-count truncations do not discard a legal count. Eight-bit AXI LEN retains the final burst's beats-minus-one representation; subtraction warnings do not authorize zero-length inputs. Twenty-bit performance-counter arithmetic wraps modulo its width and is not an unbounded duration metric. Maximum-length transport, arbitrary response streams and end-to-end reset/drain are not established here.

### 3.4 Actionable findings

**F1 — Medium, confirmed software-visible configuration defect; nonblocking for generation/A&E.**  
R/csr_mgr.sv:200–201 assigns raw512 and32 to respectively3-bit `config1.data_width` and4-bit `data_fifo_depth` (dma_pkg.sv:225–238). Both read back **zero** by truncation. No source-defined encoding conversion justifies those zeros; do not call them an accurate capability report merely because hardware parameters are correct. The fixed400MHz field at csr_mgr:207 is also not timing/clock evidence for this external-clock component. **Action:** define/document the intended capability encodings and actual clock-reporting contract, assign explicit representable values, and add CSR readback checks in the next changed package. Do not alter datapath geometry to match broken telemetry or rewrite this consumed run.

**F2 — Medium, confirmed writer-state observability defect; nonblocking for engine wiring/A&E.**  
R/dma_write_engine.sv:38–63 defines9 one-hot state bits; line128 writes them into the6-bit field selected by dma_pkg.sv:20,183. RD_FIFO_WR_DEST, WAIT_FOR_WR_RSP and ERROR therefore all read as **zero** in `wr_state`. The actual9-bit FSM is not truncated, and separate sticky error/busy signals remain connected, so this is not evidence that the engine loses its ERROR state internally. **Action:** use a documented complete state encoding or a deliberately revised register layout without shifting established status/error bits accidentally, and check transfer/wait/error readback states. The150→64 warning at csr_mgr:289 is distinct: it drops the two40-bit performance structures plus6 high reserved bits, while preserving actual low status bits; performance counters already have separate CSR reads at297–298. Make the64-bit status packing explicit rather than treating every aggregate truncation as harmless or widening it blindly.

**F3 — High for future software recovery/visibility claims, retained integration gap; not a newly failed native stage.**  
Reader first response code is driven at dma_read_engine.sv:209–210, but dma_top:86/88 and csr_mgr:179/181 force exposed response encodings to zero/NOT_SUPPORTED. Writer `wr_resp_enc` is undriven and not selected by the top. Actual sticky rd_rsp_err/wr_rsp_err and stopped_on_error are connected; first-error detail and admission-failure persistence are not. Moreover csr_mgr:186–187 reports written legacy reset/stop control bits, not acknowledged quiescence; dma_top:121 gates FIFO dequeue with stop_descriptors. Neither is a safe active-operation drain/reset ABI. **Action:** preserve the no-live-recovery/no-buffer-release claim, then implement and qualify explicit readable admission/first-error state and a source-supported drain/reset/fence/ownership contract before software relies on them. Internal forwarded BRESP alone cannot report a posted PCIe write failure reliably to the CPU.

**F4 — Low, source/manifest hygiene; no current milestone blocker.**  
Remove the redundant packed AR assignment in a future reviewed mux change, initialize unused payload/status/debug fields where appropriate, and bind the supplementary bank-count/host-width leaves in the next geometry manifest. Any such change must preserve the actual channel/field behavior; no warning suppression or unchanged rerun is justified by this cleanup alone. Reuse current read-only evidence rather than modifying frozen sources/manifests.

## 4. Explicit unresolved acceptance boundaries

These are **blockers to broader integration/deployment claims**, not blockers to recording the completed scoped native milestone:

1. **Reset DRC remains failed:** DRC reports **RES-10204 High,1 violation,0 waived;1 of10 rules failed; zero Reset Release IP, exactly one required**. Component reset is external. Establish the full FIM's single device-level Reset Release owner and distribution; do not add a duplicate to the persona merely to silence this standalone report. External clock/reset and freeze wiring do not prove PR quiescence or device configuration release; DMA is not stopped by the kernel freeze input.
2. **MMIO is not a protected outer aperture:** new read/write router sources `G/altera_merlin_router_1921/synth/*_bknbsua.sv` and `*_pleb25y.sv`:162–174,214–223 still decode low17 bits of the20-bit address. `0x30000` aliases kernel `0x10000`. CSR admission validates only the16 bits it receives. An upstream single-beat/access-shape/full-aperture guard is required before narrowing; unused CSR WLAST does not make arbitrary AXI bursts legal.
3. **Actual PIM composition remains absent:** exactly one primary host owner, real generated packages, per-bank ID18 preservation into the physical ID9 domain, USER semantics, burst/protocol mapping and CDC/reset need completed integration. The finite unit fixtures use synthetic line-request endpoints; arbitrary AXI WRAP/4KiB semantics and mixed special host flags are not qualified by this A&E.
4. **No connected numerical/functional proof:** actual DMA+fabric+full kernel was not run end-to-end. Prior accepted reader/writer/routing/CSR unit evidence is reusable within its domain, not evidence for this new transport shape or physical DDR. HLS accepted-write accounting and the constant-zero exception output do not prove downstream memory visibility.
5. **No physical/platform acceptance:** full FIM signoff, mapped synthesis, fit/timing/CDC, physical DDR behavior, host pinned-buffer lifetime/fences, OPAE/discovery, image identity, programming and durable boot remain outside this result. No device/MMIO/driver/programming/reboot operation is authorized. Vendor DDR simulation stays SKIPPED BY USER.

## 5. Prerequisite review disposition and handoff

- Routing prerequisite is FINAL and parent-accepted; its report matches SHA256 `8e4d8948f0e3b972c583634451b658b70b13659bb8c3e7d3b44f1173cfa63a71`, corroborated by `qualification/dma-top-routing01/RESULT-ACCEPTANCE.md`. Retain its bounded findings rather than reopening the whole unit audit.
- The CSR review was pending at package preparation, but its **FINAL PASS_WITH_NONBLOCKING_FINDINGS** is now available locally and was read: `qualification/dma-csr-admission01/independent-review01.md`, SHA256 **`11aca920d44f875204431244c6a69a546803ef72436c5e79b764400e033e2970`**. It reports no in-scope admission blocker and retains source-only predicate-coverage and guard-total binding findings. Integrated CSR bytes match that reviewed candidate. Parent consumption/publication remains separate; frozen RESULTS01's preparation-time wording is not rewritten here. Do not turn the historical pending status into retrospective native-launch denial, and do not silently waive any prerequisite finding.
- Parent may accept this exact native generation / connected A&E milestone with F1–F4 and the above limits. There is **no required native rerun on unchanged inputs**. Functional or platform acceptance remains withheld.

All22 frozen entries and the package hash were rechecked unchanged before final reporting. The report's final full-file SHA256 is supplied in the handoff after writing; it is deliberately not embedded in its own hashed contents.
