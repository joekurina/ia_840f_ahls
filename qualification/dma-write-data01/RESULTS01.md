# DMA writer data channel — native results

**NATIVE W-CHANNEL UNIT PASS; independent review pending. Not complete DMA/writer or completion acceptance.**

## Exact source delta

The [additive patch](../../afu/ahls_memory/dma/patches/write_data_elastic.patch) applies **after** the AW correction, to baseline SHA256 `ec1483378ff7e3ce448bd92ff16ebc175831ac640dbae01dcb79b8924228e5f2`. It is not a patch against the pristine donor. Baseline and candidate remain separate local files. Candidate SHA256 `c6c4e1c4f9a8678d7a9dc64d22bfe1de663daeffdc12998dfe04ac930e9dcf8c`; original donor pin `e0e07f7b1878a477dc4d1191918db8430193e148`. [Source/dependency binding](source-binding01.json).

The changed W path uses the existing output register as a one-entry elastic buffer: present valid independently of ready, hold the entire packed W payload while stalled, and pop the FWFT input only into an empty or simultaneously consumed slot. A buffered WLAST prevents prefetch into the next burst; the FSM enters the next address phase or final wait only on **accepted** WLAST, regardless of input-FIFO emptiness. Data phases no longer visit the separate NOT_READY/FIFO_EMPTY_NOT_READY states; enum values and the status-port layout remain. FIFO_EMPTY still bridges an accepted address into the data phase.

AW logic, burst-count widths, B-response/retirement, CSR/status logic and error handling are unchanged from the baseline. The packet-complete head flag is still used by the unqualified final-wait/idle logic. Valid lengths, stable descriptor, correctly tagged FWFT data and one descriptor at a time remain assumptions. Original donor, prior AW candidate/evidence, accepted reader/FIM/HLS and connected fabric are unchanged.

## Actual native execution

Fresh exclusive remote directories under `/home/uwb_student00/ahls/new_BSP/work_dma_write_data01/`, owned tmux. Same native Questa Intel FPGA Edition2024.3 in `/opt/altera/25.1/questa_fe`; explicit environment, source/tool hashes,120s/native-command deadline,2CPU affinity,16GiB per-process address-space limit and existing available-memory/disk/noncompeting-native preflight. No hardware-backed device access.

| Attempt | Input/scenario | Observed result |
|---|---|---|
| red01 | AW-corrected baseline, `+ONLY=0`, sink waits for WVALID | Fatal cycle81: source waited for WREADY before WVALID |
| red02 | Same baseline, `+ONLY=2`, stalled WLAST plus FIFO gap | Fatal cycle284: extra/unaddressed data; next burst address was missed |
| green01 | W-corrected candidate, all12cases including0/2 |12cases,10060cycles,53382checks,30AWrequests,5448checked Wbeats,97AW-stall cycles,2832W-stall cycles and2592input-gap cycles |

All native version/vlib/vlog/vsim commands returned0 in every attempt; fatal-aware **outer codes1/1/0** are independently retained in tmux-buffer receipts. Native-zero/fatal baseline results remain unchanged. Both baseline runs fail functionally rather than during compilation. No timeout/residual owned native group. Ten inputs per attempt; the sole source variant is dma_write_engine.sv. Baseline simulations select cases0/2; candidate runs the identical source test's complete case set. Same tools/compiler options and bound dependencies. [Parent verification](parent-verification01.json), [red01](result-red01.json), [red02](result-red02.json), [green01](result-green01.json).

Candidate0errors/4warnings: two relaxed input-port-kind13314 and two unique-case8315 at time0. Red01 has1error/4warnings; red02 has1error/12warnings, including post-reset incomplete/overlapping unique-case diagnostics in the baseline's AW-register and status blocks at2705–2765ns. Preserve these additional warnings; they are **not all initialization warnings** and have not been globally waived. No warning suppression or vendor-library edits.

## Test coverage and limits

[Whole-module SystemVerilog test](../../afu/ahls_memory/dma/tests/write_data_tb.sv) compiles the actual donor writer with actual DMA package/FIFO interface and PIM AXI interface/checker/types/logging. Unit platform configuration remains synthetic2banks/34local address/512data/57source-address bits; no active PIM width binding or high-IOVA qualification. The stimulus is a synthetic FWFT input, not the real vendor FIFO implementation. Its contents retain the final head on empty, a disclosed precondition of the unmodified completion path.

Every accepted AW address/length/size/type, entire stalled AW/W payload, W data/strobe/last and FIFO-pop count is checked. Input pops minus accepted output beats must stay between0 and1. The address oracle and expected data use descriptor position, not the candidate's address alone. AW stalls run concurrently with ready-dependent, boundary-stalled and periodic W sinks. Case2 deliberately empties input after a burst's final pop while WLAST remains stalled; subsequent W data cannot be accepted without the next AW. Selected lengths1/2/63/256/257/512/513/769/1024/1025beats cover short/full/multiple/tail transfers. These are selected pairs, not a complete Cartesian cross-product or performance benchmark.

Every case resets. No malformed FIFO tags, invalid/overflowing lengths, in-flight reset, back-to-back descriptors without reset, out-of-order IDs, error responses, host WRAP, physical memory,4KiB/PIM burst adaptation, host buffer lifetime or hardware qualification. The sink deliberately accepts large INCR requests.

**Completion is still wrong:** no B responses are returned; wr_fsm_done asserts in all12candidate cases. Unit pass is based on accepted address/data and the full scoreboard, not this done flag. Truthful B-response/error/drain and the final-wait/descriptor/CSR contract are the next required work. Retaining this failure avoids presenting an AW/W-only success as a working DMA. DDR vendor simulation remains **SKIPPED BY USER**.

This result uses the prior AW-corrected candidate without broadening its pending independent acceptance. The AW and connected-fabric gates remain separate; no new execution-approval framework is required. No unchanged native rerun is pending.
