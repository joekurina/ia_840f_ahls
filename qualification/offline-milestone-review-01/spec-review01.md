# Independent spec review 01 — completed, changes requested

Reviewer: delegation `deleg_59242896`, completed after 324.05 seconds.
This is the full review delivered to the parent after the abbreviated local
transcript was recovered. It applies to the earlier candidate/document state,
not successor02 or the subsequently written reports.

**GAPS — AHLS offline host logic passes review; the udev candidate and handoff evidence need corrections.**

## Concrete gaps

- **Udev matching is broader than the stated IA840F scope.**
  `qualification/dfl-udev-fix-01/90-intel-fpga-opencl.rules.candidate:4–5`
  matches every `8086:bcce` DFL parent. The captured
  `dfl-pci.c:85–90,114–127` identifies that device ID with several boards,
  including N6000/N6001/D5005. A read-only invocation of the inert evaluator
  confirmed an N6000-ID parent receives `root:uwb_student00 0660`. Narrow the
  approved parent identity, or obtain an explicit broader-scope decision;
  add a same-vendor/device, wrong-board fixture.
- **Required-node failure reporting exists only in the fixture.**
  `test_rule.py:25–28,38–39` invents the `FileNotFoundError` check; the candidate
  rule contains no corresponding validation. This is a test/acceptance-coverage
  gap, not evidence that native udev rejects a missing required node. Supply
  a separate acceptance check/procedure, or explicitly leave this requirement
  unverified.
- **Handoff documentation is incomplete at inspection.** The report referenced
  by `src/host/ahls_opae_qualification.c:3` does not exist; neither UART nor udev
  evidence directory contains a report. `docs/feature-matrix.md` still describes
  the earlier source-only state. Record independent dispositions, candidate
  rollback, source/evidence bindings, and live blockers before final handoff.

## Passed review

- Host accesses are aligned and match the generated CSR layout.
- Completion handling correctly drains the two-bit clear-on-read counter,
  verifies zero, and requires exactly one fresh completion before reading results.
- Reference arithmetic matches the original eight signed-32-bit products/XOR,
  rejects overflowing inputs, and checks the entire zero-padded result.
  Independent integer recomputation matched all supplied expected values.
- Enumeration rejects zero/multiple matches and API failures; no raw-BAR
  fallback or retry/reset path was added.
- `ahls_mmio_test.c` has no staged or working-tree changes.
- Retained receipts show CTest 2/2, UART model 12/12, and udev subset model
  12/12 passing. These are offline results only.

## Declared blockers, not new host-code defects

- UART diagnosis is supported: disabled UART still advertises dummy DFHv0
  feature 0x24; a scope decision is required, not an invented clock or
  unapproved enable/disable patch.
- OPAE backend/routing/cleanup closure and authorization remain prerequisites
  to live use.
- Native udev validation, installation, activation, and actual permission
  verification remain unperformed.

Reviewer reported: no files modified, no git writes, and no hardware or remote
access performed. Parent retained source evidence and an inert test receipt;
review is independent assessment, not live qualification.
