# Work23 completed implementation evidence — accepted with timing rejection

**Accept the completed native implementation and assembly as evidence with findings. Reject numerical timing and deployment.** This closes the review of the seed-3 experiment, not the migration goal. No image was programmed.

The parent consumed [independent result review32](result-review32.md), SHA256 `b9239237dfc7be66d7bc8788e59a03029237e98df568fd255d63d94ba2a2af08`, and reverified all 36 frozen members, the highest-risk native findings and the supplemental preservation capture. [Consumption receipt](reviews-consumed36.json), [frozen result index](result-freeze31.json), [post-run preservation](preservation34.json).

## Accepted observations

- Native/CMake/effective/outer status is 0; Fitter and Assembler completed. No timeout, gate rejection, residual owned group or postflight error was recorded. Completion captured no active vendor process. [Completion metadata](completion-metadata31.json), [completion receipt](completion24-collection.json).
- The native Fitter consumed **seed 3**. The unchanged 3.000 ns requirements, exact bit243 retiming restriction, original floorplan, snapshots, four-line divider and fit-only 10 ps / STA-skip behavior remain evidenced—not a new exception or margin waiver.
- All **788 timing-summary records** are accounted for. Exactly one fails: EMIF1 PHY-l hold **−0.004 ns**, TNS **−0.004 ns**, at Fast vid2 100°C. Exact-transfer slacks remain **+0.132, +0.167, +0.047, +0.006, −0.004 ns** across the five corners, with the same endpoints/clocks and **No SDC Exception on Path**. [Analysis28](timing-analysis28.json).
- The bounded comparison of 49 ordered location/type/increment/total rows per corner matches after one explicitly paired reference-clock duplicate alias. **This excludes fanout: the distribution fanout changes 16,025→15,967. Full native rows and unreported routing are not identical.** [Raw delta29](exact-path-row-delta29.json), [restricted comparison30](seed-disposition30.json), review32 lines33–39.
- All 81 native clock rows and 146 net-delay constraint identities remain. Board PLL remains 1410 MHz VCO with the seven expected outputs. Numerical net-delay margins change, with the new minimum +1.044 ns on the control-shadow FIFO; this is not the same worst constraint as Work22's RX FIFO.

## Findings retained without waiver

- DRC remains **23/88 failed rules, zero waived**, but is not identical: CDC-50001 **13→14**, FLP-40006 **14→15**, TMC-20604 **7→3**; overlapping rule-level violations total **4,380**, not unique defects.
- The new high-severity CDC row is the AHLS MMIO command FIFO write-pointer crossing. Reset-load totals are **1,836 asynchronous / 122 synchronous / 56 enable**. Additional reset-sequence cycles change user-PLL outclk1 **4→6**, PCIe rx_ch15 **4→3**, internal oscillator **2→0**. These are not total reset widths or proof of unsafe/safe operation; positive recovery/removal does not qualify reset sequencing.
- Four electrical-warning pins, all 1,077 dangling PR inputs, PR initialization/freeze, PIM16803, 117 ignored/overridden constraints, 59 empty filters and disclosed unconstrained ports remain. Existing project-approved nonblocking findings are not retroactively new gates for this completed offline trial, and are not silently cleared.
- Synthesis has **494 ordinary + one critical** records. Fitter has **207 ordinary + one critical** versus its 209-warning footer: the one-record gap remains unresolved. STA's **189+2=191** reconciles. Assembly has the one legacy GENERATE_RBF_FILE warning20536. Native zero does not erase those findings. Detailed original line citations are in review32.

## Artifact identities and preservation

- SOF: **7,843,324 bytes**, SHA256 `6d149d05ec82587f4f61e0e78ba470d3058da0f1263b2d339ecaea7d61c374c9`; **undeployable while timing fails**.
- FME interface UUID: `c39acdc5-cde0-5256-ae78-1ae9a71266e6`, consistent in the captured metadata and MIF; not a programmed-image or compatible-persona claim.
- After the full compile, the named original SOURCE/PIM 1,891-entry inventory, Work22's 3,963 inputs, four images/intermediates and static QDB were rechecked unchanged. No broader unrecorded whole-tree claim is made.

## Consequence

Seed 3 did not repair seed 2's exact failure. **Stop blind seed iterations; no programming, margin inflation, exception or vendor-PHY override follows.** Subsequent CPA diagnostics are a separate acquisition/investigation, not accepted here. Their purpose is to explain the reported compensation difference while preserving clock requirements; no supported correction has yet been established.

Persona compatibility, electrical/PR/PIM/reset behavior and all migrated hardware/DDR gates remain unaccepted. The fallback release and `main` remain untouched. Large native reports, transport payloads, databases and programming images stay local-only with exact hash references.
