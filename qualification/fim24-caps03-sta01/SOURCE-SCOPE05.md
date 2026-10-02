# Final-snapshot STA — SOURCE/API preparation

The actual FIT stage is accepted with findings in [acceptance38](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md), not timing or hardware acceptance. This package prepares one separately owned **state-changing** final-snapshot multicorner STA operation. No native timing or authority exists yet.

## Actual copy and narrow proposed delta

[Copy01](copy01-readback/prepared-copy01.json) contains4025 entries/945,375,763bytes from the completed fit. All729 fitted-QDB members, static QDB, original fitted/mapped/setup/release/external/archive inputs and tools were verified before/after copying. Two internal relative symlinks naturally resolve into the new copy; text and target bytes are unchanged. No database, clock, source or constraint was rewritten.

The candidate changes only the two QSF references to future `build_gate_sta06.tcl`/`ia840f_sta_gate06.py`, adding those gates while retaining the old files. All other QSF/settings—including NUM36/seed1/PR_IMPL/static import—and every functional/SDC/header byte stay unchanged. The actual copy still selects the spent fitter gate; do not open it before fresh controls/review/admission. [Delta03](qsf-delta03.patch).

## STA-specific input/output roles

[Roles02](input-output-roles02.json) binds3999 immutable entries and26 exact existing runtime-output entries:two shared report files,12 report databases,11 timing/retiming caches and`legacy/1/runlog.db`. All fitted/mapped snapshots and source payloads, QPF and the other existing reports remain immutable; a280-member final-physical/static subset is explicitly identified. Adding two gates would yield4027 active/4001 critical entries. No FIT863-entry exclusion list is reused.

The first local proposal comparison selected fitter.qmsgdb instead of runlog.db; it failed before any write/native operation. [Derivation02](role-derivation02.json) preserves that correction. The final exact current path set corresponds to the historical STA role set after explicit version-component mapping; current hashes, not historical data or authority, are bound. `ofs_pr_afu.fit.qmsgdb` remains immutable. Newly generated STA reports/frequency output are distinct outputs, not exemptions of source data.

## Command and helper contract

Candidate03 CMake exposes only version/timing and rejects wrong tool/project paths. Exact command:

`quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer`

Current26.1.1 version/help/option evidence is reused from [physical help01](../fim24-caps03-physical01/help01-readback/sta_help.log) and [help02](../fim24-caps03-physical01/help02-readback/sta_snapshot.log); binary bindings were reverified during copy. Do not add fitter-only read/write-settings flags absent from STA help. Six exact CMake configure/help/dry-run/refusal checks passed without a vendor invocation or input change. [Receipt04](cmake-inert04.json).

The unchanged QSF TIMING_ANALYZER_REPORT_SCRIPT invokes user-clock computation then the OFS timing reporter. It can recreate `user_clock_freq.txt`, reread SDC/update timing and replace`timing_report`; it is not a read-only query. The existing JSON auto200/100 requests stay immutable, distinct from the application's bank0-memory clock and required3.000ns. PIM JSON/clock helpers are unchanged hash-bound members, with captured bodies in the predecessor package. `--do_report_timing` provides one critical setup path per destination clock, not exhaustive coverage. [Clock-stage07](../fim24-caps03-physical01/clock-stage-review07.md).

The generated frequency output is absent initially. Its values must be observed rather than assumed; missing-clock/slack10000MHz fallbacks must not be presented as achieved timing. No assembly/GBS hook is authorized. Keep all36 logical CPUs allowed/NUM36 requested and64GiB per-process; future configure/version/timing deadlines60/60/1800s and32MiB polled logs. The fitter's actual up-to24-worker warning is recorded separately; no guarantee of36 internal STA workers is made.

## Result/coverage obligations

Preservation and native zero are execution evidence only. Capture complete STA summary/main report, signoff DRC, clocks and OFS pass/fail summaries plus computed frequencies. Parse full supported numerical records without substring matching, reject malformed/nonfinite data, negative slack or nonzero TNS; an empty failure file alone is insufficient. Full acceptance remains independent and must establish real3.000ns application propagation, all-corner setup/hold/recovery/removal/MPW, current PIM CDC/synchronizers/pointer skew/net-delay, effective exceptions/overwrites and unconstrained coverage.

Retain the FIT review's139 constraint diagnostics,1098 ignored assignments including16 current fabric reset synchronizer rows, unused PR ports, four electrical omissions, and extra reset cycles3sys/7bank0. Source connectivity, retimer labels and device models “Final” do not close them. [Diagnostic/reset35](../fim24-caps03-physical01/fit-diagnostic-reset-review35.md).

**Next:** SOURCE/API review, then fresh runtime implementation/tests/QUALITY, exact issuance/readback/preflight and one timing run. No fitting or synthesis repeats; no timing, electrical, assembly or hardware acceptance is asserted here.
