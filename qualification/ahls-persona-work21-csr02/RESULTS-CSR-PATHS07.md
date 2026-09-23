# CSR duplicate-branch query07 — native result; review pending

Native/effective/outer **0/0/0**, all preservation domains true, no timeout or owned survivors. Quartus25.1 reused completed fit01 in a fresh query copy. No RTL, SDC, clock policy, fitter setting or hardware change. All46 payloads verified against archive SHA256 `404650507f9d3f3febf207218574802b3173aa6a24df6f11d143f111050962ff`. The separate local definition-only Tcl probe was NOT RUN because local tclsh was unavailable; this did not launch a failed native attempt. Actual Quartus executed the successor successfully. [Scope](CSR-DUPLICATE-BRANCH-SCOPE07.md), [local preflight](csr-paths07-local-preflight.json), [verification](csr-path-verification07.json).

Two exact duplicate cells, at FF_X259_Y66_N13 and FF_X259_Y69_N26, supplied10 verified singleton pins. Their four D/ENA pins returned **1,200 nonnegative overlapping records across five corners /40 groups**, with zero gaps and zero SCLR-named launches. Group maximum49 is below cap128. Every group's capture set equals the independently traversed fanout-keeper set of its selected pin. All160 detailed path bodies have the actual requested arrival-path pin, matching TSV slack/from/to and No SDC Exception on Path.81 clock tuples match06. Worst-per-capture reporting is not exhaustive pair coverage.

| New through-pin | Worst setup ns | Worst hold ns |
|---|---:|---:|
| length0_duplicate_d | 1.575 | 0.088 |
| length0_duplicate_ena | 1.150 | 0.221 |
| length14_duplicate_d | 1.404 | 0.093 |
| length14_duplicate_ena | 0.954 | 0.268 |

## Old-function → current pin → observed keeper-segment ledger

All names below are suffixes of the exact CSR-manager hierarchy in the native TSV. Detailed source identities and set comparisons are in [verification](csr-path-verification07.json); native evidence is under `artifacts-csr-paths07/csr-path-reports/`.

| Old functional obligation | Current evidence | Disposition |
|---|---|---|
| Length14 contribution to source-side endpoint arithmetic | `length[14]~DUPLICATE.comb` D/ENA fanout includes38 of the52 known `add_0` passthrough keepers and zero `add_2` keepers. Each pin has49 capture objects, including eight previously observed Select admission captures. | Newly observed source-side contribution. Do not relabel it as the nonduplicated add_2 branch. |
| Length14 received payload/update | Duplicate D paths launch from the same MMIO data[14] passthrough keeper as06. Duplicate ENA paths select the same i2852 setup / Select hold launches as06. Immediate ENA driver is the identical i2852 laboutt[8] object. | Payload and enable roles independently distinguished; duplicated branches share control, not all fanout. |
| Original duplicated length0 enable capture | `length[0]~DUPLICATE.comb` ENA has the same immediate i2852 lab_lut6outt[2] driver and selected setup/hold launches as06's nonduplicate. Hold detail reaches the duplicate ENA capture itself. | Actual duplicated enable segment observed; positive timing is bounded to this segment. |
| Length0 duplicate downstream behavior |11 capture objects per pin, including eight shared Select objects, another i919 object, FIFO RAM and the duplicate itself; unlike06's nonduplicate, this is not the104-arithmetic-keeper fanout set. | Real duplication/partitioning difference preserved. |
| Old whole feedback path and all bits | Shared storage nodes and the source-side branch now have explicit native observations, but original cycle/latency equivalence, other old captures and every merge/duplicate are not established. | OPEN. Do not concatenate slacks across sequential boundaries or call the old negative path exhaustively resolved. |

The worst detailed length14 D setup route goes through LessThan/i919/Select admission logic, not necessarily add_0. The native49-path group supplies additional add_0 captures; these are distinct branches, not a single route inferred by concatenation. Native159 warning occurrences remain; no new negative timing was observed in this bounded slice. Full Design Closure remains FAIL and all hardware acceptance gates remain open. Vendor DDR simulation is SKIPPED BY USER.
