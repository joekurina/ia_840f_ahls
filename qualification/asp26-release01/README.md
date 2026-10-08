# IA-840F ASP release qualification

These are exact copies of accepted engineering receipts, not new hardware
execution during publication. Original native exits, hashes, false lifecycle
flags and historical statuses are preserved.

- `FOUR-WAY-HARDWARE624.json`, `NATIVE-LINK-READBACK619.json` and
  `INDEPENDENT-ACCEPTANCE630.json`: independently reviewed native fat-binary,
  embedded-image and original four-way hardware milestone. That review predates
  the later runtime upgrade; it is not a new independent OPAE review.
- `FOUR-WAY-HARDWARE679.json`: final OPAE2.14.0-3 regression; all four unchanged
  images/executables,40,000 comparisons/native0, private core/plugin binding,
  AHLS library parity and empty owner/unreadable entries.
- `OPAE-BUILD676.json`, `OPAE-MODULE-RELOCATION672.json`, `OPAE-RUNTIME680.json`:
  pinned latest-release build, disclosed configuration-only lookup patch and
  coherent CLI/library/plugin/Python/MMD/MPF prefix. Programming functions and
  FPGA logic are unchanged.
- `PACKAGE-VERIFIED682.json`: vendor package681 native imports and relocated
  loader/Python checks. Its pre-manual inventory is not the final archive count.
- `ARCHIVE-VERIFIED683.json`: final retained package,14,930 regular files and97
  internal symlinks verified against its manifest, including manual/source ZIP.
- `RESOURCE-POLICY593.json`:55GiB per process and at most two admitted fits.
- `GOAL-COMPLETE685.json`: original pre-publication completion snapshot. Its
  `committed_or_pushed=false` describes that snapshot, not this subsequent Git
  publication.

`lifecycle_clean=false` and the exact scoped pending-before-FLR warning remain.
Clock MHz values are STA/GBS metadata, not throughput or live frequency samples.
Earlier optional probes remain historical and are not relabeled as rerun for
OPAE2.14. Current scope does not qualify arbitrary kernels, universal resets,
MTBF, different hosts or cross-distribution runtime compatibility.

Raw source-embedding transport launchers, agent transcripts, over2,000,000-byte
files, licensed binaries/tools and programming images remain local-only. The
original campaign and native workspace are preserved; publication does not
normalize or delete captured evidence. The public assets provide source/manual
and metadata, not the full privately retained hardware/runtime bundle.
