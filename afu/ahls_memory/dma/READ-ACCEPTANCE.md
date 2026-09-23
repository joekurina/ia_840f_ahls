# Read-request correction acceptance

The additive `patches/read_request_handshake.patch` and its complete-reader native old-fail/new-pass test are independently reviewed and parent accepted within the [source/read-unit scope](../../../qualification/dma-read-handshake01/RESULT-ACCEPTANCE.md). The frozen README's review-pending wording is historical.

This is not an integrated DMA or hardware pass. Real FIFO/writer/response drain, host IOVA bits34–56, PIM/bank/visibility and reset/error handling remain outside acceptance. Preserve the donor original and its licensing; no full vendor source is republished here. The writer address patch is a separate in-progress qualification gate.
