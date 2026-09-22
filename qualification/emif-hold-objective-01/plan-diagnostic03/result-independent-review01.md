# Plan diagnostic03 — independent actual-result review

**Finding: native Plan completed successfully; effective hold-objective acquisition failed.** The setter evidence is usable within its narrow scope. Neither rc0 nor `errors: []` establishes the missing effective uncertainty or timing closure.

## Evidence integrity

Independently decoded `preparation02.json.gz` and `result01.json.gz`; verified exact export-key sets, decoded lengths, SHA256 values, and byte equality with their respective manifests and readback directories: **16/16 prepared exports and 7/7 result exports match**.

Archive SHA256:
- Preparation: `cdc66ce9098a218b0f75552c1342db81d9f4657490579429d85ebe4cc613140f`
- Result: `527410be5be54531d31ecac29766c0e96b0a35191c0fb08b85fbcf49d21fc0f3`

The preparation hash matches `parent-preparation02.json`. Prepared candidate hash matches issuance in `status02.json`; all five overlapping result JSON records match that snapshot by hash and decoded content. Removing the single exact `insertion.tcl` block from prepared `instrumented.sdc` recovers the pre-insertion hash in `diagnostic-delta.json`. This verifies the diagnostic-only SDC insertion, not a source-approval gate.

## Completion and preservation

`native-process.json` records PID38962 executing Quartus 26.1.1 `quartus_fit --plan --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top` in diagnostic03 scratch. `native-result.json` records 2026-09-22T20:11:40.913989–20:21:31.653369UTC, native rc0, no abort, termination confirmed, empty live-PID list and no supervision errors. `execution-status.json` independently records native/effective rc0 and `timing_accepted: false`. `query.log:724–734` corroborates planned-database commit, successful Fitter completion, **0 errors/206 warnings**, and termination; line630 reports **81 clocks**. Outer rc0 is recorded by `RESULT.md`, but no separate outer-exit receipt is among the seven exports.

`status02.json` at 20:26:16.685383UTC records no matching processes; this is captured termination evidence, not a present-time remote inspection. `preservation-after.json` reports true comparisons for Work15, SOURCE (`ofs-agx7-pcie-attach`) and PIM (`ofs-platform-afu-bbb`). The prepared runner compares file hashes/link targets against `preservation.json.gz` (`run-query.py:11–22,340–348`). Full postrun inventories were not exported, so their equality cannot be independently recomputed here.

Original Work15 source-location metadata appears at `query.log:91–94`; lines619–626 explicitly read original Work15 database proxy SDCs. Retained database metadata/read dependencies are not evidence of source drift or writes, but prevent claiming a hermetic scratch sandbox.

## Setter evidence versus acquisition failure

`query.log:374,721` contains two identical records for EMIF1 `emif_1_core_usr_clk` → `emif_1_phy_clk_l_0`: `phy_index 0`, `same_tile_index 0`, `add_mode -add`, `C2P_HOLD_OC_NS 0.000`, `issued_ns 0.0`, `from_count 1`, `to_count 1`. Prepared `instrumented.sdc:983–1006` places this diagnostic immediately after the same-tile `set_clock_uncertainty` hold setter: **`-hold -add 0.0`**. The displayed multi-tile base `0.366` is not this branch's issued value. Neither number proves total effective uncertainty; the same-tile branch relies on derived uncertainty. Two observations do not establish all-corner/path coverage.

Both callback registrations return **rc1** (`query.log:375,722`): underlying `delete_timing_netlist` is unsupported in `quartus_fit`, supported only in `quartus_sta`. The inline helper catches the failure; Plan continues. There are zero callback-entry/result markers and `report-manifest.json` is `{}`. The runner permits zero reports and its error regex misses this caught uppercase `ERROR:` (`run-query.py:351–363`), explaining rc0/`errors: []` without successful acquisition.

## Limits

The 206 warnings, including ignored constraints and invalid assignments, are not cleared by this review. Design Assistant explicitly did not run (line725). Ordinary native Plan reports were not included in the reviewed exports; no complete warning, constraint, CDC/DRC or timing-coverage claim follows. This is not full place/route/finalize, final timing qualification or hardware acceptance. **Original Work15 hold −0.004 ns remains failing.** No source-SPEC/QUALITY gate or successor approval is issued. Review was local-only: no remote/native/test/hardware/git actions or source changes; only this report was authored.
