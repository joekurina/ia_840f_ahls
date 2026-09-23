# CSR data/enable pin query06 — representative native paths obtained

Native/effective/outer **0/0/0**, all four preservation domains true, no timeout/owned survivors. Source is the same completed fit01; no RTL/SDC/clock-policy change. Archive SHA256 `6be3c55b4e7a76c1e2c678c894716cf1ee0e3d0f7a226c06819bcc493aee1275`. All 66 exported payloads, 5,750 critical bindings and 344 protected physical paths verified. [Verification](csr-path-verification06.json).

Four exact fitted seeds at their prior locations: source endpoint bit38, destination endpoint bit37, descriptor length bits14 and0. Cell-derived pin collections supply all18 pins. Documented collection subtraction intersects these with simple role-suffix collections, avoiding failed bus-name glob lookups. Every intersection matched exactly one enumerated pin name. All-edge pin neighborhoods are separate from05's synchronous-edge unions; edge types/disabling remain explicit.

Six identified data/enable pins were used as real pin collections in native `-through` queries: source/destination D, and both D/ENA pins of the two length cells. Across five corners and setup/hold: **3,100 nonnegative path-record occurrences, 60 nonempty groups, zero query gaps, no SCLR launches**. Each PATHCOUNT reconciles with TSV rows; maximum106 versus cap128. These overlap and are not3,100 distinct physical paths. Native detail preserves four worst paths per group; all60reports contain their actual requested through-pin. 81 clock tuples match05; returned setup/hold relationships3.000/0.000ns with ordinary1/1 and0/0 multicycle fields.

| Representative through-pin | Worst setup ns | Worst hold ns |
|---|---:|---:|
| destination37_d | 0.637 | 0.754 |
| length0_d | 1.367 | 0.088 |
| length0_ena | 0.915 | 0.221 |
| length14_d | 1.223 | 0.093 |
| length14_ena | 0.704 | 0.268 |
| source38_d | 0.766 | 0.684 |

The source/destination paths now launch from actual address/arithmetic passthrough storage, pass through arithmetic sumout and bypassed endpoint D→Q, and reach admission-related retimed storage; unlike03/04 they do not substitute SCLR control. Length D paths launch from MMIO data passthrough storage, while ENA paths launch from retimed control/admission candidates. This supplies representative data/enable evidence, not a one-to-one equivalence theorem for every old source register or all transformed bits.

The task is NOT full timing/design/hardware acceptance. Independent specification/quality review is pending. Original negative-path identity, retimed split-segment interpretation, all-bit/source-equivalent coverage, reset/CDC/exception, metadata/freeze/drain/fence and Design Closure FAIL remain explicit obligations. Vendor DDR simulation is SKIPPED BY USER.
