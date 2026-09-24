# FPGA Test: first 64-byte bank0 roundtrip

## Bound single-use scope

Use current Work21/CAPS01, boot598f7b27-1798-4a88-8a79-9e4a2659c64d, VF0000:4f:00.2/group76. No flash, PR, VF setup, driver/AER/clock change or explicit reset. Standard VFIO enumeration/open/close can perform implicit FLR and PCI COMMAND setup. Joe's physical-access/full-continuation authority remains in effect with the no-speculative-access/no-host-hang boundary.

Completed source review: FRONTEND-REVIEW04.md ACCEPT WITH BOUNDED LIMITS. Completed compile: RESULT04.md. The unsupported malformed-success duplicate-WSID path is outside the bound allocator's normal contract, not claimed robust. Original inspection/SDK files stay unchanged; use only the new hash-bound native launcher/entry, not an inert executable.

Preflight06 succeeded via cached/ordinary metadata only: correct boot, drivers, singleton VF, source-bound cached Work21 identity, no holders/D-state, exact new artifact hashes, page4096 and unlimited MEMLOCK. Receiptf707c78aff97e29eea1a42dca301532af3fc312b89c9f36b7e2746d7244fbc20.

The unchanged reviewed frontend first verifies identity/capabilities, allocates two4096-byte buffers with flags0, checks returned IOVAs and initializes entire pages. One descriptor copies64bytes from source IOVA+64 to bank0 local0x10000; after fresh retirement, one descriptor copies that DDR location to destination IOVA+64. Full W64 source0x28/destination0x30/length0x38/GO0x40; R64 argument readback, status0x48 and zero-control check0x50. GO words0x84000000 then0x88000000, length1beat. No other DMA/kernels or concurrent bank test. Expected data depends on address/bank; all64 payload bytes must change from their complements and both4096-byte pages/guards must match before normal release. See REGISTER-CONTRACT01.md and BUFFER-LIFETIME01.md.

## Ownership and stopping

The production hold blocks ordinary signals before OPAE loading and never returns after uncertain GO or data visibility/corruption. It retains buffers, WSIDs and FDs without reset/retry/extra MMIO. Runtime-supervisor05 keeps the container command/init alive on hold, observation deadline, or post-spawn bookkeeping failure. In the same SIF with no devices exposed, all four supervisor05 cases passed, including original owner/FD retention after outer observer exit; receipt ec48870ff8943c29d4f2151d321f323477c887912e66f00d46f2b6cdd53d7fbe. Only those known inert fixtures were killed/cleaned. Their cleanup code is NOT present in the live runner.

The inner observer deadline45s and outer60s are not cancellation bounds. The outer runner sends no signal on timeout/hold; a retained owner is a failed/UNKNOWN operation and blocks all successors/recovery. SIGKILL, fatal faults, OOM and host failure remain outside containment. The old identity inner used an unbounded wait; the concrete added protection covers exceptions after successful spawn as well as finite observation deadlines.

## Required success evidence

One native/container/outer0 invocation with exactly two submissions, both local retirements, active payload/full-page verification, actual runtime library selection, unchanged boot/bindings/input files, and an empty postflight holder/D-state scan. This can qualify only the tiny serial bank0 roundtrip—not full DDR, bank1, simultaneous traffic, sustained behavior or numerical AHLS. Stop immediately on any anomaly; no retry or alternative access.
