# Work21: completed Quartus 25.1 FIM milestone

[Parent acceptance](RESULT-ACCEPTANCE.md) closes the exact historical EMIF1 hold failure and accepts fit, assembly and reported constrained numerical STA with findings. [Current status](CURRENT.md), [independent final review](final-review01.md) and [parent checks](parent-final-verification01.json) retain the coverage, PR, electrical and hardware holds. Neither the scalar AFU nor this build proves the future memory AFU functional.

## Evidence policy

The per-file publication cap is **2,000,000 bytes**. Known oversized files are excluded by `.gitignore`; full report/transfer archives and warning-source payloads remain local and SHA256-referenced. No bitstreams, license bytes, installers, licensed runtime binaries or private agent transcripts are published. Small native reports retain original whitespace/bytes; [selected excerpts](final-evidence-excerpts01.json) preserve native line ranges and per-excerpt/full-source hashes.

- Final native set: [19-member manifest](final-capture01/manifest.json); archive SHA256 `33a796362be5d2ec098d66993dc3cc519f6bdffe76f844a3329a17cbf74fbb4c` (6,701,978 bytes).
- Synthesis native set: [manifest](synthesis-capture01/manifest.json); raw oversized reports remain under `synthesis-capture01/`.
- Referenced source provenance: [warning-source manifest](warning-source-capture01/manifest.json); 28 precompile-bound identities and 18 current-only identities remain distinct.
- Prepared input provenance: `prepared-readback01/compile-candidate-01/compile-authorization.draft.json` binds the copied inputs. It is a preserved draft/input inventory, **not new authority**. Native authorization was consumed; do not rerun any launcher from these historical records.

The source-bound preparation/capture scripts and retained review dispositions document this build, not a hardware runbook. Images are identified by the remote inventory; their bytes were not locally independently rehashed for this acceptance. A base green RBF is not a qualified persona GBS. DDR simulation remains **SKIPPED BY USER**.
