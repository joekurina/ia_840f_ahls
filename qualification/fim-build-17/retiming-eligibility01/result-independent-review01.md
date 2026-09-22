# Work17 retiming eligibility — independent actual-result review

**Verdict: ACCEPT the narrow native eligibility evidence.** This is not execution authorization, Fitter-consumption acceptance, or a timing fix. Review used only local captured evidence; no remote access, vendor invocation, tests, package entry, source/configuration changes, or authorization issuance. Only this report was written. Paths below are relative to this directory; `R` denotes `result-readback01`.

## Integrity and archive closure

All **42 frozen files** matched both byte counts and SHA256 at review start and final prepublication recheck. The freeze manifest itself remained unchanged: `result-review-freeze01.json` SHA256 `f8bda9ea2d123595e3bcfeef5a27c8b355269abc4b7e9fab0c109bf9b1285d89`.

Decoded both gzip/JSON/base64 archives in memory. Exact member sets, decoded bytes, lengths and hashes matched their manifests and complete readback directories: **13 preparation exports; 9 result exports**, with no missing or extra readback files. The nested report manifest also matches both report files.

Verified SHA256:
- `preparation01.json.gz`: `81ff73f165be936909bb0240a66089551877801c27bbdbb62d47960576cea606`
- `prepared-readback01/candidate.json`: `a5e24ad6e8e302277e0fd181ec03f64d9f7ecb5b0a20495ee0c37bebf8606239`
- `result01.json.gz`: `d213e58d7f8de299e2cb6340d31b589d3a3aa602b928a766c95c2306f138e7c9`

## Actual native observation

`R/query.log:2–21,42–62` identifies Quartus Pro 26.1.1, PID64900, the copied-project query, and device AGFB027R25A2E2V. It explicitly loads **synthesized**, not fitted, snapshots for `root_partition`, `green_region`, `auto_fab_1`, and `auto_fab_0`, then confirms successful database loading. All 135 synthesized-QDB inventory entries match the recorded original Work17 hashes and remain callback-bound.

`query.tcl:31–48` uses the Agilex7/Fitter/instance filter, `create_timing_netlist -post_syn`, and the literal register selector. `R/reports/audit.tcllist:7–12` and `R/query.log:67–69` agree: raw collection count **1**, returned name count **1**, exact-name count **1**:

`local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]`

No wildcard broadening or fallback establishes this identity. `R/reports/assignment-info.txt:1–4` reports `ALLOW_REGISTER_RETIMING`, Type **Global, Instance**, legal **On, Off**, and “This setting affects the Fitter.” The exact native `get_all_assignment_names -family {Agilex 7} -module fit -type instance` query returns 145 names with membership=1. This establishes family/stage/scope eligibility beyond generic metadata alone.

## Completion and preservation

`R/native-process.json`, `native-result.json`, `execution-status.json`, and `result-manifest01.json` agree on native/effective/outer **0**. Recorded native interval: **2026-09-22T23:30:58.235449–23:33:33.449131 UTC**. Termination is confirmed, final live owned PID list empty, abort absent, supervision/acceptance errors empty. `R/query.log:70–78` retains successful completion and **0 errors, 1 warning**. Critical Warning20727 concerning unused PR partition inputs is retained, not waived or misrepresented as warning-free execution.

Decoded preparation preservation inventory equals `baseline.json.gz` exactly. `R/preservation-after.json` attests all three original Work17/SOURCE/PIM inventories unchanged; `run-query.py:280–287` performs full inventory comparisons. These are verified captured attestations, not a new remote audit. All 72 recorded Work17 SDC hashes match candidate inputs; top.sdc before/after hashes agree. The query contains no `read_sdc`, assignment setter, fit, or timing report; synthesized embedded constraints are not full signoff analysis. The reused full-lifetime supervisor/source-bound gate is **not an OS sandbox**.

## Disposition

Positive eligibility supports parent preparation of **one exact bit243 `ALLOW_REGISTER_RETIMING OFF` trial**, preserving one-variable/safe-native-iteration discipline and unchanged signoff. No global retiming, margin escalation, or PHY/clocking/geometry/seed/effort changes follow from this review. Fresh changed-design native evidence must establish actual assignment consumption, launch/path implementation, and hold/setup/coverage results. Physical implementation, timing closure, and hardware qualification remain unproven.
