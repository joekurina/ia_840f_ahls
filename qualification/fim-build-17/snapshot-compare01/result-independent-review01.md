# Work17 snapshot comparison — independent result review

**Verdict: PASS for narrow native diagnostic evidence only.** The same reported hold violation already exists in the routed snapshot; a routed-to-final change is not its origin in this run. This is not timing acceptance or approval for another execution.

## Acquisition and preservation

Independently decoded the gzip JSON archives and strict-base64 artifact bytes. All **13 preparation exports and 10 result exports** match their recorded sizes, SHA-256 values, manifests and local readbacks; the report manifest also matches. All **44 freeze bindings** were verified before review and rechecked at completion.

The candidate, issuance receipt, claim, process record, native log and execution status agree on one copied-Work17 `quartus_sta -t query.tcl` run. Native/effective/outer statuses are zero; completion is unique; termination is confirmed with no remaining owned PIDs, abort or supervision/acceptance errors. Native output records 0 errors and 374 warnings—not a warning-free or globally qualified design. The runner is an exact mechanical retarget of the prior supervised runner, not a new execution framework. Authority is the recorded parent-bound native-iteration procedure, not invented source-review approval.

The standalone baseline and preparation preservation inventory are equal: SOURCE 1,659, PIM 536, Work17 7,622 entries. Candidate comparison finds only recorded scratch relocations and gate changes; all 387 routed/final QDB entries match Work17. Source-bound prelaunch checks and postflight receipts report all three original inventories unchanged. These are independently inspected captured attestations, not fresh remote measurements.

## Snapshot, constraint and path identity

`query.log:37–40` and `509–512` explicitly load routed and final snapshots for all four named partitions. The Tcl deletes each timing netlist between stages; report headers independently identify the two snapshots.

All 73 Work17 and eight PIM `.sdc` inventory entries match the prepared copies; exported `top.sdc` matches its original inventory hash. Both stages use ordinary `read_sdc`, with identical 110-entry native SDC-read sequences. Both emit `signoff_unchanged` (`query.log:339,804`); the Fitter-only overlay is skipped. The log retains five original Work17 `cpt_proxy` SDC paths, all baseline-bound and copy-equal; do not infer hermetic filesystem access.

The query enforces singleton collections and exact raw names for the UFI input and PHY keeper. Both return one selected hold path from `amm_writedata_0_r[0][243]`, through `c2p_350_ufi.ufi_inst|d`, to `tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`, with identical full hierarchy and launch/latch clocks. Both audit and detailed body identify **Fast vid2 100C Model**: slack **−0.004 ns**, arrival **2.964**, required **2.968**, data delay **0.288**, skew **−0.080**, uncertainty **0.030 ns**; no SDC exception on path.

The complete 49,357-byte suffix beginning with `Path #1:` is byte-identical, including routing. Parent hash `ba55999b…` correctly covers the suffix *after* that marker, not including it; this boundary clarification does not change equality.

## Limits

Despite explicit `MIN_fast_vid2_100c` selection, routed's header lists five delay models; final's lists one. Therefore this is a same-returned-corner/path comparison, **not proof of single-corner-only acquisition**. It does not measure the effective Fitter optimization objective or retained Fitter uncertainty, establish global absence of retiming, identify an earlier causal stage, or qualify other paths, CDC/DRC, hardware or mission behavior. Full Work17 build review remains separate. No integrity discrepancy blocks this narrow verdict.

## Exact SHA-256 bindings

| Artifact | SHA-256 |
|---|---|
| Review freeze | `adf6eda46a15bd71d1e230b99b46ff6f7d20efff97dceb0c0f18a80c76f53ad8` |
| Preparation archive | `cc58fde2ea6a12aa8348f2fb534d921b5c02cde9258e8d029a8a1d721cf08560` |
| Result archive | `8c613390b37db0eba12ec4f3cb8b7a05ee9f5446a5fd12cc3c2e858b01f31113` |
| Candidate | `8d557cef3d27a09de294dd461eac7bbaeb23ce8e9005a5922ceb5a3ca0606729` |
| Baseline archive | `705fd360bd5ecce2bb99344dae7aca75de8e9835462f6c2ff47babef0cb85430` |
| Original/prepared top.sdc | `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814` |
| Routed report | `71a6cbb13e842774f18da8b01fbe98bcddbdb5838082c1bc0144cf3fcd3ebe9d` |
| Final report | `a4f0639789f2813ac82445aa1dc1db9ec1053ee0e13f5779fad3ad62b65ec032` |
| Shared suffix including marker | `5dadcde0333026c7feb5c3bf082ec2ca945c700fdf52b1c973ada70f10f97863` |
| Shared suffix excluding marker | `ba55999b8b749d836880d7c650d8d43fdbe2e5daa6e159178fa7fc1127aa81c4` |
