# Independent review — Quartus 25.1 standalone analysis/elaboration

Status: **FINAL — ACCEPT bounded elaboration evidence; NOT full-device or functional acceptance.**

The corrected AHLS 2026.1 memory component was actually analyzed/elaborated by Quartus 25.1 Build 129 for AGFB027R25A2E2V, with the intended hierarchy present. Native/effective exit **0** is supported independently of the runner's failed acceptance. Preserve outer **125**, `success_marker=false`, `native_stage_pass=false`, `qsf_unchanged=false`, and `accepted_by_runner=false` as historical facts. This review does not rewrite those receipts or require a redundant native rerun.

**Not accepted:** warning-free compilation, full mapped synthesis, full-device DRC/reset qualification, fit/STA, functional/numerical kernel correctness, DDR operation, DMA/PIM integration, memory visibility, or hardware acceptance. DDR simulation remains **SKIPPED BY USER**. No new source-launch approval gate is created.

## Citation keys and evidence integrity

All paths expand from `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `E=N/qualification/ahls-memory-elab25-01`; `A=E/artifacts-elab01`.
- `L=A/elaboration.log`; `AE=A/output_files/ahls_memory_elab.syn.ae.rpt`; `SYN=A/output_files/ahls_memory_elab.syn.rpt`; `DRC=A/output_files/ahls_memory_elab.drc.partitioned.rpt`; `FLOW=A/output_files/ahls_memory_elab.flow.rpt`.
- `P=N/qualification/ahls-memory-abi01/artifacts/build/mmhost_ia840f.report.prj`; `S=P/ip`; `K=P/kernel_hdl/DDRIP`; `M=P/mmhost_ia840f_report_di.sv`.
- `I=N/qualification/ahls-memory-pd25-import01/artifacts-import02`; `T=I/ahls_memory_import/synth/ahls_memory_import.v`; `W=I/ip/ahls_memory_import/ahls_memory_import_k0/mmhost_ia840f_report_di_10/synth/lsu_ic_top.sv`.

Independent local byte/size/SHA256 checks passed for **17/17 frozen package files**, **7/7 captured native members** against the original archive's decoded payloads, and **14/14 warning-referenced local source files** against both the ledger and native generated inventory. Additional cited generated consumers, `S/lsu_top.sv`, `T`, and `W` were also hash-matched to that inventory. Manifest fields equal the original archive metadata, excluding the added capture block and encoded file bodies. Dependency ledger: **177 edges / 174 distinct targets / four QIPs**, all target size/hash entries matching the **222-member** source inventory. Original/copied input preservation and no surviving owned group are supported by the captured postflight, not a new remote inspection (`E/manifest-elab01.json:3–28,36–37`; `E/run-elab01.py:10–15,28–30,89–96`).

| Identity | SHA256 |
|---|---|
| Frozen `E/review-package01.json` | `3129301f3bf88b73fdf986039c5b46815ce207d8698d45d4899be5a39aef5665` |
| Original `E/result-elab01.json.gz`, 348519 bytes | `7ce24877a886417f6ff2e379f79b2a2ead0a07eb7a38399e5b8d1665f7456480` |
| Corrected `W` | `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd` |
| Consumed prior `N/qualification/ahls-memory-pd25-import01/independent-review02.md` | `a1143ae4ac7e683b395e05a9e343bc6c6c4086e263e58bdf72ca34ce804ae30b` |

The prior import review is reused, not reopened. The write-ack correction retains its **unit-only** acceptance; elaboration adds no functional qualification to it.

## Native outcome versus outer bookkeeping

- Exact native command: `/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ahls_memory_elab -c ahls_memory_elab`. Native/effective rc0, no timeout, no descendants at leader exit, no owned survivors: `E/manifest-elab01.json:3–26`. Outer125: `E/manifest-elab01.json:1392–1395`.
- Native tool/version/command: `L:3–4,19–25`. Correct top/part: `SYN:314–330`. `L:93,107,115–118` records 230 entities, **659 elaborated partitions**, generic success, 2301 MB peak virtual memory, and 20 seconds. `FLOW:64–70,86` explicitly labels **Synthesis (Analysis & Elaboration)**. “Quartus Prime Synthesis was successful. 0 errors, 1 warning” is not proof of full mapped synthesis.
- Runner expected nonexistent stage-specific text, “Quartus Prime Analysis & Elaboration was successful”; its logic then rejected the run (`E/run-elab01.py:104–115`). The actual generic banner is `L:115`.
- Exact QSF byte comparison found only two appended lines: `set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"` and `set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"` (`A/ahls_memory_elab.qsf:10–11`). `L:1` reports the power-format default adjustment. `--write_settings_files=off` did not keep this QSF byte-identical. These are project-default mutations, not copied-HDL changes or proof of board power qualification.
- All four QIPs are explicit (`A/ahls_memory_elab.qsf:6–9`); native library ordering and source consumption agree (`L:41`; `SYN:450–457,516–517,596`). No missing-component/elaboration-error outcome appears in the captured run.

## Actual active hierarchy

The native **Parameter Settings / All Instances** panels, not instance names alone, establish:

| Instance below `k0|k0` | Actual parameters / source meaning | Native citation |
|---|---|---|
| `lsu_ic_top_gmem` | 2 read ports, 0 write ports | `AE:2516–2563` |
| `lsu_ic_top_gmem1_2_` | 0 read ports, 1 write port | `AE:2568–2615` |
| Both outer interconnects | AWIDTH34, 32-byte words, BURST_CNT_W4, NUM_DIMM1, HYPER_PIPELINE1, BSP writeack0, waitrequest allowance0, ROOT_ARB_BALANCED_RW0 | Same panels |
| Their `GEN_SIMPLE.lsu_ic` rings | AWIDTH29; same read/write split; ECC disabled | `AE:2717–2820` |
| Read ring `rd_ring` / `lsu_n_fast` | READ1, ENABLE_FAST1, OPEN_RING0, two ports | `AE:2939–2966,3178–3199` |
| Two `bursting_read` LSUs; one `bursting_write` | AWIDTH34, ALIGNMENT_ABITS5, MWIDTH_BYTES32, burst width4; write USE_BYTE_EN1, USE_WRITE_ACK0 | `AE:4771–4799,5261–5287` |

These are the generated **DDRIP kernel/LSU** hierarchy, not physical DDR controllers or established board-bank mappings. `T:7–37,45–53,84–117` exposes an external clock/reset and 34-bit memory hosts with reset conditioning; it does not supply the device-level Reset Release service.

## Diagnostic reconciliation

The full log has **57 diagnostic occurrences: 56 Warning + 1 Critical Warning**. Independent parsing reproduces the ledger exactly, including line numbers and message text. Both native report message sections reproduce that same ordered diagnostic sequence; they are duplicate presentations, not additional warnings. Summing only populated **Count** cells in `SYN:8137–8323` gives the same totals; indented detail rows must not be counted again.

| ID | Occurrences | Log references |
|---|---:|---|
| 13469 | 28 | `L:48–75` |
| 16788 | 13 | `L:76,79–90` |
| 21610 | 13 | `L:94–106` |
| 17498 | 1 | `L:38` |
| Critical 20759 | 1 | `L:39` |
| 21620 | 1 | `L:112` |

**Unresolved accounting discrepancy:** the generic final banner still says **1 warning** (`L:115`; `SYN:8442`), not 57 occurrences. The captured text establishes the full occurrence/panel agreement but not the tool's internal summary-count semantics. Do not explain away the difference as proven suppression or silently replace either total. DRC is separately **1 high-severity violation, 0 waived** (`DRC:45–71`); 20759 and 21620 concern that same reset issue, not two distinct DRC failures.

## Warning disposition

### 1. High: full-FIM reset obligation — unresolved, no waiver

`RES-10204` explicitly finds **zero Reset Release IP, exactly one required** (`DRC:62–71`; `L:39,110–114`). This component-only external-reset project can elaborate despite that failure. Full FIM integration must bind the component to the device configuration/reset-release and clock service and establish the one required device-level instance in the integrated hierarchy. **Do not add a duplicate in the persona blindly.** This is not a DRC pass, reset-function proof, or hardware acceptance.

### 2. Active address/burst arithmetic — source-explained, integration constraints remain

`L:51–55,60–63` identifies nine read/write coalescer truncations. The potentially important address warnings (`S/lsu_burst_coalesced_pipelined_read.sv:183,236–246`; corresponding write file `:202,268–279`) discard the carry of **next-word prediction**, not an existing address MSB. AWIDTH34 minus five byte-offset bits is a 29-bit word address. `W:183–184,531–546` explicitly preserves bits `[33:5]` and restores five zero LSBs; this is a **16 GiB byte-address span**, not 32-bit clipping.

The 5-to-4-bit burst increments (`read:496–507`; `write:569–583`) are bounded by the coalescer's address-boundary detection (`read:389–397,426–430`; `write:450–456,574–579`): four burst bits represent up to eight 32-byte beats at the selected burst boundary. Wrapped next-word prediction at the address-space end also encounters a burst boundary. Source supports expected arithmetic narrowing, **not permission for host buffers/addresses to wrap**. Connected adapters must retain all 34 address bits, correct byte/word units, burst boundaries, and write byteenable masks. Their physical routing and end-to-end behavior are outside this result.

Remaining coalescer truncations are timeout/FIFO-latency countdowns with explicit terminal-minus-one behavior (`read:282,399–405,879–890,1122–1133`; `write:345,459–466,943–954`). No active address-loss or burst-counter-overflow defect is established by these warnings in this configuration; no traffic was executed to validate those invariants.

### 3. Other 13469 occurrences — finite counters or unconsumed scaffolding

- **9 full-detector** occurrences: schedule throttling counters, not the primary occupancy counter (`S/acl_full_detector.sv:172–213`); all three native specializations have SCHEDULEII1, ALWAYS_THROTTLE0 (`AE:5579–5592,5888–5901,6180–6193`). **3 loop-admit** occurrences: II1 and noninterleaved; explicitly wrapped table pointers (`AE:4583–4595`; `S/acl_loop_admit.sv:399–414,667–675`).
- **1 acl_sync** occurrence: bounded negative-to-zero slow-read counter, EMPTY_PLUS_STALL_LATENCY7 (`AE:4274–4279`; `S/acl_sync.sv:664–690`). **2 ring** occurrences: two-bit fairness counters have separate “maximum elapsed” flags before wrap (`S/lsu_token_ring.sv:1633–1638,1656–1661`). These are source-supported finite-width operations, not proof of all runtime bounds.
- **2 pending-write** occurrences remain on an **active** completion path. Native COUNT_WIDTH11 gives a 13-bit seeded counter (`AE:6098–6105`; `S/acl_has_pending_write.sv:73–93`). Do not classify this as disabled because USE_WRITE_ACK0. The corrected acceptance-qualified external acknowledgment is present (`W:549–576`); matching request/ack balance, reset behavior, no overflow and downstream visibility remain functional/integration obligations, not newly proven by elaboration.
- **2 lsu_n_fast** occurrences: the alarming 322-to-34-bit assignment is to `ext_req`, which has **no reader** in this source (`S/lsu_n_fast.sv:78–82,126,177`); active requests use the separate request path. The other is the signed-underflow-style request quota countdown with an MSB-based token-release condition (`:235–248,348`; `AE:3178–3199`). Neither is evidence that the active 34-bit memory address was reduced to 34 bits from a 322-bit address.

### 4. 16788 and 21610 — distinguish pruned directions from real outputs

- `L:76`: undriven `early_avm_write` belongs to the READ1 fast read ring. Its driver exists only in the disabled slow branch; the parent read-ring instance does not connect its write output (`S/lsu_n_token.sv:165–178,181–231`; `S/lsu_token_ring.sv:1751–1771`). Source-justified unconsumed output.
- `L:79–80`: return-data FIFO nets are from the multi-bank path. Native NUM_DIMM1 uses direct input data/valid, and the instantiated read-return block leaves `o_rd_bank` unconnected (`S/lsu_rd_back.sv:775–780,889,1206–1212,1320–1326,1388–1395`; `S/lsu_token_ring.sv:2889–2902`; `AE:3006–3030`). Not an undriven active read-data path.
- `L:81–84`: zero-width write-ID placeholder in the read-only ring; read backpressure placeholder in the write-only ring; two uninstantiated write-ack-router ECC status occurrences. The selected direction guards and low-latency acknowledgment branch explain them (`S/lsu_token_ring.sv:136–148,1205,1737–1771,1872–1887,2136–2146,2511–2524,2905–2909`). ECC is disabled and the parent does not connect the ECC output (`AE:2763,2817`; `M:223–243,294–316`). This does **not** qualify an ECC-enabled configuration.
- `L:85–90,95–98`: six top-level unused opposite-direction nets and four ring outputs match the verified read-only/write-only split. `M:227–242,298–315` omits read-path write responses and write-path read responses; the selected LSU implementations consume only their active direction (`S/lsu_top.sv:1190–1208,1282–1304`). In particular, disabled **BSP** writeack inputs are not the active corrected **external** write acknowledgment wired at `M:304–305`.
- `L:99–100`: CSR `avm_enable`/`avm_burstcount` are undeclared-functionality legacy outputs: `S/cra_ring_node.sv:46–48`; burstcount has no core consumer (`M:75,352`), and `K/DDRIP_function_cra_agent.sv:28` declares enable but never reads it; accesses use read/write (`:287,458,608–613`). Not an inactive CSR datapath.
- `L:101–104`: four zero-payload control FIFOs, WIDTH0 (including B0 via **All Instances**), with payload RAM generated only when WIDTH>0 (`AE:4673–4698,4703–4722,5433–5452`; `S/acl_mid_speed_fifo.sv:133,385`). Their `data_out[-1..0]` placeholders are not lost kernel data.
- `L:105–106`: `acl_fast_pipeline` ENABLED0/NON_SPECULATIVE; the used pipeline signals are driven while the warned legacy stall/valid outputs are disconnected in the generated parent (`AE:6297–6305`; `S/acl_fast_pipeline.sv:53–70`; `K/DDRIP_i_sfc_logic_s_c0_in_for_body_i_ddr0000ter1591_ddrip_90_0gr.sv:780–800`).
- **Observable integration limitation:** `L:94` ties the exported 64-bit **device_exception_bus** to ground. `M:30` declares it without any driver, and `T:9,53` exports it. Do not use an all-zero exception bus as evidence of error detection or successful computation; the component supplies no meaningful exception reporting here. Whether the enclosing integration expects such reporting remains unresolved.

### 5. 17498 — expected language interpretation

`S/lsu_rd_back.sv:406–416,693` calculates a generate-local FIFO threshold and consumes it locally. Treating it as a localparam is source-consistent; no required override was found. This is not a failed elaboration or an independently verified FIFO-capacity guarantee.

## Final disposition and remaining work

**Accept this exact snapshot as successful standalone source analysis/elaboration with reviewed warnings and preserved runner failure.** No new active missing-driver/address-clipping defect was established in the reviewed configuration. Source explanations are configuration-specific, not vendor-origin waivers.

Retain open: (1) the full-device Reset Release requirement; (2) the 1-versus-57 native-summary accounting discrepancy; (3) full-width address/burst/byteenable routing and reset/backpressure/ack balance through the integrated FIM; (4) the constant-zero exception interface contract; and (5) all excluded synthesis/fit/timing/functional/numerical/hardware claims. Resolve these through the parent's existing donor/integration workflow, without reopening skipped DDR simulation or inventing another launch gate.

Review activity was local file inspection, hashing, parsing and static arithmetic only. No SSH, vendor/simulator/hardware execution, source edits, git operations, task transitions, or modifications to the parent's evidence occurred. Only this report was written.

## Report integrity

Review-body SHA256: `2c603ef57183ea76f5884fe7af7fd518f46b2bb36615be10e4a7a562deeefde1`. This hashes the exact UTF-8 bytes preceding the `## Report integrity` heading (including the preceding blank line); the footer is excluded to avoid self-reference. The finalized full-file SHA256 is returned with the review handoff.
