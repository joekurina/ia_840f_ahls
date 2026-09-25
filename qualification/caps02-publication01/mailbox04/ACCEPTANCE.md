# Accepted: standalone digital observer mailbox04

The parent accepts the standalone mailbox04 slice after [SPEC PASS](SPEC-REVIEW.md) and [QUALITY APPROVAL](QUALITY-REVIEW.md), with corresponding consumed-review receipts. The unchanged native counter has [separate acceptance](../candidate02/ACCEPTANCE.md).

The original [mailbox03 SPEC failure](../mailbox03/SPEC-REVIEW.md) remains preserved. [RED](red01.json) reproduces its RELEASE/rejection monitoring-window defect; [GREEN](green02.json) runs the same expanded fixture with the one-condition fix. Production sequence64 passes10cases76checks at each of three clock ratios; narrow sequence8 passes11cases847checks. B1 is closed in this standalone scope, including continued DMA/reset fault capture and an isolated ARM-enqueue contamination pulse.

This is digital RTL acceptance, not physical CDC/reset timing, locally bounded MMIO response, CSR/AFU integration, a publication fence, global drain or hardware qualification. No HLS, deployed image or vendor source is changed. Historical pending-review statements are superseded only by this exact acceptance and reviewed byte identities.

Publication preserves the failed predecessor needed to reproduce RED. It excludes simulator binaries/VVP outputs and mutable checkpoints, with selected omitted identities in publication.json. Independent acceptance of the separate full-width prototype is not part of this commit.
