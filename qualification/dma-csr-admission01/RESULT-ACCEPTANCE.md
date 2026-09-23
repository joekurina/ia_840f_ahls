# Parent acceptance — bounded DMA CSR admission

**ACCEPT_SOURCE_AND_NATIVE_ADMISSION_WITH_FINDINGS.** Consumed FINAL independent specification/quality PASS_WITH_NONBLOCKING_FINDINGS, reportSHA256 `11aca920d44f875204431244c6a69a546803ef72436c5e79b764400e033e2970`. [Review](independent-review01.md), [parent verification](parent-review-verification02.json), [scope](SCOPE.md), [native results](RESULTS03.md). Predecessor routing acceptance is published as `f9a860d86168d6b468eb4f4bcee35baccf79e45a`; it is not still pending as the old checkpoint stated.

Parent reverified all28 frozen package entries,125 decoded source payloads, dispatch/script and outer/result hashes, every native log length/hash, preserved originals/inputs/tools and empty final owned groups. The authoritative final red02/green03 pair differs only in CSR RTL. Old CSR accepts high alias0x128 incorrectly; corrected candidate rejects it. Declaration-order and stale-W fixture failures remain preserved; none was relabeled passing.

Guard result:56 checked transactions,32 rejected writes,4 rejected reads,20 rejected GO commands,20 queue admissions. The latter includes17 actual queue entries plus3 boundary-only admissions, not20 completed copies. Eight later good descriptors perform3397 checked transport and3397 checked destination-model copyback beats,19AR/AW/B each. Actual CSR log204writes/31reads supersedes partial helper totals152/27. Green native/effective/outer0, simulator0errors/11warnings; compile8warnings. No warning-clean claim.

**F1 retained:** successful/failed-GO freshness consumption, malformed-access freshness preservation, individual sticky-error/control predicates, and later drain of queued descriptors are not independently isolated dynamic proofs. Source checks support this bounded admission contract, not broader runtime behavior. No unchanged rerun required.

**F2 retained:** this runner's guard acceptance floor requires positive counts, not exact frozen totals. Parent and reviewer reconciled those exact totals here. Bind explicit expected guard counts and reconcile all transaction counters in a future changed fixture; do not rewrite consumed tests/results.

The130816-beat bound is source-derived/admission-tested only. Received16-bit CSR validation does not close upstream20-bit aliasing. Internal DECERR/SLVERR does not establish CPU-visible posted-write failure. Host buffer extents, readable admission/error status, active control safety, complete PIM/fabric/clock/reset/ID/USER behavior, global drain/fencing/physical visibility, maximum/boundary transfers and actual hardware remain unqualified. Admission-only requests reset by the fixture are not a hardware cancellation/recovery protocol.

No device/MMIO/programming/driver/reboot operation. DDR vendor simulation **SKIPPED BY USER**. This acceptance closes only this source/native-unit gate, not the standing hardware goal.
