# Paired reader/FIFO/writer unit

[Native evidence](../../../qualification/dma-engine-integration01/RESULTS02.md) uses the unmodified donor dma_engine wrapper and actual PIM BRAM FIFO/scfifo with the corrected reader and writer. External line-request endpoints and memory array remain simulation fixtures. Ten cases transfer/check6470beats; eight successful descriptors additionally read back5956model-memory beats. Write-error and missing-response cases retain descriptor ownership.

Apply `patches/read_descriptor_count.patch` after the reader AR patch; it counts the actual dequeue edge missed by the original next-WAIT update. Writer uses response-retirement02 after AW/W corrections. Native pass awaits independent acceptance. This is not dma_top/CSR/bank/PIM/AFU integration, standard host-WRAP/4KiB qualification, read-response-error handling, physical visibility or hardware acceptance.
