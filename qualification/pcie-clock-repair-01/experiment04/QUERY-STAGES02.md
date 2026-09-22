# Query-stage authoring02 — receiver mapping and clock inventory

**Local authoring/tests only. Not full-query, package, native, timing or hardware acceptance.** These definitions extend the unfinished experiment04 query; they do not create or run a vendor project.

## Receiver stage

`receiver-mapping.tcl` reuses the accepted diagnostic03 cell→pins→buried-register pattern, four groups of eight, exact predeclared clock pins, exact singleton register names/types, retained real register collections and conservative-union membership. It inspects known32 and named tile T with `get_clocks -of_objects` on actual collections. Baseline requires their observed empty association; candidate requires exactly C. Source: [diagnostic03 query](../fanout-diagnostic03/prepared-readback01/query.tcl), [source disposition §2–3](../native-mapping-disposition03.md).

Baseline reverse clock fanin must remain K. Candidate records/requires one K or O: [get_fanins -stop_at_clocks](../api-help01/commands/get_fanins.txt) can stop at the newly defined clock target O instead of the old keeper. This finite prospective allowance does not substitute an alternate query root or establish native behavior in advance; exact new-C definition/propagation remain separate guard requirements. Unexpected roots, multiple or empty fanins reject. Full-package review must inspect this candidate-specific representation rule.

`test-receivers.py`: **29 inert cases, rc0, empty stderr**, complete output receivers-tests01.json. Includes baseline/candidate success, candidate O stopping-point case, missing/extra/duplicate groups, physical/timing type errors, pin/cardinality/cap errors, reverse errors, absent/multiple/aliased buried registers, incorrect clocks, manifest and union errors. The synthetic pin-API mock injects caller-frame `pins` array and verifies unchanged sentinel at completion; no native array origin is inferred. Harness collections, pins, physical cells and registers have distinct IDs/namespaces. Initial absent-module red receipt retained. No vendor run.

## Full-SDC clock-inventory comparison

`clock-inventory.tcl` compares supplied native snapshot data to the captured80-clock reference; baseline identities must match, candidate adds exactly C, and every original definition remains equal. List-valued waveforms/targets/generated metadata are canonicalized as Tcl lists for semantic comparison—raw files are never rewritten and numeric strings are not rounded. Exact new-C ratio/source/target/master/waveform checks remain guard02 verify_created_v2's responsibility, not this comparator's.

`test-clock-inventory.py`: **18 local data tests, rc0, empty stderr**, clock-inventory-tests01.json. Uses all80 retained native definitions from [inventory03](../native-baseline-clock-inventory03.json), including original raw waveform strings with trailing whitespace; confirms that raw string comparison differs but the structural comparator passes. Mutations cover added/removed clocks, changed period/waveform/targets/type/metadata, unexpected fields, reference/count bounds. This suite was authored after the comparator; no preimplementation red replay or fresh native snapshot is claimed. The candidate fixture establishes name-set comparison only, not correct new-clock synthesis.

## Remaining integration obligations

Neither stage performs project opening, normal SDC loading, guard entry placement, all-corner report capture, per-node structural/clock coverage outside known32/T, exception/truncation accounting, FIFO numerical acceptance or cross-run A/B assessment. No full-entry sentinel test exists yet. Keep those requirements from IMPLEMENTATION-PLAN.md and the source disposition; do not call these components the complete query.

The unchanged26-case scope suite was replayed once alongside these additions and matched its saved stdout exactly. Guard02 seven-file manifest, consumed SPEC and parent receipt, and rejected predecessor manifest remain unchanged. QUALITY `deleg_1972ffaa` is the current independent guard review; it does not review these new query-stage files or authorize native execution.
