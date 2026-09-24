# Accepted live CAPS01 identity/capability milestone

The [independent review](independent-review01.md), SHA256 `e3813ba65a63d48ce77d65047b7cf7d99da833b2d2b617827929161a78f8e384`, accepts the completed native/container/outer **0/0/0** invocation. The original [RESULT.md](RESULT.md) is preserved byte-for-byte; its launch-time “review pending” wording is superseded by this acceptance, not evidence of an outstanding review.

Live enumeration and the bound frontend verified AFU UUID `673c03a1-cef3-4c82-bf10-b12c247d9718`, the exact DFH and the four-word capability decoder. Printed geometry is banks2, beat_bytes64, host_address_bits57, max_descriptor_beats130816. Unprinted raw values remain source-inferred predicates, not an independent register dump. Implicit kernel VFIO resets are included in the bounded lifecycle; the native no-reset banner refers only to explicit application requests. Boot/drivers and selected runtime bytes were unchanged; the postflight scan found no relevant holders.

The [manifest](publication-manifest01.json) binds eleven evidence files. Receipt-embedded native/loader log strings are ordinary readable diagnostics, not encoded source/binary payloads; their lengths and hashes were verified. The standalone inner runtime checker is included; the source-embedding outer runner and external SDK/build/image artifacts remain local-only and hash-referenced. This subset does not reproduce the full private software/build closure.

**Not accepted here:** DDR data integrity, DMA, numerical AHLS, simultaneous-bank or sustained testing, or general reset/CDC/no-hang certification. The separate new DMA host candidate is excluded from this commit.
