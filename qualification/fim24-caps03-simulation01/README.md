# Accepted migrated CAPS03 integrated unit simulation

[SIMULATION-ACCEPTANCE37.md](SIMULATION-ACCEPTANCE37.md) accepts the one completed Questa2024.3 integrated-memory/page-split unit run against26.1.1-generated fabric and matching Work24/PIM/application configuration. Both independent actual-result and new-warning reviews are bound by [consumption36](result-reviews-consumed36.json).

All native/effective/outer outcomes are zero. Exact records verify six numerical cases,133 integers,1600 copied bytes,30 DMA descriptors,402461 checks,bank1 reset invalidation and intermediate split-error observation. All preservation checks pass. Two identical-body module overwrites and eight scalar-zero narrowing diagnostics are nonblocking only for this frozen configuration; inherited diagnostic counts are not blanket waivers.

Explicitly excluded: full PCIe mapper/AFUtop/pr_slot,physical DDR,timing/hardware,bank0 crossing reads,native BREADY backpressure,stopped-clock/active-reset recovery andbank0 read-error telemetry. Direct-list simulation does not validate the separate future Quartus compatibility-link adaptation. Persona implementation and migrated real-card gates remain open.

## Publication policy

`publication-manifest38.json` is the exact path/size/SHA256 allowlist; every member is at most **2,000,000 bytes**. Installed/generated sources, module bodies, copied input trees, compiled libraries/databases, source-bearing/compressed transports and raw console bodies remain local. Publish only reviewed prose, authored controls/tests and payload-free metadata. Mutable checkpoints, unfinished persona implementation and raw agent transcripts are excluded.

`native-result-metadata38.json` removes only raw log text from the immutable native result, retaining exact log sizes/hashes and every other field. `duplicate-module-metadata38.json` similarly removes only generated module bodies. These are metadata projections, not executable replacement artifacts. Raw logs/source bytes remain hash-bound by `actual-result-freeze33.json`; local-only report links are intentional. `diagnostic-locations36.json` supersedes incorrect one-too-high locations in verification29 without changing its frozen bytes or any count/outcome.

Historical runners, rejected parser records and spent admission are evidence, not reusable execution authority. A clean checkout lacks the licensed tools and retained native inputs; no clean-clone buildability or deployability is implied. The migration branch alone receives this gate; main and the released CAPS03 fallback remain protected.
