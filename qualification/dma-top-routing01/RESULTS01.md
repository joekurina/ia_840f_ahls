# Full donor DMA-top routing — native results

**Native finite test passed; independent review pending.** This adds actual `dma_top`, `csr_mgr`, descriptorFIFO, donor directional mux and PIM register slices to the previously tested reader/dataFIFO/writer. Full host addresses and both selected bank ports are exercised through real CSR programming, not forced descriptors. External host/bank endpoints remain synthetic. [Scope](SCOPE.md), [source bindings](source-binding01.json), [parent checks](parent-verification01.json).

## Ordered experiments

|Attempt / tmux|Single changed variable|Observed outcome|
|---|---|---|
|red01 /207|First full-top fixture|vlog0; vsim native0/effective124/outer124 after120s; no native assertion reached. Retained timeout, no surviving owned group.|
|red02 /208|Continuous field-wise fixture wiring replaces procedural bidirectional mux; initial marker added; DUT unchanged|All5native steps0, outer1; cycle7 read address/count mismatch on first host read.|
|width01 /209|Only src_mem address width|All5native steps0/outer0;8cases passed,100317checks. Inactive-bank readiness stays high and replies absent in this variant.|
|isolate_red01 /210|Only +ISOLATE stimulus|All5native steps0/outer1; cycle1 `inactive bank1 reply was consumed`, asserting against exposed inactive-bank readiness while its reply valid is forced high.|
|isolate_green01 /211|Only selected-bank ready/response masking|All5native steps0/outer0; same isolated fixture passed8cases,108863checks.|

The timeout is **not** an address-defect assertion or host hardware hang. [Fixture note](FIXTURE02-NOTE.md) records the tested fixture change without claiming a fully diagnosed simulator delta-cycle mechanism. Neither deadline nor vendor tools were changed. [Failed timeout](RED01-TIMEOUT.md).

## Source corrections

[top_source_address_width.patch](../../afu/ahls_memory/dma/patches/top_source_address_width.patch) changes the internal source address from the local-bank34-bit default to max(HOST_ADDR_W,aggregateDDRwidth),57bits here. The five remaining data/burst/ID/USER properties explicitly preserve the native local-memory macro expressions. The actual directional mux and register slices carry that width; the DDR side projects to bank-local34bit through existing field copies. CSR source readback and actual external host AR checks exercise high bits34/56; host destination AW checks exercise bits35/55. This closes the tested donor-top narrowing, not arbitrary host/IOVA allocation support.

[ddr_selected_bank_ownership.patch](../../afu/ahls_memory/dma/patches/ddr_selected_bank_ownership.patch) masks each bank's ready/valid/payload before reduction, ORs only selected ready, and drives inactive-bank RREADY/BREADY low. Descriptor bank-select bit34 determines bank0/1; bank-local offsets remain34bit. Width-patched original selector fails the isolated fixture; corrected selector passes with inactive bank ready low and forced erroneous R/B data/IDs. These are deliberately synthetic interference stimuli. The current descriptor remains the routing owner until real dequeue; no independent overlapping-descriptor/bank transaction policy is added.

## What actually ran and was checked

Final: **8cases /8626monitored cycles /108863checks;19AR/19AW/3397R/3397W/19B**. Every3397beat is checked through the real pipelines and compared again from destination model-memory at successful retirement. [Case ledger](cases01.json). All four direction×bank combinations are covered twice; bank selection is independently chosen by the fixture, not echoed from the DUT. Bank1 uses the descriptor's16GiB stride while models check the local offset. High local-offset bit33 is set, so testing is not confined below8GiB.

**32aligned full64-bit CSR writes and16reads** exercise real address/length/go programming, source readback, and post-completion status: descriptor count, idle and empty queue. The real16-entry descriptorFIFO is instantiated, with one descriptor offered at a time. Seven good successors run without module reset; no zero-gap/full-queue/concurrent-producer claim. Real32-entry dataFIFO/scfifo and both actual PIM AXI register slices are instantiated, not bypass mocks. Observed read/write stall cycles3069/4908, maximum accepted-R minus accepted-W38. Two register-slice slots plus the original one-beat engine stage are allowed at each external pipeline boundary. Full packed stalled AR/AW/W payloads, beat order/data/length/size/ID/burst/strobes/last, FIFO bounds and successful completion accounting remain checked.

Native Questa Intel FPGA Edition2024.3 under /opt/altera/25.1; unchanged installed INI and same bound6-file scfifo library.25input files/run and20vlog compilation units. Added PIM source originals are before/after hash-bound remotely; pinned donor files are local-capture-bound and transported byte-for-byte. The original macro template is retained except group0 placeholder substitution in an explicitly synthetic platform fixture (2banks,34bit offset,512data,8-bit AXI len,ID9/USER14; host57bits). This is not an actual generated PIM import. The AFU UUID header is a simulation-only value and must never be used for live discovery/deployment.

Native final0errors/**11warnings**: seven distinct relaxedinput-kind13314 sites plus four time-zero8315 cases. Vlog lists8warning occurrences because csr_mgr input status is repeated; vopt lists the seven sites. No late warning, suppression or native error in either passing result. A mapped Quartus fit/timing run was not performed.

## Retained integration limits

The as-run fixtures inherited a stale paired-test header saying no selector/CSR queue; their actual module instantiation and native hierarchy do include both. This prose does not change the frozen source bytes. Full25-input compositions and native logs are authoritative. Future fixture edits should correct that inherited header; no native rerun is justified just for it.

CSR high-address aliasing, ignored byteenables, upper address/length truncation before validation, descriptor overflow and stop/reset/replay policy remain open. First-read-error response code is still tied off in top/csr aggregation despite the accepted reader latch; this gate tests good selected responses, not error propagation through full top. Interface ID/USER values are fixture bindings, not adaptation of fabric ID18/USER2 into real PIM IDs. One-primary host mapping, clock/reset/PR integration and physical endpoint routing remain uninstantiated.

External endpoints interpret donor host WRAP metadata as linear line requests. This is **not generic AXI4 WRAP/4KiB compliance**, maximum burst-count proof, invalid address/length admission or actual PIM splitter qualification. Two bank ports are exercised serially via selected descriptors; this is not simultaneous physicalDDR traffic. Read-response correction accepted/published separately as `fda7ddabefab1a44db1a73759c7f3fd61e5456fd`; its error-test evidence does not automatically qualify full-top error status/lifecycle.

No hardware/device/MMIO, driver, FPGA programming or reboot. DDR vendor simulation **SKIPPED BY USER**. No claim of physical DDR/host visibility, fence/global drain/reset recovery, full AFU/PIM/mapped synthesis/timing, OPAE or durable boot acceptance. Independent source/test/evidence review and parent acceptance remain required before this routing milestone is published.
