# First matching persona fit — accepted with findings

**Accepted:** the one completed26.1.1 FIT stage, execution/output integrity, native-reported root/PR preservation and recorded immutable-input preservation. Independent [fit34](fit-result-review34.md) and [diagnostic/reset35](fit-diagnostic-reset-review35.md) reviews are consumed after220-member revalidation. [Consumption37](result-reviews-consumed37.json).

Fresh STA preparation may proceed. This is **not timing, reset-entry, electrical, assembly or hardware acceptance**, a diagnostic waiver or a new execution authority. Keep the completed fit untouched; no unchanged refit or resynthesis is needed.

## Accepted stage evidence

Native/CMake/effective/outer/wait/readback outcomes are0, execution-clean true, no postflight errors or owned residual groups. Runtime2127.124458s.53 captures/74,109,997bytes plus five unchanged predecessor report bodies reconcile;729 QDB files/380,651,175bytes were remotely hash-reverified. All13 preservation checks pass, including original mapped bytes and exact entry set; QPF is byte-identical. [Verification32](native-result-verification32.json), [index30](completion-index30.json).

The final native table reports root Default/final/from `ofs_top.qdb`, green_region Reconfigurable and auto_fab_0 final. Static QDB SHA256 remains `dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4`. This supplies fitter-stage corroboration absent from the earlier synthesis table, without asserting functional PR/hardware equivalence. [Report:245–253](completion30-readback/reports/ofs_pr_afu.fit.rpt), [review34](fit-result-review34.md).

Runtime-output changes are explicitly scoped:832 unchanged,31 changed,0 removed among863 admitted entries, including database re-materialization—not solely logs. These FIT roles are not a future STA exemption list. Resource labels remain123,298 ALMs needed versus106,867 actually used in final placement; device-model “Final” is not timing closure.

## Findings retained into STA and later qualification

- **Unused PR inputs:**47 boundary ports include four unused divided/user clocks, bank ID/user metadata, freeze and debug inputs. Five Critical20727 occurrences do not justify noprune/interface changes or prove safe dynamic PR.
- **Constraint coverage:**139 constraint diagnostics remain. Old `ahls_binding|board` FIFO endpoints do not constrain current `primary_axi`/`map_banks`; actual generic PIM pointer/skew/net-delay and bidirectional CDC coverage must be verified. Empty collections, pin-name alternatives, EMIF/user-clock overwrites and effective exception precedence remain visible. Preserve the exact exported SDC and all source constraints.
- **Ignored assignments:**1,098 native entries include16 current fabric reset-synchronizer rows as well as vendor/EMIF attributes. Require current effective CDC/reset/EMIF timing disposition; no speculative vendor override.
- **Electrical:** omissions for `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso` and `SYS_REFCLK` remain before hardware. Native processor-count warning20031 is separate from the admitted CPU-affinity/QSF resource request; no fixed worker-count claim.
- **Reset:** three additional `clk_sys` cycles and seven additional bank0 memory-clock cycles extend an already-valid sequence, not total pulse widths or sleeps. Do not inherit the older four-cycle bank0 result. Rebind normal VF-FLR/clock-running/banks-initialized/no-active-work prerequisites later.
- **DRC:** Finalize Design Assistant did not run(no enabled rule). Reused synthesis5/13 failed rules/15 violations/seven disabled rules and73 initialization rows are not a new physical DRC pass. Retimer dependency-loop and “No further analysis” observations do not substitute for all-corner setup/hold/recovery/removal/MPW.

Exact populations, source locations and limits are in [review35](fit-diagnostic-reset-review35.md); nothing above is waived.

## Next gate

Use a fresh copy of the [completed4025-entry fitted workspace](sta-copy-basis36.json). Bind current physical snapshots and source/SDC/settings/tools while defining STA-specific mutable reports/caches and new frequency output. The OFS STA hook is state-changing: it computes clock metadata, rereads SDC and rewrites timing reports. Preserve bank0's3.000ns application requirement and the separate auto200/100 user requests. Fmax fallback values or an empty failure file cannot conceal missing timing coverage.

After fresh SOURCE/runtime review and exact admission, run final-snapshot multicorner STA. Actual clocks/endpoints, exception precedence, unconstrained paths/I/O, bidirectional CDC/synchronizers, pointer skew/net-delay, signoff DRC and reset/electrical disposition remain mandatory. Assembly/images, deployment and all migrated hardware gates remain open. The migration goal is not complete.
