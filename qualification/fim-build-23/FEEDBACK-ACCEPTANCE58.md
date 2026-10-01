# CPA feedback diagnostics — accepted observations, unresolved correction

**Accept the three completed observations with their limits. No timing correction or deployment acceptance is established.** The migration remains blocked by the exact −0.004 ns EMIF1 hold failure under the required26.1.1 configuration.

The parent consumed [independent feedback review52](feedback-review52.md), SHA256 `db8c24548d792bf1bb49b2dd5c279bd5500a642e2396f965d204937c6a8ab5c5`, and reverified all64 frozen file identities, all three completion/preservation receipts, PHY full-row equality and the core fanout/topology distinction. [Consumption56](feedback-review-consumed56.json), [frozen evidence51](feedback-result-freeze51.json).

## Scope actually accepted

- Attempts37,41 and46 completed with effective/supervised-CMake/outer status0, no abort, confirmed termination and no remaining owned group. Each direct native target's log also records successful Timing Analyzer completion,0 errors/192 warnings. The historical field named `native_rc` records the supervised CMake exit; nonzero CMake would not identify the exact vendor exit. This is not warning-free signoff.
- Each query used a separate preserved copy and its original tool version: Work23 under26.1.1 and Work21 under25.1.0. The original Work/PIM file-hash/link inventories remained unchanged. No new fit, image generation, programming, reset, hardware probe or toolchain replacement occurred.
- All queried paths identify final snapshot / Fast vid2 100C. Work23's anchor reproduced−0.004 ns and Work21's anchor reproduced+0.082 ns.
- Attempt37's board-reference-to-PHY zero-path result is an acquisition gap, not zero delay or physical absence. Attempt41's bounded upstream-keeper query resolves that path scope; its actual start is PLL `lvds_clk[0]`.
- Eight matched extrema per build were measured, not exhaustive route coverage. Core queries constrain both endpoint polarities; PHY queries constrain destination polarity and report the actual source.

## Result and limits

The [comparison50](feedback-comparison50.json) and [observation table55](CPA-FEEDBACK-OBSERVATIONS55.md) give all values. Core extrema change by only1–5 ps; all PHY route fields, including fanout, are identical. Core routes genuinely differ:58→57 rows, DCM muxI27→I29 and changed branches/fanout. Empty `changed_fields` for structurally unequal paths does not mean no fields changed.

The anchor comparison independently reconciles the−86 ps signoff change as−84 ps CPA COMP and−2 ps launch-clock interconnect. Data delay and required time remain equal. **The measured raw feedback extrema do not explain how COMP was produced.** There is no established mapping from these extrema to that compensation value; arbitrary min/max/mean selection would invent an equation. Implementation-dependent nonlinear/discrete response, nominal/early-late treatment and effective internal settings remain unresolved. No compiler-defect or impossibility claim is made.

The generated-source phase/mux facts remain evidence of requested connectivity/configuration, not every effective internal parameter. The installed tool has no verified output-specific CPA calculation command. `report_clock_network -initial_depth` is GUI collapse, not a bounded-query limit, and was not used to expand the whole clock fanout.

## Remaining dependency and stop boundary

Obtain a supported calculation/decomposition for this exact output, identifying reference planes/detector endpoints, edge/divider relationship, nominal versus early/late treatment and effective internal settings, and reproducing both COMP values without fitted constants. Applicable implementation-source evidence, vendor model-owner guidance or a documented26.1.1 correction/patch could resolve that gap.

**No further blind experiment is justified by these results.** Do not reopen the closed eSRAM/force-Hyper-Register workaround branch, change CPA phase controls, inflate margins, waive4ps, change the pinned tool target, or program a failed image. The required supported correction has not been found.

A [support-request draft](CPA-SUPPORT-DRAFT57.md) and verified24-member report packet were prepared locally. Nothing was sent or uploaded. A request for support access/contact/case/patch information was cancelled without an answer; availability remains **unknown**, not "no support channel." Further action needs applicable evidence or an explicit scope decision. The qualified fallback remains untouched.
