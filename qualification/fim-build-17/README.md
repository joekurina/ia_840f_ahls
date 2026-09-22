# Work17 snapshot-enabled native build evidence

[Result acceptance](RESULT-ACCEPTANCE.md) is authoritative for this milestone: native execution and failed-timing evidence accepted, **timing FAIL / hardware NOT QUALIFIED**. [Independent review](result-independent-review01.md) and [parent consumption](parent-result-consumption01.json) bind the exact sources, archive exports and claim limits. `RESULT.md` is the immutable pre-review account.

The sole new configuration assignment enables intermediate fitter snapshots in the copied completed Work16 QSF. Existing original signoff, Fitter-only10ps overlay, seed2, clocks, both16GiB DDR channels and PR/PIM are retained. Retargeted gates are execution provenance, not functional corrections. Both full compile and original authorization are spent.

## Payload policy

Individual tracked files are capped at2,000,000bytes. Large decoded reports and the native log remain local, losslessly recoverable from bounded preparation/completion/reports/postflight02 gzip JSON archives. Manifests include per-file sizes and SHA256. Preparation uses base64/bytes; completion and reports use per-file gzip_base64/size; completion keys map absolute remote paths to local evidence/project. Postflight02 contains four stage reports plus full SOURCE/PIM/Work17 inventories. Its oversized Plan/Place decoded reports are explicitly ignored. Remote programming images and QDB payloads are hash-inventoried, not uploaded or hardware-qualified. No secrets, license contents or licensed runtime binaries are included.

`result-review-freeze01.json` binds all106 reviewed local files, including ignored decoded payloads. Keep raw whitespace/line endings unchanged. Collector01's failed size-bound acquisition is preserved beside successor02; no native build retry occurred.

The separately executed snapshot-compare01 diagnostic is **outside this build milestone** and awaits its own result review/acceptance/publication. Current local orchestration is in CURRENT.md; no later-state handoff retroactively changes the frozen evidence.
