# DMA read-response error correction — native result

**Native finite paired test PASS; independent review pending.** Exact baseline is paired-engine pair02 reader with the descriptor-counter correction. The actual donor wrapper, corrected writer, real PIM BRAM FIFO/scfifo and all other inputs are unchanged. Test is additive: earlier dma_engine_tb.sv and every frozen gate remain untouched. [Source bindings](source-binding01.json); [scope](SCOPE.md).

## Reproduced defect and correction

Baseline red01 (tmux205) completed native version/vlib/vdir/vlog/vsim with all rc0, but failed at cycle909: `accepted bad read response was not latched`. Outer1 correctly rejected it. Two preceding good descriptors completed. Native0 is not functional acceptance. [Preserved result](result-red01.json).

[Additive reader patch](../../afu/ahls_memory/dma/patches/read_response_retirement.patch) latches a non-OKAY response **on accepted RVALID/RREADY**, retains the first response code until module reset, exposes rd_rsp_err/rd_resp_enc, and rejects descriptor dequeue if sticky/current read fault exists. The current valid descriptor still issues/accepts its remaining read/write traffic; entering ERROR waits for writer-local completion. ERROR is absorbing. An idle fault blocks a later start by source logic, but stray/idle reply behavior is not dynamically tested here.

Bad data may be forwarded/written before error is reported: **discard the entire failed descriptor result**. Error does not mean global drain, safe reset, physical visibility or permission to unpin buffers. A write error prevents writer-done, so the reader may remain WAIT with its read error sticky; if both sides failed, writer ERROR still holds ownership. Missing B keeps the reader waiting even after all data beats have transferred.

## Native candidate evidence

Green01 (tmux206), same13source/test inputs except reader: all5native/effective statuses0, outer0. Questa Intel FPGA Edition2024.3 under /opt/altera/25.1, unchanged installed modelsim.ini/precompiled6-file scfifo library from pair02. No DDR model. Same finite120s-command,2CPU/16GiB-process supervisor and resource/concurrency checks. Added only a durable SHA256 receipt buffer to the retargeted runner. No timeout/live owned group, input/original/tool drift or diagnostics error. [Result](result-green01.json), [parent checks](parent-verification01.json).

**16cases /17508monitored cycles /229774checks;40AR,40AW,6800R,6800W,37B.** Four successful descriptor retirements, ten terminal error holds, two missing-B holds. Ten cases inject read faults (one overlaps missing B, one overlaps write SLVERR). [Exact case ledger](cases01.json).

All6800transport beats and accepted request addresses/lengths, FIFO data/flags/occupancy, destination values/strobes/last, packed stalled AR/AW/W payloads and descriptor counts are checked. Successful4cases additionally compare **1796**model-memory copyback beats; failed/held cases are not successful computation. Two good successors run without reset. Read/write stalls6062/9878cycles; real FIFO almost-full observed6463cycles; maximum R-minus-W34beats. The reused test now explicitly requires at least32buffered beats and nonzero almost-full observations, addressing prior paired-review Q1 without changing the frozen prior test.

Faults span first, middle, final and single read beats; SLVERR, DECERR and nonexclusive EXOKAY; successive unequal errors preserve the first code. Sticky status, busy and no dequeue/count increment checked after each error through terminal observations. Read-error-only cases still complete all current data/replies before reader ERROR. Write-only, simultaneous read/write errors, missing B and read-error+missing-B remain distinct. Missing cases13/14 each hold for128completed-data observations, then the fixture resets before another case: that is **not** recovered/drained hardware. Terminal errors are observed for ten cycles, not indefinitely.

Native final0errors/**9warnings**: five relaxedinput-port-kind13314 and four time-zero uniquecase8315. No suppression or warning-clean claim. [Test](../../afu/ahls_memory/dma/tests/dma_read_response_tb.sv).

## Limits

This is direct57-bit engine-interface testing with synthetic linear line-request endpoints, not generic AXI WRAP/4KiB correctness or actual PIM mapper operation. Eight source-side high-address and eight destination-side cases preserve exercised upper bits, but dma_top narrowing/physical bank routing remain untouched. R replies are same-ID/in-order with correct RLAST/beat counts; malformed RID/RLAST, unsolicited/extra replies, maximum9-bit transaction count, invalid lengths, address admission and zero-gap real descriptor queues are unqualified.

CSR aggregation, software error/quiescence, stop/cancel/reset, ID/USER/clock adapters, exactly one primary PIM owner, physical visibility/fences, mapped synthesis/fit/timing, DDR/OPAE and durable boot remain open. Prior B-response and pair02 reviews are separate bounded gates; this result does not enlarge their scope. No FPGA,MMIO,driver,programming or reboot. DDR vendor simulation **SKIPPED BY USER**.
