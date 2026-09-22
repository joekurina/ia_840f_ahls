# Independent actual-result review — Plan diagnostic01

**Finding: failed, parent-stopped execution; no hold-objective or timing acceptance.** This retrospective evidence review is not a source SPEC/QUALITY review or a launch-approval gate. Successor02 was not reviewed.

## Evidence identity

Independently verified all 15 preparation exports and all 7 result exports: exact filenames, decoded bytes, sizes and SHA256 agree between `preparation02.json.gz` / `result01.json.gz`, their manifests and corresponding readback directories. The prepared candidate hashes to `e8c5c6e0c2a198aa7fd620ecbfc110b050aaffedd6d317ab411b964aa13eb63f`. `status01.json` binds that candidate to issued authorization `c0b5ad57203eb7f4ae18f620cda4ccd9dba5ead78ba006e20388d2fc7c81d538`; that authorization identity is recorded evidence, not an independently rehashed raw authorization export.

## Termination verified from captured evidence

`result-readback01/native-process.json` identifies the actual `quartus_fit --plan --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top` invocation. `native-result.json` records 2026-09-22 **19:46:15.331956–19:48:10.257535 UTC**, native return **−15**, termination confirmed, no final live PIDs and no supervision errors. `execution-status.json` records effective return **143** and `timing_accepted: false`.

The saved process stat in `status01.json` independently matches PID **36100**, start ticks **6964709**, and parent runner PID **36061**. `parent-stop-request01.json` records a successful **pidfd SIGTERM to that exact owned Fitter**, leaving descendant drainage to its existing supervisor—not a broad kill. Its explicit stop reason explains the supervisor's null `abort_reason`; null does not mean normal completion. `query.log:78` corroborates supervision, and the later `drift01.json` audit at 19:48:56 UTC records no native tools. These are historical termination observations, not a new live-process check.

## Preservation

`prepared-readback02/preservation.json.gz` inventories maintained SOURCE, PIM and original Work15 (1,657 / 536 / 7,346 entries). All three roots have true comparison results in `result-readback01/preservation-after.json`, repeated identically in `drift01.json`. This supports preservation of those originals, not byte preservation of the interrupted scratch. The export contains baseline inventories and comparison outcomes, not full post-run original-tree inventories; no independent remote rehash was performed.

## Runtime-output misclassification

`query.log:1–23` records rejection because `qdb/_compiler/ofs_top/_flat/26.1.1/legacy/1/ofs_top.fit.qmsgdb` was absent during QSF validation. Quartus demoted the Tcl failure to **Critical Warning 125091** and continued: lines 49–66 show synthesized-database loading and successful loading. The Tcl rejection therefore did not itself terminate native execution.

Recounting `drift01.json` gives **561** changed/deleted entries: **8 modified, 553 deleted**. Stage totals are `_all` 4, `final` 197, `legacy` 4, `placed` 118, `planned` 2, `retimed` 118 and `routed` 118. Every recorded before-hash matches both candidate prelaunch and callback inventories. None of these recorded changes is in synthesized, partitioned or source stages. The rejected message database subsequently existed with a different hash: its initial absence and later recreation are consistent, not conflicting evidence.

This establishes that mutable copied Fitter outputs were incorrectly required to remain immutable at runtime. It does not justify discarding all QDB or prelaunch input bindings.

## Objective evidence absent

The complete exported log has zero `EMIF1_HOLD_ISSUED` or diagnostic callback markers; `report-manifest.json` is empty. Execution status explicitly reports missing exact hold-setter diagnostics and native Fitter success. Native analysis is incomplete: neither the requested hold objective, its effective value/application, nor timing improvement or closure was demonstrated. Missing observations must not be interpreted as a zero objective or proof that the setter never executes. Preserve this spent attempt as failed execution evidence; it supplies a runtime-inventory correction diagnosis, not a timing waiver or successor approval.
