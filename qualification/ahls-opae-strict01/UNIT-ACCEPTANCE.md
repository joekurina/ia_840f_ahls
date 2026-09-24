# Parent acceptance — strict initialization source and inert tests

**ACCEPT WITH FINDINGS, source and finite inert evidence only.** The complete
[FINAL review](independent-review01.md) was read; its returned SHA256
`b6dd9b161f06ce21ffda57de722eaae7c2feed550339e04e4f41648e8b81c446`
and all 120 frozen files / 1,627,145 bytes matched. The parent independently
reconstructed the exact 39-case set from the driver AST and 21 bound fixtures,
parsed recorded RESULT lines, checked every category/retry predicate and command
log hash, and retained the original semantic RED and GREEN01 compile failure.
No test was rerun. [Verification](parent-review-verification01.json).

Accept the opt-in fragment/header and sibling entry, beside unchanged originals:
config failure cannot select compiled defaults through this private path;
nonmatching effective tables fail before discovery; missing adapters fail;
repeat attempts through the private function are rejected. The actual SDK manager
and parser were exercised only with explicit inert IO/loader/adapter boundaries.
[Scope](SCOPE.md), [results](RESULTS01.md),
[implementation](../../src/host/opae/ia840f_strict_init.inc).

Retain every review limitation:
- Exactness concerns the effective two-row parsed table, not raw JSON/schema or
  unique ELF/BDF identity. The legacy API remains callable and unchanged.
- The sealed stable regular-file snapshot is a caller precondition. Unit config
  IO is replaced. The inherited reader's unchecked seek/short-read loop is a
  source-derived limitation, not a reproduced failure of a sealed snapshot.
- Existing loader prefix searches, transitive RUNPATHs, constructor timing and
  real startup/module selection are not tested by this unit gate.
- Failed initialization may retain adapter state. No forced unload, retry,
  reset, cancellation or recovery is authorized. Latch persistence after
  finalization is source-inspected, not exercised here.
- Coverage excludes the specific allocation/state/concurrency/sysfs cases
  listed in the review. The frozen case set is parent-verified; future matrix
  expansion should pin names/counts internally rather than relying on globbing.
- RESULTS01.md's ELF-inspection wording is interpreted per execution batch,
  not as a separate inspection before each of the 39 processes.

The separately reviewed target build is a distinct gate. No actual library or
backend startup, hardware safety, DFL/MMIO, DDR/DMA, numerical AHLS, full design
closure, lifecycle or boot is accepted. Vendor DDR simulation: SKIPPED BY USER.
Frozen earlier pending wording is superseded by this additive acceptance.
