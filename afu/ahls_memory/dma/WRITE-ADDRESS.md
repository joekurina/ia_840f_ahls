# Writer address adaptation

`patches/write_address_handshake.patch` is an additive correction against the immutable AI Suite donor. It makes AWVALID independent of ready, retains the full AW payload across stalls, and corrects intermediate/full/final AWLEN scheduling. Original source is preserved.

[Native qualification evidence](../../../qualification/dma-write-address01/RESULTS01.md) reproduces three original defects, then passes the12-case AW/W-always-ready unit. Independent acceptance pending. The synthetic sink does not return B responses and the unmodified writer still signals done: this remains a concrete completion defect, **not a qualified writer**.

The separate [reader correction](../../../qualification/dma-read-handshake01/RESULTS01.md) is unchanged. No complete DMA is integrated, mapped, fitted or deployed. Data-channel backpressure, error/drain/visibility, PIM widths/bank mapping and all hardware gates remain unresolved.
