# Work24 physical acceptance — with findings, offline advance

**Accept the completed Fitter, reported multi-corner numerical timing and assembly for a fresh matching PR/PIM export and persona preparation.** This closes the specific EMIF1 bit243 hold defect under unchanged requirements. It does not grant clean Design Closure, electrical/PR/reset-protocol acceptance, deployment, hardware qualification or migration completion.

Parent consumed both independent reviews after rechecking41/41 frozen members, actual path/summary data and the unchanged81-row clock table. [Physical review42](physical-review42.md), [CPA path review43](cpa-path-review43.md), [parent consumption45](physical-reviews-consumed45.json).

## Accepted experiment and measured outcome

The exact EMIF1 global source consumes **CLOCK_SPINE2** with unchanged `SX0 SY0 SX6 SY7`,56-sector coverage, root ownership and source site. Seed3, Quartus26.1.1 Build130, AGFB027R25A2E2V, both DDR banks, PR/static geometry, operating clocks and signoff SDC remain unchanged. The two new QSF records are the spine request and matching full-region companion; no vendor RTL, latency, uncertainty or timing waiver was introduced. [Reviewed basis](ITERATION-BASIS01.md), [completed allocation](clock-allocation26.json).

| Exact bit243 hold corner | Work23 ns | Work24 ns |
|---|---:|---:|
| Slow vid2 100C | 0.132 | **0.242** |
| Slow vid2b 100C | 0.167 | **0.272** |
| Fast vid2a 0C | 0.047 | **0.118** |
| Fast vid2a 100C | 0.006 | **0.086** |
| Fast vid2 100C | −0.004 | **0.082** |

All five exact transfers retain **No SDC Exception on Path**, the same launch/capture clock pair and zero hold relationship. All788summary records are nonnegative, with the complete Type multiset preserved. Global hold and MPW minima display0.000ns; this is not a claim of positive physical margin everywhere. [Path comparison](exact-transfer-comparison40.json), [coverage review](physical-review42.md#timing-and-coverage).

At the previously failing corner, **+84ps CPA COMP +2ps launch-clock interconnect = +86ps slack**; data delay, required-path terms and physical transfer sites are unchanged. Both compensation roles and all five printed slacks return to Work21 values. Full arc comparisons retain changed fanout and explicitly site/pin-paired reference aliases. This validates the same-version physical correction, not a unique CPA equation, compiler-only defect or measured silicon margin. Work24 feedback-route timing was not separately captured and is not an extra acceptance gate. [Detailed independent comparison](cpa-path-review43.md).

## Full-result checks and retained findings

Native/CMake/effective/outer0, empty postflight errors, no residual native processes and successful assembly are verified. Fresh named-domain checks preserve1891SOURCE/PIM entries,3963Work23 inputs, its four images/intermediates and static QDB. No image was programmed. [Completion](completion-metadata38.json), [preservation](preservation39.json).

The completed report preserves81clock rows,3.000ns EMIF pairs, seven system-PLL outputs/1410MHz VCO, the four-line PCIe divider,146net-delay identities and102skew identities per corner. All110SDC-load rows are OK; fit-only10ps and STA-skip separation are verified. The new clock assignments are not ignored. Whole clock/transfer/pin/geometry comparisons and limits are in [physical-review42](physical-review42.md).

Retain all disclosed findings, including23/88failed DRC rules,4384overlapping violations with zero waivers,1077danglingPR inputs, unconstrained reserved/BMC ports, two missing MPW checks despite clock presence, electrical-setting gaps, synthesis19854/DRC/integration findings and unqualified reset/freeze/quiescence behavior. Clock allocation changed32spines total (31collateral); DDR0 reference-clock region shrank and two reset anchors moved. Positive recovery/removal does not establish reset sequencing. These findings are not erased by closing bit243 and are not newly imposed blockers to the accepted offline preparation step. [Retained findings](physical-review42.md#retained-findings-and-corrected-accounting).

## Warning-accounting correction

The immutable preliminary [RESULT41.md](RESULT41.md) quoted188STA warnings from the later export hook. **Main signoff STA has189;188 belongs to the separate PR-SDC export hook.** Fitter's207ordinary+onecritical report entries plus pre-banner Warning20031 reconcile its209footer count. Full flow is **495synthesis +209fitter +189STA +1assembly =894**; including the separate hook gives1082raw warnings. The parent checked these native log lines and preserved the frozen preliminary/report bytes. [Review42 lines45–51](physical-review42.md), [consumption correction](physical-reviews-consumed45.json).

## Matched-image identity and next boundary

- Interface UUID: **fc603c44-5c8f-5e94-bcbe-a5780030947c**.
- Static QDB SHA256: **dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4**.
- SOF:7836539bytes, SHA256 **16812c62675e31bb7d3bdbdce80e9342c32bb7263c6a862611da427249c85195**.

This is the scalar `qual_vec_op` shell, not a matching CAPS03DDR persona. Proceed with the fresh Work24-bound export, regenerated26.1.1 fabric/PIM integration, RTL simulation and matching persona implementation. Reuse verified unchanged HLS sources and standalone GettingStarted results; do not relabel an old persona UUID or bypass25.1-specific guards. Deployment/card gates remain separate. The full migration goal is not complete.

Raw reports, installed/vendor source, transport payloads, databases and images remain local with hash references; no file over2,000,000bytes or embedded source/binary payload is publishable. Reviewers used disclosed GPT6/openai-codex substitution for unavailableGLM5.3.
