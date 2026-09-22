# Plan diagnostic02 — independent native-result review

**Disposition: verified failed native attempt with trustworthy partial setter evidence; no complete SDC, effective-objective, or timing acceptance.** This is a local review of frozen evidence, not a source-SPEC/QUALITY review, launch gate, or successor approval. No remote/native/test/hardware/git operations were performed.

## Export integrity and termination

Independently decoded both archives and compared every file's byte count, SHA256, and exact bytes against the corresponding manifest and readback directory: **16/16 preparation files and 7/7 result files match**, with identical file sets and no discrepancies.

Archive SHA256:
- `preparation02.json.gz`: `44d5f08cea2a5571b6103871f9549bd0625141782457dcccb157be2210f45b50`
- `result01.json.gz`: `4b2aadb427a614614f4769a096cafcfea352bbb26848462c27aa06d5d3aac061`

The full exported `query.log` is 97,228 bytes, SHA256 `8508366c73a2478e3287008970946fde2d4014dcbceece8a3c38cb9746c2b680`. All five result receipts duplicated in `status02.json` match their exported hashes and JSON contents; its log size also matches.

`native-process.json` identifies Quartus 26.1.1 `quartus_fit --plan --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`, PID 37561, in diagnostic02 scratch. `native-result.json` records 2026-09-22 19:52:55.847156–20:01:26.856592 UTC, native rc3, no abort, confirmed termination, empty final live-PID list, and no supervision errors. `execution-status.json` records effective rc3 and `timing_accepted: false`. Log lines 486–492 corroborate unsuccessful Fitter completion and supervision; the later 20:08:00 UTC status capture has no matching processes. These are captured termination observations, not a fresh workstation inspection.

## Trusted issued value and branch

`query.log:374` contains exactly one native `EMIF1_HOLD_ISSUED` observation, after the hold setter in `prepared-readback02/instrumented.sdc:1006`:

- Prefix: `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1`
- From: prefix + `|emif_1_core_usr_clk`; to: prefix + `|emif_1_phy_clk_l_0`.
- Application `quartus_fit`; `phy_index 0`, `same_tile_index 0`; `from_count 1`, `to_count 1`.
- `add_mode -add`, `C2P_HOLD_OC_NS 0.000`, **`issued_ns 0.0`**.
- `periphery_uncertainty {0.0 0.0 0.0 0.0}`, `overconstraints_st {0.000 0.000 0.000 0.000}`, `overconstraints_mt {0.0 0.0 0.0 0.0}`.

The captured branch (`instrumented.sdc:983–1006`) selects the same-tile additive expression, not the multi-tile replacement expression. The logged `multi_tile_base 0.366` is **not used for this same-tile hold setter**. This establishes the issued additive value and clock selection, not zero total uncertainty or a final effective timing objective.

## Missing proof and failure classification

Immediately afterward, log lines 375–400 show Error19104: external `diagnostic.tcl` absent from the Quartus project database, Error332000 on `source`, and failed `read_sdc`. This is diagnostic packaging failure, not proof of defective production clock constraints. No callback registration/entry/result markers occur; `report-manifest.json` is empty.

The derived 44-clock inventory at lines 434–482 follows failed SDC loading: it is neither a complete baseline nor effective-uncertainty/timing proof. The planned-database commit at line 483 does not override rc3. No gate rejection appears; the 691 recorded runtime-output exclusions concern the distinct earlier issue. The generic execution error label `native/query/gate diagnostic` does not establish a gate rejection here.

## Captured preservation and conclusion

`preservation-after.json` records true inventory comparisons for original Work15, SOURCE, and PIM. The hash-bound preparation before-image contains respectively 7,346, 1,657, and 536 file/link entries; captured runner lines 342–348 compare fresh inventories against it. This supports preservation as captured; post-run per-file inventories were not exported for independent recomputation.

Accept this evidence only as a safely terminated failed diagnostic with a useful exact setter observation. It does not supersede the independently accepted failing Work15 full-fit hold result of −0.004 ns or establish hardware acceptance.
