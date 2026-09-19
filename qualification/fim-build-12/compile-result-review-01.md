# Work12 full-compile independent result review — compile-result-review-01

Reviewer scope: independent verification of every Work12 claim from the actual captured artifacts (both full STA parses, images, flow evidence, evidence integrity local/remote-manifest), plus a bounded accept-vs-iterate assessment for the residual −0.004 ns hold. No vendor execution, no remote queries, no source/work/gate edits. Machine-readable counterpart: `compile-result-review-01.evidence.json` (same directory).

## Verdict: **PASS-narrow** — ACCEPT Work12; do NOT iterate on the 4 ps hold

All claimed results reproduced independently from captured bytes. One material correction to the parent's assumed next step: **TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT is already ON in Work12** (inherited from Work11, which was itself the TDC-ON experiment vs Work10). The proposed "TDC ON" follow-up is not an available experiment; it has already run and did not move this path.

## 1. Evidence integrity — VERIFIED

- Manifest `readback/manifest.json`: 31 entries, all 31 rehashed locally, **0 hash failures, 0 size failures**.
- `export.json`: decoded archive 3,795,017 B, SHA256 `9fa7c1710945d2d4b62b1202bbebbecb3cb6b5107a2cb5f3c51fa5009fd1edbc` (declared==computed), 32 members (31 payload + manifest.json); **all 32 members byte-identical to the local readback tree**; no archive-only or readback-only payload files.
- Key evidence hashes (recomputed): status.json `bf9340b2…` (state finished, `gate_rejection:false`), native-status.json `4ee41119…` (**native rc0 @ 2026-09-19T12:36:31.614Z**), runner-returncode.json `f1ace7fc…` (**outer rc0 @ 12:36:31.629Z** — persisted before postflight per runner contract), native.log `437fbe02…` (3,042,729 B), invocation.json `ed280035…` and claim `b8c1d51c…` — both match COMPILE-HANDOFF values; authorization `ad16f23c…` was the prior consumed-once record.
- `compile_fit_assembly_timing_acceptance` = "PENDING REPORT REVIEW" in status.json — correctly not self-claimed; this review is that gate.
- Local tree is the authoritative complete copy; remote twin not re-queried (boundary: read-only remote only if essential — nothing missing locally).

## 2. Full STA parse — W12 and W11 independently (not marker greps)

W12 `ofs_top.sta.rpt`: 46,655,195 B, SHA256 `3dbae18d751539cdc76de0d7f9b6402f6fb71e911a703b59211e6c6ab2a29081` (rehashed ✓). W11: 46,834,561 B, `9b851e84ea597e8c7b8b846d630609ce69ed6436ce555cc853858f6ec91f838c` (rehashed ✓).

Machine parse of all native-console check blocks (Info 332146/332119) — 125 rows per build, identical block structure (setup 17, hold 17, recovery 9, removal 9, min-pulse-width 73); five corner models in both (Slow vid2 100C, Slow vid2b 100C, Fast vid2 100C, Fast vid2a 0C/100C); Final/sign-off delay models.

| Check (worst) | W11 | W12 |
|---|---|---|
| Setup | **−0.508** (emif_0_core_usr_clk, TNS −185.081, 711 ep, Slow vid2 100C); second violation emif_1_core_usr_clk −0.170 (TNS −29.340, 403 ep) | **+0.093** (pcie ptile rx_ch15, Slow vid2b 100C); all 17 rows ≥ 0; TNS 0.000 |
| Hold | −0.004 (emif_1_phy_clk_l_0, TNS −0.004, 1 ep, Fast vid2 100C) | **−0.004** (identical row) |
| Recovery / Removal / MPW | +0.194 / +0.122 / 0.000 | +0.250 / +0.078 / 0.000 |

- Negative rows: W11 exactly **3** (as claimed), W12 exactly **1** (as claimed). Design-wide TNS: W11 −214.421 setup / −0.004 hold; W12 0.0 / −0.004.
- W11 `(VIOLATED)` path details: 20 setup paths (10 per MSA domain, −0.508…−0.493 and −0.170…−0.162) + 1 hold path. W12: **1 unique violated path** (6 textual occurrences = TOC ×2 + per-instance report + summary tables).
- Both prior MSA setup violations are **eliminated**; emif core setup now +0.443 (emif_1) / +0.637 (emif_0).

### The residual hold path (full detail extracted from both reports)

- From `emif_1|arch_inst|hmc.amm.amm.data_if_inst|amm_writedata_0_r[0][243]` (Avalon-MM write-data pipeline reg) → To `emif_1|arch_inst|io_tiles_wrap_inst|tile_gen[2].lane_gen[1].lane_inst|lane_inst~phy_reg1` (PHY lane register).
- Launch `emif_1_core_usr_clk` → Latch `emif_1_phy_clk_l_0`, hold relationship 0.000, clock skew −0.080, data delay 0.288, 1 logic level, arrival 2.964 vs required 2.968, Fast vid2 100C.
- **Numerically byte-identical between W11 and W12** (same endpoints, same times, same skew; only diff in the whole block is a launch-tree node rename `pll_inst~refclk|…` → `pll_inst~refclk_Duplicate|…`, a duplicate-derived-clock naming artifact).
- The path lies entirely inside the **encrypted vendor EMIF arch** (core Avalon domain → PHY lane domain, clocks from the same EMIF IOPLL). No user-SDC-reachable constraint or logic hook exists on it.

### Constraint checker / unconstrained paths (both builds, identical)

1 unconstrained clock (`pcie … u_pciess_clock_divider|clkdiv_inst~div_reg` — Warning 332060), 2 unconstrained input ports (78 path pairs), 2 output ports (10 pairs), setup and hold; `Unconstrained Paths: Fail` in the checker; 8 `set_net_delay` "Invalid clock" rows. **Unchanged W11→W12** — standing OFS upstream baseline, not a Work12 regression, still open for a future constraint-closure pass. Critical Warning 332148 "Timing requirements not met" ×2 in W12 (hold), as expected.

## 3. Flow, stages, images — VERIFIED

- Flow status **Successful** (05:35:52 remote-local); stage elapsed Synthesis 00:07:15, Fitter 00:36:51, Timing Analyzer 00:01:01, Assembler 00:05:40, Total 00:50:47; wall 11:41:16Z→12:36:31Z ≈ 55 min (matches native.log final elapsed).
- Fitter Successful, 78,716/912,800 ALMs (9 %), 321 pins, 1 P-Tile, 8 PLLs, AGFB027R25A2E2V, Quartus 26.1.1 Build 130 SC Pro, Final models. Utilization dropped vs W11 (86,270 → 78,716 ALMs) consistent with the accepted MSA memory correction.
- Effective fitter settings (flow.rpt): `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT = On` (also On in W11), high-performance effort / maximum placement, seed 2 retained.
- Programming images (sizes/hashes recomputed from images.json manifest values, byte counts exact):

| File | Bytes | SHA256 |
|---|---:|---|
| ofs_top.sof | 8,744,710 | `f0710784aff43e76a0acadc48bee84c947951abb8d7fbdfffd9bedb9c9864616` |
| ofs_top.green_region.rbf | 8,458,240 | `e5ebd5849c076aa4e1e5af1e9f51eea157aee905a4a4581f59174121b4e74ecf` |
| ofs_top.green_region.pmsf | 8,109,814 | `18db06019311175a6eb7ef124f87790d978f1d2e26e42ce0b9faf3daa6b7c818` |
| ofs_top.static.msf | 3,341,315 | `241d61e9db4fe30653e3d67bd0b959e051c149d849ef57e600e8ecadec53bfef` |

- Diagnostics: native.log **zero** Error/Fatal-colon lines under a case-insensitive scan including timestamp/DWR-prefixed, `Error (suppressible):` and `Internal Error` forms (the 23 naive word-grep hits are all benign: `$fatal` severity-task synthesis warnings, `vfnonfatalmsg` port names, `m10_seu_error` SDC filter names). syn.rpt's 26 "error" string hits are `$fatal(2, "** ERROR ** …")` literals inside listed vendor RTL; synthesis itself reports "0 errors, 32 warnings". All other stage reports: 0. Gate markers `IA840F_GATE_REJECTED` / `NOT READY` / `EXPERIMENTAL GATE:` / `125091`: **0 everywhere**. `gate_rejection:false`. Design Assistant 19/88 rules failed — CDC/lint baseline category, non-blocking, consistent with prior builds.

## 4. Accept-vs-iterate — bounded technical assessment

**Recommendation: ACCEPT (PASS-narrow). Reasoning:**

1. **The proposed knob is already spent.** TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON is the Work11 experiment, retained in Work12 (verified in both flow.rpt settings tables). The −0.004 hold is identical W10→W11→W12, so aggressive hold closure has already failed to move it. There is no supported "TDC ON" follow-up experiment left.
2. **The path is seed/place-insensitive.** W11 and W12 are materially different fits (86,270 vs 78,716 ALMs; 45:32 vs 36:51 fitter; post-MSA-correction placement changes), yet the violated path is numerically identical to the picosecond. It is structurally determined by the EMIF core→PHY relative layout inside the vendor domain, not fitter luck. A seed-only rerun has low expected value.
3. **A seed roll has real downside risk.** The newly won MSA setup margins are modest (+0.443/+0.637 ns emif core setup; +0.093 ns worst overall PCIE). A re-roll plausibly reopens the −0.5 ns-class MSA setup violations — strictly worse — while costing a once-only build number, ~55 min vendor compute and a full evidence/authorization cycle.
4. **Magnitude and domain.** −0.004 ns = 4 ps on a single endpoint, fast-corner (Fast vid2 100C) check, on a 0.288 ns data path inside the encrypted EMIF arch. Final-model fast-corner delay uncertainty (routing-level quantization alone ≈ 5–15 ps) exceeds the violation; the PHY-internal segment is deskewed by EMIF runtime calibration rather than static core timing. Treat as within model noise; not a functional-red flag for the STA-evidence acceptance scope.
5. **Fitter effort is exhausted.** High-performance effort + maximum placement + SPEED/MAX router already active; previously reviewed assignment-enum evidence shows the remaining router/physical-synthesis knobs are not Agilex 7 applicable. No contract-preserving single-variable experiment with a credible mechanism remains for this path.

**If the parent nevertheless wants one more data point** (not recommended): the only defensible minimal experiment is a **seed-only change (e.g. seed 3), everything else identical** (clocks, SDC, geometry, constraints, effort, TDC ON retained) — explicitly labeled exploratory, with risks: (a) may reopen the eliminated MSA setup violations, (b) expected no hold change per point 2, (c) consumes a build/authorization cycle. EMIF-parameter or SDC changes to reach this path are **not** acceptable single-variable experiments (contract-changing or vendor-internal).

**Residuals kept open (unchanged, non-blocking):** unconstrained-path closure Fail (1 clock / 2+2 ports); Design Assistant 19/88; no separate DDR sub-report captured (EMIF DDR IO timing is carried by the EMIP/EMIF timing flow, not core STA — same handling as W11); all qualification flags (readiness, timing-functional, calibration, functional) remain **false** — this is STA evidence acceptance only, standard-exerciser AFU, no hardware/DDR-sim claims.

## Disposition

Work12 result evidence: **accepted**. Parent may flip `compile_fit_assembly_timing_acceptance` from PENDING REPORT REVIEW on the strength of this review; the −0.004 ns hold is recorded as an accepted, bounded residual on a vendor-internal EMIF path.
