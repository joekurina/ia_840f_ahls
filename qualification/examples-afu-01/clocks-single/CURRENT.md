# clocks — relative-frequency FPGA Test accepted after targeted permission fix

**PASS at the named scope**, FINAL `deleg_8c818285`, attempt89. [Acceptance93](ACCEPTANCE93.json), [retry summary90](successful-retry-summary90.json), [review90](review-manifest90.json).

Original native build0/effective0 and GBS SHA256 `d29b3c059316aac396fe76ed6cfeaf79698a35919e4c1bb1a4f5fdfacb18ee75` are unchanged. Following explicit user authorization for necessary permissions, only UID1000rwACL was granted on exact `/dev/uio0`; owner/group remainroot/root, grouproot---/other---. Backup/rollback/effectiveaccess verified. [Permission88](permission88-collection.json). No driver/BIOS/AER/link changes or GBS rebuild.

Fresh normal-user `fpgaconf 0000:4f:00.0 <same GBS>` and `clock_freq_test_checked 759` both durably nativeEXITED0 with empty stderr. Host resets its existing counters, then verifies divider/AFU ratios and actual packaged user-frequency target. Expected759.000000MHz, metadata-scaled counter estimate757.143062MHz, tolerance7.590000MHz; uClkDiv2 approximately378.6MHz. pClk470MHz is reference metadata, not independent absolute metrology. [Runtime89](hardware-result89-collection.json). Scopedpostflight holders/maps/errors/relevants/D empty, sameboot.

Original permission failure is preserved in commit `1de1cf23feecda8479cc48ce508b38b7c2099afc`, with nativePR5/hosts[]/successfalse. This follow-up does not rewrite it. The current authored checkpoint supersedes its earlier failure-only state. No blanket timing/CDC/reset/future-health/no-hang qualification. No active example job; images/oversized raw remain remote-only and hash-referenced.
