# Work17 routed/final exact-path comparison — native result

One isolated copied-project `quartus_sta -t query.tcl` completed native/effective/outer rc0 on2026-09-22T23:05:33.816333–23:07:31.750285UTC, owned tmux@120/%120. Termination confirmed, no live owned PIDs or supervision/acceptance errors. Original Work17/SOURCE/PIM full inventories match prelaunch. Candidate8d557cef3d27a09de294dd461eac7bbaeb23ce8e9005a5922ceb5a3ca0606729 and authorization947a5c2271a7d2ce686f9b7ecea3ed27c1b5464485efb363e1ca473ef06bc531 are SPENT. No fit/source correction/hardware action.

Native query.log37–40 and509–512 confirms actual routed/final snapshots loaded. Both locate exactly one expected UFI input and one exact PHY keeper, and return one hold path. The original SDC is unchanged; Fitter-only10ps overlay emits signoff_unchanged twice in this ordinary STA run (339/804).

Both returned paths are Fast vid2 100C, same bit243 launch→c2p_350_ufi→lane PHY endpoint, with slack−0.004ns, arrival2.964ns, required2.968ns, data delay0.288ns, clock skew−0.080ns and signoff uncertainty0.030ns. Full `Path #1:` body including detailed routing is byte-identical routed↔final. `reports/audit.tcllist` and the two full-path reports preserve actual identities and numerical values; `parent-observations01.json` records hashes.

**This exact reported failure already exists in the routed snapshot.** A later retiming/finalization change is not its origin in this run. This is not a global retiming conclusion, proof of retained Fitter uncertainty, or a corrected design. Final failure reproduction agrees with Work17 full signoff. No new timing acceptance.

Corner-scope limitation: routed report header lists all five delay models, whereas final lists Fast vid2 100C only, despite the explicit native-listed set_operating_conditions selection in both. The actual selected worst-path operating_conditions/corner is Fast vid2 100C in both audit and detailed path body. Do not claim routed evaluation was single-corner-only; this header difference does not erase the observed already-negative routed path at the same reported corner.

Preparation13exports and result10exports are hash-bound to their archives/manifests. Parent native-iteration authority uses existing supervised runner and explicit manifest/candidate checks, not invented source SPEC/QUALITY approvals. Work17 full-build result review is separate. **Independent snapshot-result review pending; timing/hardware/mission remain unqualified.**
