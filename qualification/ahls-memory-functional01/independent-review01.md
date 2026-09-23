# Independent review — connected AHLS numerical simulation

**Status: FINAL**  
**Specification: PASS for the stated connected, synthetic-endpoint numerical simulation.**  
**Quality: PASS_WITH_NONBLOCKING_FINDINGS within that scope.**  
**Bounded verdict: ACCEPT_CONNECTED_NUMERICAL_SIMULATION_AND_SCOPED_CORRECTIONS.**

No blocker was found to accepting path08's numerical result or the exact constant-reset-index and page-boundary corrections. The native evidence supports four successful connected invocations, not hardware equivalence, a deployable accelerator, exhaustive AXI compliance, or a software-visible drain/fence. Minor coverage/evidence findings and retained integration obligations are below. No unchanged native rerun or new execution framework is requested.

This FINAL replaces the early IN_PROGRESS report. Review used local reads, hashes, AST/literal/base64 decoding, exact comparisons and independent arithmetic only. No SSH, runner import/execution, vendor/simulator/native execution, hardware access, implementation edits, git operations, publication or task transitions occurred. Only this report was intentionally created/modified.

## 1. Specification compliance — reviewed first

Paths below are relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`. **K** = `qualification/ahls-memory-functional01`; **R** = `K/inputs-path08`; **H** = `R/generated/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth`; **P** = `R/rtl/platform/ofs_plat_if/rtl`. **TB** = `afu/ahls_memory/core/tests/ahls_memory_path04_tb.sv`; **MODEL** = `afu/ahls_memory/core/tests/axi_memory_model.sv`; **BANK** = `afu/ahls_memory/pim/ia840f_ahls_memory_bank_shim03.sv`.

| Scope requirement | Independent assessment |
|---|---|
| Actual generated DDRIP and connected transport | **Pass.** TB:25–35 instantiates both real bank-shim chains and `ia840f_ahls_memory_core`. The latter instantiates the generated PD fabric and real DMA top. Its core/DMA/CSR/selector/mux bodies match the accepted component input copies. The generated HLS, arbitration, adapters, descriptor/data FIFOs, PIM register slices, user/ID queues and CDC are present, not replaced by numerical stubs. |
| Source-defined numerical operation | **Pass.** `afu/ahls_memory/src/mmhost_ia840f.cpp:18–44` specifies two 34-bit, 256-bit-data hosts, x/y on one location, z on the other, and `z[i]=x[i]+y[i]`. Provenance points to hls-samples2026.1.0 commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`; prior generation evidence is reused, not regenerated. TB:272–334 independently computes and compares every requested integer and every copied byte. |
| Real control/data path, not injected completion | **Pass.** TB:213–270 drives aligned full-width 64-bit MMIO, separated AW/W arrivals, retained requests, response IDs/codes and finite timeouts. TB:281–303 initializes only host-model inputs/sentinels, then programs actual DMA descriptors, kernel pointers/size and start. There is no forced descriptor, completion substitution or golden result written into bank/result memory. |
| Completion sequencing and numerical copyback | **Pass within the explicit fixture contract.** Non-destructive status is polled; finish is read/cleared only with no invocation outstanding and checked against a zero baseline then fresh count1. Copyback follows observation of exactly n×4 accepted kernel-store bytes and synthetic bank1 write/B inactivity. This last condition is deliberately not a host-visible fence; see §4. |
| Guards, partial stores and repeated invocations | **Pass.** Four no-reset cases n=1,8,17,65 exercise partial-vector stores, all copied result/guard/padding bytes, two input copies plus initialization/copyback per case, and the 4-bit descriptor-count wrap over16 descriptors. Count progression is modulo16 with idle, descriptor-FIFO-empty and error checks, not monotonic-count inference. |
| Backpressure, response delay and bank clocks | **Pass for deterministic fixtures.** Core/bank periods are10/14/22ns. MODEL:55–57,85,120–127 supplies deterministic channel stalls and delayed retained B responses; TB:342 requires observed write stalls on both banks. This is not randomized/exhaustive timing, metastability analysis or FPGA performance evidence. |
| Preserve failures and correct narrowly | **Pass.** Eight retained attempts, exact inter-run source deltas, native/outer statuses and full logs agree. The only removed fixture expectation is invalid upstream AXI-Lite RLAST; the page assertion, crossing addresses, numerical oracle and guards are unchanged. |
| Scope honesty and safety | **Pass.** SCOPE/RESULTS explicitly exclude primary PCIe mapping, OPAE, physical DDR, reset-under-traffic, PR and hardware access. The host endpoint is an explicitly synthetic linear line-request model, not generic AXI WRAP. Vendor DDR simulation remains **SKIPPED BY USER**. |

The C++ harness was read, not run; its SYCL `main` is not the deployed OPAE host. This review does not duplicate or consume the separate real-PIM predecessor review. The accepted core structural milestone remains distinct from this functional milestone and from the exact-candidate Quartus/build work still outstanding.

## 2. Evidence integrity and actual native result

Independently verified the frozen **54/54** package entries, lengths and SHA256s against:

`K/review-package01.json` — **`c40ecd6f130dde7798a868e6b05b57aec6b45497cca0302896cf9d4cf09efa01`**.

Additional checks, rather than reliance on `parent-verification01.json` alone:

- Parsed all eight payload-bearing runners as AST; decoded only literal `C` dictionaries and base64 source bodies. **4219/4219 source payloads** match their embedded hashes and native-result input inventories. No runner was imported or executed.
- Checked all dispatch full-script hashes, all outer result-file hashes and all five embedded log lengths/hashes per run. Rebuilt diagnostic-error inventories from the logs and compared exact rows. Recorded original/input/tool preservation is true throughout; recorded owned groups are empty at completion, with no timeout or residual-group failure.
- All **527 initial** and **528 final** local source copies equal decoded payload bytes. Both source bindings agree with source lengths/hashes, original inventory, compile order and flags; the final binding also agrees with all19 tool/library metadata entries. All449 final compilation entries are unique and bound. The final test, model and bank-wrapper each occur once.
- Replacing each literal `C` assignment by the template placeholder reproduces `run-native.py.in` for path01 and `run-native02.py.in` for paths02–08 exactly. The sole runner-body change is vdir's library target and addition of `-L altera_lnsim_ver`. No hidden diagnostic suppression or changing scoreboard acceptance logic was found.
- `library02.json` binds the same modelsim.ini and six additional installed Verilog altera_lnsim files; those entries exactly match the added tool bindings. Native vdir lists `altera_syncram`. Library bodies are not published locally: this establishes internally consistent captured identity/preservation, **not** a fresh independent read of installed remote binaries.
- Final corrected `lsu_ic_top.sv` still has predecessor write-ack SHA256 `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd`; the new reset edits do not replace or undo it.

### Native outcome

Path08: owned receipt **@233 %233**, root `/home/uwb_student00/ahls/new_BSP/work_ahls_memory_functional01/path08`. The version log says **Questa Intel FPGA Edition-64 vsim2024.3, Simulator2024.09 Sep10 2024** under `/opt/altera/25.1/questa_fe`. Version, vlib, vdir, vlog and vsim each have native/effective rc0; outer rc0. Native vsim ran12:20:59.191641–12:21:05.051126Z on2026-09-23. CPU affinity[0,1], address-space limit17179869184 bytes, core dumps disabled and120-second per-command deadline are source/receipt bound. This is recorded execution/preservation, not a new live process or workstation audit.

Exact native marker:

```
AHLS_PATH_UNIT_PASS cases=4 elements=91 copied_bytes=1088 dma=16 checks=2729 mmio_reads=292 mmio_writes=84 bank0_W=18 bank1_W=31
```

Native finish: **43310ns**, simulation **Errors0 / Warnings255**; vlog **Errors0 / Warnings43**. There are no Error/Fatal rows in path08. The compiler warning count is separate from the simulation/elaboration count; neither is waived.

| Case | n | Input-copy beats each | Copyback bytes | Kernel result bytes | Guard/padding bytes | Independent golden range |
|---|---:|---:|---:|---:|---:|---|
|0|1|1|192|4|188|54|
|1|8|1|192|32|160|52–80|
|2|17|2|256|68|188|50–114|
|3|65|5|448|260|188|48–304|
|Total|91|—|1088|364|724|—|

Native per-case rows equal `cases08.json` and the independently recomputed extents. TB's x/y formulas give `54+4*i-2*c`; all91 sums and inputs are safely signed32-bit. Negative inputs occur, but all tested **results are positive**. There are91 integer comparisons plus1088 byte comparisons;364 result bytes are intentionally checked again bytewise, not1088 additional distinct arithmetic outputs. The2729 total also includes MMIO/status/drain checks and is not a count of independent protocol scenarios.

### Retained attempts and exact deltas

| Attempt | vsim / outer | Disposition and independently checked change |
|---|---|---|
|01|12 /12|All448 HDL entries compile;17 missing `altera_syncram` errors prevent functional loading. The18 diagnostic rows include the error summary. |
|02|12 /12|Exactly the same527 source inputs; only library binding/search changes. Strict7061 array-ownership errors and2064 backend errors prevent time-stepping. |
|03|0 /1|Only the two LSU files change via three reset-loop expansions. Real simulation reaches the first MMIO read and fails RID/RLAST at4085ns. |
|04|0 /1|Only the failing assertion's diagnostic text changes. It proves RID0x52 correct and RLAST0 at address0x48. |
|05|0 /1|Only the invalid RLAST expectation is removed. Two bank0 input copies complete; bank1 initialization crosses4KiB at0x3fc0 and fails at7645ns. |
|06|12 /12|Only new bank-wrapper source and fixture instantiation name. Copied LEN8 violates the mapper's page-size/max-burst requirement; reversed[5:8] select. |
|07|12 /12|Only the new wrapper changes to internal LEN5. Strict `to_source_clk`→`to_source` modport forwarding is rejected. |
|08|0 /0|Only the wrapper's internal full interface and existing clock-driving connector pattern change. Four numerical/guard cases pass. |

The three rc0/fatal attempts remain failed. A simulator exit0 does not override either a fatal diagnostic or missing final scoreboard.

## 3. RTL correction assessment

### 3.1 Constant reset indices — accepted for these exact generated bytes

`H/lsu_burst_coalesced_pipelined_read.sv:281,305–334` fixes COALESCER_PIPE_DEPTH at5. Generate-selected stage1 processes own `kword_address_cpipe[1]`; the common pipeline resets/writes stages2..5. No second owner of stage1 is introduced by expanding the reset loop.

`H/lsu_burst_coalesced_pipelined_write.sv:1030,1239–1334` fixes VALID_GEN_THREAD_COUNT_PIPE_DEPTH at4. The mutually exclusive write-ack/ignore-write-ack branches own stages1..3; the common process owns stage4. Both branch reset loops are expanded, even though this generated kernel uses USE_WRITE_ACK0.

I independently replaced exactly those three loops in memory and obtained byte-identical path03/path08 candidates. The independently generated unified diff equals `afu/ahls_memory/patches/constant_reset_indices.patch`. Candidate copies, source-delta03 before/after hashes and runner payloads all agree. All event controls, reset predicates, nonblocking zero values, fixed localparams and non-reset logic remain unchanged; always_ff is retained. This is a small source-equivalent reset expansion, not a multiple-driver waiver or general license to hard-code changed future pipeline depths. Dynamic coverage of both mutually exclusive parameter branches and post-synthesis equivalence are **not** claimed.

### 3.2 AXI-Lite assertion correction — accepted, not DUT weakening

TB:237–255 continues checking accepted RID, RRESP and request/response deadlines. `afu/ahls_memory/pim/ofs_plat_afu.sv` declares the actual upstream `ofs_plat_axi_mem_lite_if` and routes flattened core RLAST to `mmio_single_rlast`, not an upstream RLAST field. The generated composition's MMIO/CSR bridge instances explicitly set USE_M0_RLAST0 (composition lines599 and857); bank bridges retain it1. Removing the full-AXI RLAST expectation at this AXI-Lite boundary is therefore correct. This does not excuse arbitrary MMIO bursts, invalid shapes or upper-aperture aliases.

### 3.3 Page-boundary correction — accepted for the exercised bank path

BANK:15–47 inserts the existing `ofs_plat_axi_mem_if_map_bursts(PAGE_SIZE=4096)` ahead of the unchanged real local-memory shim. It uses the local-memory NO_REPLY enum, not a newly invented flag. It preserves address/data/ID/USER widths and leaves physical LEN8 unchanged. Internal LEN5 permits32 full-width64-byte beats, or2048bytes; page size is64 such lines. This satisfies the gearbox's explicit strict `PAGE_SIZE > SINK_MAX_BURST` contract (`P/utils/prims/ofs_plat_prim_burstcount1_mapping_gearbox.sv:236–267`). The original LEN8 attempt did not.

The source chain was checked:

- `P/base_ifcs/axi/prims/ofs_plat_axi_mem_if_map_bursts.sv:149–220,245–323` splits AR/AW, sets intermediate NO_REPLY, hides intermediate RLAST/B and preserves upstream flags.
- Its `fixup_wlast` instance regenerates last-beat boundaries from split AW lengths. The existing implementation is reused, not rewritten.
- `P/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv:139–187` retains user/expanded-ID metadata before CDC. `.../prims/ofs_plat_axi_mem_if_user_ext.sv:84–130,145–178` queues full source ID/USER on accepted requests and restores them on ordered responses; it does not depend on the physical memory echoing those fields.
- BANK's full `afu_if` plus `ofs_plat_axi_mem_if_connect_sink_clk` follows the native local-memory shim's existing pattern (shim:97–118; connector:29–51). Clock/reset/instance and request/response wiring are explicit; no new handshake algorithm is introduced by path08.

The exact failing address and length remain: bank1 initialization and copyback start at local0x3fc0 and cover3,3,4,7 full64-byte beats. MODEL's INCR4KiB assertion and byte-lane/WLAST/bounds checks are unchanged. The numerical pass therefore demonstrates legal splitting of these real crossing write/read transfers, not avoidance of the failure through address changes. It does **not** test a source burst exceeding the new32-beat internal limit, every alignment/SIZE/BURST form, or HLS stores crossing a page. The PIM mapping primitive operates in memory-line units; arbitrary narrow/WRAP transfer correctness must not be inferred from this test.

Only the final03 authoring wrapper is compiled, under unsuffixed run filename/module name. The unsuffixed and02 authoring variants remain preserved failures; they must not be co-compiled or selected accidentally in a successor build.

## 4. Fixture honesty and precise visibility limit

MODEL is a64KiB byte array per endpoint, initially filled with0xa5. TB directly changes only host-model input/sentinel regions. Bank contents reach their test values through actual DMA traffic, and computed outputs reach host0x4040 through actual bank1→host DMA. The result oracle is not a memory producer. The host's `LINEAR_HOST1` deliberately interprets line requests linearly regardless of burst tag and skips generic bank burst/page rules; bank models use `LINEAR_HOST0`. This distinction is explicit and essential.

TB:296,310–320 snapshots bank1 accepted-byte count after sentinel initialization, waits for exactly n×4 additional bytes, no active write, no queued B and no presented physical-model B, then reads fresh finish count and starts copyback. MODEL updates memory when W is accepted and delays B afterward. This is a legitimate **white-box fixture sequencing condition** ensuring that synthetic memory holds the expected stores before copyback. It is not circular numerical checking: the condition examines count/activity, not expected values.

It is also not global drain. It does not prove every internal queue or returned-B pipeline is empty, that no future request can emerge, or that a software-observable completion implies physical visibility. It deliberately supplies information unavailable to a deployed host. The test cannot authorize buffer release, retry, active reset, PR, or a claim that kernel finish alone orders DMA copyback. The one-in-flight/no-error test and subsequent byte comparisons establish this bounded numerical path, not recovery/ownership semantics.

Other fixture boundaries: serial synthetic endpoint servicing; deterministic rather than adversarial schedules; no injected bad/duplicate/missing responses; low host IOVAs; limited bank offsets; no zero-length/vector-size, signed-overflow or maximum-descriptor execution; one startup reset and no reset between cases; guards cover the copied region, not every byte in the model. IRQ and the constant-zero/undriven generated exception output are not pass criteria.

## 5. Warning and evidence-quality findings

`warnings08.json` exactly matches recomputed warning rows and native counts:

| Stage / ID | Occurrences | Disposition |
|---|---:|---|
|vlog13314|30|Default relaxed input-port-kind diagnostics; retain, not a blanket protocol/driver waiver. |
|vlog2275|7|Generated duplicate module overwrites. All3 pipeline-base copies,4 address-alignment copies and3 burst-uncompressor copies are respectively byte-identical; no differing implementation silently wins. |
|vlog13528|6|Generated `$time()` syntax diagnostics. |
|vopt13314|7|Same port-kind class on actual DMA/CSR interfaces. |
|vopt2685 /2718|52 /184|Paired too-few-port/missing-port diagnostics in generated HLS/LSU hierarchy, including unused outputs and optional/direction-specific ports. Preserved, not declared universally harmless. No removal of an active connection by the two reset edits or bank wrapper was found; the bounded numerical pass does not qualify all optional configurations or exception reporting. |
|vopt13528|6|Same generated time-function diagnostics at optimization. |
|vopt2697|2|Procedural branches in generated AXI slave NI warn on `[19:0]` from16-bit address temporaries. The instantiated PKT_ADDR_H/L are91/72, ADDR_WIDTH16. Both warned less-than branches are constant-false; the selected greater-than branches zero-pad16→20. This is not evidence of exercised-address truncation. See NI:1085–1092,1132–1139 and `...altera_mm_interconnect_1920_7cfzhiy.v` instance parameters. |
|vsim8315|4|Actual reader/writer unique-case diagnostics all occur at time0 before synchronous startup reset has initialized FSMs. None occurs during the four traffic cases; reset-under-traffic remains untested. |

### Nonblocking findings

**R1 — Low, coverage precision.** Mixed-sign operands are exercised, but the independent golden ranges above show no negative or zero result and no signed-boundary behavior. The longest vector is65; page tests cover3–7 full-line DMA beats, not the32-beat split limit or maximum admitted descriptor. Keep published claims at that bound. If a later changed campaign claims broader arithmetic or burst coverage, add the corresponding cases then; no rerun is required to accept this result.

**R2 — Low, historical failure-capture gap.** `library-capture-failure01.json` retains rc1 but explicitly says the exact exception was not retained. The collector's `len(lines)==1` assumption conflicts with the two mapping lines captured by collector02, supporting the stated diagnosis, but it is not a preserved traceback of collector01. Collector02 captures exceptions explicitly and recovered the required identity metadata; native path01–08 logs are fully retained. Preserve this distinction and use the corrected failure-export pattern for future collectors, without rewriting or rerunning the historical attempt.

## 6. Retained obligations and acceptance handoff

These block broader deployment/signoff claims, **not** acceptance of the completed scoped numerical milestone:

1. **Visibility/recovery ABI remains open.** HLS accepted-write tracking, status, fixture B drain and successful copyback do not supply software-visible global drain/fences, pinned-buffer extent/lifetime safety, first-error/admission persistence, or active-operation reset/stop acknowledgment.
2. **Inherited core findings remain.** Capability/state telemetry truncation (core F1/F2), first-error/control/drain gaps (F3), hygiene (F4), upper-MMIO alias/access-shape protection, posted-error visibility, ineffective freeze and constant-zero exception limitations are not repaired or waived here. Source equality supports carrying them forward rather than duplicating the whole earlier audit.
3. **Exact new candidate has no Quartus A&E/mapped/fit/STA acceptance yet.** The accepted/published core structural milestone `bb947533abbeaa4d24562e5b79a13d4d4b016dfa` does not cover the two new reset-index bodies or BANK03. The next ordinary integration must select those exact bytes, preserve failed variants without duplicate module definitions, and qualify the actual candidate through the existing native workflow. Simulation alone does not establish hardware equivalence, CDC/timing signoff or reset-release/full-FIM correctness.
4. **Platform proof remains absent.** No primary PCIe mapper/OPAE/physical DDR/controller/calibration, full16GiB addressing, large/sustained or simultaneous physical-bank qualification, PR, image programming or durable boot is established. Vendor DDR simulation stays **SKIPPED BY USER**. The overall hardware goal remains incomplete.

**Handoff:** accept path08's four connected numerical cases and the exact scoped corrections with R1/R2 and these retained limits. Do not relabel preserved failures as passes, import the bad bank-wrapper variants, or turn this local result review into another launch-approval framework. All54 frozen package entries are to remain unchanged. The final full-file SHA256 of this report is supplied separately after writing, not embedded in its own contents.
