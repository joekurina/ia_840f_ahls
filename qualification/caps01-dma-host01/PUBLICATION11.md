# Accepted milestone: first real CAPS01 DMA roundtrips

Independent [ROUNDTRIP-REVIEW09](ROUNDTRIP-REVIEW09.md) accepts the two completed 64-byte logical-bank roundtrips **with bounded limits**. Parent verified the review's evidence ledger and consumed it in [roundtrip-review-consumed10.json](roundtrip-review-consumed10.json). The actual frontend compared returned data and full host-buffer pages; both native/container/outer exit triples were zero and recorded postflight was clean.

This publication closes only that finite gate. It does not establish bank isolation, simultaneous traffic, large/address-boundary coverage, sustained DDR, numerical AHLS, or general host/reset safety. The later additive isolation candidate is not part of this commit. Historical preparation reports and their pending-review statements remain unchanged; this acceptance and the completed reviews supersede those states.

Selected authored frontend/core/lifetime sources, inert tests, native CMake inputs, compact test/result receipts, and independent reviews are included by explicit path/hash allowlist. The original inspection frontend and unrelated work remain untouched.

`dma-build03-result.json` stays local because it embeds ELF/log payloads. [build03-result-metadata11.json](build03-result-metadata11.json) removes only recursive `base64` fields and retains exact source size/SHA256 and remaining metadata. Its omitted payload hashes keep provenance auditable; it is not a replacement executable receipt. Binary outputs, vendor bound RTL/SDK captures, payload-bearing runners, internal transcripts, mutable checkpoints and the isolation work remain local. Runner and original build hashes are preserved in the reviewed evidence even when their full bytes are excluded.

The publication manifest names each selected file and binds its size and SHA256. No file exceeds 2,000,000 bytes. Raw captured evidence is preserved byte-for-byte; publication does not rewrite historical results or add a hardware action.
