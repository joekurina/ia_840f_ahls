# Matching persona first fit — completed, result review pending

## Actual operation

The single first fit completed under Quartus Pro26.1.1 Build130 for AGFB027R25A2E2V, top `top`, revision `ofs_pr_afu`. Configure/version/fitting CMake/effective outcomes are0; direct version/fitter native outcomes and outer/wait/readback are0. `execution_clean=true`, no postflight errors, no owned live groups at return. Runner interval **2026-10-02T15:25:36.083899+00:00 →16:01:03.208357+00:00**, elapsed **2127.124458s**. [Verification32](native-result-verification32.json), [raw result](completion30-readback/operation/result.json).

Admission `08acc24c47633076b5abdd0f53de34355d053d6b5f66d6517f7c7076627fa4af`, tmux `@288/%288`, runner352362/start50383668 and native fitter352411/start50384534 belong to this completed/spent operation. One actual callback accepted the exact executable/hash/argv/cwd/owner/ancestry. Waiter `proc_fcdfe081d270` finished0. Do not repeat the fit or synthesize again. No STA, assembly, GBS or hardware operation ran.

## Preserved inputs and produced physical data

All **13** completion-capture preservation checks pass, including original mapped bytes and its exact entry set—no added or missing original files. All68 protected mapped/static members and the imported static QDB remain unchanged, as do critical/external/setup/release/archive/tool/control and predecessor-result bindings. QPF before/after is byte-identical. All863 reviewed runtime-output entries were recorded: **832 unchanged /31 changed /0 removed**. These are native report/bookkeeping changes, not source exemptions. [Index30](completion-index30.json), [runtime deltas31](runtime-output-deltas31.json).

Captured **53 files /74,109,997bytes**, including all seven required fitter reports. Five unchanged synthesis/DRC reports are referenced to the accepted local mapped-result bodies rather than retransferred. All **729 QDB files /380,651,175bytes** were inventoried and hash-reverified; their binary bodies remain remote. All five required new final/green physical members exist. The bounded completion process snapshot is empty, not exhaustive hardware ownership. [Reused report bindings31](reused-report-bindings31.json), [verification32](native-result-verification32.json).

The **final native partition table** reports root `final` preservation from `ofs_top.qdb`, green_region **Reconfigurable**, and auto_fab_0 final preservation. This is actual fitter corroboration of the PR/static import contract, not behavioral or hardware acceptance. [Main report:245–253](completion30-readback/reports/ofs_pr_afu.fit.rpt).

Final resources must retain their distinct definitions: **123,298 ALMs needed** versus **106,867 ALMs used in final placement**,275,262 dedicated registers,3,029,196 block-memory bits,482 RAM blocks,one P-Tile andeight PLLs. Device timing/power model status “Final” is not design timing closure. [Summary](completion30-readback/reports/ofs_pr_afu.fit.summary), [resource panel:17880–17956](completion30-readback/reports/ofs_pr_afu.fit.rpt).

## Findings, not waivers

Native footer is **0 errors /166 warnings**; the complete console contains **161 Warning +5 Critical Warning** occurrences. All five critical occurrences are20727, unused PR/reserved partition inputs. Keep the native partition-port population and interface scope in review; do not add noprune or edit interfaces merely to suppress the warning. Other occurrences include18502 assignment findings and332174/332054/332049 unmatched-filter/constraint findings; inheritance and successful fitting do not establish effective timing coverage. [Diagnostics31](diagnostics31.json).

The final report's reset table contains81 domains. It requires **three additional cycles for sys_pll|iopll_0_clk_sys** and **seven for bank0's EMIF core clock**. These extend an already-valid reset sequence; they are not a complete reset pulse, FLR, cold-entry or active-transaction recovery guarantee. The intermediate Retime capture is byte-identical to the completed Retime report, and its entire reset table matches the final main report. Do not substitute the older persona's four-cycle bank0 requirement. [Final report:25770–25856](completion30-readback/reports/ofs_pr_afu.fit.rpt), [retime observations27](retime-observations27.json).

Info21624 explicitly states **Design Assistant did not run in Finalize because no rule was enabled**. The unchanged copied synthesized DRC5/13 failed rules/15 violations/seven disabled rules and prior power-up/reset findings remain. An unchanged report is not a newly passed physical DRC. The Plan capture confirmed device/SDC-import/user-target observations but did not contain final partition preservation; the completed main report now provides that separate table.

## Next gate

Independent fit-integrity/static-PR and diagnostic/reset/constraint reviews must disposition this completed stage and whether fresh STA preparation may proceed. Do not treat fitter success, retiming analysis or final device models as the required multi-corner timing acceptance. Preserve the bank0-memory-clocked **3.000ns** application requirement, all original constraints and the distinct auto200/100 user-clock requests.

Subsequent STA is a separately admitted state-changing operation: its OFS hook computes user-clock output, rereads constraints and writes timing reports. Full clock/exception/unconstrained/CDC/recovery/removal/MPW and reset/electrical acceptance, assembly/matching images, deployment and all migrated real-card gates remain incomplete. No new authority or hardware acceptance follows from this record.
