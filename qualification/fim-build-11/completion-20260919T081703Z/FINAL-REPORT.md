# Work11 final disposition — native complete; timing/constraints FAIL

## Outcome
Existing Work11 completed **2026-09-19T08:19:11.716264Z**, native return code **0**. Native full compilation reports **0 errors, 950 warnings**. Assembler succeeded with **0 errors, 1 warning**, ending **08:18:32 UTC**. Final snapshot at **2026-09-19T08:19:39.637001+00:00** finds no live claimed native process, runner or assembler, and no remaining vendor tasks in the captured process inventory.

**This is execution/assembly success, not BSP acceptance.** Hold-only ON produced no timing improvement versus Work10. `ready_for_build=false`, timing acceptance=false, constraint acceptance=false, functional acceptance=false. No another build, Query04, DDR simulation or hardware operation was launched.

## Native evidence and identity
- Fresh observer window `completion-20260919T081703Z`, pane `%405`, session `ia840f_mailbox_monitored_01`. Host Agilex7Workstation, UID1000 verified. Existing panes untouched; all remote operational reads ran within the owned window.
- Three snapshots span 08:17:17–08:19:39 UTC. First two verify assembler156622/start9359480 and flow151888 ancestry through claim151870/start9008184, runner151868/start9008051 and tmux7828. Final snapshot verifies their absence. See `disposition-verification.json`.
- Claim retained and matches authorization SHA256 `c8efbbfc0c850b95ffe21746b123717f388bfece3c0d822bd3754f182d838213`. No record, claim, gate or source edits.
- Final 129-log/report scan: zero detected Error/Fatal diagnostics, zero gate-rejection markers, zero 125091. Timing critical warnings remain real failures, not error-colon execution diagnostics.
- Exact final status/native log/claim/invocation, flow report, assembly report and fit/synthesis summaries are in `readback/captured/`. Native status remains historical `compile_fit_assembly_timing_acceptance=PENDING REPORT REVIEW`; this report supplies the independent failed timing/constraint disposition without rewriting that record.

## Timing compared with Work10 (ns)
Both full STA files were rehashed locally; Work11's original **46,834,561-byte** report remains at `../monitor-20260919T080835Z/readback/captured/output_files/ofs_top.sta.rpt`, SHA256 `9b851e84ea597e8c7b8b846d630609ce69ed6436ce555cc853858f6ec91f838c`. Work10 SHA256 `8e6002a2c4c7974f0382a9b458c8be9ca87034a120d4972da3c14081367aded4`. No full STA retransmission or replacement by a reduced report occurred.

All **34 setup/hold clock summary rows** match Work10 in WNS, TNS, failing endpoints and limiting corner. Five delay models are represented. Source-line checks against both full reports and row equality are recorded in `disposition-verification.json`; full per-corner/path/constraint data and comparison remain in `../monitor-20260919T080835Z/timing-analysis.json`.

| Domain | Check | Work10 / Work11 WNS | TNS | Failing endpoints | Limiting corner |
|---|---|---:|---:|---:|---|
| DDR0 core | Setup | -0.508 / -0.508 | -185.081 | 711 | Slow vid2 100C |
| DDR1 core | Setup | -0.170 / -0.170 | -29.340 | 403 | Slow vid2 100C |
| DDR1 PHY clk_l_0 | Hold | -0.004 / -0.004 | -0.004 | 1 | Fast vid2 100C |
| DDR0 core | Hold | 0.000 / 0.000 | 0.000 | 0 | Slow vid2 100C |
| DDR1 core | Hold | 0.000 / 0.000 | 0.000 | 0 | Slow vid2 100C |
| DDR0 PHY clk_l_0 | Hold | +0.103 / +0.103 | 0.000 | 0 | Fast vid2 100C |

Worst setup paths remain MSA bank-spreading/scheduler paths. DDR1 hold remains the core write-data register to PHY register path. Unconstrained summary remains **1 clock, 2 input ports / 78 path pairs, 2 output ports / 10 path pairs**, for setup and hold. S1/TRS, PCIe-divider and BMC IRQ/JTAG questions remain unresolved. Successful STA execution (0 errors/240 warnings, 08:11:58 UTC) does not override these results.

## Actual setting versus native migration
- Final native **flow report line396** explicitly records `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ; On ; Off` (effective/native non-default setting versus default). SOURCE QSF line129 and final WORK QSF line128 both retain ON. This establishes native recognition, not timing improvement.
- Fitter reports High Performance Effort, Maximum physical placement effort, seed2 and MAXIMUM router timing optimization. No clock/RTL/SDC/geometry/PF/BAR/pin change is part of the hold experiment.
- SOURCE QSF retains reviewed SHA256 `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`.
- WORK QSF SHA256 `d72f033986ea4a020a9d60b3c11af074dd9de3cff23534b4052750291e67fb41`: Quartus natively migrated the old optimization spelling to HIGH PERFORMANCE EFFORT plus GLOBAL_PLACEMENT_EFFORT MAXIMUM EFFORT, updated LAST_QUARTUS_VERSION and added its deprecation comment. This is separate from operator changes; exact `readback/native-qsf-migration.diff` retained. No migration copied back to SOURCE.
- Reviewed Work10-to-Work11 source delta was exactly three files: `syn/board/ia840f/syn_top/ofs_top.qsf` (hold ON addition), `ofs-common/tools/ofss_config/ia840f_compile_gate.py` and `ofs-common/tools/ofss_config/ia840f_experimental_gate.py` (mechanical WORK/EVIDENCE/dispatch retargets). Prior spec/quality review and issuance inventories establish that scope; this completion pass changed none of them.

## Programming-image inventory
Remote generated bytes were hashed read-only; image binaries were not transferred or programmed. Exported `readback/images.json` was locally hash-verified against its remote manifest.

| Programming image | Bytes | Remote SHA256 |
|---|---:|---|
| `ofs_top.green_region.rbf` | 9121792 | `b580972ff8e3ff6dfeae12f1eb9ee14d631726489d57a6d87adbee02b6c4ed83` |
| `ofs_top.sof` | 9327739 | `477a44e9ae801d7d7cf069990771d09eb7a6530e5180571385f32d1a83a12b16` |

Assembler intermediates, **not additional SOF/RBF programming images**:

| Intermediate | Bytes | Remote SHA256 |
|---|---:|---|
| `ofs_top.green_region.pmsf` | 8431159 | `cb5aaef7dc7b682e7c39d3fb7fdafe0ed29dd5c48a59a46a6611007f9c10775c` |
| `ofs_top.static.msf` | 3653083 | `175e192b196bacca19b4e36b7cb35dadf8e0a6a1fbca583c34d6ad51c3d5e3eb` |

Assembler warning20536 says legacy `GENERATE_RBF_FILE` was ignored. The inventoried `ofs_top.green_region.rbf` exists; **no full/static RBF was present in the inventory**. Image existence is not timing acceptance or hardware permission.

## Resources and runtime
Device AGFB027R25A2E2V, Quartus26.1.1 Build130. ALMs86,270/912,800 (9%); registers235,991; pins321/886; block memory2,306,508bits; RAM blocks664/13,272; DSP0; P-tiles1/2; PLLs8/36.

| Native flow table stage | Elapsed | Peak virtual memory |
|---|---|---:|
| Synthesis | 00:07:44 | 5688 MB |
| Fitter | 00:45:32 | 21576 MB |
| Timing Analyzer | 00:01:24 | 9711 MB |
| Assembler | 00:05:43 | 19218 MB |
| Table total | 01:00:23 | — |

Module ending messages independently report fitter00:45:36, STA00:01:27, assembler00:05:44. Full shell elapsed01:04:53; runner wall time **3896.728907s**, from07:14:14.987357Z to08:19:11.716264Z. Differences reflect native report scopes/overhead, not a recomputed stage-total claim. Fitter0errors/202warnings; synthesis0errors/34warnings; complete compile0errors/950warnings.

## Pass / fail / not-run matrix
| Criterion | Disposition |
|---|---|
| Single existing native invocation / return code | PASS — finished, 0 |
| Native synthesis / fitter / STA execution / assembly | PASS — execution only |
| Gate markers / 125091 / detected error diagnostics | PASS — zero in final scan |
| Final SOF and partial RBF existence/hash inventory | PASS — not programmed |
| Setup closure | FAIL — both DDR core domains |
| Hold closure / DDR closure | FAIL — DDR1 PHY -0.004ns |
| Constraint completeness | FAIL — unconstrained clock/I/O remain |
| Hold-ON improvement versus Work10 | FAIL — all34 summary rows unchanged |
| Functional / DDR simulation | NOT RUN — explicitly skipped by user |
| Query04 / hardware programming or test | NOT RUN |
| Build readiness / timing / constraint / functional acceptance | FALSE |

## Preservation and verification
Remote completion directory `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-11/completion-20260919T081703Z`; local directory `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-11/completion-20260919T081703Z`. Historical reports, claims, source and gate inputs were not rewritten. New files are confined to these evidence directories and owned tmux transport buffers/window.

Compact export: **147018 bytes**, SHA256 `b6e67d07382229d70110f7ad94ef6158f451751e98cd1fb6270a64a0765da25e`; **16 manifest files** locally checked for size/SHA256, with monitor-script byte equality and requested-batch identity checks. `export-verification.json`, `full-sta-local-verification.json`, `disposition-verification.json` and `readback/manifest.json` retain machine-readable provenance. `ARTIFACTS-SHA256.json` covers local completion artifacts including this report.

No operational blocker occurred. The outstanding issue is failed timing/constraints, not native build execution. No rerun, vendor query, simulation, hardware, install, permission change, process control or commit was performed.
