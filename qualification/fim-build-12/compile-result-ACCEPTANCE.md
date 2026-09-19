# Work12 result review — parent acceptance

Date: 2026-09-19 (PDT)

## Accepted

`compile-result-review-01.md` (SHA256 `ba219f36…`, full hash recorded in the
file's evidence twin) — **verdict PASS-narrow → ACCEPT Work12; do not iterate
on the residual 4 ps hold violation.**

The review independently reproduced every Work12 claim from captured bytes:
31/31 evidence-manifest rehash, both full STA reports machine-parsed
(Work11: 3 negative rows → Work12: 1), native rc0 + outer runner rc0
persisted, zero genuine Error/Fatal diagnostics, `gate_rejection:false`,
all image sizes/hashes, and flow stage elapsed times.

## Material correction adopted

`TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT` was already ON in Work12 (inherited from
the Work11 experiment). A "TDC ON" follow-up is therefore not an available
experiment — it has effectively already run (W10→W11→W12) and did not move the
−0.004 ns hold path on `emif_1_phy_clk_l_0`. The path is placement-insensitive
(identical across two materially different fits) and lies entirely inside the
encrypted vendor EMIF arch, where 4 ps is below fast-corner model quantization
and the PHY segment is calibration-deskewed. If a further data point is ever
required, seed-3-only (all else fixed) is the sole defensible single-variable
experiment, with explicit risk of reopening the eliminated MSA setup
violations.

## Scope of this acceptance

Timing-evidence acceptance for the Work12 compile only. Concretely **not**
claimed: functional readiness, calibration association, constraint
completeness (unconstrained-path Fail and DA 19/88 remain open, non-blocking),
DDR simulation (skipped by user), AHLS AFU functionality (build contains the
default standard-exerciser AFU), or any hardware operation. All
readiness/qualification flags remain false.

`compile_fit_assembly_timing_acceptance` in Work12 `run/status.json`
("PENDING REPORT REVIEW") is now satisfied by this record.

Next milestone: AHLS AFU integration (the actual AHLS-generated RTL as the
AFU in place of the default exerciser), then PR release packaging and
hardware bring-up.
