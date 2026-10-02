# Migrated integrated-memory unit simulation — accepted with findings

Accept the one completed Questa2024.3 run of the26.1.1-generated fabric and matching Work24/PIM/application configuration. Both independent [behavior/result34](native-result-review34.md) and [warning35](warning-result-review35.md) reviews are consumed, with669 frozen members reverified. [Parent consumption36](result-reviews-consumed36.json), [actual result32](RESULT32.md).

Configure and six direct simulator targets have CMake/effective0; native0 propagates through the six simulator targets, not configure. Outer0, exact whole-record scoreboards and all seven preservation domains pass. Actual results: six cases,133 integers,1600 copied bytes,30 DMA descriptors,402461 checks,1010 MMIO reads,161 MMIO writes,40/56 bank write observations; one reset-invalidation and one intermediate split-error record. No error/fatal diagnostics, model edits, suppression or unchanged rerun.

Retain38/269/0 warnings. The ten new occurrences are nonblocking only in this frozen configuration: two module overwrites replace identical bodies in the retained flat-work recipe; eight warned scalar inputs receive value-preserving narrowed zero literals. The partial plaintext-library region does not establish all precompiled/encrypted internals. Same ID counts do not blanket-clear inherited diagnostics. [Warning review35](warning-result-review35.md).

Verification29 used one-too-high diagnostic/summary citation numbers. [Locations36](diagnostic-locations36.json) corrects every affected warning row and the three summary rows to actual native lines868/1289/62, without changing frozen evidence, messages, counts, markers or outcomes.

This accepts only retained unit coverage. Explicitly excluded: full PCIe mapper/AFUtop/pr_slot, physical DDR/timing/hardware, bank0 crossing reads, native BREADY backpressure (both bank B-hold counts zero), stopped-clock/active-reset recovery and bank0 read-error telemetry. Intermediate split-error coverage comes from the separate fault test, not a numerical HLS case. The future Quartus compatibility link is not validated by direct-list simulation.

Advance fresh matching persona compile preparation under the unchanged board/timing/protocol contract. Preserve this completed simulation, original setup/static release/fabric and all spent claims. Hardware deployment and real-card qualification remain separate; the migration is not complete.
