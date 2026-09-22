# Work16 independent actual-result review

**Verdict: ACCEPT the ACTUAL EXECUTION / FAILED-TIMING EVIDENCE milestone only.** Timing remains **FAIL**; this is not build readiness, source SPEC/QUALITY approval, successor authorization, hardware qualification, or task closure.

All paths below are relative to this directory: `C=completion-readback01`, `P=prepared-readback01`, `R=reports01/output_files`, and `L=C/evidence/run/native.log`.

## Frozen evidence and archive closure

Independently recomputed sizes and SHA-256 for **all 62 frozen files**, initially and again immediately before report publication: all matched. The freeze manifest itself stayed byte-identical, SHA-256 `3094171472ca7ee7beba343ebaf1015f3ba22bc70e6181e8018c9c7f915137b9` (`result-review-freeze01.json:4–254`).

Decoded the lossless archives in memory and checked exact exported file sets, sizes, hashes, metadata and local readback bytes: **19 preparation, 16 completion, 9 reports**. Preparation uses base64; completion/reports require nested gzip_base64, whose compressed hashes/sizes also verified. Readback directory sets exactly match their exports. Archive/JSON bindings match the manifests. Full STA **49,225,196 bytes**, fitter **19,809,615 bytes**, signoff DRC, finalize and summaries are present, not merely excerpts; final completion identities match the exported STA/FIT (`preparation-manifest01.json:2–77`; `completion-manifest01.json:2–43,199–348`; `reports-manifest01.json:6–72`).

## Native completion, not watcher success

The runner records finished, native rc0, gate_rejection=false, start **2026-09-22T20:47:35.046503+00:00**, end **2026-09-22T21:39:29.106862+00:00**. The separate native-status receipt records rc0 at 21:39:29.098659+00:00. Completion and postflight snapshots contain no matching native processes; these are captured observations, not a present-time workstation audit (`C/evidence/run/status.json:2–24`; `C/evidence/run/native-status.json:2–3`; `completion-manifest01.json:171–198`; `postflight-summary01.json:15–20`).

Native messages independently confirm synthesis **0 errors/81 warnings**, fitter **0/208**, STA **0/190 then 0/187**, assembler **0/1**, full compilation **0/894**. These distinct totals are not additive (`L:8290,9182,10460,10943,11096,11219–11225`). No gate-rejection marker was found. The successful flow identifies Quartus 26.1.1 Build130 and AGFB027R25A2E2V (`C/project/output_files/ofs_top.flow.rpt:22–30`), but native success does not override the timing warnings (`L:9760,10434`).

## Exact experiment and remaining failure

Old/new captured bytes prove the sole functional source delta is the appended **10ps `set_clock_uncertainty -hold -add`**, guarded to quartus_fit, on the singleton EMIF1 core_usr_clk→phy_clk_l_0 pair. Both gate files differ solely by mechanical Work15→Work16 root retargets. The old SDC prefix is unchanged; the new branch does not relax final STA (`top.sdc:151–165`; `P/compile-candidate-01/source-inputs/delta-report.json:2–15`). Native Fitter issued the singleton applied marker; both STA invocations issued the skip marker (`L:8811,9597,10803`).

These markers prove **setter issuance**, not total effective uncertainty, subsequent retention or physical-edge applicability. Repeated manual `-add` setters do not accumulate; hold also affects removal. No effective-objective or no-op mechanism is established (`iteration-basis.md:5–7`).

Independent parsing recovered all **788 numerical summary rows**, with one negative row:

| Analysis | Worst slack, ns | Summary lines |
|---|---:|---|
| Setup | +0.151 | `R/ofs_top.sta.summary:5–8` |
| Hold / TNS | **−0.004 / −0.004** | `R/ofs_top.sta.summary:95–98` |
| Recovery | +0.274 | `R/ofs_top.sta.summary:185–188` |
| Removal | +0.137 | `R/ofs_top.sta.summary:240–243` |
| Minimum pulse width | 0.000 | `R/ofs_top.sta.summary:295–298` |

The violated EMIF1 hold path is at **Fast vid2 100C**: `amm_writedata_0_r[0][243]` to `tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`, core_usr_clk→phy_clk_l_0, with no SDC exception (`R/ofs_top.sta.rpt:126786–126794`). Final STA reports 0.030ns uncertainty (`:126894`), not a Fitter-total measurement.

The complete 61,018-byte summary is byte-identical to `../fim-build-15/completion-readback01/project/output_files/ofs_top.sta.summary`. The selected hold-detail block also agrees with the hash-verified Work15 archived STA (`../fim-build-15/reports01.json.gz`, member `output_files/ofs_top.sta.rpt:126779–126899`; binding `../fim-build-15/reports-manifest01.json:48–60`). Neither comparison proves identical internal optimization or why the experiment failed; full STA files are not byte-identical.

## DRC, coverage and preservation

Reparsed the native signoff table: **23/88 failed rules; 7 failed High rules, 34 violations, 0 waived**. Raw comma-formatted counts `1,518`, `1,484`, `1,074` correctly parse as 1518/1484/1074 and remain preserved (`R/ofs_top.tq.drc.signoff.rpt:123–214`; `drc-observations01.json:2–6`). Coverage remains open: two unconstrained input and two output ports, with 78/10 pairs-only paths for both setup and hold (`R/ofs_top.sta.rpt:214884–214894`). Electrical assignment warnings remain (`R/ofs_top.fit.rpt:6991–6998`); CDC and PR rows are not waived by positive timing minima.

Recomputed full captured inventory differences from `postflight01.json.gz` against `postflight-input01.json.gz`. Its baseline exactly matches the SHA-bound `../emif-hold-objective-01/plan-diagnostic03/prepared-readback02/preservation.json.gz`. Original Work15 and PIM are unchanged. SOURCE has exactly the three prelaunch changes plus new `build_fim_work_ia840f_fim_16.log`: the raw three-file-only equality flag is correctly **false**, not hidden drift (`postflight-summary01.json:2–20,41–45`). Independently hash-matched the logger source; filename and tee explain that addition (`build-log-provenance01.json:2–13`; `../../ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_top.sh:163,192`).

Work16's captured input-delta record lists only native `build_env_db.txt`/`fme_id.mif` changes; their before/after hashes independently match preparation and completion bytes (`postflight-summary01.json:21–37`). There is no complete Work16 after-inventory in this payload; unchanged remaining inputs rely on the captured delta record, not an independent live rescan.

## Blockers and conclusion

**No blocker to this narrow evidence milestone.** Failed timing/DRC and disclosed native metadata/log changes are nonblockers to recording the actual failed result, not waived defects. Timing, CDC/DRC, coverage, electrical, PR and hardware acceptance remain blocked/open. Compiled FME UUID `ef3f29b8-f48b-5056-9f96-4d4a3351eeae` is not live-card or persona compatibility evidence (`C/project/build_env_db.txt:11`). SOF/RBF records prove provenance only (`completion-manifest01.json:16–26`). DDR simulation remains skipped by user; no DDR/device execution was performed here. No remote access, vendor execution, source edit or git operation was used. Only this report was authored; practical next-correction review remains separate.
