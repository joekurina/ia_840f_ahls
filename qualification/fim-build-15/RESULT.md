# Work15 result — native compile complete, timing FAIL

**Subsequent acceptance:** independent actual-native review and the next-iteration recommendation are parent-consumed in [RESULT-ACCEPTANCE.md](RESULT-ACCEPTANCE.md). Native compile/fit/assembly and narrow fresh-fit PCIe clock progress accepted; timing FAIL and hardware unqualified. Pending-review wording below is the preserved initial result checkpoint.

**Independent actual-result review pending. Timing NOT ACCEPTED. Hardware NOT RUN.**

The single-use full compile ended at **2026-09-22T18:47:29.363718Z**, native rc0 with no gate rejection. The completion snapshot found no matching live native processes. Fitting and assembly report successful; the overall flow records **0 errors / 894 warnings**. This is execution evidence, not qualification. ([Completion manifest](completion-manifest01.json), [final status](completion-readback01/evidence/run/status.json), [flow report](completion-readback01/project/output_files/ofs_top.flow.rpt), [assembly report](completion-readback01/project/output_files/ofs_top.asm.rpt))

## Numerical findings

| Check | Minimum reported slack | Disposition |
|---|---:|---|
| Setup | +0.151 ns | Nonnegative summary; not whole-design acceptance |
| Hold | **−0.004 ns** | **FAIL**, EMIF1 PHY clock, Fast vid2 100C; TNS −0.004 ns |
| Recovery | +0.274 ns | Nonnegative summary |
| Removal | +0.137 ns | Nonnegative summary |
| Minimum pulse width | 0.000 ns | No margin at minimum; not a waiver of other failures |

These values were parsed from the complete native summary using decimal arithmetic. The corrected PCIe `avmm_clock0` now has numerical setup **17.489 ns** and hold **0.056 ns** entries. Exact clock properties, coverage, FIFO assignments and remaining unconstrained categories are being independently checked against full STA; summary availability is not exhaustive coverage. ([Parsed observations](timing-summary-observations01.json), [full-report manifest](reports-manifest01.json))

Signoff reports **23 of 88 rules failed**, including **7 failing High rules / 34 violations / 0 waived**. The High-rule counts remain 13 CDC-50001, 7 CDC-50004, 5 TMC-20027, 4 RES-50001, 2 CDC-50007, 2 CDC-50012 and 1 CDC-50003. These are not automatically benign merely because the tool assembled an image. ([Parent observations](parent-observations01.json), `reports01/output_files/ofs_top.tq.drc.signoff.rpt:123–133`, bound in [manifest](reports-manifest01.json))

## Artifact and preservation boundaries

New fitted FME interface: **fd2baeed-3092-5735-90c9-52ef20542b75**. A matching persona is still required; predecessor personas do not become compatible by assumption. SOF/RBF/MSF/PMSF sizes and hashes are recorded in `completion01.json.gz`, not deployed. ([FME metadata](completion-readback01/project/build_env_db.txt), [completion manifest](completion-manifest01.json))

Original Work14 and PIM full inventories remain unchanged. SOURCE matches the recorded three-file integration overlay plus the native-created `build_fim_work_ia840f_fim_15.log`; calling the entire SOURCE tree unchanged would be false. Work15's recorded input changes are exactly the native `build_env_db.txt` and `fme_id.mif` metadata updates. ([Postflight summary](postflight-summary01.json), [launcher-source attribution](parent-observations01.json))

## Continuation

Independent native-result review and one focused next-iteration recommendation are running against the completed fitted reports. No unchanged rerun, hold waiver, blind seed sweep, deployment or hardware access is authorized by this report. The next correction must be supported by actual fitted timing and preserve the board/interface/clock contract. The separate requested warning review is not a new build approval framework. ([Review dispatch](result-review-dispatch01.json), [iteration authority](ITERATION-AUTHORITY.md))

DDR simulation remains **SKIPPED BY USER**. Real DDR/transfers/AHLS/PR/sustained/QSPI and independent host-recovery gates remain unresolved. `ready_for_build=false`.
