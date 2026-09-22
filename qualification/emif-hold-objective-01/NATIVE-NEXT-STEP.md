# Native next step: EMIF1 hold objective

**Use a diagnostic-only Plan run on an independent Work15 copy. Do not use `quartus_fit -t` to create a timing netlist.** Plan is the shortest **evidence-backed stage** that reads this EMIF SDC and creates the exact clock pair. It can expose the vendor's issued objective; obtaining the final effective, derived-plus-overridden uncertainty additionally requires the reporting hook identified below. No supported read-only reopening of Work15's historical Fitter timing state is established.

## Why Plan, not another full fit

`fit-help03.txt:21,172` proves STA package loading succeeds but `create_timing_netlist` is unsupported in `quartus_fit`. Package availability is not command availability. `read_sdc -post_fit/-post_syn` does not change the executable identity. Do not spoof `TimeQuestInfo`.

Actual Work15 evidence is stronger than generic stage descriptions. In `../fim-build-15/completion-readback01/evidence/run/native.log`:

- 8351–8359: native Fitter opens the synthesized database.
- 8389: periphery placement starts.
- 8695: the exact generated EMIF1 `..._ym4dzra.sdc` is read.
- 8998,9002: both `emif_1_core_usr_clk` and `emif_1_phy_clk_l_0` exist.
- 9041–9042: Plan/periphery placement ends; 9040 says intermediate snapshots were disabled.

Thus Plan reaches this SDC and pair before placement/routing. The original Plan took 00:09:38; that is history, not a runtime promise. It does **not** preserve the final Hyper-Register path for path-delay reporting.

Parent-run command, from a self-contained scratch copy including Work15's synthesized database and dependencies:

```sh
cd "$SCRATCH_COPY/syn/board/ia840f/syn_top"
/opt/altera/26.1.1/quartus/bin/quartus_fit \
  --plan --read_settings_files=on --write_settings_files=off \
  ofs_top -c ofs_top
```

All options are present in `fit-help01.txt`. Preserve existing environment/settings/seed2. No synthesis, place, route, finalize, assembly or hardware step is requested. The copy must not share writable databases or the instrumented SDC through hardlinks/symlinks with Work15. `--write_settings_files=off` does not prevent database/report writes.

## Exact diagnostic insertion

In **the copy only**, insert this immediately after original line 1006 of `mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra.sdc`, retaining the original `set_clock_uncertainty` unchanged. Its directory is identified by native.log:8695 and the generation-source link in `../fim-build-15/next-iteration-recommendation01.md`.

```tcl
set __e1_hold_P {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1}
if {$fit_flow == 1 &&
    $local_core_clock eq "${__e1_hold_P}|emif_1_core_usr_clk" &&
    [set local_phy_clk_l_${i_phy_clock}] eq "${__e1_hold_P}|emif_1_phy_clk_l_0"} {
    post_message -type info [list EMIF1_HOLD_ISSUED \
        app $::TimeQuestInfo(nameofexecutable) \
        from $local_core_clock \
        to [set local_phy_clk_l_${i_phy_clock}] \
        phy_index $i_phy_clock same_tile_index $same_tile_index \
        add_mode $add_to_derived \
        C2P_HOLD_OC_NS $var(C2P_HOLD_OC_NS) \
        issued_ns $c2p_h \
        from_count [get_collection_size [get_clocks $local_core_clock]] \
        to_count [get_collection_size \
            [get_clocks [set local_phy_clk_l_${i_phy_clock}]]]]
}
unset __e1_hold_P
```

This records actual branch indices, exact names, collection sizes and the value passed to the native setter. Use `post_message`, **not** vendor `post_sdc_message`, which suppresses Fitter messages (`..._utils.tcl:244–249`). Retain every occurrence: Fitter rereads constraints. Missing markers or non-singleton collections are missing evidence, not zero uncertainty.

The native-path identity remains bit243 → `tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1`, through `c2p_350_ufi`; the complete names are in the existing recommendation. This diagnostic targets its exact clock transfer, not a neighboring bit or all EMIF clocks.

## What still separates this from the effective objective

`issued_ns` is **not automatically total uncertainty**. Original SDC:983–1008 uses either explicit override (empty `add_mode`) or derived uncertainty plus `-add`; later SDC can supersede either. Native.log:8696 expressly defers uncertainty calculation until timing-netlist update.

The supported report grammar is:

```tcl
report_sdc -ignored -stdout
```

There is no `-hold_uncertainty` selector. Run this only at an established **post-SDC, post-update Fitter reporting point**, then retain the exact pair's effective uncertainty and assignment history.

**Precise missing API fact:** how to reach that point in a bounded Plan invocation with its native timing netlist and report database still open. The official [26.1 Scripting guide](https://docs.altera.com/api/khub/maps/GVZ07Sa8_SDeLZRDISur9g/attachments/JLm0lJdqyju_Iupu2CYJPw-GVZ07Sa8_SDeLZRDISur9g/content?download=true&locationValue=reader), §4.1.38.42, documents `register_delete_timing_netlist_callback <body>` before deletion. It does **not** establish that Plan invokes this callback after its last update, or that reporting is valid there. Check that specific installed callback/driver behavior; do not assume it or call `update_timing_netlist` recursively inside SDC. No full-fit rerun is needed merely to resolve this fact.

A Plan replay is new native evidence, not recovery of the historical Work15 objective. `C2P_HOLD_OC_NS=0.000` is already established; hidden `DIAG_EXTRA_CONFIGS`/qini plumbing supplies no public legal numeric domain. This inspection neither edits that value nor proposes a correction, waiver, seed sweep or generated-PHY RTL change.
