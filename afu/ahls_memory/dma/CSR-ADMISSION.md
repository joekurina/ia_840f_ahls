# DMA CSR and descriptor admission

Apply `patches/csr_descriptor_admission02.patch` to the pinned donor CSR manager; the unsuffixed patch is preserved failed declaration-order history. Final test is `tests/dma_csr_admission02_tb.sv`; original fixture and both failures are retained. [Bounded acceptance](../../../qualification/dma-csr-admission01/RESULT-ACCEPTANCE.md) and [independent review](../../../qualification/dma-csr-admission01/independent-review01.md).

The received CSR interface rejects alias/malformed accesses and invalid raw descriptor values before narrowing; full queue, freshness, mode/range/end-address and counter-derived length predicates govern GO. This is not a global cancellation/reset/drain or CPU-visible posted-error protocol. ReviewF1/F2 and all full-system/hardware limits remain. Retain the existing scalar AFU and unmodified donor sources.
