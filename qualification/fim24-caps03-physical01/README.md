# Accepted migrated CAPS03 first FIT stage

[FIT-ACCEPTANCE38.md](FIT-ACCEPTANCE38.md) accepts the one completed Quartus Pro26.1.1 fitter stage, its native-reported static/root/PR preservation and recorded source integrity. Independent result and diagnostic/reset reviews are bound by [consumption37](result-reviews-consumed37.json).

This milestone is **not multi-corner timing, reset-entry, electrical, assembly or hardware acceptance**. Native/CMake/effective/outer statuses were zero; all13 capture preservation checks passed. The root is reported final-preserved from the selected static QDB, with green_region Reconfigurable. Retain unused-PR-input, constraint/ignored-assignment and electrical findings, including three additional sys-clock reset cycles and seven bank0 cycles. The prior unit-simulation limits remain.

## Publication policy

`publication-manifest39.json` is the exact path/size/SHA256 allowlist; each member is at most **2,000,000 bytes**. Only authored controls/tests, reviewed prose, bounded diagnostic extracts and payload-free metadata are published. Raw native reports/log bodies, vendor/generated sources, compiled databases/images, payload-bearing transport archives, oversized inventories, raw agent transcripts, mutable handoffs and unfinished STA preparation stay local and are hash-referenced.

`native-result-metadata39.json` preserves every field of the actual result, whose logs/databases are represented by metadata rather than raw bodies. `input-output-role-summary39.json` removes only four complete path maps from roles05, retaining their raw file size/SHA and all other fields; it is a summary, not a split payload or executable replacement. `reused-report-bindings31.json` identifies five unchanged predecessor synthesis/DRC reports; they are not newly executed FIT DRC. Finalize Design Assistant did not run because no rule was enabled.

Historical controls, issued admission and completed fit are spent evidence, not reusable authority. Local-only links in reviews are intentional. A clean checkout does not supply licensed tools, retained native workspaces, databases or deployable images. Current STA preparation is separate and unpublished here. Only the migration branch receives this gate; main and released CAPS03 fallback remain protected.
