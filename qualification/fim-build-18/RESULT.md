# Work18 — completed native trial, unchanged hold failure

Status: native execution complete; timing FAIL; independent result review pending. Hardware NOT RUN / NOT QUALIFIED. `ready_for_build=false`. Authorization spent; do not rerun Work18.

## Actual run

The native full compile ran 2026-09-22T23:40:32.416165Z–2026-09-23T00:33:11.447650Z in tmux @124/%124. Native and outer rc0, gate rejection false. Completion capture reports no matching active processes. Synthesis 0 errors/81 warnings, Fitter 0/208, Assembler 0/1, full compilation 0/894. Timing Analyzer runs report 0/190 and 0/187; stage counts are not additive. See `completion-readback01/evidence/run/{status.json,native-status.json,native.log}` and `completion01.json.gz`.

## What the one-register trial established

The completed QSF retains the exact EMIF1 `amm_writedata_0_r[0][243]` instance `ALLOW_REGISTER_RETIMING OFF`, with global retiming ON. The saved reports do not yet prove effective Fitter instance consumption. Do not mistake QSF presence or prior metadata eligibility for that proof.

The final STA summary is byte-identical to Work17. The only negative numerical summary row remains EMIF1 hold −0.004 ns / TNS −0.004 ns at Fast vid2 100C. Minima: setup +0.151 ns, recovery +0.274 ns, removal +0.137 ns, minimum pulse width 0.000 ns. Five exact detailed hold-path blocks are unchanged versus Work17 (`parent-observations01.json` records boundaries and hashes).

The failing Fast path at `reports01/output_files/ofs_top.sta.rpt:126779–126895` still launches from Hyper-Register BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32 through UFI_X210_Y0_N355 to IO12LANE_X184_Y0_N374. Arrival 2.964 ns, required 2.968 ns, data delay 0.288 ns, signoff uncertainty 0.030 ns. It reports no SDC exception on the path. This experiment did not close hold, and the same physical launch remains. This alone does not prove why the restriction had no observed effect.

Fresh Design Assistant report: 23/88 failing rules, 7 High failing rules /34 High violations /0 waived. Constraint, CDC, electrical, PR and functional gates remain unresolved. Summary identity is not complete timing-coverage qualification. No new snapshot STA diagnostic was run.

## Preservation and identities

`postflight01.json.gz` recomputes complete Work17/SOURCE/PIM/Work18 inventories against the accepted retiming-eligibility baseline and recorded preparation delta. Original Work17 and PIM unchanged. SOURCE contains the two intended gate retargets plus the disclosed native-created `build_fim_work_ia840f_fim_18.log`; do not claim SOURCE byte identity. Work18 input changes are the two expected generated metadata files, `build_env_db.txt` and `fme_id.mif`. No active native tools in postflight.

The Work18 FME interface UUID is `3bf9c93a-e773-5ec9-b29d-b8472f65fb9a`, generated metadata only, not a currently programmed image or compatible persona claim. The QDB inventory has 1540 entries; raw databases/programming images stay remote. Preparation/completion/final-report/stage-report archives contain 20/16/9/4 exports respectively. Exact hashes and counts are retained in manifests and `parent-observations01.json`.

No programming, OPAE discovery, MMIO, reset or host recovery action occurred. DDR simulation remains SKIPPED BY USER; all hardware gates remain open.
