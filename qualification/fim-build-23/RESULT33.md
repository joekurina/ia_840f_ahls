# Work23 seed-3 result — timing failure persists

**Parent disposition: REJECT timing and deployment.** Changing the actual Fitter seed from 2 to 3 did not fix the exact EMIF1 bit243 hold failure. The full compile completed normally; no image was programmed. Independent result review and a focused clock-compensation investigation are pending, not yet accepted.

## Actual execution

The compile finished at `2026-10-01T20:20:48.529663+00:00`, with native/CMake/effective/outer status 0, no timeout, no gate rejection and no remaining owned group. The completion waiter independently read outer 0. Assembler reports Successful, 0 errors / 1 warning. A final ordinary-file capture at 20:22:26Z found no active vendor process. [Completion receipt](completion24-collection.json), [payload-free metadata](completion-metadata31.json), [completion event](compile07-completion-event.json).

Fitter Settings explicitly reports **initial placement seed 3**, not the default-column value 1. The report is in the complete nine-member [timing capture](timing22-collection.json). The original seed-2 attempt remains preserved; the declared setting change was actually consumed.

## Timing result

All **788** summary records were parsed; exactly one fails: EMIF1 PHY-l hold **−0.004 ns**, TNS **−0.004 ns**, Fast vid2 100°C. Other summary records are nonnegative, which does not waive this failure. [Complete parsed summary and comparison](timing-analysis28.json).

| Exact EMIF1 bit243 transfer corner | Work22, seed 2 | Work23, seed 3 |
|---|---:|---:|
| Slow vid2 100°C | +0.132 ns | +0.132 ns |
| Slow vid2b 100°C | +0.167 ns | +0.167 ns |
| Fast vid2a 0°C | +0.047 ns | +0.047 ns |
| Fast vid2a 100°C | +0.006 ns | +0.006 ns |
| Fast vid2 100°C | **−0.004 ns** | **−0.004 ns** |

Every compared path has the same launch/capture and clock identities and **No SDC Exception on Path**. The Hyper-Register, UFI and PHY sites remain `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32`, `UFI_X210_Y0_N355` and `IO12LANE_X184_Y0_N374`.

The raw row comparison is **not byte-identical**: the reference-clock label changes from `pll_inst~refclk_Duplicate` to `pll_inst~refclk_Duplicate_3`. Both label sets are at `REFCLKINPUT_X172_Y0_N301`, with the same three pin roles in arrival and required paths. After only that explicit six-row-per-corner alias pairing, all **49 ordered reported location/type/increment/total rows per corner** match. Raw differences remain in [row delta29](exact-path-row-delta29.json); the restricted pairing and conclusion are in [seed disposition30](seed-disposition30.json). This is not a claim about unreported routing resources or Boolean equivalence.

At the failing corner, arrival/required remain **2.964 / 2.968 ns**, data delay **0.288 ns**, and the clock-compensation and clock-interconnect terms remain unchanged. The passing Work21 / Quartus25.1 comparison retains a **0.086 ns** advantage: **0.084 ns from COMP** at `pa_core_clk_out[0]` and **0.002 ns from launch-clock interconnect**. The five-corner decomposition is retained in [reference comparison18](reference-clock-compensation18.json). This is a specific investigation lead, not isolated proof of a compiler defect.

## Preserved artifacts and scope

- Work23 SOF: `6d149d05ec82587f4f61e0e78ba470d3058da0f1263b2d339ecaea7d61c374c9`, 7,843,324 bytes; **not accepted for programming**.
- Generated FME interface identity: `c39acdc5-cde0-5256-ae78-1ae9a71266e6`; not a programmed-image or persona-compatibility claim.
- Post-run [preservation34](preservation34.json) rechecked 1,891 original SOURCE/PIM entries, 3,963 original Work22 input entries, its four images/intermediates and static QDB. All match; no unrecorded whole-tree claim.
- Synthesis retains 494 ordinary warning records plus Critical19854. Its complete diagnostic multiset matches Work22 after explicitly pairing WORK-root and synthesis-PID temporary paths; the warnings are not cleared. [Comparison16](synthesis-comparison16.json), [path disposition17](synthesis-path-disposition17.json).
- Electrical, PR/freeze/reset, PIM, persona and all migrated real-card gates remain unaccepted. The fallback release and `main` remain unchanged.

## Next action

Stop blind seed iteration. Do not inflate the hold margin, add a path exception, change clock requirements, alter vendor PHY RTL or program either failed image. Consume the independent result review and the focused investigation of what determines the COMP term and whether a supported requirement-preserving correction exists. The prior eSRAM delay-chain workaround is not an EMIF remedy; already enabled aggressive hold/maximum effort must not be re-proposed as a new experiment. The migration goal is still unmet.
