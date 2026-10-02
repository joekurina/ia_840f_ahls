# Migrated CAPS03 — accepted final-STA numerical milestone

This directory publishes the **completed execution, acquisition and numerical 3.000 ns STA result**, accepted with findings. It does **not** claim endpoint-complete timing/CDC signoff, clean Design Assistant, reset-entry/electrical acceptance, assembly or hardware qualification. [Acceptance32](NUMERICAL-ACCEPTANCE32.md), [result26](RESULT26.md), [independent integrity28](native-result-review28.md), [coverage29](timing-coverage-review29.md), [diagnostic/reset30](diagnostic-reset-review30.md).

## Verified result

- One final-snapshot multicorner Timing Analyzer operation under Quartus26.1.1 Build130. CMake/effective/outer statuses are zero; native zero is propagated through the direct CMake vendor targets. No refit or resynthesis occurred.
- The99.430144-second recorded interval includes configure/version/postflight. Exact live native identity/callback and completion witnesses are retained in metadata; no owned native process remained at acquisition.
-923 native summary records and635 overlapping per-corner hook records pass complete-record numerical screening. Minimum setup is0.002ns; hold/MPW minima include0.000ns, which is not positive margin. The actual application period remains3.000ns; user-clock100/200MHz analysis is separate.
-54 readbacks/70,744,266bytes and15 preservation checks pass. Original STA inputs, fitted/mapped/static and external/setup/release/tool evidence remain bound. Every native authority in this package is spent.

[Structured verification25](native-result-verification25.json), [capture index24](completion-index24.json), [raw-result metadata](native-result-metadata35.json), [live observation](live-observation-metadata35.json).

## Explicitly open

The two generic PIM net-delay selectors still need endpoint membership and effective exception-precedence evidence for the current40 directed pointer bundles/20 FIFOs. Reset entry must be bound to the actual supported operation and include three additional sys/seven additional bank0 cycles. Four named electrical findings remain. Signoff DRC23/88 failed rules and379 warnings are preserved, not waived. Offline assembly preparation is distinct from native assembly or deployment authority. [Coverage29](timing-coverage-review29.md#L51-L57), [diagnostic/reset30](diagnostic-reset-review30.md#L35-L45).

## Publication and reproducibility policy

Only the exact accepted path allowlist in [manifest35](publication-manifest35.json) is published. **No member may exceed2,000,000 bytes.** The local `.gitignore` excludes every other artifact by default. Raw vendor/generated source captures, complete native logs/reports, QDB/databases/images, transport archives and embedded-payload launchers stay local regardless of size. Tool binaries/installers, license values, credentials and internal agent transcripts are never included. Mutable `CURRENT.md`, active successor preparation and pending reset/electrical research are deliberately excluded.

The actual local corpus is under this qualification directory and the preserved remote root `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01`; exact original paths/sizes/SHA256 are retained in the freezes and capture index. A citation to a raw readback can therefore refer to a **local-only file absent from a clean clone**. Metadata projections retain their source digest, omitted-field counts/canonical digests and all unomitted values; their reconstruction was verified against the original. [Projection verification35](projection-verification35.json), [admission metadata](admission-metadata35.json), [prepared-input metadata](prepared-inputs-metadata35.json), [admitted-input metadata](admitted-inputs-metadata35.json), [role summary](input-output-role-summary35.json).

Published Python/Tcl/CMake files are historical tested controls and evidence of the consumed operation, **not executable replacements for omitted manifests/workspaces** and not a clean-checkout FPGA build recipe. Some inert tests require retained local fixtures. Do not rerun a spent issuer/native operation or infer readiness from the presence of its script.

Hash-bound reports, reviews and diff evidence remain byte-for-byte intact. Any preserved unified-diff context whitespace is handled by exact path/hash/line dispositions in the publication receipt, not normalized or broadly exempted. The accepted FIT predecessor, `main`, released CAPS03 fallback and unrelated tracked edits are preserved.
