# Writer-local write-response retirement — native results

**Final candidate native unit pass; independent review pending. This is not full DMA, downstream visibility or hardware acceptance.**

## Source and behavior

The final [response-retirement02 patch](../../afu/ahls_memory/dma/patches/write_response_retirement02.patch) applies after the separately preserved AW and elastic-W patches. Baseline SHA256 `c6c4e1c4f9a8678d7a9dc64d22bfe1de663daeffdc12998dfe04ac930e9dcf8c`; final SHA256 `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b`. It is **not** directly applicable to the pristine donor. Pin `e0e07f7b1878a477dc4d1191918db8430193e148`, [original/dependency binding](source-binding01.json), [final differential binding](source-binding02.json).

- Count accepted AW and credited B independently, including simultaneous handshakes. A B receives credit only for ID zero, an accepted AW and an already/same-edge accepted WLAST. Early, extra or wrong-ID replies do not discharge outstanding transactions. Non-OKAY replies with valid credit still retire their bus transaction but latch failure.
- Successful done requires all expected AW/WLAST/B counts equal and no buffered W beat, no sticky failure and no current invalid/error response. The counter test occurs in the final wait state. A reply seen on the completion edge cannot be ignored in favor of success.
- Error capture is active throughout the descriptor, not only in final wait. Every non-OKAY reply (SLVERR,DECERR,EXOKAY) is a failure for these nonexclusive requests. After an error the writer finishes the **current descriptor's** address/data/reply sequence; it does not abruptly abandon accepted traffic. It then stays in ERROR and withholds done/descriptor retirement. This deliberately does not implement abort-on-first-error.
- Busy remains high while a descriptor is active or held in ERROR. Error status is sticky/clocked. The unqualified `reset_dispatcher` bit cannot restart ERROR; only module reset clears this state, and **that is not permission or proof of safe system reset/recovery**. A fault without a matching reply can remain busy/waiting indefinitely. No automatic timeout/reset/retry is added.
- Completion no longer depends on retained FIFO-head packet-complete data. The legacy chained idle num_wlasts assignment is corrected to explicit zero. The packet head remains only in unused debug-close logic. AW/W payload scheduling and source-width/length geometry are unchanged from the previous candidate.

Source tracing into the existing reader shows descriptor FIFO acknowledgment is tied to wr_fsm_done in its final-wait state (`qualification/dma-read-handshake01/inputs-candidate/dma_read_engine.sv:201–203`); the acquired dma_engine wrapper connects the same pulse and actual BRAM FIFO (`qualification/ahls-memory-fabric01/dma-extra-source01/ip/dma/dma_engine.sv:47–99`). Those sources establish the intended integration boundary, not an exercised combined-engine result. Failed descriptors deliberately remain owned; current wrapper/software error, cancellation and global-drain semantics still need integration.

## Preserved attempts

|Attempt|Input|Observed native test|
|---|---|---|
|red01|AW/W-corrected baseline, case0|Fatal cycle541: premature done before response retirement|
|red02|Same baseline, case4|Fatal cycle266: response error was not latched|
|green01|First response candidate|Fatal cycle606/6116ns: spurious response error|
|green02|Final status-only correction|16cases PASS,11059cycles,75576checks,42AW,7500checked Wbeats,44physical B handshakes|

All16 native version/vlib/vlog/vsim commands returned0. The functional outer receipts are **1/1/1/0**. Native rc0 is not relabeled as functional success. All logs, failed source/payloads and outer receipts remain unchanged. [First-candidate failure explanation](GREEN01-FAILURE.md): raw credit validity changes after the accepting edge updates the B counter; exposing that raw expression as status caused the assertion. No waveform was captured. Green02 changes only error-status reporting to the sticky clocked flag; the instantaneous completion check remains. [Parent verification](parent-verification01.json).

Fresh owned tmux windows197–200 ran `/opt/altera/25.1/questa_fe/linux_x86_64` Questa Intel FPGA Edition2024.3 in exclusive `work_dma_write_response01/{red01,red02,green01,green02}` directories. Four commands each,120s/command deadline,2CPU affinity,16GiB per-process limit and existing free-memory/disk/native-ownership checks. No timeout, surviving owned native group or tool/input/original drift. Ten inputs each; only writer RTL differs, with the same complete testbench, dependencies and compiler options. Baseline selects cases0/4; final runs all16. Successful final runner ended `2026-09-23T09:30:51.378228+00:00`.

Final simulation reports **0errors/4warnings**: two relaxed descriptor/csr_control port-kind13314 and two time-zero unique-case8315. Each failed run reports1error/4warnings. Warnings are retained, not suppressed or broadly waived. Full logs, argv and hashes are embedded in `result-*.json`.

## Finite test matrix

[Actual complete-writer testbench](../../afu/ahls_memory/dma/tests/write_response_tb.sv); [parsed case ledger](cases02.json). Done/error/held classifications below are test observations, not a claim all transfers succeeded.

|ID|Beats|AW|Credited B|Done/error/held|Scenario|
|---:|---:|---:|---:|---|---|
|0|513|3|3|1/0/0|Delay all B replies until64completed-data observation cycles|
|1|1|1|1|1/0/0|One-beat successor without reset|
|2|1025|5|5|1/0/0|Overlap prior B and next AW; no reset|
|3|257|2|2|1/0/0|Delay final B64cycles; no reset|
|4|769|4|4|0/1/0|SLVERR on first burst while later data remains|
|5|513|3|3|0/1/0|DECERR on final burst|
|6|769|4|4|0/1/0|EXOKAY on middle burst is not nonexclusive success|
|7|257|2|2|0/1/0|Wrong BID followed by credited ID-zero reply|
|8|513|3|3|0/1/0|Premature B before accepted WLAST, then normal replies|
|9|512|2|2|0/1/0|Duplicate B before next WLAST, then normal replies|
|10|1024|4|4|1/0/0|Periodic response scheduling|
|11|256|1|1|1/0/0|Full-burst successor without reset|
|12|63|1|1|1/0/0|Short successor without reset|
|13|2|1|1|0/1/0|Single-burst SLVERR|
|14|1025|5|5|0/1/0|Delayed final DECERR|
|15|1|1|0|0/0/1|No B;128completed-data observations without false terminal result|

Seven cases retire successfully with exactly one done pulse. Eight deliberately injected-error cases drain their expected descriptor replies, latch error, hold busy and reject restart via reset_dispatcher while new input is offered. One missing-response case remains busy without false done/error/stop through128observations after its final data acceptance; simulation ends with that synthetic transaction **still outstanding**. This is a hold test, not a missing-response recovery or a drained-state pass.

The44physical replies comprise41credited replies and3injected uncredited replies;42AW includes the one missing reply. Five AW/B same-edge events and five descriptor successors without reset were observed. All accepted AW addresses/lengths/size/ID/burst, W data/strobes/last, stalled packed AW/W payloads and FIFO-pop accounting are actively checked. The FIFO output is set to zero whenever empty, so success cannot depend on retaining its end tag. Current-descriptor writes intentionally continue after an early response fault until the accounted transaction set drains; no later descriptor is started.

## Boundaries still open

This is the complete writer with actual donor package/FIFO interface and PIM AXI types/checker, but **synthetic platform configuration, FWFT input and B sink**. The real BRAM FIFO/reader/descriptor queue, selector/register slices, one-primary-mapper PIM top, actual IOVA/ID/user widths and physical banks were not instantiated. Only HOST_TO_DDR/INCR is exercised. No high-IOVA bits34–56, host WRAP,4KiB conversion, invalid/overflowing descriptor length, malformed data tags, or9-bit maximum-count proof. Selected transfers reach1025beats; this is not full20-bit-length qualification.

Good-ID replies must actually correspond to their in-order writes; aggregate counters cannot identify a malicious duplicate substituted for a missing same-ID response once another valid credit exists. Injection tests only cover the explicitly enumerated uncredited faults. No system-wide stop/cancel/reset/drain contract is supplied. Fixture resets between independent error cases occur in simulation and do not qualify a live reset; successful no-reset sequences do not prove arbitrary multiclient/queued-descriptor concurrency.

A counted successful B at this writer boundary is **not** proof of DDR physical visibility, host cache/PCIe posted-write completion, full pipeline quiescence or application numerical correctness. Retain buffer ownership/fence and downstream response-origin obligations. No FPGA/device access, programming, driver changes or reboot. DDR vendor simulation **SKIPPED BY USER**. Prior AW/W/fabric independent handoffs remain separate; this stage does not retroactively accept them or authorize deployment. No unchanged native rerun is pending.
