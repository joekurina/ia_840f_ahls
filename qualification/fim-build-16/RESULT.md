# Work16 native result — compile rc0; timing still FAIL

**Native execution completed. The 10 ps Fitter-only experiment did not close the EMIF1 failure. Independent actual-result review is pending; timing NOT ACCEPTED, hardware NOT RUN / NOT QUALIFIED, ready_for_build=false.**

## Execution

The single-use full compile ran 2026-09-22T20:47:35.046503+00:00–2026-09-22T21:39:29.106862+00:00: native rc0, gate_rejection=false. Completion and postflight captures show no matching native tools. Do not rerun or reissue Work16. Synthesis 0 errors/81 warnings; fitter 0/208; assembler 0/1; full compile 0/894 are separate native totals, not additive counts. [Run status](completion-readback01/evidence/run/status.json), [native status](completion-readback01/evidence/run/native-status.json), [native messages](parent-observations01.json)

Parent verified 19 preparation, 16 completion and 9 full-report exports. Captured final STA/FIT hashes match the completed run. Lossless archives are `preparation01.json.gz`, `completion01.json.gz` and `reports01.json.gz`; decoded oversized reports are ignored, not discarded. [Preparation manifest](preparation-manifest01.json), [completion manifest](completion-manifest01.json), [reports manifest](reports-manifest01.json)

## Timing and constraints

| Analysis | Worst slack (ns) | Corner |
|---|---:|---|
| Setup | +0.151 | Slow vid2b 100C |
| Hold | **−0.004** | Fast vid2 100C |
| Recovery | +0.274 | Slow vid2b 100C |
| Removal | +0.137 | Fast vid2 100C |
| Minimum pulse width | 0.000 | Slow vid2 100C |

Failing hold clock: `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0`, TNS −0.004 ns. The **complete STA summary is byte-identical to Work15**. That proves no change in these reported summary values, not identical internal optimization or a proven no-op mechanism. [Parent observations](parent-observations01.json), [summary comparison](drc-observations01.json), [full-report identity](reports-manifest01.json)

Fitter emitted the exact-pair singleton 10 ps applied marker; both STA invocations emitted the skip marker. Repeated `-add` setters do not accumulate. Issuance markers do not prove retention, physical-edge applicability or total effective uncertainty. Original signoff requirements were not relaxed. [Source delta](top-sdc.diff), [iteration basis](iteration-basis.md), [native messages](parent-observations01.json)

Signoff DRC remains **23 of 88 failed rules**, including **7 High rules / 34 violations / 0 waived**. CDC/DRC, unconstrained coverage, electrical and PR concerns are not cleared by positive timing summaries. Raw thousand-separated counts in the native DRC table are preserved alongside parsed counts. [DRC observations](drc-observations01.json), [full DRC binding](reports-manifest01.json)

## Preservation and interface

Postflight full inventories confirm original Work15 and PIM unchanged. SOURCE equals its recorded baseline plus the prelaunch SDC/two-gate changes **and** native-created `build_fim_work_ia840f_fim_16.log`; the raw three-file-only equality flag is correctly false. The addition follows the hash-matched build script's logger, not an undisclosed source correction. Work16's only recorded input changes are native `build_env_db.txt` and `fme_id.mif` updates. [Postflight](postflight-summary01.json), [baseline payload](postflight-input01.json.gz), [logger provenance](build-log-provenance01.json)

New compiled FME interface: `ef3f29b8-f48b-5056-9f96-4d4a3351eeae`. This is not a live-card identity or persona compatibility proof. SOF/RBF hashes are artifact provenance only: no deployment occurred. DDR simulation remains SKIPPED BY USER. DDR, transfers, real OPAE/AHLS numerical behavior, PR, sustained operation and QSPI power-cycle qualification remain unperformed. [Build metadata](completion-readback01/project/build_env_db.txt), [artifact inventory](completion-manifest01.json)

## Continuation

Independent actual-result review is required before milestone acceptance. Practical next-correction review `deleg_afffd24d` is separate from that review and from launch authority. No successor is issued. Use the smallest justified native correction, not another unchanged fit, hidden control, signoff waiver, or speculative hardware operation.
