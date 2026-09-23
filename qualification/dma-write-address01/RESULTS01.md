# DMA writer address correction — native results

**NATIVE AW-CHANNEL UNIT PASS; independent acceptance pending. Not a qualified DMA writer or complete DMA.**

## Exact source scope

The additive [patch](../../afu/ahls_memory/dma/patches/write_address_handshake.patch) against AI Suite commit `e0e07f7b1878a477dc4d1191918db8430193e148` removes AWREADY from initial admission, asserts AWVALID independently in SEND_WR_REQ, loads AW payload only on entry, and chooses full-versus-tail AWLEN from the completed-burst count. Existing write-data/FIFO logic,9-bit counters, status, error handling and completion logic are **unchanged**. Exact baseline/candidate/dependency identities: [source binding](source-binding01.json). The original vendor file is preserved; no installed vendor tree, accepted FIM, fabric or reader correction was edited.

The source-visible hazards were independently identified in [DMA donor review §4](../ahls-memory-fabric01/DMA-DONOR-REVIEW01.md); the following are new executed native results, not another static prediction.

## Executed original-fail / candidate-pass

Each isolated attempt uses installed Questa Intel FPGA Edition2024.3 from `/opt/altera/25.1/questa_fe`, the same10 source members except dma_write_engine.sv, actual PIM interface/checker/types, and identical source testbench. Fresh directories under `/home/uwb_student00/ahls/new_BSP/work_dma_write_address01/`, owned tmux,80GB available-memory precheck,2CPUs,16GiB per-process address-space bound,120s per native command. No competing native process was found by each preflight. These limits are not a hardware-access sandbox.

| Attempt | Original/candidate and scenario | Actual result |
|---|---|---|
| red01 | Original, `+ONLY=0`: ready waits for valid | Fatal at cycle25: source waited for AWREADY before AWVALID |
| red02 | Original, `+ONLY=1`: ready falls after valid | Fatal at cycle1: AWVALID followed ready low |
| red03 | Original, `+ONLY=2`: always-ready513-beat transfer | Fatal at cycle261: middle burst expected256beats, actual1 |
| green01 | Corrected, all12cases including the same three |12cases,5,709cycles,33,284checks,30AW requests,5,448accepted W beats,87stalled-address cycles |

All four native commands (`vsim -version`,vlib,vlog,vsim) returned0 in every attempt. Fatal/error-aware outer verdicts are **1/1/1/0**, captured in unique tmux buffers. Native-zero/fatal original runs are not mislabeled native-nonzero. All owned native groups drained, no timeouts. Result JSON contains full logs, exact argv, times/process identities, original/input/tool preservation and per-log sizes/SHA256. [Parent verification](parent-verification01.json), [red01](result-red01.json), [red02](result-red02.json), [red03](result-red03.json), [green01](result-green01.json).

Candidate native summary:0errors/4warnings. These are two relaxed input-port-kind13314 warnings and two unique-case8315 warnings at time0 before synchronous reset. They are retained, not suppressed or globally waived.

## Coverage and limitations

[SystemVerilog test](../../afu/ahls_memory/dma/tests/write_address_tb.sv) compiles the entire donor writer and uses an explicit synthetic first-word-fall-through FIFO. **WREADY is always high.** It checks each AW address/length/size/type, entire AW payload stability through stalls, independent valid issuance, every W payload/strobe/WLAST, FIFO pop accounting and absence of duplicate/unaddressed data. Lengths span1,2,63,256,257,512,513,769,1024,1025beats with ready-dependent, falling-ready, always-ready and periodic-stall address sinks, and varied aligned offsets in the upper half of a16GiB bank-local range. Every case resets the DUT. No claim about reset-in-flight, concurrent descriptor ownership, data-channel backpressure, invalid lengths or9-bit burst-counter overflow.

**Completion defect explicitly reproduced and retained:** the test returns no B responses; `wr_fsm_done` nevertheless asserts in **all12 candidate cases**. The unit verdict is based on accepted AW/W data, never on this done flag. The result does not establish response-drained completion or host/DDR visibility. This evidence strengthens the requirement to fix retirement before integration/hardware use; it is not a waiver.

Unit-only platform packages specify2banks/34local address bits/512data/57source-address bits. They are not a generated active PIM binding, and neither fix nor exercise dma_top's source-IOVA truncation. The sink intentionally accepts large INCR bursts; no4KiB, host WRAP, PIM burst splitting, physical bank, AHLS, OPAE or memory-array correctness claim. No DDR vendor model: SKIPPED BY USER.

Next source work is the unchanged W-channel backpressure path and truthful B-response/error/drain retirement, followed by source-bound DMA/PIM integration. Reuse these completed results; no unchanged rerun is pending. Independent result review governs publication, not a new source-execution permission barrier.
