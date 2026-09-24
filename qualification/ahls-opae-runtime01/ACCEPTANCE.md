# Parent acceptance — DFL-only configuration and SDK parser

**ACCEPT WITH FINDINGS: additive, uninstalled configuration and parser-only
results.** Specification PASS; evidence/quality sufficient within this gate.

The parent consumed the complete FINAL [independent review](independent-review01.md)
from `deleg_44a2062b`, matched its returned SHA256
`3e302ff4e4d9f7a3da9196deaeb8cd474de2bb6e95cd35571cc0f1b486a763c3`, and rehashed
all 101 frozen members / 850,948 bytes without mismatch or symlink members.
Package SHA256 `4920c1a6c29dd677cb70b6e8fd7baf379f634a019a96f49475fdb35f5128b465`.
[Parent verification](parent-review-verification01.json).

## Accepted observations

The 858-byte candidate (SHA256
`9f49f4d455e672de26dc8546a8ccdc029dbdfe521bee1beca47d102cb63ef5e4`)
parses into exactly the two required xfpga rows:
`8086:bcce/8086:1771` and `8086:bccf/8086:1771`, both with
`/work/sdk-build/lib/libxfpga.so` and `{}`. It is not installed.

Accept the retained RED 54-row SDK configuration versus GREEN 2-row candidate,
and both 22-case matrices. Parent reduction confirms 1 exact, 13 compiled-default
fallback, 2 empty, 6 different tables per matrix; the NULL default is 52 rows.
All native parser calls in the matrices returned 0, including malformed-input
fallback. The exact-candidate predicate, not native rc alone, determines the
project result. The only cross-receipt difference is the `missing-configs`
stderr fixture directory. The original equality rejection remains evidence.

The actual SDK parser fixture excludes OPAE initialization, plugin management,
backend and loader paths. Direct ELF dependencies are JSON-C/UBSan/libc;
this is neither complete transitive qualification nor an OS sandbox.
No completed test was rerun. See [scope](SCOPE.md) and [results](RESULTS01.md).

## Findings retained and disposition

- **F1 — future execution prerequisite, not a blocker for this parser gate:**
  constructors, fallback discovery, prefix-based loader resolution, sysfs/ioctl
  initialization and prefilter backend activity remain unqualified. An absolute
  module string does not attest the loaded ELF; PCI-ID tuples are not BDF
  isolation. No backend/device execution follows from this acceptance.
- **F2 — nonblocking future harness improvement:** mutation predicates classify
  broad nonexact tables and use the observed NULL table as fallback oracle.
  The independent review matched this frozen default to C literals and checked
  all six actual mutation outputs specifically. A changed future regression
  should pin exact per-case rows; no current rerun or frozen-harness edit.
- **F3 — explicit qualification of RESULTS01.md:59–63:** the matrices exercise
  **JSON parsing/compiled-table fallback only**. Environment/HOME/system-path
  discovery was source-inspected, not exercised; its functions were discarded
  from this parser executable. Do not describe those path searches as tested.

The optional reviewer package-content inspection could not decode Zstd;
package/runtime hashes and retained signature receipts were verified instead.
No independent package-payload/header comparison or new signature run is claimed.
Frozen evidence and its historical pending wording remain unchanged.

The separate explicit-startup candidate remains under its own review; it is
not accepted here. This gate grants no installation, runtime loading, driver,
OPAE discovery/MMIO, physical DDR/DMA, numerical AHLS, lifecycle, full-design
closure or durable-boot acceptance. Vendor DDR simulation remains SKIPPED BY USER.
