# Work14 initial fitter / timing result — assembly pending

**Fitter completed successfully; timing is NOT accepted.** This is a bounded result readback, not independent full-build review, final native completion or hardware qualification.

## Stage evidence

At **2026-09-22T05:22:44.503097+00:00**, [status10](status10-summary.json) records the original Quartus flow PID 7644 and assembler PID 10955 in the authorized Work14 cwd. The runner still reports `running`; no final native status existed at that snapshot. Fitter reports success with **0 errors / 222 warnings** and target `AGFB027R25A2E2V`. Do not restart or reissue the consumed compile.

Five complete, stable ordinary reports were retrieved in @30/%30 at **2026-09-22T05:24:07.809085+00:00**, with whole-transfer and individual-file size/hash checks. [Manifest](reports11/manifest.json). No vendor command, device access or live design edit was performed by this collection.

## Timing findings

The [full summary analysis](reports11/timing-summary-analysis.json) parses all **743** `Type` blocks in the captured summary and retains nonnumeric entries rather than dropping them. Observed worst numeric values:

| Check | Slack (ns) | Reported corner |
|---|---:|---|
| Setup | +0.015 | Slow vid2 100C Model |
| Hold | **−0.004** | **Fast vid2 100C Model** |
| Recovery | +0.214 | Slow vid2 100C Model |
| Removal | +0.132 | Fast vid2a 0C Model |
| Minimum pulse width | 0.000 | Slow vid2 100C Model |

These are Work14 FIM results, not qualification of the earlier AHLS persona. The failed hold clock is `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1_phy_clk_l_0`, with TNS −0.004 ns. The [summary](reports11/output_files/ofs_top.sta.summary), lines 90–93, supplies the clock/corner/slack; the [full STA](reports11/output_files/ofs_top.sta.rpt.gz), lines 209795–209801, independently reports the EMIF1 DDR-core hold failure and `DDR Timing requirements not met`. The magnitude matches the earlier W13 checkpoint, but this Work14 corner is **Fast vid2 100C**, not W13's recorded slow corner; no identical physical path or identical cause is inferred.

Full STA Design Closure Summary, lines 2716–2739, explicitly marks overall closure, hold, DDR and unconstrained paths **Fail**, with high-severity Design Assistant findings. Setup, recovery, removal and minimum-pulse-width summaries are marked Pass, which does not override overall failure. Unconstrained Paths Summary, lines 209843–209854, lists one unconstrained clock, two input ports (78 path pairs) and two output ports (10 path pairs) for both setup and hold. Lines 209811–209818 report invalid PCIe `set_net_delay` assignments with missing destination clock periods. These findings require scope/source disposition; they have not been waived or classified as benign. Design Assistant reports high-severity violations at line 209821; detailed signoff review is pending.

The main STA process reports 0 errors / **260 warnings** at lines 209835–209839. A later post-module Timing Analyzer invocation in the native log reports 201 warnings; do not substitute that later invocation's count for the main STA report. Tool execution success is not timing closure.

## Provenance and remaining work

- Full STA: **48,068,193 bytes**, SHA256 `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6`; compressed copy is 1,204,782 bytes and within the default per-file cap.
- Full fitter: **19,940,793 bytes**, SHA256 `32b311d2216c1675bf1cfc8813b93d1a55346977dd773a674ff9e8bee9b073ad`; compressed copy is 418,793 bytes.
- Raw full fitter/STA reports remain local and ignored; exact gzip copies, summaries and manifest retain reviewable evidence. Historical review-bound inputs are unchanged.

Wait for the **existing** compile's final status, then capture assembly/flow results and programming-artifact identities separately; reuse the already retrieved full STA. Final native rc0, if obtained, still will not clear timing or hardware qualification. No timing experiment, clock change, DDR simulation or dummy-CSR exercise has been started. The agreed hardware data gate remains required; this timing observation is not a request to requalify encrypted vendor internals.

Flash/reboot permission is recorded. Timing/result review, exact deployment/runtime binding and verified independent host recovery remain unresolved; nothing has been flashed, rebooted or exercised through OPAE.
