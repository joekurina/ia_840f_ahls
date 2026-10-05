# OFS tutorial AFU qualification evidence

This campaign qualified the OFS tutorial AFUs on the accepted migrated IA-840F FIM. It is **complete under the recorded-failure policy**: eight variants built/loaded/tested, six scoped hardware passes and two data-verification failures; the README-only advanced entry is explicitly skipped. [Final summary](FINAL-SUMMARY121.md) and [verified aggregate](FINAL-AGGREGATE121.json) carry the results. [CURRENT.md](CURRENT.md) is the authoritative closed handoff; [targets28.json](targets28.json) is the immutable initial inventory, whose old NOT_STARTED/active fields are historical—not current work.

## Evidence/publication policy

- Programming images, static databases, licensed binaries and raw captures larger than **2,000,000 bytes** are never committed. Native work/artifacts remain under `/home/uwb_student00/ahls/new_BSP/work_examples_afu01/`; collected local-only evidence stays in this qualification tree. Reports/manifests carry exact sizes, paths and SHA256 identities.
- Embedded executable transport payloads and raw agent transcripts remain local/private regardless of size. Standalone reviewed source/monitors, payload-free manifests, native result receipts and selected raw text captures are explicit publication candidates.
- Preserve failed receipts, source captures and their byte hashes. A later corrected attempt or engineering acceptance is a separate record, not a rewritten raw success flag.
- Commit only an explicit, size/content/secret-reviewed allowlist at each independently accepted example; verify staged blobs and intended remote branch after push. Never sweep unrelated worktree files or active next-example preparations into an acceptance commit.
- Native clock-summary screening is not a blanket DRC/CDC/reset/unconstrained waiver. Scoped OS ownership observations are not comprehensive hardware-health or future no-hang guarantees.

## Functional acceptance

The actual hello-world tutorial performs MMIO-triggered DMA, not an MMIO write/read roundtrip. Its checked alternative verifies the entire64-byte greeting/NUL/zero-padding line. The original tutorial sources remain intact. Other examples are judged against actual source-defined data/frequency checks and recorded host corrections where necessary.

A transient D-state sample alone does not prove an MMIO hang. Observe the same owned process within its original finite deadline and preserve the actual native exit receipt before postflight; explicit stopped failures and true deadline expiry retain the owner without kill/recovery/retry. No source or GBS rebuild is justified solely by a monitoring-receipt defect.
