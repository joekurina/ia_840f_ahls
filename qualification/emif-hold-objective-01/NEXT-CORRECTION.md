# Next EMIF1 hold correction

## Decision

**Recommend the exact-pair 10ps Fitter-only overlay as the next bounded optimization experiment, subject to a narrow last-writer check—not as a validated fix.** Missing absolute Fitter uncertainty is not itself a blocker. The supplied captures do not establish the complete later-SDC precedence chain; that is the concrete preflight still owed before claiming an unconditionally tighter objective.

Paths below are relative to this evidence directory; `D3` means `plan-diagnostic03`.

## What the native evidence establishes

- `D3/result-readback01/query.log:374,721` records the same exact EMIF1 transfer twice: singleton clocks, `phy_index=0`, `same_tile_index=0`, `-hold -add 0.0`, and `C2P_HOLD_OC_NS=0.000`. The printed `multi_tile_base=0.366` is **not** this branch's objective. Generated `D3/prepared-readback02/instrumented.sdc:983–1006` confirms the same-tile branch relies on derived uncertainty.
- Plan completed with 81 clocks, zero errors and 206 warnings. Both reporting callbacks failed because their underlying command is STA-only; no effective uncertainty was acquired. Do not retry those callbacks, spoof `TimeQuestInfo`, or repeat the unchanged Plan.
- `D3/native-reports-manifest01.json` distinguishes fresh Plan/aggregate/summary reports from unchanged copied Work15 place/route/retime/finalize reports. There is no fresh full-fit timing result or effective-uncertainty panel.
- `../fim-build-15/reports01/output_files/ofs_top.sta.rpt:126779–126895` shows Fast vid2 100C, bit243 Hyper-Register → `c2p_350_ufi` → `phy_reg1`: arrival 2.964ns, required 2.968ns, slack −0.004ns. The actual uncertainty increment is 0.030ns in all five signoff corners (`work15-hold-components01.json`, full-report hash verified). This is signoff evidence, **not** the Fitter total.

## Minimal proposed source delta

Append only this timing change to existing `syn/shared_config/top.sdc`, after its existing constraints, with vendor-generated SDC unchanged:

```tcl
if {[info exists ::TimeQuestInfo(nameofexecutable)] &&
    $::TimeQuestInfo(nameofexecutable) eq "quartus_fit"} {
    set_clock_uncertainty -hold -add \
        -from [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk}] \
        -to [get_clocks {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0}] 10ps
}
```

The read-only tool-identity guard follows the generated SDC's own branch convention (`instrumented.sdc:43–55`). At application, require exact singleton collections and record a simple native setter marker; do not suppress missing-clock warnings or treat a marker as proof of retention. Apply on every Fitter SDC load, not behind a process-wide “already applied” flag. Final `quartus_sta` must skip this block and retain all original constraints.

This covers hold/removal checks, both transition polarities, for **all paths on this directed clock pair**, not bit243 alone. It excludes EMIF0, other PHY clocks, reverse P2C and setup/recovery uncertainty. Placement changes can nevertheless affect setup elsewhere. Preserve both DDR instances and the existing two-DDR/16GiB configuration, clocks, PR, PIM, P-/F-Tile settings, seed and already-enabled optimization settings. No hidden `DIAG_EXTRA_CONFIGS`, PHY RTL edits, waivers or new false paths.

## Semantics, precedence and edges

Installed 26.1.1 native help (`fit-help05.txt:31–83,150–159`) establishes:

- `-add` adds to **derived uncertainty**, not previous manual setters; the later matching assignment replaces earlier assignments. Thus this replaces the observed additive zero, rather than accumulating across repeated loads.
- Positive hold uncertainty increases required time. With the same derived component and applicable edges, replacing additive zero by 10ps makes the requirement 10ps tighter. The absolute derived value need not be known to establish that relative change. This is not a measured Fitter total, nor a guaranteed slack improvement after refitting.
- Ordinary derivation is automatic; existing `top.sdc:25` calls it without options. `derive_clock_uncertainty -overwrite` ignores manual setters. Do not add that option or reorder derivation.
- Same-physical-edge transfers ignore uncertainty by default. Equal 0.000 launch/latch timestamps do not prove physical-edge identity; “same tile” is also not “same physical edge.” Work15's nonzero applied uncertainty supports applicability at signoff, not proof inside Fitter. Do not add `-enable_same_physical_edge` speculatively.

## Concrete next action and falsification

**Parent: inspect the ordinary SDC chain following `top.sdc` for overlapping setters/removals and derivation overrides.** Native first-pass order is EMIF1:372 → top:415 → bti_refclk:491 → pmci:492 → bwbmc:618 → proxy SDCs:619–626 → derivation:628. File names alone do not prove non-overlap; the second load's abbreviated messages do not prove identical precedence. If clear, use this single delta in the next full native fit and unchanged final STA, not another diagnostic baseline.

Reject the tighter-objective claim if the overlay is absent, unmatched, superseded, removed, edge-ignored, or the baseline winning setter differs from additive zero. Reject a closure claim if fresh all-corner STA retains any failure, introduces regressions/unconstrained paths, or applies the overlay during signoff. Unchanged failing slack disproves closure, not necessarily setter application. **Signoff and hardware acceptance remain false.**
