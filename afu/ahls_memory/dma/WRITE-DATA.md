# Writer data-channel adaptation

Apply `patches/write_data_elastic.patch` after the separately preserved `write_address_handshake.patch`. Its baseline is the AW-corrected candidate, not the pristine AI Suite source. It preserves the original vendor file and preceding artifacts, using the existing W output register as a one-entry elastic buffer and advancing bursts only on accepted WLAST.

[Native evidence](../../../qualification/dma-write-data01/RESULTS01.md): two reproduced baseline failures, then12candidate cases with30AWrequests/5448checked data beats under AW/W stalls and input-FIFO gaps. Independent review pending. The input FIFO/platform are explicit fixtures, not deployed bindings.

No B responses are supplied and the unchanged completion logic still signals done in every candidate case. This is **not a qualified writer or DMA**. Response/error/drain, CSR/descriptor lifetime, real FIFO/PIM integration, legal length/address limits and physical hardware remain open. Do not apply this patch to maintained/live sources or deploy merely because its standalone unit passed.
