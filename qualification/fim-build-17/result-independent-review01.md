# Work17 independent actual-result review

**Recommendation: ACCEPT the narrow completed-build/failed-timing result-evidence milestone. Timing remains FAIL.** This is neither timing readiness nor approval of any successor execution.

## Evidence closure

Reviewed `RESULT.md`, `parent-observations01.json`, the frozen evidence, decoded reports, and the relevant Work16 antecedents locally. No remote access, vendor invocation, hardware operation, source edit, or git operation was performed.

All **106 frozen files** pass independently recomputed byte-length and SHA256 checks, including a final recheck. The binding is `result-review-freeze01.json`, SHA256 `4b9fd693531c097b06ddf0c9de957fe87dcb99f3bd5988d79cafa314f5d14097`.

Archive-to-manifest-to-readback closure passes for **20 preparation, 16 completion, 9 final-report, and 4 stage-report exports**. Verification respects preparation's base64/bytes schema, completion's gzip_base64/size and absolute-remote-to-evidence/project mapping, and relative report paths. Encoded payload hashes/sizes, decoded bytes, available envelope hashes, and local readbacks agree. Final/stage report and completion artifact hashes also agree with the postflight Work17 inventory.

Collector01's preserved exit-1 receipt corresponds to its ordinary-file 3,000,000-byte cap: Plan is 3,314,855 bytes. Successor02 changes the batch identity and uses exact previously captured sizes, including Place at 8,410,679 bytes; its four exports and exit-0 receipt verify. This was an acquisition failure, not a failed native build or vendor retry.

## Actual native result

Decoded `completion-readback01/evidence/run/status.json`, `native-status.json`, and `native.log` establish native **rc0**, no gate rejection, start **2026-09-22 22:00:01 UTC**, finish **22:52:32 UTC**. Full compilation reports **0 errors/894 warnings**; synthesis **0/81**, Fitter **0/208**, assembler **0/1**. Timing Analyzer completion reports **0/190**; the separate PR-SDC helper reports **0/187**. These overlapping flow/stage counts are not additive. Completion and postflight captures report no matching active native tools; this is historical captured state, not a live-host assertion.

## Timing and DRC remain failed

Independent parsing of all **788 STA summary rows** finds the sole negative summary slack: **EMIF1 hold −0.004 ns, Fast vid2 100C**. `reports01/output_files/ofs_top.sta.rpt:126779–126895` identifies `amm_writedata_0_r[0][243]` through UFI to `lane_inst~phy_reg1`: arrival **2.964 ns**, required **2.968 ns**, signoff uncertainty **0.030 ns**, no SDC exception on this path.

The complete summary and all five cited hold-detail blocks are byte-identical to decoded Work16 evidence. Setup +0.151, recovery +0.274, removal +0.137, and minimum-pulse-width 0.000 ns do not clear hold or constraint-coverage concerns. Native diagnostics explicitly report unmet timing and DDR timing requirements.

Recomputed signoff DRC table (`ofs_top.tq.drc.signoff.rpt:123–214`): **23/88 rules failed; 7 High failed rules, 34 High violations; zero waived**. Parsing includes thousands-separated counts. Tool exit zero is not timing or CDC/DRC acceptance.

## Snapshots and preservation limits

The WORK QSF change is exactly the snapshot-retention comment/assignment; FIT line 184 reports intermediate snapshots On. All **52 recorded SDC bindings** match Work16 and Work17 pre/post evidence: the existing Fitter-only 10 ps margin remains, while STA skips it and preserves original signoff.

Native commit messages and postflight hashes establish retained **planned, placed, routed, retimed, final** databases, respectively **161/187/187/189/197 inventory entries**. The 1,540-entry QDB inventory agrees with the complete captured Work17 inventory, including substantive timing/netlist/routing members. No separately executed snapshot timing comparison is evidenced. Remote database retention is not local byte possession or demonstrated query usability.

Recomputed full SOURCE/PIM comparisons show exactly the two intended gate retargets plus the new `build_fim_work_ia840f_fim_17.log`; PIM is unchanged. All **5,441 original Work16 recorded input/completed-output bindings** reconstruct exactly from antecedent evidence; the bound postflight collector checked every binding and reports zero differences. **No complete prelaunch original Work16 QDB inventory was exported; full original-tree preservation cannot be claimed.**

Work17's only recorded-input postrun changes are `build_env_db.txt` and `fme_id.mif`. Interface UUID `33f9e51f-aa64-5620-b9c0-714a0ddf485c` is generated build metadata, not live-image identity or persona compatibility. Raw images/QDBs remain remote. Hardware is **NOT RUN / NOT QUALIFIED**, DDR simulation **SKIPPED BY USER**, and `ready_for_build=false` remains appropriate.
