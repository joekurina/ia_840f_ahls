# Real PIM structural checkpoint

Native Quartus25.1 A&E `elab01` is FINAL independently reviewed and parent accepted, **structural only**. Review SHA256 bd6d1188d1e0d579e6b9012c1ce6219dddb1a7a25ce327ec3754f0d3be2216e0. All20 frozen package entries,9 exports and273 platform/core source payloads verified. Native/effective/outer0, all preservation true; no unchanged rerun.

One primary host mapper and both actual bank shims surround the real DMA/AHLS core. 341 warning occurrences, ResetReleaseHigh, ineffective freeze, original bank PAGE_SIZE0, host burst semantics, outer MMIO aliases/posted-error visibility, telemetry/drain/buffer-lifetime and full-FIM/hardware limits remain. See RESULT-ACCEPTANCE.md and independent-review01.md for F1–F6 dispositions.

The prior connected-core gate is separately published bb947533abbeaa4d24562e5b79a13d4d4b016dfa; CSR admission cbefc1a91b1cb417906eb360fddf0f15f33a4407 and routing f9a860d remain accepted within their scopes. Later functional and page-safe native candidates are separate, not part of this milestone. No programming/MMIO/driver/reboot operations; vendor DDR simulation SKIPPED BY USER. Goal incomplete.
