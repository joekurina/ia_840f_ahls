# Acceptance155 — mailbox126 local functional milestone

**Accepted gate: staged mailbox126 local RTL functionality, only.** The independent [source/spec review129](SOURCE-REVIEW129.md) was consumed in [record131](review-consumed131.json); the completed run's independent [functional/test-quality review132](RESULT-REVIEW132.md) was consumed in [record140](review-consumed140.json). Neither review requires a correction or rerun within this gate. Historical pending-review fields remain unchanged in the original reports and receipts.

The actual [run127 summary](run127/summary.json), [result130](RESULT130.md), and [verification130](verification130.json) establish five successful positive runs: **51 executed cases and 1522 executed checks**. All three labeled synthetic RTL mutants compiled successfully and exited nonzero at their intended live assertions. These are fixture counts, not counts of distinct specifications. The focused fixture's 447 checks describe the retained Icarus trace, not a cross-simulator instrumentation-count guarantee; review132 records the final idle-check scheduling caveat.

The additive [mailbox126 RTL](../../afu/ahls_memory/control/ia840f_ahls_observer_mailbox_timing126.sv) stages payload before request/ACK publication and inhibits source completion while notification is pending. The maintained original is not replaced. The [source delta](mailbox126.diff), [design126](DESIGN126.md), [selector-only fixture](tb_mailbox_timing127.sv), and [focused fixture](tb_staging127.sv) retain the exact reviewed implementation and tests. The timing46 observer and timing56 fixture/reference receipts are included as dependencies of this test, not as another newly closed gate.

## Publication scope

[PUBLICATION155.json](PUBLICATION155.json) enumerates the exact publishable files with sizes and SHA256 values, plus local-only compiled artifacts and external tool bindings. The publication manifest itself is audited as an additional Git blob rather than attempting a recursive self-hash. Authored sources, finite test sources, compact JSON/log evidence, and review/consumption records are included. No tests or native build are rerun for publication.

Compiled `test.vvp` files remain local-only under [the scoped exclusion](.gitignore); their exact hashes are retained in the manifest and individual results. Icarus/compiler/backend binaries are external prerequisites bound by [inputs.json](run127/inputs.json) and [PROVISION.json](../caps02-afu-publication09/simulator-tools50/PROVISION.json), not repository deliverables. Clock-analysis references in historical reports remain separate evidence; including clock review128 preserves the provenance of record131 and does not certify its physical model. No licensed tools, embedded launch payloads, secrets, active build inputs or mutable progress checkpoint are included in this milestone.

## Boundaries that remain open

This acceptance does **not** cover physical CDC, metastability/aperture, fitted clock or bundle margin, reset/RDC/MTBF, effective per-register preservation, final timing, DDR, PCIe/OPAE, buffer lifetime, drain/teardown or hardware numerical behavior. Integrated simulation133, synthesis141 and diagnostic fit152 are separate stages and are not accepted by this document. `PUBLISH_SUPPORTED=0` and the original production selection remain unchanged.

The parent rechecked the retained source/review/input/output hashes for publication. This is a preservation check, not a new simulation or hardware result. The overall IA-840F hardware goal remains incomplete.
