# Accepted Work24 matching PR/PIM export

[Acceptance39](EXPORT-ACCEPTANCE39.md) is the authoritative scope: matching Quartus26.1.1 release-only export for offline fabric/simulation/persona preparation, not persona or hardware qualification. Independent native-result and PIM/QIP reviews are consumed in [record38](result-reviews-consumed38.json). [Routing disposition37](ROUTING-DISPOSITION37.md) distinguishes PF1/non-VF BMC from the PF0/VF0 AFU.

The native export completed with zero CMake/vendor-target status. Raw supervisor/outer1 and `execution_clean=false` remain preserved for exactly two copied-DNI bookkeeping changes, independently classified in the acceptance. This publication does not turn those raw statuses into a clean execution receipt or authorize a rerun.

## Evidence policy

The explicit `publication-manifest40.json` defines the curated path set, sizes and SHA256 values. Maximum tracked member size is **2,000,000 bytes**. Raw transport archives, embedded source payloads, installed Tcl/vendor source, generated PIM/RTL/IP bodies, full large reports, native databases and programming images remain local and hash-referenced by the frozen inventories/reviews. A small file or text extension does not override content classification. Mutable `CURRENT.md`, live preparation of the next fabric stage and raw agent transcripts are not acceptance-commit inputs.

Selected native result metadata and gate events are retained byte-for-byte. Unpublished capture paths in report links intentionally refer to the local evidence workspace. SHA manifests preserve their identities; a clean checkout cannot recreate the native build workspace, licensed installation, static QDB or programming images from this milestone alone. Do not execute the historical runners/claims as a clean-clone recipe or reusable authority.

The accepted static interface is `fc603c44-5c8f-5e94-bcbe-a5780030947c`, retaining PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc`. Full implementation and every migrated card-bound gate remain separate. `main` and release `ia840f-caps03-v1.1.0` remain the preserved fallback.
