# Parent acceptance — explicit startup and inert integration

**ACCEPT WITH FINDINGS** the additive launcher/shared entry and retained
525-process inert startup-ordering evidence. Specification PASS; quality/evidence
sufficient for this gate only. [Scope](SCOPE.md), [results](RESULTS01.md),
[FINAL independent review](independent-review01.md).

Parent consumed the complete FINAL at the dispatch-bound report path and
verified its captured SHA256
`413122d3338caedb18213252c3325d4aa98ec999afbd84299b69c15ba0950cc4`.
All95 frozen files /1,898,023 bytes match package SHA256
`3ec4f08c89e8b8c9389f5a668433a0fef6a69383dfbfb8c5d7e7a32254d1f365`.
[Verification](parent-review-verification01.json).

The parent independently reduced the525 unique records:25 API faults,
448 word/bit pairs (all7×64),12 invalid argument sets,28 config/file rejects,
12 other cases. Recorded rc totals are0:3,1:480,2:42, matching intentional negative
cases rather than525 native zero exits. Constructor/init/seal/finalize marker
counts482/481/481/480 reconcile with the review. The positive25-call/seven-read
sequence and corrected FIFO's rc2/no-constructor rejection were checked directly.
No test was rerun and no original source or frozen evidence was rewritten.

## Findings retained

1. Tests cover finite frontend API/configuration cases, not all launcher
   allocation/I/O/environment/sealing/loader failures. Source establishes the
   literal explicit-init value and same-buffer sealed copy; the fixture checks
   seals/path agreement and a module-path substring, not whole config bytes.
2. Config replacement is an in-place truncation/rewrite, not a concurrent rename
   race test. The O_PATH correction is not a universal pseudo-filesystem timeout.
3. Per-case environments are recovered from the bound driver, not stored in
   every receipt. ELF inspection ordering is procedural evidence, not enforced
   by the test driver. The FIFO RED says killed-and-waited but lacks a raw timeout
   process receipt; do not overclaim its one-second provenance.
4. Real OPAE destructor/partial-initialization/finalization behavior remains
   source-derived, not dynamically qualified. No resource-lifetime/recovery proof.
5. Crucially, real pluginmgr initialization rereads the config and calls the
   **default-returning wrapper**. Sealing prevents input replacement, not later
   read/allocation/parser failure. Launcher validation is not proof of fail-closed
   real runtime initialization. This is a blocker to broader runtime acceptance,
   not to the bounded inert candidate.
6. Module/dependency/namespace/preload identity and real device isolation remain
   external prerequisites. Missing-entry detection happens after constructors.
   The inherited SDK build-context/empty-element RUNPATH issue remains open.

These limits require no unchanged matrix rerun. Original scalar/memory/core/config
sources remain preserved. The separately completed target01 compile/link has its
own pending independent review; this acceptance does not absorb it or claim target
runtime execution. No installed launcher, OPAE/backend loading, hardware access,
physical DDR/DMA, numerical AHLS, lifecycle/full-signoff or boot acceptance.
Vendor DDR simulation remains SKIPPED BY USER.
