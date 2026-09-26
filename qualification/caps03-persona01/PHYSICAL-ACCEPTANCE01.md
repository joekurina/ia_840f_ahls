# CAPS03 bounded physical acceptance

**Accepted for steady-state operation at the unchanged 3.000 ns target.**
Independent review `deleg_cf5dcc3a` is consumed. No demonstrated timing/CDC defect
requires another fit. This permits offline assembly of the accepted fitted
candidate, **not deployment or unconditional reset-entry acceptance**.

## Completed evidence

The parent independently reverified all20 fit02 and15 sta01 captured members;
all native/CMake/effective/outer returns are0, preservation checks are true,
and no owned residual or postflight error remains.
[Parent verification](physical-parent-verification01.json),
[fit receipt](fit02-outer.json), [STA receipt](sta01-outer.json).

The native summary contains913 numeric, nonnegative slack records, including640
max-skew and144 net-delay records; all reported TNS is0.000. Bank0 worst-corner
setup/hold/recovery/removal is **0.213 / 0.000 / 0.592 / 0.155 ns**. Printed0.000
is not positive hold margin. Global minima for other clocks are not the bank0
reset margins. [Native summary](sta01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.summary),
[complete numeric screen](sta01-numeric-summary.json).

The actual application clock is3.000ns (`ofs_pr_afu.sta.rpt:2782`). Its worst
setup path is completion `aw_count[11]~.rtm_bwd_1` to
`byte_inc[0]~.rtm_bwd_1`, slack0.213ns, a3.000ns relationship and no SDC exception
(`:158198–158218`). The selected100/200MHz user clocks are separate clocks, not
an application-clock slowdown. The reset recovery path is genuinely timed at
0.592ns without exception (`:193299–193319`).
[Full native STA report](sta01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt).

The current `primary_axi`/`map_banks` vendor FIFO constraints have40 pointer-direction
bundles across20 FIFOs, each present at all five corners:200 results, minimum
skew slack1.363ns. The parent independently reconciled this population.
Generic effective pointer net-delay entries have1.366/1.388ns slack. These are
current-instance constraints, not unmatched inherited `ahls_binding|board` names.
Bank0/bank1 pointer transfers use vendor exceptions; host/application transfer
tables also contain cuts, not independent synchronous-path passes.
[Parent verification](physical-parent-verification01.json),
[native STA report, max-skew tables and lines3828/3830](sta01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt).

The root partition remains final-preserved from `ofs_top.qdb`, with
`green_region` Reconfigurable (`fit.rpt:240–247`). Joined-reset logical fanouts
remain1996/1510 (`:17266,17274`). Native Design Closure remains **FAIL**;
LNT-30010 retains1735 CLRN,981 SCLR and513 ENA loads. Numerical timing resolves
the observed timing risk, not arbitrary reset sequencing. The unconstrained
ports are reserved JTAG data/control and `bwbmc_bmc_irq`; illegal and unconstrained
clocks are zero. These findings are retained, not blanket-waived.
[Fit report](fit02-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.rpt),
[signoff DRC](sta01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.tq.drc.signoff.rpt),
[native STA unconstrained section, lines216293–216431](sta01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sta.rpt).

## Remaining reset-entry obligation

The fitted bank0 domain requires **four additional reset-sequence cycles**
(`fit.retime.rpt:139,159`). The selected reset joins synchronize and delay reset;
they do not establish an arbitrary minimum incoming pulse width.
[Native retiming report](fit02-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.retime.rpt).
Altera's reset-sequence guidance says to reuse the existing sequence and add the
reported extra clock cycles to retain functional equivalence.[1]

Parent source-only follow-up identified the existing normal VF-FLR path:

- Work21-bound `flr_rst_mgr.sv` uses separate32-state reset and recovery phases.
  The actual native CSR clock period is9.929ns, not an assumed10ns. Each
  counter-phase budget is317.728ns; four bank0 periods are12.000ns.
- The matched port gasket routes the selected PF/VF reset through `port_rst_n`;
  the fitted standard, non-multiplexed per-port reset instance is retained.
  The selected PIM clock/reset and application join sources were hash-matched
  to the actual STA inputs.
- Do not substitute the PORT_CONTROL FSM's256-cycle default as a universal
  cold-reset guarantee: its cold-reset/deactivation branch can bypass that hold.

Exact source identities, clock arithmetic and their limited scope are in
[reset-entry-source01.json](reset-entry-source01.json). This establishes a
source-bound candidate entry sequence and substantial counter-phase budget,
**not a measured FLR pulse, a full receiver reset-width proof, or live readiness**.
Before hardware entry, bind the actual operation to successful normal VF FLR
with the relevant clocks running, both banks initialized and no prior active
transaction. Keep cold/PR-entry acceptance open until its intended sequence
satisfies the extra-cycle requirement; do not add an arbitrary sleep or claim
that successful enumeration alone proves reset delivery.

The retained exact-kernel review establishes reset-capable VFIO acquisition and
release, not a measured reset count. Its old physical-access blocker is historical;
current operation-specific recovery must be checked rather than inferred from it.
[Kernel/reset source evidence](../caps01-runtime-readiness01/VFIO-RESET09.md).

Stopped-clock and active-transaction reset recovery, hardware arithmetic,
boot/DDR/sustained-operation tests and the separate P-Tile pending-transaction /
teardown issue remain unqualified. Do not infer a global drain or safe FLR from
CAPS03 finite-store completion.
[Lifecycle disposition](../caps01-dma-gib01/ERRATUM11.md).

## Sources

[1] https://docs.altera.com/r/docs/683353/25.1.1/hyperflex-architecture-high-performance-design-handbook/retiming-reset-sequences — Hyperflex Architecture High-Performance Design Handbook 25.1.1 — Retiming Reset Sequences
