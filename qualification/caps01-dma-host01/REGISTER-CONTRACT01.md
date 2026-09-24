# CAPS01 finite DMA host contract — source-bound, not yet a hardware pass

The accepted CAPS01 literal payloads were decoded without executing their runners and SHA-checked before inspection. Bound RTL copies remain local-only under `bound-rtl/`; do not publish vendor source bodies merely because they are small. Existing image/host inspection acceptance is reused, not rebuilt.

## Descriptor and route

The maintained candidate will use PF0 VF0/BAR0/MMIO0 through the already exercised strict VFIO backend. Full aligned W64 only: source `0x28`, destination `0x30`, length `0x38` in **64-byte beats**, descriptor control `0x40`. Read-only status is `0x48`; control `0x50` must already be zero and is never written by this test. These are `dma_pkg.sv:61-79` indices multiplied by8 and `csr_mgr.sv:119-200,324-350,430-457` decoding.

Use enum/RTL meanings, not the swapped stale comment beside the mode field: HOST_TO_DDR=1, DDR_TO_HOST=2 (`dma_pkg.sv` enum, `dma_axi_mm_mux.sv:130-144`). GO is bit31; mode occupies27:26, giving `0x84000000` and `0x88000000`. Validate addresses, mapped extents, beat alignment, length and bank boundaries **before any device access**. Write each argument once and read it back before GO. Source RTL requires all three fresh fields for every GO and consumes freshness on GO (`csr_mgr.sv:149-215`). No dispatcher-reset/stop write or GO retry.

Local DDR bank selection occupies address bits above per-bank width34; bank0/1 each covers16GiB, with low34 address bits forwarded by `dma_ddr_selector.sv`. First candidate roundtrip is64 bytes at fixed bank-local offset0x10000, with separate4096-byte host source/destination allocations and64-byte head/tail guard space. Test each bank separately; this is not simultaneous/full DDR qualification.

## Completion and buffer ownership

Status low bits survive the legacy aggregate truncation: busy0, descriptor-empty1, descriptor-full2, data/response-FIFO-empty3/full4, stopped5, resetting6, stopped-on-error7, write-response error10, read-response error13, writer state21:16, reader state27:22, retired-descriptor count31:28. Writer internally has9 states but the status field is6 bits: do not use it as a complete writer-state decoder. The idle encoding remains bit0 in both FSM fields (`dma_pkg.sv` status struct and read/write engine enums).

For one outstanding descriptor, require a fresh retired-count increment modulo16 **and** both FIFOs empty, busy clear, no error/stop/reset flags, and both reported FSM fields at idle. A busy transition need not be observed for a fast transfer. Idle alone or a stale completion count is not success. Read engine increments the counter on actual descriptor dequeue (`dma_read_engine.sv:223-247`), which requires writer done and no read error. Writer done requires all accepted AWs to have completed W bursts and valid matching OKAY B responses (`dma_write_engine.sv:88-118,294-303`). This closes the source-visible engine obligations; host-memory physical visibility still needs actual copied-back data verification.

Mark GO as potentially issued **before** calling its write API: failure can be ambiguous. After GO, API error, sticky hardware error, unexpected counter or polling exhaustion means uncertain DMA ownership. Do not release buffers, close the device, finalize OPAE, exit, reset or retry automatically. Retain the owning process/resources without further device accesses pending a reviewed recovery decision. The exact backend allocation/release and controlled failure-hold policy is being reviewed separately in BUFFER-LIFETIME01.md. No claim is made that userspace can retain resources across arbitrary fatal kernel/process failure.

Normal cleanup is permitted only after every submitted descriptor has a source-supported completion and all output payload/guard bytes have been checked. A data mismatch after verified retirement is failure, not permission to reuse the buffer for a new attempt. The transfer test cannot by itself establish GB-scale, simultaneous-bank or sustained DDR qualification.
