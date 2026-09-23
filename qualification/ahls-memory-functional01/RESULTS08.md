# Connected AHLS numerical simulation — path08

**Native and outer PASS; independent review pending.** This is a simulation of the real generated HLS kernel and our transport composition, not physical DDR/PCIe/OPAE qualification. [Scope](SCOPE.md), [final source binding](source-binding08.json), [parent verification](parent-verification01.json).

## Verified result

Questa Intel FPGA Edition2024.3 under Quartus25.1 installation, fresh `work_ahls_memory_functional01/path08`, owned tmux@233/%233. Five native/effective commands return0; outer0; no Error/Fatal diagnostic, no timeout or surviving owned group, and all recorded input/original/tool preservation checks true. The exact final marker is:

```
AHLS_PATH_UNIT_PASS cases=4 elements=91 copied_bytes=1088 dma=16 checks=2729 mmio_reads=292 mmio_writes=84 bank0_W=18 bank1_W=31
```

Simulation finishes at43310ns, Errors0/Warnings255. Native compilation reports0errors/43warnings. [Warnings](warnings08.json) remain unwaived; this is not warning-clean. Final source set528files,449HDL compilation units; six additional same-release altera_lnsim library files are hash-bound alongside the prior altera_mf library and tools. `vdir` confirms actual `altera_syncram`; no model substitute or installed-library edit.

| Case | Elements | All copied-back bytes checked | Exact kernel store bytes |
|---|---:|---:|---:|
|0|1|192|4|
|1|8|192|32|
|2|17|256|68|
|3|65|448|260|

Totals:91signed-int sums,1088byte comparisons,364kernel-result bytes and724guard/padding bytes. [Per-case ledger](cases08.json). Inputs include nonzero and negative integers; sums stay within signed32-bit range. The test initializes host-model memory only, then uses actual CSR-programmed DMA to stage x/y in bank0 and output sentinels in bank1. It programs generated kernel pointers/size/start through the generated MMIO fabric, polls non-destructive status, reads the finish counter only while quiescent, and copies bank1 data back through DMA. It checks every result and every copied byte, including prefix/suffix and partial-vector padding. No forced DUT descriptors, internal completion substitution or recomputed result written into the memory model.

Four cases run without resetting between them;16DMA descriptors exercise the4-bit descriptor-count wrap. The one-in-flight test uses modulo-count advancement plus idle/FIFO-empty/error status, not a presumed monotonic counter. Core/bank clocks have10/14/22ns periods, respectively. Actual PIM bank CDC, metadata/expanded-ID preservation, write-last adjustment and FIFO implementations are instantiated. Deterministic request/data stalls and delayed B responses are active. These periods are fixture choices, not FPGA timing/performance measurements.

The host endpoint deliberately implements the previously documented linear line-request convention, not generic AXI WRAP semantics or a primary PCIe mapper. Bank endpoints enforce legal AXI burst shapes, byte lanes, model bounds and4KiB boundaries. Memory arrays are byte-addressed synthetic endpoints, **not vendor DDR models**.

## Failures and scoped corrections

All eight native attempts are retained; native zero never overrides a failing assertion.

| Attempt | Native final / outer | Actual result / change |
|---|---|---|
|path01|12/12|HDL compiles; missing altera_syncram library binding prevents loading. No functional run.|
|path02|12/12|Add only installed altera_lnsim_ver search/bindings. Loading exposes generated-LSU always_ff array-ownership errors7061.|
|path03|0/1|Expand three fixed reset loops to constant indices in two generated LSU copies. Real simulation starts; first MMIO combinedRID/RLAST check fails.|
|path04|0/1|Only assertion diagnostic text changes. RID0x52 is correct; flattenedRLAST0 is the discriminator.|
|path05|0/1|Fix fixture contract: real upstream AXI-Lite has noRLAST, and actual PIM wrapper leaves it unused. All other checks retained. Two input copies pass; third copy crosses4KiB and fails the bank protocol assertion.|
|path06|12/12|Insert existing PIM PAGE_SIZE4096 mapper ahead of both bank shims. Initial sinkLEN8 configuration violates vendor page-gearbox range requirement.|
|path07|12/12|Correct only internal page-limited LEN to5 (32beats/2KiB <4KiB). Loading then rejects our direct to_source_clk→to_source modport forwarding.|
|path08|0/0|Use the existing PIM clock-driving interface connector with an internal full interface. All four numerical/guard cases pass.|

The reset patch `afu/ahls_memory/patches/constant_reset_indices.patch` preserves always_ff/event controls/reset conditions/nonblocking values and all non-reset logic. Read stage1 and stages2..5 are separate owners; writer stages1..3 and stage4 are separate owners. Fixed localparams5/4 and exact original blocks are asserted by patch derivation. Both mutually exclusive writer branches are covered. This is an additive candidate, not an edit to accepted generated output or installed vendor source. [Ownership proof/delta](source-delta03.json), [rationale](RESET-INDEX-CORRECTION01.md).

The final bank wrapper is **`afu/ahls_memory/pim/ia840f_ahls_memory_bank_shim03.sv`**, compiled under the unsuffixed module filename in this run. Unsuffixed/02authoring files are preserved failed candidates; do not compile all three together. It reuses `ofs_plat_axi_mem_if_map_bursts(PAGE_SIZE=4096)`, WLAST fixup, the existing NO_REPLY flag, and the unchanged local-memory shim's metadata queues/CDC. Internal LEN5 satisfies the source-declared strict page/burst-size contract; address/data/ID/USER and physical bank capacity are unchanged. The exact failing0x3fc0→0x4000crossing addresses remain in all positive cases, for both initialization writes and copyback reads. No guard/assertion or test address was relaxed to hide the crossing.

Final test is **`afu/ahls_memory/core/tests/ahls_memory_path04_tb.sv`**, compiled as ahls_memory_path_tb.sv; earlier fixture versions remain preserved. The only fixture expectation removed was RLAST at an AXI-Lite boundary; RID/RRESP/timeouts and all numerical/protocol checks remain. OriginalDUT/library/test variants are reconstructed by inert AST payload decoding. Parent verified4219source payloads across8runs, every dispatch/result/log hash and all preservation/lifetime receipts.

## Important limits

- The test observes **synthetic endpoint accepted-store byte counts and B-queue drain before copyback**. This prevents assuming HLS finish means physical visibility, but is not a software-visible global-drain/fence ABI. No host buffer may be released/reset/retried on that basis.
- This does not execute the primary PCIe mapper, DFL/OPAE, physical memory controller, calibration, full-size16GiB addressing, GB/minutes stress, malformed responses, error recovery, PR or reset under traffic. Actual hardware DDR gate remains open and vendor DDR simulation remains **SKIPPED BY USER**.
- Maximum tested vector65; no maximum descriptor-length or exhaustive burst/alignment coverage. Physical-bank simultaneous traffic qualification is not inferred from two-bank kernel operation.
- Newly added page wrapper and reset-index corrections are not yet imported into a newly qualified full AFU/FIM build. Native Quartus synthesis/fit/STA for these exact candidate bytes remains open. Previous component structural milestone is accepted/published **bb947533abbeaa4d24562e5b79a13d4d4b016dfa**; it does not cover these changes. Real-PIM predecessor review is separate.
- Capability telemetry, writer-state/first-error reporting, outer-aperture aliases, posted-write visibility, control/drain, freeze/PR and fullFIMsignoff findings remain. Constant-zero exception output is not used as a pass criterion.

No FPGA/device/MMIO/driver/programming/reboot operations occurred. All MMIO references here are simulated SV transactions. Goal incomplete.
