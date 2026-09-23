# Work21 completed-build result acceptance

**ACCEPT fit, assembly and reported constrained numerical STA WITH FINDINGS. The historical EMIF1 −0.004 ns hold failure is RESOLVED for this exact Work21 build. Overall hardware qualification remains OPEN.**

## Evidence consumed

The parent consumed the FINAL [independent review](final-review01.md), SHA256 `ce26e582872bb0e2f0e8701ef3d5ac28749e5a1caf73590dba4841088522f2d4`, and recorded [verification](parent-final-verification01.json). It rehashed all 19 final native members and their archive, all five synthesis reports, and the ten cited source files. It independently parsed 778 nonnegative numerical STA summary records and compared the exact historical hold transfer at all five corners. These are summary records, not exhaustive individual-path coverage. [Native capture manifest](final-capture01/manifest.json).

Work21 completed under Quartus Prime Pro 25.1.0 Build 129 SC Pro for AGFB027R25A2E2V, native rc 0, **0 errors / 1,183 warnings**. The consumed authorization remains `793eece9892980e7c7bb0daa383a47838c21c1fd679768c033eb6db6038060a8`; no relaunch is authorized by this acceptance. [Current checkpoint](CURRENT.md), [native status](final-capture01/runner/run/native-status.json).

## Closed numerical blocker

The same `amm_writedata_0_r[0][243]` to `lane_inst~phy_reg1` hold transfer passes all five corners. Its worst slack changes from **−0.004 ns to +0.082 ns**, an improvement of **0.086 ns**. The top-level SDC is byte-identical to Work18; final STA explicitly skips the fit-only margin and every paired detail says **No SDC Exception on Path**. The launch remains a Hyper-Register. This result does not establish that the retiming-OFF assignment caused the improvement. [Independent exact-path analysis](final-review01.md#2-the-exact-emif1-failure-is-numerically-resolved), [parent comparison](parent-final-verification01.json).

Accept completed fitting and assembly and the reported constrained numerical STA. Do not rerun an unchanged fit or increase hold margins to address a failure that this exact build no longer has. Do not change immutable launch-time pending-review receipts or conflate numerical acceptance with readiness flags.

## Retained holds — no waivers

- **Timing/CDC coverage:** Unconstrained Paths FAIL; the named ports are reserved JTAG TDI/TMS/TDO and `bwbmc_bmc_irq`. Signoff has **23 of 88 failed rules, 4,393 overlapping rule-level violation occurrences, zero waived**. Active clock/reset/exception findings require source/effective-constraint disposition; occurrences are not a count of distinct defects. [Review §3](final-review01.md#3-numerical-sta-versus-timingcdc-coverage).
- **PR and future DDR persona:** the final PR region is populated, but **1,076 dangling inputs** remain (537 per DDR bank plus two debug inputs). Initialization warning 19854 and boundary warning 20727 are not cleared by fit or area retention. The scalar AFU intentionally idles memory; future memory-persona interface retention and reset/first-use behavior are unqualified. [Review §4](final-review01.md#4-pr-retained-but-later-ddr-persona-not-qualified).
- **Electrical:** warning 15714 names `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n` and `bwbmc_fpga_max_miso` for missing termination/slew settings. Fitted defaults exist, but their board adequacy is not established or disproved. No arbitrary pin-setting change is accepted. [Review §5](final-review01.md#5-electrical-and-image-boundaries).
- **Synthesis diagnostics:** retain the [bounded synthesis findings](synthesis-review02.md), including the unused 40-bit export connected to an implicit one-bit top net and unresolved native-versus-textual warning counts. No active internal MSI-X truncation failure has been demonstrated.
- **Deployment and function:** captured image hashes are remote inventory identities, not local image-byte rehashes or deployment acceptance. The base green RBF is not a qualified persona GBS. OPAE/DFL, DMA/PIM integration, both DDR channels, numerical execution, sustained operation and QSPI boot after power cycle remain unqualified. **DDR simulation is SKIPPED BY USER.** No hardware operation, source correction or new native execution was performed to consume this review.

The next FIM checks are bounded source/effective-constraint disposition, required PR memory/debug boundary retention, concrete PR initialization cases and board-supported BMC electrical requirements. Ordinary offline AFU work may proceed under existing authority; live FPGA operations retain their separate safety and recovery prerequisites.
