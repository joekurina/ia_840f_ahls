# Work15 — native result accepted; clock corrected; timing FAIL

Joe explicitly directed Quartus→reports→correction→Quartus instead of more mocks/repeated source reviews. ITERATION-AUTHORITY.md records the amendment. Production-clock01's43-line guard/mock detour is stopped and unpromoted. Do not restart its review or wait for delayed notices. No new independent source SPEC/QUALITY is claimed; parent exact-source/retarget/prepared checks and actual-result review remain distinct.

## Latest verified progress

Independent actual-result review and next-iteration recommendation `deleg_6a2be4c6` are complete and parent-consumed: `RESULT-ACCEPTANCE.md`, `parent-result-consumption01.json`. Native compile/fit/STA/assembly and narrow fresh-fit PCIe clock progress accepted; timing still FAIL, hardware unqualified. All55 frozen files and19/16/9 exports reverified. Original80 clocks unchanged plus corrected C; all eight formerly invalid FIFO constraints now numerical, minimum15.369ns. No live reviewer or pending approval from that batch. Next concrete work: `../emif-hold-objective-01/` captures installed hold-objective control evidence. No new fit or guessed assignment issued. Earlier running/pending statements below are chronological provenance, superseded by this paragraph.


Parallel warning review `deleg_7e4900c1` has been received and parent-verified; see `warning-review01/PARENT-DISPOSITION.md` and `parent-consumption01.json`. Triage is complete, findings remain open. Full SYN/FIT confirm 495/208 diagnostic rows; the 80-group/81-native-total synthesis discrepancy remains explicitly unresolved even after full-report read. Full fitter panels narrow electrical warning25315 to three BMC signals plus SYS_REFCLK and prove green_region/place/route constraints remain present. ECC exported error is confirmed unconnected; no correction is yet applied. The actual-result and next-iteration reviewers are no longer live; their delivered results still need parent consumption. No duplicate review dispatch or build.


Work15 finished at **2026-09-22T18:47:29.363718Z**, native rc0, no gate rejection; completion capture found no matching live native processes. Fitter and assembler report Successful. Overall flow reports 0 errors / 894 warnings (stage counts are separate, not additive). **Timing FAIL:** EMIF1 hold remains −0.004 ns / TNS −0.004 at Fast vid2 100C; setup minimum +0.151 ns. The PCIe avmm_clock0 now has numerical setup/hold results. Signoff still has 7 failing High rules / 34 violations / 0 waived. No timing or hardware acceptance.

Full evidence: `completion01.json.gz` plus `completion-manifest01.json`, `reports01.json.gz` plus `reports-manifest01.json` (9 complete reports), `result-review-freeze01.json` (55 frozen inputs), `timing-summary-observations01.json`, `parent-observations01.json`. New FME interface: `fd2baeed-3092-5735-90c9-52ef20542b75`; old personas do not inherit compatibility. SOF/RBF hashes are captured, not programming authority.

Postrun `postflight01.json.gz` and summary verify original Work14/PIM unchanged. SOURCE has the recorded 3-file prelaunch overlay plus one new native build log; it is NOT fully byte-identical. Launcher `build_top.sh:163,190` accounts for that log. Work15 recorded input changes are the two native FME metadata files only. Independent actual-result review and a focused next-iteration recommendation are running as `deleg_6a2be4c6`; see `result-review-dispatch01.json`. Do not rerun/reissue Work15 or waive hold. Earlier RUNNING sections below are historical checkpoints.


At 2026-09-22T18:40:22.341796Z, Work15 fitting completed successfully and final timing analysis is running (`quartus_sta` PID 28265 under the original `quartus_sh` PID 24806). Evidence: `status04.json`, `progress04.json`; fitter summary SHA256 `b6897e95d0a6028b70035c2eb918d5ef5e18887228d13da9533c8cc3b866bf91`. The full run has not reported completion; timing and hardware are not accepted. Do not infer EMIF hold resolution from partial DDR output.

Joe requested parallel actual-warning review. `deleg_7e4900c1` / `sa-0-671fd452` is reviewing the captured full native-log prefix, synthesis/fitter diagnostic rows and local source. Inputs are bound by `warning-review01/manifest02.json`; expected outputs are `REVIEW.md` and `findings.json` there. This is native-warning triage, not a new build approval gate; no source changes or remote/vendor actions by the child. The first collection hit the report-size cap and returned to the shell; capture02 completed with a bounded streaming extraction. The original compile and exit notification remain unchanged.


At2026-09-22T18:10:44.680396Z, the same native fitterPID25882/start identity remains active, with47246additional CPUticks since status02. Evidence status03.json/progress03.json; no final fitter/STA result yet. The delayed deleg_07ecaf28 reports were hash-verified against the already-consumed design disposition and next-fit anchors; no new review or rerun is needed. Completion notification remains proc_576af98f4e94 (completion-notification01.json).


At2026-09-22T18:04:37.467057Z, native synthesis completed successfully with0errors/81warnings; ofs_top.syn.summarySHA35deefbabb19d9b43cf3a000a946e6789d3c683864af724c38889eb1efe525a2. Native quartus_fitPID25882 is active under the original invocation. Evidence status02.json. Fitting/STA/assembly remain pending; no timing acceptance. The cancelled production-clock01 source SPEC returned interrupted, no verdict; it is not a dependency and will not be restarted.

An ordinary process-exit event waiter is dispatched (exit-wait-dispatch01.json), bound to the recorded runner PID/start ticks. It waits on a pidfd without polling or signaling and captures only owned status files; no hardware/vendor action. Its event means runner exit, NOT automatic full-descendant termination/timing acceptance.

## Current execution

- Fresh remote WORK: /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_15.
- Owned tmux ia840f_mailbox_monitored_01, native @59/%59. Started2026-09-22T17:55:17.352306Z, runnerPID24751, native build_topPID24789. AuthorizationSHA c691e5faa2a0260397f3683d88fd4fb1c8814d195ee028997d6c812a535d49b2. Single-use: never reissue/relaunch.
- Actual status at17:56:22.454956Z: running, quartus_shPID24806 and quartus_synPID24839 active. IP generation completed0errors/0warnings. Fit/STA/assembly not yet complete or accepted. Evidence status01.json; status capture @60/%60.
- Quartus26.1.1, AGFB027R25A2E2V. Existing compile flow, seed/effort/hold settings unchanged. No hardware/device/programming/reboot action.

## Preparation and source

Ordinary-file preparation @58/%58 finished successfully, non-consuming issuer preflightPASS:5424 existing generated inputs,135 finite native contexts, originalWork14/PIM preserved. SOURCE changed in exactly3files: native-supported4-line top.sdc declaration plus2 mechanical gate retargets. No full-fit database/output copied. Memory available126133604352bytes; disk1375284563968bytes at preflight. Source/target/master/divide2 are from the accepted clock-trial02 result published77a5339e765ad89d130face4740f2f5d506dc3bb; exceptions preserved byte-for-byte.

Prepared archiveSHA0b7aae6d8a878ac0231af8c97a2a7f65cf6a7e2759fd4a53d8e44d8b5973bac2,19 exports verified. Package manifestSHA3f8ce25ae9a62d75e9ab80f41db0c43152ea42135c58a82b17e7dc324b6fe317. Exact top.sdcSHAb706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc is applied remotely and synchronized to the local maintained SDC. Local maintained gate copies have NOT been silently overwritten; actual successor gates are captured under prepared-readback01/compile-candidate-01/gate-copy.

The preparation window exited after the script; its outer rc was not captured. Unique buffer/preparation receipt establishes complete=true/preflightPASS/no vendor invocation at that stage. Do not rerun it. The launch receipt has a literal backslash-n trailer; raw bytes are retained in status01.json and issuance-readback01.json documents exact decoding. This does not modify the authorization or running inputs.

## Next action

Read only this owned build's status/logs and actual synthesis/fitter/STA reports through tmux. Let real Quartus failures determine the next correction. Do not edit live bound source, rerun the current build, expand mocks or resume paused source reviews. On completion collect full timing, unconstrained/CDC/HighDRC, clock/FIFO results, assembly and image identities; independent actual-result review precedes timing acceptance. EMIF1hold−0.004ns and previous HighDRC findings remain unresolved until actual new results say otherwise. Hardware recovery/backend, matching persona, DDR/transfers/AHLS/PR/sustained/QSPI criteria remain open. ready_for_build=false; goal incomplete.
