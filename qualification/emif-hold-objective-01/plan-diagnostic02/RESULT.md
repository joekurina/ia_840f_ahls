# Plan diagnostic02 — native rc3, partial setter evidence

One-use run spent. Native/effective3; termination confirmed, no live descendants or supervision errors; original Work15/SOURCE/PIM comparison outcomes true. Verified7 exported files, result archive SHA256 `4b2aadb427a614614f4769a096cafcfea352bbb26848462c27aa06d5d3aac061`. Independent actual-result review is consumed in RESULT-ACCEPTANCE.md; acceptance is limited to failed execution and the exact partial setter observation, not timing/effective-objective acceptance.

Native query.log:374 recorded:

```text
Info: EMIF1_HOLD_ISSUED app quartus_fit from local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_core_usr_clk to local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0 phy_index 0 same_tile_index 0 add_mode -add C2P_HOLD_OC_NS 0.000 issued_ns 0.0 multi_tile_base 0.366 periphery_uncertainty {0.0 0.0 0.0 0.0} overconstraints_st {0.000 0.000 0.000 0.000} overconstraints_mt {0.0 0.0 0.0 0.0} from_count 1 to_count 1
```

Same-tile branch0→0 uses -add with0.0ns, C2P_HOLD_OC_NS0.000, both clock collections singleton. This is the issued additive value, NOT total effective uncertainty; later SDC loading failed. The diagnostic's source of external diagnostic.tcl was rejected by the Fitter project database (Error19104/332000). This is instrumentation packaging failure, not a production clock-constraint diagnosis. No callback registration/report completed. Derived44-clock output followed a failed SDC read; do not accept it as a complete baseline. Planned database commit does not override rc3.

Successor03 uses a fresh original Work15 copy, embeds the identical callback definitions inline instead of external source, and preserves every existing timing setter/exception/parameter/seed. It does not reuse this failed planned database.
