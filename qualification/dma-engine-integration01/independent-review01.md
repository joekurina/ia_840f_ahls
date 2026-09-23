# Independent DMA integration review

**Status: FINAL**  
**Verdict: PASS — bounded paired native datapath evidence and narrow reader descriptor-counter correction.** No blocking finding within the stated scope. This is not DMA-top/PIM/AFU, general AXI4, physical-memory or hardware acceptance, and does not independently accept the separate writer B-response gate.

Local evidence only. An IN_PROGRESS report preceded this final review. No SSH, simulator/vendor execution, hardware access, source edits, git operations or task transitions were performed. Only this review was written. Runner configurations were AST/literal-decoded, never executed or imported; patch application was checked in memory.

## 1. Bounded specification compliance — PASS

- **Frozen evidence verified:** full-file SHA256 and byte sizes match all **20** entries in `review-package01.json`. Independently checked both runners' **13** decoded inputs, their dispatch hashes, all **10** embedded native log payloads, outer-result hashes and case accounting. Both runner bodies match `run-native.py.in`; configurations differ only by run name and reader bytes. `inputs02/` supplies only that reader; the other non-test inputs come from `inputs01/`, and the final testbench is unchanged. No manifest drift was found.
- **Real internal composition:** `inputs01/dma_engine.sv` is byte-identical to the bound donor wrapper; its writer-done/reader-ack connection and PIM FIFO instance are real (lines 47–101). The FIFO source matches the bound PIM original: N_ENTRIES=32, registered output, installed `scfifo`, and active wrapper overflow/underflow assertions (`dma_pkg.sv:27`, `ofs_plat_prim_fifo_bram.sv:38–99`). No substitute `scfifo` definition occurs in the 13 inputs; literal include dependencies are bound. Native `vdir` lists `MODULE scfifo`, and `vsim` explicitly uses `-L altera_mf_ver`. Catalog/library hashes agree with both runners and native preservation receipts: **6 files / 2,652,245 bytes**, same installed modelsim.ini. The optimized log loads `dma_engine_tb(fast)`; it does **not** provide a separate scfifo load line. The family define is confined to the integration include fixture.
- **Actual paired outcome:** recorded Questa Intel FPGA Edition2024.3 under `/opt/altera/25.1`, tmux203/204. Version/vlib/vdir/vlog/vsim each return0 on both runs, but pair01 has the cycle171 / 1776ns fatal and outer1; pair02 has outer0. Fatal-aware acceptance correctly rejects the baseline despite simulator rc0. Native receipts show no timeout or residual owned groups and unchanged inputs/originals/tools/library. This reviewer verified the saved receipts, not the remote host anew.
- **Native ledger reconciled:** 10 cases; 15,616 monitored cycles; 168,352 checks; **33 AR / 33 AW / 6,470 R / 6,470 W / 32 B**. Eight successful retirements, one write-SLVERR error hold, one missing-B hold. All 6,470 beats are transport-checked; the eight successful cases additionally compare **5,956** destination-model-memory beats at retirement. The remaining **514** beats are not successful descriptor completions. The missing-B case ends with its synthetic transaction outstanding after128 observations, not with drain or reset recovery.
- **Coverage matches the bounded claim:** testbench lines 103–180 check whole stalled AR/AW/W payloads, accepted full addresses/length/size/ID/burst encoding, FIFO data/flags/markers, pipeline accounting, W strobes/last and actual descriptor retirement. Four successors run without reset, with consecutive counter checks. Lengths are 1,257,514,2049,769,1279,63,1024,513,1, including multiburst tails2 and255. Recorded read/write stalls are 5,406 / 8,618 cycles; maximum R-minus-W is34. Five host-source cases set bits34/56 and five host-destination cases set bits35/55. These are direct57-bit interface tests, not host IOVA allocation or dma_top narrowing repair.
- **Warnings preserved:** final simulator summary is **0 errors / 9 warnings**: five relaxed-input-kind13314 and four unique-case8315, all latter at time zero before synchronous state initialization. The compiler reports the same five port-kind sites; optimization repeats them. No later warning or FIFO assertion failure appears. This is not a warning-free or synthesis/timing result.

## 2. Source and test quality — PASS with one nonblocking note

**Counter correction is exact and causal.** In the reader, actual dequeue is `state[WAIT_FOR_WR_RSP_BIT] && wr_fsm_done` (candidate lines201–203), which selects next IDLE (121–123). The old increment under next WAIT therefore misses the successful edge. The patch moves the same increment to the nonreset clocked default (215–249), preserving reset precedence and all request/data/control logic. It remains a four-bit modulo16 counter (`dma_pkg.sv:28,181`). Exact in-memory patch replay proves retained read-unit original → accepted AR patch → pair01 reader → counter patch → pair02 reader; the AR correction is preserved. The additive counter patch is not a pristine-donor standalone patch.

**Test separation is adequate for this result.** External drivers update away from the sampling edge; assertions check pre-NBA handshakes and the counter after NBA. Expected payloads derive from descriptor position and case identity, not merely echoed DUT addresses. Real FIFO enqueue/dequeue and actual writer completion replace the earlier synthetic internal boundaries. Successful retirement requires complete beat/B accounting, locally empty pipelines, exactly one ack and model-memory comparison. Write-SLVERR allows the current descriptor's writes/replies to drain, then holds reader ownership; missing B cannot retire. The fixture supplies a stable descriptor until real dequeue, not a real descriptor FIFO/CSR producer.

**Q1 — low, nonblocking regression-hardening opportunity:** `tests/dma_engine_tb.sv:194` only requires `max_buffered > 2` and nonzero stalls. Those assertions alone would permit a future shallow-buffer run to pass without the present deep-backpressure coverage. This frozen run reports34 buffered beats and substantial stalls, so its evidence is not invalidated. If reusing the test as a future coverage gate, add an explicit near-capacity/almost-full coverage requirement rather than inferring coverage from the pass marker alone. No rerun is required for this review.

## 3. Limits retained; no promotion of adjacent gates

The external source/sink are **linear line-request models**, not generic AXI4 WRAP endpoints; donor host-side WRAP encodings remain. Hash-checked source context forwards address/length without burst type: host mapper lines353–357/590–592 and AXI-to-Avalon bridge lines70–76/250–255, at paths bound in `source-binding02.json`. Neither mapper is instantiated. This supplies context only, not WRAP/4KiB legality or actual mapper-splitting qualification.

Wrapper MODE stays HOST_TO_DDR; its unused width localparameters do not resize externally supplied interfaces. Dynamic descriptor modes exercise engine branches only. No dma_top/selector/register-slice/bank routing, real descriptor queue/CSR, ID/user adaptation, address admission, PIM/AFU/PCIe/physical DDR, cancellation/reset/global drain, buffer-reuse or visibility acceptance follows.

All read responses are IDzero/OKAY. **Read-response-error handling remains a source gap, not a pass.** Maximum nine-bit transaction counts, invalid/overflow lengths, malformed tags and four-bit counter wrap are unqualified. Successful no-reset successors are not proof of a real queue's zero-gap producer behavior. No live operations were performed; DDR vendor simulation remains **SKIPPED BY USER**. Prior AW/W acceptances are neither reopened nor enlarged; the separately pending writer-response review is not polled or promoted here. Parent verification/acceptance still governs publication.

## Full-file SHA256 binding

The manifest binds the remaining reviewed evidence; these are the principal exact identities:

| File | SHA256 |
|---|---|
| `review-package01.json` | `8bc5ef419e60ad1629127f52ba9556d397bad90efef0999c2e4e75a029c82a1a` |
| `inputs01/dma_read_engine.sv` | `dd50e2de9ab6139d93fc36b95e16f8ac2a9a1bd249384026bfe3944a55c00f6a` |
| `inputs02/dma_read_engine.sv` | `7433c99064fcd9b2b07cd86edc1b1d4d2a02019af041e1c5bc7ccae4079f6cf6` |
| `inputs01/dma_write_engine.sv` | `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b` |
| `../../afu/ahls_memory/dma/tests/dma_engine_tb.sv` | `e660db29851bb38131bd6480e1abc77ae51c11e2074a8608227b750647ac712c` |
| `../../afu/ahls_memory/dma/patches/read_descriptor_count.patch` | `267401838760d8c90879e1cc129e2b78245740d9f10b9cab3f6e2a1e5efab303` |
| `result-pair01.json` | `30e337bf0665e99d5ae6912ab050cd1630b6a9b0011ab39b93a2a2ff9688b972` |
| `result-pair02.json` | `79f82edecedd6d7a05b10b55b40eb61367d49be815baf544626f0117506e3a3d` |
